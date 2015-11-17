@isTest
private class SL_Test_ctrl_EquipDisp
{
	
	@isTest static void test_method_one()
	{
		Letter_of_Intent__c l = new Letter_of_Intent__c();
		insert l;

		Schedule__c s = new Schedule__c();
		s.Name = 'Test Schedule';
		s.Letter_of_Intent__c = l.Id;

		insert s;

		Equipment__c e = new Equipment__c();
		e.Name = 'Test Equipment';
		e.Schedule__c = s.Id;

		insert e;

		Equipment_Item__c ei = new Equipment_Item__c();
		ei.Serial__c = '123462';
		ei.Equipment__c = e.Id;

		insert ei;

		PageReference slp = Page.sl_equipdisp;
		Test.setCurrentPage(slp);
		ApexPages.currentPage().getParameters().put('sid',s.Id);

		SL_ctrl_EquipDisp ced = new SL_ctrl_EquipDisp();

		SL_ctrl_EquipDisp.EdWrapper edObj = new SL_ctrl_EquipDisp.EdWrapper();

		edObj.description = 'TEst';
		edObj.sId = s.Id;
		edObj.status = 'Late';
		edObj.type = 'Return';

		String edString = JSON.serialize(edObj);

		SL_ctrl_EquipDisp.createDisp(edString, new Id[]{ei.Id});
	}
	
}