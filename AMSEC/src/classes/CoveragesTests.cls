@isTest
private class CoveragesTests {
	private static User u;
	private static Contact userCont;
	private static Contact cont;
	private static Industry_Group_Coverage__c coverage1;
	private static Industry_Group_Coverage__c coverage2;
	private static Industry_Group_Coverage__c coverage3;
	
	private static void setup() {
		Profile prof = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
		
		u = new User(
			FirstName = 'Unit',
			LastName = 'Test',
			Alias = 'UnitTest',
			CommunityNickname = 'UnitTest',
			Email = 'unittest@unittest.com',
			Username = 'unittest@unittest.com',
			TimeZoneSidKey = 'America/Los_Angeles',
			LocaleSidKey = 'en_US',
			LanguageLocaleKey = 'en_US',
			EmailEncodingKey = 'ISO-8859-1',
			ProfileId = prof.Id
		);
		insert u;
		
		Account userAcct = new Account(
			Name = 'Internal Account'
		);
		Account acct = new Account(
			Name = 'Customer Account'
		);
		insert new List<Account> { userAcct, acct };
		
		userCont = new Contact(
			FirstName = u.FirstName,
			LastName = u.LastName,
			Email = u.Email,
			AccountId = userAcct.Id,
			Salesforce_User__c = u.Id
		);
		cont = new Contact(
			FirstName = 'Test',
			LastName = 'Customer',
			Email = 'test@test.com',
			AccountId = acct.Id
		);
		insert new List<Contact> { userCont, cont };
		
		Industry_Group__c indGroup1 = new Industry_Group__c(
			Name = 'Unit Test Group 1',
			Coverage_Level__c = 'Medium'
		);
		Industry_Group__c indGroup2 = new Industry_Group__c(
			Name = 'Unit Test Group 2',
			Coverage_Level__c = 'Medium'
		);
		Industry_Group__c indGroup3 = new Industry_Group__c(
			Name = 'Unit Test Group 3',
			Coverage_Level__c = 'Medium'
		);
		insert new List<Industry_Group__c> { indGroup1, indGroup2, indGroup3 };
		
		coverage1 = new Industry_Group_Coverage__c(
			Industry_Group__c = indGroup1.Id,
			Company__c = acct.Id,
			Company_Contact__c = cont.Id,
			Primary_Coverage_Person__c = userCont.Id,
			Inactive__c = false,
			Industry_Group_Coverage_Level__c = 'High',
			Action_Frequency__c = '30 Days'
		);
		coverage2 = new Industry_Group_Coverage__c(
			Industry_Group__c = indGroup2.Id,
			Company__c = acct.Id,
			Company_Contact__c = cont.Id,
			Primary_Coverage_Person__c = userCont.Id,
			Inactive__c = false,
			Industry_Group_Coverage_Level__c = 'Medium',
			Action_Frequency__c = '60 Days'
		);
		coverage3 = new Industry_Group_Coverage__c(
			Industry_Group__c = indGroup3.Id,
			Company__c = acct.Id,
			Company_Contact__c = cont.Id,
			Primary_Coverage_Person__c = userCont.Id,
			Inactive__c = false,
			Industry_Group_Coverage_Level__c = 'Low',
			Action_Frequency__c = '90 Days'
		);
		insert new List<Industry_Group_Coverage__c> { coverage1, coverage2 , coverage3 };
	}
	
	private static Event loadEvent(Id eventId) {
		return [SELECT Id, Ind_Grp_Coverage_ID1__c, Ind_Grp_Coverage_ID2__c, Ind_Grp_Coverage_ID3__c, StartDateTime, Event_Type__c FROM Event WHERE Id = :eventId];
	}
	
	private static Industry_Group_Coverage__c loadCoverage(Id coverageId) {
		return [SELECT Id, Last_Action_Date__c, Last_Action__c, Last_Action_Type__c FROM Industry_Group_Coverage__c WHERE Id = :coverageId];
	}
	
