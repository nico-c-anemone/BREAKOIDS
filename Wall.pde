// Wall.pde
// Copyright 2014 (c) Nicholas Alcus
// This program is provided WITHOUT WARRANTY of ANY KIND 

class Wall {
  float x;
  float y;
  float w;
  float h;

  Body b;

  Wall(float x_, float y_, float w_, float h_) {
    x=x_;
    y=y_;
    w=w_;
    h=h_;

    PolygonShape sd = new PolygonShape();
    float box2dW = box2d.scalarPixelsToWorld(w/2);
    float box2dH = box2d.scalarPixelsToWorld(h/2);
    sd.setAsBox(box2dW, box2dH);


    BodyDef bd = new BodyDef();
    bd.type= BodyType.STATIC;
    bd.position.set(box2d.coordPixelsToWorld(x, y));
    b = box2d.createBody(bd);

    FixtureDef fd = new FixtureDef();
    fd.shape = sd;
    fd.density = 1;
    fd.friction = 0;
    fd.restitution = 1;
    fd.filter.categoryBits = CATEGORY_WALL;
    fd.filter.maskBits = MASK_WALL;    
    b.createFixture(fd);

    b.setUserData(this);
  }

  void render() {
    Vec2 pos = box2d.getBodyPixelCoord(b);
    float hw=w*0.5;
    float hh=h*0.5;
    colorMode(RGB, 255);
    tint(255, 255);
    beginShape(QUADS);
    texture(blanca_tex);
    vertex(pos.x-hw, pos.y-hh, 0, 0);
    vertex(pos.x+hw, pos.y-hh, 1, 0);
    vertex(pos.x+hw, pos.y+hh, 1, 1);
    vertex(pos.x-hw, pos.y+hh, 0, 1);
    endShape();
  }
}

