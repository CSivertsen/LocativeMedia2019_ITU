/*
This program extends the face tracking functionality from the KNN face classification example by Andreas Refsgaard by adding the opportunity to save KNN model data to local storage.
Source: https://andreasref.github.io/ml5js/

This example is written by Christian Sivertsen for the course Locative Media Spring 2019 at the IT University of Copenhagen
*/

var k = 5; //k can be any integer
var machine = new kNear(k);

var currentClass = 0;

var nSamples = 0;

var normalized = [];

var w = 640 * 1.5,
  h = 480 * 1.5;

var faceData;
var savedModel;

function setup() {
  //capture = createCapture(VIDEO);
  var brfv4canvas = createCanvas(w,h);
  brfv4canvas.id('_imageData');
  brfv4canvas.parent('canvas-parent');
  savedModel = JSON.parse(localStorage.savedModel);
  if (savedModel != null){
    machine.setModel(savedModel); //Load latest KNN model
    console.log("Loaded model");
  }

}

function processFaceData() {
    for(var i = 0; i < faceData.length; i++) {
      var face = faceData[i];
      var numVertices = face.vertices.length;
      var vertices = face.vertices;

      // draw face data
      fill('#ff0000');
      for (var i = 0; i < numVertices; i += 2) {
          ellipse(vertices[i], vertices[i+1], 5, 5);
      }

      // get max and min vertex positions
      var minX = width;
      var minY = height;
      var maxX = 0;
      var maxY = 0;

      for (var i = 0; i < numVertices; i += 2) {
          //ellipse(vertices[i], vertices[i+1], 2, 2);
          if (vertices[i] < minX) {
              minX = vertices[i];
          } if (vertices[i] > maxX) {
              maxX = vertices[i];
          } if (vertices[i+1] < minY) {
              minY = vertices[i+1];
          } if (vertices[i+1] > maxY) {
              maxY = vertices[i+1];
          }
      }

      // calculate normalized vertex positions and store them in an array
      normalized = [];
      for (var i = 0; i < numVertices; i += 2) {
          normalized.push((vertices[i] - minX) / (maxX-minX));
          normalized.push((vertices[i+1] - minY) / (maxY-minY));
      }

    }
}

function drawCanvasInstructions() {
    if (mouseIsPressed) {
        machine.learn(normalized, currentClass);
        saveOurData(); //Every time the model is updated it is saved to local storage
        nSamples++;
        fill(255, 0, 0);
        noStroke();
        ellipse(w - 380, 25, 25, 25);
    } else if (nSamples >0)  {
        fill(0,255,0);
        test = machine.classify(normalized);
        textSize(126);
        text(test, w/2, h/2);
    }

    noStroke();
    fill('#fff');
    textSize(18);
    text("press [0-9] to change current class --- hold mouse to record samples", 10, 35);
    textSize(18);
    text("trainingClass: " + currentClass, 10, 75);
    text(" nSamples: " + nSamples, w - 550, 75);
}

// override function to process brfv4 data
handleTrackingResults = function(
    brfv4,          // namespace
    faces,          // tracked faces
    imageDataCtx    // canvas context to draw into
    )
{
    faceData = faces;
    processFaceData();
    drawCanvasInstructions();

};

function keyPressed() {
  if (key == '0') {
    currentClass = 0;
  } else if (key == '1') {
    currentClass = 1;
  } else if (key == '2') {
    currentClass = 2;
  } else if (key == '3') {
    currentClass = 3;
  } else if (key == '4') {
    currentClass = 4;
  } else if (key == '5') {
    currentClass = 5;
  } else if (key == '6') {
    currentClass = 6;
  } else if (key == '7') {
    currentClass = 7;
  } else if (key == '8') {
    currentClass = 8;
  } else if (key == '9') {
    currentClass = 9;
  } else if (key == 'c' || key == 'C') {
    clearOurData(); //Watch out! Pressing C will clear the stored data
  }
}

// Store your data.
function saveOurData() {
    localStorage.savedModel = JSON.stringify(machine.getModel()); //Get the model of the current machine and save it in JSON format to localStorage
    console.log("Saved data");
}

// Clear your data
function clearOurData() {
    savedModel = null;
    localStorage.savedModel = JSON.stringify(savedModel); //Overwrites the currently saved model with null
    console.log("Cleared data");
}
