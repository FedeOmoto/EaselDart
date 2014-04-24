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
 * DisplayObject is an abstract class that should not be constructed directly.
 * Instead construct subclasses such as [Container], [Bitmap], and [Shape].
 * DisplayObject is the base class for all display classes in the EaselJS
 * library. It defines the core properties and methods that are shared between
 * all display objects, such as transformation properties (x, y, scaleX, scaleY,
 * etc), caching, and mouse handlers.
 */
abstract class DisplayObject extends EventDispatcher {
  // Listing of mouse event names. Used in _hasMouseEventListener.
  static const List<String> _MOUSE_EVENTS = const <String>['click', 'dblclick',
      'mousedown', 'mouseout', 'mouseover', 'pressmove', 'pressup', 'rollout',
      'rollover'];

  /**
   * Suppresses errors generated when using features like hitTest, mouse events,
   * and [getObjectsUnderPoint] with cross domain content.
   */
  static bool suppressCrossDomainErrors = false;

  // stage.snapToPixelEnabled is temporarily copied here during a draw to
  // provide global access.
  static bool _snapToPixelEnabled = false;

  static CanvasElement _hitTestCanvas = new CanvasElement(width: 1, height: 1);
  static CanvasRenderingContext2D _hitTestContext = _hitTestCanvas.context2D;
  static int _nextCacheID = 1;

  /**
   * The alpha (transparency) for this display object. 0 is fully transparent, 1
   * is fully opaque.
   */
  double alpha = 1.0;

  CanvasElement _cacheCanvas;
  int _cacheWidth;
  int _cacheHeight;
  int _id;

  /**
   * Indicates whether to include this object when running mouse interactions.
   * Setting this to `false` for children of a [Container] will cause events on
   * the Container to not fire when that child is clicked. Setting this property
   * to `false` does not prevent the [Container.getObjectsUnderPoint] method
   * from returning the child.
   *
   * **Note:** In EaselJS 0.7.0, the mouseEnabled property will not work
   * properly with nested Containers. Please check out the latest NEXT version
   * in [GitHub](https://github.com/CreateJS/EaselJS/tree/master/lib) for an
   * updated version with this issue resolved. The fix will be provided in the
   * next release of EaselJS.
   */
  bool mouseEnabled = true;

  /**
   * If `false`, the tick will not run on this display object (or its children).
   * This can provide some performance benefits. In addition to preventing the
   * "tick" event from being dispatched, it will also prevent tick related
   * updates on some display objects (ex. Sprite & MovieClip frame advancing,
   * DOMElement visibility handling).
   */
  bool tickEnabled = true;

  /**
   * An optional name for this display object. Included in
   * [DisplayObject.toString]. Useful for debugging.
   */
  String name;

  Container _parent;

  /**
   * The left offset for this display object's registration point. For example,
   * to make a 100x100px Bitmap rotate around its center, you would set regX and
   * [DisplayObject.regY] to 50.
   */
  double regX = 0.0;

  /**
   * The y offset for this display object's registration point. For example, to
   * make a 100x100px Bitmap rotate around its center, you would set
   * [DisplayObject.regX] and regY to 50.
   */
  double regY = 0.0;

  /// The rotation in degrees for this display object.
  double rotation = 0.0;

  /**
   * The factor to stretch this display object horizontally. For example,
   * setting scaleX to 2 will stretch the display object to twice its nominal
   * width. To horizontally flip an object, set the scale to a negative number.
   */
  double scaleX = 1.0;

  /**
   * The factor to stretch this display object vertically. For example, setting
   * scaleY to 0.5 will stretch the display object to half its nominal height.
   * To vertically flip an object, set the scale to a negative number.
   */
  double scaleY = 1.0;

  /// The factor to skew this display object horizontally.
  double skewX = 0.0;

  /// The factor to skew this display object vertically.
  double skewY = 0.0;

  /**
   * A shadow object that defines the shadow to render on this display object.
   * Set to `null` to remove a shadow. If null, this property is inherited from
   * the parent container.
   */
  Shadow shadow;

  /**
   * Indicates whether this display object should be rendered to the canvas and
   * included when running the Stage [Stage.getObjectsUnderPoint] method.
   */
  bool visible = true;

  /// The x (horizontal) position of the display object, relative to its parent.
  double x = 0.0;

