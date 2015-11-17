@isTest
private class SL_Test_NoteExtension
{
	
	@isTest static void test_method_one()
	{
        Note__c myN = new Note__c();
        ApexPages.StandardController sc = new ApexPages.StandardController(myN);
		SL_NoteExtension nEx = new SL_NoteExtension(sc);
		nEx.saveAndRedirect();

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

		Test.setCurrentPage(Page.SL_NoteAddEdit_VF);
		ApexPages.currentPage().getParameters().put('lkupId',a.id);

		nEx = new SL_NoteExtension(sc);

		nEx.saveAndRedirect();
		nEx.AccountPopulated();

		ApexPages.currentPage().getParameters().put('lkupId',r.id);

		nEx = new SL_NoteExtension(sc);

		nEx.GroupPopulated();
		nEx.getRelatedRelationshipGroupsForView();
		nEx.getFields();
		nEx.createNotification = true;
		nEx.saveAndRedirect();
		nEx.cancel();
		nEx.att.Body = Blob.valueOf('testme');
		nEx.att.Name = 'Test Att';
		nEx.uploadAtt();
	}
	
}