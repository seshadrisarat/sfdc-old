@isTest
private class SL_Test_Batch_MergeDuplicateContacts {

    static testMethod void myUnitTest() 
    {
    	// Insert Account 
        Account objAccount = new Account(Name = 'Broker View Contacts');
		insert objAccount;
		
		Account objAcc = new Account(Name = 'TestAccount');
		insert objAcc;
		
		List<Contact> lstContact = new List<Contact>();
		String strContactRecordtypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Broker Contact').getRecordTypeId();
		
		List<FeedItem> lstFeedItem;
		List<Attachment> lstAttachment;
		List<Note> lstNote;
		List<Task> lstTask;
		List<Event> lstEvent;
		List<CampaignMember> lstCM;
		
		// Add list of contact into list
		for(Integer intCount = 1; intCount <= 5; intCount++)
		{
			lstContact.add(new Contact(LastName = 'Test'+intCount, Title = 'Title', AccountId = objAccount.Id, Email = 'test'+intCount+'@test.com', recordTypeId = strContactRecordtypeId));
		}
		insert lstContact;
		system.debug('==lstContact='+lstContact);
        
        Contact objContact = new Contact(LastName = 'Test123', Title = 'Title', AccountId = objAcc.Id, Email = 'test2@test.com', recordTypeId = strContactRecordtypeId);
		insert objContact;
        system.debug('==objContactId='+objContact.Id);
        
        Contact objContact1 = new Contact(LastName = 'Test1234', Title = 'Title', AccountId = objAcc.Id, Email = 'test2@test.com', recordTypeId = strContactRecordtypeId);
		insert objContact1;
		
        lstAttachment = new List<Attachment>{
	        									new Attachment(Name='Unit Test Attachment', Body=Blob.valueOf('Unit Test Attachment Body'), parentId=objContact.id),
	        									new Attachment(Name='Unit Test Attachment1', Body=Blob.valueOf('Unit Test Attachment Body'), parentId=objContact.id)
        									};
        insert lstAttachment;
        
        lstFeedItem = new List<FeedItem>{
        									new FeedItem(ParentId=objContact.id, Body='TestFeed'),
        									new FeedItem(ParentId=objContact.id, Body='TestFeed1')
        								};
        insert lstFeedItem;
        lstNote = new List<Note>{
        							new Note(Title='Test', Body='Hello Test', ParentId=objContact.id),
        							new Note(Title='Test1', Body='Hello Test', ParentId=objContact.id)
        						};
        insert lstNote;   
          
        lstTask = new List<Task>{
						         new Task(Subject = 'test1', WhoId = objContact.id ),
						         new Task(Subject = 'test2', WhoId = objContact.id )
        						};
  		insert lstTask;
        
        lstEvent = new List<Event>{
        							new Event(Subject = 'Call', StartDateTime = Date.Today(), EndDateTime = Date.Today().addDays(5), WhoId = objContact.Id),
        							new Event(Subject = 'Email', StartDateTime = Date.Today(), EndDateTime = Date.Today().addDays(5), WhoId = objContact.Id)
        						  };
        insert lstEvent;
         
        Campaign c1 = new Campaign(name='Campaign 1',IsActive=true,StartDate=Date.newInstance(2015,02,19));
    	insert c1;
	
		Campaign c2 = new Campaign(name='Campaign 2',IsActive=true,StartDate=Date.newInstance(2015,01,19));
    	insert c2;    	
        lstCM = new List<CampaignMember>{
        									new CampaignMember(CampaignId=c1.Id, Status='Sent', ContactId=objContact.id),
        									new CampaignMember(CampaignId=c2.Id, Status='review', ContactId=objContact.id)
        								};
        insert lstCM;
        
        Test.startTest();
    	SL_Batch_MergeDuplicateContacts objBatch = new SL_Batch_MergeDuplicateContacts();
        Database.executeBatch(objBatch, 200);
        SL_ScheduleBatch_MergeDuplicateContacts.scheduleBatch();
    	Test.stopTest();
    }
}