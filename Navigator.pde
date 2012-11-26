class Navigator {

  ColorMapper colorMapper;
  
  int x1, x2, y1, y2;
  int visibley1, visibley2;
  
  boolean navigating = false;
  int navigationOffset = 0;
  
  int visibleRange = getPlotHeight() / getRowHeight();
  
  Navigator(ColorMapper colorMapper, int x1, int y1, int x2, int y2) {
    this.colorMapper = colorMapper;
    this.x1 = x1;
    this.x2 = x2;
    this.y1 = y1;
    this.y2 = y2;
  }
  
  void draw(List<Species> speciesList) {
    int index = 0;
    for(Species s : speciesList) {
      int thumbnailY = getThumbnailLocation(index,speciesList.size());
      int drawY = s.drawY();
      if(selectedPeriodIndex == -1 || s.isFoundInPeriod(selectedPeriodIndex)) {
        stroke(colorMapper.getColor(s));
        line(x1,thumbnailY,x2,thumbnailY);
        if(outOfRange(drawY)) {
          // out of range
          stroke(255,255,255,180);
          line(x1,thumbnailY,x2,thumbnailY);          
        }
      }
      index++;
    }
    
    if(speciesList.size() > visibleRange) {
      int yrange1 = getThumbnailLocation(speciesIndexOffset,speciesList.size());
      int yrange2 = getThumbnailLocation(speciesIndexOffset + visibleRange,speciesList.size());
      int midy = (yrange1 + yrange2)/2;
      
      pushStyle();
      noFill();
      stroke(0,0,0,100);
      beginShape();
      vertex(x2+2,yrange1);
      bezierVertex(x2+6,yrange1,x2,midy,x2+6,midy);
      bezierVertex(x2,midy,x2+6,yrange2,x2+2,yrange2);
      endShape();
      popStyle();
    }
  }
  
  boolean contains(int x, int y) {
    return x >= x1 && x <= x2 && y >= y1 && y <= y2;
  }
  
  boolean inRange(int drawY) {
    return !outOfRange(drawY);
  }
  
  int width() {
    return x2 - x1;
  }
  
  boolean outOfRange(int drawY) {
    return drawY < y1 || drawY > y2;
  }
  
  int getThumbnailLocation(int index, int numSpecies) {
    if(numSpecies < y2 - y1) {
      return y1 + index;
    }
    return round(map(index,0,numSpecies-1,y1,y2));
  }
  
  int getSpeciesIndex(int thumbnailY, int numSpecies) {
    return round(map(thumbnailY,y1,y2,0,numSpecies-1));
  }
  
  void beginNav(int numSpecies) {
    if(contains(mouseX,mouseY)) {
      navigating = true;
      int selectedIndex = getSpeciesIndex(mouseY,numSpecies);
      if(selectedIndex > speciesIndexOffset && (selectedIndex-speciesIndexOffset) <= visibleRange) {
        navigationOffset = speciesIndexOffset - getSpeciesIndex(mouseY,numSpecies);        
      }
      else {
        navigationOffset = -visibleRange/2;
      }
      continueNav(numSpecies);
    }
  }
  
  void continueNav(int numSpecies) {
    if(navigating()) {
      int index = getSpeciesIndex(mouseY,numSpecies);
      if(index >= 0 && index < numSpecies) {
        speciesIndexOffset = index + navigationOffset;
        if(speciesIndexOffset < 0) {
          speciesIndexOffset = 0;
        }
        else if(speciesIndexOffset >= numSpecies) {
          speciesIndexOffset = numSpecies - 1;
        }
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