	private static List<Industry_Group_Coverage__c> loadCoverages(Set<Id> coverageIds) {
		return [SELECT Id, Last_Action_Date__c, Last_Action__c, Last_Action_Type__c FROM Industry_Group_Coverage__c WHERE Id IN :coverageIds];
	}
	
	static testMethod void testCoverageLinkage() {
		setup();
		System.assertNotEquals(null, coverage1.Id);
		System.assertNotEquals(null, coverage2.Id);
		System.assertNotEquals(null, coverage3.Id);
		
		Industry_Group_Coverage__c coverage = loadCoverage(coverage1.Id);
		System.assertEquals(null, coverage.Last_Action_Date__c);
		System.assertEquals(null, coverage.Last_Action_Type__c);
		
		Event evnt = new Event(
			WhoId = cont.Id,
			OwnerId = u.Id,
			Subject = 'Meeting',
			Event_Type__c = 'Meeting',
			StartDateTime = System.now(),
			EndDateTime = System.now().addHours(1)
		);
		System.debug(System.LoggingLevel.INFO, '\n\n\n\n\nSTART HERE\n\n\n\n\n');
		insert evnt;
		
		evnt = loadEvent(evnt.Id);
		System.assertNotEquals(null, evnt.Ind_Grp_Coverage_ID1__c);
		System.assertNotEquals(null, evnt.Ind_Grp_Coverage_ID2__c);
		System.assertNotEquals(null, evnt.Ind_Grp_Coverage_ID3__c);
		System.assertNotEquals(evnt.Ind_Grp_Coverage_ID1__c, evnt.Ind_Grp_Coverage_ID2__c);
		System.assertNotEquals(evnt.Ind_Grp_Coverage_ID1__c, evnt.Ind_Grp_Coverage_ID3__c);
		System.assertNotEquals(evnt.Ind_Grp_Coverage_ID2__c, evnt.Ind_Grp_Coverage_ID3__c);
		System.assertNotEquals(null, evnt.StartDateTime);
		System.assertNotEquals(null, evnt.Event_Type__c);
		
		Set<Id> coverageIds = new Set<Id> { evnt.Ind_Grp_Coverage_ID1__c, evnt.Ind_Grp_Coverage_ID2__c, evnt.Ind_Grp_Coverage_ID3__c };
		System.assert(coverageIds.contains(coverage1.Id));
		System.assert(coverageIds.contains(coverage2.Id));
		System.assert(coverageIds.contains(coverage3.Id));
		
		Map<Id, Industry_Group_Coverage__c> coverageMap = new Map<Id, Industry_Group_Coverage__c>(loadCoverages(coverageIds));
		coverage = coverageMap.get(evnt.Ind_Grp_Coverage_ID1__c);
		System.assertNotEquals(null, coverage.Last_Action_Date__c);
		System.assertNotEquals(null, coverage.Last_Action_Type__c);
		System.assertEquals(evnt.StartDateTime.date(), coverage.Last_Action_Date__c);
		System.assertEquals(evnt.Event_Type__c, coverage.Last_Action_Type__c);
		
		coverage = coverageMap.get(evnt.Ind_Grp_Coverage_ID2__c);
		System.assertNotEquals(null, coverage.Last_Action_Date__c);
		System.assertNotEquals(null, coverage.Last_Action_Type__c);
		System.assertEquals(evnt.StartDateTime.date(), coverage.Last_Action_Date__c);
		System.assertEquals(evnt.Event_Type__c, coverage.Last_Action_Type__c);
		
		coverage = coverageMap.get(evnt.Ind_Grp_Coverage_ID3__c);
		System.assertNotEquals(null, coverage.Last_Action_Date__c);
		System.assertNotEquals(null, coverage.Last_Action_Type__c);
		System.assertEquals(evnt.StartDateTime.date(), coverage.Last_Action_Date__c);
		System.assertEquals(evnt.Event_Type__c, coverage.Last_Action_Type__c);
	}
}