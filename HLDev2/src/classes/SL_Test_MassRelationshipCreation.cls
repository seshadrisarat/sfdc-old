/**  
* \arg ClassName      : SL_Test_MassRelationshipCreation
* \arg JIRATicket     : HL-14
* \arg CreatedOn      : 27/MAY/2014
* \arg LastModifiedOn : 27/MAY/2014
* \arg CreatededBy    : Lodhi
* \arg ModifiedBy     : -
* \arg Description    : Test class for SL_MassRelationshipCreation.cls
*/

@isTest
private class SL_Test_MassRelationshipCreation 
{
  
    static testMethod void myUnitTest() 
    {
        Id HLRecordtypeId = [SELECT Id FROM RecordType WHERE RecordType.DeveloperName = 'Houlihan_Employee'].Id;
        Id ExternalRTId = [SELECT Id FROM RecordType WHERE RecordType.DeveloperName = 'External_Contact'].Id;
    	
    	Account objAccount = new Account(Name = 'Test Account -01');
    	insert objAccount;
    	
    	Contact objContact = new Contact(LastName = 'Test Contact HL', AccountId = objAccount.Id, RecordTypeId = HLRecordtypeId);
        insert objContact;
        
        List<Contact> lstContact = new List<Contact>{
        												new Contact(LastName = 'Test Contact External-01', AccountId = objAccount.Id, RecordTypeId = ExternalRTId),
        												new Contact(LastName = 'Test Contact External-02', AccountId = objAccount.Id, RecordTypeId = ExternalRTId),
        												new Contact(LastName = 'Test Contact External-03', AccountId = objAccount.Id, RecordTypeId = ExternalRTId),
        												new Contact(LastName = 'Test Contact External-04', AccountId = objAccount.Id, RecordTypeId = ExternalRTId),
        												new Contact(LastName = 'Test Contact External-05', AccountId = objAccount.Id, RecordTypeId = ExternalRTId),
        												new Contact(LastName = 'Test Contact External-06', AccountId = objAccount.Id, RecordTypeId = ExternalRTId),
        												new Contact(LastName = 'Test Contact External-07', AccountId = objAccount.Id, RecordTypeId = ExternalRTId),
        												new Contact(LastName = 'Test Contact External-08', AccountId = objAccount.Id, RecordTypeId = ExternalRTId)
        											};
      
        insert lstContact;
        
        Engagement__c objEngagement = new Engagement__c(Name='Test Engagement', Client__c = objAccount.Id, Subject__c = objAccount.Id,
														Primary_Office__c = 'FF', Line_of_Business__c = 'CF',Stage__c = 'Closed / Won / Engaged', 
														Job_Type__c = 'Take Over Defense', Industry_Group__c = 'ADG');
		insert objEngagement;
		
		List<Engagement_External_Team__c> lstEET = new List<Engagement_External_Team__c>();
		
		for(Contact objCont : lstContact)
		{
			lstEET.add(new Engagement_External_Team__c(Engagement__c = objEngagement.Id, Contact__c = objCont.id, Type__c= 'External'));
			lstEET.add(new Engagement_External_Team__c(Engagement__c = objEngagement.Id, Contact__c = objCont.id, Type__c= 'Client'));
		}
		
		insert lstEET;
		ApexPages.StandardController sc = new ApexPages.standardController(objEngagement);
		SL_MassRelationshipCreation objMRC = new SL_MassRelationshipCreation(sc);
		objMRC.getContactOptions();
		objMRC.cancel();
		SL_MassRelationshipCreation.getRelationShipRecords(objEngagement.Id, objContact.Id, 'All_Contacts');
		SL_MassRelationshipCreation.getRelationShipRecords(objEngagement.Id, objContact.Id, 'External_Team');
		SL_MassRelationshipCreation.getRelationShipRecords(objEngagement.Id, objContact.Id, 'Client_Team');
		SL_MassRelationshipCreation.getRelationShipRecords(objEngagement.Id, objContact.Id, 'Counterparty_Contacts');
		
		SL_MassRelationshipCreation.upsertRelationshipRecord('', objContact.Id, lstContact[0].Id, '2', true);
		SL_MassRelationshipCreation.getRelationShipRecords(objEngagement.Id, objContact.Id, 'All_Contacts');
		
		List <Relationship__c> lstRelationship = [SELECT Id, 
														 Sync_to_Outlook__c, 
														 Strength_Rating__c 
													FROM Relationship__c 
												   WHERE External_Contact__c =: lstContact[0].Id AND HL_Contact__c =: objContact.Id];
		System.assertEquals(lstRelationship.size(), 1);
		System.assertEquals(lstRelationship[0].Sync_to_Outlook__c, true);
		SL_MassRelationshipCreation.upsertRelationshipRecord(lstRelationship[0].Id, objContact.Id, lstContact[0].Id, '2', false);
       	List <Relationship__c> lstRelationship1 = [SELECT Id, 
														 Sync_to_Outlook__c, 
														 Strength_Rating__c 
													FROM Relationship__c 
												   WHERE External_Contact__c =: lstContact[0].Id AND HL_Contact__c =: objContact.Id];
		System.assertEquals(lstRelationship1.size(), 1);
		System.assertEquals(lstRelationship1[0].Sync_to_Outlook__c, false);
    }
}