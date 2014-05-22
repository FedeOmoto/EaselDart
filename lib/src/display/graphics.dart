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
 * Inner class used by the [Graphics] class. Used to create the instruction
 * lists used in Graphics:
 */
class Command {
  Symbol _memberName;
  List _args;
  bool _path;

  Command(this._memberName, this._args, [this._path = true]);

  void call(CanvasRenderingContext2D ctx) {
    InstanceMirror im = reflect(ctx);

    if (im.type.instanceMembers[_memberName].isGetter) {
      im.setField(_memberName, _args[0]);
    } else {
      im.invoke(_memberName, _args);
    }
  }
}

/**
 * The Graphics class exposes an easy to use API for generating vector drawing
 * instructions and drawing them to a specified context. Note that you can use
 * Graphics without any dependency on the Easel framework by calling
 * [DisplayObject.draw] directly, or it can be used with the [Shape] object to
 * draw vector graphics within the context of an Easel display list.
 *
 * ##Example
 *      var g = new createjs.Graphics();
 *          g.setStrokeStyle(1);
 *          g.beginStroke(createjs.Graphics.getRGB(0,0,0));
 *          g.beginFill(createjs.Graphics.getRGB(255,0,0));
 *          g.drawCircle(0,0,3);
 *
 *          var s = new createjs.Shape(g);
 *              s.x = 100;
 *              s.y = 100;
 *
 *          stage.addChild(s);
 *          stage.update();
 *
 * Note that all drawing methods in Graphics return the Graphics instance, so
 * they can be chained together. For example, the following line of code would
 * generate the instructions to draw a rectangle with a red stroke and blue
 * fill, then render it to the specified context2D:
 *
 *      myGraphics.beginStroke("#F00").beginFill("#00F").drawRect(20, 20, 100, 50).draw(myContext2D);
 *
 * ##Tiny API
 * The Graphics class also includes a "tiny API", which is one or two-letter
 * methods that are shortcuts for all of the Graphics methods. These methods are
 * great for creating compact instructions, and is used by the Toolkit for
 * CreateJS to generate readable code. All tiny methods are marked as protected,
 * so you can view them by enabling protected descriptions in the docs.
 *
 * <table border="1" style="background-color: #f5f5f5; width: 100%;">
 * <tr style="background-color: #cccccc;"><th>Tiny</th><th>Method</th>
 * <th>Tiny</th><th>Method</th></tr>
 * <tr><td>mt</td><td>[moveTo]</td>
 * <td>lt</td><td>[lineTo]</td></tr>
 * <tr><td>a/at</td><td>[arc] / [arcTo]</td>
 * <td>bt</td><td>[bezierCurveTo]</td></tr>
 * <tr><td>qt</td><td>[quadraticCurveTo] (also curveTo)</td>
 * <td>r</td><td>[rect]</td></tr>
 * <tr><td>cp</td><td>[closePath]</td>
 * <td>c</td><td>[clear]</td></tr>
 * <tr><td>f</td><td>[beginFill]</td>
 * <td>lf</td><td>[beginLinearGradientFill]</td></tr>
 * <tr><td>rf</td><td>[beginRadialGradientFill]</td>
 * <td>bf</td><td>[beginBitmapFill]</td></tr>
 * <tr><td>ef</td><td>[endFill]</td>
 * <td>ss</td><td>[setStrokeStyle]</td></tr>
 * <tr><td>s</td><td>[beginStroke]</td>
 * <td>ls</td><td>[beginLinearGradientStroke]</td></tr>
 * <tr><td>rs</td><td>[beginRadialGradientStroke]</td>
 * <td>bs</td><td>[beginBitmapStroke]</td></tr>
 * <tr><td>es</td><td>[endStroke]</td>
 * <td>dr</td><td>[drawRect]</td></tr>
 * <tr><td>rr</td><td>[drawRoundRect]</td>
 * <td>rc</td><td>[drawRoundRectComplex]</td></tr>
 * <tr><td>dc</td><td>[drawCircle]</td>
 * <td>de</td><td>[drawEllipse]</td></tr>
 * <tr><td>dp</td><td>[drawPolyStar]</td>
 * <td>p</td><td>[decodePath]</td></tr>
 * </table>
 * 
 * <br>
 * 
 * Here is the above example, using the tiny API instead.
 *
 *      myGraphics.s("#F00").f("#00F").r(20, 20, 100, 50).draw(myContext2D);
 */
class Graphics {
  /**
   * Returns a CSS compatible color string based on the specified RGB numeric
   * color values in the format "rgba(255,255,255,1.0)", or if alpha is null
   * then in the format "rgb(255,255,255)". For example,
   *
   *      createjs.Graphics.getRGB(50, 100, 150, 0.5);
   *      // Returns "rgba(50,100,150,0.5)"
   *
   * It also supports passing a single hex color value as the first param, and
   * an optional alpha value as the second param. For example,
   *
   *      createjs.Graphics.getRGB(0xFF00FF, 0.2);
   *      // Returns "rgba(255,0,255,0.2)"
   */
  static String getRGB(int r, int g, int b, [double alpha]) {
    if (alpha == null) {
      return 'rgb($r,$g,$b)';
    } else {
      return 'rgba($r,$g,$b,$alpha)';
    }
  }

