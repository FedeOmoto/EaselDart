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
 * Encapsulates the properties and methods associated with a sprite sheet.
 * A sprite sheet is a series of images (usually animation frames) combined
 * into a larger image (or images). For example, an animation consisting of
 * eight 100x100 images could be combined into a single 400x200 sprite sheet
 * (4 frames across by 2 high).
 *
 * The data passed to the SpriteSheet constructor defines three critical pieces
 * of information:
 * 
 * 1. The image or images to use.
 * 
 * 1. The positions of individual image frames. This data can be represented in
 * one of two ways: As a regular grid of sequential, equal-sized frames, or as
 * individually defined, variable sized frames arranged in an irregular
 * (non-sequential) fashion.
 * 
 * 1. Likewise, animations can be represented in two ways: As a series of
 * sequential frames, defined by a start and end frame [0,3], or as a list of
 * frames [0,1,2,3].
 * 
 * ##SpriteSheet Format
 *
 *      data = {
 *          // DEFINING FRAMERATE:
 *          // This specifies the framerate that will be set on the SpriteSheet.
 *          // See framerate for more information.
 *          framerate: 20,
 *
 *          // DEFINING IMAGES:
 *          // List of images or image URIs to use. SpriteSheet can handle
 *          // preloading.
 *          // The order dictates their index value for frame definition.
 *          images: [image1, "path/to/image2.png"],
 *
 *          // DEFINING FRAMES:
 *              // The simple way to define frames, only requires frame size
 *              // because frames are consecutive:
 *              // Define frame width/height, and optionally the frame count and
 *              // registration point x/y.
 *              // If count is omitted, it will be calculated automatically
 *              // based on image dimensions.
 *              frames: {width:64, height:64, count:20, regX: 32, regY:64},
 *
 *              // OR, the complex way that defines individual rects for frames.
 *              // The 5th value is the image index per the list defined in
 *              // "images" (defaults to 0).
 *              frames: [
 *                      // x, y, width, height, imageIndex, regX, regY
 *                      [0,0,64,64,0,32,64],
 *                      [64,0,96,64,0]
 *              ],
 *
 *          // DEFINING ANIMATIONS:
 *
 *              // Simple animation definitions. Define a consecutive range of
 *              // frames (begin to end inclusive).
 *              // Optionally define a "next" animation to sequence to (or false
 *              // to stop) and a playback "speed".
 *              animations: {
 *                      // start, end, next, speed
 *                      run: [0,8],
 *                      jump: [9,12,"run",2]
 *              }
 *
 *          // The complex approach which specifies every frame in the animation
 *          // by index.
 *          animations: {
 *              run: {
 *                      frames: [1,2,3,3,2,1]
 *              },
 *              jump: {
 *                      frames: [1,4,5,6,1],
 *                      next: "run",
 *                      speed: 2
 *              },
 *              stand: { frames: [7] }
 *          }
 *
 *              // The above two approaches can be combined, you can also use a
 *              // single frame definition:
 *              animations: {
 *                      run: [0,8,true,2],
 *                      jump: {
 *                              frames: [8,9,10,9,8],
 *                              next: "run",
 *                              speed: 2
 *                      },
 *                      stand: 7
 *              }
 *      }
 *
 * ##Example
 * 
 * To define a simple sprite sheet, with a single image "sprites.jpg" arranged
 * in a regular 50x50 grid with two animations, "run" looping from frame 0-4
 * inclusive, and "jump" playing from frame 5-8 and sequencing back to run:
 *
 *      var data = {
 *          images: ["sprites.jpg"],
 *          frames: {width:50, height:50},
 *          animations: {run:[0,4], jump:[5,8,"run"]}
 *      };
 *      var spriteSheet = new createjs.SpriteSheet(data);
 *      var animation = new createjs.Sprite(spriteSheet, "run");
 *
 *
 * **Warning:** Images loaded cross-origin will throw cross-origin security
 * errors when interacted with using a mouse, using methods such as
 * `getObjectUnderPoint`, using filters, or caching. You can get around this by
 * setting `crossOrigin` flags on your images before passing them to EaselJS,
 * eg: `img.crossOrigin="Anonymous";`
 */
class SpriteSheet extends create_dart.EventDispatcher {
  bool _complete = true;
  List<Map<String, Object>> _frames;
  Map<String, Map<String, Object>> _data;
  int _loadCount = 0;
  int _numFrames = 0;
  SpriteSheetData _ssd;

