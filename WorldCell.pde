class WorldCell{
  private final float MAX_VEG = 100;
  
  private float elevation;
  private float vegetation;
  private float temperature;
  
  private boolean isFertile = false;
  private float sideLength;
  private float x;
  private float y;
  
  public WorldCell(float x, float y, float sideLength, float elevation, float temperature){
    this.elevation = elevation;
    this.temperature = temperature;
    this.vegetation = 0;
    this.x = x;
    this.y = y;
    this.sideLength = sideLength;
    //this.timer = 0;
    setVegetation(MAX_VEG);
    if(!isFertile){
      //println("not fertile!");
    }
  }
  
  /*
    Return the elevation of the cell
  */
  public float getElevation(){
    return elevation;
  }
  
  /*
    Return the vegetation of the cell
  */
  public float getVegetation(){
    return vegetation;
  }
  
  /*
    Return the temperature of the cell
  */
  public float getTemperature(){
    return temperature;
  }
  
  /*
    Return the x coordinate of the cell
  */
  public float getX(){
    return x;
  }
  
  /*
    Return the y coordinate of the cell
  */
  public float getY(){
    return y;
  }
  
  /*
    Return the x midpoint coordinate of the cell
  */
  public float getXMid(){
    return x + sideLength/2;
  }
  
  /*
    Return the y midpoint coordinate of the cell
  */
  public float getYMid(){
    return y + sideLength/2;
  }
  
  /*
    Increment the vegetation based on a bell curve formula
  */
  public void incrementVegetation(){
    if(isFertile){
      if(vegetation < 100){
        vegetation = 1.32980760134*exp(-0.0005*(vegetation - 50)*(vegetation - 50)/(0.32));
      }
    }
  }
  
  /*
    Add onto the vegetation because of creatures that die spontaneously
  */
  public void addVegetation(float amount){
    vegetation += amount;
  }
  
  ///*
  //  Decrease vegetation because of a creature eating the vegetation in this cell THIS WILL NO LONGER BE USED
  //*/
  //public void decrementVegetation(float amount){
  //  vegetation -= amount;
  //  vegetation = vegetation < 0 ? 0 : vegetation;
  //}
  
  /*
    Take the vegetation that can be extracted from the cell, and also update the vegetation accordingly
  */
  public float getFood(float amount){
    float originalVegetation = vegetation;
    if(vegetation - amount > 0){
      vegetation -= amount;
      return amount;
    }
    else{
      vegetation = 0;
      return originalVegetation;
    }
  }
  
  
  public void decrementTemperature(){
    temperature -= 0.5;
    setVegetation(vegetation);
  }
  
  public void incrementTemperature(){
    temperature += 0.5;
    setVegetation(vegetation);
  }
  
  public void setVegetation(float startingAmount){
    isFertile = false;
    vegetation = 0;
    float vegElevationProb = 0;
    float vegTempProb = 0;
    if(elevation < 0){
      vegElevationProb = 1/(0.4*sqrt(2*PI))*exp(-(0.25*elevation)*(0.25*elevation)/(2*0.4*0.4));
    }
    else{
      vegElevationProb = 1/(0.4*sqrt(2*PI))*exp(-0.25*(1.0/7.0*elevation)*(1.0/7.0*elevation)/(2*0.4*0.4));
    }
    
    vegTempProb = 1/(0.4*sqrt(2*PI))*exp(-0.25*(1.0/8.0*temperature)*(1.0/8.0*temperature)/(2*0.4*0.4));
    
    float vegProb = vegElevationProb * vegTempProb;
    //println("elevation = " + elevation + " probDueToElevation = " + vegElevationProb);
    //println(vegTempProb);
    //println(vegProb);
    if(random(1) < vegProb){
      isFertile = true;
      vegetation = startingAmount;
    }
  }
  
  public void draw(){
    float vegetationColor = map(vegetation, 0, 150, 0, 255);
    float temperatureColor = map(temperature, -10, 10, 0, 255);
    float elevationColor = map(elevation, -10, 10, 0, 255);
    
    //rgb
    fill(temperatureColor, vegetationColor, elevationColor);
    if(abs(elevation) < 0.5){
      stroke(1);
    }
    else{
      noStroke();
    }
    //rect(curCol * unitLength, curRow * unitLength, (curCol + 1) * unitLength, (curRow + 1) * unitLength);
    rect(x, y, sideLength, sideLength);
  }
}
