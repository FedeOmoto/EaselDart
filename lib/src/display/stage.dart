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
 * A stage is the root level [Container] for a display list. Each time its
 * [tick] method is called, it will render its display list to its target
 * canvas.
 *
 * ##Example
 * This example creates a stage, adds a child to it, then uses [Ticker] to
 * update the child and redraw the stage using [update].
 *
 *      var stage = new createjs.Stage("canvasElementId");
 *      var image = new createjs.Bitmap("imagePath.png");
 *      stage.addChild(image);
 *      createjs.Ticker.addEventListener("tick", handleTick);
 *      function handleTick(event) {
 *          image.x += 10;
 *          stage.update();
 *      }
 */
class Stage extends Container {

}
