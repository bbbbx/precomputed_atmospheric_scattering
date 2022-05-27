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

/*<h2>atmosphere/definitions.glsl</h2>

<p>This GLSL file defines the physical types and constants which are used in the
main <a href="functions.glsl.html">functions</a> of our atmosphere model, in
such a way that they can be compiled by a GLSL compiler (a
<a href="reference/definitions.h.html">C++ equivalent</a> of this file
provides the same types and constants in C++, to allow the same functions to be
compiled by a C++ compiler - see the <a href="../index.html">Introduction</a>).

<p>这个 GLSL 文件定义了物理类型和常量，它们会用于我们的大气模型的
main <a href="functions.glsl.html">functions</a> 中，这样的话它们就可以被
一个 GLSL 编译器编译了（还有一个该文件 <a href="reference/definitions.h.html">C++ equivalent</a>
在 C++ 提供了相同的类型和常量，使得相同的函数能够被 C++ 编译器编译，见 <a href="../index.html">Introduction</a>）。
</p>

<h3>Physical quantities</h3>
<h3>物理量</h3>

<p>The physical quantities we need for our atmosphere model are
<a href="https://en.wikipedia.org/wiki/Radiometry">radiometric</a> and
<a href="https://en.wikipedia.org/wiki/Photometry_(optics)">photometric</a>
quantities. In GLSL we can't define custom numeric types to enforce the
homogeneity of expressions at compile time, so we define all the physical
quantities as <code>float</code>, with preprocessor macros (there is no
<code>typedef</code> in GLSL).

<p>我们的大气模型所需要的物理量是
<a href="https://en.wikipedia.org/wiki/Radiometry">radiometric</a> 和
<a href="https://en.wikipedia.org/wiki/Photometry_(optics)">photometric</a>
量。在 GLSL 中，我们不能自定义数值类型，所以我们用处理器宏把所有的物理量定义为 <code>float</code>
（GLSL 中没有 <code>typedef</code>）。
</p>

<p>We start with six base quantities: length, wavelength, angle, solid angle,
power and luminous power (wavelength is also a length, but we distinguish the
two for increased clarity).

<p>我们从 6 个基本的量开始：长度、波长、角度、立体角、功率和流明功率
（波长也是一个长度，但我们将两者区分开来以提高清晰度）。
</p>
*/

#define Length float
#define Wavelength float
#define Angle float
#define SolidAngle float
#define Power float
#define LuminousPower float

/*
<p>From this we "derive" the irradiance, radiance, spectral irradiance,
spectral radiance, luminance, etc, as well pure numbers, area, volume, etc (the
actual derivation is done in the <a href="reference/definitions.h.html">C++
equivalent</a> of this file).

<p>然后我们“派生”出辐照度、辐射度、光谱的辐照度、光谱的辐射度、亮度等等，
以及标量、面积、体积等等（实际的派生是在本文件的
<a href="reference/definitions.h.html">C++ 等价</a>中完成的）。
</p>
*/

#define Number float
#define InverseLength float
#define Area float
#define Volume float
#define NumberDensity float
#define Irradiance float
#define Radiance float
#define SpectralPower float
#define SpectralIrradiance float
#define SpectralRadiance float
#define SpectralRadianceDensity float
#define ScatteringCoefficient float
#define InverseSolidAngle float
#define LuminousIntensity float
#define Luminance float
#define Illuminance float

/*
<p>We  also need vectors of physical quantities, mostly to represent functions
depending on the wavelength. In this case the vector elements correspond to
values of a function at some predefined wavelengths. Again, in GLSL we can't
define custom vector types to enforce the homogeneity of expressions at compile
time, so we define these vector types as <code>vec3</code>, with preprocessor
macros. The full definitions are given in the
<a href="reference/definitions.h.html">C++ equivalent</a> of this file).

<p>我们还需要物理量的向量，大多数都是表示依赖于波长的函数。
在这种情况下，向量的元素对应位于预定义波长处的函数值。同样，GLSL 中我们不能自定义向量类型，
所以我们用预处理器的宏把这些向量定义为 <code>vec3</code>。
（本文件的 <a href="reference/definitions.h.html">C++ 等价</a> 也有完整的定义）。
</p>

*/

