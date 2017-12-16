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
 
 ArrayList<Particle> particles = new ArrayList<Particle>();
 
 void setup() {
   // If this doesn't work on your computer, you can remove the 'P3D'
   // parameter.  On many computers, having P3D should make it run faster
   size(700, 400, P3D);
   pixelDensity(displayDensity());
   
   img = loadImage("background.png");
   uwnd = loadTable("uwnd.csv");
   vwnd = loadTable("vwnd.csv");
   
   for(int i = 0; i < 1000; i++) {
     float randomX = random(0, width);
     float randomY = random(0, height);
     float randomLifeCycle = random(0, 201);
     Particle particle = new Particle(randomX, randomY, (int) randomLifeCycle);
     particles.add(particle);
   }
 }
 
 void draw() {
   background(255);
   image(img, 0, 0, width, height);
   drawMouseLine();
   drawParticles();
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
   strokeWeight(2);
   line(mouseX, mouseY, mouseX + dx, mouseY + dy);
 }
 
  // Reads a bilinearly-interpolated value at the given a and b
  // coordinates.  Both a and b should be in data coordinates.
  float readInterp(Table tab, float a, float b) {
     int x1 = (int) a;
     int y2 = (int) b;
     int y1 = y2 + 1;
     int x2 = x1 + 1;
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
     float R1 = (((x2-x)*(readRaw(tab,y1,x1)))+((x-x1)*(readRaw(tab,y1,x2))))/(x2-x1);
     float R2 = (((x2-x)*(readRaw(tab,x1,y2)))+((x-x1)*(readRaw(tab,x2,y2))))/(x2-x1);
     float P = (((y2-y)*R1)+((y-y1)*R2))/(y2-y1);
     return P;
  }

  void drawParticles() {
    float stepSize = 0.1;

    stroke(255, 20, 147);
    beginShape(POINTS);
    strokeWeight(4);
    
    for(int i = 0; i < particles.size(); i++) {
      Particle p = particles.get(i);
      if(p.age < p.lifeCycle) {
        //Runge Kutta
        float yk1 = -1 * stepSize * readInterp(vwnd, p.x, p.y);
        float yk2 = -1 * stepSize * readInterp(vwnd, p.x + (1/2*stepSize), p.y + (1/2*yk1));
        float yk3 = -1 * stepSize * readInterp(vwnd, p.x + (1/2*stepSize), p.y + (1/2*yk2));
        float yk4 = -1 * stepSize * readInterp(vwnd, p.x + stepSize, p.y + yk3);
        
        float xk1 = stepSize * readInterp(uwnd, p.x, p.y);
        float xk2 = stepSize * readInterp(uwnd, p.x + (1/2*xk1), p.y + (1/2*stepSize));
        float xk3 = stepSize * readInterp(uwnd, p.x + (1/2*xk2), p.y + (1/2*stepSize));
        float xk4 = stepSize * readInterp(uwnd, p.x + xk3, p.y + stepSize);
        
        p.y = p.y + (1/6f)*yk1 + (1/3f)*yk2 + (1/3f)*yk3 + (1/6f)*yk4;
        p.x = p.x + (1/6f)*xk1 + (1/3f)*xk2 + (1/3f)*xk3 + (1/6f)*xk4;
        
        vertex(p.x, p.y);
        p.age++;
      } else {
        particles.set(i, new Particle(random(0, width), random(0, height), (int) random (0, 200)));
      }
    }
    
    endShape();
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