#ifndef KeyFrames_h
#define KeyFrames_h


#define KEYFRAME_MAX_AM       500


struct KeyFrame {
  unsigned long time;
  Color col;
};


class KeyFrames {
  public:
    KeyFrames();
    void addKeyframe(unsigned long, Color);
    KeyFrame getKeyframe(unsigned int);
    int getKeyframeAm();

  private:
    KeyFrame keyframeArr[KEYFRAME_MAX_AM];
    int keyframeAm;

};

KeyFrames::KeyFrames() {
  keyframeAm = 0;
}

void KeyFrames::addKeyframe(unsigned long t, Color c) {
  keyframeArr[keyframeAm].time = t;
  keyframeArr[keyframeAm].col = c;
  keyframeAm++;
}

KeyFrame KeyFrames::getKeyframe(unsigned int id) {
  if (id < keyframeAm) {
    return keyframeArr[id];
  }
  return keyframeArr[0];
}

int KeyFrames::getKeyframeAm(){
  return keyframeAm;
}


#endif