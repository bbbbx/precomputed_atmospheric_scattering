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

/*<h2>atmosphere/model.h</h2>

<p>This file defines the API to use our atmosphere model in OpenGL applications.
To use it:
<ul>
<li>create a <code>Model</code> instance with the desired atmosphere
parameters.</li>
<li>call <code>Init</code> to precompute the atmosphere textures,</li>
<li>link <code>GetShader</code> with your shaders that need access to the
atmosphere shading functions.</li>
<li>for each GLSL program linked with <code>GetShader</code>, call
<code>SetProgramUniforms</code> to bind the precomputed textures to this
program (usually at each frame).</li>
<li>delete your <code>Model</code> when you no longer need its shader and
precomputed textures (the destructor deletes these resources).</li>
</ul>

<p>本文件定义了在 OpenGL 应用中使用我们的大气模型的 API。
要使用的话，需要：
<ul>
<li>用想要的大气参数创建一个 <code>Model</code> 实例。</li>
<li>调用 <code>Init</code> 预计算大气纹理。</li>
<li>用 <code>GetShader</code> 和你的着色器链接起来，以便可以访问大气着色函数。</li>
<li>对每个和 <code>GetShader</code> 链接的 GLSL program 调用 <code>SetProgramUniforms</code>
来绑定预计算的纹理到该 program。</li>
<li>当你不再需要它的着色器和预计算的纹理时，删除你的 <code>Model</code>（析构函数会删除这些资源）。</li>
</ul>

<p>The shader returned by <code>GetShader</code> provides the following
functions (that you need to forward declare in your own shaders to be able to
compile them separately):

<p><code>GetShader</code> 返回的着色器提供了下列的函数
（你需要在你的着色器中直接声明它们，以便可以分开编译）：
</p>

<pre class="prettyprint">
// Returns the radiance of the Sun, outside the atmosphere.
// 返回太阳在大气外的辐射度
vec3 GetSolarRadiance();

// Returns the sky radiance along the segment from 'camera' to the nearest
// atmosphere boundary in direction 'view_ray', as well as the transmittance
// along this segment.
// 返回从 'camera' 沿着 'view_ray' 方向，到最近的大气边界，这条线段的天空辐射度，
// 还返回了这条线段的 transmittance。
vec3 GetSkyRadiance(vec3 camera, vec3 view_ray, double shadow_length,
    vec3 sun_direction, out vec3 transmittance);

// Returns the sky radiance along the segment from 'camera' to 'p', as well as
// the transmittance along this segment.
// 返回从 'camera' 到 'p' 的天空辐射度，还返回了这条线段的 transmittance。
vec3 GetSkyRadianceToPoint(vec3 camera, vec3 p, double shadow_length,
    vec3 sun_direction, out vec3 transmittance);

// Returns the sun and sky irradiance received on a surface patch located at 'p'
// and whose normal vector is 'normal'.
// 返回了法线为 'normal' 的表面 'p' 点接收到的太阳辐照度和天空的辐照度
vec3 GetSunAndSkyIrradiance(vec3 p, vec3 normal, vec3 sun_direction,
    out vec3 sky_irradiance);

// Returns the luminance of the Sun, outside the atmosphere.
// 返回太阳在大气外的亮度
vec3 GetSolarLuminance();

// Returns the sky luminance along the segment from 'camera' to the nearest
// atmosphere boundary in direction 'view_ray', as well as the transmittance
// along this segment.
// 返回从 'camera' 沿着 'view_ray' 方向，到最近的大气边界，这条线段的天空亮度，
// 还返回了这条线段的 transmittance。
// 注意，是亮度，上面的那个 GetSkyRadiance 返回的是辐射度！
vec3 GetSkyLuminance(vec3 camera, vec3 view_ray, double shadow_length,
    vec3 sun_direction, out vec3 transmittance);

// Returns the sky luminance along the segment from 'camera' to 'p', as well as
// the transmittance along this segment.
// 返回从 'camera' 到 'p' 的天空亮度，还返回了这条线段的 transmittance。
vec3 GetSkyLuminanceToPoint(vec3 camera, vec3 p, double shadow_length,
    vec3 sun_direction, out vec3 transmittance);

// Returns the sun and sky illuminance received on a surface patch located at
// 'p' and whose normal vector is 'normal'.
// 返回了法线为 'normal' 的表面 'p' 点接收到的太阳照度和天空的照度。
vec3 GetSunAndSkyIlluminance(vec3 p, vec3 normal, vec3 sun_direction,
    out vec3 sky_illuminance);
</pre>

<p>where
<ul>
<li><code>camera</code> and <code>p</code> must be expressed in a reference
frame where the planet center is at the origin, and measured in the unit passed
to the constructor's <code>length_unit_in_meters</code> argument.
<code>camera</code> can be in space, but <code>p</code> must be inside the
atmosphere,</li>
<li><code>view_ray</code>, <code>sun_direction</code> and <code>normal</code>
are unit direction vectors expressed in the same reference frame (with
<code>sun_direction</code> pointing <i>towards</i> the Sun),</li>
<li><code>shadow_length</code> is the length along the segment which is in
shadow, measured in the unit passed to the constructor's
<code>length_unit_in_meters</code> argument.</li>
</ul>

<p>其中：
<ul>
<li><code>camera</code> 和 <code>p</code> 必须以行星中心位于原点的方式来表达，
且单位是构造函数中的<code>length_unit_in_meters</code> 参数。<code>camera</code>
可以位于太空，但 <code>p</code> 必须位于大气内，</li>
<li><code>view_ray</code>、<code>sun_direction</code> 和 <code>normal</code>
都是在同一个坐标系下的单位方向向量（<code>sun_direction</code> 是指向太阳的），</li>
<li><code>shadow_length</code> 是指定线段中处于阴影内的长度，
单位是构造函数中的<code>length_unit_in_meters</code> 参数。</li>
</ul>
</p>

<p>and where
<ul>
<li>the first 4 functions return spectral radiance and irradiance values
(in $W.m^{-2}.sr^{-1}.nm^{-1}$ and $W.m^{-2}.nm^{-1}$), at the 3 wavelengths
<code>kLambdaR</code>, <code>kLambdaG</code>, <code>kLambdaB</code> (in this
order),</li>
<li>the other functions return luminance and illuminance values (in
$cd.m^{-2}$ and $lx$) in linear <a href="https://en.wikipedia.org/wiki/SRGB">
sRGB</a> space (i.e. before adjustements for gamma correction),</li>
<li>all the functions return the (unitless) transmittance of the atmosphere
along the specified segment at the 3 wavelengths <code>kLambdaR</code>,
<code>kLambdaG</code>, <code>kLambdaB</code> (in this order).</li>
</ul>

<p>且
<ul>
<li>前 4 个函数返回的是 3 个波长
<code>kLambdaR</code>、<code>kLambdaG</code>、<code>kLambdaB</code>（按顺序）
的光谱的辐射度和光谱的辐照度值（单位分别是
$W \cdot m^{-2} \cdot sr^{-1} \cdot nm^{-1}$ 和 $W \cdot m^{-2} \cdot nm^{-1}$）</li>
<li>其他的函数返回的是线性 <a href="https://en.wikipedia.org/wiki/SRGB">
sRGB</a> 空间（即在伽马校正之前）的亮度和照度值（单位分别是
$cd \cdot m^{-2}$ 和 $lx$）</li>
<li>所有函数返回的大气 transmittance（没有单位的）都是位于 3 个波长
<code>kLambdaR</code>、<code>kLambdaG</code>、<code>kLambdaB</code> 上的（按顺序）</li>
</ul>


<p><b>Note</b> The precomputed atmosphere textures can store either irradiance
or illuminance values (see the <code>num_precomputed_wavelengths</code>
parameter):
<ul>
  <li>when using irradiance values, the RGB channels of these textures contain
  spectral irradiance values, in $W.m^{-2}.nm^{-1}$, at the 3 wavelengths
  <code>kLambdaR</code>, <code>kLambdaG</code>, <code>kLambdaB</code> (in this
  order). The API functions returning radiance values return these precomputed
  values (times the phase functions), while the API functions returning
  luminance values use the approximation described in
  <a href="https://arxiv.org/pdf/1612.04336.pdf">A Qualitative and Quantitative
  Evaluation of 8 Clear Sky Models</a>, section 14.3, to convert 3 radiance
  values to linear sRGB luminance values.</li>
  <li>when using illuminance values, the RGB channels of these textures contain
  illuminance values, in $lx$, in linear sRGB space. These illuminance values
  are precomputed as described in
  <a href="http://www.oskee.wz.cz/stranka/uploads/SCCG10ElekKmoch.pdf">Real-time
  Spectral Scattering in Large-scale Natural Participating Media</a>, section
  4.4 (i.e. <code>num_precomputed_wavelengths</code> irradiance values are
  precomputed, and then converted to sRGB via a numerical integration of this
  spectrum with the CIE color matching functions). The API functions returning
  luminance values return these precomputed values (times the phase functions),
  while <i>the API functions returning radiance values are not provided</i>.
  </li>
</ul>

<p><b>注意</b> 预先计算的大气纹理可以存储为辐照度或照度（见 <code>num_precomputed_wavelengths</code> 参数）：
<ul>
  <li>当使用辐照度值时，这些纹理的 RGB 通道包含的是光谱的辐照度值，单位是
    $W \cdot m^{-2} \cdot nm^{-1}$。返回辐射度的 API 函数返回的是这些预计算的值（乘上相位函数），
    而返回亮度的 API 函数使用的是 <a href="https://arxiv.org/pdf/1612.04336.pdf">A Qualitative and Quantitative
    Evaluation of 8 Clear Sky Models</a> 14.3 节中描述的近似方法，将辐射度值转换为线性的 sRGB 亮度值。</li>
  <li>当使用照度值时，这些纹理的 RGB 通道包含的是照度值，单位是 $lx$，位于线性 sRGB 空间。
    这些照度值是用 <a href="http://www.oskee.wz.cz/stranka/uploads/SCCG10ElekKmoch.pdf">Real-time
    Spectral Scattering in Large-scale Natural Participating Media</a> 4.4 节中描述的方法预计算的
    （<code>num_precomputed_wavelengths</code> 照度值是预计算的，然后通过该光谱和 CIE color matching functions
    的数值积分被转换 sRGB）。返回亮度的 API 函数返回这些预计算的值（乘上相位函数），而返回辐射度的 API 函数则没有被提供。</li>
</ul>

<p>The concrete API definition is the following:

<p>具体的 API 定义如下：</P>
*/

