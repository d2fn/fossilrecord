class Navigator {
  
  int x1, x2, y1, y2;
  int visibley1, visibley2;
  
  boolean navigating = false;
  
  Navigator(int x1, int y1, int x2, int y2) {
    this.x1 = x1;
    this.x2 = x2;
    this.y1 = y1;
    this.y2 = y2;
  }
  
  void draw(Species[] speciesList) {
    int index = 0;
    for(Species s : speciesList) {
      int thumbnailY = getThumbnailLocation(index,speciesList.length);
      int drawY = s.drawY();
      if(selectedPeriodIndex == -1 || s.isFoundInPeriod(selectedPeriodIndex)) {
        stroke(s.getColorForHabitat());
        line(x1,thumbnailY,x2,thumbnailY);
        if(outOfRange(drawY)) {
          // out of range
          stroke(255,255,255,180);
          line(x1,thumbnailY,x2,thumbnailY);          
        }
      }
      index++;
    }
  }
  
  boolean contains(int x, int y) {
    return x >= x1 && x <= x2 && y >= y1 && y <= y2;
  }
  
  boolean inRange(int drawY) {
    return !outOfRange(drawY);
  }
  
  boolean outOfRange(int drawY) {
    return drawY < y1 || drawY > y2;
  }
  
  int getThumbnailLocation(int index, int numSpecies) {
    return round(map(index,0,numSpecies-1,y1,y2));
  }
  
  int getSpeciesIndex(int thumbnailY, int numSpecies) {
    return round(map(thumbnailY,y1,y2,0,numSpecies-1));
  }
  
  void beginNav(int numSpecies) {
    if(contains(mouseX,mouseY)) {
      navigating = true;
      continueNav(numSpecies);
    }
  }
  
  void continueNav(int numSpecies) {
    if(navigating()) {
      int index = getSpeciesIndex(mouseY,numSpecies);
      if(index >= 0 && index < numSpecies) {
        speciesIndexOffset = index;
      }
    }
  }
  
  void endNav() {
    navigating = false;
  }
  
  boolean navigating() {
    return navigating;
  }
}