// A generic function from Wavelength to some other type.
// 一个和波长相关的通用类型
#define AbstractSpectrum vec3
// A function from Wavelength to Number.
// 一个和波长相关的标量
#define DimensionlessSpectrum vec3
// A function from Wavelength to SpectralPower.
// 一个和波长相关的 SpectralPower
#define PowerSpectrum vec3
// A function from Wavelength to SpectralIrradiance.
// 和波长相关的 SpectralIrradiance
#define IrradianceSpectrum vec3
// A function from Wavelength to SpectralRadiance.
// 和波长相关的 SpectralRadiance
#define RadianceSpectrum vec3
// A function from Wavelength to SpectralRadianceDensity.
// 和波长相关的 SpectralRadianceDensity
#define RadianceDensitySpectrum vec3
// A function from Wavelength to ScaterringCoefficient.
// 和波长相关的 ScaterringCoefficient
#define ScatteringSpectrum vec3

// A position in 3D (3 length values).
// 3D 的坐标
#define Position vec3
// A unit direction vector in 3D (3 unitless values).
// 3D 的单位方向向量
#define Direction vec3
// A vector of 3 luminance values.
// 3 个亮度值的向量
#define Luminance3 vec3
// A vector of 3 illuminance values.
// 3 个照度值的向量
#define Illuminance3 vec3

/*
<p>Finally, we also need precomputed textures containing physical quantities in
each texel. Since we can't define custom sampler types to enforce the
homogeneity of expressions at compile time in GLSL, we define these texture
types as <code>sampler2D</code> and <code>sampler3D</code>, with preprocessor
macros. The full definitions are given in the
<a href="reference/definitions.h.html">C++ equivalent</a> of this file).

<p>最后，我们还需要定义每个纹素都包含物理量的预计算纹理。
用预处理宏定义把这些纹理类型定义为 <code>sampler2D</code> 和 <code>sampler3D</code>
（本文件的 <a href="reference/definitions.h.html">C++ 等价</a> 也有完整的定义）。
</p>
*/

#define TransmittanceTexture sampler2D
#define AbstractScatteringTexture sampler3D
#define ReducedScatteringTexture sampler3D
#define ScatteringTexture sampler3D
#define ScatteringDensityTexture sampler3D
#define IrradianceTexture sampler2D

/*
<h3>Physical units</h3>
<h3>物理单位</h3>

<p>We can then define the units for our six base physical quantities:
meter (m), nanometer (nm), radian (rad), steradian (sr), watt (watt) and lumen
(lm):

<p>我们可以为我们的 6 个基本物理量定义单位：
米 m、纳米 nm、弧度 rad、球面度 sr、瓦特 watt 和流明 lm：
</p>
*/

const Length m = 1.0;
const Wavelength nm = 1.0;
const Angle rad = 1.0;
const SolidAngle sr = 1.0;
const Power watt = 1.0;
const LuminousPower lm = 1.0;

/*
<p>From which we can derive the units for some derived physical quantities,
as well as some derived units (kilometer km, kilocandela kcd, degree deg):

<p>我们可以导出一些物理量的单位（千米 km、千坎德拉 kcd、degree deg 表示 1 度角的弧度）：
</p>
*/

const float PI = 3.14159265358979323846;

const Length km = 1000.0 * m;
const Area m2 = m * m;
const Volume m3 = m * m * m;
const Angle pi = PI * rad;
const Angle deg = pi / 180.0;
const Irradiance watt_per_square_meter = watt / m2;
const Radiance watt_per_square_meter_per_sr = watt / (m2 * sr);
const SpectralIrradiance watt_per_square_meter_per_nm = watt / (m2 * nm);
const SpectralRadiance watt_per_square_meter_per_sr_per_nm =
    watt / (m2 * sr * nm);
const SpectralRadianceDensity watt_per_cubic_meter_per_sr_per_nm =
    watt / (m3 * sr * nm);
