String serialBuffer = "";

void startSerialMode(){
  if(!serialControlMode){
    serialControlMode = true;
    stopPlaying();
    seg[1].setFade(Color(0, 0, 0, RGB_MODE), 1);
  }
}

void checkSerial() {
  while (Serial.available()) {
    char inChar = (char)Serial.read();

    if ( inChar == '\n' || inChar == '\r' ) {
      startSerialMode();
      parseSerialString();
      serialBuffer = "";
    } else {
      serialBuffer += inChar;
    }
  }
}

void parseSerialString() {
  if (serialBuffer.length() < 12) return;

  int values[6];
  int i = 0;
  while(true){
    int indexOfComma = serialBuffer.indexOf(',');
    int val;
    if(indexOfComma==-1) val = serialBuffer.toInt();
    else val = serialBuffer.substring(0,indexOfComma).toInt();

    values[i] = val;
    
    if(indexOfComma==-1) break;
    serialBuffer.remove(0,indexOfComma+1);
    i++;
  }

  seg[2].setStaticColor(Color(values[0],values[1],values[2], RGB_MODE));
  seg[3].setStaticColor(Color(values[3],values[4],values[5], RGB_MODE));
   
}
