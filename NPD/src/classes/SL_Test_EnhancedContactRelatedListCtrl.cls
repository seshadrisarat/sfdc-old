/**
    * \arg ClassName      : SL_Test_EnhancedContactRelatedListCtrl
    * \arg JIRATicket     : NPD-85
    * \arg CreatedOn      : 2/August/2015
    * \arg LastModifiedOn : 
    * \arg CreatededBy    : Sandeep
    * \arg ModifiedBy     : 
    * \arg Description    : This Test class for the SL_EnhancedContactRelatedListCtrl class.
*/
@isTest
private class SL_Test_EnhancedContactRelatedListCtrl 
{
	private static testMethod void testEnhancedContactRelLst() 
	{
	    List<RecordType> lstRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Parent_Account'];
	    
        Account objAccount = new Account (Name = 'Test Account 1', recordTypeId = lstRecordType[0].Id, BillingCountry = 'INDIA');
        insert objAccount;
        Contact objContact = new Contact (LastName = 'Test Contact', AccountId = objAccount.Id);
        insert objContact;
        
        Contact_Relationship__c objContactRelationship = new Contact_Relationship__c(Parent_Account__c = objAccount.Id, 
                                                                                        Contact__c = objContact.Id);
        insert objContactRelationship;
        
        ApexPages.StandardController sc = new ApexPages.standardController(objAccount);
        SL_EnhancedContactRelatedListCtrl sic = new SL_EnhancedContactRelatedListCtrl(sc);
        sic.idSelectedContactId = objContact.id;
        sic.delContactRecord();
	}
}