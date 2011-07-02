PFont[] fonts;
Species[] speciesList;
Species selectedSpecies;

// set to true during rendering to avoid multiple period label paintings
boolean renderedPeriod = false;

void setup() {
  // setup size
  size(500, 900);

  // setup fonts
  fonts = new PFont[8];
  for (int i = 0; i < 8; i++) {
    fonts[i] = loadFont("Georgia-"+(i+1)+".vlw");
  }
  textFont(fonts[1], 2);

  // read fossil record data
  String[] lines = loadStrings("39-Reptilia.csv");
  speciesList = new Species[lines.length];
  for (int i = 0; i < lines.length; i++) {
    String line = lines[i];
    String[] fields = line.split(",");
    speciesList[i] = new Species(fields);
  }
  placeObjects();
}

void placeObjects() {
  for(int i = 0; i < speciesList.length; i++) {
    speciesList[i].placeAt(25,25+i*speciesList[i].height());  
  }
}

void draw() {
  background(255);
  fill(50);
  renderedPeriod = false;
  boolean hitDetected = false;
  for (int i = 0; i < speciesList.length; i++) {
    Species s = speciesList[i];
    if(s.draw()) {
      hitDetected = true;
    }
  }
  
  if(!hitDetected) {
    selectedSpecies = null;
  }
}

void timeSort() {
  Arrays.sort(speciesList,new Comparator<Species>() {
    public int compare(Species s1, Species s2) {
      return s1.getIndexOfFirstAppearance() - s2.getIndexOfFirstAppearance();
    }
  });
  placeObjects();
}

void alphaSort() {
  Arrays.sort(speciesList,new Comparator<Species>() {
    public int compare(Species s1, Species s2) {
      return s1.family.compareTo(s2.family);
    }
  });
  placeObjects();
}

void habitatSort() {
  Arrays.sort(speciesList,new Comparator<Species>() {
    public int compare(Species s1, Species s2) {
      int c = s1.habitat.compareTo(s2.habitat);
      if(c == 0) {
        c = s1.toString().compareTo(s2.toString());
      }
      return c;
    }
  });
  placeObjects();
}

void keyPressed() {
  if(key == 't') {
    timeSort();
  }
  else if(key == 'a') {
    alphaSort();
  }
  else if(key == 'h') {
    habitatSort();
  }
}
