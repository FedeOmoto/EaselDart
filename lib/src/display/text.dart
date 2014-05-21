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
 * Display one or more lines of dynamic text (not user editable) in the display
 * list. Line wrapping support (using the lineWidth) is very basic, wrapping on
 * spaces and tabs only. Note that as an alternative to Text, you can position
 * HTML text above or below the canvas relative to items in the display list
 * using the [DisplayObject.localToGlobal] method, or using [DOMElement].
 *
 * **Please note that Text does not support HTML text, and can only display one
 * font style at a time.** To use multiple font styles, you will need to create
 * multiple text instances, and position them manually.
 *
 * ##Example
 *      var text = new createjs.Text("Hello World", "20px Arial", "#ff7700");
 *      text.x = 100;
 *      text.textBaseline = "alphabetic";
 *
 * CreateJS Text supports web fonts (the same rules as Canvas). The font must be
 * loaded and supported by the browser before it can be displayed.
 *
 * **Note:** Text can be expensive to generate, so cache instances where
 * possible. Be aware that not all browsers will render Text exactly the same.
 */
class Text extends DisplayObject {
  static CanvasRenderingContext2D _workingContext = new CanvasElement(width: 1,
      height: 1).context2D;

  /**
   * Lookup table for the ratio to offset bounds x calculations based on the
   * textAlign property.
   */
  static const Map<String, double> H_OFFSETS = const <String, double> {
    'start': 0.0,
    'left': 0.0,
    'center': -0.5,
    'end': -1.0,
    'right': -1.0
  };

  /**
   * Lookup table for the ratio to offset bounds y calculations based on the
   * textBaseline property.
   */
  static const Map<String, double> V_OFFSETS = const <String, double> {
    'top': 0.0,
    'hanging': -0.01,
    'middle': -0.4,
    'alphabetic': -0.8,
    'ideographic': -0.85,
    'bottom': -1.0
  };

  /// The text to display.
  String text = '';

  /**
   * The font style to use. Any valid value for the CSS font attribute is
   * acceptable (ex. "bold 36px Arial").
   */
  String font;

  /**
   * The color to draw the text in. Any valid value for the CSS color attribute
   * is acceptable (ex. "#F00"). Default is "#000".
   * It will also accept valid canvas fillStyle values.
   */
  String color;

  /**
   * The horizontal text alignment. Any of "start", "end", "left", "right", and
   * "center". For detailed information view the [whatwg spec](http://
   * www.whatwg.org/specs/web-apps/current-work/multipage/
   * the-canvas-element.html#text-styles). Default is "left".
   */
  String textAlign = 'left';

  /**
   * The vertical alignment point on the font. Any of "top", "hanging",
   * "middle", "alphabetic", "ideographic", or "bottom". For detailed
   * information view the [whatwg spec](http://www.whatwg.org/specs/web-apps/
   * current-work/multipage/the-canvas-element.html#text-styles). Default is
   * "top".
   */
  String textBaseline = 'top';

  /**
   * The maximum width to draw the text. If maxWidth is specified (not null),
   * the text will be condensed orvshrunk to make it fit in this width. For
   * detailed information view the [whatwg spec](http://www.whatwg.org/specs/
   * web-apps/current-work/multipage/the-canvas-element.html#text-styles).
   */
  double maxWidth;

  /**
   * If greater than 0, the text will be drawn as a stroke (outline) of the
   * specified width.
   */
  double outline = 0.0;

  /**
   * Indicates the line height (vertical distance between baselines) for
   * multi-line text. If null or 0, the value of getMeasuredLineHeight is used.
   */
  double lineHeight = 0.0;

  /**
   * Indicates the maximum width for a line of text before it is wrapped to
   * multiple lines. If null, the text will not be wrapped.
   */
  double lineWidth;

  Text(this.text, this.font, this.color);

  /**
   * Returns true or false indicating whether the display object would be
   * visible if drawn to a canvas. This does not account for whether it would be
   * visible within the boundaries of the stage.
   * NOTE: This method is mainly for internal use, though it may be useful for
   * advanced uses.
   */
  bool get isVisible {
    bool hasContent = _cacheCanvas != null || (text != null && text != '');
    return !!(visible && alpha > 0 && scaleX != 0 && scaleY != 0 && hasContent);
  }

  /**
   * Draws the Text into the specified context ignoring its visible, alpha,
   * shadow, and transform. Returns true if the draw was handled (useful for
   * overriding functionality).
   * NOTE: This method is mainly for internal use, though it may be useful for
   * advanced uses.
   */
  @override
  bool draw(CanvasRenderingContext2D ctx, [bool ignoreCache = false]) {
    if (super.draw(ctx, ignoreCache)) return true;
    String color;

    if (this.color == null) {
      color = '#000';
    } else {
      color = this.color;
    }

    if (outline > 0) {
      ctx.strokeStyle = color;
      ctx.lineWidth = outline * 1;
    } else {
      ctx.fillStyle = color;
    }

    _drawText(_prepContext(ctx));
    return true;
  }

