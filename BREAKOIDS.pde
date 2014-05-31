// BREAKOIDS
// Copyright 2014 (c) Nicholas Alcus
// This software is provided with ABSOLUTELY NO WARRANTY!!

import ddf.minim.*;
import shiffman.box2d.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.contacts.*;

// CONSTANTS
static final float DEFAULT_PADDLE_WIDTH = 96.0;
static final float DEFAULT_PADDLE_HEIGHT = 24.0;

final short CATEGORY_PADDLE = 0x0001;
final short CATEGORY_PIT = 0x0002;
final short CATEGORY_ROCK = 0x0004;
final short CATEGORY_WALL = 0x0008;
final short CATEGORY_BALL = 0x0016;

final short MASK_PADDLE = CATEGORY_BALL;
final short MASK_PIT = CATEGORY_ROCK;
final short MASK_ROCK = CATEGORY_PIT| CATEGORY_ROCK| CATEGORY_WALL | CATEGORY_BALL;
final short MASK_WALL = CATEGORY_ROCK|CATEGORY_BALL;
final short MASK_BALL = CATEGORY_WALL | CATEGORY_ROCK | CATEGORY_PADDLE;

final float GRAVITY_STRENGTH = 750;

final int INITIAL_LIVES = 3;

// GLOBAL GAME VARIABLES
boolean in_game;
boolean game_over;
int score;
int high_score;
boolean title_sound_triggered;
int stage;
int lives;

// GUI
boolean reset_down=false;

// TEXTURES
PImage blanca_tex;
PImage ball_image;
PImage title_image;
PImage game_over_image;
PImage copyright_image;
PImage font_image;
PImage start_image;
PImage rock_large_image;
PImage rock_medium_image;
PImage rock_small_image;

// SOUND
Minim minim;
AudioSample title_sound;
AudioSample begin_sound;
AudioSample bounce_sound;
AudioSample strike_sound;
AudioSample explosion_sound;
AudioSample gameover_sound;

// PHYSICS
Box2DProcessing box2d;

// TIMING
int startTime;
int oldTime;
int newTime;
int resetTime;
int interval;
int oldMouseX;
int oldMouseY;
float cachedDiv;

// STARS
static final int initialStars=100;
ArrayList<Star> stars;

// ROCKS
static final int initialRocks=1;
ArrayList<Rock> rocks;

RockQueue rockQueue;

// METRICS
float halfWidth;
float halfHeight;

// WALLS
ArrayList<Wall> walls;

Pit thePit;

// BALL
ArrayList<Ball> balls;

// PADDLE
Paddle thePaddle;

// TOGGLES
boolean attractor = false;

void setup () {
  size(480, 640, P3D);
  frameRate(60);
  noStroke();
  background(16);

  // cache half metrics
  halfWidth=width*0.5;
  halfHeight=height*0.5;

  // prepare textures
  // white one pixel texture
  blanca_tex = createImage(1, 1, RGB);
  blanca_tex.loadPixels();
  blanca_tex.pixels[0] = color(255, 255, 255);
  blanca_tex.updatePixels();

  // load textures from files
  title_image=loadImage("breakoids_title.png");
  ball_image=loadImage("ball.png");
  game_over_image=loadImage("gameover.png");
  copyright_image=loadImage("copyright.png");
  font_image=loadImage("04b_03_32.png");
  start_image=loadImage("start.png");
  rock_small_image=loadImage("asteroid_32.png");
  rock_medium_image=loadImage("asteroid_64.png");
  rock_large_image=loadImage("asteroid_128.png");

  setIcon();
  
  // initialize sound
  minim = new Minim(this);
  title_sound =  minim.loadSample("2014_02_24_breakoids_robot_voice_441_16.wav", 256);
  begin_sound = minim.loadSample("begin_verb_44_16.wav", 256);
  strike_sound = minim.loadSample("strike_verb_44_16.wav", 256);
  bounce_sound = minim.loadSample("bounce_verb_44_16.wav", 256);
  explosion_sound = minim.loadSample("explosion2_44_16.wav", 256);
  gameover_sound = minim.loadSample("game_over_44_16.wav", 256);

  // initialize physics
  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  box2d.setGravity(0, 0);
  box2d.listenForCollisions();

  // initialize timing
  oldTime=millis();
  newTime=millis();

  // initialize mouse
  oldMouseX=mouseX;
  oldMouseY=mouseY;

  // cache division for stars
  cachedDiv=-2.0/width; 

  // initialize score
  high_score=0;
  score=0;

  // add walls
  walls = new ArrayList<Wall>();
  walls.add(new Wall(2, halfHeight, 4, height));
  walls.add(new Wall(halfWidth, 2, width, 4));
  walls.add(new Wall(width-2, halfHeight, 4, height));

  thePit = new Pit(halfWidth, height-2.0, width, 4.0); 

  // add a single ball
  balls = new ArrayList<Ball>();

  rockQueue = new RockQueue();

  rocks = new ArrayList<Rock>();




  // initialize stars
  stars = new ArrayList<Star>();
  for (int i=0; i<initialStars; i++) {
    stars.add(new Star(random(width), random(height), 0.5, 0.1, 0.5+random(2.0)));
  } 

  thePaddle = new Paddle(halfWidth, height-75, DEFAULT_PADDLE_WIDTH, DEFAULT_PADDLE_HEIGHT);

  // reset simulation
  resetToTitle();
}

