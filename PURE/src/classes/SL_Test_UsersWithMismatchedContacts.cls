@isTest
private class SL_Test_UsersWithMismatchedContacts
{

	private static final Boolean PRIMARY = true;
	private static final Boolean NOT_PRIMARY = false;

	@isTest
	static void batchTest(){

		Integer numContactsCreated = 1;
		Integer numUsersCreated; // Should equal numPrimaryContactsCreated
		Integer numPrimaryContactsCreated = 1;

		List<Account> accounts = createAccounts(numContactsCreated);
		List<Contact> primaryContacts = createContacts(numPrimaryContactsCreated, PRIMARY, accounts); // Create Primary Contacts
		List<Contact> contacts = createContacts(numContactsCreated, NOT_PRIMARY, accounts); // Create non-primary contacts
		
		Contact contactWithRelatedObjects = primaryContacts[0];
		insertCampaignMember(contactWithRelatedObjects);
		insertAttachment(contactWithRelatedObjects);
		insertNote(contactWithRelatedObjects);
		insertFeedItem(contactWithRelatedObjects);
		insertTask(contactWithRelatedObjects);

		numContactsCreated = primaryContacts.size() + contacts.size();
		numUsersCreated = createPortalUsers(contacts); // Associate users with Non-Primary Contacts

		Test.startTest();
		SL_UsersWithMismatchedContacts_Cleanup batch = new SL_UsersWithMismatchedContacts_Cleanup(null);
		Database.executeBatch(batch);
		Test.stopTest();

		Integer numUsersWithPrimaryContacts = [SELECT COUNT() 
											   FROM User 
											   WHERE ContactId IN (SELECT Id 
											   					   FROM Contact 
											   					   WHERE Primary__c = true)];
		Integer numPrimaryContacts = [SELECT COUNT() 
									  FROM Contact 
									  WHERE Primary__c = true];

		Integer numTotalContacts = [SELECT COUNT() 
									FROM Contact];

		Set<Id> relatedObjectsContact = new Set<Id>();

		List<CampaignMember> cm = [SELECT ContactId FROM CampaignMember];
		System.debug('~~~~ cm: ' + cm);
		System.assert(cm != null && cm.size() == 1, 'Campaign Member not found');
		relatedObjectsContact.add(cm[0].ContactId);

		List<Attachment> a = [SELECT ParentId FROM Attachment];
		System.assert(a != null && a.size() == 1, 'Attachment not found');
		relatedObjectsContact.add(a[0].ParentId);

		List<Note> note = [SELECT ParentId FROM Note];
		System.assert(note != null && note.size() == 1, 'Note not found');
		relatedObjectsContact.add(note[0].ParentId);

		List<FeedItem> fi = [SELECT ParentId FROM FeedItem];
		System.assert(fi != null && fi.size() == 1, 'FeedItem not found');
		relatedObjectsContact.add(fi[0].ParentId);

		List<Task> task = [SELECT WhoId FROM Task];
		System.assert(task != null && task.size() == 1, 'Task not found');
		relatedObjectsContact.add(task[0].WhoId);

		System.assertEquals(relatedObjectsContact.size(), 1, 'Error: More than one contact associated with related objects.');

		List<Contact> c = [SELECT Primary__c FROM Contact WHERE Id IN :relatedObjectsContact];
		System.assertEquals(c[0].Primary__c, true, 'Error: Related objects not related to Primary Contact');

		// Users should only be associated with Primary Contacts after batch
		System.assertEquals(numUsersWithPrimaryContacts, numUsersCreated, 'Error: Number of users with Primary Contacts doesn\'t match number of users created');

		// Should have same number of contacts at end as at beginning
		System.assertEquals(numTotalContacts, numContactsCreated, 'Error: Number of total contacts after the batch doesn\'t match number of contacts created');
	}

	public static void insertCampaignMember(Contact contact){
		Campaign campaign = new Campaign(Name = 'Test');
		insert campaign;

		CampaignMember cm = new CampaignMember();
		cm.CampaignId = campaign.Id;
		cm.ContactId = contact.Id;
		insert cm;
		System.debug('~~~~ Inserted CampaignMember: ' + cm);
	}

	public static void insertAttachment(Contact contact){
		Attachment atchmnt = new Attachment();
		atchmnt.Name = 'test';
		atchmnt.Body = Blob.valueOf('test');
		atchmnt.Description = 'test';
		atchmnt.ParentId = contact.Id;
		insert atchmnt;
		System.debug('~~~~ Inserted Attachment: ' + atchmnt);
	}

	public static void insertNote(Contact contact){
		Note note = new Note();
		note.Title = 'test';
		note.IsPrivate = false;
		note.Body = 'test';
		note.ParentId = contact.Id;
		insert note;
		System.debug('~~~~ Inserted Note: ' + note);
	}

	public static void insertFeedItem(Contact contact){
		FeedItem fi = new FeedItem();
		fi.Title = 'test post';
		fi.Body = 'test post';
		fi.ParentId = contact.Id;
		insert fi;
		System.debug('~~~~ Inserted FeedItem: ' + fi);
	}

	public static void insertTask(Contact contact){
		Task t = new Task();
		t.Priority = 'low';
		t.Status = 'In Progress';
		t.WhoId = contact.Id;
		insert t;
		System.debug('~~~~ Inserted Task: ' + t);
	}

	public static List<Account> createAccounts(Integer numAccounts){
		List<Account> accounts = new List<Account>();

		for(Integer j = numAccounts-1; j >= 0; j--){
			Account a = new Account();
			a.Name = 'test' + j;
			accounts.add(a);
		}

		insert accounts;
		System.debug('~~~~~ Accounts Inserted: ' + accounts);
		return accounts;
	}

	public static List<Contact> createContacts(Integer numContacts, Boolean isPrimary, List<Account> accounts){
		

		List<Contact> contacts = new List<Contact>();

		for(Integer i = numContacts-1; i >= 0; i--){
			Contact c = new Contact();
			c.LastName = '' + i + isPrimary;
			c.Email = '' + i + isPrimary + '@test.com';
			c.Phone = '8888888888';
			c.Primary__c = isPrimary;
			c.AccountId = accounts[i].id;
			contacts.add(c);
		}

		insert contacts;

		System.debug('~~~~~ Contacts inserted: ' + contacts);
		return contacts;
	}

	public static Integer createPortalUsers(List<Contact> contacts){
		List<User> users = new List<User>();

		for(Integer i = contacts.size()-1; i >= 0; i--){

			User newUser = new User();
			newUser.Alias = contacts[i].LastName.mid(1,7);
			newUser.CommunityNickname = contacts[i].Email;
			newUser.ContactId = contacts[i].Id;
			newUser.DefaultGroupNotificationFrequency = 'N';
			newUser.DigestFrequency = 'N';
			newUser.Email = contacts[i].email;
			newUser.EmailEncodingKey = 'ISO-8859-1';
			newUser.FirstName = 'test';
			newUser.LanguageLocaleKey = 'en_US';
			newUser.LastName = contacts[i].LastName;
			newUser.LocaleSidKey = 'en_US';
			newUser.ProfileId = '00ed0000000WxDy'; // Pure Customer Community Login user
			newUser.TimeZoneSidKey = 'GMT';
			newUser.Username = contacts[i].email;

			users.add(newUser);
		}

		insert users;
		System.debug('~~~~~ Users inserted: ' + users);

		return users.size();
	}
}