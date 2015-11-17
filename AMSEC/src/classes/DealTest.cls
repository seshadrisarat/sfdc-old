@isTest
private class DealTest {
	private static General_Settings__c settings;
	private static User u1, u2, u3;
	private static Account acct;
	private static Deal__c d1;
	private static Industry_Group__c indGroup1;

	private static void setup(Boolean autoFollow, String dealStage, Boolean fc) {
		settings = new General_Settings__c(
			SetupOwnerId = UserInfo.getOrganizationId(),
			Auto_Follow_Deals__c = autoFollow
		);
		insert settings;

		Profile prof = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

		u1 = createUser('Unit', 'Test1', 'unittest1@unittest.com', 'UT1', prof);
		u2 = createUser('Unit', 'Test2', 'unittest2@unittest.com', 'UT2', prof);
		u3 = createUser('Unit', 'Test3', 'unittest3@unittest.com', 'UT3', prof);
		insert new List<User> { u1, u2, u3 };

		acct = new Account(
			Name = 'Unit Test Account'
		);
		insert acct;

		indGroup1 = new Industry_Group__c(
			Name = 'Industry Group 1',
			Industry__c = 'Consumer',
			Coverage_Level__c = 'Low'
		);
		insert indGroup1;

		d1 = createDeal('Deal 1', System.today(), dealStage, false);
		insert d1;
	}

	private static User createUser(String firstName, String lastName, String email, String alias, Profile prof) {
		return new User(
			FirstName = firstName,
			LastName = lastName,
			Alias = alias,
			CommunityNickname = alias,
			Email = email,
			Username = email,
			TimeZoneSidKey = 'America/Los_Angeles',
			LocaleSidKey = 'en_US',
			LanguageLocaleKey = 'en_US',
			EmailEncodingKey = 'ISO-8859-1',
			ProfileId = prof.Id
		);
	}

	private static Deal__c createDeal(String name, Date launchDate, String finalStage, Boolean fc) {
		return new Deal__c(
			Name = name,
			Source_Company__c = acct.Id,
			AS_Team__c = u1.Alias,
			Deal_Launch_Date__c = launchDate,
			Deal_Status__c = 'LOI Signed',
			Final_AS_Stage__c = finalStage,
			Fireside_Chat__c = fc,
			Industry_Deal__c = indGroup1.Id,
			EBITDA__c = 600,
			Tracking_Status__c='TrackingAc'
		);
	}

	private static Deal__c loadDeal(Id dId) {
		return [SELECT Id, AS_Team__c, AS_Team_Hidden__c, Deal_Launch_Date__c, Final_AS_Stage__c, Fireside_Chat__c, Stage_Column__c, FC_Column__c, Inv_Opp_Launch_Year__c, Include_In_Funnel_Stage__c, Include_In_Funnel_FC__c FROM Deal__c WHERE Id = :dId];
	}

	private static List<EntitySubscription> loadSubscriptions(Id dId) {
		return [SELECT Id, ParentId, SubscriberId FROM EntitySubscription WHERE ParentId = :dId];
	}

	static testMethod void testTeamStamping() {
		setup(false, 'Idea', false);

		d1 = loadDeal(d1.Id);
		System.assertNotEquals(null, d1.AS_Team_Hidden__c);
		System.assertEquals(d1.AS_Team__c, d1.AS_Team_Hidden__c);
	}

	static testMethod void testDealAutoFollow() {
		setup(true, 'Idea', false);

		List<EntitySubscription> entSubs = loadSubscriptions(d1.Id);
		System.assertEquals(1, entSubs.size());

		insert new EntitySubscription(
			ParentId = d1.Id,
			SubscriberId = u2.Id
		);

		Set<Id> expectedIds = new Set<Id> { u1.Id, u2.Id };
		entSubs = loadSubscriptions(d1.Id);
		System.assertEquals(2, entSubs.size());

		for(EntitySubscription entSub : entSubs) {
			System.assertEquals(true, expectedIds.contains(entSub.SubscriberId));
		}

		expectedIds.add(u3.Id);
		d1.AS_Team__c = u1.Alias + ';' + u3.Alias;
		update d1;
		entSubs = loadSubscriptions(d1.Id);
		System.assertEquals(3, entSubs.size());

		for(EntitySubscription entSub : entSubs) {
			System.assertEquals(true, expectedIds.contains(entSub.SubscriberId));
		}

		expectedIds.remove(u1.Id);
		d1.AS_Team__c = u3.Alias;
		update d1;
		entSubs = loadSubscriptions(d1.Id);
		System.assertEquals(2, entSubs.size());

		for(EntitySubscription entSub : entSubs) {
			System.assertEquals(true, expectedIds.contains(entSub.SubscriberId));
		}

		settings.Auto_Follow_Deals__c = false;
		update settings;

		expectedIds = new Set<Id> { u2.Id, u3.Id };
		d1.AS_Team__c = u1.Alias + ';' + u3.Alias;
		update d1;
		entSubs = loadSubscriptions(d1.Id);
		System.assertEquals(2, entSubs.size());

		for(EntitySubscription entSub : entSubs) {
			System.assertEquals(true, expectedIds.contains(entSub.SubscriberId));
		}
	}

	/*static testMethod void testStageColumns() {
		setup(false, 'Second Round Bid', false);

		Deal__c d2 = createDeal('Deal 2', System.today(), 'Second Round Bid', false);
		insert d2;

		d1 = loadDeal(d1.Id);
		d2 = loadDeal(d2.Id);

		System.assertNotEquals(null, d1.Inv_Opp_Launch_Year__c);
		System.assertNotEquals(null, d2.Inv_Opp_Launch_Year__c);
		System.assertEquals(true, d1.Include_In_Funnel_Stage__c);
		System.assertEquals(true, d2.Include_In_Funnel_Stage__c);
		System.assertEquals(1, d1.Stage_Column__c);
		System.assertEquals(2, d2.Stage_Column__c);
	}

	static testMethod void testFiresideChatColumns() {
		setup(false, 'Fireside Chat', true);

		Deal__c d2 = createDeal('Deal 2', System.today(), 'Fireside Chat', true);
		insert d2;

		d1 = loadDeal(d1.Id);
		d2 = loadDeal(d2.Id);

		System.assertEquals(true, d1.Fireside_Chat__c);
		System.assertNotEquals(null, d1.Inv_Opp_Launch_Year__c);
		System.assertNotEquals(null, d2.Inv_Opp_Launch_Year__c);
		System.assertEquals(true, d1.Include_In_Funnel_FC__c);
		System.assertEquals(true, d2.Include_In_Funnel_FC__c);
		System.assertEquals(1, d1.FC_Column__c);
		System.assertEquals(2, d2.FC_Column__c);
	}*/
}