  /// The y (vertical) position of the display object, relative to its parent.
  double y = 0.0;

  /**
   * The composite operation indicates how the pixels of this display object
   * will be composited with the elements behind it. If `null`, this property is
   * inherited from the parent container. For more information, read the
   * [whatwg spec on compositing](http://www.whatwg.org/specs/web-apps/
   * current-work/multipage/the-canvas-element.html#compositing).
   */
  String compositeOperation;

  /**
   * Indicates whether the display object should be drawn to a whole pixel when
   * [Stage.snapToPixelEnabled] is true. To enable/disable snapping on whole
   * categories of display objects, set this value on the prototype (Ex.
   * Text.prototype.snapToPixel = true).
   */
  bool snapToPixel = true;

  /**
   * An array of Filter objects to apply to this display object. Filters are
   * only applied / updated when [cache] or [updateCache] is called on the
   * display object, and only apply to the area that is cached.
   */
  List<Filter> filters;

  /**
   * Returns an ID number that uniquely identifies the current cache for this
   * display object. This can be used to determine if the cache has changed
   * since a previous check.
   */
  int cacheID = 0;

  /**
   * A Shape instance that defines a vector mask (clipping path) for this
   * display object. The shape's transformation will be applied relative to the
   * display object's parent coordinates (as if it were a child of the parent).
   */
  Shape mask;

  /**
   * A display object that will be tested when checking mouse interactions or
   * testing [Container.getObjectsUnderPoint].
   * The hit area will have its transformation applied relative to this display
   * object's coordinate space (as though the hit test object were a child of
   * this display object and relative to its regX/Y). The hitArea will be tested
   * using only its own `alpha` value regardless of the alpha value on the
   * target display object, or the target's ancestors (parents).
   * 
   * If set on a [Container], children of the Container will not receive mouse
   * events.
   * This is similar to setting [mouseChildren] to false.
   *
   * Note that hitArea is NOT currently used by the `hitTest()` method, nor is
   * it supported for [Stage].
   */
  DisplayObject hitArea;

  /**
   * A CSS cursor (ex. "pointer", "help", "text", etc) that will be displayed
   * when the user hovers over this display object. You must enable mouseover
   * events using the [Stage.enableMouseOver] method to use this property.
   * Setting a non-null cursor on a Container will override the cursor set on
   * its descendants.
   */
  String cursor;

  double _cacheOffsetX = 0.0;
  double _cacheOffsetY = 0.0;
  double _cacheScale = 1.0;
  int _cacheDataURLID = 0;
  String _cacheDataURL;
  Matrix2D<double> _matrix;
  Rectangle<double> _rectangle;
  Rectangle<double> _bounds;

  /**
   * If a cache is active, this returns the canvas that holds the cached version
   * of this display object. See [cache] for more information.
   */
  CanvasElement get cacheCanvas => _cacheCanvas;

  /**
   * Unique ID for this display object. Makes display objects easier for some
   * uses.
   */
  int get id => _id;

  /**
   * A reference to the [Container] or [Stage] object that contains this display
   * object, or null if it has not been added to one.
   */
  Container get parent => _parent;

  DisplayObject() {
    _id = UID.get;
    _matrix = new Matrix2D<double>();
    _rectangle = new Rectangle<double>(0.0, 0.0, 0.0, 0.0);
  }

  /**
   * Returns true or false indicating whether the display object would be
   * visible if drawn to a canvas.
   * This does not account for whether it would be visible within the boundaries
   * of the stage.
   *
   * NOTE: This method is mainly for internal use, though it may be useful for
   * advanced uses.
   */
  bool get isVisible => !!(visible && alpha > 0.0 && scaleX != 0.0 && scaleY !=
      0.0);

  /**
   * Draws the display object into the specified context ignoring its visible,
   * alpha, shadow, and transform.
   * Returns `true` if the draw was handled (useful for overriding
   * functionality).
   *
   * NOTE: This method is mainly for internal use, though it may be useful for
   * advanced uses.
   */
  bool draw(CanvasRenderingContext2D ctx, [bool ignoreCache = false]) {
    if (ignoreCache || _cacheCanvas == null) return false;

    double scale = _cacheScale,
        offX = _cacheOffsetX,
        offY = _cacheOffsetY;

    Rectangle<double> fBounds;

    if ((fBounds = _applyFilterBounds(offX, offY, 0.0, 0.0)) != null) {
      offX = fBounds.left;
      offY = fBounds.top;
    }

    ctx.drawImageScaled(_cacheCanvas, offX, offY, _cacheCanvas.width / scale,
        _cacheCanvas.height / scale);

    return true;
  }

