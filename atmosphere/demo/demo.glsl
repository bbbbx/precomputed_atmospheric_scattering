/**
 * Copyright (c) 2017 Eric Bruneton
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the copyright holders nor the names of its
 *    contributors may be used to endorse or promote products derived from
 *    this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 * THE POSSIBILITY OF SUCH DAMAGE.
 */

/*<h2>atmosphere/demo/demo.glsl</h2>

<details>
<summary>本 GLSL 片段着色器用于渲染我们的 demo 场景，它由一个位于球体行星 P 上的球体 S 组成。
本 demo 通过 "ray tracing" 渲染，即单独着色器输出 view ray 的方向，
而片段着色器计算该 ray 和 球体 S、行星 P 的交点来产出最后的像素。
该片段着色器还计算了 light rays 和球体 S 的交点来计算阴影，
还计算了 view ray 和 S 的 shadow volume 的交点，以便计算 light shafts。
</summary>
<p>This GLSL fragment shader is used to render our demo scene, which consists of
a sphere S on a purely spherical planet P. It is rendered by "ray tracing", i.e.
the vertex shader outputs the view ray direction, and the fragment shader
computes the intersection of this ray with the spheres S and P to produce the
final pixels. The fragment shader also computes the intersection of the light
rays with the sphere S, to compute shadows, as well as the intersections of the
view ray with the shadow volume of S, in order to compute light shafts.
</details>

<details>
<summary>我们的片段着色器具有以下输入和输出：
</summary>
<p>Our fragment shader has the following inputs and outputs:
</details>
*/

uniform vec3 camera;
uniform float exposure;
uniform vec3 white_point;
uniform vec3 earth_center;
uniform vec3 sun_direction;
uniform vec2 sun_size;
in vec3 view_ray;
layout(location = 0) out vec4 color;

/*
<details>
<summary>它使用下列在外部定义的（通过 <code>Model</code> 的 <code>GetShader()</code> 着色器）
常量和大气渲染函数。
<code>USE_LUMINANCE</code> 选项用于选择函数是返回辐射度值还是返回亮度值
（见 <a href="../model.h.html">model.h</a>）。
</summary>
<p>It uses the following constants, as well as the following atmosphere
rendering functions, defined externally (by the <code>Model</code>'s
<code>GetShader()</code> shader). The <code>USE_LUMINANCE</code> option is used
to select either the functions returning radiance values, or those returning
luminance values (see <a href="../model.h.html">model.h</a>).
</details>
*/

const float PI = 3.14159265;
const vec3 kSphereCenter = vec3(0.0, 0.0, 1000.0) / kLengthUnitInMeters;
const float kSphereRadius = 1000.0 / kLengthUnitInMeters;
const vec3 kSphereAlbedo = vec3(0.8);
const vec3 kGroundAlbedo = vec3(0.0, 0.0, 0.04);

#ifdef USE_LUMINANCE
#define GetSolarRadiance GetSolarLuminance
#define GetSkyRadiance GetSkyLuminance
#define GetSkyRadianceToPoint GetSkyLuminanceToPoint
#define GetSunAndSkyIrradiance GetSunAndSkyIlluminance
#endif

vec3 GetSolarRadiance();
vec3 GetSkyRadiance(vec3 camera, vec3 view_ray, float shadow_length,
    vec3 sun_direction, out vec3 transmittance);
vec3 GetSkyRadianceToPoint(vec3 camera, vec3 point, float shadow_length,
    vec3 sun_direction, out vec3 transmittance);
vec3 GetSunAndSkyIrradiance(
    vec3 p, vec3 normal, vec3 sun_direction, out vec3 sky_irradiance);

