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
 * Applies the alpha from the mask image (or canvas) to the target, such that
 * the alpha channel of the result will be derived from the mask, and the RGB
 * channels will be copied from the target. This can be used, for example, to
 * apply an alpha mask to a display object. This can also be used to combine a
 * JPG compressed RGB image with a PNG32 alpha mask, which can result in a much
 * smaller file size than a single PNG32 containing ARGB.
 *
 * **IMPORTANT NOTE: This filter currently does not support the targetCtx, or
 * targetX/Y parameters correctly.**
 *
 * ##Example
 * This example draws a gradient box, then caches it and uses the "cacheCanvas"
 * as the alpha mask on a 100x100 image.
 *
 *      var box = new createjs.Shape();
 *      box.graphics.beginLinearGradientFill(["#000000", "rgba(0, 0, 0, 0)"], [0, 1], 0, 0, 100, 100)
 *      box.graphics.drawRect(0, 0, 100, 100);
 *      box.cache(0, 0, 100, 100);
 *
 *      var bmp = new createjs.Bitmap("path/to/image.jpg");
 *      bmp.filters = [
 *          new createjs.AlphaMaskFilter(box.cacheCanvas)
 *      ];
 *      bmp.cache(0, 0, 100, 100);
 *
 * See [Filter] for more information on applying filters.
 */
class AlphaMaskFilter extends Filter {
  /// The image (or canvas) to use as the mask.
  CanvasImageSource mask;

  AlphaMaskFilter(this.mask);

  @override
  Rectangle<double> get getBounds => null;

  /**
   * Applies the filter to the specified context.
   *
   * **IMPORTANT NOTE: This filter currently does not support the targetCtx, or
   * targetX/Y parameters correctly.**
   */
  @override
  bool applyFilter(CanvasRenderingContext2D ctx, double x, double y, int
      width, int height, [CanvasRenderingContext2D targetCtx, double targetX, double
      targetY]) {
    if (mask == null) return true;
    targetCtx = targetCtx != null ? targetCtx : ctx;
    if (targetX == null) targetX = x;
    if (targetY == null) targetY = y;
    targetCtx.save();

    if (ctx != targetCtx) {
      // TODO: support targetCtx and targetX/Y
      // clearRect, then draw the ctx in?
    }

    targetCtx.globalCompositeOperation = 'destination-in';
    targetCtx.drawImage(mask, targetX, targetY);
    targetCtx.restore();

    return true;
  }

  /// Returns a clone of this object.
  @override
  AlphaMaskFilter clone() => new AlphaMaskFilter(mask);
}
