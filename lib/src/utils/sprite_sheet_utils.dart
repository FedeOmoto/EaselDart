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
 * The SpriteSheetUtils class is a collection of static methods for working with
 * [SpriteSheet]s. A sprite sheet is a series of images (usually animation
 * frames) combined into a single image on a regular grid. For example, an
 * animation consisting of 8 100x100 images could be combined into a 400x200
 * sprite sheet (4 frames across by 2 high). The SpriteSheetUtils class uses a
 * static interface and should not be instantiated.
 */
class SpriteSheetUtils {
  static CanvasElement _workingCanvas = new CanvasElement(width: 1, height: 1);
  static CanvasRenderingContext2D _workingContext = _workingCanvas.context2D;

  /// Answer the singleton instance of the Touch class.
  static SpriteSheetUtils get current => SpriteSheetUtils._singleton;

  static final SpriteSheetUtils _singleton = new SpriteSheetUtils._internal();

  factory SpriteSheetUtils() {
    throw new UnsupportedError(
        'SpriteSheetUtils cannot be instantiated, use SpriteSheetUtils.current');
  }

  SpriteSheetUtils._internal();

  /**
   * **This is an experimental method, and may be buggy. Please report issues.**
   * <br/><br/>
   * Extends the existing sprite sheet by flipping the original frames
   * horizontally, vertically, or both, and adding appropriate animation & frame
   * data. The flipped animations will have a suffix added to their names (_h,
   * _v, _hv as appropriate). Make sure the sprite sheet images are fully loaded
   * before using this method.
   * <br/><br/>
   * For example:<br/>
   * SpriteSheetUtils.addFlippedFrames(mySpriteSheet, true, true);
   * The above would add frames that are flipped horizontally AND frames that
   * are flipped vertically.
   * <br/><br/>
   * Note that you can also flip any display object by setting its scaleX or
   * scaleY to a negative value. On some browsers (especially those without
   * hardware accelerated canvas) this can result in slightly degraded
   * performance, which is why addFlippedFrames is available.
   */
  addFlippedFrames(SpriteSheet spriteSheet, bool horizontal, bool vertical, bool
      both) {
    if (!horizontal && !vertical && !both) return;

    int count = 0;
    if (horizontal) _flip(spriteSheet, ++count, true, false);
    if (vertical) _flip(spriteSheet, ++count, false, true);
    if (both) _flip(spriteSheet, ++count, true, true);
  }

  /**
   * Returns a single frame of the specified sprite sheet as a new PNG image. An
   * example of when this may be useful is to use a spritesheet frame as the
   * source for a bitmap fill.
   *
   * **WARNING:** In almost all cases it is better to display a single frame
   * using a [Sprite] with a [Sprite.gotoAndStop] call than it is to slice out a
   * frame using this method and display it with a Bitmap instance. You can also
   * crop an image using the [Bitmap.sourceRect] property of [Bitmap].
   *
   * The extractFrame method may cause cross-domain warnings since it accesses
   * pixels directly on the canvas.
   */
  ImageElement extractFrame(SpriteSheet spriteSheet, dynamic frameOrAnimation) {
    if (frameOrAnimation is String) {
      frameOrAnimation = (spriteSheet.getAnimation(frameOrAnimation)['frames']
          as List<int>)[0];
    }

    Map<String, Object> data = spriteSheet.getFrame(frameOrAnimation);
    if (data == null) return null;
    Rectangle<double> r = data['rect'];
    CanvasElement canvas = SpriteSheetUtils._workingCanvas;
    canvas.width = r.width.round();
    canvas.height = r.height.round();
    SpriteSheetUtils._workingContext.drawImageScaledFromSource(data['image'],
        r.left, r.top, r.width, r.height, 0, 0, r.width, r.height);
    ImageElement img = new ImageElement();
    img.src = canvas.toDataUrl();

    return img;
  }

