class ColorSequencer implements Sequencer<Integer> {

	private final List<Integer> colors;
	private int ptr = 0;

	private ColorSequencer(Integer ... colorArgs) {
		colors = new ArrayList<Integer>();
		for(Integer c : colorArgs) {
			colors.add(c);
		}
	}

	public Integer next() {
		Integer value = colors.get(ptr);
		ptr = (ptr+1)%colors.size();
		return value;
	}
}