/*<h3>Shadows and light shafts</h3>
<h3>阴影和光轴</h3>

<details>
<summary>计算阴影和光轴的函数必须在 main 函数之前定义，所以我们先定义他们。
检测一个点是否位于球体 S 的引用内等价于测试对应的 light ray 是否和球体相交，这是非常简单的。
但是，这只能用于 punctual 光源，太阳光不是 punctual 光源。
在下列的函数中，我们通过考虑太阳的 angular size 来计算一个近似的（和有偏差的）软阴影：
</summary>
<p>The functions to compute shadows and light shafts must be defined before we
can use them in the main shader function, so we define them first. Testing if
a point is in the shadow of the sphere S is equivalent to test if the
corresponding light ray intersects the sphere, which is very simple to do.
However, this is only valid for a punctual light source, which is not the case
of the Sun. In the following function we compute an approximate (and biased)
soft shadow by taking the angular size of the Sun into account:
</details>
*/

float GetSunVisibility(vec3 point, vec3 sun_direction) {
  vec3 p = point - kSphereCenter;
  float p_dot_v = dot(p, sun_direction);
  float p_dot_p = dot(p, p);
  float ray_sphere_center_squared_distance = p_dot_p - p_dot_v * p_dot_v;
  float distance_to_intersection = -p_dot_v - sqrt(
      kSphereRadius * kSphereRadius - ray_sphere_center_squared_distance);
  if (distance_to_intersection > 0.0) {
    // Compute the distance between the view ray and the sphere, and the
    // corresponding (tangent of the) subtended angle. Finally, use this to
    // compute an approximate sun visibility.
    float ray_sphere_distance =
        kSphereRadius - sqrt(ray_sphere_center_squared_distance);
    float ray_sphere_angular_distance = -ray_sphere_distance / p_dot_v;
    return smoothstep(1.0, 0.0, ray_sphere_angular_distance / sun_size.x);
  }
  return 1.0;
}

/*
<details>
<summary>该球体还部分遮挡了天空光，我们用一个环境遮挡因子来近似这种效果。
由球体引起的环境遮挡因子在 <a href=
"http://webserver.dmt.upm.es/~isidoro/tc3/Radiation%20View%20factors.pdf"
>Radiation View Factors</a> (Isidoro Martinez, 1995) 中给出。
在球体完全可见的简单情况下，它由以下函数给出：
</summary>
<p>The sphere also partially occludes the sky light, and we approximate this
effect with an ambient occlusion factor. The ambient occlusion factor due to a
sphere is given in <a href=
"http://webserver.dmt.upm.es/~isidoro/tc3/Radiation%20View%20factors.pdf"
>Radiation View Factors</a> (Isidoro Martinez, 1995). In the simple case where
the sphere is fully visible, it is given by the following function:
</details>
*/

float GetSkyVisibility(vec3 point) {
  vec3 p = point - kSphereCenter;
  float p_dot_p = dot(p, p);
  return
      1.0 + p.z / sqrt(p_dot_p) * kSphereRadius * kSphereRadius / p_dot_p;
}

