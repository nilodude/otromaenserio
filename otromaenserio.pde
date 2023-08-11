import processing.sound.*;
import java.util.ArrayDeque;
import java.util.*;

SoundFile file;
AudioIn in;
FFT fft;

String songDir = "D:/MUSICA/LIBRERIAS/tracklists";
List<String> songs = new ArrayList<>();
int cols, rows;
int bands = 512;
float w;
float[] spectrum = new float[bands];
float[] sum = new float[bands];
float[] logBins = new float[bands];
float[] scaledBins = new float[bands];
float binWidth = 0;
ArrayDeque<float[]> data = new ArrayDeque<>();
final int maxEle = 100;
final static int vScale = 8;
int volume = 100;
float smoothing = 0.48;
float maxLogBin = 0;
float minLogBin = 9999;
int myWidth = width +500;
int myHeight = height +200;

float angle = 0;

float cameraX=0;
float cameraY=0;
float cameraZ=0;

void setup() {
  size(displayWidth, displayHeight, P3D);
  background(150);

  readSongDir();

  file = new SoundFile(this, randomSong());
  file.amp(volume/100f);
  fft= new FFT(this, bands);
  fft.input(file);
  w = width / bands;

  setupDisplay();
}

void draw() {
  float wiggle = 20*sin(angle*2+PI/100);
  
  //          camera position                                                          camera looking at
  //     eyex,       eyeY,                               eyeZ,                        centerX,centerY,centerZ,             upX, upY, upZ
  camera(cameraX+width/2.0,wiggle+ height/2. -5*cameraY, 2000+(height/2.0) / tan(PI*30.0 / 180.0), wiggle+width/2.0, height, -500, 0, 1, 0);
  angle+=PI/100;
  if (file.isPlaying()) {
    fft.analyze(spectrum);
    final float[] clone = spectrum.clone();
    data.addFirst(clone);
  }
  if (data.size() >= maxEle) {
    data.removeLast();
  }
  if (data.size() > maxEle) {
    data.clear();
  }

  background(0);
  //showMouse();
  showGridHelper();
  //showEQ();
  
  
  //int widthPercent = 90;

  //final float spectrumWidth = width / 100.0f * widthPercent;
  //float spectrumEleWidth = spectrumWidth / bands;
  //float xStart = (width - spectrumWidth) / 2;
  final float yStart = height * 0.95f;
  
  int z = 0;
  float alpha = 255;
  int eleNum = 0;
  for (float[] ele : data) {
    eleNum++;
    alpha = map(eleNum, 0, data.size(), 255, 0);

    for (int i = 0; i < ele.length; i++) {
      final float greem = map(i, 0, ele.length, 50, 255);
      final float blue = map(i, 0, ele.length, 255, 0);
      
      push();
      fill(30, greem, blue, alpha);
      translate(0, 0, z);
      
      float amp = ele[i];
      sum[i] += (amp - sum[i]) * smoothing;

      float y =max(-height, 10* (float) Math.log(sum[i]/height)*vScale);
      

      rect(scaledBins[i], yStart, w, -y-height);
      pop();
    }
    z += 50;
  }
   
}

void showEQ(){
  stroke(0);
  for (int i = 0; i < bands; i++) {
    
    float amp = spectrum[i];
    sum[i] += (amp - sum[i]) * smoothing;

    float y =max(-height, 10* (float) Math.log(sum[i]/height)*vScale);
    stroke(130, 255, 0);
    line(scaledBins[i] + w/2, height, scaledBins[i] + w/2, height - y );

    stroke(255, 255/(i+1), i);
    fill(0, 0, 0, 0);
    // jugando con "height-y" , "height + y", "height", "y", se consiguen efectos guapos

    rect(scaledBins[i], height, w, -y-height);
  } 
}

void setupDisplay() {
  binWidth = file.sampleRate()/bands;

  for (int i=0; i<bands; i++) {
    float temp = (i+1)*binWidth;
   if (temp < 20000) {
      logBins[i]= (float) Math.log10(temp);

      if (maxLogBin < logBins[i]) {
        maxLogBin = logBins[i];
      }
      if (minLogBin > logBins[i]) {
        minLogBin = logBins[i];
      }
      print(logBins[i]+"--");
    }
  }

  println("\n");

  for (int i=0; i<bands; i++) {
    scaledBins[i]= round(map(logBins[i], minLogBin, maxLogBin, 0, width));
    print(scaledBins[i]+"--");
  }

  println();
  //println(scaledBins[127]);

  println(scaledBins.length);
}

void mouseClicked() {
  if (!file.isPlaying()) {
    file.play();
  } else {
    
    file.pause();
  }
}

void showGridHelper() {
  beginShape();
  fill(0, 255, 0);
  stroke(0, 255, 0);
  line(0, 0, 0, 0, 0, 2000);
  line(0, 0, 0, 0, height, 0);
  line(0, 0, 0, width, 0, 0);
  endShape();
}

void showMouse() {
  beginShape();
  textSize(200);
  fill(255);
  text(mouseX, 0, height/3);
  text(mouseY, 0, 100+height/3);
  endShape();
}

void readSongDir() {
  File[] files = new File(songDir).listFiles();

  for (File file : files) {
    if (!file.isDirectory() && !file.getName().contains("flac")) {
      songs.add(file.getPath());
    }
  }
}

String randomSong() {
  String song = songs.get(parseInt(random(songs.size())));
  println(song);
  return song;
}

public void mouseWheel(MouseEvent event) {
  final int count = event.getCount();
  volume -= count;
  if (volume > 100) {
    volume = 100;
  }
  if (volume < 0) {
    volume = 0;
  }
  setVolume();
}

public void keyPressed(KeyEvent event) {
  //CAMERA CONTROLS
  if (event.getKeyCode() == 87) {
   cameraY+=30;
  }
  if (event.getKeyCode() == 83) {
   cameraY-=30;
  }
  if (event.getKeyCode() == 68) {
   cameraX+=30;
  }
  if (event.getKeyCode() == 65) {
   cameraX-=30;
  }
  
  
  if (event.getKeyCode() == '1') {
    file.stop();
    file.removeFromCache();
    
    loadSong();
  }
  if (event.getKeyCode() == 38 && smoothing<0.8) {
    smoothing+= 0.030;
    println(smoothing);
  }
  if (event.getKeyCode() == 40 && smoothing>=0.05) {
    smoothing-=0.030;
    println(smoothing);
  }
}

private void setVolume() {
  file.amp(volume / 100.0f);
}

private void loadSong() {
  file = new SoundFile(this, randomSong());
  if (file != null) {
    file.amp(volume / 100f);
    fft.input(file);
    if (!file.isPlaying()) {
      file.play();
    }
  }
}
