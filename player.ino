
void startPlaying() {
  playing = true;
  playWav.play("AUDIO.WAV");
  for (int i = 0; i < PLAYERSAM; i++) {
    players[i].reset();
  }
  seg[1].setFade(Color(0, 0, 0, RGB_MODE), 0.5);
}

void stopPlaying() {
  playing = false;
  playWav.stop();
  seg[2].setFade(Color(0, 0, 0, RGB_MODE), 0.5);
  seg[3].setFade(Color(0, 0, 0, RGB_MODE), 0.5);
  seg[1].setFade(Color(255, 255, 255, RGB_MODE), 0.5);
}

void updatePlayer() {
  if (playWav.isPlaying()) {
    unsigned long currPos = playWav.positionMillis();

    for (int i = 0; i < PLAYERSAM; i++) {
      players[i].update(currPos);
    }
  }
}

