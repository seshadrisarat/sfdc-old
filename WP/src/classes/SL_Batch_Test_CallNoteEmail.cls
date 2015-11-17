/**
* \arg ClassName      : SL_Batch_Test_CallNoteEmail
* \arg JIRATicket     : WP-136
* \arg CreatedOn      : 5/MAY/2014
* \arg LastModifiedOn : -
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : -
* \arg Description    : This test class is used to check the funtionality of SL_Batch_CallNotesEmail batch process.
*/
@isTest
private class SL_Batch_Test_CallNoteEmail 
{
	static final Id callNote = [SELECT Id FROM RecordType WHERE SobjectType=:'Event' AND DeveloperName =:'Fundraising_Event' LIMIT 1].Id;
	static final Id employee = [SELECT Id FROM RecordType WHERE SobjectType=:'Contact' AND DeveloperName =:'Employee' LIMIT 1].Id;
	static Account objAccount;
	static Event objEvent;
	static List<Contact> lstContact;
	static List<Admin_Assignment__c> lstAdminAssignment;
	static Reply_To_Address__c objReplyToAddress;
	
	//Method to prepare test data
	private static void createData()
	{
		objAccount = new Account(Name = 'Test Account');
		insert objAccount;
		
		lstContact = new List<Contact>{
											new Contact(LastName = 'Test Contact1', Email = 'test@sil.com', RecordTypeId = employee),
											new Contact(LastName = 'Test Contact1', Email = 'test1@sil.com', RecordTypeId = employee)
									  };
		insert lstContact;
		
		objEvent = new Event(Subject = 'Test', StartDateTime = Datetime.newInstance(2015, 5, 5, 10, 35, 45), EndDateTime = Datetime.newInstance(2015, 5, 5, 11, 35, 45), RecordTypeId = callNote, WhoId = lstContact[0].Id);
		insert objEvent;
		
		objReplyToAddress = new Reply_To_Address__c(Name = 'Default', Email__c = 'jflsdjf@apex.salesforce.com');
		insert objReplyToAddress;
		
		lstAdminAssignment = new List<Admin_Assignment__c>{
																new Admin_Assignment__c(Professional__c = lstContact[0].Id, Admin__c = lstContact[1].Id)
														  };
		insert lstAdminAssignment;
	}
	
	//test method for checking the call note email batch functionality
    static testMethod void checkForCallNote() 
    {
       createData();
       
       Test.startTest();
       Database.executeBatch(new SL_Batch_CallNotesEmail(),1);
       Test.stopTest();
       
       System.assertEquals([SELECT CallNotesRequestSent__c FROM Event WHERE Id =:objEvent.Id].CallNotesRequestSent__c, true);
    }
}