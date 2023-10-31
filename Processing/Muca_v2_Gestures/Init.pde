void initSerial() {
  for (int i = 0; i < Serial.list().length; i++) println("[", i, "]:", Serial.list()[i]);
  String portName = Serial.list()[Serial.list().length-1];
  myPort = new Serial(this, portName, 115200);
  myPort.bufferUntil('\n');
  myPort.clear();
}

void initParam() {
  pg = createGraphics(iF*row, iF*column);  //Initiate image
  raw = createGraphics(row, column);  //Initiate image
  pxW = (float)iF;
  pxH = (float)iF;
  rawData = new int[paraNum];
  data = new int[row][column];
  calib = new int[row][column];
  img = new PImage(iF*row, iF*column);
  background = new PImage(iF*row, iF*column);
  scaledbc = new PImage(iF*row, iF*column);
  tm = new TouchManager();
  vecs = new ArrayList<PVector>();
}
