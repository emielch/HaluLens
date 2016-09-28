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
    int nextKeyFrame;

};

LEDPlayer::LEDPlayer() {
  nextKeyFrame = -1;
}

LEDPlayer::LEDPlayer(KeyFrames* k, Segment* s) {
  keyframes = k;
  segment = s;
  nextKeyFrame = 0;
}

void LEDPlayer::update(unsigned long currPos) {
  if (nextKeyFrame == -1) return;

  if (nextKeyFrame < keyframes->getKeyframeAm()) {
    if (currPos > keyframes->getKeyframe(nextKeyFrame - 1).time) {
      KeyFrame next = keyframes->getKeyframe(nextKeyFrame);
      Serial.println("fade to: " + String(next.time) + " keyframe: " + String(nextKeyFrame) );
      float spd = 10000;
      if ( next.time > 0 ) {
        spd = 1000. / (next.time - currPos);
        Serial.println(spd);
      }
      segment->setFade(next.col, spd);
      nextKeyFrame++;
    }
  }
}

void LEDPlayer::reset() {
  nextKeyFrame = 0;
}


#endif
