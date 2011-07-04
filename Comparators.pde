static class Comparators {
  
  static Comparator<Species> family = new Comparator<Species>() {
    public int compare(Species s1, Species s2) {
      return s1.family.compareTo(s2.family);
    }
  };
  
  static Comparator<Species> className = new Comparator<Species>() {
      public int compare(Species s1, Species s2) {
        int c = s1.className.compareTo(s2.className);
        if (c == 0) {
          c = s1.getIndexOfFirstAppearance() - s2.getIndexOfFirstAppearance();
          if(c == 0) {
            c = s1.getIndexOfLastAppearance() - s2.getIndexOfLastAppearance();
          }
        }
        return c;
      }};
      
  static Comparator<Species> phylum = new Comparator<Species>() {
      public int compare(Species s1, Species s2) {
        int c = s1.phylum.compareTo(s2.phylum);
        if (c == 0) {
          c = s1.getIndexOfFirstAppearance() - s2.getIndexOfFirstAppearance();
          if(c == 0) {
            c = s1.getIndexOfLastAppearance() - s2.getIndexOfLastAppearance();
          }
        }
        return c;
      }};
  
  static Comparator<Species> firstAppearance =
    new Comparator<Species>() {
      public int compare(Species s1, Species s2) {
        int c = s1.getIndexOfFirstAppearance() - s2.getIndexOfFirstAppearance();
        if (c == 0) {
          c = s2.getIndexOfLastAppearance() - s1.getIndexOfLastAppearance();
        }
        return c;
      }
    };
  
  static Comparator<Species> lastAppearance =
    new Comparator<Species>() {
      public int compare(Species s1, Species s2) {
        int c = s1.getIndexOfLastAppearance() - s2.getIndexOfLastAppearance();
        if (c == 0) {
          c = s1.getIndexOfFirstAppearance() - s2.getIndexOfFirstAppearance();
        }
        return c;
      }
    };
  
  static Comparator<Species> duration =
    new Comparator<Species>() {
        public int compare(Species s1, Species s2) {
          int c = s2.getDuration() - s1.getDuration();
          if (c == 0) {
            c = s1.getIndexOfFirstAppearance() - s2.getIndexOfFirstAppearance();
            if (c == 0) {
              c = s1.toString().compareTo(s2.toString());
            }
          }
          return c;
        }};
   
   static Comparator<Species> habitat = new Comparator<Species>() {
    public int compare(Species s1, Species s2) {
      int c = s1.habitat.compareTo(s2.habitat);
      if (c == 0) {
        c = s2.getDuration() - s1.getDuration();
        if (c == 0) {
          c = s2.getIndexOfLastAppearance() - s1.getIndexOfLastAppearance();
        }
      }
      return c;
    }};
}