  static String getRGBFromHex(int hex, [double alpha]) {
    int b = hex & 0xFF;
    int g = hex >> 8 & 0xFF;
    int r = hex >> 16;

    if (alpha == null) {
      return 'rgb($r,$g,$b)';
    } else {
      return 'rgba($r,$g,$b,$alpha)';
    }
  }

  /**
   * Returns a CSS compatible color string based on the specified HSL numeric
   * color values in the format "hsla(360,100,100,1.0)", or if alpha is null
   * then in the format "hsl(360,100,100)".
   *
   *      createjs.Graphics.getHSL(150, 100, 70);
   *      // Returns "hsl(150,100,70)"
   */
  static String getHSL(int hue, int saturation, int lightness, [double alpha]) {
    if (alpha == null) {
      return 'hsl(${hue%360},$saturation%,$lightness%)';
    } else {
      return 'hsla(${hue%360},$saturation%,$lightness%,$alpha)';
    }
  }

  /// Map of Base64 characters to values. Used by [decodePath].
  static const Map<String, int> BASE_64 = const <String, int> {
    'A': 0,
    'B': 1,
    'C': 2,
    'D': 3,
    'E': 4,
    'F': 5,
    'G': 6,
    'H': 7,
    'I': 8,
    'J': 9,
    'K': 10,
    'L': 11,
    'M': 12,
    'N': 13,
    'O': 14,
    'P': 15,
    'Q': 16,
    'R': 17,
    'S': 18,
    'T': 19,
    'U': 20,
    'V': 21,
    'W': 22,
    'X': 23,
    'Y': 24,
    'Z': 25,
    'a': 26,
    'b': 27,
    'c': 28,
    'd': 29,
    'e': 30,
    'f': 31,
    'g': 32,
    'h': 33,
    'i': 34,
    'j': 35,
    'k': 36,
    'l': 37,
    'm': 38,
    'n': 39,
    'o': 40,
    'p': 41,
    'q': 42,
    'r': 43,
    's': 44,
    't': 45,
    'u': 46,
    'v': 47,
    'w': 48,
    'x': 49,
    'y': 50,
    'z': 51,
    '0': 52,
    '1': 53,
    '2': 54,
    '3': 55,
    '4': 56,
    '5': 57,
    '6': 58,
    '7': 59,
    '8': 60,
    '9': 61,
    '+': 62,
    '/': 63
  };

  /**
   * Maps numeric values for the caps parameter of [setStrokeStyle] to
   * corresponding string values. This is primarily for use with the tiny API.
   * The mappings are as follows: 0 to "butt", 1 to "round", and 2 to "square".
   * For example, to set the line caps to "square":
   *
   *      myGraphics.ss(16, 2);
   */
  static const List<String> STROKE_CAPS_MAP = const <String>['butt', 'round',
      'square'];

  /**
   * Maps numeric values for the joints parameter of [setStrokeStyle] to
   * corresponding string values. This is primarily for use with the tiny API.
   * The mappings are as follows: 0 to "miter", 1 to "round", and 2 to "bevel".
   * For example, to set the line joints to "bevel":
   *
   *      myGraphics.ss(16, 0, 2);
   */
  static const List<String> STROKE_JOINTS_MAP = const <String>['miter', 'round',
      'bevel'];

  CanvasRenderingContext2D _ctx;

