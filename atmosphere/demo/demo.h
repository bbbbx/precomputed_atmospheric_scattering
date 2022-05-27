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

/*<h2>atmosphere/demo/demo.h</h2>

<p>Our demo application consists of a single class, whose header is defined
below. Besides a constructor and an initialization method, this class has one
method per user interface event, and a few fields to store the current rendering
options, the current camera and Sun parameters, as well as references to the
atmosphere model and to the GLSL program, vertex buffers and text renderer used
to render the scene and the help messages:

<p>我们的 demo 应用由单个类组成，它的头文件定义如下。除了构造函数和初始化方法，该类
对于每个用户接口事件都有一个方法，还有一些字段，用于保存当前渲染选项、当前相机参数、太阳参数、
对大气模型的引用和对 GLSL program 的引用，vertex buffers 和 text renderer 用于渲染场景和 help 消息：
</p>
*/

#ifndef ATMOSPHERE_DEMO_DEMO_H_
#define ATMOSPHERE_DEMO_DEMO_H_

#include <glad/glad.h>

#include <memory>

#include "atmosphere/model.h"
#include "text/text_renderer.h"

namespace atmosphere {
namespace demo {

class Demo {
 public:
  Demo(int viewport_width, int viewport_height);
  ~Demo();

  const Model& model() const { return *model_; }
  const GLuint vertex_shader() const { return vertex_shader_; }
  const GLuint fragment_shader() const { return fragment_shader_; }
  const GLuint program() const { return program_; }

 private:
  enum Luminance {
    // Render the spectral radiance at kLambdaR, kLambdaG, kLambdaB.
    // 渲染位于 kLambdaR、kLambdaG、kLambdaB 的光谱辐射
    NONE,
    // Render the sRGB luminance, using an approximate (on the fly) conversion
    // from 3 spectral radiance values only (see section 14.3 in <a href=
    // "https://arxiv.org/pdf/1612.04336.pdf">A Qualitative and Quantitative
    //  Evaluation of 8 Clear Sky Models</a>).
    // 使用一个近似的（在运行时）转换，只用 3 个光谱辐射值来渲染 sRGB 亮度（见<a href=
    // "https://arxiv.org/pdf/1612.04336.pdf">A Qualitative and Quantitative
    //  Evaluation of 8 Clear Sky Models</a> 的 14.3 节）。
    APPROXIMATE,
    // Render the sRGB luminance, precomputed from 15 spectral radiance values
    // (see section 4.4 in <a href=
    // "http://www.oskee.wz.cz/stranka/uploads/SCCG10ElekKmoch.pdf">Real-time
    //  Spectral Scattering in Large-scale Natural Participating Media</a>).
    // 使用 15 个预计算的光谱辐射值（见 <a href=
    // "http://www.oskee.wz.cz/stranka/uploads/SCCG10ElekKmoch.pdf">Real-time
    //  Spectral Scattering in Large-scale Natural Participating Media</a>4.4 节）来渲染 sRGB 亮度。
    PRECOMPUTED
  };

  void InitModel();
  void HandleRedisplayEvent() const;
  void HandleReshapeEvent(int viewport_width, int viewport_height);
  void HandleKeyboardEvent(unsigned char key);
  void HandleMouseClickEvent(int button, int state, int mouse_x, int mouse_y);
  void HandleMouseDragEvent(int mouse_x, int mouse_y);
  void HandleMouseWheelEvent(int mouse_wheel_direction);
  void SetView(double view_distance_meters, double view_zenith_angle_radians,
      double view_azimuth_angle_radians, double sun_zenith_angle_radians,
      double sun_azimuth_angle_radians, double exposure);

  bool use_constant_solar_spectrum_;
  bool use_ozone_;
  bool use_combined_textures_;
  bool use_half_precision_;
  Luminance use_luminance_;
  bool do_white_balance_;
  bool show_help_;

  std::unique_ptr<Model> model_;
  GLuint vertex_shader_;
  GLuint fragment_shader_;
  GLuint program_;
  GLuint full_screen_quad_vao_;
  GLuint full_screen_quad_vbo_;
  std::unique_ptr<TextRenderer> text_renderer_;
  int window_id_;

  double view_distance_meters_;
  double view_zenith_angle_radians_;
  double view_azimuth_angle_radians_;
  double sun_zenith_angle_radians_;
  double sun_azimuth_angle_radians_;
  double exposure_;

  int previous_mouse_x_;
  int previous_mouse_y_;
  bool is_ctrl_key_pressed_;
};

}  // namespace demo
}  // namespace atmosphere

#endif  // ATMOSPHERE_DEMO_DEMO_H_
