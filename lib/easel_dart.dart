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

/**
 * The EaselJS Javascript library provides a retained graphics mode for canvas
 * including a full hierarchical display list, a core interaction model, and
 * helper classes to make working with 2D graphics in Canvas much easier.
 * EaselJS provides straight forward solutions for working with rich graphics
 * and interactivity with HTML5 Canvas...
 *
 * ##Getting Started
 * To get started with Easel, create a [Stage] that wraps a CANVAS element, and
 * add [DisplayObject] instances as children. EaselJS supports:
 * 
 * * Images using [Bitmap]
 * * Vector graphics using [Shape] and [Graphics]
 * * Animated bitmaps using [SpriteSheet] and [Sprite]
 * * Simple text instances using [Text]
 * * Containers that hold other DisplayObjects using [Container]
 * * Control HTML DOM elements using [DOMElement]
 *
 * All display objects can be added to the stage as children, or drawn to a
 * canvas directly.
 *
 * **User Interactions**
 * 
 * All display objects on stage (except DOMElement) will dispatch events when
 * interacted with using a mouse or touch. EaselJS supports hover, press, and
 * release events, as well as an easy-to-use drag-and-drop model. Check out
 * [MouseEvent] for more information.
 *
 * ##Simple Example
 * This example illustrates how to create and position a [Shape] on the [Stage]
 * using EaselJS' drawing API.
 *
 *          //Create a stage by getting a reference to the canvas
 *          stage = new createjs.Stage("demoCanvas");
 *          //Create a Shape DisplayObject.
 *          circle = new createjs.Shape();
 *          circle.graphics.beginFill("red").drawCircle(0, 0, 40);
 *          //Set position of Shape instance.
 *          circle.x = circle.y = 50;
 *          //Add Shape instance to stage display list.
 *          stage.addChild(circle);
 *          //Update stage will render next frame
 *          stage.update();
 *
 * **Simple Interaction Example**
 *
 *      displayObject.addEventListener("click", handleClick);
 *      function handleClick(event){
 *          // Click happenened
 *      }
 *
 *      displayObject.addEventListener("mousedown", handlePress);
 *      function handlePress(event) {
 *          // A mouse press happened.
 *          // Listen for mouse move while the mouse is down:
 *          event.addEventListener("mousemove", handleMove);
 *      }
 *      function handleMove(event) {
 *          // Check out the DragAndDrop example in GitHub for more
 *      }
 *
 * **Simple Animation Example**
 * 
 * This example moves the shape created in the previous demo across the screen.
 *
 *          //Update stage will render next frame
 *          createjs.Ticker.addEventListener("tick", handleTick);
 *
 *          function handleTick() {
 *          //Circle will move 10 units to the right.
 *              circle.x += 10;
 *              //Will cause the circle to wrap back
 *              if (circle.x > stage.canvas.width) { circle.x = 0; }
 *              stage.update();
 *          }
 *
 * ##Other Features
 * EaselJS also has built in support for
 * 
 * * Canvas features such as [Shadow] and CompositeOperation
 * * [Ticker], a global heartbeat that objects can subscribe to
 * * Filters, including a provided [ColorMatrixFilter], [AlphaMaskFilter],
 * [AlphaMapFilter], and [BlurFilter]. See [Filter] for more information
 * * A [ButtonHelper] utility, to easily create interactive buttons
 * * [SpriteSheetUtils] and a [SpriteSheetBuilder] to help build and manage
 * [SpriteSheet] functionality at run-time.
 *
 * ##Browser Support
 * All modern browsers that support Canvas will support EaselJS
 * ([http://caniuse.com/canvas](http://caniuse.com/canvas)).
 * Browser performance may vary between platforms, for example, Android Canvas
 * has poor hardware support, and is much slower on average than most other
 * browsers.
 */
library easel_dart;

import 'dart:html' hide Touch;
import 'dart:html' as html show Touch;
import 'dart:math';

@MirrorsUsed(targets: const [CanvasRenderingContext2D])
import 'dart:mirrors';

import 'dart:async';

import 'package:create_dart/create_dart.dart' as create_dart;
export 'package:create_dart/create_dart.dart';

part 'src/display/display_object.dart';
part 'src/display/container.dart';
part 'src/display/shadow.dart';
part 'src/display/shape.dart';
part 'src/display/graphics.dart';
part 'src/display/stage.dart';
part 'src/display/text.dart';
part 'src/display/bitmap.dart';
part 'src/display/sprite_sheet_data.dart';
part 'src/display/sprite_sheet.dart';
part 'src/display/sprite.dart';
part 'src/filters/filter.dart';
part 'src/filters/blur_filter.dart';
part 'src/filters/color_filter.dart';
part 'src/filters/color_matrix.dart';
part 'src/filters/color_matrix_filter.dart';
part 'src/filters/alpha_mask_filter.dart';
part 'src/geom/matrix_2d.dart';
part 'src/utils/uid.dart';
part 'src/utils/ticker.dart';
part 'src/events/mouse_event.dart';
part 'src/events/tick_event.dart';
part 'src/events/animation_end_event.dart';
part 'src/ui/touch.dart';
