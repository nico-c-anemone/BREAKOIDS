// RockQueue.pde
// Copyright 2014 (c) Nicholas Alcus
// This program is provided WITHOUT WARRANTY of ANY KIND

final int R_Q_SIZE=100;

class RockQueue {
  boolean[] TODO = new boolean[R_Q_SIZE];
  float[] x = new float[R_Q_SIZE];
  float[] y = new float[R_Q_SIZE];
  int[] size = new int[R_Q_SIZE];

  RockQueue() {
    wipe();
  }

  void wipe() {
    for (int i=0; i<R_Q_SIZE; i++) {
      TODO[i]=false;
      x[i]=0;
      y[i]=0;
      size[i]=0;
    }
  }


  void addRock(float x_, float y_, int size_)
  {
    for (int i=0; i<R_Q_SIZE; i++)
    {
      if (TODO[i]==false) {
        TODO[i]=true;
        x[i]=x_;
        y[i]=y_;
        size[i]=size_;
        break;
      }
    }
  }

  void popRocks() {
    for (int i=0; i<R_Q_SIZE; i++)
    {
      if (TODO[i]==true) {
        TODO[i]=false;
        rocks.add(new Rock(x[i], y[i], size[i], new Vec2(random(-10.0, 10.0), random(-10.0, 10.0))));
      }
    }
  }
}

