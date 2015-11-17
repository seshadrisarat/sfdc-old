public with sharing class SL_Related_Topics {

	// for storing the Related_Topics_Excel__c field value
	private String excelTopics;
	// for storing the Related_Topic__c field value
	private String topics;
	public SL_Related_Topics(String topics, String excelTopics) {
		this.topics=topics;
		this.excelTopics=excelTopics;
	}
	public String getTopics (){ return topics; }

	public String getExcelTopics (){ return excelTopics; }

}