import 'dart:html';
import 'package:easel_dart/easel_dart.dart' as easel;

easel.Stage stage;
bool isDrawing = false;
easel.Shape drawingCanvas;
Point<double> oldPt;
Point<double> oldMidPt;
ImageElement image;
easel.Bitmap bitmap;
easel.AlphaMaskFilter maskFilter;
easel.Shape cursor;
easel.Text text;
easel.Bitmap blur;

void handleComplete(Event event) {
  querySelector('#loader').className = '';
  easel.Touch.current.enable(stage);
  stage.enableMouseOver();

  stage.addEventListener('stagemousedown', handleMouseDown);
  stage.addEventListener('stagemouseup', handleMouseUp);
  stage.addEventListener('stagemousemove', handleMouseMove);
  drawingCanvas = new easel.Shape();
  bitmap = new easel.Bitmap(image);

  blur = new easel.Bitmap(image);
  blur.filters = [new easel.BlurFilter(15.0, 15.0, 2)];
  blur.cache(0.0, 0.0, 960, 400);
  blur.alpha = 0.9;

  text.text = 'Click and Drag to Reveal the Image.';

  stage.addChild(blur);
  stage.addChild(text);
  stage.addChild(bitmap);
  updateCacheImage(false);

  cursor = new easel.Shape(new easel.Graphics()
      ..beginFill("#FFFFFF")
      ..drawCircle(0.0, 0.0, 20.0));
  cursor.cursor = 'pointer';

  stage.addChild(cursor);
}

void handleMouseDown(easel.Event event, [dynamic data]) {
  oldPt = new Point<double>(stage.mouseX, stage.mouseY);
  oldMidPt = oldPt;
  isDrawing = true;
}

void handleMouseMove(easel.Event event, [dynamic data]) {
  cursor.x = stage.mouseX;
  cursor.y = stage.mouseY;

  if (!isDrawing) {
    stage.update();
    return;
  }

  Point<double> midPoint = new Point<double>((oldPt.x + stage.mouseX) / 2,
      (oldPt.y + stage.mouseY) / 2);

  drawingCanvas.graphics.setStrokeStyle(40, 1, 1)
      ..beginStroke('rgba(0,0,0,0.15)')
      ..moveTo(midPoint.x, midPoint.y)
      ..curveTo(oldPt.x, oldPt.y, oldMidPt.x, oldMidPt.y);

  oldPt = new Point<double>(stage.mouseX, stage.mouseY);
  oldMidPt = new Point<double>(midPoint.x, midPoint.y);

  updateCacheImage(true);
}

void handleMouseUp(easel.Event event, [dynamic data]) {
  updateCacheImage(true);
  isDrawing = false;
}

void updateCacheImage(bool update) {
  if (update) {
    drawingCanvas.updateCache();
  } else {
    drawingCanvas.cache(0.0, 0.0, image.width, image.height);
  }

  maskFilter = new easel.AlphaMaskFilter(drawingCanvas.cacheCanvas);
  bitmap.filters = [maskFilter];

  if (update) {
    bitmap.updateCache();
  } else {
    bitmap.cache(0.0, 0.0, image.width, image.height);
  }

  stage.update();
}

void main() {
  if (window.top != window) querySelector('#header').style.display = 'none';

  image = new ImageElement();
  image.onLoad.listen(handleComplete);
  image.src = 'assets/images/AlphaMaskImage.png';

  stage = new easel.Stage(querySelector('#testCanvas'));
  text = new easel.Text("Loading...", "20px Arial", "#999999");
  text.x = stage.canvas.width / 2;
  text.y = (stage.canvas.height - 80).toDouble();
  text.textAlign = 'center';
}
