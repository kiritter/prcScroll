final int FRAME_NUM_ADDBALL = 7;
final int FRAME_NUM_ADDPAR = FRAME_NUM_ADDBALL * 32;
final int FRAME_NUM_CAMERA = FRAME_NUM_ADDBALL * 4;
final int FRAME_NUM_ADDBGLINE_NEAR = FRAME_NUM_ADDBALL * 10;
final int FRAME_NUM_ADDBGLINE_FAR = FRAME_NUM_ADDBALL * 28;
final int NUM_PARTICLES = 30;

float seedY;
final float NOISE_DELTA = 0.1;

PVector lastP;
PVector thisP;

Util util;
Camera2D camera;
ArrayList<Life> bgLines;
ArrayList<Life> lines;
ArrayList<Life> balls;
ArrayList<Life> particles;

//--------------------------------------------------
void setup(){
  initWindow();
  initObjects();
}

void initWindow() {
  size(640, 480);
  smooth();
  frameRate(30);
}

void initObjects() {
  seedY = random(0, 10);
  lastP = new PVector(width / 5 * 4, height / 2);
  thisP = new PVector(0, 0);

  util = new Util();
  camera = new Camera2D();
  bgLines = new ArrayList<Life>();
  lines = new ArrayList<Life>();
  balls = new ArrayList<Life>();
  addBall(lastP, util.getColor());
  particles = new ArrayList<Life>();
}

//--------------------------------------------------
void draw(){
  background(0);

  if (frameCount % FRAME_NUM_ADDBALL == 0) {
    getPoint(lastP);
    color c = util.getColor();
    addLine(lastP, thisP, c);
    addBall(thisP, c);
    lastP.set(thisP.x, thisP.y);
  }
  if (frameCount % FRAME_NUM_ADDPAR == 0) {
    addParticles(thisP);
  }
  if (frameCount % FRAME_NUM_CAMERA == 0) {
    camera.updateScroll();
  }
  if (frameCount % FRAME_NUM_ADDBGLINE_NEAR == 0) {
    addBgLine(thisP, BgLine.BGLEVEL_NEAR);
  }
  if (frameCount % FRAME_NUM_ADDBGLINE_FAR == 0) {
    addBgLine(thisP, BgLine.BGLEVEL_FAR);
  }

  camera.scroll();
  drawBgLines();
  drawLines();
  drawBalls();
  drawParticles();
}

void keyPressed() {
  if (key == 'r') {
    saveFrame("output/frame-####.png");
  }
}

//--------------------------------------------------
void getPoint(PVector lastP) {
  int delta = camera.SCROLL_DELTA_X * FRAME_NUM_ADDBALL;
  int plmi = util.getPlusMinus();
  float x = delta;
  float y = plmi * noise(seedY) * 80;
  thisP.set(lastP.x + x, lastP.y + y);
  camera.add(y);
  seedY += NOISE_DELTA;
}

void addBgLine(PVector thisP, int level) {
  bgLines.add(new BgLine(thisP, level));
}
void addLine(PVector lastP, PVector thisP, color c) {
  lines.add(new Line(lastP, thisP, c));
}
void addBall(PVector thisP, color c) {
  float r = random(10, 30);
  balls.add(new Ball(thisP, r, c));
}
void addParticles(PVector thisP) {
  float r;
  color c;
  for (int i = 0; i < NUM_PARTICLES; i++) {
    r = random(5, 20);
    c = util.getColor();
    particles.add(new Particle(thisP, r, c));
  }
}

//--------------------------------------------------
void drawBgLines() {
  drawLives(bgLines);
}
void drawLines() {
  drawLives(lines);
}
void drawBalls() {
  drawLives(balls);
}
void drawParticles() {
  drawLives(particles);
}
void drawLives(ArrayList<Life> lives) {
  Life life;
  int len = lives.size() - 1;
  for (int i = len; i >= 0; i--) {
    life = lives.get(i);
    if (life.isDead()) {
      lives.remove(i);
    }else{
      life.run();
    }
  }
}

//--------------------------------------------------
class Camera2D {
  static final int SCROLL_DELTA_X = 7;
  float scroll_delta_y;
  float sumOfDeltaY;

