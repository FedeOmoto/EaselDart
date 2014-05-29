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

// TODO: support for double tap.
/**
 * Global utility for working with multi-touch enabled devices in EaselJS.
 * Currently supports W3C Touch API (iOS and modern Android browser) and the
 * Pointer API (IE), including ms-prefixed events in IE10, and unprefixed in
 * IE11.
 *
 * Ensure that you [disable] touch when cleaning up your application. You do not
 * have to check if touch is supported to enable it, as it will fail gracefully
 * if it is not supported.
 *
 * ##Example
 *
 *      var stage = new createjs.Stage("canvasId");
 *      createjs.Touch.enable(stage);
 *
 * **Note:** It is important to disable Touch on a stage that you are no longer
 * using:
 *
 *      createjs.Touch.disable(stage);
 */
class Touch {
  /// Answer the singleton instance of the Touch class.
  static Touch get current => Touch._singleton;

  static final Touch _singleton = new Touch._internal();

  factory Touch() {
    throw new UnsupportedError('Touch cannot be instantiated, use Touch.current'
        );
  }

  Touch._internal();

  /// Returns `true` if touch is supported in the current browser.
  bool get isSupported => TouchEvent.supported;

  /**
   * Enables touch interaction for the specified EaselJS [Stage]. Currently
   * supports iOS (and compatible browsers, such as modern Android browsers),
   * and IE10/11. Supports both single touch and multi-touch modes. Extends the
   * EaselJS {{#crossLink "MouseEvent"}}{{/crossLink}} model, but without
   * support for double click or over/out events. See the MouseEvent
   * [MouseEvent.pointerId] for more information.
   */
  bool enable(Stage stage, [bool singleTouch = false, bool allowDefault =
      false]) {
    if (stage == null || stage.canvas == null || !isSupported) return false;

    stage._touch = <String, Object> {
      'pointers': new Map<int, bool>(),
      'multitouch': !singleTouch,
      'preventDefault': !allowDefault,
      'count': 0
    };

    _enable(stage);

    return true;
  }

  /**
   * Removes all listeners that were set up when calling `Touch.enable()` on a
   * stage.
   */
  void disable(Stage stage) {
    if (stage == null) return;
    _disable(stage);
  }

  void _enable(Stage stage) {
    EventListener listener = stage._touch['listener'] = (TouchEvent event) {
      _handleEvent(stage, event);
    };

    stage.canvas.addEventListener('touchstart', listener, false);
    stage.canvas.addEventListener('touchmove', listener, false);
    stage.canvas.addEventListener('touchend', listener, false);
    stage.canvas.addEventListener('touchcancel', listener, false);
  }

  void _disable(Stage stage) {
    if (stage.canvas == null) return;
    EventListener listener = stage._touch['listener'];
    stage.canvas.removeEventListener('touchstart', listener, false);
    stage.canvas.removeEventListener('touchmove', listener, false);
    stage.canvas.removeEventListener('touchend', listener, false);
    stage.canvas.removeEventListener('touchcancel', listener, false);
  }

  void _handleEvent(Stage stage, TouchEvent event) {
    if (stage == null) return;
    if (stage._touch['preventDefault']) event.preventDefault();

    for (html.Touch touch in event.changedTouches) {
      int id = touch.identifier;

      if (touch.target != stage.canvas) continue;

      if (event.type == 'touchstart') {
        _handleStart(stage, id, event, touch.page.x, touch.page.y);
      } else if (event.type == 'touchmove') {
        _handleMove(stage, id, event, touch.page.x, touch.page.y);
      } else if (event.type == 'touchend' || event.type == 'touchcancel') {
        _handleEnd(stage, id, event);
      }
    }
  }

  void _handleStart(Stage stage, int id, TouchEvent event, int x, int y) {
    if (!stage._touch['multitouch'] && stage._touch['count']) return;
    Map<int, bool> ids = stage._touch['pointers'];
    if (ids[id] == true) return;
    ids[id] = true;
    stage._touch['count'] = (stage._touch['count'] as int) + 1;
    stage._handlePointerDown(id, event, x, y);
  }

  void _handleMove(Stage stage, int id, TouchEvent event, int x, int y) {
    Map<int, bool> ids = stage._touch['pointers'];
    if (ids[id] == null || !ids[id]) return;
    stage._handlePointerMove(id, event, x, y);
  }

  void _handleEnd(Stage stage, int id, TouchEvent event) {
    // TODO: cancel should be handled differently for proper UI (ex. an up would
    // trigger a click, a cancel would more closely resemble an out).
    Map<int, bool> ids = stage._touch['pointers'];
    if (ids[id] == null || !ids[id]) return;
    stage._touch['count'] = (stage._touch['count'] as int) - 1;
    stage._handlePointerUp(id, event, true);
    ids.remove(id);
  }
}
