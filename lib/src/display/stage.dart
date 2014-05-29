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
  /**
   * Indicates whether the stage should automatically clear the canvas before
   * each render. You can set this to `false` to manually control clearing (for
   * generative art, or when pointing multiple stages at the same canvas for
   * example).
   *
   * ##Example
   *
   *      var stage = new createjs.Stage("canvasId");
   *      stage.autoClear = false;
   */
  bool autoClear = true;

  /**
   * The canvas the stage will render to. Multiple stages can share a single
   * canvas, but you must disable autoClear for all but the first stage that
   * will be ticked (or they will clear each other's render).
   *
   * When changing the canvas property you must disable the events on the old
   * canvas, and enable events on the new canvas or mouse events will not work
   * as expected. For example:
   *
   *      myStage.enableDOMEvents(false);
   *      myStage.canvas = anotherCanvas;
   *      myStage.enableDOMEvents(true);
   */
  CanvasElement canvas;

  /**
   * The current mouse X position on the canvas. If the mouse leaves the canvas,
   * this will indicate the most recent position over the canvas, and
   * mouseInBounds will be set to false.
   */
  double mouseX = 0.0;

  /**
   * The current mouse Y position on the canvas. If the mouse leaves the canvas,
   * this will indicate the most recent position over the canvas, and
   * mouseInBounds will be set to false.
   */
  double mouseY = 0.0;

  /**
   * Indicates whether display objects should be rendered on whole pixels. You
   * can set the [DisplayObject.snapToPixel] property of display objects to
   * false to enable/disable this behaviour on a per instance basis.
   */
  bool snapToPixelEnabled = false;

  /// Indicates whether the mouse is currently within the bounds of the canvas.
  bool mouseInBounds = false;

  /**
   * If true, tick callbacks will be called on all display objects on the stage
   * prior to rendering to the canvas.
   */
  bool tickOnUpdate = true;

  /**
   * If true, mouse move events will continue to be called when the mouse leaves
   * the target canvas. See [mouseInBounds], and [MouseEvent] x/y/rawX/rawY.
   */
  bool mouseMoveOutside = false;

  /**
   * Specifies a target stage that will have mouse / touch interactions relayed
   * to it after this stage handles them. This can be useful in cases where you
   * have multiple layered canvases and want user interactions events to pass
   * through. For example, this would relay mouse events from topStage to
   * bottomStage:
   *
   *      topStage.nextStage = bottomStage;
   *
   * To disable relaying, set nextStage to null.
   * 
   * MouseOver, MouseOut, RollOver, and RollOut interactions are also passed
   * through using the mouse over settings of the top-most stage, but are only
   * processed if the target stage has mouse over interactions enabled.
   * Considerations when using roll over in relay targets:
   * 
   * 1. The top-most (first) stage must have mouse over interactions enabled
   * (via enableMouseOver)
   * 1. All stages that wish to participate in mouse over interaction must
   * enable them via enableMouseOver
   * 1. All relay targets will share the frequency value of the top-most stage
   * 
   * <br>
   * 
   * To illustrate, in this example the targetStage would process mouse over
   * interactions at 10hz (despite passing 30 as it's desired frequency):
   * 
   *      topStage.nextStage = targetStage;
   *      topStage.enableMouseOver(10);
   *      targetStage.enableMouseOver(30);
   * 
   * If the target stage's canvas is completely covered by this stage's canvas,
   * you may also want to disable its DOM events using:
   * 
   *      targetStage.enableDOMEvents(false);
   */
  Stage get nextStage => _nextStage;

  /**
   * Specifies a target stage that will have mouse / touch interactions relayed
   * to it after this stage handles them. This can be useful in cases where you
   * have multiple layered canvases and want user interactions events to pass
   * through. For example, this would relay mouse events from topStage to
   * bottomStage:
   *
   *      topStage.nextStage = bottomStage;
   *
   * To disable relaying, set nextStage to null.
   * 
   * MouseOver, MouseOut, RollOver, and RollOut interactions are also passed
   * through using the mouse over settings of the top-most stage, but are only
   * processed if the target stage has mouse over interactions enabled.
   * Considerations when using roll over in relay targets:
   * 
   * 1. The top-most (first) stage must have mouse over interactions enabled
   * (via enableMouseOver)
   * 1. All stages that wish to participate in mouse over interaction must
   * enable them via enableMouseOver
   * 1. All relay targets will share the frequency value of the top-most stage
   * 
   * <br>
   * 
   * To illustrate, in this example the targetStage would process mouse over
   * interactions at 10hz (despite passing 30 as it's desired frequency):
   * 
   *      topStage.nextStage = targetStage;
   *      topStage.enableMouseOver(10);
   *      targetStage.enableMouseOver(30);
   * 
   * If the target stage's canvas is completely covered by this stage's canvas,
   * you may also want to disable its DOM events using:
   * 
   *      targetStage.enableDOMEvents(false);
   */
  void set nextStage(Stage stage) {
    _nextStage = stage;
  }

  /*
   * Holds objects with data for each active pointer id. Each object has the
   * following properties: x, y, event, target, overTarget, overX, overY,
   * inBounds, posEvtObj (native event that last updated position)
   */
  Map<int, Map<String, Object>> _pointerData;

  // Number of active pointers.
  int _pointerCount = 0;

  // The ID of the primary pointer.
  int _primaryPointerID;

  Timer _mouseOverInterval;
  Stage _nextStage;
  Stage _prevStage;
  Map<String, EventListener> _eventListeners;
  double _mouseOverX, _mouseOverY;
  List<DisplayObject> _mouseOverTarget;
  Map<String, Object> _touch;

  Stage(this.canvas) {
    _pointerData = new Map<int, Map<String, Object>>();
    enableDOMEvents(true);
  }

  /**
   * Each time the update method is called, the stage will call [tick] unless
   * [tickOnUpdate] is set to false, and then render the display list to the
   * canvas.
   */
  void update([List<Object> params]) {
    if (canvas == null) return;

    // update this logic in SpriteStage when necessary
    if (tickOnUpdate) tick(params);

    dispatchEvent(new create_dart.Event('drawstart')); //TODO: make cancellable?
    DisplayObject._snapToPixelEnabled = snapToPixelEnabled;
    if (autoClear) clear();
    CanvasRenderingContext2D ctx = canvas.context2D;
    ctx.save();
    updateContext(ctx);
    draw(ctx, false);
    ctx.restore();
    dispatchEvent(new create_dart.Event('drawend'));
  }

  /**
   * Propagates a tick event through the display list. This is automatically
   * called by [update] unless [tickOnUpdate] is set to false.
   *
   * Any parameters passed to `tick()` will be included as an array in the
   * "param" property of the event object dispatched to [DisplayObject.tick]
   * event handlers. Additionally, if the first parameter is a [Ticker.tick]
   * event object (or has equivalent properties), then the delta, time, runTime,
   * and paused properties will be copied to the event object.
   *
   * Some time-based features in EaselJS (for example [Sprite.framerate] require
   * that a [Ticker.tick] event object (or equivalent) be passed as the first
   * parameter to tick(). For example:
   *
   *          Ticker.on("tick", handleTick);
   *          function handleTick(evtObj) {
   *              // do some work here, then update the stage, passing through the tick event object as the first param
   *              // and some custom data as the second and third param:
   *              myStage.update(evtObj, "hello", 2014);
   *          }
   *          
   *          // ...
   *          myDisplayObject.on("tick", handleDisplayObjectTick);
   *          function handleDisplayObjectTick(evt) {
   *              console.log(evt.params[0]); // the original tick evtObj
   *              console.log(evt.delta, evt.paused); // ex. "17 false"
   *              console.log(evt.params[1], evt.params[2]); // "hello 2014"
   *          }
   */
  void tick([List<Object> params]) {
    dispatchEvent(new create_dart.Event('tickstart')); //TODO: make cancellable?
    List<Object> args = params != null ? params.toList() : null;
    Object evt = (args != null && args.isNotEmpty) ? args.first : null;
    Map<Symbol, Object> props = (evt != null && (evt is TickEvent)) ? <Symbol,
        Object> {
      #delta: evt.delta,
      #paused: evt.paused,
      #time: evt.time,
      #runTime: evt.runTime,
      #params: args
    } : new Map<Symbol, Object>();
    if (tickEnabled) _tick(props);
    dispatchEvent(new create_dart.Event('tickend'));
  }

  /**
   * Default event handler that calls the Stage [update] method when a
   * [DisplayObject.tick] event is received. This allows you to register a Stage
   * instance as a event listener on [Ticker] directly, using:
   *
   *      Ticker.addEventListener("tick", myStage);
   *
   * Note that if you subscribe to ticks using this pattern, then the tick event
   * object will be passed through to display object tick handlers, instead of
   * `delta` and `paused` parameters.
   */
  void handleEvent(create_dart.Event event, [dynamic data]) {
    if (event is TickEvent) update(<Object>[event, data]);
  }

  /// Clears the target canvas. Useful if [autoClear] is set to `false`.
  void clear() {
    if (canvas == null) return;
    CanvasRenderingContext2D ctx = canvas.context2D;
    ctx.setTransform(1, 0, 0, 1, 0, 0);
    ctx.clearRect(0, 0, canvas.width + 1, canvas.height + 1);
  }

  /**
   * Returns a data url that contains a Base64-encoded image of the contents of
   * the stage. The returned data url can be specified as the src value of an
   * image element.
   */
  String toDataURL([String backgroundColor, String mimeType = 'image/png']) {
    ImageData data;
    String compositeOperation;
    CanvasRenderingContext2D ctx = canvas.context2D;

    if (backgroundColor != null) {
      //get the current ImageData for the canvas.
      data = ctx.getImageData(0, 0, canvas.width, canvas.height);

      //store the current globalCompositeOperation
      compositeOperation = ctx.globalCompositeOperation;

      //set to draw behind current content
      ctx.globalCompositeOperation = 'destination-over';

      //set background color
      ctx.fillStyle = backgroundColor;

      //draw background on entire canvas
      ctx.fillRect(0, 0, canvas.width, canvas.height);
    }

    //get the image data from the canvas
    String dataURL = canvas.toDataUrl(mimeType);

    if (backgroundColor != null) {
      //clear the canvas
      ctx.clearRect(0, 0, canvas.width + 1, canvas.height + 1);

      //restore it with original settings
      ctx.putImageData(data, 0, 0);

      //reset the globalCompositeOperation to what it was
      ctx.globalCompositeOperation = compositeOperation;
    }

    return dataURL;
  }

  /**
   * Enables or disables (by passing a frequency of 0) mouse over, mouse out and
   * roll over events for this stage's display list. These events can be
   * expensive to generate, so they are disabled by default. The frequency of
   * the events can be controlled independently of mouse move events via the
   * optional `frequency` parameter.
   *
   * ##Example
   *      var stage = new createjs.Stage("canvasId");
   *      stage.enableMouseOver(10); // 10 updates per second
   */
  void enableMouseOver([int frequency = 20]) {
    if (_mouseOverInterval != null) {
      _mouseOverInterval.cancel();
      _mouseOverInterval = null;
      if (frequency == 0) _testMouseOver(true);
    }

    if (frequency <= 0) return;
    Duration duration = new Duration(milliseconds: (1000 / min(50, frequency
        )).round());
    _mouseOverInterval = new Timer.periodic(duration, (Timer timer) =>
        _testMouseOver());
  }

  /**
   * Enables or disables the event listeners that stage adds to DOM elements
   * (window, document and canvas). It is good practice to disable events when
   * disposing of a Stage instance, otherwise the stage will continue to receive
   * events from the page.
   *
   * When changing the canvas property you must disable the events on the old
   * canvas, and enable events on the new canvas or mouse events will not work
   * as expected. For example:
   *
   *      myStage.enableDOMEvents(false);
   *      myStage.canvas = anotherCanvas;
   *      myStage.enableDOMEvents(true);
   */
  void enableDOMEvents([bool enable = true]) {
    if (!enable && _eventListeners != null) {
      _eventListeners.forEach((String name, EventListener listener) {
        window.removeEventListener(name, listener, false);
      });
      _eventListeners = null;
    } else if (enable && _eventListeners == null && canvas != null) {
      _eventListeners = new Map<String, EventListener>();
      _eventListeners['mouseup'] = (UIEvent e) => _handleMouseUp(e);
      _eventListeners['mousemove'] = (UIEvent e) => _handleMouseMove(e);
      _eventListeners['dblclick'] = (UIEvent e) => _handleDoubleClick(e);
      _eventListeners['mousedown'] = (UIEvent e) => _handleMouseDown(e);

      _eventListeners.forEach((String type, EventListener listener) {
        window.addEventListener(type, listener, false);
      });
    }
  }

  /// Returns a clone of this Stage.
  Stage clone([bool recursive = false]) {
    Stage stage = new Stage(null);
    _cloneProps(stage);
    return stage;
  }

  Rectangle<double> _getElementRect(CanvasElement element) {
    Rectangle<double> bounds = element.getBoundingClientRect();

    int offX = window.scrollX - document.body.clientLeft;
    int offY = window.scrollY - document.body.clientTop;

    CssStyleDeclaration styles = element.getComputedStyle();
    int padL = int.parse(styles.paddingLeft.replaceAll('px', '')) + int.parse(
        styles.borderLeftWidth.replaceAll('px', ''));
    int padT = int.parse(styles.paddingTop.replaceAll('px', '')) + int.parse(
        styles.borderTopWidth.replaceAll('px', ''));
    int padR = int.parse(styles.paddingRight.replaceAll('px', '')) + int.parse(
        styles.borderRightWidth.replaceAll('px', ''));
    int padB = int.parse(styles.paddingBottom.replaceAll('px', '')) + int.parse(
        styles.borderBottomWidth.replaceAll('px', ''));

    double left = bounds.left + offX + padL;
    double top = bounds.top + offY + padT;
    double right = bounds.right + offX - padR;
    double bottom = bounds.bottom + offY - padB;

    return new Rectangle<double>.fromPoints(new Point<double>(left, top),
        new Point<double>(right, bottom));
  }

  Map<String, Object> _getPointerData(int id) {
    if (_pointerData[id] == null) {
      _pointerData[id] = <String, Object> {
        'x': 0.0,
        'y': 0.0
      };

      // if it's the first new touch, then make it the primary pointer id:
      if (_primaryPointerID == null) _primaryPointerID = id;

      // if it's the mouse (id == -1) or the first new touch, then make it the
      // primary pointer id:
      if (_primaryPointerID == null || _primaryPointerID == -1) {
        _primaryPointerID = id;
      }
    }

    return _pointerData[id];
  }

  void _handleMouseMove(UIEvent event) {
    _handlePointerMove(-1, event, event.page.x, event.page.y);
  }

  void _handlePointerMove(int id, UIEvent event, int pageX, int pageY, [Stage
      owner]) {
    if (_prevStage != null && owner == null) return; // redundant listener.
    if (canvas == null) return;

    Map<String, Object> data = _getPointerData(id);
    bool inBounds = data['inBounds'] == null ? false : data['inBounds'];
    _updatePointerPosition(id, event, pageX, pageY);

    if (inBounds || data['inBounds'] || mouseMoveOutside) {
      if (id == -1 && data['inBounds'] == !inBounds) {
        _dispatchMouseEvent(this, (inBounds ? 'mouseleave' : 'mouseenter'),
            false, id, data, event);
      }

      _dispatchMouseEvent(this, 'stagemousemove', false, id, data, event);
      _dispatchMouseEvent(data['target'], 'pressmove', true, id, data, event);
    }

    if (_nextStage != null) {
      _nextStage._handlePointerMove(id, event, pageX, pageY, null);
    }
  }

  void _updatePointerPosition(int id, UIEvent event, int pageX, int pageY) {
    Rectangle<double> rect = _getElementRect(canvas);
    double x = (pageX - rect.left).toDouble();
    double y = (pageY - rect.top).toDouble();

    x /= (rect.right - rect.left) / canvas.width;
    y /= (rect.bottom - rect.top) / canvas.height;
    Map<String, Object> data = _getPointerData(id);

    if (data['inBounds'] = (x >= 0 && y >= 0 && x <= canvas.width - 1 && y <=
        canvas.height - 1)) {
      data['x'] = x;
      data['y'] = y;
    } else if (mouseMoveOutside) {
      data['x'] = x < 0 ? 0 : (x > canvas.width - 1 ? canvas.width - 1 : x);
      data['y'] = y < 0 ? 0 : (y > canvas.height - 1 ? canvas.height - 1 : y);
    }

    data['posEvtObj'] = event;
    data['rawX'] = x;
    data['rawY'] = y;

    if (id == _primaryPointerID) {
      mouseX = data['x'];
      mouseY = data['y'];
      mouseInBounds = data['inBounds'];
    }
  }

  void _handleMouseUp(UIEvent event) {
    _handlePointerUp(-1, event, false);
  }

  void _handlePointerUp(int id, UIEvent event, bool clear, [Stage owner]) {
    if (_prevStage != null && owner == null) return; // redundant listener.

    Map<String, Object> data = _getPointerData(id);
    _dispatchMouseEvent(this, 'stagemouseup', false, id, data, event);

    DisplayObject target,
        dataTarget = data['target'];
    if (owner == null && (dataTarget != null || _nextStage != null)) {
      List<DisplayObject> list = _getObjectsUnderPoint(data['x'], data['y'],
          null, true);
      if (list != null) target = list.first;
    }

    if (target == dataTarget) {
      _dispatchMouseEvent(dataTarget, 'click', true, id, data, event);
    }

    _dispatchMouseEvent(dataTarget, 'pressup', true, id, data, event);

    if (clear) {
      if (id == _primaryPointerID) this._primaryPointerID = null;
      _pointerData.remove(id);
    } else {
      data['target'] = null;
    }

    if (_nextStage != null) {
      if (owner == null && target != null) owner = this;
      _nextStage._handlePointerUp(id, event, clear, owner);
    }
  }

  void _handleMouseDown(UIEvent event) {
    _handlePointerDown(-1, event, event.page.x, event.page.y);
  }

  void _handlePointerDown(int id, UIEvent event, int pageX, int pageY, [Stage
      owner]) {
    if (pageY != null) _updatePointerPosition(id, event, pageX, pageY);
    DisplayObject target;
    Map<String, Object> data = _getPointerData(id);

    if (data['inBounds']) {
      _dispatchMouseEvent(this, 'stagemousedown', false, id, data, event);
    }

    if (owner == null) {
      List<DisplayObject> list = _getObjectsUnderPoint(data['x'], data['y'],
          null, true);
      if (list != null) target = data['target'] = list.first;
      _dispatchMouseEvent(data['target'], 'mousedown', true, id, data, event);
    }

    if (_nextStage != null) {
      if (owner == null && target != null) owner = this;
      _nextStage._handlePointerDown(id, event, pageX, pageY, owner);
    }
  }

  void _testMouseOver([bool clear = false, Stage owner, Stage eventTarget]) {
    if (_prevStage != null && owner == null) return; // redundant listener.

    if (_mouseOverInterval == null) {
      // not enabled for mouseover, but should still relay the event.
      if (_nextStage != null) {
        _nextStage._testMouseOver(clear, owner, eventTarget);
      }

      return;
    }

    // only update if the mouse position has changed. This provides a lot of
    // optimization, but has some trade-offs.
    if (_primaryPointerID != -1 || (!clear && mouseX == _mouseOverX && mouseY ==
        _mouseOverY && mouseInBounds)) {
      return;
    }

    Map<String, Object> data = _getPointerData(-1);
    UIEvent event = data['posEvtObj'];

    // TODO: (event.target == canvas) ???
    bool isEventTarget = eventTarget != null || event != null && (event.target
        == canvas);

    DisplayObject target, tmpTarget;
    int common = -1;
    String cursor = '';

    if (owner == null && (clear || mouseInBounds && isEventTarget)) {
      List<DisplayObject> list = _getObjectsUnderPoint(mouseX.toDouble(),
          mouseY.toDouble(), null, true);
      if (list != null) target = list.first;
      _mouseOverX = mouseX;
      _mouseOverY = mouseY;
    }

    List<DisplayObject> oldList = _mouseOverTarget != null ? _mouseOverTarget :
        new List<DisplayObject>();
    DisplayObject oldTarget = oldList.isNotEmpty ? oldList.last : null;
    List<DisplayObject> list = _mouseOverTarget = new List<DisplayObject>();

    // generate ancestor list and check for cursor:
    tmpTarget = target;

    while (tmpTarget != null) {
      list.insert(0, tmpTarget);
      if (tmpTarget.cursor != null) cursor = tmpTarget.cursor;
      tmpTarget = tmpTarget.parent;
    }

    canvas.style.cursor = cursor;

    if (owner == null && eventTarget != null) {
      eventTarget.canvas.style.cursor = cursor;
    }

    // find common ancestor:
    for (int i = 0; i < list.length; i++) {
      if (oldList.isEmpty || list[i] != oldList[i]) break;
      common = i;
    }

    if (oldTarget != target) {
      _dispatchMouseEvent(oldTarget, 'mouseout', true, -1, data, event);
    }

    for (int i = oldList.length - 1; i > common; i--) {
      _dispatchMouseEvent(oldList[i], 'rollout', false, -1, data, event);
    }

    for (int i = list.length - 1; i > common; i--) {
      _dispatchMouseEvent(list[i], 'rollover', false, -1, data, event);
    }

    if (oldTarget != target) {
      _dispatchMouseEvent(target, 'mouseover', true, -1, data, event);
    }

    if (_nextStage != null) {
      if (owner == null && target != null) owner = this;
      if (eventTarget == null && isEventTarget) eventTarget = this;
      _nextStage._testMouseOver(clear, owner, eventTarget);
    }
  }

  void _handleDoubleClick(UIEvent event, [Stage owner]) {
    DisplayObject target;
    Map<String, Object> data = _getPointerData(-1);

    if (owner == null) {
      List<DisplayObject> list = _getObjectsUnderPoint(data['x'], data['y'],
          null, true);
      if (list != null) target = list.first;
      _dispatchMouseEvent(target, 'dblclick', true, -1, data, event);
    }

    if (_nextStage != null) {
      if (owner == null && target != null) owner = this;
      _nextStage._handleDoubleClick(event, owner);
    }
  }

  void _dispatchMouseEvent(DisplayObject target, String type, bool bubbles, int
      pointerId, Map<String, Object> data, UIEvent nativeEvent) {
    // TODO: might be worth either reusing MouseEvent instances, or adding a
    // willTrigger method to avoid GC.
    if (target == null || (!bubbles && !target.hasEventListener(type))) return;

    /*
    // TODO: account for stage transformations:
    this._mtx = this.getConcatenatedMatrix(this._mtx).invert();
    var pt = this._mtx.transformPoint(o.x, o.y);
    var evt = new createjs.MouseEvent(type, bubbles, false, pt.x, pt.y, nativeEvent, pointerId, pointerId==this._primaryPointerID, o.rawX, o.rawY);
    */
    MouseEvent event = new MouseEvent(type, bubbles, false, data['x'],
        data['y'], nativeEvent, pointerId, pointerId == _primaryPointerID, data['rawX'],
        data['rawY']);
    target.dispatchEvent(event);
  }
}
