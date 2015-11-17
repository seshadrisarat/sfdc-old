@isTest
private class SL_Test_Batch_ConvertActivities {
	
	@isTest static void test_method_one()
	{
		Account a = new Account();
		a.Name = 'test account';

		insert a;

		Rep_Code__c rc = new Rep_Code__c();
		rc.Rep_Code__c = 'PA01';

		insert rc;

		Rep_Code__c rc2 = new Rep_Code__c();
		rc2.Rep_Code__c = 'PA02';

		insert rc2;

		Rep_Code_User__c rcu = new Rep_Code_User__c();
		rcu.Rep_Code__c = rc.Id;
		rcu.User__c = UserInfo.getUserId();

		insert rcu;

		User u = [Select Id
				  From User
				  WHERE Profile.Name != 'System Administrator' AND IsActive = true LIMIT 1];

		Rep_Code_User__c rcu2 = new Rep_Code_User__c();
		rcu2.Rep_Code__c = rc2.Id;
		rcu2.User__c = u.Id;

		insert rcu2;

		Relationship_Group__c r = new Relationship_Group__c();
		r.Name = 'Test group';
		r.Rep_Code__c = rc2.Id;

		insert r;

		Group_Member__c gm = new Group_Member__c();
		gm.Client_Prospect__c = a.Id;
		gm.Relationship_Group__c = r.Id;

		insert gm;

		Financial_Account__c fa = new Financial_Account__c();
		fa.Rep_Code__c = rc.Id;

		insert fa;

		Hilliard_Lyons_Account__c hla = new Hilliard_Lyons_Account__c();
		hla.Financial_Account__c = fa.Id;
		hla.Client__c = a.Id;

		insert hla;

		Task t = new Task();
		t.WhatId = r.Id;

		insert t;

		Attachment att = new Attachment();
		att.Name = 'Test';
		att.Body = Blob.valueOf('test');
		att.ParentId = t.Id;
		insert att;

		Test.startTest();
		SL_Batch_ConvertActivities cjBatch = new SL_Batch_ConvertActivities();
		Database.executeBatch(cjBatch);
		Test.stopTest();
	}
	
}