  /**
   * Returns the measured, untransformed width of the text without wrapping. Use
   * getBounds for a more robust value.
   */
  double get getMeasuredWidth {
    return _prepContext(Text._workingContext).measureText(text).width;
  }

  /**
   * Returns an approximate line height of the text, ignoring the lineHeight
   * property. This is based on the measured width of a "M" character multiplied
   * by 1.2, which provides an approximate line height for most fonts.
   */
  double get getMeasuredLineHeight {
    return _prepContext(Text._workingContext).measureText('M').width * 1.2;
  }

  /**
   * Returns the approximate height of multi-line text by multiplying the number
   * of lines against either the `lineHeight` (if specified) or
   * [getMeasuredLineHeight]. Note that this operation requires the text flowing
   * logic to run, which has an associated CPU cost.
   */
  double get getMeasuredHeight {
    return _drawText(null, new Map<String, double>())['height'];
  }

  /// Docced in superclass.
  Rectangle<double> get getBounds {
    Rectangle<double> rect = super.getBounds;
    if (rect != null) return rect;
    if (text == null || text == '') return null;
    Map<String, double> object = _drawText(null, new Map<String, double>());
    double width = (maxWidth != null && maxWidth < object['width']) ? maxWidth :
        object['width'];
    double x = width * Text.H_OFFSETS[textAlign == null ? 'left' : textAlign];
    double lineHeight = this.lineHeight == 0 ? getMeasuredLineHeight :
        this.lineHeight;
    double y = lineHeight * Text.V_OFFSETS[textBaseline == null ? 'top' :
        textBaseline];

    return _rectangle = new Rectangle<double>(x, y, width, object['height']);
  }

  /// Returns a clone of the Text instance.
  @override
  Text clone([bool recursive = false]) {
    Text text = new Text(this.text, font, color);
    _cloneProps(text);
    return text;
  }

  /// Returns a string representation of this object.
  @override
  String toString() {
    return
        '[Text (text=${(text.length > 20 ? text.substring(0, 17) + '...' : text)})]';
  }

  @override
  void _cloneProps(Text text) {
    super._cloneProps(text);
    text.textAlign = textAlign;
    text.textBaseline = textBaseline;
    text.maxWidth = maxWidth;
    text.outline = outline;
    text.lineHeight = lineHeight;
    text.lineWidth = lineWidth;
  }

  CanvasRenderingContext2D _prepContext(CanvasRenderingContext2D ctx) {
    ctx.font = font;
    ctx.textAlign = textAlign == null ? 'left' : textAlign;
    ctx.textBaseline = textBaseline == null ? 'top' : textBaseline;

    return ctx;
  }

  Map<String, double> _drawText(CanvasRenderingContext2D ctx, [Map<String,
      double> object]) {
    bool paint = !(ctx == null);
    if (!paint) ctx = _prepContext(Text._workingContext);
    double lineHeight = this.lineHeight == 0 ? getMeasuredLineHeight :
        this.lineHeight;
    double maxWidth = 0.0,
        count = 0.0;
    List<String> lines = text.split(new RegExp(r'(?:\r\n|\r|\n)'));

    lines.forEach((String line) {
      double width;

      if (lineWidth != null && (width = ctx.measureText(line).width) >
          lineWidth) {
        // text wrapping:
        List<String> words = line.split(new RegExp(r'(\s)'));
        line = words.first;
        width = ctx.measureText(line).width;

        for (int i = 1; i < words.length; i += 2) {
          // Line needs to wrap:
          double wordWidth = ctx.measureText(words[i] + words[i + 1]).width;
          if (width + wordWidth > lineWidth) {
            if (paint) _drawTextLine(ctx, line, count * lineHeight);
            if (width > maxWidth) maxWidth = width;
            line = words[i + 1];
            width = ctx.measureText(line).width;
            count++;
          } else {
            line += words[i] + words[i + 1];
            width += wordWidth;
          }
        }
      }

      if (paint) _drawTextLine(ctx, line, count * lineHeight);
      if (object != null && width == null) width = ctx.measureText(line).width;
      if (width != null && width > maxWidth) maxWidth = width;
      count++;
    });

    if (object != null) {
      object['count'] = count;
      object['width'] = maxWidth;
      object['height'] = count * lineHeight;
    }

    return object;
  }

  void _drawTextLine(CanvasRenderingContext2D ctx, String text, double y) {
    if (outline > 0) {
      ctx.strokeText(text, 0.0, y, maxWidth);
    } else {
      ctx.fillText(text, 0, y, maxWidth);
    }
  }
}
