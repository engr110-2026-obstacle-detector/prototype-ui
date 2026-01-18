
float esp32Millis=0.0;
boolean enabled=false;

int numSensors=3;
float distances[]=new float[numSensors];

byte objectCount[] = new byte[3];
byte dropCount[] = new byte[3];
byte prevObjectCount[] = new byte[3];
byte prevDropCount[] = new byte[3];

float dropThresh=100;

float objThresh=50;

////https://discourse.processing.org/t/is-there-a-text-to-speech-for-android/26777/7
//import android.app.Activity;
//import android.os.Bundle;
//import android.speech.tts.TextToSpeech;
//import java.util.Locale;
//import android.app.Activity;
//import android.content.ActivityNotFoundException;
//import android.content.Intent;
//import android.speech.RecognizerIntent;
//import android.content.*; 

import processing.sound.*;

SinOsc sine;



//TextToSpeech tts;

Slider DropThreshSlider; 

Slider ObjThreshSlider; 

void saveThresholds() {
  String[] settings={str(dropThresh), str(objThresh)};
  saveStrings("tSettings.txt", settings);
}
void loadThresholds() {
  try {
    String[] settings=loadStrings("tSettings.txt");
    dropThresh=float(settings[0]);
    objThresh=float(settings[1]);
  }
  catch(Exception e) {
  }
}

void setup() {
  fullScreen();
  rcmdsSetup();
  //setup UI here
  DropThreshSlider = new Slider(width*.12, height*.75, height*.45, width*.05, 0, 1000, color(100, 0, 0), color(255), null, 0, 0, .03, 0, false, false);
  ObjThreshSlider = new Slider(width*.2, height*.75, height*.45, width*.05, 0, 1000, color(0, 0, 250), color(255), null, 0, 0, .03, 0, false, false);

  loadThresholds();


  sine = new SinOsc(this);

  //sine.play();



  //Activity activity = this.getActivity();
  //Context context = activity.getApplicationContext();

  //tts = new TextToSpeech(context, new TextToSpeech.OnInitListener() {
  //  @Override
  //    public void onInit(int status) {
  //    if (status == TextToSpeech.SUCCESS) {
  //      tts.setLanguage(Locale.US);
  //      tts.setSpeechRate(2);
  //    } else {
  //      println("error tts init");
  //    }
  //  }
  //}
  //);
}

//void speaktts(String text) {
//  print(text);
//  if (tts != null) {
//    tts.speak(text, TextToSpeech.QUEUE_FLUSH, null, null);
//  }
//}

//void stop() {
//  if (tts != null) {
//    tts.stop();
//    tts.shutdown();
//  }
//}

//void sayTest() {
//  speaktts("hello world");
//}

//void speakObject(int i) {
//  String str[]={"object left", "object front", "object right"};
//  speaktts(str[i]);
//}

//void speakDrop(int i) {
//  String str[]={"drop left", "drop front", "drop right"};
//  speaktts(str[i]);
//}


//void draw(){
//  sine.play();
//  //sine.freq(millis()/10);
//}

void draw() {
  background(0);
  runWifiSettingsChanger();
  //enabled=enableSwitch.run(enabled);

  float prevDropThresh=dropThresh;
  float prevObjThresh=objThresh;

  dropThresh=DropThreshSlider.run(dropThresh);
  if (dropThresh<=objThresh) {
    objThresh=dropThresh-.0001;
  }
  objThresh=ObjThreshSlider.run(objThresh);
  if (objThresh>=dropThresh) {
    dropThresh=objThresh+.0001;
  }

  if (prevDropThresh!=dropThresh || prevObjThresh!=objThresh) {
    saveThresholds();
  }

  /////////////////////////////////////add UI here

  int numOther=5;
  String[] msg=new String[numOther+numSensors*3];
  String[] data=new String[numOther+numSensors*3];

  msg[0]="phone millis";
  data[0]=str(millis());
  msg[1]="esp32 millis";
  data[1]=str(esp32Millis);
  msg[2]="ping";
  data[2]=str(wifiPing);
  msg[3]="dropThresh";
  data[3]=str(dropThresh);
  msg[4]="objThresh";
  data[4]=str(objThresh);
  for (int i=0; i<numSensors; i++) {
    msg[numOther]="dist "+str(i);
    data[numOther]=str(distances[i]);
    numOther++;
  }
  for (int j=0; j<numSensors; j++) {
    int i=0;
    if (j==0) {
      i=1;
    }
    if (j==1) {
      i=0;
    }
    if (j==2) {
      i=2;
    }
    if (distances[i]>dropThresh) {
      msg[0]="################";
      sine.amp(1.0);
      sine.pan(i-1.0);
      sine.freq(440);
      sine.play();

      break;
    } else if (distances[i]<objThresh) {
      msg[1]="################";
      sine.amp(.7);
      sine.pan(i-1.0);
      sine.freq(1320);
      sine.play();

      break;
    } else {
      msg[2]="################";
      //sine.amp(0);
      //sine.pan(0);
      //sine.freq(880);
      sine.stop();
    }
  }

  //if ((millis()%1000)<500) {
  //  toneH

  //  // Map mouseX from 20Hz to 1000Hz for frequency  
  //  float frequency = map(mouseX, 0, width, 80.0, 1000.0);
  //  sine.freq(frequency);

  //  print(millis());


  //  // Map mouseX from -1.0 to 1.0 for panning the audio to the left or right
  //  float panning = map(mouseX, 0, width, 1.0, 1.0);
  //  sine.pan(int(panning));
  //} else {
  //  sine.stop();
  //}


  for (int i=0; i<numSensors; i++) {
    msg[numOther]="objects "+str(i);
    data[numOther]=str(objectCount[i]);
    if (prevObjectCount[i]!=objectCount[i]) {
      //speakObject(i);
    }
    prevObjectCount[i]=objectCount[i];
    numOther++;
  }
  for (int i=0; i<numSensors; i++) {
    msg[numOther]="drops "+str(i);
    data[numOther]=str(dropCount[i]);
    if (prevDropCount[i]!=dropCount[i]) {
      //speakDrop(i);
    }
    prevDropCount[i]=dropCount[i];
    numOther++;
  }

  dispTelem(msg, data, width/2, height*2/3+20, width/4, height*2/3+10, 20);

  sendWifiData(true);
  endOfDraw();
}



void WifiDataToRecv() {
  esp32Millis=recvFl();
  ////////////////////////////////////add data to read here
  for (int i=0; i<numSensors; i++) {
    distances[i]=recvFl();
  }
  for (int i=0; i<numSensors; i++) {
    objectCount[i]=byte(recvBy());
    dropCount[i]=byte(recvBy());
  }
}
void WifiDataToSend() {
  sendBl(enabled);
  ///////////////////////////////////add data to send here
  sendFl(objThresh);
  sendFl(dropThresh);
}