#ifndef ATMOSPHERE_MODEL_H_
#define ATMOSPHERE_MODEL_H_

#include <glad/glad.h>
#include <array>
#include <functional>
#include <string>
#include <vector>

namespace atmosphere {

// An atmosphere layer of width 'width' (in m), and whose density is defined as
//   'exp_term' * exp('exp_scale' * h) + 'linear_term' * h + 'constant_term',
// clamped to [0,1], and where h is the altitude (in m). 'exp_term' and
// 'constant_term' are unitless, while 'exp_scale' and 'linear_term' are in
// m^-1.
// 一个宽度为 'width' 的大气层，它的密度定义为：
//   'exp_term' * exp('exp_scale' * h) + 'linear_term' * h + 'constant_term'，
// 并被 clamped 到 [0,1]，其中 h 是海拔（米）。'exp_term' 和 'constant_term'
// 是没有单位的，而 'exp_scale' 和 'linear_term' 单位为 m^-1
class DensityProfileLayer {
 public:
  DensityProfileLayer() : DensityProfileLayer(0.0, 0.0, 0.0, 0.0, 0.0) {}
  DensityProfileLayer(double width, double exp_term, double exp_scale,
                      double linear_term, double constant_term)
      : width(width), exp_term(exp_term), exp_scale(exp_scale),
        linear_term(linear_term), constant_term(constant_term) {
  }
  double width;
  double exp_term;
  double exp_scale;
  double linear_term;
  double constant_term;
};

class Model {
 public:
  Model(
    // The wavelength values, in nanometers, and sorted in increasing order, for
    // which the solar_irradiance, rayleigh_scattering, mie_scattering,
    // mie_extinction and ground_albedo samples are provided. If your shaders
    // use luminance values (as opposed to radiance values, see above), use a
    // large number of wavelengths (e.g. between 15 and 50) to get accurate
    // results (this number of wavelengths has absolutely no impact on the
    // shader performance).
    // 波长，纳米，按递增的顺序存储，为 solar_irradiance、rayleigh_scattering、
    // mie_scattering、mie_extinction 和 ground_albedo 的样本提供。
    // 如果你的着色器使用亮度值（和辐射度值相反，见上面），则请使用
    // 更多的波长个数（例如 15 到 50 之间）来得到准确的结果
    // （波长的个数对着色器的性能完全没有影响）。
    const std::vector<double>& wavelengths,
    // The solar irradiance at the top of the atmosphere, in W/m^2/nm. This
    // vector must have the same size as the wavelengths parameter.
    // 大气顶部的太阳照度，单位为 W/m^2/nm 逐纳米的瓦每平方。
    // 该 vector 必须和 wavelengths 参数具有相同的个数。
    const std::vector<double>& solar_irradiance,
    // The sun's angular radius, in radians. Warning: the implementation uses
    // approximations that are valid only if this value is smaller than 0.1.
    // 太阳的角度半径，弧度制。警告：只有该值小于 0.1 时，实现使用近似才有效。
    double sun_angular_radius,
    // The distance between the planet center and the bottom of the atmosphere,
    // in m.
    // 行星中心到大气底部的距离，单位为米。
    double bottom_radius,
    // The distance between the planet center and the top of the atmosphere,
    // in m.
    // 行星中心到大气顶部的距离，单位为米。
    double top_radius,
    // The density profile of air molecules, i.e. a function from altitude to
    // dimensionless values between 0 (null density) and 1 (maximum density).
    // Layers must be sorted from bottom to top. The width of the last layer is
    // ignored, i.e. it always extend to the top atmosphere boundary. At most 2
    // layers can be specified.
    // 空气分子的密度分布，层必须按底到顶的顺序存储。最后一层的宽度会被忽略，
    // 即它总是扩展到大气的顶部。最多可以指定 2 层
    const std::vector<DensityProfileLayer>& rayleigh_density,
    // The scattering coefficient of air molecules at the altitude where their
    // density is maximum (usually the bottom of the atmosphere), as a function
    // of wavelength, in m^-1. The scattering coefficient at altitude h is equal
    // to 'rayleigh_scattering' times 'rayleigh_density' at this altitude. This
    // vector must have the same size as the wavelengths parameter.
    // 空气分子密度最大的海拔处（通常是大气的底部）的空气分子散射系数，
    // 是有关波长的函数，单位为 m^-1。海拔 h 处的散射系数等于
    // 'rayleigh_scattering' 乘上该海拔的 'rayleigh_density'。
    // 该 vector 必须和 wavelengths 参数具有相同的个数。
    const std::vector<double>& rayleigh_scattering,
    // The density profile of aerosols, i.e. a function from altitude to
    // dimensionless values between 0 (null density) and 1 (maximum density).
    // Layers must be sorted from bottom to top. The width of the last layer is
    // ignored, i.e. it always extend to the top atmosphere boundary. At most 2
    // layers can be specified.
    // 气溶胶的密度分布。最多指定 2 层。
    const std::vector<DensityProfileLayer>& mie_density,
    // The scattering coefficient of aerosols at the altitude where their
    // density is maximum (usually the bottom of the atmosphere), as a function
    // of wavelength, in m^-1. The scattering coefficient at altitude h is equal
    // to 'mie_scattering' times 'mie_density' at this altitude. This vector
    // must have the same size as the wavelengths parameter.
    // 气溶胶密度最大的海拔处的气溶胶散射系数（通常是大气的底部）。
    // 是有关波长的函数，单位为 m^-1。海拔 h 处的散射系数等于
    // 'mie_scattering' 乘上该海拔的 'mie_density'。
    // 该 vector 必须和 wavelengths 参数具有相同的个数。
    const std::vector<double>& mie_scattering,
    // The extinction coefficient of aerosols at the altitude where their
    // density is maximum (usually the bottom of the atmosphere), as a function
    // of wavelength, in m^-1. The extinction coefficient at altitude h is equal
    // to 'mie_extinction' times 'mie_density' at this altitude. This vector
    // must have the same size as the wavelengths parameter.
    // 气溶胶密度最大的海拔处的气溶胶消光系数，海拔 h 处的消光系数等于
    // 'mie_extinction' 乘上该海拔的 'mie_density'。
    const std::vector<double>& mie_extinction,
    // The asymetry parameter for the Cornette-Shanks phase function for the
    // aerosols.
    // 气溶胶的 Cornette-Shanks 相位函数的不对称参数
    double mie_phase_function_g,
    // The density profile of air molecules that absorb light (e.g. ozone), i.e.
    // a function from altitude to dimensionless values between 0 (null density)
    // and 1 (maximum density). Layers must be sorted from bottom to top. The
    // width of the last layer is ignored, i.e. it always extend to the top
    // atmosphere boundary. At most 2 layers can be specified.
    // 会吸光的空气分子（例如臭氧）的密度分布，最多指定 2 层。
    const std::vector<DensityProfileLayer>& absorption_density,
    // The extinction coefficient of molecules that absorb light (e.g. ozone) at
    // the altitude where their density is maximum, as a function of wavelength,
    // in m^-1. The extinction coefficient at altitude h is equal to
    // 'absorption_extinction' times 'absorption_density' at this altitude. This
    // vector must have the same size as the wavelengths parameter.
    // 会吸光的分子位于最大密度处的消光系数。消光系数等于
    // 'absorption_extinction' 乘上该海拔的 'absorption_density'。
    const std::vector<double>& absorption_extinction,
    // The average albedo of the ground, as a function of wavelength. This
    // vector must have the same size as the wavelengths parameter.
    // 地面的平均反照率 albedo，是有关波长的函数，必须和 wavelengths 参数具有相同的个数。。
    const std::vector<double>& ground_albedo,
    // The maximum Sun zenith angle for which atmospheric scattering must be
    // precomputed, in radians (for maximum precision, use the smallest Sun
    // zenith angle yielding negligible sky light radiance values. For instance,
    // for the Earth case, 102 degrees is a good choice for most cases (120
    // degrees is necessary for very high exposure values).
    // 必须是预计算的大气散射的最大太阳天顶角（太阳光线与天顶方向的夹角），弧度制。
    // （角度越小，精度越高，但天空光的辐射度也越低。
    // 对于地球，102° 不错的选择，如果是非常高的曝光值，可以选择 120°。）。
    double max_sun_zenith_angle,
    // The length unit used in your shaders and meshes. This is the length unit
    // which must be used when calling the atmosphere model shader functions.
    // 你的着色器和 meshes 的长度单位。
    // 调用大气模型着色器函数时，需要使用这个值。
    double length_unit_in_meters,
    // The number of wavelengths for which atmospheric scattering must be
    // precomputed (the temporary GPU memory used during precomputations, and
    // the GPU memory used by the precomputed results, is independent of this
    // number, but the <i>precomputation time is directly proportional to this
    // number</i>):
    // - if this number is less than or equal to 3, scattering is precomputed
    // for 3 wavelengths, and stored as irradiance values. Then both the
    // radiance-based and the luminance-based API functions are provided (see
    // the above note).
    // - otherwise, scattering is precomputed for this number of wavelengths
    // (rounded up to a multiple of 3), integrated with the CIE color matching
    // functions, and stored as illuminance values. Then only the
    // luminance-based API functions are provided (see the above note).
    // 需要预计算的大气散射的波长个数（预计算期间使用的和预计算结果使用的显存
    // 是独立于波长个数的，但预计算的时间和波长个数成正比。）：
    // - 如果波长个数小于或等于 3，则散射使用 3 个波长来计算，
    //   并保持为辐照度值。然后基于辐射度和基于照明的 API 函数都可以使用（见上面）。
    // - 否则，散射按照指定的波长个数计算（向上取整为 3 的倍数），
    //   用 CIE color matching function 来积分，保存为照度值。
    //   只有基于亮度的 API 函数可以使用（见上面）。
    unsigned int num_precomputed_wavelengths,
    // Whether to pack the (red component of the) single Mie scattering with the
    // Rayleigh and multiple scattering in a single texture, or to store the
    // (3 components of the) single Mie scattering in a separate texture.
    // 是否把米氏散射的红色分量打包进瑞利散射纹理，或者
    // 把米氏散射的 3 个分量单独保存到另一个纹理里。
    bool combine_scattering_textures,
    // Whether to use half precision floats (16 bits) or single precision floats
    // (32 bits) for the precomputed textures. Half precision is sufficient for
    // most cases, except for very high exposure values.
    // 对预计算的纹理是否使用半精度浮点数（16位）或单精度浮点数（32位）。
    // 大多数情况，半精度就足够了，除非是非常高的曝光值。
    bool half_precision);

