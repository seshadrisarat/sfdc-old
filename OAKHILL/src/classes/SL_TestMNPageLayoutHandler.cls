@isTest
public class SL_TestMNPageLayoutHandler {

	static testMethod void unitTestCode() {

		SL_MNPageLayoutHandler objMNPageLayoutHandler = new SL_MNPageLayoutHandler();

		MN_Page_Layout__c objMNPageLayout = new MN_Page_Layout__c();
		objMNPageLayout.FieldSetName__c = 'SL_TaskDescription';
		objMNPageLayout.RecordType__c = 'Test';
		objMNPageLayout.Profile__c = 'System Administrator';
		insert objMNPageLayout; 

		try {

			MN_Page_Layout__c objMNPageLayout1 = new MN_Page_Layout__c();
			objMNPageLayout1.FieldSetName__c = 'SL_TaskDescription';
			objMNPageLayout1.RecordType__c = 'Test';
			objMNPageLayout1.Profile__c = 'System Administrator';
			insert objMNPageLayout1;

		} catch(Exception e) {

			//Exception
		}

		try {

			MN_Page_Layout__c objMNPageLayout2 = new MN_Page_Layout__c();
			objMNPageLayout2.FieldSetName__c = 'SL_TaskDescription';
			objMNPageLayout2.RecordType__c = 'Test11';
			objMNPageLayout2.Profile__c = 'System Administrator';
			insert objMNPageLayout2;

		} catch(Exception e) {

			//Exception
		}
	}
}