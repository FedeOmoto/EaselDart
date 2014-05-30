import 'dart:html';
import 'dart:math';
import 'package:easel_dart/easel_dart.dart' as easel;

CanvasElement canvas;
easel.Stage stage;
int barPadding = 7;
int barHeight;
int maxValue = 50;
int count;
List<int> barValues = new List<int>();
List<Bar> bars = new List<Bar>();

class Bar extends easel.Container {
  int hue;
}

void tick(easel.TickEvent event, [dynamic data]) {
  // if we are on the last frame of animation then remove the tick listener:
  if (--count == 1) {
    easel.Ticker.current.removeEventListener('tick', tick);
  }

  // animate the bars in one at a time:
  int c = bars.length * 10 - count;
  int index = (c ~/ 10);
  Bar bar = bars[index];
  drawBar(bar, (c % 10 + 1) / 10 * barValues[index]);

  // update the stage:
  stage.update([event]);
}

void drawBar(Bar bar, double value) {
  // calculate bar height:
  double h = value / maxValue * barHeight;

  // update the value label:
  easel.Text val = bar.getChildAt(3);
  val.text = value.toInt().toString();
  val.visible = (h > 28);
  val.y = -h + 10;

  // scale the front panel, and position the top:
  bar.getChildAt(1).scaleY = h / 100;
  // the 0.5 eliminates gaps from numerical precision issues.
  bar.getChildAt(2).y = -h + 0.5;

  // redraw the side bar (we can't just scale it because of the angles):
  easel.Shape right = bar.getChildAt(0);
  right.graphics
      ..clear()
      ..beginFill(easel.Graphics.getHSL(bar.hue, 60, 15, 0.7))
      ..moveTo(0.0, 0.0)
      ..lineTo(0.0, -h)
      ..lineTo(10.0, -h - 10)
      ..lineTo(10.0, -10.0)
      ..closePath();
}

void main() {
  if (window.top != window) querySelector('#header').style.display = 'none';

  // create a new stage and point it at our canvas:
  canvas = querySelector('#testCanvas');
  stage = new easel.Stage(canvas);

  // generate some random data (between 4 and 10)
  Random random = new Random();
  int numBars = random.nextInt(6) + 4;
  int max = 0;

  for (int i = 0; i < numBars; i++) {
    int val = random.nextInt(maxValue) + 1;
    if (val > max) {
      max = val;
    }
    barValues.add(val);
  }

  // calculate the bar width and height based on number of bars and width of
  // canvas:
  int barWidth = ((canvas.width - 150 - (numBars - 1) * barPadding) /
      numBars).round();
  barHeight = canvas.height - 150;

  // create a shape to draw the background into:
  easel.Shape bg = new easel.Shape();
  stage.addChild(bg);

  // draw the "shelf" at the bottom of the graph:
  bg.graphics
      ..beginStroke('#444')
      ..moveTo(40.0, canvas.height - 69.5)
      ..lineTo(canvas.width - 70.0, canvas.height - 69.5)
      ..endStroke()
      ..beginFill('#222')
      ..moveTo(canvas.width - 70.0, canvas.height - 70.0)
      ..lineTo(canvas.width - 60.0, canvas.height - 80.0)
      ..lineTo(50.0, canvas.height - 80.0)
      ..lineTo(40.0, canvas.height - 70.0)
      ..closePath();

  // draw the horizontal lines in the background:
  for (int i = 0; i < 9; i++) {
    bg.graphics
        ..beginStroke(i.isOdd ? '#333' : '#444')
        ..moveTo(50.0, (canvas.height - 80 - i / 8 * barHeight).toInt() + 0.5)
        ..lineTo(canvas.width - 60.0, (canvas.height - 80 - i / 8 *
            barHeight).toInt() + 0.5);
  }

  // add the graph title:
  easel.Text label = new easel.Text("Bar Graph Example", "bold 30px Arial",
      "#FFF");
  label.textAlign = 'center';
  label.x = canvas.width / 2;
  label.y = 20.0;
  stage.addChild(label);

  // draw the bars:
  for (int i = 0; i < numBars; i++) {
    // each bar is assembled in its own Container, to make them easier to work
    // with:
    Bar bar = new Bar();

    // this will determine the color of each bar, save as a property of the bar
    // for use in drawBar:
    int hue = bar.hue = (i / numBars * 360).toInt();

    // draw the front panel of the bar, this will be scaled to the right size in
    // drawBar:
    easel.Shape front = new easel.Shape();
    front.graphics
        ..beginLinearGradientFill(<String>[easel.Graphics.getHSL(hue, 100, 60,
            0.9), easel.Graphics.getHSL(hue, 100, 20, 0.75)], <double>[0.0, 1.0], 0.0,
            -100.0, barWidth.toDouble(), 0.0)
        ..drawRect(0.0, -100.0, barWidth + 1, 100);

    // draw the top of the bar, this will be positioned vertically in drawBar:
    easel.Shape top = new easel.Shape();
    top.graphics
        ..beginFill(easel.Graphics.getHSL(hue, 100, 70, 0.9))
        ..moveTo(10.0, -10.0)
        ..lineTo(10.0 + barWidth, -10.0)
        ..lineTo(barWidth.toDouble(), 0.0)
        ..lineTo(0.0, 0.0)
        ..closePath();

    // if this has the max value, we can draw the star into the top:
    if (barValues[i] == max) {
      top.graphics
          ..beginFill('rgba(0,0,0,0.45)')
          ..drawPolyStar(barWidth / 2, 31.0, 7.0, 5, 0.6, -90.0)
          ..closePath();
    }

    // prepare the side of the bar, this will be drawn dynamically in drawBar:
    easel.Shape right = new easel.Shape();
    right.x = barWidth - 0.5;

    // create the label at the bottom of the bar:
    easel.Text label = new easel.Text('Label $i', '16px Arial', '#FFF');
    label.textAlign = 'center';
    label.x = barWidth / 2;
    label.maxWidth = barWidth.toDouble();
    label.y = 12.0;
    label.alpha = 0.5;

    // draw the tab that is placed under the label:
    easel.Shape tab = new easel.Shape();
    tab.graphics
        ..beginFill(easel.Graphics.getHSL(hue, 100, 20))
        ..drawRoundRectComplex(0.0, 1.0, barWidth, 38, 0.0, 0.0, 10.0, 10.0);

    // create the value label that will be populated and positioned by drawBar:
    easel.Text value = new easel.Text('foo', 'bold 14px Arial', '#000');
    value.textAlign = 'center';
    value.x = barWidth / 2;
    value.alpha = 0.45;

    // add all of the elements to the bar Container:
    bar
        ..addChild(right)
        ..addChild(front)
        ..addChild(top)
        ..addChild(value)
        ..addChild(tab)
        ..addChild(label);

    // position the bar, and add it to the stage:
    bar.x = i * (barWidth + barPadding) + 60.0;
    bar.y = canvas.height - 70.0;

    stage.addChild(bar);
    bars.add(bar);

    // draw the bar with an initial value of 0:
    drawBar(bar, 0.0);
  }

  // set up the count for animation based on the number of bars:
  count = numBars * 10;

  // start the tick and point it at the window so we can do some work before
  // updating the stage:
  easel.Ticker.current.useRAF = true;

  // if we use requestAnimationFrame, we should use a framerate that is a factor
  // of 60:
  easel.Ticker.current.setFPS = 30.0;
  easel.Ticker.current.addEventListener('tick', tick);
}
