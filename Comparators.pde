static class Comparators {
  static Comparator<Species> firstAppearanceComparator() {
    return new Comparator<Species>() {
      public int compare(Species s1, Species s2) {
        int c = s1.getIndexOfFirstAppearance() - s2.getIndexOfFirstAppearance();
        if (c == 0) {
          c = s2.getIndexOfLastAppearance() - s1.getIndexOfLastAppearance();
        }
        return c;
      }
    };
  }
}
