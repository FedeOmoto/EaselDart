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
 * Applies a color transform to DisplayObjects.
 *
 * ##Example
 * This example draws a red circle, and then transforms it to Blue. This is
 * accomplished by multiplying all the channels to 0 (except alpha, which is set
 * to 1), and then adding 255 to the blue channel.
 *
 *      var shape = new createjs.Shape().set({x:100,y:100});
 *      shape.graphics.beginFill("#ff0000").drawCircle(0,0,50);
 *
 *      shape.filters = [
 *          new createjs.ColorFilter(0,0,0,1, 0,0,255,0)
 *      ];
 *      shape.cache(-50, -50, 100, 100);
 *
 * See [Filter] for more information on applying filters.
 * @class ColorFilter
 */
class ColorFilter extends Filter {
  /// Red channel multiplier.
  double redMultiplier;

  /// Green channel multiplier.
  double greenMultiplier;

  /// Blue channel multiplier.
  double blueMultiplier;

  /// Alpha channel multiplier.
  double alphaMultiplier;

  /// Red channel offset (added to value).
  int redOffset;

  /// Green channel offset (added to value).
  int greenOffset;

  /// Blue channel offset (added to value).
  int blueOffset;

  /// Alpha channel offset (added to value).
  int alphaOffset;

  ColorFilter({this.redMultiplier: 1.0, this.greenMultiplier:
      1.0, this.blueMultiplier: 1.0, this.alphaMultiplier: 1.0, this.redOffset:
      0, this.greenOffset: 0, this.blueOffset: 0, this.alphaOffset: 0});

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

    for (int i = 0; i < pixels.length; i += 4) {
      pixels[i] = (pixels[i] * redMultiplier + redOffset).round();
      pixels[i + 1] = (pixels[i + 1] * greenMultiplier + greenOffset).round();
      pixels[i + 2] = (pixels[i + 2] * blueMultiplier + blueOffset).round();
      pixels[i + 3] = (pixels[i + 3] * alphaMultiplier + alphaOffset).round();
    }

    targetCtx.putImageData(imageData, targetX, targetY);
    return true;
  }

  /// Returns a clone of this ColorFilter instance.
  @override
  ColorFilter clone() {
    return new ColorFilter(redMultiplier: redMultiplier, greenMultiplier:
        greenMultiplier, blueMultiplier: blueMultiplier, alphaMultiplier:
        alphaMultiplier, redOffset: redOffset, greenOffset: greenOffset, blueOffset:
        blueOffset, alphaOffset: alphaOffset);
  }
}
