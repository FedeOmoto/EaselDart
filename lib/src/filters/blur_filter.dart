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
 * Applies a box blur to DisplayObjects. Note that this filter is fairly CPU
 * intensive, particularly if the quality is set higher than 1.
 *
 * ##Example
 * This example creates a red circle, and then applies a 5 pixel blur to it. It
 * uses the [getBounds] method to account for the spread that the blur causes.
 *
 *      var shape = new createjs.Shape().set({x:100,y:100});
 *      shape.graphics.beginFill("#ff0000").drawCircle(0,0,50);
 *
 *      var blurFilter = new createjs.BlurFilter(5, 5, 1);
 *      shape.filters = [blurFilter];
 *      var bounds = blurFilter.getBounds();
 *
 *      shape.cache(-50+bounds.x, -50+bounds.y, 100+bounds.width, 100+bounds.height);
 *
 * See [Filter] for more information on applying filters.
 */
class BlurFilter extends Filter {
  // TODO: There might be a better better way to place these two lookup tables:
  static const List<int> MUL_TABLE = const <int>[1, 171, 205, 293, 57, 373, 79,
      137, 241, 27, 391, 357, 41, 19, 283, 265, 497, 469, 443, 421, 25, 191, 365, 349,
      335, 161, 155, 149, 9, 278, 269, 261, 505, 245, 475, 231, 449, 437, 213, 415,
      405, 395, 193, 377, 369, 361, 353, 345, 169, 331, 325, 319, 313, 307, 301, 37,
      145, 285, 281, 69, 271, 267, 263, 259, 509, 501, 493, 243, 479, 118, 465, 459,
      113, 446, 55, 435, 429, 423, 209, 413, 51, 403, 199, 393, 97, 3, 379, 375, 371,
      367, 363, 359, 355, 351, 347, 43, 85, 337, 333, 165, 327, 323, 5, 317, 157, 311,
      77, 305, 303, 75, 297, 294, 73, 289, 287, 71, 141, 279, 277, 275, 68, 135, 67,
      133, 33, 262, 260, 129, 511, 507, 503, 499, 495, 491, 61, 121, 481, 477, 237,
      235, 467, 232, 115, 457, 227, 451, 7, 445, 221, 439, 218, 433, 215, 427, 425,
      211, 419, 417, 207, 411, 409, 203, 202, 401, 399, 396, 197, 49, 389, 387, 385,
      383, 95, 189, 47, 187, 93, 185, 23, 183, 91, 181, 45, 179, 89, 177, 11, 175, 87,
      173, 345, 343, 341, 339, 337, 21, 167, 83, 331, 329, 327, 163, 81, 323, 321,
      319, 159, 79, 315, 313, 39, 155, 309, 307, 153, 305, 303, 151, 75, 299, 149, 37,
      295, 147, 73, 291, 145, 289, 287, 143, 285, 71, 141, 281, 35, 279, 139, 69, 275,
      137, 273, 17, 271, 135, 269, 267, 133, 265, 33, 263, 131, 261, 130, 259, 129,
      257, 1];

  static const List<int> SHG_TABLE = const <int>[0, 9, 10, 11, 9, 12, 10, 11,
      12, 9, 13, 13, 10, 9, 13, 13, 14, 14, 14, 14, 10, 13, 14, 14, 14, 13, 13, 13, 9,
      14, 14, 14, 15, 14, 15, 14, 15, 15, 14, 15, 15, 15, 14, 15, 15, 15, 15, 15, 14,
      15, 15, 15, 15, 15, 15, 12, 14, 15, 15, 13, 15, 15, 15, 15, 16, 16, 16, 15, 16,
      14, 16, 16, 14, 16, 13, 16, 16, 16, 15, 16, 13, 16, 15, 16, 14, 9, 16, 16, 16,
      16, 16, 16, 16, 16, 16, 13, 14, 16, 16, 15, 16, 16, 10, 16, 15, 16, 14, 16, 16,
      14, 16, 16, 14, 16, 16, 14, 15, 16, 16, 16, 14, 15, 14, 15, 13, 16, 16, 15, 17,
      17, 17, 17, 17, 17, 14, 15, 17, 17, 16, 16, 17, 16, 15, 17, 16, 17, 11, 17, 16,
      17, 16, 17, 16, 17, 17, 16, 17, 17, 16, 17, 17, 16, 16, 17, 17, 17, 16, 14, 17,
      17, 17, 17, 15, 16, 14, 16, 15, 16, 13, 16, 15, 16, 14, 16, 15, 16, 12, 16, 15,
      16, 17, 17, 17, 17, 17, 13, 16, 15, 17, 17, 17, 16, 15, 17, 17, 17, 16, 15, 17,
      17, 14, 16, 17, 17, 16, 17, 17, 16, 15, 17, 16, 14, 17, 16, 15, 17, 16, 17, 17,
      16, 17, 15, 16, 17, 14, 17, 16, 15, 17, 16, 17, 13, 17, 16, 17, 17, 16, 17, 14,
      17, 16, 17, 16, 17, 16, 17, 9];

