class World{
  private int boardSize;//number of pixels across
  private float unitLength;
  private float[][] elevationArray;
  private float[][] temperatureArray;
  private WorldCell[][] cellArray;
  private ArrayList<Creature> creatureList;
  private ArrayList<Creature> birthList;
  private ArrayList<Creature> killList;
  
  final int HEIGHT_LIMIT = 20 * 2;
  
  World(int boardSize, float pix, float noiseSeparation, int initCreatures){//boardSize is the number of pixels across, pix is how many actual pixels there are across, initCreatures is how many starting creatures there are
    this.boardSize = boardSize;
    this.unitLength = pix/boardSize;
    elevationArray = new float[boardSize][boardSize];
    temperatureArray = new float[boardSize][boardSize];
    cellArray = new WorldCell[boardSize][boardSize];
    //this is how we generate the world
    //we want to assign values into the array 
    for(int curRow = 0; curRow < boardSize; curRow++){
      for(int curCol = 0; curCol < boardSize; curCol++){
        float elevation = noise(curCol * noiseSeparation, curRow * noiseSeparation) * HEIGHT_LIMIT - HEIGHT_LIMIT/2.0;
        float temperature = - (1/12.0 * (curRow - 50))*(1/13.0 * (curRow - 50)) + 6;
        cellArray[curRow][curCol] = new WorldCell(curCol * unitLength, curRow * unitLength, unitLength, elevation, temperature);
      }
    }
    
    creatureList = new ArrayList();
    killList = new ArrayList();
    birthList = new ArrayList();
    for(int i = 0; i < initCreatures; i++){
      creatureList.add(new Creature(this, random(pix), random(pix)));
    }
  }
  
  public float getPix(){
    return (float)boardSize * unitLength;
  }
  
  public float getUnitLength(){
    return unitLength;
  }
  
  /**
    Here is where we show the thing
  **/
  public void draw(){
    //we want to center it around 0, 0
    //println("about to show world");
    int i = 0;
    for(int curRow = 0; curRow < boardSize; curRow++){
      for(int curCol = 0; curCol < boardSize; curCol++){
        cellArray[curRow][curCol].draw();
        i++;
      }
    }
    
    for(Creature creature : creatureList){
      creature.draw();
    }
  }
  
  //public void updateWorldCells(float yCoord, float xCoord){
  //  int curRow = (int)(yCoord/unitLength);
  //  int curCol = (int)(xCoord/unitLength);
    
  //  for(int i = -1; i <= 1; i++){
  //    for(int j = -1; j <= 1; j++){
  //      updateWorldCell(curRow + i, curCol + j);
  //    }
  //  }
  //}
  
  //private void updateWorldCell(int curRow, int curCol){
  //  if((curRow >= 0 && curRow < boardSize) && (curCol >= 0 && curCol < boardSize)){
  //    int blueness = (cellArray[curRow][curCol].getElevation() < 0) ? (int)map(elevationArray[curRow][curCol], -25, 0, 120, 255) : (int)map(elevationArray[curRow][curCol], 0, 25, 200, 255);
  //    int landness = (cellArray[curRow][curCol].getElevation() < 0) ? 0 : (int)map(elevationArray[curRow][curCol], 0, 25, 255, 0);
  //    float greeness = cellArray[curRow][curCol].getVegetation();
  //    fill(landness, greeness, blueness);
  //    noStroke();
  //    rect(curCol * unitLength, curRow * unitLength, unitLength, unitLength);
  //  }
  //}
  
  public WorldCell getWorldCell(float yCoord, float xCoord){
    
    int curRow = (int)(yCoord/unitLength);
    int curCol = (int)(xCoord/unitLength);
    
    if(curRow < 0 || curRow >= boardSize ||curCol < 0 || curCol >= boardSize){
      return null;
    }
    
    return cellArray[curRow][curCol];
  }
  
  //public void decrementTemperature(){
  //  for(int i = 0; i < boardSize; i++){
  //    for(int j = 0; j < boardSize; j++){
  //      cellArray[i][j].decrementTemperature();
  //      //cellArray[i][j].setVegitation();
  //    }
  //  }
  //}
  
  //public void incrementTemperature(){
  //  for(int i = 0; i < boardSize; i++){
  //    for(int j = 0; j < boardSize; j++){
  //      cellArray[i][j].incrementTemperature();
  //      //cellArray[i][j].setVegitation();
  //    }
  //  }
  //}
  
  public float getVegetationAmount(float yCoord, float xCoord){//this grabs the vegetation on and around the cell
    int curRow = (int)(yCoord/unitLength);
    int curCol = (int)(xCoord/unitLength);
    
    float VegAmount = 0;
    for(int i = -1; i <= 1; i++){
      for(int j = -1; j <= 1; j++){
        VegAmount += cellArray[curRow][curCol].getVegetation();
      }
    }
    return VegAmount;
  }
  
  public float getVegCell(float yCoord, float xCoord){
    int curRow = (int)(yCoord/unitLength);
    int curCol = (int)(xCoord/unitLength);
    
    if(curRow < 0 || curRow >= boardSize || curCol < 0 || curCol >= boardSize){
      return 0;
    }
    
    return cellArray[curRow][curCol].getVegetation();
  }
  
  //public float 
  
  public float getElevCell(float yCoord, float xCoord){
    int curRow = (int)(yCoord/unitLength);
    int curCol = (int)(xCoord/unitLength);
    
    if(curRow < 0 || curRow >= boardSize || curCol < 0 || curCol >= boardSize){
      return 0;
    }
    
    return cellArray[curRow][curCol].getElevation();
  }
  
  public void growVegetation(){
    for(int i = 0; i < boardSize; i++){
      for(int j = 0; j < boardSize; j++){
        cellArray[i][j].incrementVegetation();
      }
    }
  }
  
  public ArrayList<Creature> getCreatureList(){
    return creatureList;
  }
  
  public ArrayList<Creature> getCreatureListWithBounds(float xMin, float yMin, float xMax, float yMax){
    ArrayList<Creature> list = new ArrayList();
    
    for(Creature creature : creatureList){
      float x = creature.getX();
      float y = creature.getY();
      if(x > xMin && x < xMax && y > yMin && y < yMax){
        list.add(creature);
      }
    }
    
    Creature lowestRanking = null;
    float lowestRankingValue = Float.MAX_VALUE;
    Creature highestRanking = null;
    float highestRankingValue = -Float.MAX_VALUE;
    
    for(Creature creature : list){
      lowestRanking = lowestRankingValue > creature.getRanking() ? creature : lowestRanking;
      highestRanking = highestRankingValue < creature.getRanking() ? creature : highestRanking;
    }
    
    list.clear();
    list.add(lowestRanking);
    list.add(highestRanking);
    return list;
  }
  
  public ArrayList<Creature> getPreyListWithinCircle(float x, float y, float radius, Creature predator){
    ArrayList<Creature> list = new ArrayList();
    
    for(Creature creature : creatureList){
      float creatureX = creature.getX();
      float creatureY = creature.getY();
      float distance = sqrt((x-creatureX)*(x-creatureX) + (y - creatureY)*(y - creatureY));
      if(distance <= radius && predator.getRanking() > creature.getRanking()){
        list.add(creature);
      }
    }
    
    return list;
  }
  
  
  public void simulate(){
    for(Creature creature : creatureList){
      creature.simulate(birthList, killList);
    }
    
    //if any of the creatures have an isDead of true, delete them
  }
}
