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
  /**
   * The array of children in the display list. You should usually use the child
   * management methods such as [addChild], [removeChild], [swapChildren], etc,
   * rather than accessing this directly, but it is included for advanced uses.
   */
  List<DisplayObject> children;

  /**
   * Indicates whether the children of this container are independently enabled
   * for mouse/pointer interaction. If false, the children will be aggregated
   * under the container - for example, a click on a child shape would trigger a
   * click event on the container.
   */
  bool mouseChildren = true;

  /**
   * If false, the tick will not be propagated to children of this Container.
   * This can provide some performance benefits. In addition to preventing the
   * "tick" event from being dispatched, it will also prevent tick related
   * updates on some display objects (ex. Sprite & MovieClip frame advancing,
   * DOMElement visibility handling).
   */
  bool tickChildren = true;

  Container() {
    children = new List<DisplayObject>();
  }

  /**
   * Returns true or false indicating whether the display object would be
   * visible if drawn to a canvas. This does not account for whether it would be
   * visible within the boundaries of the stage.
   *
   * NOTE: This method is mainly for internal use, though it may be useful for
   * advanced uses.
   */
  bool get isVisible {
    bool hasContent = _cacheCanvas != null || children.isNotEmpty;
    return !!(visible && alpha > 0.0 && scaleX != 0.0 && scaleY != 0.0 &&
        hasContent);
  }

  /**
   * Draws the display object into the specified context ignoring its visible,
   * alpha, shadow, and transform.
   * Returns true if the draw was handled (useful for overriding functionality).
   *
   * NOTE: This method is mainly for internal use, though it may be useful for
   * advanced uses.
   */
  @override
  bool draw(CanvasRenderingContext2D ctx, [bool ignoreCache = false]) {
    if (super.draw(ctx, ignoreCache)) return true;

    // this ensures we don't have issues with display list changes that occur
    // during a draw:
    List<DisplayObject> list = children.toList();

    for (DisplayObject child in list) {
      if (!child.isVisible) continue;

      // draw the child:
      ctx.save();
      child.updateContext(ctx);
      child.draw(ctx);
      ctx.restore();
    }

    return true;
  }

  /**
   * Adds a child to the top of the display list.
   *
   * ##Example
   *      container.addChild(bitmapInstance);
   */
  DisplayObject addChild(DisplayObject child) {
    if (child == null) return null;
    if (child._parent != null) child._parent.removeChild(child);
    child._parent = this;
    children.add(child);

    return child;
  }

  /**
   * Adds children to the top of the display list.
   *
   * ##Example
   *      container.addChild(bitmapInstance, shapeInstance, textInstance);
   */
  DisplayObject addChildren(List<DisplayObject> children) {
    if (children == null) return null;
    children.forEach((DisplayObject child) => addChild(child));
    return children.last;
  }

  /**
   * Adds a child to the display list at the specified index, bumping children
   * at equal or greater indexes up one, and setting its parent to this
   * Container.
   *
   * ##Example
   *      addChildAt(child1, index);
   *
   * The index must be between 0 and numChildren. For example, to add myShape
   * under otherShape in the display list, you could use:
   *
   *      container.addChildAt(myShape, container.getChildIndex(otherShape));
   *
   * This would also bump otherShape's index up by one. Fails silently if the
   * index is out of range.
   */
  DisplayObject addChildAt(DisplayObject child, int index) {
    if (index < 0 || index > children.length) return child;
    if (child._parent != null) child._parent.removeChild(child);
    child._parent = this;
    children.insert(index, child);

    return child;
  }

  /**
   * Adds children to the display list at the specified index, bumping children
   * at equal or greater indexes up one, and setting its parent to this
   * Container.
   *
   * ##Example
   *      addChildAt(child1, child2, ..., index);
   *
   * The index must be between 0 and numChildren. For example, to add myShape
   * under otherShape in the display list, you could use:
   *
   *      container.addChildAt(myShape, container.getChildIndex(otherShape));
   *
   * This would also bump otherShape's index up by one. Fails silently if the
   * index is out of range.
   */
  DisplayObject addChildrenAt(List<DisplayObject> children, int index) {
    if (index < 0 || index > this.children.length) return children.last;
    children.forEach((DisplayObject child) => addChildAt(child, index++));
    return children.last;
  }

  /**
   * Removes the specified child from the display list. Note that it is faster
   * to use removeChildAt() if the index is already known.
   *
   * ##Example
   *      container.removeChild(child);
   *
   * Returns true if the child was removed, or false if it was not in the
   * display list.
   */
  bool removeChild(DisplayObject child) {
    return removeChildAt(children.indexOf(child));
  }

  /**
   * Removes the specified children from the display list. Note that it is
   * faster to use removeChildAt() if the index is already known.
   *
   * ##Example
   *      removeChild(child1, child2, ...);
   *
   * Returns true if the children were removed, or false if they was not in the
   * display list.
   */
  bool removeChildren(List<DisplayObject> children) {
    bool good = true;

    children.forEach((DisplayObject child) {
      good = good && removeChild(child);
    });

    return good;
  }

  /**
   * Removes the child at the specified index from the display list, and sets
   * its parent to null.
   *
   * ##Example
   *
   *      container.removeChildAt(2);
   *
   * Returns true if the child was removed, or false if the index was out of
   * range.
   */
  bool removeChildAt(int index) {
    if (index < 0 || index > children.length - 1) return false;
    DisplayObject child = children[index];
    if (child != null) child._parent = null;
    children.removeAt(index);

    return true;
  }

  /**
   * Removes the children at the specified indexes from the display list, and
   * sets its parent to null.
   *
   * ##Example
   *
   *      container.removeChild(2, 7, ...)
   *
   * Returns true if the children were removed, or false if any index was out of
   * range.
   */
  bool removeChildrenAt(List<int> indexes) {
    bool good = true;
    indexes.forEach((int index) => good = good && removeChildAt(index));
    return good;
  }

  /**
   * Removes all children from the display list.
   *
   * ##Example
   *      container.removeAlLChildren();
   */
  void removeAllChildren() {
    children.forEach((DisplayObject child) {
      children.remove(child);
      child._parent = null;
    });
  }

  /**
   * Returns the child at the specified index.
   *
   * ##Example
   *      container.getChildAt(2);
   */
  DisplayObject getChildAt(int index) => children[index];

  /// Returns the child with the specified name.
  DisplayObject getChildByName(String name) {
    return children.firstWhere((DisplayObject child) => child.name == 'name',
        orElse: () => null);
  }

  /**
   * Performs an array sort operation on the child list.
   *
   * ##Example: Display children with a higher y in front.
   * 
   *      var sortFunction = function(obj1, obj2, options) {
   *          if (obj1.y > obj2.y) { return 1; }
   *          if (obj1.y < obj2.y) { return -1; }
   *          return 0;
   *      }
   *      container.sortChildren(sortFunction);
   */
  void sortChildren(Function sortFunction) => children.sort(sortFunction);

  /**
   * Returns the index of the specified child in the display list, or -1 if it
   * is not in the display list.
   *
   * ##Example
   *      var index = container.getChildIndex(child);
   */
  int getChildIndex(DisplayObject child) => children.indexOf(child);

  /// Returns the number of children in the display list.
  int get getNumChildren => children.length;

  /**
   * Swaps the children at the specified indexes. Fails silently if either index
   * is out of range.
   */
  void swapChildrenAt(int index1, int index2) {
    DisplayObject o1 = children[index1];
    DisplayObject o2 = children[index2];
    if (o1 == null || o2 == null) return;
    children[index1] = o2;
    children[index2] = o1;
  }

  /**
   * Swaps the specified children's depth in the display list. Fails silently if
   * either child is not a child of this Container.
   */
  void swapChildren(DisplayObject child1, DisplayObject child2) {
    int i, index1, index2;

    for (i = 0; i < children.length; i++) {
      if (children[i] == child1) index1 = i;
      if (children[i] == child2) index2 = i;
      if (index1 != null && index2 != null) break;
    }

    if (i == children.length) return; // TODO: throw error?

    children[index1] = child2;
    children[index2] = child1;
  }

  /**
   * Changes the depth of the specified child. Fails silently if the child is
   * not a child of this container, or the index is out of range.
   */
  void setChildIndex(DisplayObject child, int index) {
    if (child._parent != this || index < 0 || index >= children.length) {
      return;
    }

    if (!children.remove(child)) {
      return;
    }

    children.insert(index, child);
  }

  /**
   * Returns true if the specified display object either is this container or is
   * a descendent (child, grandchild, etc) of this container.
   */
  bool contains(DisplayObject child) {
    while (child != null) {
      if (child == this) return true;
      child = child._parent;
    }

    return false;
  }

  /**
   * Tests whether the display object intersects the specified local point (ie.
   * draws a pixel with alpha > 0 at the specified position). This ignores the
   * alpha, shadow and compositeOperation of the display object, and all
   * transform properties including regX/Y.
   */
  @override
  bool hitTest(double x, double y) {
    // TODO: optimize to use the fast cache check where possible.
    return (getObjectUnderPoint(x, y) != null);
  }

  /**
   * Returns an array of all display objects under the specified coordinates
   * that are in this container's display list. This routine ignores any display
   * objects with mouseEnabled set to false. The array will be sorted in order
   * of visual depth, with the top-most display object at index 0. This uses
   * shape based hit detection, and can be an expensive operation to run, so it
   * is best to use it carefully. For example, if testing for objects under the
   * mouse, test on tick (instead of on mousemove), and only if the mouse's
   * position has changed.
   * 
   * Accounts for both [DisplayObject.hitArea] and [DisplayObject.mask].
   */
  List<DisplayObject> getObjectsUnderPoint(double x, double y) {
    List<DisplayObject> list = <DisplayObject>[];
    Point<double> pt = localToGlobal(x, y);
    _getObjectsUnderPoint(pt.x, pt.y, list);

    return list;
  }

  /**
   * Similar to [getObjectsUnderPoint], but returns only the top-most display
   * object. This runs significantly faster than `getObjectsUnderPoint()`, but
   * is still an expensive operation. See [getObjectsUnderPoint] for more
   * information.
   */
  DisplayObject getObjectUnderPoint(double x, double y) {
    Point<double> pt = localToGlobal(x, y);
    return _getObjectsUnderPoint(pt.x, pt.y).first;
  }

  /**
   * Docced in superclass.
   */
  @override
  Rectangle<double> get getBounds => _getBounds(null, true);

  /**
   * Returns a clone of this Container. Some properties that are specific to
   * this instance's current context are reverted to their defaults (for example
   * .parent).
   */
  @override
  Container clone([bool recursive = false]) {
    Container container = super.clone();

    if (recursive) {
      container.children = children.map((DisplayObject child) {
        return child.clone(recursive).._parent = container;
      }).toList();
    }

    return container;
  }

  @override
  void _tick(Map<Symbol, Object> props) {
    if (tickChildren) {
      children.forEach((DisplayObject child) {
        if (child.tickEnabled) child._tick(props);
      });
    }

    super._tick(props);
  }

  List<DisplayObject> _getObjectsUnderPoint(double x, double
      y, [List<DisplayObject> list, bool mouse = false, bool activeListener = false])
      {
    CanvasRenderingContext2D ctx = DisplayObject._hitTestContext;
    Matrix2D mtx = _matrix;
    activeListener = activeListener || (mouse && _hasMouseEventListener());

    // draw children one at a time, and check if we get a hit:
    for (DisplayObject child in children.reversed) {
      if (!child.visible || (child.hitArea == null && !child.isVisible) ||
          (mouse && !child.mouseEnabled)) {
        continue;
      }

      if (child.hitArea == null && child.mask != null && child.mask.graphics !=
          null && !child.mask.graphics.isEmpty) {
        Matrix2D maskMtx = child.mask.getMatrix(child.mask._matrix
            )..prependMatrix(getConcatenatedMatrix(mtx));
        ctx.setTransform(maskMtx.a, maskMtx.b, maskMtx.c, maskMtx.d, maskMtx.tx
            - x, maskMtx.ty - y);

        // draw the mask as a solid fill:
        child.mask.graphics.drawAsPath(ctx);
        ctx.fillStyle = '#000';
        ctx.fill();

        // if we don't hit the mask, then no need to keep looking at this DO:
        if (!_testHit(ctx)) continue;
        ctx.setTransform(1, 0, 0, 1, 0, 0);
        ctx.clearRect(0, 0, 2, 2);
      }

      // if a child container has a hitArea then we only need to check its
      // hitArea, so we can treat it as a normal DO:
      if (hitArea == null && child is Container) {
        List<DisplayObject> result = child._getObjectsUnderPoint(x, y, list,
            mouse, activeListener);
        if (list == null && result != null) {
          return (mouse && !mouseChildren) ? [this] : result;
        }
      } else {
        if (mouse && !activeListener && !child._hasMouseEventListener()) {
          continue;
        }

        child.getConcatenatedMatrix(mtx);

        if (hitArea != null) {
          mtx.appendTransform(hitArea.x, hitArea.y, hitArea.scaleX,
              hitArea.scaleY, hitArea.rotation, hitArea.skewX, hitArea.skewY, hitArea.regX,
              hitArea.regY);
          mtx.alpha = hitArea.alpha;
        }

        ctx.globalAlpha = mtx.alpha;
        ctx.setTransform(mtx.a, mtx.b, mtx.c, mtx.d, mtx.tx - x, mtx.ty - y);

        if (hitArea != null) {
          hitArea.draw(ctx);
        } else {
          child.draw(ctx);
        }

        if (!_testHit(ctx)) continue;
        ctx.setTransform(1, 0, 0, 1, 0, 0);
        ctx.clearRect(0, 0, 2, 2);
        if (list != null) {
          list.add(child);
        } else {
          return (mouse && !mouseChildren) ? [this] : [child];
        }
      }
    }

    return null;
  }

  @override
  Rectangle<double> _getBounds([Matrix2D matrix, bool ignoreTransform]) {
    Rectangle<double> bounds = super.getBounds;
    if (bounds != null) {
      return _transformBounds(bounds, matrix, ignoreTransform);
    }
    Matrix2D mtx = ignoreTransform == true ? _matrix.identity() : getMatrix(
        _matrix);
    if (matrix != null) mtx.prependMatrix(matrix);
    double minX, maxX, minY, maxY;

    for (DisplayObject child in children) {
      if (!child.visible || (bounds = child._getBounds(mtx)) == null) continue;

      double x1 = bounds.left,
          y1 = bounds.top,
          x2 = x1 + bounds.width,
          y2 = y1 + bounds.height;

      if (minX == null || x1 < minX) minX = x1;
      if (maxX == null || x2 > maxX) maxX = x2;
      if (minY == null || y1 < minY) minY = y1;
      if (maxY == null || y2 > maxY) maxY = y2;
    }

    return (maxX == null) ? null : _rectangle = new Rectangle<double>(minX,
        minY, maxX - minX, maxY - minY);
  }
}
