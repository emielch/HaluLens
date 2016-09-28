#include "keyframes.h"

#define PLAYERSAM  2

String readBuffer = "";
char newLineChar = ' '; // 0 undefined; 1 LF '\n'; 2 CR '\r'

LEDPlayer players[PLAYERSAM];


boolean readFiles() {
  readBuffer = readFile("LED.TXT");
  if (!readBuffer.equals("")) {
    KeyFrames keyframes = parseLedFile(readBuffer);
    players[0] = LEDPlayer(&keyframes, &seg[2]);
    players[1] = LEDPlayer(&keyframes, &seg[3]);
  } else {
    readBuffer = readFile("LED1.TXT");
    KeyFrames keyframes1 = parseLedFile(readBuffer);
    if (readBuffer.equals("")) return false;

    readBuffer = readFile("LED2.TXT");
    KeyFrames keyframes2 = parseLedFile(readBuffer);
    if (readBuffer.equals("")) {
      players[0] = LEDPlayer(&keyframes1, &seg[2]);
      players[1] = LEDPlayer(&keyframes1, &seg[3]);
    }else {
      players[0] = LEDPlayer(&keyframes1, &seg[2]);
      players[1] = LEDPlayer(&keyframes2, &seg[3]);
    }
  }
  return true;
}

String readFile(String _fileName) {
  String _readBuffer = "";

  char fileName[_fileName.length() + 1];
  _fileName.toCharArray(fileName, sizeof(fileName));
  File ledFile = SD.open(fileName);

  if (ledFile) {
    // read from the file until there's nothing else in it:
    while (ledFile.available()) {
      char newChar = (char)ledFile.read();
      if (newLineChar == ' ') {
        if (newChar == '\r') newLineChar = '\r';
        else if (newChar == '\n') newLineChar = '\n';
      }
      if (newLineChar == '\n' && newChar == '\r') continue;
      if (newLineChar == '\r' && newChar == '\n') continue;
      if (newChar == ' ') continue;
      _readBuffer += newChar;
    }
    // close the file:
    ledFile.close();
  } else {
    // if the file didn't open, print an error:
    Serial.println("error opening led.txt");
  }
  return _readBuffer;
}

KeyFrames parseLedFile(String readBuffer) {
  KeyFrames keyframes;

  int startLine = 0;
  int cr = 0;
  int i = 0;

  while (cr != -1) {
    cr = readBuffer.indexOf(newLineChar, startLine);
    String line;
    if (cr == -1) line = readBuffer.substring(startLine);
    else line = readBuffer.substring(startLine, cr);

    int startInt = 0;
    int comma = 0;
    int j = 0;
    unsigned long time = 0;
    int r = 0;
    int g = 0;
    int b = 0;

    while (comma != -1) {
      comma = line.indexOf(',', startInt);
      unsigned long num;
      if (comma == -1) num = line.substring(startInt).toInt();
      else num = line.substring(startInt, comma).toInt();

      if (j == 0) time = num;
      else if (j == 1) r = num;
      else if (j == 2) g = num;
      else if (j == 3) b = num;

      startInt = comma + 1;
      j++;
    }

    keyframes.addKeyframe(time, Color(RGB_MODE, r, g, b));


    startLine = cr + 2;
    i++;

    Serial.print("time: ");
    Serial.print(time);
    Serial.print(" R: ");
    Serial.print(r);
    Serial.print(" G: ");
    Serial.print(g);
    Serial.print(" B: ");
    Serial.println(b);
  }

}
