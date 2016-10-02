import processing.serial.*;

Serial serialPort;       

void updateSerial() {
  colorMode(RGB,255);
  
  serialPort.write(str(red(leftEye.col)));
  serialPort.write(',');
  serialPort.write(str(green(leftEye.col)));
  serialPort.write(',');
  serialPort.write(str(blue(leftEye.col)));
  serialPort.write(',');
  serialPort.write(str(red(rightEye.col)));
  serialPort.write(',');
  serialPort.write(str(green(rightEye.col)));
  serialPort.write(',');
  serialPort.write(str(blue(rightEye.col)));
  serialPort.write("\r\n");
}