String filePath = "";


void openFile(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());
    loadLEDFile(selection.getAbsolutePath());
  }
}

void loadLEDFile(String file) {
  filePath = dataPath(file);
  String lines[] = loadStrings(filePath);
  if (lines==null) return;
  parseFile(lines);
}

void openAudioFile(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    String audioPath = selection.getAbsolutePath();
    println("User selected " + audioPath);
    audioBar.loadAudio(audioPath);
  }
}

void parseFile(String lines[]) {
  kfBarLeft.keyframes.clear();
  kfBarRight.keyframes.clear();

  KeyframeBar kfBar = kfBarLeft;
  boolean stereo = false;

  for (int i = 0; i < lines.length; i++) {
    String line = lines[i];
    String[] values = split(line, ',');

    if (values.length>=4) {
      int t, r, g, b = 0;
      t = Integer.parseInt(values[0]);
      r = Integer.parseInt(values[1]);
      g = Integer.parseInt(values[2]);
      b = Integer.parseInt(values[3]);
      println(t+"'"+r+"'"+g+"'"+b);
      if (t>=0 && t<=audioBar.getLength()) {
        colorMode(RGB, 255);
        KeyFrame newKF = new KeyFrame(t, color(r, g, b), kfBar);
        kfBar.addKeyframe(newKF);
      } else println("keyframe out of bounds!");
    } else if (values[0].charAt(0)=='-') {
      kfBar = kfBarRight;
      stereo = true;
      stereoToggle.setState(true);
    }
  }
  kfBarLeft.setRenderBG();
  kfBarRight.setRenderBG();
  stereoToggle.setState(stereo);
}

void saveFile() {
  println("Saving file");
  if (filePath=="") {
    selectInput("Save:", "setFile");
    return;
  } else {
    println(filePath);
    PrintWriter output;
    output = createWriter(filePath);
    output.print(kfBarLeft.getExport());
    if (stereoMode) {
      output.println();
      output.println('-');
      output.print(kfBarRight.getExport());
    }

    output.flush();
    output.close();
  }
}

void setFile(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    filePath = selection.getAbsolutePath();
    println("User selected " + filePath);
    saveFile();
  }
}