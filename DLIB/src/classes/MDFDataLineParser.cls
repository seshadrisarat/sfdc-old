/**
 * Class that deals with parsing a line of data from the MetricsDataFile
 */
public with sharing class MDFDataLineParser {
	public static final Pattern MDF_DATA_LINE_PATTERN = Pattern.compile('^"(\\w*)",".*?",".*?","([A-Z]*)[",\\d\\.]*?([\\/\\w]*?)","(\\d*)".*$');
	
	public static final Map<Integer, String> MDF_DATA_LINE_FIELD_NAME_INDEX_MAP = new Map<Integer, String> {
            1 => MDFDataModel.SUBSCRIBER_ORG_ID_FIELD_NAME,
            2 => MDFDataModel.SUBSCRIBER_ORG_STATUS_FIELD_NAME,
            3 => MDFDataModel.RESOURCE_NAME_FIELD_NAME,
            4 => MDFDataModel.RESOURCE_COUNT_FIELD_NAME
        };
	
    private Map<Integer, String> indexToFieldNameMapping;
    private Pattern regexPattern;

	/**
	 * Constructs a default MDFDataLineParser which uses the basic index to field name mapping and regex
	 */
	public MDFDataLineParser() {
		this(MDF_DATA_LINE_FIELD_NAME_INDEX_MAP, MDF_DATA_LINE_PATTERN);
	}

    public MDFDataLineParser(Map<Integer, String> indexToFieldNameMapping, Pattern regexPattern) {
        this.indexToFieldNameMapping = indexToFieldNameMapping;
        this.regexPattern = regexPattern;
    }
    
    /**
     * Parse the provided line and return a Map keyed based on the indexToFieldNameMapping and the regex.
     */
    public Map<String, String> parseLine(String line) {
    	System.debug('parsing line [' + line + ']');
    	
        Map<String, String> fieldNameToValueMapping = new Map<String, String>();
        Matcher m = regexPattern.matcher(line);
        
        if (m.find()) {
        	System.debug('regex [' + regexPattern + '] matches');
            for (Integer index : indexToFieldNameMapping.keySet()) {
                String value = m.group(index);
                System.debug('mapping value [' + value + '] from group=' + index + ' / ' + indexToFieldNameMapping.get(index));
                fieldNameToValueMapping.put(indexToFieldNameMapping.get(index), value);
            }
        }
        else {
        	System.debug('regex [' + regexPattern + '] found no match');
        }
        
        return fieldNameToValueMapping;
    }

    /**
     * Create a MDFDataModel from the provided line. This assumes that the indexToFieldNameMapping has
     * field names that correspond to valid properties of the MDFDataModel.
     */
    public MDFDataModel createModelFromLine(String line) {
        Map<String, String> mapOfValues = parseLine(line);
    
        System.Type t = MDFDataModel.class;
        String dataAsJson = JSON.serialize(mapOfValues);
        System.debug(dataAsJson);
        MDFDataModel dataModel = (MDFDataModel) JSON.deserialize(dataAsJson, t);
        System.debug(dataModel.subscriberOrgId);
    
        return dataModel;
    }
}