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
final static int vScale = 5; 
int volume = 100;
float smoothing = 0.18;
float maxLogBin = 0;
float minLogBin = 9999;
int myWidth = width +500;
int myHeight = height +200;

void setup(){
  size(displayWidth, displayHeight, P3D);
  background(150);
    
  readSongDir();
  
  file = new SoundFile(this, randomSong());
  file.amp(volume/100f);
  fft= new FFT(this, bands);
  fft.input(file);
  w = width / bands;
    
  binWidth = file.sampleRate()/bands;
  
  for(int i=0;i<bands;i++){
    float temp = (i+1)*binWidth;
    if(temp < 20000){
      logBins[i]= (float) Math.log10(temp);
      
      if(maxLogBin < logBins[i]){
        maxLogBin = logBins[i];
      }
      if(minLogBin > logBins[i]){
        minLogBin = logBins[i];
      }
      //print(logBins[i]+"--");
    }
  }
  
  println();
  
  for(int i=0;i<bands;i++){
    scaledBins[i]= round(map(logBins[i],minLogBin,maxLogBin,0,width));
    print(scaledBins[i]+"--");
  }
  
  println();
  //println(scaledBins[127]);

  println(scaledBins.length);
}

void draw(){
   //          camera position                                          camera looking at
  //     eyex,       eyeY,             eyeZ,                        centerX,centerY,centerZ,       upX, upY, upZ
  camera(width/2.0,height/2. - 500, 2000+(height/2.0) / tan(PI*30.0 / 180.0), width/2.0, height, -500,    0, 1, 0);
   
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
  
  
  //lo siguiente es almacenar cada iteracion del spectrum en un arrayDeque y hacer que se desplaze hacia abajo
  //las muestras antiguas y que se vaya mostrando arriba del todo la nueva muestra (iteracion actual) de spectrum
  
  stroke(0);
  for(int i = 1; i < bands; i++){
    float amp = spectrum[i];
    sum[i] += (amp - sum[i]) * smoothing;
    float y =  min(height,sum[i] * height *vScale);
    
    stroke(130, 255, 0);
    //line(i*w + w/2, height, i*w + w/2, height - y );
    
    stroke(255,255/(i+1),i);
    fill(0,0,0,0);
    // jugando con "height-y" , "height + y", "height", "y", se consiguen efectos guapos
    
    rect(scaledBins[i],height, w, -y*i/6);
    
    
  }
  
}

int logspace(int band){
 
  return 1;
}

void mouseClicked() {
  if (!file.isPlaying()) {
    file.play();
  } else {
    file.pause();
  }
}

void showGridHelper(){
  beginShape();
  fill(0,255,0);
  stroke(0,255,0);
  line(0,0,0,0,0,2000);
  line(0,0,0,0,height,0);
  line(0,0,0,width,0,0);
  endShape();
}

void showMouse(){
  beginShape();
  textSize(200);
  fill(255);
  text(mouseX, 0, height/3);
  text(mouseY, 0, 100+height/3);
  endShape(); 
}

void readSongDir(){
 File[] files = new File(songDir).listFiles();
  
  for(File file : files){
    if(!file.isDirectory() && !file.getName().contains("flac")){
      songs.add(file.getPath()); 
    }
  } 
}

String randomSong(){
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
 if (event.getKeyCode() == '1') {
  file.stop();
    file.removeFromCache();
    loadSong();
  }
  if(event.getKeyCode() == 38 && smoothing<0.8){
    smoothing+= 0.030;
    println(smoothing);
  }
  if(event.getKeyCode() == 40 && smoothing>=0.05){
    smoothing-=0.030;
    println(smoothing);
  }
}

private void setVolume() {
  file.amp(volume / 100.0f);
} 
  
private void loadSong() {
  file = new SoundFile(this, randomSong());
  if(file != null){
    file.amp(volume / 100f);
    fft.input(file);
    if (!file.isPlaying()) {
      file.play();
    }
  }
  
}
