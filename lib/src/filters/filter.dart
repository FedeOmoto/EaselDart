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
 * Base class that all filters should inherit from. Filters need to be applied
 * to objects that have been cached using the [DisplayObject.cache] method. If
 * an object changes, please cache it again, or use [DisplayObject.updateCache].
 * Note that the filters must be applied before caching.
 *
 * ##Example
 *      myInstance.filters = [
 *          new createjs.ColorFilter(0, 0, 0, 1, 255, 0, 0),
 *          new createjs.BlurFilter(5, 5, 10)
 *      ];
 *      myInstance.cache(0,0, 100, 100);
 *
 * Note that each filter can implement a [Filter.getBounds] method, which
 * returns the margins that need to be applied in order to fully display the
 * filter. For example, the [BlurFilter] will cause an object to feather
 * outwards, resulting in a margin around the shape.
 *
 * ##EaselJS Filters
 * EaselJS comes with a number of pre-built filters. Note that individual
 * filters are not compiled into the minified version of EaselJS. To use them,
 * you must include them manually in the HTML.
 * 
 * * [AlphaMapFilter]: Map a greyscale image to the alpha channel of a display
 * object
 * * [AlphaMaskFilter]: Map an image's alpha channel to the alpha channel of a
 * display object
 * * [BlurFilter]: Apply vertical and horizontal blur to a display object
 * * [ColorFilter]: Color transform a display object
 * * [ColorMatrixFilter]: Transform an image using a [ColorMatrix]
 */
abstract class Filter {
  /**
   * Returns a rectangle with values indicating the margins required to draw the
   * filter or null. For example, a filter that will extend the drawing area 4
   * pixels to the left, and 7 pixels to the right (but no pixels up or down)
   * would return a rectangle with (x=-4, y=0, width=11, height=0).
   */
  Rectangle<double> get getBounds;

  /// Applies the filter to the specified context.
  bool applyFilter(CanvasRenderingContext2D ctx, double x, double y, int
      width, int height, [CanvasRenderingContext2D targetCtx, double targetX, double
      targetY]);

  /// Returns a string representation of this object.
  @override
  String toString() => '[${runtimeType}]';

  /// Returns a clone of this Filter instance.
  Filter clone();
}
