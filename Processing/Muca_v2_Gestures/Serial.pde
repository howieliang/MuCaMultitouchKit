void serialEvent(Serial myPort) {
  String inData = myPort.readStringUntil('\n');
  int[] sensorValue_list = int(inData.trim().split(","));
  if (sensorValue_list.length == paraNum)   
  {
    rawData = sensorValue_list;
    boolean bSkipped = false;
    for (int i = 0; i < row; i++) {
      bSkipped = false;
      for (int n=0; n<skippedRows.length; n++) {
        if (i == skippedRows[n]) bSkipped = true;
      }
      for (int j = 0; j < column; j++) {
        boolean bSkipped2 = false;
        for (int n=0; n<skippedCols.length; n++) {
          if (j == skippedCols[n]) bSkipped2 = true;
        }
         if(!bSkipped && !bSkipped2){ 
          if(!vFlipped && !hFlipped) data[i][j] = rawData[row*j+i];
          if(!vFlipped && hFlipped) data[i][j] = rawData[row*j+(row-i-1)];
          if(vFlipped && !hFlipped) data[i][j] = rawData[row*(column-j-1)+i];
          if(vFlipped && hFlipped) data[i][j] = rawData[row*(column-j-1)+(row-i-1)];
        }
        if (!bCalibed) calib[i][j] = data[i][j];
      }
    }
    if (!bCalibed) bCalibed = true;
  }
  return;
}