  float x;
  float y;
  
  void scroll() {
    x -= SCROLL_DELTA_X;
    y -= scroll_delta_y;
    translate(x, y);
  }
  void add(float deltaY) {
    this.sumOfDeltaY += deltaY;
  }
  void updateScroll() {
    scroll_delta_y = sumOfDeltaY / FRAME_NUM_CAMERA;
    sumOfDeltaY = 0.0;
  }
}
//--------------------------------------------------
abstract class Life {
  int lifespan;

  final void run() {
    updateLifespan();
    update();
    display();
  }
  final void updateLifespan() {
    lifespan -= 1;
  }
  abstract void update();
  abstract void display();
  final boolean isDead() {
    if (lifespan <= 0) {
      return true;
    } else {
      return false;
    }
  }
}
//--------------------------------------------------
class BgLine extends Life {
  PVector p;
  int level;
  static final int BGLEVEL_NEAR = 1;
  static final int BGLEVEL_FAR = 2;
  color c;
  float rectWidth;
  float rectHeight;
  
  BgLine(PVector p, int level) {
    this.lifespan = 300;
    this.p = p.get();
    this.level = level;

    if (level == BGLEVEL_NEAR) {
      c = color(128, 255);
    }else if (level == BGLEVEL_FAR){
      c = color(255, random(32, 64));
      rectWidth = random(30, 60);
      rectHeight = rectWidth * random(2, 4);
    }
  }
  void update() {
    if (level == BGLEVEL_NEAR) {
      p.x += 3;
      p.y += camera.scroll_delta_y;
    }else if (level == BGLEVEL_FAR){
      p.x += 4;
      p.y += camera.scroll_delta_y / 3 * 2;
    }
  }
  void display() {
    if (level == BGLEVEL_NEAR) {
      strokeWeight(1);
      stroke(c);
      line(p.x + 150, p.y - 500, p.x + 150, p.y + 500);
    }else if (level == BGLEVEL_FAR){
      noStroke();
      fill(c);
      rect(p.x + 150, p.y - rectHeight / 2, rectWidth, rectHeight);
    }
 }
}
//--------------------------------------------------
class Line extends Life {
  PVector p1, p2;
  color c;
  
  Line(PVector p1, PVector p2, color c) {
    this.lifespan = 150;
    this.p1 = p1.get();
    this.p2 = p2.get();
    this.c = c;
  }
  void update() {
  }
  void display() {
    strokeWeight(2);
    stroke(c);
    line(p1.x, p1.y, p2.x, p2.y);
 }
}
//--------------------------------------------------
class Ball extends Life {
  PVector p;
  float EndR;
  float r = 1.0;
  float deltaR;
  color c;
  boolean finished = false;

  Ball(PVector p, float r, color c) {
    this.lifespan = 150;
    this.p = p.get();
    this.EndR = r;
    this.deltaR = this.EndR / FRAME_NUM_ADDBALL;
    this.c = c;
  }
  void update() {
    if (finished == false) {
      if (r < EndR) {
        r += deltaR;
      }else{
        r = EndR;
        finished = true;
      }
    }
  }
  void display() {
    noStroke();
    fill(c);
    ellipse(p.x, p.y, r * 2, r * 2);
 }
}
//--------------------------------------------------
class Particle extends Life {
  PVector location;
  PVector velocity;
  PVector acceleration;
  float r;
  color c;

  Particle(PVector p, float r, color c) {
    this.lifespan = 110;
    this.location = p.get();
    this.velocity = new PVector(random(0, 10), random(-6, 6));
    this.acceleration = new PVector(-0.3, 0);
    this.r = r;
    this.c = c;
  }
  void update() {
    velocity.add(acceleration);
    location.add(velocity);
  }
  void display() {
    noStroke();
    fill(c, lifespan*2);
    ellipse(location.x, location.y, r * 2, r * 2);
  }
}
//--------------------------------------------------
class Util {
  int getPlusMinus() {
    float r = random(-0.5, 0.5);
    if (r < 0) {
      return -1;
    }else{
      return 1;
    }
  }
  color getColor() {
    return color(random(0, 255), random(0, 255), random(0, 255), 255);
  }
}
