@isTest
private class MDFDataLineParserTest {
	
	static testMethod void testDefaultSettingsTypeVF() {
		MDFDataLineParser lineParser = new MDFDataLineParser();
		
		String subscriberOrgId = '00DyyMOCKORG1';
		String subscriberOrgStatus = 'TRIAL';
		String resourceName = 'mockPage1';
		Integer resourceCount = 100;
		
		/* test the v30 version of the data */
		String templateStringV30 = '"{0}","Org Name","Org Edition","{1}","{2}","{3}","0","0"';
		String dataLine = String.format(templateStringV30, new List<String>{subscriberOrgId, subscriberOrgStatus, resourceName, String.valueOf(resourceCount)});
		/* test creating the map */
		Map<String, String> result = lineParser.parseLine(dataLine);
		verifyMap(result, subscriberOrgId, subscriberOrgStatus, resourceName, resourceCount);
		
		/* test creating the model */
		MDFDataModel model = lineParser.createModelFromLine(dataLine);
		verifyModel(model, subscriberOrgId, subscriberOrgStatus, resourceName, resourceCount);

		/* test the v31+ version of the data */
		String templateStringV31 = '"{0}","Org Name","Org Edition","{1}","1.0","{2}","{3}","0","0"';		
		dataLine = String.format(templateStringV31, new List<String>{subscriberOrgId, subscriberOrgStatus, resourceName, String.valueOf(resourceCount)});
		/* test creating the map */
		result = lineParser.parseLine(dataLine);
		verifyMap(result, subscriberOrgId, subscriberOrgStatus, resourceName, resourceCount);
		
		/* test creating the model */
		model = lineParser.createModelFromLine(dataLine);
		verifyModel(model, subscriberOrgId, subscriberOrgStatus, resourceName, resourceCount);
	}
	
	static testMethod void testDefaultSettingsTypeCustomObject() {
		MDFDataLineParser lineParser = new MDFDataLineParser();
		
		String subscriberOrgId = '00DyyMOCKORG1';
		String subscriberOrgStatus = 'TRIAL';
		String resourceName = 'mockPage1';
		Integer resourceCount = 100;
		
		/* test the v30 version of the data */
		String templateStringV30 = '"{0}","Org Name","Org Edition","{1}","{2}","{3}"';
		String dataLine = String.format(templateStringV30, new List<String>{subscriberOrgId, subscriberOrgStatus, resourceName, String.valueOf(resourceCount)});
		/* test creating the map */
		Map<String, String> result = lineParser.parseLine(dataLine);
		verifyMap(result, subscriberOrgId, subscriberOrgStatus, resourceName, resourceCount);
		
		/* test creating the model */
		MDFDataModel model = lineParser.createModelFromLine(dataLine);
		verifyModel(model, subscriberOrgId, subscriberOrgStatus, resourceName, resourceCount);

		/* test the v31+ version of the data */
		//String templateStringV31 = '"{0}","Org Name","Org Edition","{1}","1.0","{2}","{3}"';		
		//dataLine = String.format(templateStringV31, new List<String>{subscriberOrgId, subscriberOrgStatus, resourceName, String.valueOf(resourceCount)});
		/* test creating the map */
		//result = lineParser.parseLine(dataLine);
		//verifyMap(result, subscriberOrgId, subscriberOrgStatus, resourceName, resourceCount);
		
		/* test creating the model */
		//model = lineParser.createModelFromLine(dataLine);
		//verifyModel(model, subscriberOrgId, subscriberOrgStatus, resourceName, resourceCount);
	}

	private static void verifyMap(Map<String, String> resultMap, String subscriberOrgId, String subscriberOrgStatus, String resourceName, Integer resourceCount) {
		System.assertEquals(subscriberOrgId, resultMap.get(MDFDataModel.SUBSCRIBER_ORG_ID_FIELD_NAME));
		System.assertEquals(subscriberOrgStatus, resultMap.get(MDFDataModel.SUBSCRIBER_ORG_STATUS_FIELD_NAME));
		System.assertEquals(resourceName, resultMap.get(MDFDataModel.RESOURCE_NAME_FIELD_NAME));
		System.assertEquals(String.valueOf(resourceCount), resultMap.get(MDFDataModel.RESOURCE_COUNT_FIELD_NAME));
	}
	
	private static void verifyModel(MDFDataModel model, String subscriberOrgId, String subscriberOrgStatus, String resourceName, Integer resourceCount) {
		System.assertEquals(subscriberOrgId, model.subscriberOrgId);
		System.assertEquals(subscriberOrgStatus, model.subscriberOrgStatus);
		System.assertEquals(resourceName, model.resourceName);
		System.assertEquals(resourceCount, model.resourceCount);		
	}
	
    static testMethod void testLineProcessorCustom() {
        Pattern testRegex = Pattern.compile('"(\\w*)","(.*)","(\\d*)"');
        Map<Integer, String> indexMap = new Map<Integer, String> {
            1 => 'field1',
            2 => 'field2',
            3 => 'field3'
        };

        MDFDataLineParser lineParser = new MDFDataLineParser(indexMap, testRegex);

        Map<String, String> result = lineParser.parseLine('"foo","bar biz","1"');
        System.assert(result.get('field1').equals('foo'), 'field1 should have value of foo; had value of [' + result.get('field1') + ']');
        System.assert(result.get('field2').equals('bar biz'), 'field2 should have value of bar biz; had value of [' + result.get('field2') + ']');
    }
}