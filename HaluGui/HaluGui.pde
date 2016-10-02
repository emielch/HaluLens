import ddf.minim.*;


Minim minim;
AudioBar audioBar;
ScrollBar scrollBar;
KeyframeBar kfBarLeft;
KeyframeBar kfBarRight;

EyePreview leftEye;
EyePreview rightEye;

ColorPicker colorPicker;

int barsSidesMargin = 150;
int barsBottomMargin = 50;
int audioBarHeight = 80;
int scrollBarHeight = 30;
int kfBarHeight = 40;
int audioBarYpos, kfBarYpos;

int mouseDownX, mouseDownY;
boolean stereoMode = true;

void settings() {
  float winFac = 0.7;
  //size(int(displayWidth*winFac), int(displayHeight*winFac), P3D);
  size(1366, 768, P3D);
  //fullScreen(P3D);
}

void setup() {
  surface.setResizable(true);
  cp5 = new ControlP5(this);
  printArray(Serial.list());
  //if (Serial.list().length>0) {
  //  serialPort = new Serial(this, Serial.list()[0], 9600);
  //}

  int barsWidth = width-barsSidesMargin*2;
  audioBarYpos = height-audioBarHeight-scrollBarHeight-barsBottomMargin;
  kfBarYpos = audioBarYpos-kfBarHeight*2;
  minim = new Minim(this);
  audioBar = new AudioBar(barsWidth, audioBarHeight, barsSidesMargin, audioBarYpos);
  audioBar.loadAudio("AUDIO.WAV");
  scrollBar = new ScrollBar(barsWidth, scrollBarHeight, barsSidesMargin, audioBarYpos+audioBarHeight);
  colorPicker = new ColorPicker(buttonTopMargin, int(buttonSize*1.3)+buttonTopMargin, 500, 250);
  kfBarLeft = new KeyframeBar(barsWidth, kfBarHeight, barsSidesMargin, kfBarYpos, audioBar, colorPicker, 0);
  kfBarRight = new KeyframeBar(barsWidth, kfBarHeight, barsSidesMargin, kfBarYpos+kfBarHeight, audioBar, colorPicker, 1);

  int eyeSize = int((width-colorPicker.w-colorPicker.x-130*2-15)*0.5);
  leftEye = new EyePreview(colorPicker.x+colorPicker.w+130, colorPicker.y, eyeSize, int(eyeSize*0.8), audioBar, kfBarLeft);
  rightEye = new EyePreview(leftEye.x+leftEye.w+30, leftEye.y, leftEye.w, leftEye.h, audioBar, kfBarRight);

  //for (int i=0; i<5; i++) {
  //  KeyFrame newKF = new KeyFrame((int)random(0, 350000), color(random(0, 255), random(0, 255), random(0, 255)), kfBarLeft);
  //  kfBarLeft.addKeyframe(newKF);
  //  newKF = new KeyFrame((int)random(0, 350000), color(random(0, 255), random(0, 255), random(0, 255)), kfBarRight);
  //  kfBarRight.addKeyframe(newKF);
  //}

  setupButtons();
  loadLEDFile("LED.TXT");
}

void draw() {
  if (mousePressed) {
    mouseDragged_nonblocking();
  }

  updateSerial();

  colorMode(RGB, 255);
  background(255);
  audioBar.draw();
  scrollBar.draw();
  kfBarLeft.draw();
  kfBarRight.draw();
  leftEye.draw();
  rightEye.draw();
  colorPicker.draw();

  textSize(40);
  fill(0);
  text(audioBar.getTimeCode(), playPause.getPosition()[0]+playPause.getWidth()+20, playPause.getPosition()[1]+playPause.getHeight());
  textSize(20);
  text(filePath, barsSidesMargin, height-10);
}

void renderKFBackgrounds() {
  Collections.sort(kfBarLeft.keyframes);
  Collections.sort(kfBarRight.keyframes);
  kfBarLeft.renderBackground();
  kfBarRight.renderBackground();
}


void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  if (shiftDown) {
    float center = (scrollBar.start+scrollBar.end)/2;
    if (e>0) scrollBar.move(center+scrollBar.window*0.05, 1);
    else scrollBar.move(center-scrollBar.window*0.05, 1);
    audioBar.zoom(true, scrollBar.start, scrollBar.end);
    kfBarLeft.renderBackground();
    kfBarRight.renderBackground();
  } else {
    if (e>0) zoomOut();
    else zoomIn();
  }
}


void mouseDragged_nonblocking() {
  if (scrollBar.mouseInteract()) {
    audioBar.zoom(false, scrollBar.start, scrollBar.end);
    kfBarLeft.renderBackground();
    kfBarRight.renderBackground();
  }
  if (audioBar.mouseInteract()) {
  }
  if (kfBarLeft.mouseInteraction()) {
    kfBarRight.selectKF();
  }
  if (kfBarRight.mouseInteraction()) {
    kfBarLeft.selectKF();
  }
  colorPicker.mouseInteraction(false);
}

void mousePressed() {
  mouseDownX = mouseX;
  mouseDownY = mouseY;
  if (scrollBar.mousePressed()) {
    audioBar.zoom(false, scrollBar.start, scrollBar.end);
    kfBarLeft.renderBackground();
    kfBarRight.renderBackground();
  }
  if (audioBar.mousePressed()) {
  }
  kfBarLeft.mousePressed();
  kfBarRight.mousePressed();
  colorPicker.mouseInteraction(true);
}

void mouseReleased() {
  scrollBar.mouseReleased();
  audioBar.mouseReleased();
  kfBarLeft.mouseReleased();
  kfBarRight.mouseReleased();
  colorPicker.mouseReleased();
}

boolean ctrlDown = false;
boolean shiftDown = false;
void keyPressed() {
  if (keyCode==CONTROL) ctrlDown = true;
  if (keyCode==SHIFT) shiftDown = true;

  if (key == ' ') {
    togglePlaying();
  } else if (key == DELETE) {
    deleteKF();
  } else if (keyCode == 67 && ctrlDown) {
    copyKF();
  } else if (keyCode == 86 && ctrlDown) {
    pasteKF();
  }
}

void keyReleased() {
  if (keyCode==CONTROL) ctrlDown = false;
  if (keyCode==SHIFT) shiftDown = false;
}