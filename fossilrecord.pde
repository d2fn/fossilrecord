import processing.opengl.*;

PFont[] fonts;
PFont helpFont;
String helpText;
Species[] speciesList;
List<Species> visibleSpecies;
Species selectedSpecies;
Navigator nav;

int selectedPeriodIndex = -1;

// current species index and the index at the last frame
int pspeciesIndexOffset = 0;
int speciesIndexOffset = 0;

int yOffset;

int topMargin = 25;
int leftMargin = 500;
int bottomMargin = 10;
int leftNavBuffer = 150;
int screenHeight;

// set to true during rendering to avoid multiple period label paintings
boolean renderedPeriod = false;

int thumbnailx1;
int thumbnailx2;

List<ArrowLabel> speciesLabels = new ArrayList<ArrowLabel>(5);

String searchTerm = "";
String psearchTerm = "";

FieldType habitatField;
FieldType classField;
ColorMapper colorMapper;
ColorSequencer colorSequencer;

int getPlotHeight() {
  return height - bottomMargin - topMargin;
}

void setup() {

  colorSequencer = new ColorSequencer(
      color( 15,  59, 160),
      color( 47, 207, 121),
      color(255, 102,   0),
      color(245, 222,   0),
      color(  0, 170,  80),
      color(157,  62, 229),
      color(205,   0,  19));

  habitatField = new FieldType("habitat", colorSequencer);
  habitatField.map("F", "Freshwater");
  habitatField.map("M", "Marine");
  habitatField.map("T", "Terrestrial");
  habitatField.map("B", "Brackish");
  habitatField.map("L", "Lagoonal");
  habitatField.map("V", "Volant");
  habitatField.map("S", "Littoral");

  colorMapper = new ColorMapper(habitatField);

// F Freshwater
// M Marine
// T Terrestrial
// B Brackish
// L Lagoonal
// V Volant
// S Littoral
    // if(habitat != null) {
    //   if(habitat.equals("F")) {
    //     return color(15,59,160);
    //   }
    //   else if(habitat.equals("M")) {
    //     return color(47,207,121);
    //   }
    //   else if(habitat.equals("T")) {
    //     return color(255,102,0);
    //   }
    //   else if(habitat.equals("B")) {
    //     return color(245,222,0);
    //   }
    //   else if(habitat.equals("L")) {
    //     return color(0,170,80);
    //   }
    //   else if(habitat.equals("V")) {
    //     return color(157,62,229);
    //   }
    //   else if(habitat.equals("S")) {
    //     return color(205,0,119);
    //   }
    // }


  // setup size
  size(leftMargin+getPeriodWidth()*periodLabels.length + leftNavBuffer + 15, 800);
  smooth();
  frameRate(60);

  thumbnailx1 = width - 45;
  thumbnailx2 = width - 30;

  nav = new Navigator(colorMapper, thumbnailx1, topMargin, thumbnailx2, height - 10);

  // setup fonts
  fonts = new PFont[8];
  for (int i = 0; i < 8; i++) {
    fonts[i] = loadFont("Georgia-"+(i+1)+".vlw");
  }
  textFont(fonts[1], 2);
  
  helpFont = loadFont("Courier-12.vlw");
  String[] helpLines = loadStrings("help.txt");
  StringBuilder sb = new StringBuilder();
  for(String line : helpLines) {
    sb.append(line).append("\n");
  }
  helpText = sb.toString();

  // read fossil record data
  String[] lines = loadStrings("fr.csv");
  speciesList = new Species[lines.length];
  for (int i = 0; i < lines.length; i++) {
    String line = lines[i];
    String[] fields = line.split(",");
    speciesList[i] = new Species(fields);
  }
  
  visibleSpecies = new ArrayList<Species>(speciesList.length);
  clearSearch();

  int totalPixelHeight = speciesList.length * speciesList[0].height();
  screenHeight = height-topMargin-bottomMargin;
  float numPages = totalPixelHeight / screenHeight;
  println("numPages = " + numPages);
}


