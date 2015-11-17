/**
* \arg ClassName      : SL_ContactClone
* \arg JIRATicket     : HL-22
* \arg CreatedOn      : 15/JULY/2014
* \arg LastModifiedOn : 15/JULY/2014
* \arg CreatededBy    : Lodhi
* \arg ModifiedBy     : -
* \arg Description    : Test class for SL_ContactClone.
*/
@isTest()
public with sharing class SL_Test_ContactClone 
{
	@isTest()
	static void test_ContactClone()
    {
    	Id HLRecordtypeId = [SELECT Id FROM RecordType WHERE RecordType.DeveloperName = 'Houlihan_Employee'].Id;
        Id ExternalRTId = [SELECT Id FROM RecordType WHERE RecordType.DeveloperName = 'External_Contact'].Id;
        
    	List<Contact> lstContactHL = SL_TestSetupUtils.CreateContact('Contact', 1);
        lstContactHL[0].RecordTypeId = HLRecordtypeId;
    	insert lstContactHL;
    	
    	List<Contact> lstContactEX = SL_TestSetupUtils.CreateContact('Contact', 1);
        lstContactEX[0].RecordTypeId = ExternalRTId;
        insert lstContactEX;
    	
    	List<Relationship__c> lstRelationship = new List<Relationship__c>();
        for(Relationship__c objRelationship : SL_TestSetupUtils.CreateRelationship('Relationship__c', 5))
        {
            lstRelationship.add(new Relationship__c(External_Contact__c = lstContactEX[0].Id, HL_Contact__c = lstContactHL[0].Id));
        }
        insert lstRelationship;
        System.assertEquals(lstRelationship.size(), 5);
        
    	ApexPages.StandardController sc = new ApexPages.standardController(lstContactHL[0]);
    	SL_ContactClone objContactClone = new SL_ContactClone(sc); 
    	objContactClone.cloneContact();
    	
    	List<Contact> lstContact = [SELECT Id FROM Contact];
    	System.assertEquals(lstContact.size(), 3);
    }
}