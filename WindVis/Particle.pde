class Particle {
  
  float x;
  float y;
  float lifeCycle;
  float stepSize = 0.1;
  int age;
  
  Particle(float x, float y, int lifeCycle, Table tab) {
    this.x = x;
    this.y = y;
    this.lifeCycle = lifeCycle;
  }
  
  void update(float x, float y, Table tab) {
    
    stroke(255, 20, 147);
    beginShape(POINTS);
    strokeWeight(4);
    vertex(x,y);
    //Runge Kutta
    float k1 = stepSize * readInterp(tab, x, y);
    float k2 = stepSize * readInterp(tab, x + (1/2*k1), y + (1/2*stepSize));
    float k3 = stepSize * readInterp(tab, x + (1/2*k2), y + (1/2*stepSize));
    float k4 = stepSize * readInterp(tab, x + k3, y + stepSize);
    
    float newY = y + (1/6)*k1 + (1/3)*k2 + (1/3)*k3 + (1/6)*k4;
    float newX = x + stepSize;
    
    x = newX;
    y = newY;

    endShape();
      
   }

//  float getX(){
//    return x;
//  }
//  float getY(){
//    return y;
//  }
//  int getLifeCycle(){
//  return (int)lifeCycle;
//}

}