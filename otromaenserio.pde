import processing.sound.*;
import java.util.ArrayDeque;
import java.util.*;

SoundFile file;
AudioIn in;
FFT fft;
 
String songDir = "D:/MUSICA/LIBRERIAS/tracklists";
List<String> songs = new ArrayList<>();
int cols, rows;
int bands = 256;
float w;
float[] spectrum = new float[bands];
float[] sum = new float[bands];
float[] logBins = new float[bands];
float[] scaledBins = new float[bands];
float binWidth = 0;
ArrayDeque<float[]> data = new ArrayDeque<>();
final int maxEle = 100;
final static int vScale = 11;
int volume = 99;

/*
  para valores de "smoothing" mayores que 0.5 hay mas "ruido", y puede venir bien para "tirar encima un trapo" y que tenga mas "sitios de apoyo".
  el trapo es una malla de vertices 
  
  para valores menores que 0.48 (default), y cercanos a 0.1, se parece mas a un EQ, el "terreno es mas planito", hay menos "ruido"


*/
float smoothing = 0.48;

float maxLogBin = 0;
float minLogBin = 9999;

float angle = 0;
float wiggle1 =0;
float wiggle2 =0;
float cameraX=0;
float cameraY=0;
float cameraZ=0;

boolean presUP = false;
boolean presDOWN = false;
boolean presLEFT = false;
boolean presRIGHT = false;

boolean relUP = false;
boolean relDOWN = false;
boolean relLEFT = false;
boolean relRIGHT = false;

void setup() {
  size(displayWidth, displayHeight, P3D);
  background(150);

  readSongDir();
  
  fft= new FFT(this, bands);
  loadSongFile();
  
  setupDisplay();
}

void draw() {
  background(0);
  
  renderCamera();
  
  readFFT();
  
  //showMouse();
  showGridHelper();
 //drawEQ();
  
  drawSpectrogram();
  
}

void renderCamera(){
 
  
  wiggle1 = 150*sin(angle+0.0001*millis());
    wiggle2 = 200*sin(0.5*angle+0.0001*millis());

 //          camera position                                                                                camera looking at
 //     eyex,       eyeY,                               eyeZ,                                          centerX,centerY,centerZ,                   upX, upY, upZ
   camera(wiggle2+cameraX+width/2.0,height/2.+ wiggle1 - cameraY, 12*mouseY+(height/2.0) / tan(PI*30.0 / 180.0),wiggle2+ width/2.0, height, -500, 0, 1, 0);
   
   angle-=0.01;
 
  
   if(presUP){
    cameraY+=10;
  }
  if(presDOWN){
    cameraY-=10;
  }
  if(presLEFT){
    cameraX-=10;
  }
  if(presRIGHT){
    cameraX+=10;
  }
   
  //println("UP:....PRESS= "+presUP+", RELEASE= "+relUP+"     ");
  //println("DOWN:..PRESS= "+presDOWN+", RELEASE= "+relDOWN+"     ");
  //println("LEFT:..PRESS= "+presLEFT+", RELEASE= "+relLEFT+"     ");
  //println("RIGHT:.PRESS= "+presRIGHT+", RELEASE= "+relRIGHT+"     ");
}

void readFFT(){
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

}

void drawEQ(){
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
  w = width / bands;
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
      //print(logBins[i]+"--");
    }
  }

  //println("\n");

  for (int i=0; i<bands; i++) {
    scaledBins[i]= round(map(logBins[i], minLogBin, maxLogBin, 0, width));
    //print(scaledBins[i]+"--");
  }

  //println();
  //println(scaledBins.length);
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
  println(volume);
  setVolume();
}

public void keyPressed(KeyEvent event) {
  //CAMERA CONTROLS
  
  presUP = event.getKeyCode() == 87;
  presDOWN = event.getKeyCode() == 83;
  presRIGHT = event.getKeyCode() == 68;
  presLEFT = event.getKeyCode() == 65;
  
  relUP = presUP && !relUP;
  relDOWN = presDOWN && !relDOWN;
  relRIGHT = presRIGHT && !relRIGHT;
  relLEFT = presLEFT && !relLEFT;
  
  if (event.getKeyCode() == '1') {
    file.stop();
    file.removeFromCache();
    changeSongFile();
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

public void keyReleased(KeyEvent event){
  relUP = event.getKeyCode() == 87;
  relDOWN = event.getKeyCode() == 83;
  relRIGHT = event.getKeyCode() == 68;
  relLEFT = event.getKeyCode() == 65;
  
  presUP = relUP && !presUP;
  presDOWN = relDOWN && !presDOWN;
  presRIGHT = relRIGHT && !presRIGHT;
  presLEFT = relLEFT && !presLEFT;
  
}

private void setVolume() {
  file.amp(volume / 100.0f);
}

private void changeSongFile(){
  loadSongFile();
  if (!file.isPlaying()) {
      file.play();
  }
}

private void loadSongFile() {
  try{
    
  file = new SoundFile(this, randomSong());
  if (file != null) {
    file.amp(volume / 100f);
    fft.input(file);
  }
  }catch(Exception e){
    loadSongFile();  
  }
}

void drawSpectrogram(){
  final float yStart = height * 0.99f;
  
  int z = 0;
  float alpha = 255;
  int eleNum = 0;
  for (float[] ele : data) {
    eleNum++;
    alpha = map(eleNum, 0, data.size(), 255, 0);

    for (int i = 0; i < ele.length; i++) {
      final float red = map(i, 0, ele.length, 0, 10);
      final float greem = map(i, 0, ele.length, 0, 255);
      final float blue = map(i, 0, ele.length, 255, 0);
      
      push();
      fill(red, greem, blue, alpha);
      translate(0, 0, (0.2*eleNum+1)*z);
      
      float amp = ele[i];
      sum[i] += (amp - sum[i]) * smoothing;

      float y =max(-height, 10* (float) Math.log(sum[i]/height)*vScale);
      

      rect(scaledBins[i], yStart, w, -y-height);
      pop();
    }
    z += 8;
  } 
}
