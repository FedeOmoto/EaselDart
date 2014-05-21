import 'dart:html';
import 'package:easel_dart/easel_dart.dart' hide Text;
import 'package:easel_dart/easel_dart.dart' as easel show Text;

DivElement canvasHolder;
ImageElement img;
List<Demo> demos;
const String STROKE_COLOR = 'rgba(255,255,255,1)';
const String FILL_COLOR = 'rgba(255,255,255,1)';

typedef DisplayObject DemoCode();

class Demo {
  String label;
  String sourceCode;
  DemoCode code;

  Demo(this.label, this.sourceCode, this.code);

  void draw(CanvasElement canvas) {
    Stage stage = new Stage(canvas);
    stage.addChild(code());
    stage.update();
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

Demo textDemo() {
  String sourceCode =
      '''// Text
Text text = new Text('Hello CreateDart!', '15px Arial', '#FFF');
text.y = 45.0;
stage.addChild(text);''';

  DemoCode code = () {
    easel.Text text = new easel.Text('Hello CreateDart!', '15px Arial', '#FFF');
    text.y = 45.0;
    return text;
  };

  return new Demo('Text', sourceCode, code);
}

Demo blurFilterDemo() {
  String sourceCode =
      '''// Blur Filter
BlurFilter blurFilter = new BlurFilter(5.0, 2.0, 2);
Rectangle&lt;double&gt; margins = blurFilter.getBounds;
Bitmap image = new Bitmap(img);
image.filters = [blurFilter];
// filters are only displayed when the display object is cached
// later, you can call updateCache() to update changes to your filters
image.cache(margins.left, margins.top, img.width + margins.width.toInt(),
    img.height + margins.height.toInt());''';

  DemoCode code = () {
    BlurFilter blurFilter = new BlurFilter(5.0, 2.0, 2);
    Rectangle<double> margins = blurFilter.getBounds;
    Bitmap image = new Bitmap(img);
    image.filters = [blurFilter];
    // filters are only displayed when the display object is cached
    // later, you can call updateCache() to update changes to your filters
    image.cache(margins.left, margins.top, img.width + margins.width.toInt(),
        img.height + margins.height.toInt());

    return image;
  };

  return new Demo('Blur Filter', sourceCode, code);
}

void main() {
  if (window.top != window) querySelector('#header').style.display = 'none';

  img = new ImageElement();
  img.onLoad.listen(layout);
  img.src = 'assets/images/daisy.png';

  canvasHolder = querySelector('.canvasHolder');

  demos = <Demo>[new Demo('lineTo();',
      '''// lineTo();
new Graphics()
    ..beginStroke('rgba(255,255,255,1)')
    ..moveTo(5.0, 35.0)
    ..lineTo(110.0, 75.0)
    ..endStroke();''',
      () {
      return new Shape(new Graphics()
          ..beginStroke(STROKE_COLOR)
          ..moveTo(5.0, 35.0)
          ..lineTo(110.0, 75.0)
          ..endStroke());
    }), new Demo('arcTo();',
        '''// arcTo();
new Graphics()
    ..beginStroke('rgba(255,255,255,1)')
    ..moveTo(50.0, 20.0)
    ..arcTo(150.0, 20.0, 150.0, 70.0, 50.0)
    ..endStroke();''',
        () {
      return new Shape(new Graphics()
          ..beginStroke(STROKE_COLOR)
          ..moveTo(50.0, 20.0)
          ..arcTo(150.0, 20.0, 150.0, 70.0, 50.0)
          ..endStroke());
    }), new Demo('quadraticCurveTo();',
        '''// quadraticCurveTo();
new Graphics()
    ..beginStroke('rgba(255,255,255,1)')
    ..moveTo(0.0, 25.0)
    ..quadraticCurveTo(45.0, 50.0, 35.0, 25.0)
    ..endStroke();''',
        () {
      return new Shape(new Graphics()
          ..beginStroke(STROKE_COLOR)
          ..moveTo(0.0, 25.0)
          ..quadraticCurveTo(45.0, 50.0, 35.0, 25.0)
          ..endStroke());
    }), new Demo('bezierCurveTo();',
        '''// bezierCurveTo();
new Graphics()
    ..beginStroke('rgba(255,255,255,1)')
    ..moveTo(5.0, 75.0)
    ..bezierCurveTo(4.05, 90.0, 75.0, 75.0, -25.0, -25.0)
    ..endStroke();''',
        () {
      return new Shape(new Graphics()
          ..beginStroke(STROKE_COLOR)
          ..moveTo(5.0, 75.0)
          ..bezierCurveTo(45.0, 90.0, 75.0, 75.0, -25.0, -25.0)
          ..endStroke());
    }), new Demo('beginLinearGradientStroke();',
        '''// beginLinearGradientStroke();
new Graphics()
    ..beginLinearGradientStroke(['rgba(255,255,255,1)',
        'rgba(50, 50, 50, 1)'], [0.0, 0.4], 0.0, 0.0, 70.0, 140.0)
    ..moveTo(5.0, 25.0)
    ..lineTo(110.0, 25.0)
    ..endStroke();''',
        () {
      return new Shape(new Graphics()
          ..beginLinearGradientStroke(<String>[STROKE_COLOR,
              'rgba(50, 50, 50, 1)'], <double>[0.0, 0.4], 0.0, 0.0, 70.0, 140.0)
          ..moveTo(5.0, 25.0)
          ..lineTo(110.0, 25.0)
          ..endStroke());
    }), new Demo('drawRect();',
        '''// drawRect();
new Graphics()
    ..beginFill('rgba(255,255,255,1)')
    ..rect(5.0, 5.0, 80, 80);''',
        () {
      return new Shape(new Graphics()
          ..beginFill(FILL_COLOR)
          ..rect(5.0, 5.0, 80, 80));
    }), new Demo('drawRoundRect();',
        '''// drawRoundRect();
new Graphics()
    ..beginFill('rgba(255,255,255,1)')
    ..drawRoundRect(0.0, 0.0, 120, 120, 5.0);''',
        () {
      return new Shape(new Graphics()
          ..beginFill(FILL_COLOR)
          ..drawRoundRect(0.0, 0.0, 120, 120, 5.0));
    }), new Demo('beginLinearGradientFill() with drawRoundRect();',
        '''// beginLinearGradientFill() with drawRoundRect();
new Graphics()
    ..beginLinearGradientFill(&lt;String&gt;['rgba(255,255,255,1)', 'rgba(0,0,0,1)'],
        &lt;double&gt;[0.0, 1.0], 0.0, 0.0, 0.0, 130.0)
    ..drawRoundRect(0.0, 0.0, 120, 120, 5.0);''',
        () {
      return new Shape(new Graphics()
          ..beginLinearGradientFill(<String>[FILL_COLOR, 'rgba(0,0,0,1)'],
              <double>[0.0, 1.0], 0.0, 0.0, 0.0, 130.0)
          ..drawRoundRect(0.0, 0.0, 120, 120, 5.0));
    }), new Demo('drawCircle();',
        '''// drawCircle();
new Graphics()
    ..beginFill('rgba(255,255,255,1)')
    ..drawCircle(40.0, 40.0, 40.0);''',
        () {
      return new Shape(new Graphics()
          ..beginFill(FILL_COLOR)
          ..drawCircle(40.0, 40.0, 40.0));
    }), new Demo('beginRadialGradientFill() with drawCircle();',
        '''// beginRadialGradientFill() with drawCircle();
new Graphics()
    ..beginRadialGradientFill(&lt;String&gt;['rgba(255,255,255,1)', 'rgba(0,0,0,1)'],
        &lt;double&gt;[0.0, 1.0], 0.0, 0.0, 0.0, 0.0, 0.0, 60.0)
    ..drawCircle(40.0, 40.0, 40.0);''',
        () {
      return new Shape(new Graphics()
          ..beginRadialGradientFill(<String>[FILL_COLOR, 'rgba(0,0,0,1)'],
              <double>[0.0, 1.0], 0.0, 0.0, 0.0, 0.0, 0.0, 60.0)
          ..drawCircle(40.0, 40.0, 40.0));
    }), new Demo('drawEllipse();',
        '''// drawEllipse();
new Graphics()
    ..beginFill('rgba(255,255,255,1)')
    ..drawEllipse(5.0, 5.0, 60, 120);''',
        () {
      return new Shape(new Graphics()
          ..beginFill(FILL_COLOR)
          ..drawEllipse(5.0, 5.0, 60, 120));
    }), new Demo('Draw Hexagon using drawPolyStar();',
        '''// Draw Hexagon using drawPolyStar();
new Graphics()
    ..beginFill('rgba(255,255,255,1)')
    ..drawPolyStar(60.0, 60.0, 60.0, 6, 0.0, 45.0);''',
        () {
      return new Shape(new Graphics()
          ..beginFill(FILL_COLOR)
          ..drawPolyStar(60.0, 60.0, 60.0, 6, 0.0, 45.0));
    }), new Demo('Draw a star using drawPolyStar();',
        '''// Draw a star using drawPolyStar();
new Graphics()
    ..beginFill('rgba(255,255,255,1)')
    ..drawPolyStar(80.0, 80.0, 70.0, 5, 0.6, -90.0);''',
        () {
      return new Shape(new Graphics()
          ..beginFill(FILL_COLOR)
          ..drawPolyStar(80.0, 80.0, 70.0, 5, 0.6, -90.0));
    }), new Demo('beginBitmapStroke() with drawRect();',
        '''// beginBitmapStroke() with drawRect();
new Graphics()
    ..setStrokeStyle(25)
    ..beginBitmapStroke(img)
    ..rect(5.0, 5.0, 100, 100);''',
        () {
      return new Shape(new Graphics()
          ..setStrokeStyle(25)
          ..beginBitmapStroke(img)
          ..rect(5.0, 5.0, 100, 100));
    }), new Demo('drawRoundRectComplex();',
        '''// drawRoundRectComplex();
new Graphics()
    ..beginFill('rgba(255,255,255,1)')
    ..drawRoundRectComplex(5.0, 5.0, 70, 70, 5.0, 10.0, 15.0, 25.0);''',
        () {
      return new Shape(new Graphics()
          ..beginFill(FILL_COLOR)
          ..drawRoundRectComplex(5.0, 5.0, 70, 70, 5.0, 10.0, 15.0, 25.0));
    }), new Demo('drawCircle(); with beginBitmapFill();',
        '''// drawCircle(); with beginBitmapFill();
new Graphics()
    ..beginStroke('rgba(255,255,255,1)')
    ..beginBitmapFill(img)
    ..drawCircle(30.0, 30.0, 30.0)
    ..endStroke();''',
        () {
      return new Shape(new Graphics()
          ..beginStroke(STROKE_COLOR)
          ..beginBitmapFill(img)
          ..drawCircle(30.0, 30.0, 30.0)
          ..endStroke());
    }), textDemo(), blurFilterDemo()];
}