  /// Horizontal blur radius in pixels
  double blurX;

  /// Vertical blur radius in pixels
  double blurY;

  /**
   * Number of blur iterations. For example, a value of 1 will produce a rough
   * blur. A value of 2 will produce a smoother blur, but take twice as long to
   * run.
   */
  int quality;

  BlurFilter([this.blurX = 0.0, this.blurY = 0.0, this.quality = 1]) {
    if (blurX < 0) blurX = 0.0;
    if (blurY < 0) blurY = 0.0;
    if (quality < 1) quality = 1;
  }

  /// docced in super class
  @override
  Rectangle<double> get getBounds {
    double q = pow(quality, 0.6) * 0.5;
    return new Rectangle<double>(-blurX * q, -blurY * q, 2 * blurX * q, 2 *
        blurY * q);
  }

  //@override
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

    num radiusX = blurX / 2;
    if (radiusX < 0) return false;
    radiusX = radiusX.truncate();

    num radiusY = this.blurY / 2;
    if (radiusY < 0) return false;
    radiusY = radiusY.truncate();

    if (radiusX == 0 && radiusY == 0) return false;

    int iterations = quality;
    if (iterations < 1) iterations = 1;
    if (iterations > 3) iterations = 3;
    if (iterations < 1) iterations = 1;

    List<int> pixels = imageData.data;

    var r_out_sum, g_out_sum, b_out_sum, a_out_sum, r_in_sum, g_in_sum,
        b_in_sum, a_in_sum, rbs;

    int divx = radiusX + radiusX + 1;
    int divy = radiusY + radiusY + 1;
    int w4 = width << 2;
    int widthMinus1 = width - 1;
    int heightMinus1 = height - 1;
    int rxp1 = radiusX + 1;
    int ryp1 = radiusY + 1;
    Map<String, dynamic> stackStartX = <String, dynamic> {
      'r': 0,
      'b': 0,
      'g': 0,
      'a': 0,
      'next': null
    };
    Map<String, dynamic> stackx = stackStartX;

    for (int i = 1; i < divx; i++) {
      stackx = stackx['next'] = <String, dynamic> {
        'r': 0,
        'b': 0,
        'g': 0,
        'a': 0,
        'next': null
      };
    }

    stackx['next'] = stackStartX;
    Map<String, dynamic> stackStartY = <String, dynamic> {
      'r': 0,
      'b': 0,
      'g': 0,
      'a': 0,
      'next': null
    };
    Map<String, dynamic> stacky = stackStartY;

    for (int i = 1; i < divy; i++) {
      stacky = stacky['next'] = {
        'r': 0,
        'b': 0,
        'g': 0,
        'a': 0,
        'next': null
      };
    }

    stacky['next'] = stackStartY;
    Map<String, dynamic> stackIn;

