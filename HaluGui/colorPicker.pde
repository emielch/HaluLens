
class ColorPicker {
  int x, y, w, h;
  ArrayList<ColorSlider> sliders = new ArrayList<ColorSlider>();
  KeyFrame selectedKF;
  KeyframeBar kfBar;

  ColorPicker(int _x, int _y, int _w, int _h) {
    w = _w;
    h = _h;
    x = _x;
    y = _y;

    for (int i=0; i<3; i++) {
      ColorSlider newSlider = new ColorSlider(x, y+i*h/3, w, int(h/3*0.7), i);
      sliders.add(newSlider);
    }
  }

  void draw() {
    for (int i=0; i<sliders.size(); i++) {
      sliders.get(i).draw();
    }
  }

  void setKF(KeyFrame kf, KeyframeBar _kfBar) {
    colorMode(HSB, 1);
    selectedKF = kf;
    color col = selectedKF.col;
    updateColor(hue(col), saturation(col), brightness(col), -1);
    kfBar = _kfBar;
  }

  void updateColor(float hue, float sat, float bri, int valID) {
    colorMode(HSB, 1);
    for (int i=0; i<sliders.size(); i++) {
      if (i==valID) continue;
      sliders.get(i).setColor(hue, sat, bri);
    }
    selectedKF.col = color(hue, sat, bri);
    if (valID!=-1)kfBar.setRenderBG();
  }

  void clearKF() {
    selectedKF = null;
    for (int i=0; i<sliders.size(); i++) {
      sliders.get(i).clearColor();
    }
  }

  void mouseInteraction(boolean click) {
    for (int i=0; i<sliders.size(); i++) {
      if (sliders.get(i).mouseInteraction(click)) {
        //audioBar.player.cue(selectedKF.time);
        break;
      }
    }
  }

  void mouseReleased() {
    for (int i=0; i<sliders.size(); i++) {
      sliders.get(i).mouseDown = false;
    }
  }
}


class ColorSlider {
  int x, y, w, h;
  int valID;
  float hue, sat, bri;
  boolean active;
  boolean mouseDown = false;

  ColorSlider(int _x, int _y, int _w, int _h, int _valID) {
    w = _w;
    h = _h;
    x = _x;
    y = _y;
    valID = _valID;
  }

  void setColor(float _hue, float _sat, float _bri) {
    colorMode(HSB, 1);
    
    hue = _hue;
    sat = _sat;
    bri = _bri;
    active = true;
  }

  void clearColor() {
    active = false;
  }

  boolean mouseInteraction(boolean click) {
    if (!active) return false;
    if (mouseX>x && mouseX<x+w && mouseY>y && mouseY<y+h) {
      if (click) mouseDown = true;
    }

    if (mouseDown) {
      colorMode(HSB, 1);
      float val = constrain((float)(mouseX-x)/w, 0, 1);

      if (valID==0) hue = val;
      else if (valID==1) sat = val;
      else if (valID==2) bri = val;
      colorPicker.updateColor(hue, sat, bri, valID);
      return true;
    }
    return false;
  }

  void draw() {
    colorMode(HSB, 1);

    if (active) {
      for (int i=0; i<w; i++) {
        float _hue = hue;
        float _sat = sat;
        float _bri = bri;
        if (valID==0) _hue = (float)i/w;
        if (valID==1) _sat = (float)i/w;
        else if (valID==2) _bri = (float)i/w;

        color strokeCol = color(_hue, _sat, _bri);

        stroke(strokeCol);
        strokeWeight(1);
        line(x+i, y, x+i, y+h);
      }
    }

    rectMode(CORNER);
    noFill();
    if (!active) fill(20);
    stroke(0);
    strokeWeight(1);
    rect(x, y, w, h);

    if (active) {

      float val = 0;
      if (valID==0) val = hue;
      else if (valID==1) val = sat;
      else if (valID==2) val = bri;



      float xpos = map(val, 0, 1, x, x+w);
      rectMode(CENTER);
      stroke(0);
      strokeWeight(3);
      fill(color(hue, sat, bri));
      rect(xpos, y+h/2, 10, h*1.2);
    }
  }
}