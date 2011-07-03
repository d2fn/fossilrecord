import processing.opengl.*;

PFont[] fonts;
Species[] speciesList;
Species selectedSpecies;
Navigator nav;

int selectedPeriodIndex = -1;

int speciesIndexOffset = 0;
int yOffset;

int leftMargin = 300;
int leftNavBuffer = 150;

// set to true during rendering to avoid multiple period label paintings
boolean renderedPeriod = false;

int thumbnailx1;
int thumbnailx2;

int getPlotHeight() {
  return height - 10 - 25;
}

void setup() {
  
  // setup size
  size(leftMargin+getPeriodWidth()*periodLabels.length + leftNavBuffer + 15, 900);
  smooth();

  thumbnailx1 = width - 45;
  thumbnailx2 = width - 30;

  nav = new Navigator(thumbnailx1, 25, thumbnailx2, height - 10);

  // setup fonts
  fonts = new PFont[8];
  for (int i = 0; i < 8; i++) {
    fonts[i] = loadFont("Georgia-"+(i+1)+".vlw");
  }
  textFont(fonts[1], 2);

  // read fossil record data
  String[] lines = loadStrings("fr.csv");
  speciesList = new Species[lines.length];
  for (int i = 0; i < lines.length; i++) {
    String line = lines[i];
    String[] fields = line.split(",");
    speciesList[i] = new Species(fields);
  }
  placeObjects();

  int totalPixelHeight = speciesList.length * speciesList[0].height();
  screenHeight = height-25;
  float numPages = totalPixelHeight / screenHeight;
  println("numPages = " + numPages);
}


void placeObjects() {
  for (int i = 0; i < speciesList.length; i++) {
    speciesList[i].placeAt(leftMargin, 25+i*getRowHeight());
  }
}

boolean update() {
  boolean stable = true;
  for (Species s : speciesList) {
    s.update();
    stable = stable && s.stable();
  }
  println("stable = " + stable);
  return stable;
}

void draw() {
  
  if(update() && pmouseX == mouseX && pmouseY == mouseY) {
    noLoop();
    return;
  }

  background(255);
  fill(50);
  renderedPeriod = false;
  int index = 0;

  nav.draw(speciesList);

  yOffset = speciesList[speciesIndexOffset].y();

  for (int i = speciesIndexOffset; i < speciesList.length; i++) {
    Species s = speciesList[i];
    s.draw();
    if (s.contains(mouseX, mouseY)) {
      selectedSpecies = s;
    }
  }

  for (int i = speciesIndexOffset; i < speciesList.length; i++) {
    Species s = speciesList[i];
    int drawY = s.drawY();
    int thumbnailY = nav.getThumbnailLocation(i, speciesList.length);
    if (nav.inRange(drawY)) {
      // draw the curve from the rightmost era, unless a period is selected,
      // then draw from that period, connecting the right-hand nav to the
      // particular species at the given era
      int drawFromPeriodIndex = periodLabels.length - 1;
      if (selectedPeriodIndex != -1) {
        drawFromPeriodIndex = selectedPeriodIndex;
      }
      // only draw the connecting line if the species has fossil records from the selected period
      if (s.isFoundInPeriod(drawFromPeriodIndex)) {
        stroke(s.getColorForHabitat());
        int startX = getPeriodX(drawFromPeriodIndex) + getPeriodWidth();
        int endX  = nav.x1;
        float cx1 = startX + max(50, 0.3*(endX - startX));
        float cy1 = drawY;
        float cx2 = endX - 50;//0.2*(endX - startX);
        float cy2 = thumbnailY;

        noFill();
        beginShape();
        vertex(startX, drawY);
        bezierVertex(cx1, cy1, cx2, cy2, endX, thumbnailY);
        endShape();
      }
    }
  }

  if (selectedSpecies != null) {
    pushStyle();
    textFont(fonts[7], 12);
    textAlign(LEFT, BOTTOM);
    String label = selectedSpecies.toString();
    int textX = mouseX > 45 ? 45 : mouseX;
    int textY = mouseY;
    int boxHeight = round(textAscent())+4;
    int boxWidth = round(textWidth(label));
    fill(255, 255, 255, 130);
    noStroke();
    rect(textX-2, textY-boxHeight, boxWidth+4, boxHeight);
    fill(50, 50, 50);
    text(label, textX, textY);
    popStyle();
  }

  if (selectedPeriodIndex != -1) {
    pushStyle();
    fill(50, 50, 50);
    textFont(fonts[7], 12);
    textAlign(CENTER, CENTER);
    int x = getPeriodX(selectedPeriodIndex) + round(getPeriodWidth()/2);
    String label = getPeriodLabel(selectedPeriodIndex);
    text(label, x, 10);
    // show the label for this fossil period
    stroke(220, 220, 220);
    line(x, 25, x, height-10);
    popStyle();
  }
}

void sortByFirstAppearance() {
  Arrays.sort(speciesList, new Comparator<Species>() {
    public int compare(Species s1, Species s2) {
      int c = s1.getIndexOfFirstAppearance() - s2.getIndexOfFirstAppearance();
      if (c == 0) {
        c = s2.getIndexOfLastAppearance() - s1.getIndexOfLastAppearance();
      }
      return c;
    }
  }
  );
  placeObjects();
}

void sortByLastAppearance() {
  Arrays.sort(speciesList, new Comparator<Species>() {
    public int compare(Species s1, Species s2) {
      int c = s1.getIndexOfLastAppearance() - s2.getIndexOfLastAppearance();
      if (c == 0) {
        c = s1.getIndexOfFirstAppearance() - s2.getIndexOfFirstAppearance();
      }
      return c;
    }
  }
  );
  placeObjects();
}