  ~Model();

  void Init(unsigned int num_scattering_orders = 4);

  GLuint shader() const { return atmosphere_shader_; }

  void SetProgramUniforms(
      GLuint program,
      GLuint transmittance_texture_unit,
      GLuint scattering_texture_unit,
      GLuint irradiance_texture_unit,
      GLuint optional_single_mie_scattering_texture_unit = 0) const;

  // Utility method to convert a function of the wavelength to linear sRGB.
  // 'wavelengths' and 'spectrum' must have the same size. The integral of
  // 'spectrum' times each CIE_2_DEG_COLOR_MATCHING_FUNCTIONS (and times
  // MAX_LUMINOUS_EFFICACY) is computed to get XYZ values, which are then
  // converted to linear sRGB with the XYZ_TO_SRGB matrix.
  // 将波长的函数转换为线性 sRGB 的工具方法。
  // 'wavelengths' 和 'spectrum' 必须具有相同的 size。
  static void ConvertSpectrumToLinearSrgb(
      const std::vector<double>& wavelengths,
      const std::vector<double>& spectrum,
      double* r, double* g, double* b);

  static constexpr double kLambdaR = 680.0;
  static constexpr double kLambdaG = 550.0;
  static constexpr double kLambdaB = 440.0;

 private:
  typedef std::array<double, 3> vec3;
  typedef std::array<float, 9> mat3;

  void Precompute(
      GLuint fbo,
      GLuint delta_irradiance_texture,
      GLuint delta_rayleigh_scattering_texture,
      GLuint delta_mie_scattering_texture,
      GLuint delta_scattering_density_texture,
      GLuint delta_multiple_scattering_texture,
      const vec3& lambdas,
      const mat3& luminance_from_radiance,
      bool blend,
      unsigned int num_scattering_orders);

  unsigned int num_precomputed_wavelengths_;
  bool half_precision_;
  bool rgb_format_supported_;
  std::function<std::string(const vec3&)> glsl_header_factory_;
  GLuint transmittance_texture_;
  GLuint scattering_texture_;
  GLuint optional_single_mie_scattering_texture_;
  GLuint irradiance_texture_;
  GLuint atmosphere_shader_;
  GLuint full_screen_quad_vao_;
  GLuint full_screen_quad_vbo_;
};

}  // namespace atmosphere

#endif  // ATMOSPHERE_MODEL_H_
