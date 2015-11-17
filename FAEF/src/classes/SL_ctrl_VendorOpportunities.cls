public with sharing class SL_ctrl_VendorOpportunities {

	private List<Opportunity> opptyRecords;
	public String opptyRecordsJSON {get;set;}
	public List<Schema.FieldSetMember> listViewFieldSet {get;set;}
	public String listViewFieldSetJSON {get;set;}
	
	public  SL_ctrl_VendorOpportunities()
	{	
		initialize();
	} 

	private void initialize()
	{
	 	String query = 'SELECT ';
	 	SL_util_VendorCommunity.PortalBrandingWrapper branding = SL_util_VendorCommunity.getPortalBranding();
		String listviewName = branding.opportunityListview;
		listViewFieldSet = SObjectType.Opportunity.FieldSets.getMap().get(listviewName).getFields();
		listViewFieldSetJSON = JSON.serializePretty(listViewFieldSet);
        for(Schema.FieldSetMember f : listViewFieldSet) {
            query += f.getFieldPath() + ', ';
        }
        query += 'Id FROM Opportunity';
        User currentUser = [SELECT ContactId, Id FROM User WHERE Id = : UserInfo.getUserId()];
        if(currentUser.ContactId == null){
         	query += ' WHERE Vendor_Referral1__c = \'' + ApexPages.currentPage().getCookies().get('accountCookie').getValue() +'\'';   
        }
        opptyRecords = Database.query(query);
        opptyRecordsJSON = JSON.serializePretty(opptyRecords);
	}
}