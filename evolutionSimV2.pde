public static final float ACTIVITY_WIDTH = 1300;
public static final float ACTIVITY_HEIGHT = 1300;
World w;

public void settings(){
  size((int)ACTIVITY_WIDTH, (int)ACTIVITY_HEIGHT);
}

void setup() {
  w = new World(100, (int)ACTIVITY_WIDTH, 0.06, 1);
  //noLoop();
} 

void draw(){
  w.draw();
  w.simulate();
}
