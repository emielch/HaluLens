import java.util.concurrent.TimeUnit;

class AudioBar {
  int w, h, x, y;
  float start, end;

  PGraphics wf;

  AudioPlayer player;
  AudioSample audio;
  FloatList waveformFrames;
  int wfSampleSize = -1;
  float[] audioFrames;

  boolean mouseDown = false;

  AudioBar(int _w, int _h, int _x, int _y) {
    wf = createGraphics(w, h);
    w = _w;
    h = _h;
    x = _x;
    y = _y;
    start = 0;
    end = 1;
  }

  void draw() {
    image(wf, x, y);

    float posx = getFacPosInWindow(player.position())*w +x;
    if (!(posx<x || posx>x+w)) {
      stroke(0, 200, 0);
      strokeWeight(4);
      line(posx, y, posx, y+h);
    }
  }

  float getCursor() {
    return (float)player.position()/player.length();
  }
  
  float getFacPosInWindow(float millis) {
    return map(millis, player.length()*start, player.length()*end, 0, 1);
  }

  void loadAudio(String fileName) {
    audio = minim.loadSample(fileName, 2048);
    player = minim.loadFile(fileName, 2048);
    audioFrames = audio.getChannel(AudioSample.LEFT);

    resampleAudioFrames();

    wf = drawWaveform();
  }

  void resampleAudioFrames() {
    int newSampleSize = max(int((audioFrames.length/w)*0.1*(end-start)), 1);
    if (wfSampleSize==newSampleSize) {
      return;
    }
    wfSampleSize = newSampleSize;
    waveformFrames = new FloatList();
    for (int i=0; i<audioFrames.length-wfSampleSize; i+=wfSampleSize) {
      float max = 0;
      for (int j=0; j<wfSampleSize; j++) {
        if (abs(audioFrames[i+j])>abs(max)) max = audioFrames[i+j];
      }
      waveformFrames.append(max);
    }
  }

  PGraphics drawWaveform() {
    PGraphics _wf = createGraphics(w, h, P3D);
    _wf.beginDraw();
    _wf.background(0);
    _wf.stroke(255);

    int startFrame = int(waveformFrames.size()*start);
    int endFrame = int(waveformFrames.size()*end);
    float len = endFrame-startFrame;
    for (int i = 0; i < len - 1; i++) {
      _wf.line((i/len)*w, h/2+waveformFrames.get(startFrame+i)*h*0.5, ((i+1)/len)*w, h/2+waveformFrames.get(startFrame+i+1)*h*0.5);
    }
    _wf.endDraw();
    return _wf;
  }

  void zoom(boolean zoom, float s, float e) {
    start = s;
    end = e;
    if (zoom) {
      resampleAudioFrames();
    }
    wf = drawWaveform();
  }

  String getTimeCode() {
    long millis = player.position();
    long minutes = TimeUnit.MILLISECONDS.toMinutes(millis);
    millis -= TimeUnit.MINUTES.toMillis(minutes);
    long seconds = TimeUnit.MILLISECONDS.toSeconds(millis);
    millis -= TimeUnit.SECONDS.toMillis(seconds);

    StringBuilder sb = new StringBuilder(64);
    sb.append(nf(int(minutes),2));
    sb.append(":");
    sb.append(nf(int(seconds),2));
    sb.append(".");
    sb.append(nf(int(millis),3));

    return(sb.toString());
  }


  boolean mousePressed() {
    if (mouseX>x && mouseX<x+w && mouseY>y && mouseY<y+h) {
      mouseDown = true;
      mouseInteract();
      return true;
    }
    return false;
  }

  void mouseReleased() {
    mouseDown = false;
  }

  boolean mouseInteract() {
    if (mouseDown) {
      int pos = (int)map(mouseX, x, x+w, player.length()*start, player.length()*end);
      player.cue(pos);
      return true;
    }
    return false;
  }
}