    while (iterations-- > 0) {
      int yw = 0;
      int yi = 0;
      int mulSum = BlurFilter.MUL_TABLE[radiusX];
      int shgSum = BlurFilter.SHG_TABLE[radiusX];

      for (int y = height; --y > -1; ) {
        int p, pr, pg, pb, pa;
        int rSum = rxp1 * (pr = pixels[yi]);
        int gSum = rxp1 * (pg = pixels[yi + 1]);
        int bSum = rxp1 * (pb = pixels[yi + 2]);
        int aSum = rxp1 * (pa = pixels[yi + 3]);

        stackx = stackStartX;

        for (int i = rxp1; --i > -1; ) {
          stackx['r'] = pr;
          stackx['g'] = pg;
          stackx['b'] = pb;
          stackx['a'] = pa;
          stackx = stackx['next'];
        }

        for (int i = 1; i < rxp1; i++) {
          p = yi + ((widthMinus1 < i ? widthMinus1 : i) << 2);
          rSum += (stackx['r'] = pixels[p]);
          gSum += (stackx['g'] = pixels[p + 1]);
          bSum += (stackx['b'] = pixels[p + 2]);
          aSum += (stackx['a'] = pixels[p + 3]);
          stackx = stackx['next'];
        }

        stackIn = stackStartX;

        for (int x = 0; x < width; x++) {
          pixels[yi++] = ((rSum * mulSum) & 0xFFFFFFFF) >> shgSum;
          pixels[yi++] = ((gSum * mulSum) & 0xFFFFFFFF) >> shgSum;
          pixels[yi++] = ((bSum * mulSum) & 0xFFFFFFFF) >> shgSum;
          pixels[yi++] = ((aSum * mulSum) & 0xFFFFFFFF) >> shgSum;

          p = (yw + ((p = x + radiusX + 1) < widthMinus1 ? p : widthMinus1)) <<
              2;

          rSum -= stackIn['r'] - (stackIn['r'] = pixels[p]);
          gSum -= stackIn['g'] - (stackIn['g'] = pixels[p + 1]);
          bSum -= stackIn['b'] - (stackIn['b'] = pixels[p + 2]);
          aSum -= stackIn['a'] - (stackIn['a'] = pixels[p + 3]);

          stackIn = stackIn['next'];
        }

        yw += width;
      }

      mulSum = BlurFilter.MUL_TABLE[radiusY];
      shgSum = BlurFilter.SHG_TABLE[radiusY];

      for (int x = 0; x < width; x++) {
        int p, pr, pg, pb, pa;
        yi = x << 2;

        int rSum = ryp1 * (pr = pixels[yi]);
        int gSum = ryp1 * (pg = pixels[yi + 1]);
        int bSum = ryp1 * (pb = pixels[yi + 2]);
        int aSum = ryp1 * (pa = pixels[yi + 3]);

        stacky = stackStartY;

        for (int i = 0; i < ryp1; i++) {
          stacky['r'] = pr;
          stacky['g'] = pg;
          stacky['b'] = pb;
          stacky['a'] = pa;
          stacky = stacky['next'];
        }

        int yp = width;

        for (int i = 1; i <= radiusY; i++) {
          yi = (yp + x) << 2;

          rSum += (stacky['r'] = pixels[yi]);
          gSum += (stacky['g'] = pixels[yi + 1]);
          bSum += (stacky['b'] = pixels[yi + 2]);
          aSum += (stacky['a'] = pixels[yi + 3]);

          stacky = stacky['next'];

          if (i < heightMinus1) yp += width;
        }

        yi = x;
        stackIn = stackStartY;

        if (iterations > 0) {
          for (int y = 0; y < height; y++) {
            p = yi << 2;
            pixels[p + 3] = pa = ((aSum * mulSum) & 0xFFFFFFFF) >> shgSum;

            if (pa > 0) {
              pixels[p] = (((rSum * mulSum) & 0xFFFFFFFF) >> shgSum);
              pixels[p + 1] = (((gSum * mulSum) & 0xFFFFFFFF) >> shgSum);
              pixels[p + 2] = (((bSum * mulSum) & 0xFFFFFFFF) >> shgSum);
            } else {
              pixels[p] = pixels[p + 1] = pixels[p + 2] = 0;
            }

            p = (x + (((p = y + ryp1) < heightMinus1 ? p : heightMinus1) *
                width)) << 2;

            rSum -= stackIn['r'] - (stackIn['r'] = pixels[p]);
            gSum -= stackIn['g'] - (stackIn['g'] = pixels[p + 1]);
            bSum -= stackIn['b'] - (stackIn['b'] = pixels[p + 2]);
            aSum -= stackIn['a'] - (stackIn['a'] = pixels[p + 3]);

            stackIn = stackIn['next'];

            yi += width;
          }
        } else {
          for (int y = 0; y < height; y++) {
            p = yi << 2;
            pixels[p + 3] = pa = ((aSum * mulSum) & 0xFFFFFFFF) >> shgSum;

            if (pa > 0) {
              double pa1 = 255 / pa;
              pixels[p] = ((((rSum * mulSum) & 0xFFFFFFFF) >> shgSum) *
                  pa1).round();
              pixels[p + 1] = ((((gSum * mulSum) & 0xFFFFFFFF) >> shgSum) *
                  pa1).round();
              pixels[p + 2] = ((((bSum * mulSum) & 0xFFFFFFFF) >> shgSum) *
                  pa1).round();
            } else {
              pixels[p] = pixels[p + 1] = pixels[p + 2] = 0;
            }

            p = (x + (((p = y + ryp1) < heightMinus1 ? p : heightMinus1) *
                width)) << 2;

            rSum -= stackIn['r'] - (stackIn['r'] = pixels[p]);
            gSum -= stackIn['g'] - (stackIn['g'] = pixels[p + 1]);
            bSum -= stackIn['b'] - (stackIn['b'] = pixels[p + 2]);
            aSum -= stackIn['a'] - (stackIn['a'] = pixels[p + 3]);

            stackIn = stackIn['next'];

            yi += width;
          }
        }
      }
    }

    targetCtx.putImageData(imageData, targetX, targetY);
    return true;
  }

  /// Returns a clone of this object.
  @override
  Filter clone() => new BlurFilter(blurX, blurY, quality);
}