void draw () {

  background(0);

  // update timing  
  oldTime=newTime;
  newTime=millis();
  interval=newTime-oldTime;



  // update mouse position
  oldMouseX=mouseX;
  oldMouseY=mouseY;



  // game state conditional
  if (in_game&&!game_over) // main loop 
  {
    // draw stars 
    for (Star star : stars) {
      star.update(interval);
      star.render();
    }

    // step physics...
    drawWalls();
    box2d.step();


    for (int i = rocks.size ()-1; i >= 0; i--) {
      Rock r = rocks.get(i);
      r.render();
      if (r.done()) {
        rocks.remove(i);
      }
    }

    for (int i = balls.size ()-1; i >= 0; i--) {
      Ball ball = balls.get(i);
      if (attractor) {
        Vec2 force = thePaddle.attract(ball, GRAVITY_STRENGTH);
        ball.applyForce(force);
      }
      ball.render();
      if (ball.done()) {
        balls.remove(i);
      }
    }

    thePaddle.update(mouseX, mouseY);
    thePaddle.render();

    rockQueue.popRocks();

    int ball_size = balls.size();
    
    if (ball_size<1) {
      loseLife();
    }

    if (rocks.size ()<1) {
      newStage();
    }
    colorMode(RGB, 255);
    tint(255, 255);
    write ("Stage:"+stage, 16, 16, 1.0, 0.6);
    
    drawLives();

    
    if ((millis()-startTime>2000)&&(millis()-startTime<10000)) {
         colorMode(RGB, 255);
    tint(255, 192); 
      int l=32;
      int t=128;
      write (" Mouse over the",l, t, 0.8, 0.7);
      write ("screen to control",l, t+32, 0.8, 0.7);
      write (" the paddle.", l, t+64, 0.8, 0.7);
    }
    
    if ((millis()-startTime>3000)&&(millis()-startTime<11000)) {
         colorMode(RGB, 255);
    tint(255, 192); 
          int l=(int)halfWidth-64;
      int t=128*2;
      write (" Left click to  ",l, t, 0.8, 0.7);
      write ("  activate the  ",l, t+32, 0.8, 0.7);
      write ("paddle's magnet.",l, t+64, 0.8, 0.7);
    }

    if ((millis()-startTime>5000)&&(millis()-startTime<13000)) {
         colorMode(RGB, 255);
    tint(255, 192); 
          int l=32;
      int t=128*3;
      write (" Break the rocks" ,l, t, 0.8, 0.7);
      write ("with the ball to",l, t+32, 0.8, 0.7);
      write ("  win the game. ",l, t+64, 0.8, 0.7);
    }
    
  } else if (!in_game&&!game_over) { 
    // ** TITLE SCREEN **

    // draw stars 
    for (Star star : stars) {
      star.update(interval);
      star.render();
    }
    // step physics...
    drawWalls();

    drawTitle();
  } else { 
    // ** game over screen **
    colorMode(RGB, 255);
    tint(255, 255);
    image (game_over_image, int(halfWidth-(game_over_image.width*0.5)), int(halfHeight-(game_over_image.height*0.5)));
  }

  drawScores();
}


void drawWalls() {

  for (Wall wall : walls) {
    wall.render();
  }

  thePit.render();
}

void mousePressed() {
  if (in_game&&!game_over) {
    // artificaial gravity
    // println ("TODO: activate artificial gravity on MouseDown");
    attractor=true;
  } else if (!in_game&&!game_over) {
    startGame();
  } else if (game_over)
    // GAME OVER SCREEN MOUSE PRESSED
  {
    reset_down=true;
  }
}

void mouseReleased() {
  
  if (in_game&&!game_over) {
    attractor=false;
  } else if (game_over&&reset_down) {
    
    resetToTitle();
  }
  reset_down=false;
}

void resetToTitle() {
  resetTime=millis();
  in_game=false;
  game_over=false;
  score=0;
  title_sound_triggered=false;
  stage=0;
  rockQueue.wipe();
}

