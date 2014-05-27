// Ball.pde
// Copyright 2014 (c) Nicholas Alcus
// This program is provided WITHOUT WARRANTY of ANY KIND 

class Ball {
  float x;
  float y;
  float r;
  Body b;

  boolean delete=false;

  Ball (float x_, float y_) {
    x=x_;
    y=y_;
    r=16.0;

    BodyDef bd = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.position.set(box2d.coordPixelsToWorld(x, y));
    b = box2d.createBody(bd);

    CircleShape cs = new CircleShape();
    cs.m_radius = box2d.scalarPixelsToWorld(r/2);

    FixtureDef fd = new FixtureDef();
    fd.shape = cs;
    fd.density = 1;
    fd.friction = 1;
    fd.restitution = 1;
    fd.filter.categoryBits = CATEGORY_BALL;
    fd.filter.maskBits = MASK_BALL;

    b.createFixture(fd);

    b.setUserData(this);
  }


  void initialize() {
    x=halfWidth;
    y=32;
    r=16.0;
    setVelocity(new Vec2(random(-10, 10.0), random(-10, 10.0)));
  }


  void render() {
    Vec2 pos = box2d.getBodyPixelCoord(b);
    float half=r*0.5;
    colorMode(RGB, 255);
    color(255, 255);   
    tint(255, 255); 
    beginShape(QUADS);
    texture(ball_image);
    // upperleft
    vertex(pos.x-half, pos.y-half, 0, 0);
    // upper right
    vertex(pos.x+half, pos.y-half, 16, 0);
    // lower right
    vertex(pos.x+half, pos.y+half, 16, 16);
    // lower left
    vertex(pos.x-half, pos.y+half, 0, 16);
    endShape();
  }

  void applyForce(Vec2 force) {
    b.applyForce(force, b.getWorldCenter());
  }

  void setVelocity(Vec2 v) {
    b.setLinearVelocity(v);
  }

  void killBody() {
    box2d.destroyBody(b);
  }

  boolean done() {
    Vec2 pos = box2d.getBodyPixelCoord(b);
    if (pos.y>(height+32) || delete) {
      killBody();
      return true;
    }
    return false;
  }
}

