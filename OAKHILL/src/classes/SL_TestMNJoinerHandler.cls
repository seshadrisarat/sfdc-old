@isTest
public class SL_TestMNJoinerHandler {

	static testMethod void unitTestCode() {

		MN_Page_Layout__c objLayout = new MN_Page_Layout__c(Name = 'Master_Task',  FieldSetName__c = 'SL_TaskDescription', 
															Email_Prefill__c = '', Profile__c = 'System Administrator');
		insert objLayout;

		MN_Related_List__c objRelatedList = new MN_Related_List__c(Name = 'Companies Discussed', DisplayName__c = 'DisplayName__c',
																   FieldSetName__c = 'SL_CompaniesDiscussedFieldSet', ObjectName__c = 'Account', Order__c = 1);

		insert objRelatedList;

		insert new MN_Joiner__c(MN_Page_Layout__c = objLayout.Id, MN_Related_List__c = objRelatedList.Id);

		try {

			insert new MN_Joiner__c(MN_Page_Layout__c = objLayout.Id, MN_Related_List__c = objRelatedList.Id);

		} catch(Exception e) {

			system.assert(true, e.getMessage().contains('Record already exists with provided MN Related List and MN Page Layout combination, Please provide different values'));
		}
	}
}