import processing.sound.*;

SoundFile file;
AudioIn in;
FFT fft;

int cols, rows;
int bands = 32;
float w;
float[] spectrum = new float[bands];

void setup(){
  size(displayWidth, displayHeight, P3D);
  background(150);
  file = new SoundFile(this, "song.wav");
  fft= new FFT(this, bands);
  fft.input(file);
  w = width / bands;
}

void draw(){
  background(0);
  fft.analyze(spectrum);
  stroke(0);
  
  //file.sampleRate() devuelve freq. muestreo, con eso se pueden calcular fBins y pintar con exactitud
  //lo siguiente es almacenar cada iteracion del spectrum en un arrayDeque y hacer que se desplaze hacia abajo
  //las muestras antiguas y que se vaya mostrando arriba del todo la nueva muestra (iteracion actual) de spectrum
  for(int i = 1; i < bands; i++){
    float amp = spectrum[i];
    float y =  min(height,amp * height *10);
    
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
