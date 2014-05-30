import 'dart:html';
import 'package:easel_dart/easel_dart.dart' as easel;

DivElement canvasHolder;
ImageElement img;
List<Demo> demos;
const String STROKE_COLOR = 'rgba(255,255,255,1)';
const String FILL_COLOR = 'rgba(255,255,255,1)';

typedef easel.DisplayObject DemoCode(easel.Stage stage);

class Demo {
  final String label;
  final String sourceCode;
  final DemoCode code;
  easel.Stage _stage;

  Demo(this.label, this.sourceCode, this.code);

  void draw(CanvasElement canvas) {
    _stage = new easel.Stage(canvas);
    _stage.addChild(code(_stage));
    _stage.update();
  }
}

void layout(Event event) {
  demos.forEach((Demo demo) {
    CanvasElement canvas = new CanvasElement(width: 150, height: 150);
    TableElement table = new Element.html('<table width="100%"><tbody><tr><td '
        'width="50" valign="top"></td><td valign="top"></td></tr></tbody></table>');
    HeadingElement h2 = new HeadingElement.h2()..text = demo.label;
    DivElement sourceCode = new Element.html(
        '<div><pre><code>${demo.sourceCode}' '</code></pre></div>')..style.width =
        '750px';

    ElementList<Element> list = table.querySelectorAll('td');
    list[0].append(canvas);
    list[1].append(sourceCode);

    canvasHolder
        ..append(h2)
        ..append(table);
    demo.draw(canvas);
  });
}

Demo lineDemo() {
  String sourceCode =
      '''// lineTo();
new easel.Graphics()
    ..beginStroke('rgba(255,255,255,1)')
    ..moveTo(5.0, 35.0)
    ..lineTo(110.0, 75.0)
    ..endStroke();''';

  DemoCode code = (easel.Stage stage) {
    return new easel.Shape(new easel.Graphics()
        ..beginStroke(STROKE_COLOR)
        ..moveTo(5.0, 35.0)
        ..lineTo(110.0, 75.0)
        ..endStroke());
  };

  return new Demo('lineTo();', sourceCode, code);
}

Demo arcDemo() {
  String sourceCode =
      '''// arcTo();
new easel.Graphics()
    ..beginStroke('rgba(255,255,255,1)')
    ..moveTo(50.0, 20.0)
    ..arcTo(150.0, 20.0, 150.0, 70.0, 50.0)
    ..endStroke();''';

  DemoCode code = (easel.Stage stage) {
    return new easel.Shape(new easel.Graphics()
        ..beginStroke(STROKE_COLOR)
        ..moveTo(50.0, 20.0)
        ..arcTo(150.0, 20.0, 150.0, 70.0, 50.0)
        ..endStroke());
  };

  return new Demo('arcTo();', sourceCode, code);
}

Demo quadraticCurveDemo() {
  String sourceCode =
      '''// quadraticCurveTo();
new easel.Graphics()
    ..beginStroke('rgba(255,255,255,1)')
    ..moveTo(0.0, 25.0)
    ..quadraticCurveTo(45.0, 50.0, 35.0, 25.0)
    ..endStroke();''';

  DemoCode code = (easel.Stage stage) {
    return new easel.Shape(new easel.Graphics()
        ..beginStroke(STROKE_COLOR)
        ..moveTo(0.0, 25.0)
        ..quadraticCurveTo(45.0, 50.0, 35.0, 25.0)
        ..endStroke());
  };

  return new Demo('quadraticCurveTo();', sourceCode, code);
}

Demo bezierCurveDemo() {
  String sourceCode =
      '''// bezierCurveTo();
new easel.Graphics()
    ..beginStroke('rgba(255,255,255,1)')
    ..moveTo(5.0, 75.0)
    ..bezierCurveTo(4.05, 90.0, 75.0, 75.0, -25.0, -25.0)
    ..endStroke();''';

  DemoCode code = (easel.Stage stage) {
    return new easel.Shape(new easel.Graphics()
        ..beginStroke(STROKE_COLOR)
        ..moveTo(5.0, 75.0)
        ..bezierCurveTo(45.0, 90.0, 75.0, 75.0, -25.0, -25.0)
        ..endStroke());
  };

  return new Demo('bezierCurveTo();', sourceCode, code);
}

