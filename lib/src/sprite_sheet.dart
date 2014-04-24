// Copyright 2014 Federico Omoto
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

part of easel_dart;

/**
 * Encapsulates the properties and methods associated with a sprite sheet.
 * A sprite sheet is a series of images (usually animation frames) combined
 * into a larger image (or images). For example, an animation consisting of
 * eight 100x100 images could be combined into a single 400x200 sprite sheet
 * (4 frames across by 2 high).
 *
 * The data passed to the SpriteSheet constructor defines three critical pieces
 * of information:
 * 
 * 1. The image or images to use.
 * 
 * 1. The positions of individual image frames. This data can be represented in
 * one of two ways: As a regular grid of sequential, equal-sized frames, or as
 * individually defined, variable sized frames arranged in an irregular
 * (non-sequential) fashion.
 * 
 * 1. Likewise, animations can be represented in two ways: As a series of
 * sequential frames, defined by a start and end frame [0,3], or as a list of
 * frames [0,1,2,3].
 * 
 * ##SpriteSheet Format
 *
 *      data = {
 *          // DEFINING FRAMERATE:
 *          // This specifies the framerate that will be set on the SpriteSheet.
 *          // See framerate for more information.
 *          framerate: 20,
 *
 *          // DEFINING IMAGES:
 *          // List of images or image URIs to use. SpriteSheet can handle
 *          // preloading.
 *          // The order dictates their index value for frame definition.
 *          images: [image1, "path/to/image2.png"],
 *
 *          // DEFINING FRAMES:
 *              // The simple way to define frames, only requires frame size
 *              // because frames are consecutive:
 *              // Define frame width/height, and optionally the frame count and
 *              // registration point x/y.
 *              // If count is omitted, it will be calculated automatically
 *              // based on image dimensions.
 *              frames: {width:64, height:64, count:20, regX: 32, regY:64},
 *
 *              // OR, the complex way that defines individual rects for frames.
 *              // The 5th value is the image index per the list defined in
 *              // "images" (defaults to 0).
 *              frames: [
 *                      // x, y, width, height, imageIndex, regX, regY
 *                      [0,0,64,64,0,32,64],
 *                      [64,0,96,64,0]
 *              ],
 *
 *          // DEFINING ANIMATIONS:
 *
 *              // Simple animation definitions. Define a consecutive range of
 *              // frames (begin to end inclusive).
 *              // Optionally define a "next" animation to sequence to (or false
 *              // to stop) and a playback "speed".
 *              animations: {
 *                      // start, end, next, speed
 *                      run: [0,8],
 *                      jump: [9,12,"run",2]
 *              }
 *
 *          // The complex approach which specifies every frame in the animation
 *          // by index.
 *          animations: {
 *              run: {
 *                      frames: [1,2,3,3,2,1]
 *              },
 *              jump: {
 *                      frames: [1,4,5,6,1],
 *                      next: "run",
 *                      speed: 2
 *              },
 *              stand: { frames: [7] }
 *          }
 *
 *              // The above two approaches can be combined, you can also use a
 *              // single frame definition:
 *              animations: {
 *                      run: [0,8,true,2],
 *                      jump: {
 *                              frames: [8,9,10,9,8],
 *                              next: "run",
 *                              speed: 2
 *                      },
 *                      stand: 7
 *              }
 *      }
 *
 * ##Example
 * 
 * To define a simple sprite sheet, with a single image "sprites.jpg" arranged
 * in a regular 50x50 grid with two animations, "run" looping from frame 0-4
 * inclusive, and "jump" playing from frame 5-8 and sequencing back to run:
 *
 *      var data = {
 *          images: ["sprites.jpg"],
 *          frames: {width:50, height:50},
 *          animations: {run:[0,4], jump:[5,8,"run"]}
 *      };
 *      var spriteSheet = new createjs.SpriteSheet(data);
 *      var animation = new createjs.Sprite(spriteSheet, "run");
 *
 *
 * **Warning:** Images loaded cross-origin will throw cross-origin security
 * errors when interacted with using a mouse, using methods such as
 * `getObjectUnderPoint`, using filters, or caching. You can get around this by
 * setting `crossOrigin` flags on your images before passing them to EaselJS,
 * eg: `img.crossOrigin="Anonymous";`
 */
class SpriteSheet {
}