  /**
   * Applies this display object's transformation, alpha,
   * globalCompositeOperation, clipping path (mask), and shadow to the specified
   * context. This is typically called prior to [draw].
   */
  void updateContext(CanvasRenderingContext2D ctx) {
    Matrix2D<double> mtx;

    if (mask != null && mask.graphics != null && !mask.graphics.isEmpty) {
      mtx = mask.getMatrix(mask._matrix);
      ctx.transform(mtx.a, mtx.b, mtx.c, mtx.d, mtx.tx, mtx.ty);

      mask.graphics.drawAsPath(ctx);
      ctx.clip();

      mtx.invert();
      ctx.transform(mtx.a, mtx.b, mtx.c, mtx.d, mtx.tx, mtx.ty);
    }

    mtx = _matrix
        ..identity()
        ..appendTransform(x, y, scaleX, scaleY, rotation, skewX, skewY, regX,
            regY);

    double tx = mtx.tx,
        ty = mtx.ty;

    if (DisplayObject._snapToPixelEnabled && snapToPixel) {
      tx = (tx + (tx < 0 ? -0.5 : 0.5)).truncateToDouble();
      ty = (ty + (ty < 0 ? -0.5 : 0.5)).truncateToDouble();
    }

    ctx.transform(mtx.a, mtx.b, mtx.c, mtx.d, tx, ty);
    ctx.globalAlpha *= alpha;

    if (compositeOperation != null) {
      ctx.globalCompositeOperation = compositeOperation;
    }

    if (shadow != null) _applyShadow(ctx, shadow);
  }

  /**
   * Draws the display object into a new canvas, which is then used for
   * subsequent draws. For complex content that does not change frequently (ex.
   * a Container with many children that do not move, or a complex vector
   * Shape), this can provide for much faster rendering because the content does
   * not need to be re-rendered each tick. The cached display object can be
   * moved, rotated, faded, etc freely, however if its content changes, you must
   * manually update the cache by calling [updateCache] or [cache] again. You
   * must specify the cache area via the x, y, w, and h parameters. This defines
   * the rectangle that will be rendered and cached using this display object's
   * coordinates.
   *
   * ##Example
   * For example if you defined a Shape that drew a circle at 0, 0 with a radius
   * of 25:
   *
   *      var shape = new createjs.Shape();
   *      shape.graphics.beginFill("#ff0000").drawCircle(0, 0, 25);
   *      myShape.cache(-25, -25, 50, 50);
   *
   * Note that filters need to be defined <em>before</em> the cache is applied.
   * Check out the [Filter] class for more information. Some filters (ex.
   * BlurFilter) will not work as expected in conjunction with the scale param.
   * 
   * Usually, the resulting cacheCanvas will have the dimensions width*scale by
   * height*scale, however some filters (ex. BlurFilter) will add padding to the
   * canvas dimensions.
   */
  void cache(double x, double y, int width, int height, [double scale = 1.0]) {
    // draw to canvas.
    if (_cacheCanvas == null) _cacheCanvas = new CanvasElement();

    _cacheWidth = width;
    _cacheHeight = height;
    _cacheOffsetX = x;
    _cacheOffsetY = y;
    _cacheScale = scale;

    updateCache();
  }

