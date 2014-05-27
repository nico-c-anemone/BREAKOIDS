// Rock.pde
// Copyright 2014 (c) Nicholas Alcus
// This program is provided WITHOUT WARRANTY of ANY KIND

class Rock {
  int size;

  float x;
  float y;
  float r;

  Body b;

  int hp;

  boolean delete = false;

  Rock(float x_, float y_, int size_, Vec2 vel_) {
    size=size_;
    float r_;
    switch (size) {
    case 1:
      r_=32;
      break;
    case 2:
      r_=64;
      break;
    default:
      size=3;
    case 3:
      r_=128;
      break;
    }
    x=x_;
    y=y_;
    r=r_;

    BodyDef bd = new BodyDef();
    bd.type= BodyType.DYNAMIC;
    bd.position.set(box2d.coordPixelsToWorld(x, y));
    b = box2d.createBody(bd);

    CircleShape cs = new CircleShape();
    cs.m_radius = box2d.scalarPixelsToWorld(r/2);

    FixtureDef fd = new FixtureDef();
    fd.shape = cs;
    fd.density = 0.5;
    fd.friction = 1;
    fd.restitution = 1;
    fd.filter.categoryBits = CATEGORY_ROCK;
    fd.filter.maskBits = MASK_ROCK;

    b.createFixture(fd);

    b.setUserData(this);
    b.setLinearVelocity(vel_);
    b.setAngularVelocity(random(-PI, PI));
  }

  void damage(ArrayList<Rock> allTheRocks) {
    Vec2 pos = box2d.getBodyPixelCoord(this.b);

    switch (this.size) {
    case 1:
      break;
    case 2:
      rockQueue.addRock(pos.x, pos.y, 1);
      rockQueue.addRock(pos.x, pos.y, 1);
      break;
    default:
      size=3;
    case 3:
      rockQueue.addRock(pos.x, pos.y, 2);
      rockQueue.addRock(pos.x, pos.y, 2);
      rockQueue.addRock(pos.x, pos.y, 2);
      break;
    }
    this.delete();

    incrementScore();
    explosion_sound.trigger();
  }

  void delete() {
    delete = true;
  }

  boolean done() {
    Vec2 pos = box2d.getBodyPixelCoord(this.b);
    boolean OOB = false;
    if (pos.x>width+32||pos.x<0-32||pos.y<0-32||pos.y>height+32) {
      OOB=true;
    }
    if (delete||OOB) {
      killBody();
      return true;
    }
    return false;
  }

  void killBody() {
    box2d.destroyBody(b);
  }

  void render()
  {
    if (b!=null) {
      if (size >0) {
        Vec2 pos = box2d.getBodyPixelCoord(b);
        float hr=r*0.5;
        float hh=r*0.5;
        float a = -b.getAngle();

        pushMatrix(); 
        translate(pos.x, pos.y);
        rotateZ(a);
        colorMode(RGB, 255);
        tint(255, 255);
        beginShape();
        switch (size) {
        case 1:
          texture(rock_small_image);
          break;
        case 2:
          texture(rock_medium_image);
          break;
        default:
          size=3;
        case 3:
          texture(rock_large_image);
          break;
        }
        vertex(-hr, -hr, 0, 0);
        vertex(+hr, -hr, hr*2, 0);
        vertex(+hr, +hr, hr*2, hr*2);
        vertex(-hr, +hr, 0, hr*2);
        endShape();
        popMatrix();
      }
    } else {
      println ("null render!");
    }
  }
}