Demo linearGradientStrokeDemo() {
  String sourceCode =
      '''// beginLinearGradientStroke();
new easel.Graphics()
    ..beginLinearGradientStroke(&lt;String&gt;['rgba(255,255,255,1)',
        'rgba(50, 50, 50, 1)'], &lt;double&gt;[0.0, 0.4], 0.0, 0.0, 70.0, 140.0)
    ..moveTo(5.0, 25.0)
    ..lineTo(110.0, 25.0)
    ..endStroke();''';

  DemoCode code = (easel.Stage stage) {
    return new easel.Shape(new easel.Graphics()
        ..beginLinearGradientStroke(<String>[STROKE_COLOR,
            'rgba(50, 50, 50, 1)'], <double>[0.0, 0.4], 0.0, 0.0, 70.0, 140.0)
        ..moveTo(5.0, 25.0)
        ..lineTo(110.0, 25.0)
        ..endStroke());
  };

  return new Demo('beginLinearGradientStroke();', sourceCode, code);
}

Demo rectDemo() {
  String sourceCode =
      '''// drawRect();
new easel.Graphics()
    ..beginFill('rgba(255,255,255,1)')
    ..rect(5.0, 5.0, 80, 80);''';

  DemoCode code = (easel.Stage stage) {
    return new easel.Shape(new easel.Graphics()
        ..beginFill(FILL_COLOR)
        ..rect(5.0, 5.0, 80, 80));
  };

  return new Demo('drawRect();', sourceCode, code);
}

Demo roundRectDemo() {
  String sourceCode =
      '''// drawRoundRect();
new easel.Graphics()
    ..beginFill('rgba(255,255,255,1)')
    ..drawRoundRect(0.0, 0.0, 120, 120, 5.0);''';

  DemoCode code = (easel.Stage stage) {
    return new easel.Shape(new easel.Graphics()
        ..beginFill(FILL_COLOR)
        ..drawRoundRect(0.0, 0.0, 120, 120, 5.0));
  };

  return new Demo('drawRoundRect();', sourceCode, code);
}

Demo linearGradientFillWithRoundRectDemo() {
  String sourceCode =
      '''// beginLinearGradientFill() with drawRoundRect();
new easel.Graphics()
    ..beginLinearGradientFill(&lt;String&gt;['rgba(255,255,255,1)', 'rgba(0,0,0,1)'],
        &lt;double&gt;[0.0, 1.0], 0.0, 0.0, 0.0, 130.0)
    ..drawRoundRect(0.0, 0.0, 120, 120, 5.0);''';

  DemoCode code = (easel.Stage stage) {
    return new easel.Shape(new easel.Graphics()
        ..beginLinearGradientFill(<String>[FILL_COLOR, 'rgba(0,0,0,1)'],
            <double>[0.0, 1.0], 0.0, 0.0, 0.0, 130.0)
        ..drawRoundRect(0.0, 0.0, 120, 120, 5.0));
  };

  return new Demo('beginLinearGradientFill() with drawRoundRect();', sourceCode,
      code);
}

Demo circleDemo() {
  String sourceCode =
      '''// drawCircle();
new easel.Graphics()
    ..beginFill('rgba(255,255,255,1)')
    ..drawCircle(40.0, 40.0, 40.0);''';

  DemoCode code = (easel.Stage stage) {
    return new easel.Shape(new easel.Graphics()
        ..beginFill(FILL_COLOR)
        ..drawCircle(40.0, 40.0, 40.0));
  };

  return new Demo('drawCircle();', sourceCode, code);
}

Demo radialGradientFillWithCircleDemo() {
  String sourceCode =
      '''// beginRadialGradientFill() with drawCircle();
new easel.Graphics()
    ..beginRadialGradientFill(&lt;String&gt;['rgba(255,255,255,1)', 'rgba(0,0,0,1)'],
        &lt;double&gt;[0.0, 1.0], 0.0, 0.0, 0.0, 0.0, 0.0, 60.0)
    ..drawCircle(40.0, 40.0, 40.0);''';

  DemoCode code = (easel.Stage stage) {
    return new easel.Shape(new easel.Graphics()
        ..beginRadialGradientFill(<String>[FILL_COLOR, 'rgba(0,0,0,1)'],
            <double>[0.0, 1.0], 0.0, 0.0, 0.0, 0.0, 0.0, 60.0)
        ..drawCircle(40.0, 40.0, 40.0));
  };

  return new Demo('beginRadialGradientFill() with drawCircle();', sourceCode,
      code);
}

