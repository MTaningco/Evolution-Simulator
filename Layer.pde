class Layer implements Cloneable{
  private float[] inputValues;// This is where to store all the outputs of this layer
  private float[][] weightsArray = null;
  private float[] outputLayerOutputArray = null;// This is where this layer will output to
  
  // Creates a Layer with 0 initialized output nodes
  public Layer(int nodeAmount){
    //this.outputAmount = outputAmount;
    this.inputValues = new float[nodeAmount];
    
    for(int i = 0; i < nodeAmount; i++){
      inputValues[i] = 0;
    }
  }
  
  // Layer deep copy
  public Layer(Layer layerToCopy){
    this.inputValues = new float[layerToCopy.inputValues.length];
    if(layerToCopy.weightsArray != null){
      this.weightsArray = new float[layerToCopy.weightsArray.length][layerToCopy.weightsArray[0].length];
      for(int i = 0; i < layerToCopy.weightsArray.length; i++){
        for(int j = 0; j < layerToCopy.weightsArray[i].length; j++){
          this.weightsArray[i][j] = layerToCopy.weightsArray[i][j];
        }
      }
    }
  }
  
  // Connect to the outputLayer and make the appropriate amount of biases with randomly initialized stuff
  public void connectOutputLayer(Layer outputLayer){
    this.outputLayerOutputArray = outputLayer.getInputValuesArray();
  }
  
  /*
    This makes the random weights
  */
  public void makeWeights(Layer outputLayer, float magnitude){
    weightsArray = new float[outputLayer.nodeCount()][nodeCount() + 1];//plus one is for the bias weight
    
    for(int i = 0; i < outputLayer.nodeCount(); i++){
      for(int j = 0; j < nodeCount() + 1; j++){
        weightsArray[i][j] = random(-magnitude, magnitude);
      }
    }
  }
  
  public void propagate(){
    for(int i = 0; i < outputLayerOutputArray.length; i++){
      outputLayerOutputArray[i] = 0;
      for(int j = 0; j < weightsArray[i].length - 1; j++){
        outputLayerOutputArray[i] += inputValues[j] * weightsArray[i][j];
      }
      outputLayerOutputArray[i] += weightsArray[i][inputValues.length];//bias weight
      outputLayerOutputArray[i] = 2/PI * atan(outputLayerOutputArray[i]);
    }
  }
  
  public void replaceInputArray(float[] inputArray){
    for(int i = 0; i < inputValues.length; i++){
      inputValues[i] = inputArray[i];
    }
  }
  
  //public void setWeightsArray(float[][] newWeights){
  //  weightsArray = newWeights;//TODO: is this a deep copy or shallow copy?
  //}
  
  public void setWeights1DArray(float[] newWeights){
    if(newWeights.length != weightsArray[0].length){
      throw new RuntimeException("your new weights does not equal the actual length: " + weightsArray[0].length);
    }
    
    weightsArray[0] = newWeights;
  }
  
  public float[] getFirstArray(){
    return weightsArray[0];
  }
  
  // Gets how many output nodes are in this layer
  public int nodeCount(){
    return inputValues.length;
  }
  
  //gets the array of nodes
  public float[] getInputValuesArray(){
    return inputValues;
  }
  
  public void mutateWeights(float mutationRate, float mutationAmount){
    for(int i = 0; i < weightsArray.length; i++){
      for(int j = 0; j < weightsArray[i].length; j++){
        if(random(1) < mutationRate){
          weightsArray[i][j] += random(-mutationAmount, mutationAmount);
        }
      }
    }
  }
  
  
  
  @Override
  public String toString(){
    StringBuilder stringBuilder = new StringBuilder("[\n");
    if(weightsArray != null){
      for(int i = 0; i < weightsArray.length; i++){
        stringBuilder.append("\t\t");
        for(int j = 0; j < weightsArray[i].length; j++){
          stringBuilder.append(weightsArray[i][j]);
          stringBuilder.append(" ");
        }
        stringBuilder.append("\n");
      }
    }
    
    stringBuilder.append("\t]");
    return stringBuilder.toString();
  }
  
  @Override
  public Layer clone(){
    try{
      Layer layer = (Layer)super.clone();
      layer.inputValues = (float[])inputValues.clone();
      layer.weightsArray = (float[][])weightsArray.clone();
      //TODO: need to connect this to the next output layer
      return layer;
    } catch(CloneNotSupportedException e){
      return null;
    }
  }
}
