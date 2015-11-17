public with sharing class SL_ctrl_VendorSchedules {

	private List<Schedule__c> scheduleRecords;
	public String scheduleRecordsJSON {get;set;}
	public List<Schema.FieldSetMember> listViewFieldSet {get;set;}
	public String listViewFieldSetJSON {get;set;}
	
	public  SL_ctrl_VendorSchedules()
	{
		initialize();
	}
	
	private void initialize()
	{
		String query = 'SELECT ';

		SL_util_VendorCommunity.PortalBrandingWrapper branding = SL_util_VendorCommunity.getPortalBranding();
		String listviewName = branding.scheduleListview;
		listViewFieldSet = SObjectType.Schedule__c.FieldSets.getMap().get(listviewName).getFields();
		listViewFieldSetJSON = JSON.serializePretty(listViewFieldSet);
        for(Schema.FieldSetMember f : listViewFieldSet) {
            query += f.getFieldPath() + ', ';
        }
        query += 'Id FROM Schedule__c';
        User currentUser = [SELECT ContactId, Id FROM User WHERE Id = : UserInfo.getUserId()];
        if(currentUser.ContactId == null){
         	query += ' WHERE Letter_of_Intent__r.Vendor_Referral1__c = \'' + ApexPages.currentPage().getCookies().get('accountCookie').getValue() +'\'';   
        }
        scheduleRecords = Database.query(query);
        scheduleRecordsJSON = JSON.serializePretty(scheduleRecords);
	}

}