  /**
   * Merges the rgb channels of one image with the alpha channel of another.
   * This can be used to combine a compressed JPEG image containing color data
   * with a PNG32 monochromatic image containing alpha data. With certain types
   * of images (those with detail that lend itself to JPEG compression) this can
   * provide significant file size savings versus a single RGBA PNG32. This
   * method is very fast (generally on the order of 1-2 ms to run).
   */
  CanvasElement mergeAlpha(ImageElement rgbImage, ImageElement
      alphaImage, [CanvasElement canvas]) {
    if (canvas == null) canvas = new CanvasElement();
    canvas.width = max(alphaImage.width, rgbImage.width);
    canvas.height = max(alphaImage.height, rgbImage.height);
    CanvasRenderingContext2D ctx = canvas.context2D;
    ctx.save();
    ctx.drawImage(rgbImage, 0, 0);
    ctx.globalCompositeOperation = 'destination-in';
    ctx.drawImage(alphaImage, 0, 0);
    ctx.restore();

    return canvas;
  }

  void _flip(SpriteSheet spriteSheet, int count, bool h, bool v) {
    List<CanvasImageSource> imgs = spriteSheet._ssd.images;
    CanvasElement canvas = SpriteSheetUtils._workingCanvas;
    CanvasRenderingContext2D ctx = SpriteSheetUtils._workingContext;
    int il = (imgs.length ~/ count);
    Map<ImageElement, int> tmp = new Map<ImageElement, int>();

    for (int i = 0; i < il; i++) {
      ImageElement src = imgs[i];
      tmp[src] = i;
      ctx.setTransform(1, 0, 0, 1, 0, 0);
      ctx.clearRect(0, 0, canvas.width + 1, canvas.height + 1);
      canvas.width = src.width;
      canvas.height = src.height;
      ctx.setTransform(h ? -1 : 1, 0, 0, v ? -1 : 1, h ? src.width : 0, v ?
          src.height : 0);
      ctx.drawImage(src, 0, 0);
      ImageElement img = new ImageElement();
      img.src = canvas.toDataUrl();
      // work around a strange bug in Safari:
      img.width = src.width;
      img.height = src.height;
      imgs.add(img);
    }

    List<Map<String, Object>> frames = spriteSheet._frames;
    int fl = frames.length ~/ count;

    for (int i = 0; i < fl; i++) {
      Map<String, Object> src = frames[i];
      Rectangle<double> rect = src['rect'];
      ImageElement img = imgs[tmp[src['image']] + il * count];
      Map<String, Object> frame = <String, Object> {
        'image': img,
        'regX': src['regX'],
        'regY': src['regY']
      };

      if (h) {
        // update rect
        double left = img.width - rect.left - rect.width;
        rect = new Rectangle<double>(left, rect.top, rect.width, rect.height);

        // update registration point
        frame['regX'] = rect.width - src['regX'];
      }

      if (v) {
        // update rect
        double top = img.height - rect.top - rect.height;
        rect = new Rectangle<double>(rect.left, top, rect.width, rect.height);

        // update registration point
        frame['regY'] = rect.height - src['regY'];
      }

      frame['rect'] = rect;
      frames.add(frame);
    }

    String sfx = '_' + (h ? 'h' : '') + (v ? 'v' : '');
    List<String> names = spriteSheet._animations;
    Map<String, Map<String, Object>> data = spriteSheet._data;
    int al = names.length ~/ count;

    for (int i = 0; i < al; i++) {
      String name = names[i];
      Map<String, Object> src = data[name];

      Map<String, Object> anim = {
        'name': name + sfx,
        'speed': src['speed'],
        'next': src['next'],
        'frames': new List<int>()
      };

      if (src['next'] != null) {
        anim['next'] = (anim['next'] as String) + sfx;
      }

      (src['frames'] as List<int>).forEach((int frame) {
        (anim['frames'] as List<int>).add(frame + fl * count);
      });

      data[anim['name']] = anim;
      names.add(anim['name']);
    }
  }
}
