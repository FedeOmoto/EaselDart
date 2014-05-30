import 'dart:html';
import 'dart:math';
import 'package:easel_dart/easel_dart.dart' as easel;

CanvasElement canvas;
easel.Stage stage;
ImageElement img;
List<Rat> spriteList;

class Rat extends easel.Sprite {
  int speed;
  int direction;
  double vX;
  double vY;
  easel.SpriteSheet _spriteSheet;

  Rat(easel.SpriteSheet spriteSheet, dynamic frameOrAnimation) : super(
      spriteSheet, frameOrAnimation) {
    _spriteSheet = spriteSheet;
  }
}

void handleImageLoad(Event event) {
  // create spritesheet and assign the associated data.
  easel.SpriteSheetData ssd = new easel.SpriteSheetData();
  ssd.animations = <String, Object> {
    'walkUpRt': [0, 19, 'walkRt'],
    'walkDnRt': [20, 39, 'walkUpRt'],
    'walkRt': [41, 59, 'walkDnRt']
  };
  ssd.images = <CanvasImageSource>[img];
  ssd.frames = <String, num> {
    'width': 64,
    'height': 68,
    'regX': 32,
    'regY': 34
  };
  easel.SpriteSheet spriteSheet = new easel.SpriteSheet(ssd);

  // to save file size, the loaded sprite sheet only includes right facing
  // animations we could flip the display objects with scaleX=-1, but this is
  // expensive in some browsers instead, we append flipped versions of the
  // frames to our sprite sheet this adds only horizontally flipped frames:
  easel.SpriteSheetUtils.current.addFlippedFrames(spriteSheet, true, false,
      false);

  // we could rewire the "next" sequences to make them work like so:
  // but instead we will use code in the angleChange function.
  /*
         spriteSheet.getAnimation("walkDnRt").next = "walkDnRt_h";
         spriteSheet.getAnimation("walkDnRt_h").next = "walkRt_h";
         spriteSheet.getAnimation("walkRt_h").next = "walkUpRt_h";
         spriteSheet.getAnimation("walkUpRt_h").next = "walkUpRt";
  */

  // create a Sprite instance to display and play back the sprite sheet:
  Rat sprite = new Rat(spriteSheet, null);

  // start playing the first sequence:
  sprite.gotoAndPlay('walkRt'); //animate

  // create a bunch of rats based on the first one, and place them on stage, and
  // in our collection.
  int l = 50;
  spriteList = new List<Rat>();

  Random random = new Random();

  for (int i = 0; i < l; i++) {
    sprite.name = 'rat' + i.toString();
    sprite.speed = random.nextInt(6) + 2;
    sprite.direction = 90;
    sprite.vX = sprite.speed.toDouble();
    sprite.vY = 0.0;
    sprite.x = (random.nextInt((canvas.width - 220)) + 60).toDouble();
    sprite.y = random.nextInt((canvas.height - 220)).toDouble();

    // have each rat start on a random frame in the "walkRt" animation:
    sprite.currentAnimationFrame = random.nextInt(spriteSheet.getNumFrames(
        'walkRt')).toDouble();
    stage.addChild(sprite);
    spriteList.add(sprite);

    // the callback is called each time a sequence completes:
    sprite.addEventListener('animationend', angleChange);

    // rather than creating a brand new instance each time, and setting every property, we
    // can just clone the current one and overwrite the properties we want to change:
    if (i < l - 1) sprite = sprite.clone();
  }

  // we want to do some work before we update the canvas,
  // otherwise we could use createjs.Ticker.addEventListener("tick", stage);
  easel.Ticker.current.addEventListener('tick', tick);
}

//called if there is an error loading the image (usually due to a 404)
void handleImageError(Event event) {
  //print('Error Loading Image : ${event.target.src});
}

void tick(easel.TickEvent event, [dynamic data]) {
  // move all the rats according to their vX/vY properties:
  spriteList.forEach((Rat rat) {
    rat.x += rat.vX;
    rat.y += rat.vY;
  });

  // update the stage:
  stage.update([event]);
}

void angleChange(easel.AnimationEndEvent event, [dynamic data]) {
  Rat sprite = event.target;

  // after each sequence ends update the rat's heading and adjust
  // velocities to match
  sprite.direction -= 60;
  double angle = sprite.direction * (PI / 180);
  sprite.vX = sin(angle) * sprite.speed;
  sprite.vY = cos(angle) * sprite.speed;
  Map<String, String> nextMap = {
    'walkRt': 'walkDnRt',
    'walkDnRt': 'walkDnRt_h',
    'walkDnRt_h': 'walkRt_h',
    'walkRt_h': 'walkUpRt_h',
    'walkUpRt_h': 'walkUpRt',
    'walkUpRt': 'walkRt'
  };
  sprite.gotoAndPlay(nextMap[event.name]);
}

void main() {
  //find canvas and load images, wait for last image to load
  canvas = querySelector('#testCanvas');

  // create a new stage and point it at our canvas:
  stage = new easel.Stage(canvas);

  img = new ImageElement();
  img.src = 'assets/images/testSeq.png';
  img.onLoad.listen(handleImageLoad);
}
