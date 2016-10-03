import controlP5.*;

ControlP5 cp5;



Toggle stereoToggle;
Button playPause;

PImage play_n, play_h, play_p, pause_n, pause_h, pause_p;
int buttonSize = 100;
int buttonTopMargin = 20;

void setupButtons() {
  PImage bin_n = loadImage("buttons/bin_normal.png");
  PImage bin_h = loadImage("buttons/bin_hover.png");
  PImage bin_p = loadImage("buttons/bin_press.png");
  PImage open_n = loadImage("buttons/open_normal.png");
  PImage open_h = loadImage("buttons/open_hover.png");
  PImage open_p = loadImage("buttons/open_press.png");
  PImage save_n = loadImage("buttons/save_normal.png");
  PImage save_h = loadImage("buttons/save_hover.png");
  PImage save_p = loadImage("buttons/save_press.png");
  PImage copy_n = loadImage("buttons/copy_normal.png");
  PImage copy_h = loadImage("buttons/copy_hover.png");
  PImage copy_p = loadImage("buttons/copy_press.png");
  PImage paste_n = loadImage("buttons/paste_normal.png");
  PImage paste_h = loadImage("buttons/paste_hover.png");
  PImage paste_p = loadImage("buttons/paste_press.png");
  PImage audio_n = loadImage("buttons/audio_normal.png");
  PImage audio_h = loadImage("buttons/audio_hover.png");
  PImage audio_p = loadImage("buttons/audio_press.png");

  PImage zoomin_n = loadImage("buttons/zoomin_normal.png");
  PImage zoomin_h = loadImage("buttons/zoomin_hover.png");
  PImage zoomin_p = loadImage("buttons/zoomin_press.png");
  PImage zoomout_n = loadImage("buttons/zoomout_normal.png");
  PImage zoomout_h = loadImage("buttons/zoomout_hover.png");
  PImage zoomout_p = loadImage("buttons/zoomout_press.png");

  PImage mono = loadImage("buttons/mono.png");
  PImage stereo = loadImage("buttons/stereo.png");

  play_n = loadImage("buttons/play_normal.png");
  play_h = loadImage("buttons/play_hover.png");
  play_p = loadImage("buttons/play_press.png");
  pause_n = loadImage("buttons/pause_normal.png");
  pause_h = loadImage("buttons/pause_hover.png");
  pause_p = loadImage("buttons/pause_press.png");

  int editorButtonsY = kfBarYpos - 110;
  int buttonsXOffset = barsSidesMargin+10;  


  playPause = cp5.addButton("togglePlaying")
    .setPosition(buttonsXOffset, editorButtonsY)
    .setImages(play_n, play_h, play_p)
    .updateSize()
    ;

  buttonsXOffset += buttonSize*4;
  cp5.addButton("copyKF")
    .setPosition(buttonsXOffset, editorButtonsY)
    .setImages(copy_n, copy_h, copy_p)
    .updateSize()
    ;

  buttonsXOffset += buttonSize*1.1;
  cp5.addButton("pasteKF")
    .setPosition(buttonsXOffset, editorButtonsY)
    .setImages(paste_n, paste_h, paste_p)
    .updateSize()
    ;

  buttonsXOffset += buttonSize*2;
  cp5.addButton("deleteKF")
    .setPosition(buttonsXOffset, editorButtonsY)
    .setImages(bin_n, bin_h, bin_p)
    .updateSize()
    ;

  buttonsXOffset = 20;
  cp5.addButton("selectFile")
    .setPosition(buttonsXOffset, buttonTopMargin)
    .setImages(open_n, open_h, open_p)
    .updateSize()
    ;

  buttonsXOffset += buttonSize*1.1;
  cp5.addButton("saveFile")
    .setPosition(buttonsXOffset, buttonTopMargin)
    .setImages(save_n, save_h, save_p)
    .updateSize()
    ;

  buttonsXOffset += buttonSize*2.2;
  stereoToggle = cp5.addToggle("stereoToggle")
    .setPosition(buttonsXOffset, buttonTopMargin)
    .setImages(mono, stereo)
    .updateSize()
    .setState(true)
    ;
    
  cp5.addButton("exit")
    .setPosition(width-100-buttonTopMargin, buttonTopMargin)
    .setSize(100,100);
    ;

  cp5.addButton("selectAudioFile")
    .setPosition(audioBar.x+audioBar.w+(barsSidesMargin-audio_n.width)/2, scrollBar.y+scrollBar.h-audio_n.width)
    .setImages(audio_n, audio_h, audio_p)
    .updateSize()
    ;

  float buttonScale = 0.8;
  int h = (audioBar.h+scrollBar.h)/2;

  zoomin_n.resize(int(h * buttonScale), 0);
  zoomin_h.resize(int(h * buttonScale), 0);
  zoomin_p.resize(int(h * buttonScale), 0);
  zoomout_n.resize(int(h * buttonScale), 0);
  zoomout_h.resize(int(h * buttonScale), 0);
  zoomout_p.resize(int(h * buttonScale), 0);

  cp5.addButton("zoomIn")
    .setPosition(audioBar.x-h+int(h*(1-buttonScale)/2), audioBar.y+int(h*(1-buttonScale)))
    .setImages(zoomin_n, zoomin_h, zoomin_p)
    .updateSize()
    ;

  cp5.addButton("zoomOut")
    .setPosition(audioBar.x-h+int(h*(1-buttonScale)/2), audioBar.y+h-int(h*(1-buttonScale)/2))
    .setImages(zoomout_n, zoomout_h, zoomout_p)
    .updateSize()
    ;
    
  cp5.addScrollableList("Serial_List")
     .setPosition(leftEye.x, buttonTopMargin)
     .setSize(200, 100)
     .setBarHeight(20)
     .setItemHeight(20)
     .addItems(Serial.list())
     // .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
     ;
}

