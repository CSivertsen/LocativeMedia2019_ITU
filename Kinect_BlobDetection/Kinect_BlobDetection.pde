/**
 
 Blob detection program for the course Locative Media at IT University of Copenhagen spring 2019. 
 
 Based on code from: https://github.com/CodingTrain/website/blob/master/Tutorials/Processing/11_video/sketch_11_10_BlobTracking_lifespan/sketch_11_10_BlobTracking_lifespan.pde
 
 // Daniel Shiffman
 // http://codingtra.in
 // http://patreon.com/codingtrain
 // Code for: https://youtu.be/o1Ob28sF0N8
 
 Edited by: Christian Sivertsen
 
 **/

import processing.video.*;
import org.openkinect.processing.*;

// The kinect stuff is happening in another class
Kinect kinect;

int blobCounter = 0;

int maxLife = 50;

float trackDepth = 10.0;
float likenessThreshold = 40;
float distanceThreshold = 50;

ArrayList<Blob> blobs = new ArrayList<Blob>();

PImage kinectVideo; 

// Depth data
int[] depth;

void setup() {
  size(640, 480);

  setupKinect();
}

void setupKinect() {
  kinect = new Kinect(this);

  kinect.initDepth();
  kinect.enableMirror(true);

  kinectVideo = createImage(kinect.width, kinect.height, RGB);
}

void keyPressed() {
  if (key == 'a') {
    distanceThreshold+=5;
  } else if (key == 'z') {
    distanceThreshold-=5;
  }
  distanceThreshold = constrain(distanceThreshold, 0, 150);
  if (key == 's') {
    likenessThreshold+=5;
  } else if (key == 'x') {
    likenessThreshold-=5;
  }
  likenessThreshold = constrain(likenessThreshold, 0, 150);
}

void draw() {
  kinectVideo = kinect.getDepthImage();
  image(kinectVideo, 0, 0);

  trackDepth();

  //Show the current likenessThreshold values
  textAlign(RIGHT);
  fill(0);
  textSize(24);
  text("Distance threshold: " + distanceThreshold, width-10, 25);
  text("Likeness threshold: " + likenessThreshold, width-10, 50);
  text("Tracking depth: " + trackDepth, width-10, 75);
}

//Used to calculate distances between points that have 2 dimensions
float distSq(float x1, float y1, float x2, float y2) {
  float d = (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1);
  return d;
}

//Used to calcuate distances between colors that have 3 dimensions
float distSq(float x1, float y1, float z1, float x2, float y2, float z2) {
  float d = (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1) +(z2-z1)*(z2-z1);
  return d;
}

void mousePressed() {
  setDepth();
}

void trackDepth() {

  // Get the raw depth as array of integers
  depth = kinect.getRawDepth();

  ArrayList<Blob> currentBlobs = new ArrayList<Blob>();
  // Begin loop to walk through every pixel
  for (int x = 0; x < kinectVideo.width; x++ ) {
    for (int y = 0; y < kinectVideo.height; y++ ) {
      int loc = x + y * kinectVideo.width;
      // What is current color
      int currentDepth = depth[loc];

      float d = abs(trackDepth - currentDepth); 

      if (d < likenessThreshold*likenessThreshold) {

        boolean found = false;
        for (Blob b : currentBlobs) {
          if (b.isNear(x, y)) {
            b.add(x, y);
            found = true;
            break;
          }
        }

        if (!found) {
          Blob b = new Blob(x, y);
          currentBlobs.add(b);
        }
      }
    }
  }

  for (int i = currentBlobs.size()-1; i >= 0; i--) {
    if (currentBlobs.get(i).size() < 500) {
      currentBlobs.remove(i);
    }
  }

  // There are no blobs!
  if (blobs.isEmpty() && currentBlobs.size() > 0) {
    println("Adding blobs!");
    for (Blob b : currentBlobs) {
      b.id = blobCounter;
      blobs.add(b);
      blobCounter++;
    }
  } else if (blobs.size() <= currentBlobs.size()) {
    // Match whatever blobs you can match

    for (Blob b : blobs) {
      float recordD = 1000;
      Blob matched = null;
      for (Blob cb : currentBlobs) {
        PVector centerB = b.getCenter();
        PVector centerCB = cb.getCenter();         
        float d = PVector.dist(centerB, centerCB);
        if (d < recordD && !cb.taken) {
          recordD = d; 
          matched = cb;
        }
      }
      matched.taken = true;
      b.become(matched);
    }

    // Whatever is leftover make new blobs
    for (Blob b : currentBlobs) {
      if (!b.taken) {
        b.id = blobCounter;
        blobs.add(b);
        blobCounter++;
      }
    }
  } else if (blobs.size() > currentBlobs.size()) {
    for (Blob b : blobs) {
      b.taken = false;
    }


    // Match whatever blobs you can match
    for (Blob cb : currentBlobs) {
      float recordD = 1000;
      Blob matched = null;
      for (Blob b : blobs) {
        PVector centerB = b.getCenter();
        PVector centerCB = cb.getCenter();         
        float d = PVector.dist(centerB, centerCB);
        if (d < recordD && !b.taken) {
          recordD = d; 
          matched = b;
        }
      }
      if (matched != null) {
        matched.taken = true;
        // Resetting the lifespan here is no longer necessary since setting `lifespan = maxLife;` in the become() method in Blob.pde
        // matched.lifespan = maxLife;
        matched.become(cb);
      }
    }

    for (int i = blobs.size() - 1; i >= 0; i--) {
      Blob b = blobs.get(i);
      if (!b.taken) {
        if (b.checkLife()) {
          blobs.remove(i);
        }
      }
    }
  }

  for (Blob b : blobs) {
    b.show();
  }
}

void setDepth() {
  //Record the depth of the point clicked
  int loc = mouseX + mouseY * kinectVideo.width;
  trackDepth = depth[loc];
  println(trackDepth);
  
  
}