void alphaSort() {
  Arrays.sort(speciesList, new Comparator<Species>() {
    public int compare(Species s1, Species s2) {
      return s1.family.compareTo(s2.family);
    }
  }
  );
  placeObjects();
}

void habitatSort() {
  Arrays.sort(speciesList, new Comparator<Species>() {
    public int compare(Species s1, Species s2) {
      int c = s1.habitat.compareTo(s2.habitat);
      if (c == 0) {
        c = s1.getIndexOfFirstAppearance() - s2.getIndexOfFirstAppearance();
        if (c == 0) {
          c = s1.getIndexOfLastAppearance() - s2.getIndexOfLastAppearance();
        }
      }
      return c;
    }
  }
  );
  placeObjects();
}

void sortByDuration() {
  Arrays.sort(speciesList, new Comparator<Species>() {
    public int compare(Species s1, Species s2) {
      int c = s2.getDuration() - s1.getDuration();
      if (c == 0) {
        c = s1.getIndexOfFirstAppearance() - s2.getIndexOfFirstAppearance();
        if (c == 0) {
          c = s1.toString().compareTo(s2.toString());
        }
      }
      return c;
    }
  }
  );
  placeObjects();
}

void keyPressed() {
  if (key == 's') {
    sortByFirstAppearance();
  }
  else if (key == 'e') {
    sortByLastAppearance();
  }
  else if (key == 'd') {
    sortByDuration();
  }
  else if (key == 'a') {
    alphaSort();
  }
  else if (key == 'h') {
    habitatSort();
  }
  else if (key == '[') {
    speciesIndexOffset--;
    if (speciesIndexOffset < 0) {
      speciesIndexOffset = 0;
    }
  }
  else if (key == ']') {
    speciesIndexOffset++;
  }
  loop();
}

void mouseClicked() {
  selectPeriod(mouseX);
  loop();
}

void mousePressed() {
  nav.beginNav(speciesList.length);
  if (!nav.navigating()) {
    selectPeriod(mouseX);
  }
  loop();
}

void mouseDragged() {
  nav.continueNav(speciesList.length);
  if (!nav.navigating()) {
    selectPeriod(mouseX);
  }
  loop();
}

void mouseReleased() {
  nav.endNav();
  loop();
}

void mouseMoved() {
  loop();
}

// period labels
String[] periodLabels = new String[] {
  "Hadean Precambrian", 
  "Isuan", 
  "Swazian", 
  "Randian", 
  "Huronian", 
  "Animakean", 
  "Riphean", 
  "Sturtian", 
  "Vendian", 
  "Caerfai Cambrian Palaeozoic", 
  "St David's", 
  "Merioneth", 
  "Tremadoc Ordovician", 
  "Arenig", 
  "Llanvirn", 
  "Llandeilo", 
  "Caradoc", 
  "Ashgill", 
  "Llandovery Silurian", 
  "Wenlock", 
  "Ludlow", 
  "Pridoli", 
  "Lochkovian Devonian", 
  "Pragian", 
  "Emsian", 
  "Eifelian", 
  "Givetian", 
  "Frasnian", 
  "Famennian", 
  "Tournaisian Carboniferous", 
  "Visean", 
  "Serpukhovian", 
  "Bashkirian", 
  "Moscovian", 
  "Kasimovian", 
  "Gzelian", 
  "Asselian Permian", 
  "Sakmarian", 
  "Artinskian", 
  "Kungurian", 
  "Ufimian", 
  "Kazanian", 
  "Tatarian", 
  "Scythian Triassic Mesozoic", 
  "Anisian", 
  "Ladinian", 
  "Carnian", 
  "Norian", 
  "Rhaetian", 
  "Hettangian Jurassic", 
  "Sinemurian", 
  "Pliensbachian", 
  "Toarcian", 
  "Aalenian", 
  "Bajocian", 
  "Bathonian", 
  "Callovian", 
  "Oxfordian", 
  "Kimmeridgian", 
  "Portlandian", 
  "Berriasian Cretaceous", 
  "Valanginian", 
  "Hauterivian", 
  "Barremian", 
  "Aptian", 
  "Albian", 
  "Cenomanian", 
  "Turonian", 
  "Coniacian", 
  "Santonian", 
  "Campanian", 
  "Maastrichtian", 
  "Danian Palaeogene Cainozoic", 
  "Thanetian", 
  "Ypresian", 
  "Lutetian", 
  "Bartonian", 
  "Priabonian", 
  "Rupelian", 
  "Chattian", 
  "Lower Miocene Neogene", 
  "Middle Miocene", 
  "Upper Miocene", 
  "Pliocene", 
  "Pleistocene Quaternary", 
  "Holocene"
};

// get the period label at the given index
String getPeriodLabel(int index) {
  return periodLabels[index];
}

// get the x coordinate for the given period index
int getPeriodX(int index) {
  return leftMargin + 55 + index * getPeriodWidth();
}

// return the period index at the given x coordinate
int getPeriodIndex(int x) {
  x -= leftMargin+55;
  return x/getPeriodWidth();
}

// get the width of a period to render
int getPeriodWidth() {
  return 3;
}

int getRowHeight() {
  return 2;
}

void selectPeriod(int xcoord) {
  int pindex = getPeriodIndex(xcoord);
  if (pindex >= 0 && pindex < periodLabels.length) {
    selectedPeriodIndex = pindex;
  }
  else {
    selectedPeriodIndex = -1;
  }
}

