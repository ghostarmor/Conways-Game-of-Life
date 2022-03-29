
Cell[][] grid;
int length = 100;
int cellSize = 20;
boolean running = false;
ArrayList<Cell> hovered = new ArrayList<Cell>();
HashMap<Cell, Boolean> cellsToChange = new HashMap<>();
int startTime = 0;
int lastTime = 0;
int generationSpeed = 3;
float intervalMillis = 1000/generationSpeed;
boolean shiftHeld;
int currentGeneration = 0;

//Setup
void setup(){
  fullScreen();
  grid = new Cell[length][length];
  for(int i = 0; i < length; i++){
    for(int j = 0; j < length; j++){
      grid[i][j] = new Cell(i*cellSize, j*cellSize, cellSize, cellSize);
    }
  }
}

//Drawing function
void draw(){
  background(0);
  boolean isNewGen = false;
  if(millis() - lastTime >= intervalMillis && running){
    isNewGen = true;
  }
  
  
  for(int i = 0; i < length; i++){
    for(int j = 0; j < length; j++){
      if(isNewGen){
        //Code in here for life/death logic
        
        Cell cell = grid[i][j];
        int neighbours = getNeighbours(i, j);
        cellsToChange.put(cell,cell.willLive(neighbours));
      }
      grid[i][j].display();
    }
  }
  
  for(Cell cell : cellsToChange.keySet()){
    cell.toggleLife(cellsToChange.get(cell));
    cell.display();
  }
  cellsToChange.clear();
  
  if(isNewGen){
    lastTime = millis();
    currentGeneration++;
  }
    
}




//Input functions
void mouseClicked(){
  if(shiftHeld){
    if(mouseButton == LEFT && !running){
      int[] cellIndex = getCellFromCoords();
      Cell cell = grid[cellIndex[0]][cellIndex[1]];
      int neighbours = getNeighbours(cellIndex[0], cellIndex[1]);
      println("Cell neighbours: " + neighbours);
      println("Cell is alive: " + cell.isAlive());
      println("Cell will live in the next generatin: " + cell.willLive(neighbours));
    }
  } else{
    setLife();
  }
  
}

void mouseDragged(){
  setLife();
  overlaySelection();
}

void keyPressed(){
  if(key == ' '){
    if(running) println("Current generation: " + currentGeneration);
    running = !running;
    
    if(running && startTime == 0) 
      startTime = millis();
  }
  if(keyCode == SHIFT){
    shiftHeld = true;
  } else{
    shiftHeld = false;
  }
  
  if(key == BACKSPACE && !running){
    for(int i = 0; i < length; i++){
      for(int j = 0; j < length; j++){
        grid[i][j].toggleLife(false);
      }
    }
  }
}

void mouseMoved(){
  overlaySelection();
}


//Logical functions
void setLife(){
  if(!running){
    //Must get 2d array index to get cell that was clicked (can access through mouse x and y coords with a bit of math)
    int[] cellIndex = getCellFromCoords();
    int i = cellIndex[0];
    int j = cellIndex[1];
    grid[i][j].toggleLife(mouseButton == LEFT);
    grid[i][j].display();
    
    
  }
}

void overlaySelection(){
  int[] cellIndex = getCellFromCoords();
  Cell hoveredOver = grid[cellIndex[0]][cellIndex[1]];
  hoveredOver.toggleHover();
  hoveredOver.display();
  for(Cell cell : hovered){
    cell.toggleHover();
    cell.display();
  }
  hovered.clear();
  hovered.add(hoveredOver);
}

int[] getCellFromCoords(){
  int[] res = {constrain(floor(mouseX/cellSize), 0, length-1), constrain(floor(mouseY/cellSize), 0, length-1)};
  return res;
}

boolean indexOutOfBounds(int index){
  return index < 0 || index >= length;
}


int getNeighbours(int i, int j){
  int count = 0;
  //Must get adjacent cells (+i = right, -i = left, +j = down, -j = up)
        
        //Check direct right
        if(!indexOutOfBounds(i+1)){
          Cell right = grid[i+1][j];
          if(right.isAlive()){
            count++;
          }
        }
        
        //Check bottom-right
        if(!indexOutOfBounds(i+1) && !indexOutOfBounds(j+1)){
          Cell botRight = grid[i+1][j+1];
          if(botRight.isAlive()){
            count++;
          }
        }
        
        //Check direct down
        if(!indexOutOfBounds(j+1)){
          Cell down = grid[i][j+1];
          if(down.isAlive()){
            count++;
          }
        }
        
        //Check bottom-left
        if(!indexOutOfBounds(i-1) && !indexOutOfBounds(j+1)){
          Cell botLeft = grid[i-1][j+1];
          if(botLeft.isAlive()){
            count++;
          }
        }
        
        //Check direct left
        if(!indexOutOfBounds(i-1)){
          Cell left = grid[i-1][j];
          if(left.isAlive()){
            count++;
          }
        }
        
        //Check top-left
        if(!indexOutOfBounds(i-1) && !indexOutOfBounds(j-1)){
          Cell topLeft = grid[i-1][j-1];
          if(topLeft.isAlive()){
            count++;
          }
        }
        
        //Check direct up
        if(!indexOutOfBounds(j-1)){
          Cell up = grid[i][j-1];
          if(up.isAlive()){
            count++;
          }
        }
        
        //Check top-right
        if(!indexOutOfBounds(i+1) && !indexOutOfBounds(j-1)){
          Cell topRight = grid[i+1][j-1];
          if(topRight.isAlive()){
            count++;
          }
        }
  return count;        
}




//Cell class

class Cell{
  
  float x, y;
  float width, height;
  boolean alive = false;
  boolean hoveredOver = false;
  
  Cell(float tempX, float tempY, float tempW, float tempH){
    x = tempX;
    y = tempY;
    width = tempW;
    height = tempH;
  }
  
  boolean isAlive(){
    return alive;
  }
  
  
  void toggleLife(){
    alive = !alive;
  }
  
  void toggleLife(boolean life){
    alive = life;
  }
  
  void toggleHover(){
    hoveredOver = !hoveredOver;
  }
  

  
  
  boolean willLive(int neighbours){
    if(alive){
      //Live cell with fewer than 2 neighbours dies as by underpopulation, live cell with greater than 3 neighbours dies as by overpopulation
      if(neighbours < 2 || neighbours > 3){
        return false;
      }
      
      
      //Live cell with 2 or 3 neighbours remains alive
      return true;
    } else {
      //Dead cell with 3 neighbours becomes alive as by reproduction
      if(neighbours == 3){
        return true;
      }
      //Dead cells without exactly 3 neighbours remain dead
      return false;
    }
    
    
  }
  
  
  
  void display(){
    
    stroke(255);
    
    
    
    if(alive){
      fill(#f5de33);
    } else{
      fill(150);
    }
    rect(x, y, width, height);
    
    if(hoveredOver){
      if(!running){
        fill(#2165B3, 50f);
      } else{
        fill(#b02a43, 50f);
      }
      
      rect(x, y, width, height);
      
    }
    
  }
  
}
