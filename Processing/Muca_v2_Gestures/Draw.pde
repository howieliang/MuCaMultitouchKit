void updateRawImage() {
  bUniPolar = false;
  float c;
  raw.beginDraw();
  for (int i = 0; i < row; i++) {
    for (int j = 0; j < column; j++) {
      int v = data[i][j]-calib[i][j];
      if (bCalibed) {
        if (v>TH_NOISE) {
          c = map(v, 0, threshold+TH_NOISE, 0, 255);
          c = min(max(c, 0), 255);
          raw.stroke(0, c, c);
        } else if (v<-TH_NOISE) {
          raw.stroke(0, 0, 0);
        } else {
          raw.stroke(0, 0, 0);
        }
        raw.point(i, j);
      } else {
        raw.stroke(0, 0, 0);
        raw.point(i, j);
      }
    }
  }
  raw.endDraw();
}

void updateInterpolatedImage() {
  img = raw.get();
  opencv = new OpenCV(this, img);
  Mat mat1 = opencv.getGray(); // get grayscale matrix
  Mat mat2 = new Mat(iF*row, iF*column, mat1.type()); // new matrix to store resize image
  Size sz = new Size(iF*row, iF*column); // size to be resized
  Imgproc.resize(mat1, mat2, sz, 0, 0, Imgproc.INTER_CUBIC); // resize
  opencv.toPImage(mat2, scaledbc); // store in Pimage for drawing later
}

void drawInterpolatedImage() {
  bUniPolar = true;
  image(scaledbc, 0, 0);
}

void drawGestureType(float scale, float rotation, PVector translation) {
  pushStyle();
  fill(0, 255, 0);
  textSize(textSizeM);
  String lastGestureInfo =" scaled " + nf(scale, 1, 1) + " pxs" +
    "\n rotated " + nf(degrees(rotation), 1, 2) + " degrees" +
    "\n translated (X: " + nf(translation.x, 1, 1) + ", Y:" + nf(translation.y, 1, 1) + ") pxs";
  text("last gesture:\n"+ lastGestureInfo, 0, height/3);
  text("Can be recognized as:", 0, textSizeL+height/2);
  if (scale>TH_S) { 
    text("[spreaded]", 0, 2*textSizeL+height/2);
    myPort.write('a');
  }
  if (scale<-TH_S) { 
    text("[pinched]", 0, 2*textSizeL+height/2);
    myPort.write('b');
  }
  if (degrees(rotation)>TH_R) { 
    text("[turned right]", 0, 3*textSizeL+height/2);
  }
  if (degrees(rotation)<-TH_R) { 
    text("[turned left]", 0, 3*textSizeL+height/2);
  }
  if (translation.x>TH_T) { 
    text("[swiped right]", 0, 4*textSizeL+height/2);
  }
  if (translation.x<-TH_T) { 
    text("[swiped left]", 0, 4*textSizeL+height/2);
  }
  if (translation.y>TH_T) { 
    text("[swiped down]", 0, 5*textSizeL+height/2);
  }
  if (translation.y<-TH_T) { 
    text("[swiped up]", 0, 5*textSizeL+height/2);
  }
  if (gestureType==UNDEFINED && lastGestureInfo != "" && numFingers>0) {
    text("[tapped with "+numFingers+" fingers]", 0, 6*textSizeL+height/2);
  }
  popStyle();
}

void updateMetrics() {
  int numOfBlobs = tm.getNumberOfBlobs();
  if (numOfBlobs<=1) {
    if (bEngaged) bEngaged = false;
  } else if (numOfBlobs>1) {
    d = tm.getDistanceBetween(tm.idOnStage.get(0), tm.idOnStage.get(1));
    theta = tm.getAngleBetween(tm.idOnStage.get(0), tm.idOnStage.get(1));
    m = tm.getCentroidBetween(tm.idOnStage.get(0), tm.idOnStage.get(1));
    if (!bEngaged) {
      d0=d;
      theta0=theta;
      m0=new PVector(m.x, m.y);
      bEngaged = true;
      gestureType = UNDEFINED;
      numFingers = tm.getNumberOfBlobs();
      gesturePerformed = true;
    } else {
      scale = d-d0;
      rotation = theta-theta0;
      translation = PVector.sub(m, m0);
      if (tm.getNumberOfBlobs()>numFingers) numFingers = tm.getNumberOfBlobs();
      if (gestureType==UNDEFINED) {
        if (scale>TH_S || scale<-TH_S) { 
          gestureType = SCALING;
        }
        if (degrees(rotation)>TH_R || degrees(rotation)<-TH_R) { 
          gestureType = ROTATION;
        }
        if (translation.x>TH_T || translation.x<-TH_T || translation.y>TH_T || translation.y<-TH_T) { 
          gestureType = TRANSLATION;
        }
      }
    }
  }
}