  static Command _beginCmd = new Command(#beginPath, []);

  // TODO: report a bug in dart2js when compiling with an empty list
  // "Uncaught TypeError: Failed to execute 'fill' on 'CanvasRenderingContext2D': parameter 1 ('undefined') is not a valid enum value."
  static Command _fillCmd = new Command(#fill, ['nonzero'], false);

  static Command _strokeCmd = new Command(#stroke, [], false);

  List<Command> _strokeInstructions;
  List<Command> _strokeStyleInstructions;
  bool _strokeIgnoreScale;
  List<Command> _fillInstructions;
  Matrix2D _fillMatrix;
  List<Command> _instructions;
  List<Command> _oldInstructions;
  List<Command> _activeInstructions;
  bool _active;
  bool _dirty;

  Graphics() {
    clear();
    _ctx = new CanvasElement(width: 1, height: 1).context2D;
  }

  /// Returns true if this Graphics instance has no drawing commands.
  bool get isEmpty => _instructions.length == 0 && _oldInstructions.length == 0
      && _activeInstructions.length == 0;

  /**
   * Draws the display object into the specified context ignoring its visible,
   * alpha, shadow, and transform. Returns true if the draw was handled (useful
   * for overriding functionality).
   *
   * NOTE: This method is mainly for internal use, though it may be useful for
   * advanced uses.
   */
  void draw(CanvasRenderingContext2D ctx) {
    if (_dirty) _updateInstructions();
    _instructions.forEach((Command instruction) => instruction(ctx));
  }

  /**
   * Draws only the path described for this Graphics instance, skipping any
   * non-path instructions, including fill and stroke descriptions. Used for
   * `DisplayObject.mask` to draw the clipping path, for example.
   */
  void drawAsPath(CanvasRenderingContext2D ctx) {
    if (_dirty) _updateInstructions();

    _instructions.forEach((Command instruction) {
      if (instruction._path) instruction(ctx);
    });
  }

  /**
   * Moves the drawing point to the specified position. A tiny API method "mt"
   * also exists.
   */
  Graphics moveTo(double x, double y) {
    _activeInstructions.add(new Command(#moveTo, [x, y]));
    return this;
  }

  /**
   * Draws a line from the current drawing point to the specified position,
   * which become the new current drawing point. A tiny API method "lt" also
   * exists.
   *
   * For detailed information, read the [whatwg spec](http://www.whatwg.org/
   * specs/web-apps/current-work/multipage/
   * the-canvas-element.html#building-paths).
   */
  Graphics lineTo(double x, double y) {
    _dirty = _active = true;
    _activeInstructions.add(new Command(#lineTo, [x, y]));
    return this;
  }

  /**
   * Draws an arc with the specified control points and radius. For detailed
   * information, read the [whatwg spec](http://www.whatwg.org/specs/web-apps/
   * current-work/multipage/the-canvas-element.html#dom-context-2d-arcto"). A
   * tiny API method "at" also exists.
   */
  Graphics arcTo(double x1, double y1, double x2, double y2, double radius) {
    _dirty = _active = true;
    _activeInstructions.add(new Command(#arcTo, [x1, y1, x2, y2, radius]));
    return this;
  }

  /**
   * Draws an arc defined by the radius, startAngle and endAngle arguments,
   * centered at the position (x, y). For example, to draw a full circle with a
   * radius of 20 centered at (100, 100):
   *
   *      arc(100, 100, 20, 0, Math.PI*2);
   *
   * For detailed information, read the [whatwg spec](http://www.whatwg.org/
   * specs/web-apps/current-work/multipage/
   * the-canvas-element.html#dom-context-2d-arc). A tiny API method "a" also
   * exists.
   */
  Graphics arc(double x, double y, double radius, double startAngle, double
      endAngle, [bool anticlockwise = false]) {
    _dirty = _active = true;
    _activeInstructions.add(new Command(#arc, [x, y, radius, startAngle,
        endAngle, anticlockwise]));
    return this;
  }

  /**
   * Draws a quadratic curve from the current drawing point to (x, y) using the
   * control point (cpx, cpy). For detailed information, read the [whatwg spec](
   * http://www.whatwg.org/specs/web-apps/current-work/multipage/
   * the-canvas-element.html#dom-context-2d-quadraticcurveto). A tiny API method
   * "qt" also exists.
   */
  Graphics quadraticCurveTo(double cpx, double cpy, double x, double y) {
    _dirty = _active = true;
    _activeInstructions.add(new Command(#quadraticCurveTo, [cpx, cpy, x, y]));
    return this;
  }

  /**
   * Draws a bezier curve from the current drawing point to (x, y) using the
   * control points (cp1x, cp1y) and (cp2x, cp2y). For detailed information,
   * read the [whatwg spec](http://www.whatwg.org/specs/web-apps/current-work/
   * multipage/the-canvas-element.html#dom-context-2d-beziercurveto). A tiny API
   * method "bt" also exists.
   */
  Graphics bezierCurveTo(double cp1x, double cp1y, double cp2x, double
      cp2y, double x, double y) {
    _dirty = _active = true;
    _activeInstructions.add(new Command(#bezierCurveTo, [cp1x, cp1y, cp2x, cp2y,
        x, y]));
    return this;
  }

  /**
   * Draws a rectangle at (x, y) with the specified width and height using the
   * current fill and/or stroke. For detailed information, read the
   * [whatwg spec](http://www.whatwg.org/specs/web-apps/current-work/multipage/
   * the-canvas-element.html#dom-context-2d-rect). A tiny API method "r" also
   * exists.
   */
  Graphics rect(double x, double y, int w, int h) {
    _dirty = _active = true;
    _activeInstructions.add(new Command(#rect, [x, y, w, h]));
    return this;
  }

  /**
   * Closes the current path, effectively drawing a line from the current
   * drawing point to the first drawing point specified since the fill or stroke
   * was last set. A tiny API method "cp" also exists.
   */
  Graphics closePath() {
    if (_active) {
      _dirty = true;
      _activeInstructions.add(new Command(#closePath, []));
    }

    return this;
  }

  /**
   * Clears all drawing instructions, effectively resetting this Graphics
   * instance. Any line and fill styles will need to be redefined to draw shapes
   * following a clear call. A tiny API method "c" also exists.
   */
  Graphics clear() {
    _instructions = new List<Command>();
    _oldInstructions = new List<Command>();
    _activeInstructions = new List<Command>();
    _strokeStyleInstructions = _strokeInstructions = _fillInstructions =
        _fillMatrix = null;
    _active = _dirty = _strokeIgnoreScale = false;

    return this;
  }

  /**
   * Begins a fill with the specified color. This ends the current sub-path. A
   * tiny API method "f" also exists.
   */
  Graphics beginFill(String color) {
    if (_active) _newPath();
    _fillInstructions = color != null ? <Command>[new Command(#fillStyle,
        [color], false)] : null;
    _fillMatrix = null;

    return this;
  }

  /**
   * Begins a linear gradient fill defined by the line (x0, y0) to (x1, y1).
   * This ends the current sub-path. For example, the following code defines a
   * black to white vertical gradient ranging from 20px to 120px, and draws a
   * square to display it:
   *
   *      myGraphics.beginLinearGradientFill(["#000","#FFF"], [0, 1], 0, 20, 0, 120).drawRect(20, 20, 120, 120);
   *
   * A tiny API method "lf" also exists.
   */
  Graphics beginLinearGradientFill(List<String> colors, List<double>
      ratios, double x0, double y0, double x1, double y1) {
    if (_active) _newPath();
    CanvasGradient gradient = _ctx.createLinearGradient(x0, y0, x1, y1);

    for (int i = 0; i < colors.length; i++) {
      gradient.addColorStop(ratios[i], colors[i]);
    }

    _fillInstructions = <Command>[new Command(#fillStyle, [gradient], false)];
    _fillMatrix = null;

    return this;
  }

  /**
   * Begins a radial gradient fill. This ends the current sub-path. For example,
   * the following code defines a red to blue radial gradient centered at (100,
   * 100), with a radius of 50, and draws a circle to display it:
   *
   *      myGraphics.beginRadialGradientFill(["#F00","#00F"], [0, 1], 100, 100, 0, 100, 100, 50).drawCircle(100, 100, 50);
   *
   * A tiny API method "rf" also exists.
   */
  Graphics beginRadialGradientFill(List<String> colors, List<double>
      ratios, double x0, double y0, double r0, double x1, double y1, double r1) {
    if (_active) _newPath();
    CanvasGradient gradient = _ctx.createRadialGradient(x0, y0, r0, x1, y1, r1);

    for (int i = 0; i < colors.length; i++) {
      gradient.addColorStop(ratios[i], colors[i]);
    }

    _fillInstructions = <Command>[new Command(#fillStyle, [gradient], false)];
    _fillMatrix = null;

    return this;
  }

  /**
   * Begins a pattern fill using the specified image. This ends the current
   * sub-path. A tiny API method "bf" also exists.
   */
  Graphics beginBitmapFill(CanvasImageSource image, [String repetition =
      '', Matrix2D matrix]) {
    CanvasPattern pattern;
    if (_active) _newPath();

    // TODO: VideoElement should also be supported
    if (image is ImageElement) {
      pattern = _ctx.createPatternFromImage(image, repetition);
    } else {
      pattern = _ctx.createPattern(image, repetition);
    }

    _fillInstructions = <Command>[new Command(#fillStyle, [pattern], false)];
    _fillMatrix = matrix;

    return this;
  }

  /**
   * Ends the current sub-path, and begins a new one with no fill. Functionally
   * identical to `beginFill(null)`.
   * A tiny API method "ef" also exists.
   */
  Graphics endFill() => beginFill(null);

  /**
   * Sets the stroke style for the current sub-path. Like all drawing methods,
   * this can be chained, so you can define the stroke style and color in a
   * single line of code like so:
   *
   *      myGraphics.setStrokeStyle(8,"round").beginStroke("#F00");
   *
   * A tiny API method "ss" also exists.
   */
  Graphics setStrokeStyle(int thickness, [int caps = 0, int joints = 0, int
      miterLimit = 10, bool ignoreScale = false]) {
    if (_active) _newPath();
    _strokeStyleInstructions = <Command>[new Command(#lineWidth, [thickness],
        false), new Command(#lineCap, [Graphics.STROKE_CAPS_MAP[caps]], false),
        new Command(#lineJoin, [Graphics.STROKE_JOINTS_MAP[joints]], false),
        new Command(#miterLimit, [miterLimit], false)];
    _strokeIgnoreScale = ignoreScale;

    return this;
  }

  /**
   * Begins a stroke with the specified color. This ends the current sub-path. A
   * tiny API method "s" also exists.
   */
  Graphics beginStroke(String color) {
    if (_active) _newPath();
    _strokeInstructions = color != null ? <Command>[new Command(#strokeStyle,
        [color], false)] : null;
    return this;
  }

  /**
   * Begins a linear gradient stroke defined by the line (x0, y0) to (x1, y1).
   * This ends the current sub-path. For example, the following code defines a
   * black to white vertical gradient ranging from 20px to 120px, and draws a
   * square to display it:
   *
   *      myGraphics.setStrokeStyle(10).
   *          beginLinearGradientStroke(["#000","#FFF"], [0, 1], 0, 20, 0, 120).drawRect(20, 20, 120, 120);
   *
   * A tiny API method "ls" also exists.
   */
  Graphics beginLinearGradientStroke(List<String> colors, List<double>
      ratios, double x0, double y0, double x1, double y1) {
    if (_active) _newPath();
    CanvasGradient gradient = _ctx.createLinearGradient(x0, y0, x1, y1);

    for (int i = 0; i < colors.length; i++) {
      gradient.addColorStop(ratios[i], colors[i]);
    }

    _strokeInstructions = <Command>[new Command(#strokeStyle, [gradient], false
        )];
    return this;
  }

  /**
   * Begins a radial gradient stroke. This ends the current sub-path. For
   * example, the following code defines a red to blue radial gradient centered
   * at (100, 100), with a radius of 50, and draws a rectangle to display it:
   *
   *      myGraphics.setStrokeStyle(10)
   *          .beginRadialGradientStroke(["#F00","#00F"], [0, 1], 100, 100, 0, 100, 100, 50)
   *          .drawRect(50, 90, 150, 110);
   *
   * A tiny API method "rs" also exists.
   */
  Graphics beginRadialGradientStroke(List<String> colors, List<double>
      ratios, double x0, double y0, double r0, double x1, double y1, double r1) {
    if (_active) _newPath();
    CanvasGradient gradient = _ctx.createRadialGradient(x0, y0, r0, x1, y1, r1);

    for (int i = 0; i < colors.length; i++) {
      gradient.addColorStop(ratios[i], colors[i]);
    }

    _strokeInstructions = <Command>[new Command(#strokeStyle, [gradient], false
        )];
    return this;
  }

  /**
   * Begins a pattern fill using the specified image. This ends the current
   * sub-path. Note that unlike bitmap fills, strokes do not currently support a
   * matrix parameter due to limitations in the canvas API. A tiny API method
   * "bs" also exists.
   */
  Graphics beginBitmapStroke(CanvasImageSource image, [String repetition = ''])
      {
    // NOTE: matrix is not supported for stroke because transforms on
    // strokes also affect the drawn stroke width.
    CanvasPattern pattern;
    if (_active) _newPath();

    // TODO: VideoElement should also be supported
    if (image is ImageElement) {
      pattern = _ctx.createPatternFromImage(image, repetition);
    } else {
      pattern = _ctx.createPattern(image, repetition);
    }

    _strokeInstructions = <Command>[new Command(#strokeStyle, [pattern], false
        )];

    return this;
  }

  /**
   * Ends the current sub-path, and begins a new one with no stroke.
   * Functionally identical to `beginStroke(null)`. A tiny API method "es" also
   * exists.
   */
  Graphics endStroke() {
    beginStroke(null);
    return this;
  }

  /**
   * Maps the familiar ActionScript `curveTo()` method to the functionally
   * similar [quadraticCurveTo] method.
   */
  Graphics curveTo(double cpx, double cpy, double x, double y) =>
      quadraticCurveTo(cpx, cpy, x, y);

  /**
   * Maps the familiar ActionScript `drawRect()` method to the functionally
   * similar [rect] method.
   */
  Graphics drawRect(double x, double y, int w, int h) => rect(x, y, w, h);

  /// Draws a rounded rectangle with all corners with the specified radius.
  Graphics drawRoundRect(double x, double y, int w, int h, double radius) {
    drawRoundRectComplex(x, y, w, h, radius, radius, radius, radius);
    return this;
  }

  /**
   * Draws a rounded rectangle with different corner radii. Supports positive
   * and negative corner radii. A tiny API method "rc" also exists.
   */
  Graphics drawRoundRectComplex(double x, double y, int w, int h, double
      radiusTL, double radiusTR, double radiusBR, double radiusBL) {
    double max = (w < h ? w : h) / 2;
    int mTL = 0,
        mTR = 0,
        mBR = 0,
        mBL = 0;

    if (radiusTL < 0) radiusTL *= (mTL = -1);
    if (radiusTL > max) radiusTL = max;
    if (radiusTR < 0) radiusTR *= (mTR = -1);
    if (radiusTR > max) radiusTR = max;
    if (radiusBR < 0) radiusBR *= (mBR = -1);
    if (radiusBR > max) radiusBR = max;
    if (radiusBL < 0) radiusBL *= (mBL = -1);
    if (radiusBL > max) radiusBL = max;

    _dirty = _active = true;

    _activeInstructions.addAll(<Command>[new Command(#moveTo, [x + w - radiusTR,
        y]), new Command(#arcTo, [x + w + radiusTR * mTR, y - radiusTR * mTR, x + w, y +
        radiusTR, radiusTR]), new Command(#lineTo, [x + w, y + h - radiusBR]),
        new Command(#arcTo, [x + w + radiusBR * mBR, y + h + radiusBR * mBR, x + w -
        radiusBR, y + h, radiusBR]), new Command(#lineTo, [x + radiusBL, y + h]),
        new Command(#arcTo, [x - radiusBL * mBL, y + h + radiusBL * mBL, x, y + h -
        radiusBL, radiusBL]), new Command(#lineTo, [x, y + radiusTL]), new Command(
        #arcTo, [x - radiusTL * mTL, y - radiusTL * mTL, x + radiusTL, y, radiusTL]),
        new Command(#closePath, [])]);

    return this;
  }

  /**
   * Draws a circle with the specified radius at (x, y).
   *
   *      var g = new createjs.Graphics();
   *          g.setStrokeStyle(1);
   *          g.beginStroke(createjs.Graphics.getRGB(0,0,0));
   *          g.beginFill(createjs.Graphics.getRGB(255,0,0));
   *          g.drawCircle(0,0,3);
   *
   *          var s = new createjs.Shape(g);
   *              s.x = 100;
   *              s.y = 100;
   *
   *          stage.addChild(s);
   *          stage.update();
   *
   * A tiny API method "dc" also exists.
   */
  Graphics drawCircle(double x, double y, double radius) {
    arc(x, y, radius, 0.0, PI * 2);
    return this;
  }

  /**
   * Draws an ellipse (oval) with a specified width (w) and height (h). Similar
   * to [drawCircle], except the width and height can be different. A tiny API
   * method "de" also exists.
   */
  Graphics drawEllipse(double x, double y, int w, int h) {
    _dirty = _active = true;

    double k = 0.5522848;
    double ox = (w / 2) * k;
    double oy = (h / 2) * k;
    double xe = x + w;
    double ye = y + h;
    double xm = x + w / 2;
    double ym = y + h / 2;

    _activeInstructions.addAll(<Command>[new Command(#moveTo, [x, ym]),
        new Command(#bezierCurveTo, [x, ym - oy, xm - ox, y, xm, y]), new Command(
        #bezierCurveTo, [xm + ox, y, xe, ym - oy, xe, ym]), new Command(#bezierCurveTo,
        [xe, ym + oy, xm + ox, ye, xm, ye]), new Command(#bezierCurveTo, [xm - ox, ye,
        x, ym + oy, x, ym])]);

    return this;
  }

  /**
   * Provides a method for injecting arbitrary Context2D (aka Canvas) API calls
   * into a Graphics queue. The specified callback function will be called in
   * sequence with other drawing instructions. The callback will be executed in
   * the scope of the target canvas's Context2D object, and will be passed the
   * data object as a parameter.
   *
   * This is an advanced feature. It can allow for powerful functionality, like
   * injecting output from tools that export Context2D instructions, executing
   * raw canvas calls within the context of the display list, or dynamically
   * modifying colors or stroke styles within a Graphics instance over time, but
   * it is not intended for general use.
   *
   * Within a Graphics queue, each path begins by applying the fill and stroke
   * styles and settings, followed by drawing instructions, followed by the
   * fill() and/or stroke() commands. This means that within a path, inject()
   * can update the fill & stroke styles, but for it to be applied in a
   * predictable manner, you must have begun a fill or stroke (as appropriate)
   * normally via the Graphics API. For example:
   *
   *      function setColor(color) {
   *              this.fillStyle = color;
   *      }
   *
   *      // this will not draw anything - no fill was begun, so fill() is not called:
   *      myGraphics.inject(setColor, "red").drawRect(0,0,100,100);
   *
   *      // this will draw the rect in green:
   *      myGraphics.beginFill("#000").inject(setColor, "green").drawRect(0,0,100,100);
   *
   *      // this will draw both rects in blue, because there is only a single path
   *      // so the second inject overwrites the first:
   *      myGraphics.beginFill("#000").inject(setColor, "green").drawRect(0,0,100,100)
   *              .inject(setColor, "blue").drawRect(100,0,100,100);
   *
   *      // this will draw the first rect in green, and the second in blue:
   *      myGraphics.beginFill("#000").inject(setColor, "green").drawRect(0,0,100,100)
   *              .beginFill("#000").inject(setColor, "blue").drawRect(100,0,100,100);
   */
  Graphics inject(Symbol callback, Object data) {
    _dirty = _active = true;
    _activeInstructions.add(new Command(callback, [data]));
    return this;
  }

  /**
   * Draws a star if pointSize is greater than 0, or a regular polygon if
   * pointSize is 0 with the specified number of points. For example, the
   * following code will draw a familiar 5 pointed star shape centered at 100,
   * 100 and with a radius of 50:
   *
   *      myGraphics.beginFill("#FF0").drawPolyStar(100, 100, 50, 5, 0.6, -90);
   *      // Note: -90 makes the first point vertical
   *
   * A tiny API method "dp" also exists.
   */
  Graphics drawPolyStar(double x, double y, double radius, int sides, [double
      pointSize = 0.0, double angle = 0.0]) {
    _dirty = _active = true;
    pointSize = 1.0 - pointSize;
    if (angle != 0.0) angle /= 180.0 / PI;
    double a = PI / sides;

    _activeInstructions.add(new Command(#moveTo, [x + cos(angle) * radius, y +
        sin(angle) * radius]));

    for (int i = 0; i < sides; i++) {
      angle += a;

      if (pointSize != 1.0) {
        _activeInstructions.add(new Command(#lineTo, [x + cos(angle) * radius *
            pointSize, y + sin(angle) * radius * pointSize]));
      }

      angle += a;
      _activeInstructions.add(new Command(#lineTo, [x + cos(angle) * radius, y +
          sin(angle) * radius]));
    }

    return this;
  }

  /**
   * Decodes a compact encoded path string into a series of draw instructions.
   * This format is not intended to be human readable, and is meant for use by
   * authoring tools.
   * The format uses a base64 character set, with each character representing 6
   * bits, to define a series of draw commands.
   *
   * Each command is comprised of a single "header" character followed by a
   * variable number of alternating x and y position values. Reading the header
   * bits from left to right (most to least significant): bits 1 to 3 specify
   * the type of operation (0-moveTo, 1-lineTo, 2-quadraticCurveTo,
   * 3-bezierCurveTo, 4-closePath, 5-7 unused). Bit 4 indicates whether position
   * values use 12 bits (2 characters) or 18 bits (3 characters), with a one
   * indicating the latter. Bits 5 and 6 are currently unused.
   *
   * Following the header is a series of 0 (closePath), 2 (moveTo, lineTo),
   * 4 (quadraticCurveTo), or 6 (bezierCurveTo) parameters. These parameters are
   * alternating x/y positions represented by 2 or 3 characters (as indicated by
   * the 4th bit in the command char). These characters consist of a 1 bit sign
   * (1 is negative, 0 is positive), followed by an 11 (2 char) or 17 (3 char)
   * bit integer value. All position values are in tenths of a pixel. Except in
   * the case of move operations which are absolute, this value is a delta from
   * the previous x or y position (as appropriate).
   *
   * For example, the string "A3cAAMAu4AAA" represents a line starting at -150,0
   * and ending at 150,0.
   * <br>A - bits 000000. First 3 bits (000) indicate a moveTo operation. 4th
   * bit (0) indicates 2 chars per parameter.
   * <br>n0 - 110111011100. Absolute x position of -150.0px. First bit indicates
   * a negative value, remaining bits indicate 1500 tenths of a pixel.
   * <br>AA - 000000000000. Absolute y position of 0.
   * <br>I - 001100. First 3 bits (001) indicate a lineTo operation. 4th bit (1)
   * indicates 3 chars per parameter.
   * <br>Au4 - 000000101110111000. An x delta of 300.0px, which is added to the
   * previous x value of -150.0px to provide an absolute position of +150.0px.
   * <br>AAA - 000000000000000000. A y delta value of 0.
   *
   * A tiny API method "p" also exists.
   */
  Graphics decodePath(String str) {
    InstanceMirror im = reflect(this);
    const List<Symbol> instructions = const <Symbol>[#moveTo, #lineTo,
        #quadraticCurveTo, #bezierCurveTo, #closePath];
    const List<int> paramCount = const <int>[2, 2, 4, 6, 0];
    int i = 0;
    List<double> args = new List<double>();
    double x = 0.0,
        y = 0.0;

    while (i < str.length) {
      String c = str[i];
      int n = Graphics.BASE_64[c];
      int fi = n >> 3; // highest order bits 1-3 code for operation.
      Symbol member;

      // check that we have a valid instruction
      try {
        member = instructions[fi];
      } on RangeError {
        throw new StateError('bad path data (@$i): $c');
      }

      // check that the unused bits are empty
      if ((n & 3) != 0) throw new StateError('bad path data (@$i): $c');

      if (fi == 0) x = y = 0.0; // move operations reset the position.
      args.length = 0;
      i++;

      // 4th header bit indicates number size for this operation.
      int charCount = (n >> 2 & 1) + 2;

      for (int p = 0; p < paramCount[fi]; p++) {
        int num = Graphics.BASE_64[str[i]];
        int sign = ((num >> 5) != 0) ? -1 : 1;
        num = ((num & 31) << 6) | (Graphics.BASE_64[str[i + 1]]);
        if (charCount == 3) num = (num << 6) | (Graphics.BASE_64[str[i + 2]]);
        double value = sign * num / 10;

        if ((p % 2) != 0) {
          x = (value += x);
        } else {
          y = (value += y);
        }

        args[p] = value;
        i += charCount;
      }

      im.invoke(member, args);
    }

    return this;
  }

  /**
   * Returns a clone of this Graphics instance.
   */
  Graphics clone() {
    Graphics graphics = new Graphics();
    graphics._instructions = _instructions.toList();
    graphics._activeInstructions = _activeInstructions.toList();
    graphics._oldInstructions = _oldInstructions.toList();
    graphics._fillInstructions = _fillInstructions;
    graphics._strokeInstructions = _strokeInstructions;

    if (_strokeStyleInstructions != null) {
      graphics._strokeStyleInstructions = _strokeStyleInstructions.toList();
    }

    graphics._active = _active;
    graphics._dirty = _dirty;
    graphics._fillMatrix = _fillMatrix;
    graphics._strokeIgnoreScale = _strokeIgnoreScale;

    return graphics;
  }

  /// Returns a string representation of this object.
  @override
  String toString() => '[${runtimeType}]';

  /// Shortcut to moveTo.
  Graphics mt(double x, double y) => moveTo(x, y);

  /// Shortcut to lineTo.
  Graphics lt(double x, double y) => lineTo(x, y);

  /// Shortcut to arcTo.
  Graphics at(double x1, double y1, double x2, double y2, double radius) {
    return arcTo(x1, y1, x2, y2, radius);
  }

  /// Shortcut to bezierCurveTo.
  Graphics bt(double cp1x, double cp1y, double cp2x, double cp2y, double
      x, double y) {
    return bezierCurveTo(cp1x, cp1y, cp2x, cp2y, x, y);
  }

  /// Shortcut to quadraticCurveTo / curveTo.
  Graphics qt(double cpx, double cpy, double x, double y) {
    return quadraticCurveTo(cpx, cpy, x, y);
  }

  /// Shortcut to arc.
  Graphics a(double x, double y, double radius, double startAngle, double
      endAngle, [bool anticlockwise = false]) {
    return arc(x, y, radius, startAngle, endAngle, anticlockwise);
  }

  /// Shortcut to rect.
  Graphics r(double x, double y, int w, int h) => rect(x, y, w, h);

  /// Shortcut to closePath.
  Graphics cp() => closePath();

  /// Shortcut to clear.
  Graphics c() => clear();

  /// Shortcut to beginFill.
  Graphics f(String color) => beginFill(color);

  /// Shortcut to beginLinearGradientFill.
  Graphics lf(List<String> colors, List<double> ratios, double x0, double
      y0, double x1, double y1) {
    return beginLinearGradientFill(colors, ratios, x0, y0, x1, y1);
  }

  /// Shortcut to beginRadialGradientFill.
  Graphics rf(List<String> colors, List<double> ratios, double x0, double
      y0, double r0, double x1, double y1, double r1) {
    return beginRadialGradientFill(colors, ratios, x0, y0, r0, x1, y1, r1);
  }

  /// Shortcut to beginBitmapFill.
  Graphics bf(CanvasImageSource image, [String repetition = '', Matrix2D
      matrix]) {
    return beginBitmapFill(image, repetition, matrix);
  }

  /// Shortcut to endFill.
  Graphics ef() => endFill();

  /// Shortcut to setStrokeStyle.
  Graphics ss(int thickness, [int caps = 0, int joints = 0, int miterLimit =
      10, bool ignoreScale = false]) {
    return setStrokeStyle(thickness, caps, joints, miterLimit, ignoreScale);
  }

  /// Shortcut to beginStroke.
  Graphics s(String color) => beginStroke(color);

  /// Shortcut to beginLinearGradientStroke.
  Graphics ls(List<String> colors, List<double> ratios, double x0, double
      y0, double x1, double y1) {
    return beginLinearGradientStroke(colors, ratios, x0, y0, x1, y1);
  }

  /// Shortcut to beginRadialGradientStroke.
  Graphics rs(List<String> colors, List<double> ratios, double x0, double
      y0, double r0, double x1, double y1, double r1) {
    return beginRadialGradientStroke(colors, ratios, x0, y0, r0, x1, y1, r1);
  }

  /// Shortcut to beginBitmapStroke.
  Graphics bs(CanvasImageSource image, [String repetition = '']) {
    return beginBitmapStroke(image, repetition);
  }

  /// Shortcut to endStroke.
  Graphics es() => endStroke();

  /// Shortcut to drawRect.
  Graphics dr(double x, double y, int w, int h) => drawRect(x, y, w, h);

  /// Shortcut to drawRoundRect.
  Graphics rr(double x, double y, int w, int h, double radius) {
    return drawRoundRect(x, y, w, h, radius);
  }

  /// Shortcut to drawRoundRectComplex.
  Graphics rc(double x, double y, int w, int h, double radiusTL, double
      radiusTR, double radiusBR, double radiusBL) {
    return drawRoundRectComplex(x, y, w, h, radiusTL, radiusTR, radiusBR,
        radiusBL);
  }

  /// Shortcut to drawCircle.
  Graphics dc(double x, double y, double radius) => drawCircle(x, y, radius);

  /// Shortcut to drawEllipse.
  Graphics de(double x, double y, int w, int h) => drawEllipse(x, y, w, h);

  /// Shortcut to drawPolyStar.
  Graphics dp(double x, double y, double radius, int sides, [double pointSize =
      0.0, double angle = 0.0]) {
    return drawPolyStar(x, y, radius, sides, pointSize, angle);
  }

  /// Shortcut to decodePath.
  Graphics p(String str) => decodePath(str);

  void _updateInstructions() {
    _instructions = _oldInstructions.toList();
    _instructions.add(Graphics._beginCmd);

    _appendInstructions(_fillInstructions);
    _appendInstructions(_strokeInstructions);

    if (_strokeInstructions != null && _strokeStyleInstructions != null) {
      _appendInstructions(_strokeStyleInstructions);
    }

    _appendInstructions(_activeInstructions);

    if (_fillInstructions != null) _appendDraw(Graphics._fillCmd, _fillMatrix);

    if (_strokeInstructions != null) {
      if (_strokeIgnoreScale) {
        _appendDraw(Graphics._strokeCmd, new Matrix2D());
      } else {
        _appendDraw(Graphics._strokeCmd, null);
      }
    }
  }

  void _appendInstructions(List<Command> instructions) {
    if (instructions != null) _instructions.addAll(instructions);
  }

  void _appendDraw(Command command, Matrix2D matrix) {
    if (matrix == null) {
      _instructions.add(command);
    } else {
      _instructions.addAll(<Command>[new Command(#save, [], false), new Command(
          #transform, matrix.asList(), false), command, new Command(#restore, [], false)]
          );
    }
  }

  void _newPath() {
    if (_dirty) _updateInstructions();
    _oldInstructions = _instructions;
    _activeInstructions = new List<Command>();
    _active = _dirty = false;
  }
}
