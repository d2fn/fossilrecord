class ArrowLabel {
  
  String label;
  int x, y, r, pointerWidth, lwidth, lheight;
  color textcolor, textcolorhover;
  
  ArrowLabel(String label, color textcolor, color textcolorhover, int pointToX, int pointToY, int r, int pointerWidth) {
    this.label = label;
    this.textcolor = textcolor;
    this.textcolorhover = textcolorhover;
    this.pointerWidth = pointerWidth;
    this.lwidth = ceil(textWidth(this.label));
    this.lheight = ceil(textAscent()+textDescent());
    this.x = pointToX - (pointerWidth + r + lwidth);
    this.y = pointToY - lheight/2;
  }
  
  boolean contains(int x, int y) {
    if(x > this.x && x < (this.x+this.lwidth) && y > this.y && y < (this.y+this.lheight)) {
      return true;
    }
    return false;
  }
  
  void draw() {
    
    lwidth = ceil(textWidth(label)) + 2;
    lheight = ceil(textAscent()+textDescent()) + 2;
    
    beginShape();
    vertex(x+r,y);
    vertex(x+r+lwidth,y);
    vertex(x+r+lwidth+pointerWidth,y+lheight/2);
    vertex(x+r+lwidth,y+lheight);
    vertex(x+r,y+lheight);
    bezierVertex(x,y+lheight,x,y+lheight,x,y+lheight-r);
    vertex(x,y+r);
    bezierVertex(x,y,x,y,x+r,y);
    endShape();
    
    pushStyle();
    fill(contains(mouseX,mouseY) ? this.textcolorhover : this.textcolor);
    textAlign(LEFT,TOP);
    text(this.label, this.x + this.r + 2, this.y + 2);
    popStyle();
  }
}