Demo ellipseDemo() {
  String sourceCode =
      '''// drawEllipse();
new easel.Graphics()
    ..beginFill('rgba(255,255,255,1)')
    ..drawEllipse(5.0, 5.0, 60, 120);''';

  DemoCode code = (easel.Stage stage) {
    return new easel.Shape(new easel.Graphics()
        ..beginFill(FILL_COLOR)
        ..drawEllipse(5.0, 5.0, 60, 120));
  };

  return new Demo('drawEllipse();', sourceCode, code);
}

Demo hexagonDemo() {
  String sourceCode =
      '''// Draw Hexagon using drawPolyStar();
new easel.Graphics()
    ..beginFill('rgba(255,255,255,1)')
    ..drawPolyStar(60.0, 60.0, 60.0, 6, 0.0, 45.0);''';

  DemoCode code = (easel.Stage stage) {
    return new easel.Shape(new easel.Graphics()
        ..beginFill(FILL_COLOR)
        ..drawPolyStar(60.0, 60.0, 60.0, 6, 0.0, 45.0));
  };

  return new Demo('Draw Hexagon using drawPolyStar();', sourceCode, code);
}

Demo starDemo() {
  String sourceCode =
      '''// Draw a star using drawPolyStar();
new easel.Graphics()
    ..beginFill('rgba(255,255,255,1)')
    ..drawPolyStar(80.0, 80.0, 70.0, 5, 0.6, -90.0);''';

  DemoCode code = (easel.Stage stage) {
    return new easel.Shape(new easel.Graphics()
        ..beginFill(FILL_COLOR)
        ..drawPolyStar(80.0, 80.0, 70.0, 5, 0.6, -90.0));
  };

  return new Demo('Draw a star using drawPolyStar();', sourceCode, code);
}

Demo bitmapStrokeWithRectDemo() {
  String sourceCode =
      '''// beginBitmapStroke() with drawRect();
new easel.Graphics()
    ..setStrokeStyle(25)
    ..beginBitmapStroke(img)
    ..rect(5.0, 5.0, 100, 100);''';

  DemoCode code = (easel.Stage stage) {
    return new easel.Shape(new easel.Graphics()
        ..setStrokeStyle(25)
        ..beginBitmapStroke(img)
        ..rect(5.0, 5.0, 100, 100));
  };

  return new Demo('beginBitmapStroke() with drawRect();', sourceCode, code);
}

Demo roundRectComplexDemo() {
  String sourceCode =
      '''// drawRoundRectComplex();
new easel.Graphics()
    ..beginFill('rgba(255,255,255,1)')
    ..drawRoundRectComplex(5.0, 5.0, 70, 70, 5.0, 10.0, 15.0, 25.0);''';

  DemoCode code = (easel.Stage stage) {
    return new easel.Shape(new easel.Graphics()
        ..beginFill(FILL_COLOR)
        ..drawRoundRectComplex(5.0, 5.0, 70, 70, 5.0, 10.0, 15.0, 25.0));
  };

  return new Demo('drawRoundRectComplex();', sourceCode, code);
}

Demo circleWithBitmapFillDemo() {
  String sourceCode =
      '''// drawCircle(); with beginBitmapFill();
new easel.Graphics()
    ..beginStroke('rgba(255,255,255,1)')
    ..beginBitmapFill(img)
    ..drawCircle(30.0, 30.0, 30.0)
    ..endStroke();''';

  DemoCode code = (easel.Stage stage) {
    return new easel.Shape(new easel.Graphics()
        ..beginStroke(STROKE_COLOR)
        ..beginBitmapFill(img)
        ..drawCircle(30.0, 30.0, 30.0)
        ..endStroke());
  };

  return new Demo('drawCircle(); with beginBitmapFill();', sourceCode, code);
}

Demo textDemo() {
  String sourceCode =
      '''// Text
easel.Text text = new easel.Text('Hello CreateDart!', '15px Arial', '#FFF');
text.y = 45.0;
stage.addChild(text);''';

  DemoCode code = (easel.Stage stage) {
    easel.Text text = new easel.Text('Hello CreateDart!', '15px Arial', '#FFF');
    text.y = 45.0;
    return text;
  };

  return new Demo('Text', sourceCode, code);
}

