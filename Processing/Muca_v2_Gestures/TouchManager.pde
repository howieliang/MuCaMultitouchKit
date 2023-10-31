class TouchManager {
  ArrayList<TouchObject> touches;
  final float INF = 9999999;
  final int MAX_IDNUM = 10;
  boolean[] idTable;
  ArrayList<Integer> idOnStage = new ArrayList<Integer>();
  TouchManager() {
    touches = new ArrayList<TouchObject>();
    idTable = new boolean[MAX_IDNUM];
    for (int i=0; i<idTable.length; i++) {
      idTable[i] = false;
    }
  }

  TouchObject getTouchObjectByID(int id) {
    int index = -1;
    for (int i=0; i<touches.size(); i++) {
      TouchObject to = touches.get(i);
      if (to.id == id) { 
        index = i;
        break;
      }
    }
    return touches.get(index);
  }
  int getNumberOfBlobs() {
    return tm.touches.size();
  }

  float getDistanceBetween(int i1, int i2) {
    TouchObject to1 = getTouchObjectByID(i1);
    TouchObject to2 = getTouchObjectByID(i2);
    PVector p1 = new PVector(to1.x, to1.y);
    PVector p2 = new PVector(to2.x, to2.y);
    return dist(p1.x, p1.y, p2.x, p2.y);
  }

  float getAngleBetween(int i1, int i2) {
    TouchObject to1 = getTouchObjectByID(i1);
    TouchObject to2 = getTouchObjectByID(i2);
    PVector p1 = new PVector(to1.x, to1.y);
    PVector p2 = new PVector(to2.x, to2.y);
    return atan2(p2.y-p1.y, p2.x-p1.x);
  }

  PVector getCentroidBetween(int i1, int i2) {
    TouchObject to1 = getTouchObjectByID(i1);
    TouchObject to2 = getTouchObjectByID(i2);
    PVector p1 = new PVector(to1.x, to1.y);
    PVector p2 = new PVector(to2.x, to2.y);
    return PVector.add(p1, p2).div(2);
  }

  int getMinID() {
    int id = -1;
    for (int i=0; i<idTable.length; i++) {
      if (!idTable[i]) {
        id=i; 
        break;
      }
    }
    return id;
  }
  
  void draw() {
    pushStyle();
    fill(0, 255, 0);
    for (TouchObject to : touches) {
      textAlign(RIGHT, BOTTOM);
      text(to.id, to.x, to.y);
    }
    popStyle();
  }

  void update(ArrayList<PVector> vecs) {
    for (TouchObject to : touches) {
      to.setUpdated(false);
    }
    if (vecs.size() == touches.size()) { //no add or remove
      //update the nearest neighbors
      for (PVector v : vecs) {
        int index = -1;
        float minDist = INF;
        for (int i = 0; i < touches.size(); i++) {
          TouchObject to = touches.get(i);
          if (to.updated == false && to.getDistance(v)<minDist) {
            minDist = to.getDistance(v);
            index = i;
          }
        }
        TouchObject to = touches.get(index);
        to.setLocation(v.x, v.y);
        to.setUpdated(true);
      }
    }

    if (vecs.size() > touches.size()) { //add
      ArrayList<PVector> temp = new ArrayList<PVector>();
      for (PVector v : vecs) {
        temp.add(v);
      }
      for (int i = 0; i < touches.size(); i++) {
        TouchObject to = touches.get(i);
        int index = -1;
        float minDist = INF;
        for (int j = 0; j < temp.size(); j++) {
          PVector v = temp.get(j);
          if (to.getDistance(v)<minDist) {
            minDist = to.getDistance(v);
            index = j;
          }
        }
        PVector v = temp.get(index);
        to.setLocation(v.x, v.y);
        to.setUpdated(true);
        temp.remove(index);
      }
      for (PVector v : temp) {
        int id = getMinID();
        touches.add(new TouchObject(id, v.x, v.y));
        idTable[id]=true;
        idOnStage.add(id);
      }
    }

    if (vecs.size() < touches.size()) { //remove
      //update the nearest neighbors
      for (PVector v : vecs) {
        int index = -1;
        float minDist = INF;
        for (int i = 0; i < touches.size(); i++) {
          TouchObject to = touches.get(i);
          if (to.updated == false && to.getDistance(v)<minDist) {
            minDist = to.getDistance(v);
            index = i;
          }
        }
        TouchObject to = touches.get(index);
        to.setLocation(v.x, v.y);
        to.setUpdated(true);
      }
      //remove the un-updated ones
      for (int i = touches.size()-1; i>=0; i--) {
        TouchObject to = touches.get(i);
        if (!to.updated) {
          idTable[to.id]=false;
          for (int j = idOnStage.size()-1; j>=0; j--) {
            if (idOnStage.get(j) == to.id) idOnStage.remove(j);
          }
          touches.remove(i);
        }
      }
    }
  }
}
