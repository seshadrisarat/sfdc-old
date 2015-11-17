@isTest
private class SL_Test_DeleteNote_Ctrl {
	
	@isTest static void test_method_one()
	{
		Account a = new Account();
		a.Name = 'test account';

		insert a;

		Rep_Code__c rc = new Rep_Code__c();
		rc.Rep_Code__c = 'AB01';

		insert rc;

		Rep_Code_User__c rcu = new Rep_Code_User__c();
		rcu.Rep_Code__c = rc.Id;
		rcu.User__c = UserInfo.getUserId();

		insert rcu;

		Relationship_Group__c r = new Relationship_Group__c();
		r.Name = 'Test group';
		r.Rep_Code__c = rc.Id;

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

		Note__c n = new Note__c();
		n.Account_del__c = a.Id;
		n.Rep_Code__c = rc.Id;
		n.Create_Joiner_Records__c = true;

		insert n;

		SL_DiffRecordUtil.getSObjectTypeName(n);
	}
	
}