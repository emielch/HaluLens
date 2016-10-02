
class EyePreview {
  int x, y, w, h;

  KeyframeBar keyframeBar;
  AudioBar audioBar;
  color col;

  EyePreview(int _x, int _y, int _w, int _h, AudioBar _ab, KeyframeBar _kfb) {
    w = _w;
    h = _h;
    x = _x;
    y = _y;
    audioBar = _ab;
    keyframeBar = _kfb;
  }

  void draw() {
    int currPos = audioBar.player.position();
    col = getColorAt(currPos,keyframeBar.keyframes);

    ellipseMode(CORNER);
    fill(col);
    stroke(0);
    strokeWeight(2);
    ellipse(x, y, w, h);
  }
  
  void setKFBar(KeyframeBar _kfb){
    keyframeBar = _kfb;
  }
}

color getColorAt(int time, ArrayList<KeyFrame> keyframes) {
  KeyFrame prevKF = new KeyFrame(-1);
  KeyFrame nextKF = new KeyFrame(0);
  int kfID = 0;
  while (time>nextKF.time && kfID<keyframes.size()) {
    prevKF = nextKF;
    nextKF = keyframes.get(kfID);
    kfID++;
  }
  float lerpFac = constrain(map(time, prevKF.time, nextKF.time, 0, 1), 0, 1);
  return lerpColor(prevKF.col, nextKF.col, lerpFac);
}