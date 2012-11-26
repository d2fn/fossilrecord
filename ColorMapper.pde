class ColorMapper {
	
	private FieldType field;

	public ColorMapper(FieldType field) {
		setField(field);
	}

	public void setField(FieldType field) {
		this.field = field;
	}

	public List<String> keys() {
		return field.keys();
	}

	public String getValue(String key) {
		return field.getValue(key);
	}

	public Integer getColor(String key) {
		return field.getColor(key);
	}

	public Integer getColor(Species s) {
		String value = s.getValue(field.getName());
		return field.getColor(value);
	}
}