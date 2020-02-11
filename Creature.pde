class Creature{
  private final float mutationRate = 0.001;
  private final float maxMutationAmount = 0.1;
  private final int inputSize = 11;
  private final float maxFoodBar = 100;
  private final float maxHealthMeter = 100;
  
  private World world;
  
  //for drawing
  private float x;
  private float y;
  
  //for the programmer
  private boolean isBrainEvolve;//set to true when training the brain
  private boolean isCharacteristicsEvolve;//set to true when running the actual simulation
  
  //can be changed by brain
  private float speed;
  private float angleDirection;//0 to 2pi
  
  //depletes and regenerates
  private float healthMeter;//max to 100
  private float foodBar;//max to 100
  private float currentAge;//max to maxAge
  
  //static internal characteristics, inheritable, non derivable
  private String signifier;//this is your hypothetical DNA, make a markov chain machine
  private color creatureColorHue;
  private float baseWeight;//base weight of the species
  private float metabolism;//shows how fast you lose energy and how fast you can move
  private float comfortableTemp;//shows where health regenerates naturally
  private float comfortableElevation;//shows where health regenerates naturally
  private NeuralNetwork neuralNetwork;
  
  //static deterministic internal characteristics
  private float visibilityDistance;//shows how far you can see for predators, visibility is proportionate to metabolism
  private float foodChainStanding;//shows what you can eat, proportionate to base weight and metabolism
  private float maxSpeed;//shows how fast you can travel around, derivable from metabolism, proportionate to metabolism
  private float maxAge;//shows the age at which you can go till, inversely proportionate to metabolism
  private float matureAge;//shows when the creature can reproduce asexually
  private int maxBirths;//shows how many at most the creature can reproduce, proportionate to metabolism and baseWeight, high metabolism causes higher births, high baseWeight causes lower births
  private float radius;
  
  public Creature(World world, float x, float y){
    speed = 0;
    angleDirection = random(2*PI);
    
    healthMeter = 100;
    foodBar = 100;
    
    signifier = "a";
    creatureColorHue = 0;
    baseWeight = 10;
    metabolism = 1;
    
    foodChainStanding = metabolism + baseWeight;
    visibilityDistance = world.getUnitLength() * metabolism;
    maxSpeed = metabolism * 1;
    maxAge = 10.0/metabolism;
    matureAge = maxAge/2.0;
    maxBirths = (int)(20 * metabolism / baseWeight);
    radius = baseWeight;
    
    int[] layers = {inputSize, 6, 6, 1};
    neuralNetwork = new NeuralNetwork(layers);
    
    this.world = world;
    this.x = x;
    this.y = y;
  }
  
  public float getX(){
    return x;
  }
  
  public float getY(){
    return y;
  }
  
  public float getRanking(){
    return foodChainStanding;
  }
  
  public float getHealth(){
    return healthMeter;
  }
  
  public void setHealth(float value){
    healthMeter = 0;
  }
  
  public void draw(){
    colorMode(HSB);
    stroke(1);
    fill(creatureColorHue%256, map(healthMeter, 0, 100, 0, 255), 255);
    ellipse(x, y, radius, radius);
    colorMode(RGB);
    
    drawLine(angleDirection);
  }
  
  public void simulate(ArrayList<Creature> birthList, ArrayList<Creature> killList){//not sure if i need the kill list, i probably do
    //
    
    //move according to the brain and the environment, current elevation, current temp, direction of highest veg, direction of highest/lowest rank
    WorldCell wc = world.getWorldCell(y, x);
    
    float[] input = new float[inputSize];
    input[0] = map(wc.getElevation(), -10, 10, -1, 1);
    input[1] = map(wc.getTemperature(), -10, 10, -1, 1);
    input[2] = map(getHighestElevationDirection(), -PI, PI, -1, 1);
    input[3] = map(getHighestTempDirection(), -PI, PI, -1, 1);
    
    input[4] = map(averageVegDirection(), -PI, PI, -1, 1);
    
    input[5] = map(comfortableElevation, -10, 10, -1, 1);
    input[6] = map(comfortableTemp, -10, 10, -1, 1);
    
    input[7] = map(getHighestRankingDirection(), -PI, PI, -1, 1);
    input[8] = map(getLowestRankingDirection(), -PI, PI, -1, 1);
    
    input[9] = map(healthMeter, 0, 100, 0, 1);
    input[10] = map(foodBar, 0, 100, 0, 1);
    
    float[] output = neuralNetwork.solve(input);
    
    
    //move to that direction using the brain
    
    angleDirection += output[0];
    angleDirection = standardizeAngle(angleDirection);
    move();
    constrainPosition();
    
    //update food and health meters, set any creature to isDead if necessary
    
    //eat a creature that is touching you that also has a lower standing than you, put the other creature into the kill list of the world.
    //if food bar not yet full, eat the vegetation that is on you
    
    ArrayList<Creature> preyList = world.getPreyListWithinCircle(this.x,this.y,this.radius,this);
    for(Creature prey : preyList){
      float usableNutrients = prey.getHealth() * 0.5;
      //add this onto your foodbar
      foodBar += usableNutrients;
      prey.setHealth(0);//this kills the prey
    }
    
    if(foodBar < maxFoodBar){
      //eat the thing below you
      
    }
    
    //update other internal characteristics
    
    //see if you can birth
    
    //die if you can 
  }
  
  //done check
  private float averageVegDirection(){
    //sum up the coordinate value * vegAmount, average that out, turn that into a direction
    
    float vegXSum = 0;
    float vegYSum = 0;
    float creatureXMid = world.getWorldCell(y, x).getXMid();
    float creatureYMid = world.getWorldCell(y, x).getYMid();
    float unitLength = world.getUnitLength(); 
    
    for(float curYCoord = (creatureYMid - visibilityDistance); curYCoord <= (creatureYMid + visibilityDistance); curYCoord+=unitLength){
      for(float curXCoord = (creatureXMid - visibilityDistance); curXCoord <= (creatureXMid + visibilityDistance); curXCoord+=unitLength){
        WorldCell wc = world.getWorldCell(curYCoord, curXCoord);
        if(wc != null){
          float veg = wc.getVegetation();
          vegXSum += veg * (curXCoord-x);
          vegYSum += veg * (curYCoord-y);
        }
      }
    }
    
    float magnitude = sqrt(vegXSum*vegXSum + vegYSum*vegYSum);
    vegXSum /= magnitude > 0 ? magnitude : 1;
    vegYSum /= magnitude > 0 ? magnitude : 1;
    
    return getDirection(vegXSum, vegYSum, angleDirection, angleDirection);//returning 0 - 2pi

  }
  
  private float getDirection(float xDirection, float yDirection, float defaultDirection, float directionOfTravel){//the x and y direction are wrt the creature
    
    if(xDirection == 0 && yDirection == 0){
      return getAngleDifference(defaultDirection, directionOfTravel);
    }
    float atanValue = atan(yDirection/xDirection);
    
    if(xDirection < 0){
      atanValue += PI;
    }
    else if(xDirection > 0 && yDirection < 0){
      atanValue += 2*PI;
    }
    
    return getAngleDifference(atanValue, angleDirection);//returning 0 - 1
  }
  
  private float getAngleDifference(float angleToCheck, float referenceAngle){
    float angleDiff = angleToCheck - referenceAngle;
    float signMaker = (angleDiff - PI)/abs(angleDiff - PI);
    float extraTermMaker = (int)(abs(angleDiff)/PI)*2*PI;
    return angleDiff - signMaker*extraTermMaker;
    
  }
  
  private float getHighestRankingDirection(){
    ArrayList<Creature> list = world.getCreatureListWithBounds(x - visibilityDistance,y - visibilityDistance,x + visibilityDistance,y + visibilityDistance);
    if(list.size() == 0){
      return getAngleDifference(getOppositeDirection(), angleDirection);
    }
    else{
      float xDirection = list.get(list.size() - 1).getX() - x;
      float yDirection = list.get(list.size() - 1).getY() - y;
      return getDirection(xDirection, yDirection, getOppositeDirection(), angleDirection);
    }
  }
  
  private float getLowestRankingDirection(){
    ArrayList<Creature> list = world.getCreatureListWithBounds(x - visibilityDistance,y - visibilityDistance,x + visibilityDistance,y + visibilityDistance);
    if(list.size() == 0){
      return 0;
    }
    else{
      float xDirection = list.get(0).getX() - x;
      float yDirection = list.get(0).getY() - y;
      return getDirection(xDirection, yDirection, angleDirection, angleDirection);
    }
  }
  
  //done check
  private float getHighestTempDirection(){
    float maxTempX = x;
    float maxTempY = y;
    float maxTemp = -Float.MAX_VALUE;
    float creatureXMid = world.getWorldCell(y, x).getXMid();
    float creatureYMid = world.getWorldCell(y, x).getYMid();
    float unitLength = world.getUnitLength(); 
    for(float curYCoord = (creatureYMid - visibilityDistance); curYCoord <= (creatureYMid + visibilityDistance); curYCoord+=unitLength){
      for(float curXCoord = (creatureXMid - visibilityDistance); curXCoord <= (creatureXMid + visibilityDistance); curXCoord+=unitLength){
        WorldCell wc = world.getWorldCell(curYCoord,curXCoord);
        if(wc != null && wc.getTemperature() > maxTemp){
          maxTemp = wc.getTemperature();
          maxTempX = wc.getXMid();
          maxTempY = wc.getYMid();
        }
      }
    }
  
    float xDirection = maxTempX - x;
    float yDirection = maxTempY - y;
    
    WorldCell wcCreature = world.getWorldCell(y, x);
    WorldCell wcMax = world.getWorldCell(maxTempY, maxTempX);
    if(wcCreature == wcMax){
      xDirection = 0;
      yDirection = 0;
    }
    
    xDirection = 0;
    float magnitude = sqrt(xDirection*xDirection + yDirection*yDirection);
    xDirection /= magnitude > 0 ? magnitude : 1;
    yDirection /= magnitude > 0 ? magnitude : 1;
    
    return getDirection(xDirection, yDirection, angleDirection, angleDirection);//returning 0 - 2pi
  }
  
  //done check
  private float getHighestElevationDirection(){
    float maxElevX = x;
    float maxElevY = y;
    float creatureXMid = world.getWorldCell(y, x).getXMid();
    float creatureYMid = world.getWorldCell(y, x).getYMid();
    float maxElev = -Float.MAX_VALUE;
    float unitLength = world.getUnitLength(); 
    for(float curYCoord = (creatureYMid - visibilityDistance); curYCoord <= (creatureYMid + visibilityDistance); curYCoord+=unitLength){
      for(float curXCoord = (creatureXMid - visibilityDistance); curXCoord <= (creatureXMid + visibilityDistance); curXCoord+=unitLength){
        WorldCell wc = world.getWorldCell(curYCoord,curXCoord);
        if(wc != null && wc.getElevation() > maxElev){
          maxElev = wc.getElevation();
          maxElevX = wc.getXMid();
          maxElevY = wc.getYMid();
        }
      }
    }
  
    float xDirection = maxElevX - x;
    float yDirection = maxElevY - y;
    
    WorldCell wcCreature = world.getWorldCell(y, x);
    WorldCell wcMax = world.getWorldCell(maxElevY, maxElevX);
    if(wcCreature == wcMax){
      xDirection = 0;
      yDirection = 0;
    }
    
    float magnitude = sqrt(xDirection*xDirection + yDirection*yDirection);
    xDirection /= magnitude > 0 ? magnitude : 1;
    yDirection /= magnitude > 0 ? magnitude : 1;
    
    return getDirection(xDirection, yDirection, angleDirection, angleDirection);//returning 0 - 2pi
  }
  
  private float getOppositeDirection(){
    return (angleDirection + PI)%2*PI;
  }
  
  private void drawLine(float angle){
    float xDirection = cos(angle) * 50 + x;
    float yDirection = sin(angle) * 50 + y;
    
    line(x, y, xDirection, yDirection);
  }
  
  private float standardizeAngle(float angleInRadians){
    return (angleInRadians+2*PI)%(2*PI);
  }
  
  private void constrainPosition(){
    x = x < 0 ? 0 : x;
    x = x > world.getPix() ? world.getPix() : x;
    y = y < 0 ? 0 : y;
    y = y > world.getPix() ? world.getPix() : y;
  }
  
  private void move(){
    //using the specific direction and magnitude of the speed, move that way
    float xDirection = cos(angleDirection) * speed + x;
    float yDirection = sin(angleDirection) * speed + y;
  }
}
