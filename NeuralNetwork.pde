class NeuralNetwork implements Cloneable{
  private int layerAmount;
  private ArrayList<Layer> layerList = new ArrayList();
  
  
  /*
    Constructor for NeuralNetwork using an int array, produces random weights
  */
  public NeuralNetwork(int [] layerArray){
    this.layerAmount = layerArray.length;
    
    
    for(int i = 0; i < layerAmount; i++){
      layerList.add(new Layer(layerArray[i]));
    }
    
    //connect each of the layers
    for(int i = 0; i < layerAmount - 1; i++){
      layerList.get(i).connectOutputLayer(layerList.get(i + 1)); 
      layerList.get(i).makeWeights(layerList.get(i + 1), 1);
    }
  }
  
  /*
    Constructor for the NeuralNetwork using an already existsing NerualNetwork, deep copies all its contents
  */
  private NeuralNetwork(NeuralNetwork nn){
    this.layerAmount = nn.layerAmount;
    for(Layer currentLayer : nn.layerList){
      layerList.add(new Layer(currentLayer));
    }
    
    for(int i = 0; i < layerAmount - 1; i++){
      layerList.get(i).connectOutputLayer(layerList.get(i + 1)); 
    }
  }
  
  /*
    Outputs the values where input values are given.
  */
  public float[] solve(float[] inputArray){
    layerList.get(0).replaceInputArray(inputArray);
    
    for(int i = 0; i < layerList.size() - 1; i++){
      layerList.get(i).propagate();
    }
    
    // Used for debugging
    //for(Layer currentLayer : layerList){
    //  float[] array = currentLayer.getOutputArray();
    //  StringBuilder stringBuilder = new StringBuilder("[");
    //  for(int i = 0; i < array.length; i++){
    //    stringBuilder.append(" ");
    //    stringBuilder.append(array[i]);
    //    stringBuilder.append(",");
    //  }
    //  stringBuilder.append("]");
    //  System.out.println(stringBuilder.toString());
    //}
    
    return layerList.get(layerList.size() - 1).getInputValuesArray();
  }
  
  /*
    Mutates the NeuralNetwork by a given mutationRate and mutationAmount
  */
  public NeuralNetwork mutate(float mutationRate, float mutationAmount){
    //NeuralNetwork nn = this.clone();
    
    NeuralNetwork nn = new NeuralNetwork(this);
    
    for(int i = 0; i < layerAmount - 1; i++){
      nn.layerList.get(i).connectOutputLayer(nn.layerList.get(i + 1)); 
    }
    
    for(int i = 0; i < layerAmount - 1; i++){
      nn.layerList.get(i).mutateWeights(mutationRate, mutationAmount); 
    }
    
    return nn;
  }
  
  public NeuralNetwork copy(){
    return new NeuralNetwork(this);
  }
  
  public void setWeights(float[] newWeights){
    layerList.get(1).setWeights1DArray(newWeights);
  }
  
  public float[] getWeightsFrom2nd(){
    return layerList.get(1).getFirstArray();
  }
  
  
  
  @Override
  public NeuralNetwork clone(){
    try{
      NeuralNetwork nn = (NeuralNetwork)super.clone();
      nn.layerList = (ArrayList<Layer>)layerList.clone();
      return nn;
    } catch(CloneNotSupportedException e){
      return null;
    }
  }
  
  @Override
  public String toString(){
    StringBuilder stringBuilder = new StringBuilder("[\n");
    for(Layer currentLayer : layerList){
      stringBuilder.append("\t");
      stringBuilder.append(currentLayer.toString());
      stringBuilder.append(",\n");
    }
    stringBuilder.append("]");
    return stringBuilder.toString();
  }
}
