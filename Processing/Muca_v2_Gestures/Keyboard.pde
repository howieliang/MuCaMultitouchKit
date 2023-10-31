void keyPressed() {
  if (key == ' ') bCalibed = false;
  if (key == 'r' || key == 'R') { 
    if (bRawImage) bRawImage = false; 
    else bRawImage = true;
  }
  if (key == 'u' || key == 'U') { 
    if (bUniPolar) bUniPolar = false; 
    else bUniPolar = true;
  }
  if (key == 'c' || key == 'C') { 
    if (bShowContext) bShowContext = false; 
    else bShowContext = true;
  }
}