Demo spriteDemo() {
  String sourceCode =
      '''// Sprite
ImageElement image = new ImageElement(src: 'assets/images/runningGrant.png');

easel.SpriteSheetData ssd = new easel.SpriteSheetData();
ssd.animations = &lt;String, Object&gt; {
  'run': [0, 25],
  'jump': [26, 63]
};
ssd.images = &lt;CanvasImageSource&gt;[image];
ssd.frames = &lt;String, num&gt; {
  'regX': 0.0,
  'regY': 0.0,
  'height': 292.5,
  'width': 165.75,
  'count': 64
};

easel.SpriteSheet ss = new easel.SpriteSheet(ssd);

ss.getAnimation('run')['speed'] = 2;
ss.getAnimation('run')['next'] = 'jump';
ss.getAnimation('jump')['next'] = 'run';

var sprite = new easel.Sprite(ss, 'run');
sprite.scaleY = sprite.scaleX = 0.4;

easel.Ticker ticker = easel.Ticker.current;
ticker.setFPS = 60.0;
ticker.addEventListener('tick', stage.handleEvent);

stage.addChild(sprite);''';

  DemoCode code = (easel.Stage stage) {
    ImageElement image = new ImageElement(src: 'assets/images/runningGrant.png'
        );

    easel.SpriteSheetData ssd = new easel.SpriteSheetData();
    ssd.animations = <String, Object> {
      'run': [0, 25],
      'jump': [26, 63]
    };
    ssd.images = <CanvasImageSource>[image];
    ssd.frames = <String, num> {
      'regX': 0.0,
      'regY': 0.0,
      'height': 292.5,
      'width': 165.75,
      'count': 64
    };

    easel.SpriteSheet ss = new easel.SpriteSheet(ssd);

    ss.getAnimation('run')['speed'] = 2;
    ss.getAnimation('run')['next'] = 'jump';
    ss.getAnimation('jump')['next'] = 'run';

    var sprite = new easel.Sprite(ss, 'run');
    sprite.scaleY = sprite.scaleX = 0.4;

    easel.Ticker ticker = easel.Ticker.current;
    ticker.setFPS = 60.0;
    ticker.addEventListener('tick', stage.handleEvent);

    return sprite;
  };

  return new Demo('Sprite', sourceCode, code);
}

Demo blurFilterDemo() {
  String sourceCode =
      '''// Blur Filter
easel.BlurFilter blurFilter = new easel.BlurFilter(5.0, 2.0, 2);
Rectangle&lt;double&gt; margins = blurFilter.getBounds;
easel.Bitmap image = new easel.Bitmap(img);
image.filters = &lt;easel.Filter&gt;[blurFilter];
// filters are only displayed when the display object is cached
// later, you can call updateCache() to update changes to your filters
image.cache(margins.left, margins.top, img.width + margins.width.toInt(),
    img.height + margins.height.toInt());
stage.addChild(image);''';

  DemoCode code = (easel.Stage stage) {
    easel.BlurFilter blurFilter = new easel.BlurFilter(5.0, 2.0, 2);
    Rectangle<double> margins = blurFilter.getBounds;
    easel.Bitmap image = new easel.Bitmap(img);
    image.filters = <easel.Filter>[blurFilter];
    // filters are only displayed when the display object is cached
    // later, you can call updateCache() to update changes to your filters
    image.cache(margins.left, margins.top, img.width + margins.width.toInt(),
        img.height + margins.height.toInt());

    return image;
  };

  return new Demo('Blur Filter', sourceCode, code);
}

Demo colorFilterDemo() {
  String sourceCode =
      '''// Remove Red Color Filter
easel.ColorFilter removeRedFilter = new easel.ColorFilter(redMultiplier: 0.0);
easel.Bitmap image = new easel.Bitmap(img);
image.filters = &lt;easel.Filter&gt;[removeRedFilter];
image.cache(0.0, 0.0, img.width, img.height);
stage.addChild(image);''';

  DemoCode code = (easel.Stage stage) {
    easel.ColorFilter removeRedFilter = new easel.ColorFilter(redMultiplier: 0.0
        );
    easel.Bitmap image = new easel.Bitmap(img);
    image.filters = <easel.Filter>[removeRedFilter];
    image.cache(0.0, 0.0, img.width, img.height);

    return image;
  };

  return new Demo('Remove Red Color Filter', sourceCode, code);
}

