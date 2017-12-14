// uwnd stores the 'u' component of the wind.
// The 'u' component is the east-west component of the wind.
// Positive values indicate eastward wind, and negative
// values indicate westward wind.  This is measured
// in meters per second.
Table uwnd;

// vwnd stores the 'v' component of the wind, which measures the
// north-south component of the wind. Positive values indicate
// northward wind, and negative values indicate southward wind.
Table vwnd;

// An image to use for the background.  The image I provide is a
// modified version of this wikipedia image:
//https://commons.wikimedia.org/wiki/File:Equirectangular_projection_SW.jpg
// If you want to use your own image, you should take an equirectangular
// map and pick out the subset that corresponds to the range from
// 135W to 65W, and from 55N to 25N
PImage img;

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
  drawMouseLine();
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
  //int x = int(a);
  //int y = int(b);
  
  float xy = 0;
  
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
  
  for(int u = 0; u < tab.getColumnCount(); u++) {
    for(int v = 0; v < tab.getRowCount(); v++) {
      if ((a > u) && (a < u+1) && (b < v) && ( b < v+1)) {
        float x1 = (((u+1)-(a))/((u+1)-(u))*(tab.getFloat((int)v+1,(int)u)))+(((a-u)/((u+1)-(u)))*(tab.getFloat((int)v+1,(int)u+1)));
        float x2 = (((u+1)-(a))/((u+1)-(u))*(tab.getFloat((int)v,(int)u)))+(((a-u)/((u+1)-(u)))*(tab.getFloat((int)v,(int)u+1)));
        xy = (((v-b)/v-(v+1))*x1) + (((b-(v+1))/(v-(v+1)))*x2);
    }
    }
    println(xy);
  }
  
  
  
  return xy;
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