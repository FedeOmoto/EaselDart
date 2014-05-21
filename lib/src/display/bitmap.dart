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
 * A Bitmap represents an Image, Canvas, or Video in the display list. A Bitmap
 * can be instantiated using an existing HTML element, or a string.
 *
 * ##Example
 *      var bitmap = new createjs.Bitmap("imagePath.jpg");
 *
 * **Notes:**
 * 
 * 1. When a string path or image tag that is not yet loaded is used, the stage
 * may need to be redrawn before it will be displayed.
 * 1. Bitmaps with an SVG source currently will not respect an alpha value other
 * than 0 or 1. To get around this, the Bitmap can be cached.
 * 1. Bitmaps with an SVG source will taint the canvas with cross-origin data,
 * which prevents interactivity. This happens in all browsers except recent
 * Firefox builds.
 * 1. Images loaded cross-origin will throw cross-origin security errors when
 * interacted with using a mouse, using methods such as `getObjectUnderPoint`,
 * or using filters, or caching. You can get around this by setting
 * `crossOrigin` flags on your images before passing them to EaselJS, eg:
 * `img.crossOrigin="Anonymous";`
 */
class Bitmap extends DisplayObject {
  /// The image to render. This can be an Image, a Canvas, or a Video.
  CanvasImageSource image;

  /**
   * Specifies an area of the source image to draw. If omitted, the whole image
   * will be drawn.
   */
  Rectangle<double> sourceRect;

  Bitmap(this.image);

  /**
   * Returns true or false indicating whether the display object would be
   * visible if drawn to a canvas. This does not account for whether it would be
   * visible within the boundaries of the stage.
   *
   * NOTE: This method is mainly for internal use, though it may be useful for
   * advanced uses.
   */
  @override
  bool get isVisible {
    bool hasContent = _cacheCanvas != null || (image != null && ((image is
        ImageElement && (image as ImageElement).complete) || image is CanvasElement ||
        image is VideoElement && (image as VideoElement).readyState >= 2));
    return !!(visible && alpha > 0 && scaleX != 0 && scaleY != 0 && hasContent);
  }

  /**
   * Draws the display object into the specified context ignoring its visible,
   * alpha, shadow, and transform. Returns true if the draw was handled (useful
   * for overriding functionality).
   *
   * NOTE: This method is mainly for internal use, though it may be useful for
   * advanced uses.
   */
  @override
  bool draw(CanvasRenderingContext2D ctx, [bool ignoreCache = false]) {
    if (super.draw(ctx, ignoreCache)) return true;

    if (sourceRect != null) {
      ctx.drawImageScaledFromSource(image, sourceRect.left, sourceRect.top,
          sourceRect.width, sourceRect.height, 0, 0, sourceRect.width, sourceRect.height);
    } else {
      ctx.drawImage(image, 0, 0);
    }

    return true;
  }

  /// Docced in superclass.
  @override
  Rectangle<double> get getBounds {
    Rectangle<double> rect = super.getBounds;
    if (rect != null) return rect;
    dynamic object = sourceRect == null ? image : sourceRect;
    bool hasContent = (image != null && ((image is ImageElement && (image as
        ImageElement).complete) || image is CanvasElement || image is VideoElement &&
        (image as VideoElement).readyState >= 2));

    return hasContent ? _rectangle = new Rectangle<double>(0.0, 0.0,
        object.width, object.height) : null;
  }

  /// Returns a clone of the Bitmap instance.
  @override
  Bitmap clone([bool recursive = false]) {
    Bitmap bitmap = new Bitmap(image);

    if (sourceRect != null) {
      bitmap.sourceRect = new Rectangle<double>(sourceRect.left, sourceRect.top,
          sourceRect.width, sourceRect.height);
    }

    _cloneProps(bitmap);
    return bitmap;
  }
}
