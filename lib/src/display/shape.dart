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
 * A Shape allows you to display vector art in the display list. It composites a
 * [Graphics] instance which exposes all of the vector drawing methods. The
 * Graphics instance can be shared between multiple Shape instances to display
 * the same vector graphics with different positions or transforms.
 *
 * If the vector art will not change between draws, you may want to use the
 * [DisplayObject.cache] method to reduce the rendering cost.
 *
 * ##Example
 *      var graphics = new createjs.Graphics().beginFill("#ff0000").drawRect(0, 0, 100, 100);
 *      var shape = new createjs.Shape(graphics);
 *
 *      // Alternatively use can also use the graphics property of the Shape
 *      // class to renderer the same as above.
 *      var shape = new createjs.Shape();
 *      shape.graphics.beginFill("#ff0000").drawRect(0, 0, 100, 100);
 */
class Shape extends DisplayObject {

}
