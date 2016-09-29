#ifndef LEDPlayer_h
#define LEDPlayer_h


class LEDPlayer {
  public:
    LEDPlayer();
    LEDPlayer(KeyFrames*, Segment*);
    void update(unsigned long);
    void reset();

  private:
    KeyFrames *keyframes;
    Segment *segment;
    int nextKeyframe;
    boolean activated;
};

LEDPlayer::LEDPlayer() {
  activated = false;
}

LEDPlayer::LEDPlayer(KeyFrames* k, Segment* s) {
  activated = true;
  keyframes = k;
  segment = s;
  nextKeyframe = -1;
}

void LEDPlayer::update(unsigned long currPos) {
  if (!activated) return;

  if (nextKeyframe + 1 < keyframes->getKeyframeAm()) {
    if (currPos > keyframes->getKeyframe(nextKeyframe).time) {
      nextKeyframe++;
      KeyFrame next = keyframes->getKeyframe(nextKeyframe);
      
      float spd;
      long fadeTime = next.time - currPos;
      if ( fadeTime > 0 ) {
        spd = 1000. / fadeTime;
      } else spd = 10000;
      
      segment->setFade(next.col, spd);
      Serial.println("fade to keyframe nr: " + String(nextKeyframe) + " time:" + String(next.time) + " spd:" + String(spd) );
      Serial.println("R:" + String(next.col.red()) + ", G:" + String(next.col.green()) + ", B:" + String(next.col.blue()) );
      Serial.println();
    }
  }
}

void LEDPlayer::reset() {
  nextKeyframe = -1;
}


#endif
