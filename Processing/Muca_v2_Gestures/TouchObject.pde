class TouchObject{
  int id;
  float x;
  float y;
  boolean updated;
  TouchObject(int _id, float _x, float _y){
    id = _id;
    x = _x;
    y = _y;
    updated = false;
  }
  void setLocation(float _x, float _y){
    x = _x;
    y = _y;
  }
  void setUpdated(boolean b){
    updated = b;
  }
  float getDistance(float x2, float y2){
    return dist(x,y,x2,y2);
  }
  float getDistance(PVector vec){
    return dist(x,y,vec.x,vec.y);
  }
}
