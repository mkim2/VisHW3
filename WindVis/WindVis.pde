 // uwnd stores the 'u' component of the wind.
 // The 'u' component is the east-west component of the wind.
 // Positive values indicate eastward wind, and negative
 // values indicate westward wind.  This is measured
 // in meters per second.
 Table uwnd;
 
 // vwnd stores the 'v' component of the wind, which measures the
 // north-south component of the wind.  Positive values indicate
 // northward wind, and negative values indicate southward wind.
 Table vwnd;
 
 // An image to use for the background.  The image I provide is a
 // modified version of this wikipedia image:
 //https://commons.wikimedia.org/wiki/File:Equirectangular_projection_SW.jpg
 // If you want to use your own image, you should take an equirectangular
 // map and pick out the subset that corresponds to the range from
 // 135W to 65W, and from 55N to 25N
 PImage img;
 float globalX;
 float globalY;
 
 HashMap<Integer, Particle> drawnParticles = new HashMap<Integer, Particle>();
 void setup() {
   // If this doesn't work on your computer, you can remove the 'P3D'
   // parameter.  On many computers, having P3D should make it run faster
   size(700, 400, P3D);
   pixelDensity(displayDensity());
   
   img = loadImage("background.png");
   uwnd = loadTable("uwnd.csv");
   vwnd = loadTable("vwnd.csv");
   
 }
 
 void draw() {
   background(255);
   image(img, 0, 0, width, height);
   strokeWeight(2);
   drawMouseLine();
  
   for(int i = 0; i <1000; i++) {
   float randomX = random(0, 700);
   float randomY = random(0, 400);
   float randomLifeCycle = random (0, 200);
   Particle particle = new Particle(randomX, randomY, (int)randomLifeCycle, vwnd);
   drawnParticles.put(i, particle);
   }
   for (Integer x: drawnParticles.keySet()){
     Particle par = drawnParticles.get(x);
     int cycle = (int) par.lifeCycle;
     if(par.age <= cycle) {
       par.update(par.x, par.y, vwnd);
     }
   }
 }
 
 void drawMouseLine() {
   // Convert from pixel coordinates into coordinates
   // corresponding to the data.
   float a = mouseX * uwnd.getColumnCount() / width;
   float b = mouseY * uwnd.getRowCount() / height;
   
   // Since a positive 'v' value indicates north, we need to
   // negate it so that it works in the same coordinates as Processing
   // does.
   float dx = readInterp(uwnd, a, b) * 10;
   float dy = -readInterp(vwnd, a, b) * 10;
   line(mouseX, mouseY, mouseX + dx, mouseY + dy);
 }
 
  // Reads a bilinearly-interpolated value at the given a and b
  // coordinates.  Both a and b should be in data coordinates.
  float readInterp(Table tab, float a, float b) {
   int x1 = (int)a;
   int y2 = (int)b;
   int y1 = y2 + 1;
   int x2= x1 +1;
   float x = a;
   float y = b;
    
    // TODO: do bilinear interpolation
   if (a < 0) {
     a = 0;
   }
   if(a >= tab.getColumnCount()) {
     a = tab.getColumnCount() - 1;
   }
   if (b < 0) {
     b = 0;
   }
   if(b >= tab.getRowCount()){
     b = tab.getRowCount() - 1;
   }
    float R1= (((x2-x)*(readRaw(tab,y1,x1)))+((x-x1)*(readRaw(tab,y1,x2))))/(x2-x1);
    float R2 = (((x2-x)*(readRaw(tab, x1,y2)))+((x-x1)*(readRaw(tab,x2,y2))))/(x2-x1);
    float P = (((y2-y)*R1)+((y-y1)*R2))/(y2-y1);
    //System.out.println(P);
   return P;
  }

  void drawParticle(float x, float y, int lifeCycle, Table tab) {

  float stepSize = 0.1;
  float newX;
  float newY;
    float age = 1;

    stroke(255, 20, 147);
    if(age < lifeCycle) {
    beginShape(POINTS);
    strokeWeight(4);
    vertex(x,y);
      
    //Runge Kutta
    float k1 = stepSize * readInterp(tab, x, y);
    float k2 = stepSize * readInterp(tab, x + (1/2*k1), y + (1/2*stepSize));
    float k3 = stepSize * readInterp(tab, x + (1/2*k2), y + (1/2*stepSize));
    float k4 = stepSize * readInterp(tab, x + k3, y + stepSize);
    newY = y + (1/6)*k1 + (1/3)*k2 + (1/3)*k3 + (1/6)*k4;
    newX = x + stepSize;
    globalX = newX;
    globalY = newY;
    age++;
    if (age == lifeCycle-1) {
      age = 1;
    }
    endShape();
    }
  }
  
  // Reads a raw value 
  float readRaw(Table tab, int x, int y) {
   if (x < 0) {
     x = 0;
   }
   if (x >= tab.getColumnCount()) {
     x = tab.getColumnCount() - 1;
   }
   if (y < 0) {
     y = 0;
   }
   if (y >= tab.getRowCount()) {
     y = tab.getRowCount() - 1;
   }
   return tab.getFloat(y,x);
 } 