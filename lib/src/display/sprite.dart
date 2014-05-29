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
 * Displays a frame or sequence of frames (ie. an animation) from a SpriteSheet
 * instance. A sprite sheet is a series of images (usually animation frames)
 * combined into a single image. For example, an animation consisting of 8
 * 100x100 images could be combined into a 400x200 sprite sheet (4 frames across
 * by 2 high). You can display individual frames, play frames as an animation,
 * and even sequence animations together.
 *
 * See the [SpriteSheet] class for more information on setting up frames and
 * animations.
 *
 * ##Example
 *      var instance = new createjs.Sprite(spriteSheet);
 *      instance.gotoAndStop("frameName");
 *
 * Until [gotoAndStop] or [gotoAndPlay] is called, only the first defined frame
 * defined in the sprite sheet will be displayed.
 */
class Sprite extends DisplayObject {
  int _currentFrame = 0;
  String _currentAnimation;
  final SpriteSheet _spriteSheet;

  /**
   * Prevents the animation from advancing each tick automatically. For example,
   * you could create a sprite sheet of icons, set paused to true, and display
   * the appropriate icon by setting `currentFrame`.
   */
  bool paused = true;

  int offset = 0;

  /**
   * Specifies the current frame index within the currently playing animation.
   * When playing normally, this will increase from 0 to n-1, where n is the
   * number of frames in the current animation.
   *
   * This could be a non-integer value if using time-based playback (see
   * [framerate]), or if the animation's speed is not an integer.
   */
  double currentAnimationFrame = 0.0;

  /**
   * By default Sprite instances advance one frame per tick. Specifying a
   * framerate for the Sprite (or its related SpriteSheet) will cause it to
   * advance based on elapsed time between ticks as appropriate to maintain the
   * target framerate.
   *
   * For example, if a Sprite with a framerate of 10 is placed on a Stage being
   * updated at 40fps, then the Sprite will advance roughly one frame every 4
   * ticks. This will not be exact, because the time between each tick will vary
   * slightly between frames.
   *
   * This feature is dependent on the tick event object (or an object with an
   * appropriate "delta" property) being passed into [Stage.update].
   */
  int framerate = 0;

  int _advanceCount = 0;
  Map<String, Object> _animation;

  Sprite(this._spriteSheet, dynamic frameOrAnimation) {
    if (frameOrAnimation != null) gotoAndPlay(frameOrAnimation);
  }

  /**
   * The frame index that will be drawn when draw is called. Note that with some
   * [SpriteSheet] definitions, this will advance non-sequentially. This will
   * always be an integer value.
   */
  int get currentFrame => _currentFrame;

  /// Returns the name of the currently playing animation.
  String get currentAnimation => _currentAnimation;

  /**
   * The SpriteSheet instance to play back. This includes the source image,
   * frame dimensions, and frame data. See [SpriteSheet] for more information.
   */
  SpriteSheet get spriteSheet => _spriteSheet;

  /**
   * Returns true or false indicating whether the display object would be
   * visible if drawn to a canvas. This does not account for whether it would be
   * visible within the boundaries of the stage.
   * NOTE: This method is mainly for internal use, though it may be useful for
   * advanced uses.
   */
  @override
  bool get isVisible {
    bool hasContent = _cacheCanvas != null || _spriteSheet._complete;
    return !!(visible && alpha > 0 && scaleX != 0 && scaleY != 0 && hasContent);
  }

  /**
   * Draws the display object into the specified context ignoring its visible,
   * alpha, shadow, and transform. Returns true if the draw was handled (useful
   * for overriding functionality).
   * NOTE: This method is mainly for internal use, though it may be useful for
   * advanced uses.
   */
  @override
  bool draw(CanvasRenderingContext2D ctx, [bool ignoreCache = false]) {
    if (super.draw(ctx, ignoreCache)) return true;
    _normalizeFrame();
    Map<String, Object> object = _spriteSheet.getFrame(_currentFrame);
    if (object == null) return false;
    Rectangle<double> rect = object['rect'];
    ctx.drawImageScaledFromSource(object['image'], rect.left, rect.top,
        rect.width, rect.height, -(object['regX'] as double), -(object['regY'] as
        double), rect.width, rect.height);

    return true;
  }

  /**
   * Play (unpause) the current animation. The Sprite will be paused if either
   * [stop] or [gotoAndStop] is called. Single frame animations will remain
   * unchanged.
   */
  void play() {
    paused = false;
  }

  /**
   * Stop playing a running animation. The Sprite will be playing if
   * [gotoAndPlay] is called. Note that calling [gotoAndPlay] or [play] will
   * resume playback.
   */
  void stop() {
    paused = true;
  }

  /**
   * Sets paused to false and plays the specified animation name, named frame,
   * or frame number.
   */
  void gotoAndPlay(dynamic frameOrAnimation) {
    paused = false;
    _goto(frameOrAnimation);
  }

  /**
   * Sets paused to true and seeks to the specified animation name, named frame,
   * or frame number.
   */
  void gotoAndStop(dynamic frameOrAnimation) {
    paused = true;
    _goto(frameOrAnimation);
  }

