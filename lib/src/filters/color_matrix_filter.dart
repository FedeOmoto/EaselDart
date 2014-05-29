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
 * Allows you to carry out complex color operations such as modifying
 * saturation, brightness, or inverting. See [ColorMatrix] for more information
 * on changing colors. For an easier color transform, consider the
 * [ColorFilter].
 *
 * ##Example
 * This example creates a red circle, inverts its hue, and then saturates it to
 * brighten it up.
 *
 *      var shape = new createjs.Shape().set({x:100,y:100});
 *      shape.graphics.beginFill("#ff0000").drawCircle(0,0,50);
 *
 *      var matrix = new createjs.ColorMatrix().adjustHue(180).adjustSaturation(100);
 *      shape.filters = [
 *          new createjs.ColorMatrixFilter(matrix)
 *      ];
 *
 *      shape.cache(-50, -50, 100, 100);
 *
 * See [Filter] for an more information on applying filters.
 */
class ColorMatrixFilter extends Filter {
  ColorMatrix matrix;

  ColorMatrixFilter(this.matrix);

  @override
  Rectangle<double> get getBounds => null;

  @override
  bool applyFilter(CanvasRenderingContext2D ctx, double x, double y, int
      width, int height, [CanvasRenderingContext2D targetCtx, double targetX, double
      targetY]) {
    if (targetCtx == null) targetCtx = ctx;
    if (targetX == null) targetX = x;
    if (targetY == null) targetY = y;

    ImageData imageData;

    try {
      imageData = ctx.getImageData(x, y, width, height);
    } catch (e) {
      //if (!this.suppressCrossDomainErrors) throw new Error("unable to access local image data: " + e);
      return false;
    }

    List<int> pixels = imageData.data;
    int r, g, b, a;
    double m0 = matrix._values[0],
        m1 = matrix._values[1],
        m2 = matrix._values[2],
        m3 = matrix._values[3],
        m4 = matrix._values[4],
        m5 = matrix._values[5],
        m6 = matrix._values[6],
        m7 = matrix._values[7],
        m8 = matrix._values[8],
        m9 = matrix._values[9],
        m10 = matrix._values[10],
        m11 = matrix._values[11],
        m12 = matrix._values[12],
        m13 = matrix._values[13],
        m14 = matrix._values[14],
        m15 = matrix._values[15],
        m16 = matrix._values[16],
        m17 = matrix._values[17],
        m18 = matrix._values[18],
        m19 = matrix._values[19];

    for (int i = 0; i < pixels.length; i += 4) {
      r = pixels[i];
      g = pixels[i + 1];
      b = pixels[i + 2];
      a = pixels[i + 3];

      // red
      pixels[i] = (r * m0 + g * m1 + b * m2 + a * m3 + m4).round();

      // green
      pixels[i + 1] = (r * m5 + g * m6 + b * m7 + a * m8 + m9).round();

      // blue
      pixels[i + 2] = (r * m10 + g * m11 + b * m12 + a * m13 + m14).round();

      // alpha
      pixels[i + 3] = (r * m15 + g * m16 + b * m17 + a * m18 + m19).round();
    }

    targetCtx.putImageData(imageData, targetX, targetY);
    return true;
  }

  /// Returns a clone of this ColorMatrixFilter instance.
  @override
  ColorMatrixFilter clone() => new ColorMatrixFilter(matrix);
}