void write(String message, float mes_x, float mes_y, float scale, float spacing) {
  int c=0;
  int col=0;
  int row=0;
  float xoffset=0;
  for (int i=0; i<message.length (); i++) 
  { 
    c= ((int)message.charAt(i))-32;
    col=32*(c%8);
    row=32*int(c/8);
    xoffset=mes_x+(32*i*scale*spacing);

    beginShape(QUADS);
    texture(font_image);
    vertex(xoffset, mes_y, col, row);
    vertex(xoffset+(32*scale), mes_y, col+32, row);
    vertex(xoffset+(32*scale), mes_y+(32*scale), col+32, row+32);
    vertex(xoffset, mes_y+(32*scale), col, row+32);
    endShape();
  }
}

void incrementScore() {
  score++;
  if (high_score<score) {
    high_score=score;
  }
}

void drawScores() {
  // we are going to use fixed values so we can re-use the scroe texture
  colorMode(RGB, 255);
  tint(255, 216);

  write ("Score:"+score, 32, height-40, 1.0, 0.6);
  write ("HiScore:"+high_score, halfWidth, height-40, 1.0, 0.6);
}

void drawTitle() {
  int title_brightness=0;
  title_brightness=(millis()-resetTime)/10;
  if (!title_sound_triggered) {
    title_sound.trigger();
    title_sound_triggered=true;
  }   
  if (title_brightness>255) {
    title_brightness=255;
  }
  colorMode(HSB, 255);
  tint((0.06125*millis())%255, 255, title_brightness, 255);
  image (title_image, halfWidth-(title_image.width*0.5), halfHeight-(title_image.height*0.5));
  if ((millis()%1000)>500&&title_brightness==255) {
    colorMode(RGB, 255);
    tint(196, 255);
    image (start_image, halfWidth-(start_image.width*0.5), halfHeight+(title_image.height*0.5)+24);
    
  }
  colorMode(RGB, 255);
  tint(255, 255);
  image (copyright_image,halfWidth,16);
}

void startGame() {
  in_game=true;
  rockQueue.wipe();
  newStage();
 
  lives=INITIAL_LIVES;
  
  startTime=millis();
  
  addBall();
}

void beginContact(Contact cp) {
  // Get both fixtures
  Fixture f1 = cp.getFixtureA();
  Fixture f2 = cp.getFixtureB();
  // Get both bodies
  Body b1 = f1.getBody();
  Body b2 = f2.getBody();

  // Get our objects that reference these bodies
  Object o1 = b1.getUserData();
  Object o2 = b2.getUserData();

  if ((o1.getClass() == Ball.class && o2.getClass() == Wall.class)||
    (o1.getClass() == Wall.class && o2.getClass() == Ball.class)) {
    bounce_sound.trigger();
  }

  if ((o1.getClass() == Ball.class && o2.getClass() == Paddle.class)||
    (o1.getClass() == Paddle.class && o2.getClass() == Ball.class)) {
    strike_sound.trigger();
  }

  if (o1.getClass() == Ball.class && o2.getClass() == Rock.class) {
    Rock r = (Rock) o2;
    if (r!=null) {
      r.damage(rocks);
    }
  }

  if (o1.getClass() == Rock.class && o2.getClass() == Ball.class) {
    Rock r = (Rock) o1;
    if (r!=null) {
      r.damage(rocks);
    }
  }
}

void endContact(Contact cp) {
}

void newStage()
{
  stage++;
  for (int i=0; i<initialRocks+stage-1; i++) {
    rockQueue.addRock(random(width), random(height-100), (i+2)%3);
  }
  rockQueue.popRocks();

  begin_sound.trigger();
}

void gameOver() {
  game_over=true;
  gameover_sound.trigger();
  for (Rock rock : rocks)
  {
    rock.delete();
  }
}

void setIcon() {
  final PGraphics pg = createGraphics(32, 32);

  pg.beginDraw();
  pg.image(rock_small_image, 0, 0, 32, 32);
  pg.endDraw();

  frame.setIconImage(pg.image);
}

void loseLife() {
  begin_sound.trigger(); 
  lives--;
   if (lives<1) {
     gameOver();
   } else {
     addBall();
   }
   
}

void addBall() {
  balls.add(new Ball(halfWidth, 25));

  for (Ball ball : balls) {
    ball.initialize();
  }
}

void drawLives() {
  for (int i=lives-1;i>0;i--)
 {
    float x=width-(32*i)-8;
    float y=24;
    colorMode(RGB, 255);
    tint(255, 255); 
    beginShape(QUADS);
    texture(ball_image);
    // upperleft
    vertex(x, y, 0, 0);
    // upper right
    vertex(x+16, y, 16, 0);
    // lower right
    vertex(x+16, y+16, 16, 16);
    // lower left
    vertex(x, y+16, 0, 16);
    endShape();
 } 
}
