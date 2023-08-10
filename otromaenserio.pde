import processing.sound.*;
import java.util.ArrayDeque;

SoundFile file;
AudioIn in;
FFT fft;

int cols, rows;
int bands = 32;
float w;
float[] spectrum = new float[bands];
ArrayDeque<float[]> data = new ArrayDeque<>();
final int maxEle = 100;

void setup(){
  size(displayWidth, displayHeight, P3D);
  background(150);
  file = new SoundFile(this, "song.wav");
  fft= new FFT(this, bands);
  fft.input(file);
  w = width / bands;
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
  
  //showMouse();
  showGridHelper();
  
  //file.sampleRate() devuelve freq. muestreo, con eso se pueden calcular fBins y pintar con exactitud
  //lo siguiente es almacenar cada iteracion del spectrum en un arrayDeque y hacer que se desplaze hacia abajo
  //las muestras antiguas y que se vaya mostrando arriba del todo la nueva muestra (iteracion actual) de spectrum
  background(0);
  stroke(0);
  for(int i = 1; i < bands; i++){
    float amp = spectrum[i];
    float y =  min(height,amp * height *15);
    
    stroke(130, 255, 0);
    line(i*w + w/2, height, i*w + w/2, height - y );
    
    stroke(255,255/(i+1),i);
    fill(0,0,0,0);
    rect(i*w,height-y, w, height);
  }
  
  
  
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
