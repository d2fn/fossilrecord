// http://www.fossilrecord.net/fossilrecord/index.html

class Species {
  
  public String family;
  public String kingdom;
  public String phylum;
  public String other;
  
//F Freshwater
//M Marine
//T Terrestrial
//B Brackish
//L Lagoonal
//V Volant
//S Littoral
  public String habitat;
  
  public int x1, x2, y2;
  
  public Integrator y1 = new Integrator();
  
  Species(String[] fields) {
    this.family   = fields[0];
    this.kingdom  = fields[1];
    this.phylum   = fields[2];
    this.other    = fields[3];
    
    String habitatChars = fields[4];
    if(habitatChars.length() > 0) {
      this.habitat = String.valueOf(habitatChars.charAt(0));
    }
    
    for(int i = 0; i < presence.length; i++) {
      presence[i] = false;
      int fieldIndex = i+5;
      if(fieldIndex < fields.length) {
        if(fields[5+i].length() > 0) {
          presence[i] = true;
        }
      }
    }
  }

  color getColorForHabitat() {
    if(habitat != null) {
      if(habitat.equals("F")) {
        return color(15,59,160);
      }
      else if(habitat.equals("M")) {
        return color(47,207,121);
      }
      else if(habitat.equals("T")) {
        return color(255,102,0);
      }
      else if(habitat.equals("B")) {
        return color(245,222,0);
      }
      else if(habitat.equals("L")) {
        return color(0,170,80);
      }
      else if(habitat.equals("V")) {
        return color(157,62,229);
      }
      else if(habitat.equals("S")) {
        return color(205,0,119);
      }
    }
    return color(50,50,50);
  }

  color getTextColor() {
    if(selectedSpecies != null && selectedSpecies.habitat.equals(this.habitat)) {
      return getColorForHabitat();
    }
    return color(50,50,50);
  }

  void placeAt(int x, int y) {
    bounds(x,y,width,y+2);
  }

  boolean draw() {
    update();
    
    // put a gray background behind the species the mouse is over
    boolean mouseOver = contains(mouseX,mouseY);
    if(mouseOver) {
      selectedSpecies = this;
//      fill(220,220,220);
//      noStroke();
//      rect(x1,y(),width,height());
    }
    
    // draw very small text on the left
    textFont(fonts[1],2);
    fill(getTextColor());
    textAlign(LEFT,CENTER);
    text(family,x1,y());
    
    // draw the time bounds of the fossil records for this species in habitat appropriate color
    stroke(getColorForHabitat());
    for(int i = 0; i < presence.length; i++) {
      int x0 = 55 + i*4;
      int xf = x0 + 4;
      if(presence[i]) {
        line(x0,y(),xf,y());
      }
      if(!renderedPeriod && mouseX > x0 && mouseX <= xf) {
        renderedPeriod = true;
        pushStyle();
        fill(50,50,50);
        textFont(fonts[7],12);
        textAlign(CENTER,CENTER);
        text(periodLabels[i],x0+2,10);
        // show the label for this fossil period
        stroke(220,220,220);
        line(x0+2,25,x0+2,height-25);
        popStyle();
      }
    }
    
    // draw a larger label if the mouse is over this guy
    if(mouseOver) {
      textFont(fonts[7],12);
      fill(50,50,50);
      text(toString(), mouseX > 45 ? 45 : mouseX, mouseY);
    }
    
    return mouseOver;
  }
  
  int getIndexOfFirstAppearance() {
    for(int i = 0; i < presence.length; i++) {
      if(presence[i]) {
        return i;
      }
    }
    return presence.length;
  }
  
  void update() {
    y1.update();
  }
  
  int height() {
    return 2;
  }
  
  int y() {
    return Math.round(y1.value);
  }
  
  boolean contains(int x, int y) {
    return x > x1 && x < x2 && y > y() && y <= (y() + height());
  }
  
  void bounds(int x1, int y1, int x2, int y2) {
    this.x1 = x1;
    this.x2 = x2;
    this.y1.target(y1);
    this.y2 = y2;
  }
  
  String toString() {
    return family + " : " + kingdom + " : " + phylum;
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
    "Holocene"};
    
  // record a true in the era where fossil records exist for this species
  public boolean[] presence = new boolean[periodLabels.length];
}

