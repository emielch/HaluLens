int nextKeyFrame = 0;

void startPlaying() {
  playing = true;
  playWav.play("AUDIO.WAV");
  nextKeyFrame = 0;
  seg[1].setFade(Color(0, 0, 0, RGB_MODE),0.5);
}

void stopPlaying() {
  playing = false;
  playWav.stop();
  seg[2].setFade(Color(0, 0, 0, RGB_MODE),0.5);
  seg[1].setFade(Color(255, 255, 255, RGB_MODE),0.5);
}

void updatePlayer() {
  if (playWav.isPlaying()) {
    unsigned long currPos = playWav.positionMillis();
    if (nextKeyFrame < keyframeAm) {
      if (currPos > keyframes[nextKeyFrame - 1].time) {
        Serial.println("fade to: " + String(keyframes[nextKeyFrame].time) + " keyframe: " + String(nextKeyFrame) );
        float spd = 10000;
        if ( keyframes[nextKeyFrame].time > 0 ) {
          spd = 1000. / (keyframes[nextKeyFrame].time - currPos);
          Serial.println(spd);
        }
        seg[2].setFade(keyframes[nextKeyFrame].col, spd);
        nextKeyFrame++;
      }
    }
  }
}