/*
<details>
<summary>为了计算光轴，我们需要计算 view ray 与球体 S 的 shadow volume 的交点。
由于太阳不是 punctual 光源，所以这个 shadow volume 不是圆柱体而是圆锥体
（对于 umbra，加上另一个圆锥体作为 penumbra，但我们在这里忽略它）：
</summary>
<p>To compute light shafts we need the intersections of the view ray with the
shadow volume of the sphere S. Since the Sun is not a punctual light source this
shadow volume is not a cylinder but a cone (for the umbra, plus another cone for
the penumbra, but we ignore it here):
</details>

<svg width="505px" height="200px">
  <style type="text/css"><![CDATA[
    circle { fill: #000000; stroke: none; }
    path { fill: none; stroke: #000000; }
    text { font-size: 16px; font-style: normal; font-family: Sans; }
    .vector { font-weight: bold; }
  ]]></style>
  <path d="m 10,75 455,120"/>
  <path d="m 10,125 455,-120"/>
  <path d="m 120,50 160,130"/>
  <path d="m 138,70 7,0 0,-7"/>
  <path d="m 410,65 40,0 m -5,-5 5,5 -5,5"/>
  <path d="m 20,100 430,0" style="stroke-dasharray:8,4,2,4;"/>
  <path d="m 255,25 0,155" style="stroke-dasharray:2,2;"/>
  <path d="m 280,160 -25,0" style="stroke-dasharray:2,2;"/>
  <path d="m 255,140 60,0" style="stroke-dasharray:2,2;"/>
  <path d="m 300,105 5,-5 5,5 m -5,-5 0,40 m -5,-5 5,5 5,-5"/>
  <path d="m 265,105 5,-5 5,5 m -5,-5 0,60 m -5,-5 5,5 5,-5"/>
  <path d="m 260,80 -5,5 5,5 m -5,-5 85,0 m -5,5 5,-5 -5,-5"/>
  <path d="m 335,95 5,5 5,-5 m -5,5 0,-60 m -5,5 5,-5 5,5"/>
  <path d="m 50,100 a 50,50 0 0 1 2,-14" style="stroke-dasharray:2,1;"/>
  <circle cx="340" cy="100" r="60" style="fill: none; stroke: #000000;"/>
  <circle cx="340" cy="100" r="2.5"/>
  <circle cx="255" cy="160" r="2.5"/>
  <circle cx="120" cy="50" r="2.5"/>
  <text x="105" y="45" class="vector">p</text>
  <text x="240" y="170" class="vector">q</text>
  <text x="425" y="55" class="vector">s</text>
  <text x="135" y="55" class="vector">v</text>
  <text x="345" y="75">R</text>
  <text x="275" y="135">r</text>
  <text x="310" y="125">ρ</text>
  <text x="215" y="120">d</text>
  <text x="290" y="80">δ</text>
  <text x="30" y="95">α</text>
</svg>

<details>
<summary>注意，如上图所示，$\bp$ 点是相机的位置，$\bv$ 和 $\bs$ 分别是 view ray 和太阳方向单位向量，
而 $R$ 是球体的半径（假设中心点位于原点），距离相机 $d$ 的点 $\bq=\bp+d\bv$。
该点与球心沿本影锥轴的距离为 $\delta=-\bq\cdot\bs$，且点 $\bq$ 与该轴的距离 $\br$ 满足
$r^2=\bq\cdot\bq-\delta^2$。最后，在沿轴距离 $\delta$ 处，本影圆锥的半径为
$\rho=R-\delta\tan\alpha$，其中 $\alpha$ 是太阳的半径张角。
仅当 $r^2=\rho^2$ 时，距离相机 $d$ 的点才位于 shadow cone 上。即仅当
\begin{equation}
(\bp+d\bv)\cdot(\bp+d\bv)-((\bp+d\bv)\cdot\bs)^2=
(R+((\bp+d\bv)\cdot\bs)\tan\alpha)^2
\end{equation}
的时候。这可以推导出一个 $d$ 的二次方程：
\begin{equation}
ad^2+2bd+c=0
\end{equation}
其中：
<ul>
<li>$a=1-l(\bv\cdot\bs)^2$,</li>
<li>$b=\bp\cdot\bv-l(\bp\cdot\bs)(\bv\cdot\bs)-\tan(\alpha)R(\bv\cdot\bs)$,</li>
<li>$c=\bp\cdot\bp-l(\bp\cdot\bs)^2-2\tan(\alpha)R(\bp\cdot\bs)-R^2$,</li>
<li>$l=1+\tan^2\alpha$</li>
</ul>
为此，我们可以为 $d$ 算出 2 个可能的解，它们必须被 clamped 到圆锥的真正阴影部分内
（即必须是球体中心到圆锥顶之间，也就是这些点的 $\delta$ 必须位于 $0$ 到 $R/\tan\alpha$ 之间）。
下列的函数实现了这些方程：
</summary>
<p>Noting, as in the above figure, $\bp$ the camera position, $\bv$ and $\bs$
the unit view ray and sun direction vectors and $R$ the sphere radius (supposed
to be centered on the origin), the point at distance $d$ from the camera is
$\bq=\bp+d\bv$. This point is at a distance $\delta=-\bq\cdot\bs$ from the
sphere center along the umbra cone axis, and at a distance $r$ from this axis
given by $r^2=\bq\cdot\bq-\delta^2$. Finally, at distance $\delta$ along the
axis the umbra cone has radius $\rho=R-\delta\tan\alpha$, where $\alpha$ is
the Sun's angular radius. The point at distance $d$ from the camera is on the
shadow cone only if $r^2=\rho^2$, i.e. only if
\begin{equation}
(\bp+d\bv)\cdot(\bp+d\bv)-((\bp+d\bv)\cdot\bs)^2=
(R+((\bp+d\bv)\cdot\bs)\tan\alpha)^2
\end{equation}
Developping this gives a quadratic equation for $d$:
\begin{equation}
ad^2+2bd+c=0
\end{equation}
where
<ul>
<li>$a=1-l(\bv\cdot\bs)^2$,</li>
<li>$b=\bp\cdot\bv-l(\bp\cdot\bs)(\bv\cdot\bs)-\tan(\alpha)R(\bv\cdot\bs)$,</li>
<li>$c=\bp\cdot\bp-l(\bp\cdot\bs)^2-2\tan(\alpha)R(\bp\cdot\bs)-R^2$,</li>
<li>$l=1+\tan^2\alpha$</li>
</ul>
From this we deduce the two possible solutions for $d$, which must be clamped to
the actual shadow part of the mathematical cone (i.e. the slab between the
sphere center and the cone apex or, in other words, the points for which
$\delta$ is between $0$ and $R/\tan\alpha$). The following function implements
these equations:
</details>
*/

