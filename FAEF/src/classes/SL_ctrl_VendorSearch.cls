public with sharing class SL_ctrl_VendorSearch {
	private List<Opportunity> opptyResults;
	public String opptyResultsJSON {get;set;}
	private List<Schedule__c> schedResults;
	public String schedResultsJSON {get;set;}
	private List<User> userResults;
	public String userResultsJSON {get;set;}
	public String opptyFieldSetJSON {get;set;}
	public String schedFieldSetJSON {get;set;}

	public SL_ctrl_VendorSearch() {
		init();
	}

	private void init(){
		String query = ApexPages.currentPage().getParameters().get('query');
		String searchString = 'Find {'+EncodingUtil.urlDecode(query, 'UTF-8')+'} IN ALL FIELDS RETURNING ';
		
		searchString += 'Opportunity (Id ';
		for(Schema.FieldSetMember fld :SObjectType.Opportunity.FieldSets.FAEF_Vendor_Opportunity_Listview.getFields()){
			searchString += ', ' + fld.getFieldPath();
		}

		searchString += '), Schedule__c (Id ';
		for(Schema.FieldSetMember fld :SObjectType.Schedule__c.FieldSets.FAEF_Vendor_Schedule_Listview.getFields()){
			searchString += ', ' + fld.getFieldPath();
		}

		searchString += ')';
		
		try{
			List<List<SObject>> searchResults = search.query(searchString);
			opptyResults = (List<Opportunity>) searchResults[0];
			opptyResultsJSON = JSON.serializePretty(opptyResults);
			schedResults = (List<Schedule__c>) searchResults[1];
			schedResultsJSON = JSON.serializePretty(schedResults);
			//userResults = (List<User>) searchResults[2];
			//userResultsJSON = JSON.serializePretty(userResults);

			opptyFieldSetJSON = JSON.serializePretty(SObjectType.Opportunity.FieldSets.FAEF_Vendor_Opportunity_Listview.getFields());
			schedFieldSetJSON = JSON.serializePretty(SObjectType.Schedule__c.FieldSets.FAEF_Vendor_Schedule_Listview.getFields());
		}catch(Exception e){
			ApexPages.addMessages( e );
			System.debug(LoggingLevel.ERROR, e);

			opptyResultsJSON = '{}';
			schedResultsJSON = '{}';
			
			opptyFieldSetJSON = JSON.serializePretty(SObjectType.Opportunity.FieldSets.FAEF_Vendor_Opportunity_Listview.getFields());
			schedFieldSetJSON = JSON.serializePretty(SObjectType.Schedule__c.FieldSets.FAEF_Vendor_Schedule_Listview.getFields());
		}		
	}
}