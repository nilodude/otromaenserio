import processing.sound.*;

SoundFile file;
AudioIn in;
FFT fft;

int cols, rows;
int bands = 256;
float w;
float[] spectrum = new float[bands];

void setup(){
  size(1920, 1080, P3D);
  background(150);
  file = new SoundFile(this, "song.wav");
  fft= new FFT(this, bands);
  fft.input(file);
  w = width / bands;
}

void draw(){
  background(150);
  fft.analyze(spectrum);
  stroke(0);
  for(int i = 0; i < bands; i++){
    float amp = spectrum[i];
    float y = amp* height*5;
    
    line(i*w, height, i*w, height - y );
  }
}

void mouseClicked() {
  if (!file.isPlaying()) {
    file.play();
  } else {
    file.pause();
  }
}