void GetSphereShadowInOut(vec3 view_direction, vec3 sun_direction,
    out float d_in, out float d_out) {
  vec3 pos = camera - kSphereCenter;
  float pos_dot_sun = dot(pos, sun_direction);
  float view_dot_sun = dot(view_direction, sun_direction);
  float k = sun_size.x;
  float l = 1.0 + k * k;
  float a = 1.0 - l * view_dot_sun * view_dot_sun;
  float b = dot(pos, view_direction) - l * pos_dot_sun * view_dot_sun -
      k * kSphereRadius * view_dot_sun;
  float c = dot(pos, pos) - l * pos_dot_sun * pos_dot_sun -
      2.0 * k * kSphereRadius * pos_dot_sun - kSphereRadius * kSphereRadius;
  float discriminant = b * b - a * c;
  if (discriminant > 0.0) {
    d_in = max(0.0, (-b - sqrt(discriminant)) / a);
    d_out = (-b + sqrt(discriminant)) / a;
    // The values of d for which delta is equal to 0 and kSphereRadius / k.
    float d_base = -pos_dot_sun / view_dot_sun;
    float d_apex = -(pos_dot_sun + kSphereRadius / k) / view_dot_sun;
    if (view_dot_sun > 0.0) {
      d_in = max(d_in, d_apex);
      d_out = a > 0.0 ? min(d_out, d_base) : d_base;
    } else {
      d_in = a > 0.0 ? max(d_in, d_base) : d_base;
      d_out = min(d_out, d_apex);
    }
  } else {
    d_in = 0.0;
    d_out = 0.0;
  }
}

/*<h3>Main shading function</h3>
<h3>Main 函数</h3>


<details>
<summary>有了这些函数，我们现在可以实现 main 函数了，它会计算指定 view ray 的场景辐射度。
该函数首先测试 view ray 是否和球体 S 相交。如果相交，则它会计算球体在交点处接收到的
太阳和天空光，和球体 BRDF，还有相机和球体之间的空气透视组合到一起。
然后对地面做相同的事情，即对行星球体 P，然后计算天空辐射度和透射率。
最后，把所有的这些项组合到一起（还会使用近似的 view cone - sphere 相交因子来为每个物体计算不透明度），
得到最终的辐射度。
<p>我们从计算 view ray 和球体的 shadow volume 相交开始，
因为需要它们来得到球体和行星和空气透视：
</p>
</summary>
<p>Using these functions we can now implement the main shader function, which
computes the radiance from the scene for a given view ray. This function first
tests if the view ray intersects the sphere S. If so it computes the sun and
sky light received by the sphere at the intersection point, combines this with
the sphere BRDF and the aerial perspective between the camera and the sphere.
It then does the same with the ground, i.e. with the planet sphere P, and then
computes the sky radiance and transmittance. Finally, all these terms are
composited together (an opacity is also computed for each object, using an
approximate view cone - sphere intersection factor) to get the final radiance.

<p>We start with the computation of the intersections of the view ray with the
shadow volume of the sphere, because they are needed to get the aerial
perspective for the sphere and the planet:
</details>
*/

