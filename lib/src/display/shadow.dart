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
 * This class encapsulates the properties required to define a shadow to apply
 * to a [DisplayObject] via its shadow property.
 *
 * ##Example
 *      myImage.shadow = new createjs.Shadow("#000000", 5, 5, 10);
 */
class Shadow {
  /// An identity shadow object (all properties are set to 0).
  static final Shadow identity = new Shadow('transparent', 0, 0, 0);

  /// The color of the shadow.
  String color;

  /// The x offset of the shadow.
  int offsetX;

  /// The y offset of the shadow.
  int offsetY;

  /// The blur of the shadow.
  int blur;

  Shadow(this.color, this.offsetX, this.offsetY, this.blur);

  /// Returns a string representation of this object.
  @override
  String toString() => '[${runtimeType}]';

  /// Returns a clone of this Shadow instance.
  Shadow clone() => new Shadow(color, offsetX, offsetY, blur);
}