void deleteKF() {
  for (int i=0; i<selectedKF.size(); i++) {
    KeyFrame kf = selectedKF.get(i);
    kf.kfBar.keyframes.remove(kf);
  }
  selectedKF.clear();
  colorPicker.clearKF();
  kfBarLeft.setRenderBG();
  kfBarRight.setRenderBG();
}

void selectFile() {
  selectInput("Select a file to open:", "openFile");
}

void selectAudioFile() {
  selectInput("Select an audio file:", "openAudioFile");
}

void copyKF() {
  clipboard = new ArrayList<KeyFrame>(selectedKF);
  Collections.sort(clipboard);
}

void pasteKF() {
  if (clipboard.size()==0) return;
  if (selectedKFBar==null) return;
  selectedKFBar.clearSelectedKF();
  int startTime = clipboard.get(0).time;
  int cursorTime = audioBar.getPos();

  for (int i=0; i<clipboard.size(); i++) {

    int time = clipboard.get(i).time - startTime + cursorTime;
    if (time>audioBar.getLength()) break;
    KeyFrame kf = new KeyFrame(time, clipboard.get(i).col, selectedKFBar);
    selectedKFBar.addKeyframe(kf);
    selectedKFBar.addSelectedKF(kf);
  }
}

void togglePlaying() {
  if (audioBar.isPlaying()) {
    audioBar.pause();
  } else {
    audioBar.play();
  }
}

void stereoToggle(boolean theFlag) {
  kfBarLeft.clearSelectedKF();
  if (theFlag==true) {
    kfBarRight.show();
    stereoMode = true;
    rightEye.setKFBar(kfBarRight);
  } else {
    kfBarRight.hide();
    stereoMode = false;
    rightEye.setKFBar(kfBarLeft);
  }
}

void zoomIn() {
  scrollBar.move(audioBar.getCursor(), 1.5);
  audioBar.zoom(true, scrollBar.start, scrollBar.end);
  kfBarLeft.setRenderBG();
  kfBarRight.setRenderBG();
}

void zoomOut() {
  scrollBar.move(audioBar.getCursor(), 0.66);
  audioBar.zoom(true, scrollBar.start, scrollBar.end);
  kfBarLeft.setRenderBG();
  kfBarRight.setRenderBG();
}

void Serial_List(int n) {
  String portName = cp5.get(ScrollableList.class, "Serial_List").getItem(n).get("name").toString();
  println("selected port: ", portName);

  CColor c = new CColor();
  c.setBackground(color(255, 0, 0));
  cp5.get(ScrollableList.class, "Serial_List").getItem(n).put("color", c);
  
  if(serialPort!=null) serialPort.stop();
  serialPort = new Serial(this, portName, 9600);
}