void main() {
  // Normalized view direction vector.
  vec3 view_direction = normalize(view_ray);
  // Tangent of the angle subtended by this fragment.
  // 该 fragment 的对角 fragment 和该 view rawy 的正切
  float fragment_angular_size =
      length(dFdx(view_ray) + dFdy(view_ray)) / length(view_ray);

  float shadow_in;
  float shadow_out;
  GetSphereShadowInOut(view_direction, sun_direction, shadow_in, shadow_out);

  // Hack to fade out light shafts when the Sun is very close to the horizon.
  // 当太阳非常接近地平线时，淡出光轴，是一种 hack。
  float lightshaft_fadein_hack = smoothstep(
      0.02, 0.04, dot(normalize(camera - earth_center), sun_direction));

/*
<details>
<summary>然后我们测试 view ray 是否和球体 S 相交。
如果相交，则我们用和 <code>GetSunVisibility</code> 相同的方法计算一个近似的（和有偏差的）不透明度：
</summary>
<p>We then test whether the view ray intersects the sphere S or not. If it does,
we compute an approximate (and biased) opacity value, using the same
approximation as in <code>GetSunVisibility</code>:
</details>
*/

  // Compute the distance between the view ray line and the sphere center,
  // and the distance between the camera and the intersection of the view
  // ray with the sphere (or NaN if there is no intersection).
  // 计算 view ray line 到球体中心点的距离，和相机到
  // view ray 与球体相交点的距离（如果没有交点则是 NaN）
  vec3 p = camera - kSphereCenter;
  float p_dot_v = dot(p, view_direction);
  float p_dot_p = dot(p, p);
  float ray_sphere_center_squared_distance = p_dot_p - p_dot_v * p_dot_v;
  float distance_to_intersection = -p_dot_v - sqrt(
      kSphereRadius * kSphereRadius - ray_sphere_center_squared_distance);

  // Compute the radiance reflected by the sphere, if the ray intersects it.
  // 如果 view ray 和球体相交，则计算被球体反射的辐射度
  float sphere_alpha = 0.0;
  vec3 sphere_radiance = vec3(0.0);
  if (distance_to_intersection > 0.0) {
    // Compute the distance between the view ray and the sphere, and the
    // corresponding (tangent of the) subtended angle. Finally, use this to
    // compute the approximate analytic antialiasing factor sphere_alpha.
    // 计算 view ray 和球体的距离，和对应对角 fragment 的角度。
    // 最后，我们用这个来计算一个近似的解析抗锯齿因子 sphere_alpha。
    float ray_sphere_distance =
        kSphereRadius - sqrt(ray_sphere_center_squared_distance);
    float ray_sphere_angular_distance = -ray_sphere_distance / p_dot_v;
    sphere_alpha =
        min(ray_sphere_angular_distance / fragment_angular_size, 1.0);

/*
<details>
<summary>然后我们可以计算交点和它的法线，然后用它们来得到交点处的太阳和天空的辐射度。
通过将辐照度乘以球体 BRDF，被反射的辐射度如下：
</summary>
<p>We can then compute the intersection point and its normal, and use them to
get the sun and sky irradiance received at this point. The reflected radiance
follows, by multiplying the irradiance with the sphere BRDF:
</details>
*/
    vec3 point = camera + view_direction * distance_to_intersection;
    vec3 normal = normalize(point - kSphereCenter);

    // Compute the radiance reflected by the sphere.
    // 计算被球体反射的辐射度。
    vec3 sky_irradiance;
    vec3 sun_irradiance = GetSunAndSkyIrradiance(
        point - earth_center, normal, sun_direction, sky_irradiance);
    sphere_radiance =
        kSphereAlbedo * (1.0 / PI) * (sun_irradiance + sky_irradiance);

/*
<details>
<summary>最后，我们考虑相机和球体之间的空气透视，它取决于位于阴影内的线段的长度：
</summary>
<p>Finally, we take into account the aerial perspective between the camera and
the sphere, which depends on the length of this segment which is in shadow:
</details>
*/
    float shadow_length =
        max(0.0, min(shadow_out, distance_to_intersection) - shadow_in) *
        lightshaft_fadein_hack;
    vec3 transmittance;
    vec3 in_scatter = GetSkyRadianceToPoint(camera - earth_center,
        point - earth_center, shadow_length, sun_direction, transmittance);
    sphere_radiance = sphere_radiance * transmittance + in_scatter;
  }

/*
<details>
<summary>接下来我们对行星球体 P 重复上述的步骤
（这里不再需要一个平滑的不透明度，所以我们不会再计算它。
还需要注意的是我们是如何用太阳和天空的可见性因子来调制地面接收到的太阳和天空辐照度的）：
</summary>
<p>In the following we repeat the same steps as above, but for the planet sphere
P instead of the sphere S (a smooth opacity is not really needed here, so we
don't compute it. Note also how we modulate the sun and sky irradiance received
on the ground by the sun and sky visibility factors):
</details>
*/

  // Compute the distance between the view ray line and the Earth center,
  // and the distance between the camera and the intersection of the view
  // ray with the ground (or NaN if there is no intersection).
  p = camera - earth_center;
  p_dot_v = dot(p, view_direction);
  p_dot_p = dot(p, p);
  float ray_earth_center_squared_distance = p_dot_p - p_dot_v * p_dot_v;
  distance_to_intersection = -p_dot_v - sqrt(
      earth_center.z * earth_center.z - ray_earth_center_squared_distance);

  // Compute the radiance reflected by the ground, if the ray intersects it.
  float ground_alpha = 0.0;
  vec3 ground_radiance = vec3(0.0);
  if (distance_to_intersection > 0.0) {
    vec3 point = camera + view_direction * distance_to_intersection;
    vec3 normal = normalize(point - earth_center);

    // Compute the radiance reflected by the ground.
    vec3 sky_irradiance;
    vec3 sun_irradiance = GetSunAndSkyIrradiance(
        point - earth_center, normal, sun_direction, sky_irradiance);
    ground_radiance = kGroundAlbedo * (1.0 / PI) * (
        sun_irradiance * GetSunVisibility(point, sun_direction) +
        sky_irradiance * GetSkyVisibility(point));

    float shadow_length =
        max(0.0, min(shadow_out, distance_to_intersection) - shadow_in) *
        lightshaft_fadein_hack;
    vec3 transmittance;
    vec3 in_scatter = GetSkyRadianceToPoint(camera - earth_center,
        point - earth_center, shadow_length, sun_direction, transmittance);
    ground_radiance = ground_radiance * transmittance + in_scatter;
    ground_alpha = 1.0;
  }

/*
<details>
<summary>最后，我们计算天空的辐射度和透射率，然后从后往前将场景内所有物体的
辐射度和不透明度组合到一起：
</summary>
<p>Finally, we compute the radiance and transmittance of the sky, and composite
together, from back to front, the radiance and opacities of all the objects of
the scene:
</details>
*/

  // Compute the radiance of the sky.
  // 计算天空的辐射度
  float shadow_length = max(0.0, shadow_out - shadow_in) *
      lightshaft_fadein_hack;
  vec3 transmittance;
  vec3 radiance = GetSkyRadiance(
      camera - earth_center, view_direction, shadow_length, sun_direction,
      transmittance);

  // If the view ray intersects the Sun, add the Sun radiance.
  // 如果 view ray 和太阳相交了，则加上太阳的辐射度。
  if (dot(view_direction, sun_direction) > sun_size.y) {
    radiance = radiance + transmittance * GetSolarRadiance();
  }
  radiance = mix(radiance, ground_radiance, ground_alpha);
  radiance = mix(radiance, sphere_radiance, sphere_alpha);
  color.rgb = 
      pow(vec3(1.0) - exp(-radiance / white_point * exposure), vec3(1.0 / 2.2));
  color.a = 1.0;
}
