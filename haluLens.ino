#include <Audio.h>
#include <Wire.h>
#include <SPI.h>
#include <SD.h>
#include <SerialFlash.h>
#include <Colore.h>
#include <Adafruit_DotStar.h>

#include "keyframes.h"
#include "LEDPlayer.h"


AudioPlaySdWav           playWav;
AudioOutputI2S           audioOutput;
AudioConnection          patchCord1(playWav, 0, audioOutput, 0);
AudioConnection          patchCord2(playWav, 1, audioOutput, 1);
AudioControlSGTL5000     sgtl5000_1;

#define SDCARD_CS_PIN    10
#define SDCARD_MOSI_PIN  7
#define SDCARD_SCK_PIN   14

boolean playing = false;

void setup() {
  Serial.begin(9600);
  setupLed();

  // Audio connections require memory to work.  For more
  // detailed information, see the MemoryAndCpuUsage example
  AudioMemory(8);

  // Comment these out if not using the audio adaptor board.
  // This may wait forever if the SDA & SCL pins lack
  // pullup resistors
  sgtl5000_1.enable();
  sgtl5000_1.volume(0.8);

  SPI.setMOSI(SDCARD_MOSI_PIN);
  SPI.setSCK(SDCARD_SCK_PIN);
  if (!(SD.begin(SDCARD_CS_PIN))) {
    // stop here, but print a message repetitively
    while (1) {
      Serial.println("Unable to access the SD card");
      delay(500);
    }
  }

  readFiles();
  stopPlaying();
}

boolean timeout = false;
unsigned int timeoutTime = 0;

void loop() {
  updateLed();
  updatePlayer();

  if (touchRead(16) > 750) {
    if(!playing){
      startPlaying();
    }
    if(timeout) timeout = false;
  } else if (touchRead(16) < 700 && playing) {
    if (timeout) {
      if (millis() > timeoutTime + 2000) {
        stopPlaying();
        timeout = false;
      }
    } else {
      timeout = true;
      timeoutTime = millis();
    }
  }
}