  SpriteSheet(this._ssd) {
    if (_ssd == null) return;

    // parse images:
    if (_ssd.images != null && _ssd.images.length > 0) {
      _ssd.images.forEach((CanvasImageSource img) {
        if (img is ImageElement && !img.complete) {
          _loadCount++;
          _complete = false;
          img.onLoad.listen(_handleImageLoad);
        }
      });
    }

    // parse frames:
    if (_ssd.frames != null) {
      _numFrames = _ssd.frames['count'];
      if (_loadCount == 0) _calculateFrames();
    }

    // parse animations:
    if (_ssd.animations != null) {
      List<int> frames;
      _data = new Map<String, Map<String, Object>>();

      _ssd.animations.forEach((String name, Object value) {
        Map<String, Object> anim = new Map<String, Object>();
        anim['name'] = name;
        Object obj = _ssd.animations[name];

        if (obj is int) { // single frame
          frames = anim['frames'] = <int>[obj];
        } else if (obj is List) { // simple
          if (obj.length == 1) {
            anim['frames'] = <int>[obj[0]];
          } else {
            num speed;
            Object next;

            try {
              next = obj[2];
              speed = obj[3];
            } on RangeError {}

            if (speed != null) anim['speed'] = speed;
            if (next != null) anim['next'] = next;
            frames = anim['frames'] = new List<int>();

            for (int i = obj[0]; i <= obj[1]; i++) {
              frames.add(i);
            }
          }
        } else { // complex
          anim['speed'] = (obj as Map<String, Object>)['speed'];
          anim['next'] = (obj as Map<String, Object>)['next'];
          Object tmpFrames = (obj as Map<String, Object>)['frames'];
          frames = anim['frames'] = (tmpFrames is int) ? <int>[tmpFrames] :
              new List<int>.from(tmpFrames);
        }

        if (anim['next'] == true || anim.containsKey('next') == false) { // loop
          anim['next'] = name;
        }

        if (anim['next'] == false || (frames.length < 2 && anim['next'] ==
            name)) { // stop
          anim['next'] = null;
        }

        if (anim['speed'] == null) anim['speed'] = 1;

        _data[name] = anim;
      });
    }
  }

  /// Indicates whether all images are finished loading.
  bool get complete => _complete;

  /**
   * Returns the total number of frames in the specified animation, or in the
   * whole sprite sheet if the animation param is omitted.
   */
  int getNumFrames([String animation]) {
    if (animation == null) {
      return _frames != null ? _frames.length : _numFrames;
    } else {
      Map<String, Object> data = _data[animation];

      if (data == null) {
        return 0;
      } else {
        return (data['frames'] as List<int>).length;
      }
    }
  }

  /// Returns an array of all available animation names as strings.
  List<String> get getAnimations => new List<String>.from(_ssd.animations.keys);

  /**
   * Returns an object defining the specified animation. The returned object
   * contains:
   * 
   * * frames: an array of the frame ids in the animation
   * * speed: the playback speed for this animation
   * * name: the name of the animation
   * * next: the default animation to play next. If the animation loops, the
   * name and next property will be the same.
   */
  Map<String, Object> getAnimation(String name) => _data[name];

  /**
   * Returns an object specifying the image and source rect of the specified
   * frame. The returned object has:
   * 
   * * an image property holding a reference to the image object in which the
   * frame is found
   * * a rect property containing a Rectangle instance which defines the
   * boundaries for the frame within that image.
   */
  Map<String, Object> getFrame(int frameIndex) {
    Map<String, Object> frame;

    if (_frames != null) {
      try {
        frame = _frames[frameIndex];
      } on RangeError {}

      if (frame != null) return frame;
    }

    return null;
  }

  /**
   * Returns a [Rectangle] instance defining the bounds of the specified frame
   * relative to the origin. For example, a 90 x 70 frame with a regX of 50 and
   * a regY of 40 would return:
   *
   *      [x=-50, y=-40, width=90, height=70]
   */
  Rectangle<double> getFrameBounds(int frameIndex) {
    Map<String, Object> frame = getFrame(frameIndex);
    return frame != null ? new Rectangle<double>(-(frame['regX'] as double),
        -(frame['regY'] as double), (frame['rect'] as Rectangle<double>).width,
        (frame['rect'] as Rectangle<double>).height) : null;
  }

  /// Returns a clone of the SpriteSheet instance.
  SpriteSheet clone() {
    // TODO: there isn't really any reason to clone SpriteSheet instances,
    // because they can be reused.
    var ss = new SpriteSheet(null);
    ss._complete = _complete;
    ss._frames = _frames;
    ss._data = _data;
    ss._numFrames = _numFrames;
    ss._loadCount = _loadCount;

    return ss;
  }

  void _handleImageLoad(Event envet) {
    if (--_loadCount == 0) {
      _calculateFrames();
      _complete = true;
      dispatchEvent(new create_dart.Event('complete'));
    }
  }

  void _calculateFrames() {
    if (_frames != null || _ssd.frames['width'] == 0) return;
    _frames = new List<Map<String, Object>>();
    int ttlFrames = 0;
    double fw = _ssd.frames['width'].toDouble();
    double fh = _ssd.frames['height'].toDouble();

    _ssd.images.forEach((CanvasImageSource img) {
      double cols = ((img as ImageElement).width / fw).truncateToDouble();
      double rows = ((img as ImageElement).height / fh).truncateToDouble();

      int ttl = _numFrames > 0 ? min(_numFrames - ttlFrames, cols * rows) :
          (cols * rows).toInt();

      for (int j = 0; j < ttl; j++) {
        _frames.add({
          'image': img,
          'rect': new Rectangle<double>(j % cols * fw, (j /
              cols).truncateToDouble() * fh, fw, fh),
          'regX': _ssd.frames['regX'],
          'regY': _ssd.frames['regY']
        });
      }

      ttlFrames += ttl;
    });

    _numFrames = ttlFrames;
  }
}