  /**
   * Redraws the display object to its cache. Calling updateCache without
   * anactive cache will throw an error.
   * If compositeOperation is null the current cache will be cleared prior to
   * drawing. Otherwise the display object will be drawn over the existing cache
   * using the specified compositeOperation.
   *
   * ##Example
   * Clear the current graphics of a cached shape, draw some new instructions,
   * and then update the cache. The new line will be drawn on top of the old
   * one.
   *
   *      // Not shown: Creating the shape, and caching it.
   *      shapeInstance.clear();
   *      shapeInstance.setStrokeStyle(3).beginStroke("#ff0000").moveTo(100, 100).lineTo(200,200);
   *      shapeInstance.updateCache();
   */
  void updateCache([String compositeOperation]) {
    if (_cacheCanvas == null) {
      throw new StateError('cache() must be called before updateCache()');
    }

    double offX = _cacheOffsetX * _cacheScale,
        offY = _cacheOffsetY * _cacheScale;
    Rectangle<double> fBounds;
    CanvasRenderingContext2D ctx = _cacheCanvas.context2D;

    // update bounds based on filters:
    if ((fBounds = _applyFilterBounds(offX, offY, _cacheWidth, _cacheHeight)) !=
        null) {
      offX = fBounds.left;
      offY = fBounds.top;
      _cacheWidth = fBounds.width.toInt();
      _cacheHeight = fBounds.height.toInt();
    }

    _cacheWidth = (_cacheWidth * _cacheScale).ceil();
    _cacheHeight = (_cacheHeight * _cacheScale).ceil();

    if (_cacheWidth != _cacheCanvas.width || _cacheHeight !=
        _cacheCanvas.height) {
      // TODO: it would be nice to preserve the content if there is a
      // compositeOperation.
      _cacheCanvas.width = _cacheWidth;
      _cacheCanvas.height = _cacheHeight;
    }

    if (compositeOperation == null) {
      ctx.clearRect(0, 0, _cacheWidth + 1, _cacheHeight + 1);
    } else {
      ctx.globalCompositeOperation = compositeOperation;
    }

    ctx.save();
    ctx.setTransform(_cacheScale, 0, 0, _cacheScale, -offX, -offY);
    draw(ctx, true);

    // TODO: filters and cache scale don't play well together at present.
    _applyFilters();

    ctx.restore();

    cacheID = DisplayObject._nextCacheID++;
  }

  /// Clears the current cache. See [cache] for more information.
  void uncache() {
    _cacheDataURL = _cacheCanvas = null;
    cacheID = 0;
    _cacheOffsetX = _cacheOffsetY = 0.0;
    _cacheScale = 1.0;
  }

  /**
   * Returns a data URL for the cache, or null if this display object is not
   * cached.
   * Uses cacheID to ensure a new data URL is not generated if the cache has not
   * changed.
   */
  String get getCacheDataURL {
    if (_cacheCanvas == null) return null;

    if (cacheID != _cacheDataURLID) {
      _cacheDataURL = _cacheCanvas.toDataUrl();
    }

    return _cacheDataURL;
  }

  /**
   * Returns the stage that this display object will be rendered on, or null if
   * it has not been added to one.
   */
  Stage get getStage {
    DisplayObject object = this;

    while (object._parent != null) object = object._parent;
    if (object is Stage) return object;
    return null;
  }

  /**
   * Transforms the specified x and y position from the coordinate space of the
   * display object to the global (stage) coordinate space. For example, this
   * could be used to position an HTML label over a specific point on a nested
   * display object. Returns a Point instance with x and y properties
   * correlating to the transformed coordinates on the stage.
   *
   * ##Example
   *
   *      displayObject.x = 300;
   *      displayObject.y = 200;
   *      stage.addChild(displayObject);
   *      var point = myDisplayObject.localToGlobal(100, 100);
   *      // Results in x=400, y=300
   */
  Point<double> localToGlobal(double x, double y) {
    Matrix2D<double> mtx = getConcatenatedMatrix(_matrix);

    if (mtx == null) return null;
    mtx.append(1.0, 0.0, 0.0, 1.0, x, y);
    return new Point<double>(mtx.tx, mtx.ty);
  }

  /**
   * Transforms the specified x and y position from the global (stage)
   * coordinate space to the coordinate space of the display object. For
   * example, this could be used to determine the current mouse position within
   * the display object. Returns a Point instance with x and y properties
   * correlating to the transformed position in the display object's coordinate
   * space.
   *
   * ##Example
   *
   *      displayObject.x = 300;
   *      displayObject.y = 200;
   *      stage.addChild(displayObject);
   *      var point = myDisplayObject.globalToLocal(100, 100);
   *      // Results in x=-200, y=-100
   */
  Point globalToLocal(double x, double y) {
    Matrix2D<double> mtx = getConcatenatedMatrix(_matrix);

    if (mtx == null) return null;

    mtx.invert();
    mtx.append(1.0, 0.0, 0.0, 1.0, x, y);

    return new Point(mtx.tx, mtx.ty);
  }

