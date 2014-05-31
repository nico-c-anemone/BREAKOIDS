// Paddle.pde
// Copyright 2014 (c) Nicholas Alcus
// This program is provided WITHOUT WARRANTY of ANY KIND 

class Paddle {
  float x;
  float y;
  float w;
  float h;

  Body b;

  Paddle(float x_, float y_, float w_, float h_) {
    x=x_;
    y=y_;
    w=w_;
    h=h_;

    BodyDef bd = new BodyDef();
    bd.type= BodyType.KINEMATIC;
    bd.position.set(box2d.coordPixelsToWorld(x, y));
    b = box2d.createBody(bd);

    PolygonShape sd = new PolygonShape();
    float box2dW = box2d.scalarPixelsToWorld(w/2);
    float box2dH = box2d.scalarPixelsToWorld(h/2);
    sd.setAsBox(box2dW, box2dH);

    FixtureDef fd = new FixtureDef();
    fd.shape = sd;
    fd.density = 1;
    fd.friction = 1;
    fd.restitution = 1;
    fd.filter.categoryBits = CATEGORY_PADDLE;
    fd.filter.maskBits = MASK_PADDLE;

    b.createFixture(fd);

    b.setUserData(this);
  }

  void update(float x_, float y_)
  {
    float hw=w*0.5;
    float hh=h*0.5;
    if (x_<2+hw)
      x_=hw+2;
    if (x_>width-2-hw)
      x_=width-2-hw;
    Vec2 pos = box2d.getBodyPixelCoord(b);
    Vec2 v=new Vec2(x_-pos.x, 0); 
    b.setLinearVelocity(v);
  } 

  Vec2 attract(Ball ball, float magnitude) {
    Vec2 pos = b.getWorldCenter(); // location of paddle
    Vec2 ballPos = ball.b.getWorldCenter(); // location of ball
    // vector pointing from from ball to paddle 
    Vec2 force = pos.sub(ballPos);
    // get the distance and contrain it to 1- 5
    float distance = force.length();
    distance = constrain(distance, 1, 5);
    // normalize force vector
    force.normalize();
    // calculate magnitude of strength using 1 as mass for paddle since it is a KINETIC body.
    float strength = (magnitude * 1 * ball.b.m_mass) / (distance * distance);
    // multiply force vector by strength scalar
    force.mulLocal(strength);
    // return calculated force vector
    return force;
  }


  void render() {
    Vec2 pos = box2d.getBodyPixelCoord(b);
    float hw=w*0.5;
    float hh=h*0.5;
    if (attractor) {
      colorMode(RGB, 255);
      tint(255, 255, 128, 255);
    } else {
      colorMode(RGB, 255);
      tint(255, 255);
    }
    beginShape(QUADS);
    texture(blanca_tex);
    vertex(pos.x-hw, pos.y-hh, 0, 0);
    vertex(pos.x+hw, pos.y-hh, 1, 0);
    vertex(pos.x+hw, pos.y+hh, 1, 1);
    vertex(pos.x-hw, pos.y+hh, 0, 1);
    endShape();
  }
}

