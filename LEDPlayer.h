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
    int passedKeyframe;
    boolean activated;
};

LEDPlayer::LEDPlayer() {
  activated = false;
}

LEDPlayer::LEDPlayer(KeyFrames* k, Segment* s) {
  activated = true;
  keyframes = k;
  segment = s;
  passedKeyframe = -1;
}

void LEDPlayer::update(unsigned long currPos) {
  if (!activated) return;
  
  if (passedKeyframe + 1 < keyframes->getKeyframeAm()) {
    if (currPos > keyframes->getKeyframe(passedKeyframe).time) {
      passedKeyframe++;
      KeyFrame next = keyframes->getKeyframe(passedKeyframe);
      Serial.println("fade to: " + String(next.time) + " keyframe: " + String(passedKeyframe) );
      Serial.println("r:" + String(next.col.red()) + "g:" + String(next.col.green()) + "b:" + String(next.col.blue()) );
      float spd = 10000;
      if ( next.time > 0 ) {
        spd = 1000. / (next.time - currPos);
        Serial.println(spd);
      }
      segment->setFade(next.col, spd);
    }
  }
}

void LEDPlayer::reset() {
  passedKeyframe = -1;
}


#endif