void drawInfoText(float x, float y) {
  String info = "[Thresholds > Movement]\n d =" + d +
    "\n theta =" + theta +
    "\n midpoint =(" + m.x + "," + m.y + ")" +
    "\n scale =" + nf(scale, 1, 1) +
    "\n rotation =" + nf(degrees(rotation), 1, 2) +
    "\n translation = (X: " + nf(translation.x, 1, 1) + ", Y:" + nf(translation.y, 1, 1) + ")";
  if (gestureType!=UNDEFINED) {
    info ="[Movement > Thresholds]\n scale = " + nf(scale, 1, 1) + " pixels \n"+ 
      "rotation = " + nf(degrees(rotation), 1, 2) + " degrees \n" +
      "translation = (X: " + nf(translation.x, 1, 1) + ", Y:" + nf(translation.y, 1, 1) + ") pixels";
  }
  pushStyle();
  fill(0, 255, 0);
  textSize(textSizeM);
  text(info, x, y);
  rectMode(CENTER);
  noFill();
  popStyle();
}

void drawGestureProxy(float x, float y, float d, float theta) {
  pushStyle();
  pushMatrix();
  translate(x, y);
  rotate(theta);
  noFill();
  stroke(0, 255, 0);
  ellipse(0, 0, d, d);
  noStroke();
  fill(0, 255, 0);
  rectMode(CENTER);
  rect(0, d/4, 10, d/2);
  popMatrix();
  popStyle();
}

void updateBlobsAndTouchManager() {
  opencv2 = new OpenCV(this, scaledbc);
  opencv2.threshold(TH_NOISE);
  contours = opencv2.findContours();
  rects = new ArrayList<Rectangle>();
  vecs.clear();
  for (Contour contour : contours) {
    rects.add(contour.getBoundingBox());
  }
  for (Rectangle r : rects) {
    vecs.add(new PVector(r.x+r.width/2, r.y+r.height/2));
  }
  tm.update(vecs);
}

void drawBlobs() {
  for (Contour contour : contours) {
    stroke(0, 255, 0);
    noFill();
    contour.draw();
  }
  for (Rectangle r : rects) {
    stroke(255, 0, 0);
    noFill();
    rect(r.x, r.y, r.width, r.height);
    fill(255);
    noStroke();
    ellipse(r.x+r.width/2, r.y+r.height/2, 5, 5);
  }
}

void drawCalibedImage() {
  float c;
  pg.beginDraw();
  for (int i = 0; i < row; i++) {
    for (int j = 0; j < column; j++) {
      int v = data[i][j]-calib[i][j];
      float x = pxW*i;
      float y = pxH*j;
      pg.noStroke();
      if (bCalibed) {
        if (v>TH_NOISE) {
          c = map(v, 0, threshold+TH_NOISE, 0, 255);
          c = min(max(c, 0), 255);
          pg.fill(0, c, c);
        } else if (v<-TH_NOISE) {
          c = map(v, 0, -threshold-TH_NOISE, 0, 255);
          c = min(max(c, 0), 255);
          if (!bUniPolar) pg.fill(c, 0, 0);
          else pg.fill(0, 0, 0);
        } else {
          pg.fill(0, 0, 0);
        }
        pg.rect(x, y, pxW, pxH);
        pg.fill(255);
        pg.text(v, x+10, y+30);
      }
    }
  }
  pg.endDraw();
  image(pg, 0, 0);
}

void drawBackgroundImage() {
  float c;
  pg.beginDraw();
  for (int i = 0; i < row; i++) {
    for (int j = 0; j < column; j++) {
      int v = calib[i][j];
      float x = pxW*i;
      float y = pxH*j;
      pg.noStroke();
      if (bCalibed) {
        if (v>TH_NOISE) {
          c = map(v, 0, threshold+TH_NOISE, 0, 255);
          c = min(max(c, 0), 255);
          pg.fill(0, c, c);
        } else if (v<-TH_NOISE) {
          c = map(v, 0, -threshold-TH_NOISE, 0, 255);
          c = min(max(c, 0), 255);
          if (!bUniPolar) pg.fill(c, 0, 0);
          else pg.fill(0, 0, 0);
        } else {
          pg.fill(0, 0, 0);
        }
        pg.rect(x, y, pxW, pxH);
        pg.fill(255);
        pg.text(v, x+10, y+30);
      }
    }
  }
  pg.endDraw();
  image(pg, 0, 0);
}