  /**
   * Transforms the specified x and y position from the coordinate space of this
   * display object to the coordinate space of the target display object.
   * Returns a Point instance with x and y properties correlating to the
   * transformed position in the target's coordinate space. Effectively the same
   * as using the following code with [localToGlobal] and [globalToLocal].
   *
   *      var pt = this.localToGlobal(x, y);
   *      pt = target.globalToLocal(pt.x, pt.y);
   */
  Point localToLocal(double x, double y, DisplayObject target) {
    Point point = localToGlobal(x, y);
    return target.globalToLocal(point.x, point.y);
  }

  /**
   * Shortcut method to quickly set the transform properties on the display
   * object. All parameters are optional.
   * Omitted parameters will have the default value set.
   *
   * ##Example
   *
   *      displayObject.setTransform(100, 100, 2, 2);
   */
  DisplayObject setTransform({double x: 0.0, double y: 0.0, double scaleX:
      1.0, double scaleY: 1.0, double rotation: 0.0, double skewX: 0.0, double skewY:
      0.0, double regX: 0.0, double regY: 0.0}) {
    this.x = x;
    this.y = y;
    this.scaleX = scaleX;
    this.scaleY = scaleY;
    this.rotation = rotation;
    this.skewX = skewX;
    this.skewY = skewY;
    this.regX = regX;
    this.regY = regY;

    return this;
  }

  /// Returns a matrix based on this object's transform.
  Matrix2D<double> getMatrix([Matrix2D<double> matrix]) {
    if (matrix != null) {
      matrix.identity();
    } else {
      matrix = new Matrix2D<double>();
    }

    return matrix
        ..appendTransform(x, y, scaleX, scaleY, rotation, skewX, skewY, regX,
            regY)
        ..appendProperties(alpha, shadow, compositeOperation);
  }

  /**
   * Generates a concatenated Matrix2D object representing the combined
   * transform of the display object and all of its parent Containers up to the
   * highest level ancestor (usually the [Stage]). This can be used to transform
   * positions between coordinate spaces, such as with [localToGlobal] and
   * [globalToLocal].
   */
  Matrix2D<double> getConcatenatedMatrix([Matrix2D<double> matrix]) {
    if (matrix != null) {
      matrix.identity();
    } else {
      matrix = new Matrix2D<double>();
    }

    DisplayObject object = this;

    while (object != null) {
      matrix
          ..prependTransform(object.x, object.y, object.scaleX, object.scaleY,
              object.rotation, object.skewX, object.skewY, object.regX, object.regY)
          ..prependProperties(object.alpha, object.shadow,
              object.compositeOperation, object.visible);
      object = object.parent;
    }

    return matrix;
  }

  /**
   * Tests whether the display object intersects the specified point in local
   * coordinates (ie. draws a pixel with alpha > 0 at the specified position).
   * This ignores the alpha, shadow, hitArea, mask, and compositeOperation of
   * the display object.
   *
   * ##Example
   *
   *      stage.addEventListener("stagemousedown", handleMouseDown);
   *      function handleMouseDown(event) {
   *          var hit = myShape.hitTest(event.stageX, event.stageY);
   *      }
   */
  bool hitTest(double x, double y) {
    // TODO: update with support for .hitArea & .mask and update
    // hitArea / mask docs?
    CanvasRenderingContext2D ctx = DisplayObject._hitTestContext;
    ctx.setTransform(1, 0, 0, 1, -x, -y);
    draw(ctx);

    bool hit = _testHit(ctx);
    ctx.setTransform(1, 0, 0, 1, 0, 0);
    ctx.clearRect(0, 0, 2, 2);

    return hit;
  }

  /**
   * Provides a chainable shortcut method for setting a number of properties on
   * the instance.
   *
   * ##Example
   *
   *      var myGraphics = new createjs.Graphics().beginFill("#ff0000").drawCircle(0, 0, 25);
   *      var shape = stage.addChild(new Shape())
   *          .set({graphics:myGraphics, x:100, y:100, alpha:0.5});
   */
  DisplayObject set() {
    // TODO
    return this;
  }

