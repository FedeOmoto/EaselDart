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
 * A Container is a nestable display list that allows you to work with compound
 * display elements. For  example you could group arm, leg, torso and head
 * [Bitmap] instances together into a Person Container, and transform them as a
 * group, while still being able to move the individual parts relative to each
 * other. Children of containers have their transform and alpha properties
 * concatenated with their parent Container.
 *
 * For example, a [Shape] with x=100 and alpha=0.5, placed in a Container with
 * x=50 and alpha=0.7 will be rendered to the canvas at x=150 and alpha=0.35.
 * Containers have some overhead, so you generally shouldn't create a Container
 * to hold a single child.
 *
 * ##Example
 *      var container = new createjs.Container();
 *      container.addChild(bitmapInstance, shapeInstance);
 *      container.x = 100;
 */
class Container extends DisplayObject {

}