  /// Advances the playhead. This occurs automatically each tick by default.
  void advance([double time]) {
    num speed = (_animation != null && _animation['speed'] != 0) ?
        _animation['speed'] : 1;
    int fps = framerate != 0 ? framerate : _spriteSheet._ssd.framerate;
    double t = (fps != 0 && time != null) ? time / (1000 / fps) : 1.0;

    if (_animation != null) {
      currentAnimationFrame += t * speed;
    } else {
      _currentFrame += t * speed;
    }

    _normalizeFrame();
  }

  /**
   * Returns a Rectangle instance defining the bounds of the current frame
   * relative to the origin. For example, a 90 x 70 frame with `regX=50` and
   * `regY=40` would return a rectangle with [x=-50, y=-40, width=90, 
   * height=70]. This ignores transformations on the display object.
   *
   * Also see the SpriteSheet [SpriteSheet.getFrameBounds] method.
   */
  @override
  Rectangle<double> get getBounds {
    Rectangle<double> bounds;

    // TODO: should this normalizeFrame?
    if ((bounds = super.getBounds) != null) {
      return bounds;
    } else {
      return _spriteSheet.getFrameBounds(_currentFrame);
    }
  }

  /**
   * Returns a clone of the Sprite instance. Note that the same SpriteSheet is
   * shared between cloned instances.
   */
  @override
  Sprite clone([bool recursive = false]) {
    Sprite sprite = new Sprite(_spriteSheet, null);
    _cloneProps(sprite);
    return sprite;
  }

  // Advances the `currentFrame` if paused is not true. This is called
  // automatically when the [Stage] ticks./
  @override
  void _tick(Map<Symbol, Object> props) {
    if (!paused) {
      if (props != null && props[#delta] != null) advance(props[#delta]);
    } else {
      advance();
    }

    super._tick(props);
  }

  // Normalizes the current frame, advancing animations and dispatching
  // callbacks as appropriate.
  void _normalizeFrame() {
    bool paused = this.paused;
    int frame = _currentFrame;
    int animFrame = currentAnimationFrame.round();
    int l;

    if (_animation != null) {
      l = (_animation['frames'] as List<int>).length;

      if (animFrame >= l) {
        Object next = _animation['next'];

        if (_dispatchAnimationEnd(_animation, frame, paused, next, l - 1)) {
          // something changed in the event stack.
        } else if (next != null && next != false) {
          // sequence. Automatically calls _normalizeFrame again.
          return _goto(next, animFrame - l);
        } else {
          // end.
          this.paused = true;
          animFrame = (_animation['frames'] as List<int>).length - 1;
          currentAnimationFrame = animFrame.toDouble();
          _currentFrame = (_animation['frames'] as List<int>)[animFrame];
        }
      } else {
        _currentFrame = (_animation['frames'] as List<int>)[animFrame];
      }
    } else {
      l = _spriteSheet.getNumFrames();

      if (frame >= l) {
        if (!_dispatchAnimationEnd(_animation, frame, paused, l - 1)) {
          // looped.
          if ((_currentFrame -= l) >= l) {
            return _normalizeFrame();
          }
        }
      }
    }
  }

  // Dispatches the "animationend" event. Returns true if a handler changed the
  // animation (ex. calling [stop], [gotoAndPlay], etc.)
  bool _dispatchAnimationEnd(Map<String, Object> animation, int frame, bool
      paused, dynamic next, [int end]) {
    String name = animation != null ? animation['name'] : null;

    if (hasEventListener('animationend')) {
      AnimationEndEvent evt = new AnimationEndEvent();
      evt.name = name;
      evt.next = next;
      dispatchEvent(evt);
    }

    // did the animation get changed in the event stack?:
    bool changed = (_animation != animation || _currentFrame != frame);

    // if the animation hasn't changed, but the sprite was paused, then we want to stick to the last frame:
    if (!changed && !paused && this.paused) {
      currentAnimationFrame = end != null ? end.toDouble() : 0.0;
      changed = true;
    }

    return changed;
  }

  @override
  void _cloneProps(Sprite sprite) {
    super._cloneProps(sprite);
    sprite._currentFrame = _currentFrame;
    sprite._currentAnimation = _currentAnimation;
    sprite.paused = paused;
    sprite._animation = _animation;
    sprite.currentAnimationFrame = currentAnimationFrame;
    sprite.framerate = framerate;
  }

  // Moves the playhead to the specified frame number or animation.
  void _goto(dynamic frameOrAnimation, [int frame = 0]) {
    if (frameOrAnimation is String) {
      Map<String, Object> data = _spriteSheet.getAnimation(frameOrAnimation);
      if (data != null) {
        currentAnimationFrame = frame.toDouble();
        _animation = data;
        _currentAnimation = frameOrAnimation;
        _normalizeFrame();
      }
    } else {
      currentAnimationFrame = 0.0;
      _currentAnimation = _animation = null;
      _currentFrame = frameOrAnimation;
      _normalizeFrame();
    }
  }
}
