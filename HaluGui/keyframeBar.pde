import java.util.*;
ArrayList<KeyFrame> selectedKF = new ArrayList<KeyFrame>();
ArrayList<KeyFrame> clipboard = new ArrayList<KeyFrame>();

KeyframeBar selectedKFBar;


class KeyframeBar {
  int id;
  int w, h, x, y;

  int kfW = 7;
  float buttonScale = 0.8;

  ArrayList<KeyFrame> keyframes = new ArrayList<KeyFrame>();
  ArrayList<Button> buttons = new ArrayList<Button>();

  boolean mouseDown = false;
  boolean mouseDownOnKF = false;
  int mousePrevX;

  PGraphics bg;

  AudioBar audioBar;
  ColorPicker colorPicker;

  boolean show = true;
  PImage next_n = loadImage("buttons/next_normal.png");
  PImage next_h = loadImage("buttons/next_hover.png");
  PImage next_p = loadImage("buttons/next_press.png");
  PImage prev_n = loadImage("buttons/prev_normal.png");
  PImage prev_h = loadImage("buttons/prev_hover.png");
  PImage prev_p = loadImage("buttons/prev_press.png");
  PImage plus_n = loadImage("buttons/plus_normal.png");
  PImage plus_h = loadImage("buttons/plus_hover.png");
  PImage plus_p = loadImage("buttons/plus_press.png");

  KeyframeBar(int _w, int _h, int _x, int _y, AudioBar _ab, ColorPicker _cp, int _id) {
    id = _id;
    w = _w;
    h = _h;
    x = _x;
    y = _y;

    audioBar = _ab;
    colorPicker = _cp;

    next_n.resize(int(h*buttonScale), 0);
    next_h.resize(int(h*buttonScale), 0);
    next_p.resize(int(h*buttonScale), 0);
    prev_n.resize(int(h*buttonScale), 0);
    prev_h.resize(int(h*buttonScale), 0);
    prev_p.resize(int(h*buttonScale), 0);
    plus_n.resize(int(h*buttonScale), 0);
    plus_h.resize(int(h*buttonScale), 0);
    plus_p.resize(int(h*buttonScale), 0);


    buttons.add(cp5.addButton("addKF:"+id)
      .setPosition(x-h+int(h*(1-buttonScale)/2), y+int(h*(1-buttonScale)/2))
      .setImages(plus_n, plus_h, plus_p)
      .updateSize()
      .addCallback(new CallbackListener() {
      void controlEvent(CallbackEvent theEvent) {
        if (theEvent.getAction() == ControlP5.ACTION_BROADCAST) {
          createKF();
        }
      }
    }
    ));

    buttons.add(cp5.addButton("prevKF:"+id)
      .setPosition(x+w+int(h*(1-buttonScale)/2), y+int(h*(1-buttonScale)/2))
      .setImages(prev_n, prev_h, prev_p)
      .updateSize()
      .addCallback(new CallbackListener() {
      void controlEvent(CallbackEvent theEvent) {
        if (theEvent.getAction() == ControlP5.ACTION_BROADCAST) {
          moveToKF(false);
        }
      }
    }
    ));

    buttons.add(cp5.addButton("nextKF:"+id)
      .setPosition(x+w+h, y+int(h*(1-buttonScale)/2))
      .setImages(next_n, next_h, next_p)
      .updateSize()
      .addCallback(new CallbackListener() {
      void controlEvent(CallbackEvent theEvent) {
        if (theEvent.getAction() == ControlP5.ACTION_BROADCAST) {
          moveToKF(true);
        }
      }
    }
    ));

    renderBackground();
  }

  void draw() {
    if (!show) return;
    image(bg, x, y);
    rectMode(CENTER);

    for (int i=0; i<keyframes.size(); i++) {
      KeyFrame kf = keyframes.get(i);
      float posx = audioBar.getFacPosInWindow(kf.time)*w+x;

      if (!(posx<x || posx>x+w)) {
        stroke(0);
        strokeWeight(2);
        if (kf.isSelected) fill(255);
        else fill(150);
        rect(posx, y+h/2, kfW, h-6);
      }
    }

    float posx = audioBar.getFacPosInWindow(audioBar.getPos())*w+x;
    if (!(posx<x || posx>x+w)) {
      stroke(150, 150, 150);
      strokeWeight(2);
      line(posx, y, posx, y+h);
    }

    if (mouseDown && !mouseDownOnKF) {
      rectMode(CORNERS);
      noFill();
      stroke(0);
      strokeWeight(1);
      rect(mouseDownX, mouseDownY, mouseX, mouseY);
    }

    rectMode(CORNER);
    noFill();
    if (this == selectedKFBar) stroke(200, 0, 0);
    else stroke(100);
    strokeWeight(2);
    rect(x+1, y+1, w-2, h-2);
  }

  void hide() {
    show = false;
    for (int i=0; i<buttons.size(); i++) {
      buttons.get(i).hide();
    }
  }

  void show() {
    show = true;
    for (int i=0; i<buttons.size(); i++) {
      buttons.get(i).show();
    }
  }

  void moveToKF(boolean right) {
    if (!show) return;
    if (keyframes.isEmpty()) return;
    int currTime = audioBar.getPos();
    KeyFrame kf = keyframes.get(0);
    if (right) {
      for (int i=0; i<keyframes.size(); i++) {
        kf = keyframes.get(i);
        if (kf.time>currTime) {
          break;
        }
      }
    } else {
      for (int i=keyframes.size()-1; i>=0; i--) {
        kf = keyframes.get(i);
        if (kf.time<currTime) {
          break;
        }
      }
    }
    audioBar.setPos(kf.time);
    clearSelectedKF();
    addSelectedKF(kf);
  }