const LuminousIntensity cd = lm / sr;
const LuminousIntensity kcd = 1000.0 * cd;
const Luminance cd_per_square_meter = cd / m2;
const Luminance kcd_per_square_meter = kcd / m2;

/*
<h3>Atmosphere parameters</h3>
<h3>大气参数</h3>

<p>Using the above types, we can now define the parameters of our atmosphere
model. We start with the definition of density profiles, which are needed for
parameters that depend on the altitude:

<p>有了上面的类型，我们现在可以定义我们的大气模型的参数。
我们从定义密度分布开始，它依赖于海拔：
</p>
*/

// An atmosphere layer of width 'width', and whose density is defined as
//   'exp_term' * exp('exp_scale' * h) + 'linear_term' * h + 'constant_term',
// clamped to [0,1], and where h is the altitude.
struct DensityProfileLayer {
  Length width;
  Number exp_term;
  InverseLength exp_scale;
  InverseLength linear_term;
  Number constant_term;
};

// An atmosphere density profile made of several layers on top of each other
// (from bottom to top). The width of the last layer is ignored, i.e. it always
// extend to the top atmosphere boundary. The profile values vary between 0
// (null density) to 1 (maximum density).
// 最多有 2 层。
struct DensityProfile {
  DensityProfileLayer layers[2];
};

/*
The atmosphere parameters are then defined by the following struct:

大气参数由下列结构体定义：
*/

struct AtmosphereParameters {
  // The solar irradiance at the top of the atmosphere.
  IrradianceSpectrum solar_irradiance;
  // The sun's angular radius. Warning: the implementation uses approximations
  // that are valid only if this angle is smaller than 0.1 radians.
  Angle sun_angular_radius;
  // The distance between the planet center and the bottom of the atmosphere.
  Length bottom_radius;
  // The distance between the planet center and the top of the atmosphere.
  Length top_radius;
  // The density profile of air molecules, i.e. a function from altitude to
  // dimensionless values between 0 (null density) and 1 (maximum density).
  DensityProfile rayleigh_density;
  // The scattering coefficient of air molecules at the altitude where their
  // density is maximum (usually the bottom of the atmosphere), as a function of
  // wavelength. The scattering coefficient at altitude h is equal to
  // 'rayleigh_scattering' times 'rayleigh_density' at this altitude.
  ScatteringSpectrum rayleigh_scattering;
  // The density profile of aerosols, i.e. a function from altitude to
  // dimensionless values between 0 (null density) and 1 (maximum density).
  DensityProfile mie_density;
  // The scattering coefficient of aerosols at the altitude where their density
  // is maximum (usually the bottom of the atmosphere), as a function of
  // wavelength. The scattering coefficient at altitude h is equal to
  // 'mie_scattering' times 'mie_density' at this altitude.
  ScatteringSpectrum mie_scattering;
  // The extinction coefficient of aerosols at the altitude where their density
  // is maximum (usually the bottom of the atmosphere), as a function of
  // wavelength. The extinction coefficient at altitude h is equal to
  // 'mie_extinction' times 'mie_density' at this altitude.
  ScatteringSpectrum mie_extinction;
  // The asymetry parameter for the Cornette-Shanks phase function for the
  // aerosols.
  Number mie_phase_function_g;
  // The density profile of air molecules that absorb light (e.g. ozone), i.e.
  // a function from altitude to dimensionless values between 0 (null density)
  // and 1 (maximum density).
  DensityProfile absorption_density;
  // The extinction coefficient of molecules that absorb light (e.g. ozone) at
  // the altitude where their density is maximum, as a function of wavelength.
  // The extinction coefficient at altitude h is equal to
  // 'absorption_extinction' times 'absorption_density' at this altitude.
  ScatteringSpectrum absorption_extinction;
  // The average albedo of the ground.
  DimensionlessSpectrum ground_albedo;
  // The cosine of the maximum Sun zenith angle for which atmospheric scattering
  // must be precomputed (for maximum precision, use the smallest Sun zenith
  // angle yielding negligible sky light radiance values. For instance, for the
  // Earth case, 102 degrees is a good choice - yielding mu_s_min = -0.2).
  Number mu_s_min;
};
