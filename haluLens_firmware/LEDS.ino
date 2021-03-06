//#define PIN 0  // neopixel

#define DATAPIN    4  // dotstar
#define CLOCKPIN   5// dotstar

#define BEAM_AM 10
Beam beams[BEAM_AM];

#define LED_AM 6 // Number of LEDs in strip

//Adafruit_NeoPixel leds = Adafruit_NeoPixel(LED_AM, PIN, NEO_GRB + NEO_KHZ800);
Adafruit_DotStar leds = Adafruit_DotStar(LED_AM, DATAPIN, CLOCKPIN, DOTSTAR_BGR);

Segment seg[] = {
  Segment(0, 5), // 0  rainbow
  Segment(0, 5), // 1  mask
  Segment(3, 5), // 2  keyframes left
  Segment(0, 2) // 3  keyframes right
};

byte segAm = sizeof(seg) / sizeof(Segment);
Colore colore( LED_AM, seg, segAm, beams, BEAM_AM, &set_ledLib, &get_ledLib, &show_ledLib, &reset_ledLib );


void setupLed(boolean succes) {
  leds.begin(); // Initialize pins for output
  leds.show();  // Turn all LEDs off ASAP
  if (succes) {
    seg[0].setRainbow(0.2, 10, 15);
    seg[1].setBlendMode(MULTIPLY);
    seg[1].setFade(Color(255, 255, 255, RGB_MODE), 0.5);
  } else {
    seg[0].setFade(Color(20, 0, 0, RGB_MODE), 0.5);
  }
}

void updateLed() {
  colore.update(true);
  //  printFramerate();
}

void printFramerate() {
  Serial.print("FrameRate: ");
  Serial.println(colore.getFPS()); // print framerate
}


void set_ledLib(int pixel, byte r, byte g, byte b) {
  leds.setPixelColor(pixel, r, g, b);
}

void show_ledLib() {
  leds.show();
}

void reset_ledLib() {
  for (int i = 0; i < LED_AM; i++) {
    leds.setPixelColor(i, 0, 0, 0);
  }
}

Color get_ledLib(int pixel) {
  uint32_t conn = leds.getPixelColor(pixel);  // retrieve the color that has already been saved
  byte b = conn & 255;       // unpack the color
  byte g = conn >> 8 & 255;
  byte r = conn >> 16 & 255;
  Color pixelCol(r, g, b, RGB_MODE);
  return pixelCol;
}
