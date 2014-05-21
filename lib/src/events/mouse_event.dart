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
 * Passed as the parameter to all mouse/pointer/touch related events. For a
 * listing of mouse events and their properties, see the [DisplayObject] and
 * [Stage] event listings.
 */
class MouseEvent extends create_dart.Event {
  /**
   * The normalized x position on the stage. This will always be within the
   * range 0 to stage width.
   */
  int stageX = 0;

  /**
   * The normalized y position on the stage. This will always be within the
   * range 0 to stage height.
   */
  int stageY = 0;

  /**
   * The raw x position relative to the stage. Normally this will be the same as
   * the stageX value, unless stage.mouseMoveOutside is true and the pointer is
   * outside of the stage bounds.
   */
  int rawX = 0;

  /**
   * The raw y position relative to the stage. Normally this will be the same as
   * the stageY value, unless stage.mouseMoveOutside is true and the pointer is
   * outside of the stage bounds.
   */
  int rawY = 0;

  /**
   * The native MouseEvent generated by the browser. The properties and API for
   * this event may differ between browsers. This property will be null if the
   * EaselJS property was not directly generated from a native MouseEvent.
   */
  html.MouseEvent nativeEvent;

  /**
   * The unique id for the pointer (touch point or cursor). This will be either
   * -1 for the mouse, or the system supplied id value.
   */
  int pointerID = 0;

  /**
   * Indicates whether this is the primary pointer in a multitouch environment.
   * This will always be true for the mouse. For touch pointers, the first
   * pointer in the current stack will be considered the primary pointer.
   */
  bool primary = false;

  /**
   * Returns the x position of the mouse in the local coordinate system of the
   * current target (ie. the dispatcher).
   */
  int get localX {
    return (currentTarget as DisplayObject).globalToLocal(rawX.toDouble(),
        rawY.toDouble()).x.toInt();
  }

  /**
   * Returns the y position of the mouse in the local coordinate system of the
   * current target (ie. the dispatcher).
   */
  int get localY {
    return (currentTarget as DisplayObject).globalToLocal(rawX.toDouble(),
        rawY.toDouble()).y.toInt();
  }

  MouseEvent(String type, bool bubbles, bool
      cancelable, this.stageX, this.stageY, this.nativeEvent, this.pointerID, this.primary, int
      rawX, int rawY): super(type, bubbles, cancelable) {
    this.rawX = (rawX == null) ? stageX : rawX;
    this.rawY = (rawY == null) ? stageY : rawY;
  }

  /// Returns a clone of the MouseEvent instance.
  @override
  MouseEvent clone() {
    return new MouseEvent(type, bubbles, cancelable, stageX, stageY,
        nativeEvent, pointerID, primary, rawX, rawY);
  }

  /// Returns a string representation of this object.
  @override
  String toString() =>
      '[${runtimeType} (type=$type stageX=$stageX stageY=$stageY)]';
}