  void addKeyframe(KeyFrame kf) {
    if (!show) return;
    keyframes.add(kf);
    Collections.sort(keyframes);
    renderBackground();
  }

  void createKF() {
    colorMode(RGB, 255);
    if (!show) return;
    int currPos = audioBar.getPos();
    color col = getColorAt(currPos, keyframes);
    KeyFrame newKF = new KeyFrame(audioBar.getPos(), col, this);

    addKeyframe(newKF);
    clearSelectedKF();
    addSelectedKF(newKF);
  }


  void renderBackground() {
    if (!show) return;
    colorMode(RGB, 255);
    bg = createGraphics(w, h);
    bg.beginDraw();
    bg.background(0);

    KeyFrame prevKF = new KeyFrame(-1);
    KeyFrame nextKF = new KeyFrame(0);
    int kfID = 0;
    for (int i=0; i<w; i+=3) {
      float currPos = map(i, 0, w, audioBar.getLength()*audioBar.start, audioBar.getLength()*audioBar.end);
      while (currPos>nextKF.time && kfID<keyframes.size()) {
        prevKF = nextKF;
        nextKF = keyframes.get(kfID);
        kfID++;
      }
      float lerpFac = constrain(map(currPos, prevKF.time, nextKF.time, 0, 1), 0, 1);
      color lerpCol = lerpColor(prevKF.col, nextKF.col, lerpFac);
      bg.stroke(lerpCol);
      bg.strokeWeight(3);
      bg.line(i, 0, i, h);
    }

    bg.endDraw();
  }

  void clearSelectedKF() {
    for (int i=0; i<selectedKF.size(); i++) {
      selectedKF.get(i).isSelected = false;
    }
    selectedKF.clear();
    colorPicker.clearKF();
  }

  void addSelectedKF(KeyFrame kf) {
    selectedKF.add(kf);
    kf.isSelected = true;
    if (selectedKF.size()==1) colorPicker.setKF(kf, this);
    else colorPicker.clearKF();
  }

  boolean getMouseOnKF() {
    if (!show) return false;
    for (int i=0; i<keyframes.size(); i++) {
      KeyFrame kf = keyframes.get(i);
      float posx = audioBar.getFacPosInWindow(kf.time)*w+x;

      int clickMargin = 4;
      int sides = kfW/2+clickMargin;
      if (mouseX>posx-sides && mouseX<posx+sides && mouseY>y && mouseY<y+h) {
        if (!kf.isSelected) {
          clearSelectedKF();
          addSelectedKF(kf);
        }
        //audioBar.player.cue(kf.time);
        return true;
      }
    }
    if (mouseY>y && mouseY<y+h) {
      clearSelectedKF();
    }
    return false;
  }

  boolean mousePressed() {
    if (!show) return false;
    if (mouseX>x && mouseX<x+w && mouseY>y && mouseY<y+h) {
      mouseDown = true;
      selectedKFBar = this;
      mouseDownOnKF = getMouseOnKF();
      mousePrevX = mouseX;
      return true;
    }
    return false;
  }

  void mouseReleased() {
    mouseDown = false;
    mouseDownOnKF = false;
  }

  void selectKF() {
    if (!show) return;
    if (!( (mouseDownY>y && mouseDownY<y+h) || (mouseDownY<y && mouseY>y) || (mouseDownY>y+h && mouseY<y+h) )) return;
    int selStart = (int)map(min(mouseDownX, mouseX), x, x+w, audioBar.getLength()*audioBar.start, audioBar.getLength()*audioBar.end);
    int selStop = (int)map(max(mouseDownX, mouseX), x, x+w, audioBar.getLength()*audioBar.start, audioBar.getLength()*audioBar.end);
    for (int i=0; i<keyframes.size(); i++) {
      KeyFrame kf = keyframes.get(i);
      if (kf.time>selStart) {
        if (kf.time<selStop) {
          addSelectedKF(kf);
        } else break;
      }
    }
  }

  boolean mouseInteraction() {
    if (!show) return false;
    if (mouseDown) {
      if (mouseDownOnKF) {
        boolean allowedMove = true;
        for (int i=0; i<selectedKF.size(); i++) {
          KeyFrame kf = selectedKF.get(i);
          int mouseStartTime = (int)map(mousePrevX, x, x+w, audioBar.getLength()*audioBar.start, audioBar.getLength()*audioBar.end);
          int mouseEndTime = (int)map(mouseX, x, x+w, audioBar.getLength()*audioBar.start, audioBar.getLength()*audioBar.end);
          int timeMove = mouseEndTime - mouseStartTime;
          if (!kf.stageMove(timeMove)) {
            allowedMove = false;
            break;
          }
        }
        if (allowedMove) {
          for (int i=0; i<selectedKF.size(); i++) {
            selectedKF.get(i).execMove();
          }
          renderKFBackgrounds();
          mousePrevX = mouseX;
        }
      } else {
        clearSelectedKF();
        selectKF();
        return true;
      }
    }
    return false;
  }

  String getExport() {
    colorMode(RGB, 255);
    StringBuilder sb = new StringBuilder(64);
    for (int i=0; i<keyframes.size(); i++) {
      KeyFrame kf = keyframes.get(i);
      sb.append((int)kf.time);
      sb.append(',');
      sb.append((int)red(kf.col));
      sb.append(',');
      sb.append((int)green(kf.col));
      sb.append(',');
      sb.append((int)blue(kf.col));
      if (i!=keyframes.size()-1)sb.append("\r\n");
    }

    return(sb.toString());
  }
}