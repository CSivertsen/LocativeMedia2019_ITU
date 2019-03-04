/**
 
 Blob detection program for the course Locative Media at IT University of Copenhagen spring 2019. 
 
 Based on code from: https://github.com/CodingTrain/website/blob/master/Tutorials/Processing/11_video/sketch_11_10_BlobTracking_lifespan/sketch_11_10_BlobTracking_lifespan.pde 
 
 Daniel Shiffman
 http://codingtra.in
 http://patreon.com/codingtrain
 Video: https://youtu.be/o1Ob28sF0N8
 
 Edited by: Christian Sivertsen
 
 **/

class Blob {
  float minx;
  float miny;
  float maxx;
  float maxy;

  int id = 0;

  int lifespan = maxLife;

  boolean taken = false;

  ArrayList<PVector> points;

  Blob(float x, float y) {
    points = new ArrayList<PVector>();
    points.add(new PVector(x, y));
    minx = x;
    miny = y;
    maxx = x;
    maxy = y;
  }

  boolean checkLife() {
    lifespan--; 
    if (lifespan < 0) {
      return true;
    } else {
      return false;
    }
  }

  void show() {
    stroke(0);
    fill(255, lifespan);
    strokeWeight(2);
    rectMode(CORNERS);
    rect(minx, miny, maxx, maxy);

    textAlign(CENTER);
    textSize(32);
    fill(0);
    text(id, minx + (maxx-minx)*0.5, maxy - 10);
    textSize(32);
    //text(lifespan, minx + (maxx-minx)*0.5, miny - 10);

    //Below code shows every detected point. Comment it out for better performance. 
    //for (PVector v : points) {
    //  stroke( 0, 0, 255);
    //  point(v.x, v.y);
    //}
  }

  void add(float x, float y) {
    points.add(new PVector(x, y));
    minx = min(minx, x);
    miny = min(miny, y);
    maxx = max(maxx, x);
    maxy = max(maxy, y);
  }

  void become(Blob other) {
    points = other.points;
    minx = other.minx;
    maxx = other.maxx;
    miny = other.miny;
    maxy = other.maxy;
    lifespan = maxLife;
  }

  float size() {
    return (maxx-minx)*(maxy-miny);
  }

  PVector getCenter() {
    float x = (maxx - minx)* 0.5 + minx;
    float y = (maxy - miny)* 0.5 + miny;    
    return new PVector(x, y);
  }

  boolean isNear(float x, float y) {

    float cx = max(min(x, maxx), minx);
    float cy = max(min(y, maxy), miny);
    float d = distSq(cx, cy, x, y);

    if (d < distanceThreshold*distanceThreshold) {
      return true;
    } else {
      return false;
    }
  }
}