Demo colorMatrixFilterDemo() {
  String sourceCode =
      '''// ColorMatrixFilter
easel.ColorMatrix matrix = new easel.ColorMatrix();
matrix.values = &lt;double&gt;[0.33, 0.33, 0.33, 0.0, 0.0, // red
  0.33, 0.33, 0.33, 0.0, 0.0, // green
  0.33, 0.33, 0.33, 0.0, 0.0, // blue
  0.0, 0.0, 0.0, 1.0, 0.0, // alpha
  0.0, 0.0, 0.0, 0.0, 1.0];
easel.ColorMatrixFilter greyScaleFilter = new easel.ColorMatrixFilter(matrix);

easel.Bitmap image = new easel.Bitmap(img);
image.filters = &lt;easel.Filter&gt;[greyScaleFilter];
image.cache(0.0, 0.0, img.width, img.height);
stage.addChild(image);''';

  DemoCode code = (easel.Stage stage) {
    easel.ColorMatrix matrix = new easel.ColorMatrix();
    matrix.values = <double>[0.33, 0.33, 0.33, 0.0, 0.0, // red
      0.33, 0.33, 0.33, 0.0, 0.0, // green
      0.33, 0.33, 0.33, 0.0, 0.0, // blue
      0.0, 0.0, 0.0, 1.0, 0.0, // alpha
      0.0, 0.0, 0.0, 0.0, 1.0];
    easel.ColorMatrixFilter greyScaleFilter = new easel.ColorMatrixFilter(matrix
        );

    easel.Bitmap image = new easel.Bitmap(img);
    image.filters = <easel.Filter>[greyScaleFilter];
    image.cache(0.0, 0.0, img.width, img.height);

    return image;
  };

  return new Demo('ColorMatrixFilter', sourceCode, code);
}

Demo mouseDemo() {
  String sourceCode =
      '''// Mouse Interaction
// Click one of the shapes.
easel.Shape sprite = new easel.Shape();
sprite.graphics
    ..beginFill(FILL_COLOR)
    ..drawCircle(30.0, 30.0, 20.0)
    ..moveTo(50.0, 50.0)
    ..drawRect(50.0, 50.0, 25, 25);
sprite.addEventListener('click', (easel.Event event, [dynamic data]) {
  window.alert('Click!');
});

stage.addChild(sprite);''';

  DemoCode code = (easel.Stage stage) {
    easel.Shape sprite = new easel.Shape();
    sprite.graphics
        ..beginFill(FILL_COLOR)
        ..drawCircle(30.0, 30.0, 20.0)
        ..moveTo(50.0, 50.0)
        ..drawRect(50.0, 50.0, 25, 25);
    sprite.addEventListener('click', (easel.Event event, [dynamic data]) {
      window.alert('Click!');
    });

    return sprite;
  };

  return new Demo('Mouse Interaction', sourceCode, code);
}

Demo maskDemo() {
  String sourceCode =
      '''// Mask
easel.Shape shape = new easel.Shape();
shape.graphics = new easel.Graphics()
    ..beginStroke(STROKE_COLOR)
    ..beginBitmapFill(img)
    ..drawCircle(35.0, 25.0, 20.0)
    ..endStroke();
easel.Bitmap image = new easel.Bitmap(img);
image.mask = shape;

stage.addChild(image);''';

  DemoCode code = (easel.Stage stage) {
    easel.Shape shape = new easel.Shape();
    shape.graphics = new easel.Graphics()
        ..beginStroke(STROKE_COLOR)
        ..beginBitmapFill(img)
        ..drawCircle(35.0, 25.0, 20.0)
        ..endStroke();
    easel.Bitmap image = new easel.Bitmap(img);
    image.mask = shape;

    return image;
  };

  return new Demo('Mask', sourceCode, code);
}

void main() {
  if (window.top != window) querySelector('#header').style.display = 'none';

  img = new ImageElement();
  img.onLoad.listen(layout);
  img.src = 'assets/images/daisy.png';

  canvasHolder = querySelector('.canvasHolder');

  demos = <Demo>[lineDemo(), arcDemo(), quadraticCurveDemo(), bezierCurveDemo(),
      linearGradientStrokeDemo(), rectDemo(), roundRectDemo(),
      linearGradientFillWithRoundRectDemo(), circleDemo(),
      radialGradientFillWithCircleDemo(), ellipseDemo(), hexagonDemo(), starDemo(),
      bitmapStrokeWithRectDemo(), roundRectComplexDemo(), circleWithBitmapFillDemo(),
      textDemo(), spriteDemo(), blurFilterDemo(), colorFilterDemo(),
      colorMatrixFilterDemo(), mouseDemo(), maskDemo()];
}
