class FieldType {

	private final String name;
	private final Map<String, String> strings;
	private final Map<String, Integer> colors;
	private final Sequencer<Integer> colorSequencer;

	private final List<String> keys;

	public FieldType(String name, Sequencer<Integer> colorSequencer) {
		this.name = name;
		this.strings = new HashMap<String, String>();
		this.colors = new HashMap<String, Integer>();
		this.colorSequencer = colorSequencer;
		this.keys = new ArrayList<String>();
	}

	public String getName() {
		return name;
	}

	public FieldType map(String key, String value) {
		strings.put(key, value);
		colors.put(key, colorSequencer.next());
		buildKeys();
		return this;
	}

	public String getValue(String key) {
		return strings.get(key);
	}

	public int getColor(String key) {
		if(colors.containsKey(key)) {
	 		return colors.get(key);
	 	}
	 	return 0;
	}

	public List<String> keys() {
		return keys;
	}

	private void buildKeys() {
		keys.clear();
		for(String key : strings.keySet()) {
			keys.add(key);
		}
		Collections.sort(keys);
	}
}