void placeObjects() {
  int i = 0;
  for(Species s : visibleSpecies) {
    s.placeAt(leftMargin, topMargin+i*getRowHeight());
    i++;
  }
}

boolean update() {
  boolean stable = true;
  for (Species s : speciesList) {
    s.update();
    stable = stable && s.stable();
  }
  return stable;
}

void draw() {
  
  if(update() && pmouseX == mouseX && pmouseY == mouseY && pspeciesIndexOffset == speciesIndexOffset && psearchTerm.equals(searchTerm)) {
    noLoop();
  }
  else {
    background(255);
    fill(50);
    renderedPeriod = false;
    int index = 0;
  
    if(searchTerm.length() > 0) {
      pushStyle();
      textFont(fonts[7], 12);
      textAlign(RIGHT,BOTTOM);
      text("searching: " + searchTerm,leftMargin-5,topMargin-5);
      popStyle();
    }
  
    if(visibleSpecies.isEmpty()) {
      return;
    }
  
    nav.draw(visibleSpecies);
  
    yOffset = visibleSpecies.get(speciesIndexOffset).y() - topMargin;
  
    for(Species s : visibleSpecies) {
      if (s.contains(mouseX, mouseY)) {
        selectedSpecies = s;
        s.draw(colorMapper, true);
      }
      else {
        s.draw(colorMapper, false);
      }
    }
  
    for (int i = speciesIndexOffset; i < visibleSpecies.size(); i++) {
      Species s = visibleSpecies.get(i);
      int drawY = s.drawY();
      int thumbnailY = nav.getThumbnailLocation(i, visibleSpecies.size());
      if (nav.inRange(drawY)) {
        // draw the curve from the rightmost era, unless a period is selected,
        // then draw from that period, connecting the right-hand nav to the
        // particular species at the given era
        int drawFromPeriodIndex = periodLabels.length - 1;
        if (selectedPeriodIndex != -1) {
          drawFromPeriodIndex = selectedPeriodIndex;
        }
        // only draw the connecting line if the species has fossil records from the selected period
        if (s.isFoundInPeriod(drawFromPeriodIndex) && selectedPeriodIndex != -1) {
          color lineColor = s == selectedSpecies ? color(0,0,0) : colorMapper.getColor(s);
          stroke(lineColor);
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
  
//  public String family;
//  public String kingdom;
//  public String phylum;
//  public String className;
    speciesLabels.clear();
    if(selectedSpecies != null) {
      pushStyle();
      textFont(fonts[7],12);
      fill(254,244,156,150);
      stroke(0,0,0,50);
      int pointToX = selectedSpecies.x1-2;
      int pointToY = selectedSpecies.drawY();
      color lblColor = color(0,0,0,220);
      color hvrColor = color(6,69,230);
      speciesLabels =
        arrowLabels(
          pointToX,pointToY,
          lblColor,hvrColor,
          selectedSpecies.family,
          selectedSpecies.kingdom,
          selectedSpecies.phylum,
          selectedSpecies.className);
      for(ArrowLabel a : speciesLabels) {
        a.draw();
      }
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
      line(x, topMargin, x, height-bottomMargin);
      popStyle();
    }
  }
  
  // help
  pushStyle();
  fill(50,50,50);
  textFont(helpFont, 12);
  textAlign(LEFT,BOTTOM);
  text(helpText, 15, height-15);
  popStyle();

  pushStyle();
  fill(50,50,50);
  int legendY = 15;
  for(String key : colorMapper.keys()) {
    noStroke();
    fill(colorMapper.getColor(key));
    rect(15, legendY, 15, 13);
    fill(50,50,50);
    textFont(helpFont, 12);
    textAlign(LEFT, TOP);
    text(colorMapper.getValue(key), 35, legendY+1);
    legendY += 15;
  }
  popStyle();
  
  pspeciesIndexOffset = speciesIndexOffset;
  psearchTerm = searchTerm;
}

List<ArrowLabel> arrowLabels(int pointToX, int pointToY, color lblColor, color hvrColor, String ... labels) {
  List<ArrowLabel> arrowLabels = new ArrayList<ArrowLabel>(labels.length);
  for(String label : labels) {
    ArrowLabel lbl = new ArrowLabel(label,lblColor,hvrColor,pointToX,pointToY,5,7);
    arrowLabels.add(lbl);
    pointToX = lbl.x+2;
  }
  return arrowLabels;
}

void searchFor(String search) {
  searchTerm = search.toLowerCase();
  speciesIndexOffset = 0;
  List<Species> filtered = new ArrayList(speciesList.length);
  for(Species s : speciesList) {
    if(s.toString().toLowerCase().indexOf(searchTerm) != -1) {
      filtered.add(s);
    }
  }
  visibleSpecies = filtered;
  placeObjects();
}

void clearSearch() {
  searchTerm = "";
  speciesIndexOffset = 0;
  visibleSpecies.clear();
  for(Species s : speciesList) {
    visibleSpecies.add(s);
  }
  placeObjects();
}

void sortSpecies(Comparator<Species> comparator) {
  Collections.sort(visibleSpecies,comparator);
  Arrays.sort(speciesList,comparator);
  placeObjects();
}

void keyPressed() {
  //if(key == CODED && keyCode = CONTROL) {
    if (key == 'S') {
      sortSpecies(Comparators.firstAppearance);
    }
    else if(key == 'C') {
      sortSpecies(Comparators.className);
    }
    else if (key == 'E') {
      sortSpecies(Comparators.lastAppearance);
    }
    else if (key == 'P') {
      sortSpecies(Comparators.phylum);
    }
    else if (key == 'D') {
      sortSpecies(Comparators.duration);
    }
    else if (key == 'F') {
      sortSpecies(Comparators.family);
    }
    else if (key == 'H') {
      sortSpecies(Comparators.habitat);
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
    else if (key == BACKSPACE) {
      if(searchTerm.length() < 2) {
        clearSearch();
      }
      else {
        searchFor(searchTerm.substring(0,searchTerm.length() - 1));
      }
    }
    else if (key == '.') {
      clearSearch();
    }
    else if(key != CODED) {
      searchFor(searchTerm + key);
    }
 // }
  loop();
}

void mouseClicked() {
  selectPeriod(mouseX);
  ArrowLabel arrowLabel = speciesLabelAt(mouseX,mouseY);
  if(arrowLabel != null) {
    link("http://en.wikipedia.org/wiki/" + arrowLabel.label);
  }
  selectPeriod(mouseX);
  loop();
}

void mousePressed() {
  nav.beginNav(visibleSpecies.size());
  selectPeriod(mouseX);
  loop();
}

void mouseDragged() {
  nav.continueNav(visibleSpecies.size());
  if(!nav.navigating()) {
    selectPeriod(mouseX);
  }
  loop();
}

void mouseReleased() {
  nav.endNav();
  loop();
}

ArrowLabel speciesLabelAt(int x, int y) {
  for(ArrowLabel label : speciesLabels) {
    if(label.contains(x,y)) {
      return label;
    }
  }
  return null;
}

void mouseMoved() {
  if(nav.contains(mouseX,mouseY)) {
    cursor(HAND);
  }
  else {
    ArrowLabel label = speciesLabelAt(mouseX,mouseY);
    if(label != null) {
      cursor(HAND);
    }
    else {
      cursor(CROSS);
    }
  }
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
  int leftX = leftMargin + 55;
  int rightX = 55 + leftMargin + periodLabels.length*getPeriodWidth();
  
  if(xcoord >= leftX && xcoord <= rightX) {
    int pindex = getPeriodIndex(xcoord);
    if (pindex >= 0 && pindex < periodLabels.length) {
      selectedPeriodIndex = pindex;
    }
    else {
      selectedPeriodIndex = -1;
    }
  }
  else if(xcoord > rightX && xcoord < rightX+50) {
    selectedPeriodIndex = -1;
  }
}