  /**
   * Returns a rectangle representing this object's bounds in its local
   * coordinate system (ie. with no transformation). Objects that have been
   * cached will return the bounds of the cache.
   * 
   * Not all display objects can calculate their own bounds (ex. Shape). For
   * these objects, you can use [setBounds] so that they are included when
   * calculating Container bounds.
   * 
   * <table border="1" style="background-color: #f5f5f5; width: 100%;">
   * <tr><td><b>All</b></td><td>
   * All display objects support setting bounds manually using setBounds().
   * Likewise, display objects that have been cached using cache() will return
   * the bounds of their cache. Manual and cache bounds will override the
   * automatic calculations listed below.
   * </td></tr>
   * <tr><td><b>Bitmap</b></td><td>
   * Returns the width and height of the sourceRect (if specified) or image,
   * extending from (x=0,y=0).
   * </td></tr>
   * <tr><td><b>Sprite</b></td><td>
   * Returns the bounds of the current frame. May have non-zero x/y if a frame
   * registration point was specified in the spritesheet data. See also
   * [SpriteSheet.getFrameBounds].
   * </td></tr>
   * <tr><td><b>Container</b></td><td>
   * Returns the aggregate (combined) bounds of all children that return a
   * non-null value from getBounds().
   * </td></tr>
   * <tr><td><b>Shape</b></td><td>
   * Does not currently support automatic bounds calculations. Use setBounds()
   * to manually define bounds.
   * </td></tr>
   * <tr><td><b>Text</b></td><td>
   * Returns approximate bounds. Horizontal values (x/width) are quite accurate,
   * but vertical values (y/height) are not, especially when using textBaseline
   * values other than "top".
   * </td></tr>
   * <tr><td><b>BitmapText</b></td><td>
   * Returns approximate bounds. Values will be more accurate if spritesheet
   * frame registration points are close to (x=0,y=0).
   * </td></tr>
   * </table>
   * 
   * <br>
   * 
   * Bounds can be expensive to calculate for some objects (ex. text, or
   * containers with many children), and are recalculated each time you call
   * getBounds(). You can prevent recalculation on static objects by setting the
   * bounds explicitly:
   * 
   *      var bounds = obj.getBounds();
   *      obj.setBounds(bounds.x, bounds.y, bounds.width, bounds.height);
   *      // getBounds will now use the set values, instead of recalculating
   * 
   * To reduce memory impact, the returned Rectangle instance may be reused
   * internally; clone the instance or copy its values if you need to retain it.
   * 
   *      var myBounds = obj.getBounds().clone();
   *      // OR:
   *      myRect.copy(obj.getBounds());
   */
  Rectangle<double> get getBounds {
    if (_bounds != null) {
      return _rectangle = new Rectangle<double>(_bounds.left, _bounds.top,
          _bounds.width, _bounds.height);
    }

    if (_cacheCanvas != null) {
      return _rectangle = new Rectangle<double>(_cacheOffsetX, _cacheOffsetY,
          _cacheCanvas.width / _cacheScale, cacheCanvas.height / _cacheScale);
    }

    return null;
  }

  /**
   * Returns a rectangle representing this object's bounds in its parent's
   * coordinate system (ie. with transformations applied). Objects that have
   * been cached will return the transformed bounds of the cache.
   * 
   * Not all display objects can calculate their own bounds (ex. Shape). For
   * these objects, you can use [setBounds] so that they are included when
   * calculating Container bounds.
   * 
   * To reduce memory impact, the returned Rectangle instance may be reused
   * internally; clone the instance or copy its values if you need to retain it.
   * 
   * Container instances calculate aggregate bounds for all children that return
   * bounds via getBounds.
   */
  Rectangle<double> get getTransformedBounds => _getBounds();

  /**
   * Allows you to manually specify the bounds of an object that either cannot
   * calculate their own bounds (ex. Shape & Text) for future reference, or so
   * the object can be included in Container bounds. Manually set bounds will
   * always override calculated bounds.
   * 
   * The bounds should be specified in the object's local (untransformed)
   * coordinates. For example, a Shape instance with a 25px radius circle
   * centered at 0,0 would have bounds of (-25, -25, 50, 50).
   */
  void setBounds(double x, double y, double width, double height) {
    _bounds = new Rectangle<double>(x, y, width, height);
  }

  /**
   * Returns a clone of this DisplayObject. Some properties that are specific to
   * this instance's current context are reverted to their defaults (for example
   * .parent). Also note that caches are not maintained across clones.
   */
  DisplayObject clone() {
    ClassMirror cm = reflectClass(runtimeType);
    InstanceMirror im = cm.newInstance(const Symbol(''), []);
    DisplayObject object = im.reflectee;
    //cloneProps(object);

    return object;
  }
}
