// Star.pde
// Copyright 2014 (c) Nicholas Alcus
// This program is provided WITHOUT WARRANTY of ANY KIND 

class Star {
  PVector position;
  PVector velocity;
  float size;

  Star(float x, float y, float u, float v, float s) {
    this.position = new PVector(x, y);
    this.velocity = new PVector(u, v);
    this.size=s;
  }

  void update(int timeInterval) {
    this.position.add(PVector.mult(this.velocity, (timeInterval*this.size*0.1)));

    // check for border crossings
    if (this.position.x>width+this.size&&this.velocity.x>0) {
      this.position.x=-size;
      this.position.y=random(height);
    }    

    if (this.position.x<(0-this.size)&&this.velocity.x<0) {
      this.position.x=width+size;
      this.position.y=random(height);
    }   

    if (this.position.y>height+this.size&&this.velocity.y>0) {
      this.position.y=-size;
      this.position.x=random(width);
    }    

    if (this.position.y<(0-this.size)&&this.velocity.y<0) {
      this.position.y=height+size;
      this.position.x=random(width);
    }
  }

  void render() {
    float offset=size*0.5;
    colorMode(RGB, 255);
    tint(random(15)+240, 255);    
    beginShape(QUADS);
    texture(blanca_tex);
    // upperleft
    vertex(this.position.x-offset, this.position.y-offset, 0, 0);
    // upper right
    vertex(this.position.x+offset, this.position.y-offset, 1, 0);
    // lower right
    vertex(this.position.x+offset, this.position.y+offset, 1, 1);
    // lower left
    vertex(this.position.x-offset, this.position.y+offset, 0, 1);
    endShape();
  }

  void setVelocity (PVector velocity_) {
    this.velocity.set(velocity_);
  }
}

