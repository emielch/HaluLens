

class ScrollBar {
  float start, end;
  int x, y, w, h;
  float window;

  boolean mouseDown = false;

  ScrollBar(int _w, int _h, int _x, int _y) {
    w = _w;
    h = _h;
    x = _x;
    y = _y;
    start = 0;
    end = 1;
  }

  void draw() {
    rectMode(CORNER);
    noStroke();
    fill(200);
    rect(x, y, w, h);
    fill(150);
    rect(x+start*w, y, (end-start)*w, h);
  }

  void move(float center, float am) {
    window = end-start;
    window = constrain(window/am, 0, 1);
    start = center-window/2;
    end = center+window/2;

    if (start<0) {
      start=0;
      end = start+window;
    } else if (end>1) {
      end=1;
      start = end-window;
    }
  }

  boolean mousePressed() {
    if (mouseX>x && mouseX<x+w && mouseY>y && mouseY<y+h) {
      mouseDown = true;
      mouseInteract();
      return true;
    }
    return false;
  }
  
  void mouseReleased(){
    mouseDown = false;
  }

  boolean mouseInteract() {
    if (mouseDown) {
      float pos = map(mouseX, x, x+w, 0, 1);
      move(pos, 1);
      return true;
    }
    return false;
  }
}