@isTest
private class JIRAWSHtml_Test {

    static testMethod void  test_JIRAWS() {
		pse__Proj__c proj = new pse__Proj__c();
        proj.Name = 'TEST';
        proj.JIRA_Project_Name__c = 'TEST';
        proj.pse__Is_Active__c = true;
        proj.pse__Is_Billable__c = true;
        proj.pse__Allow_Timecards_Without_Assignment__c = true;
        insert proj;
        
        Contact resource = new Contact();
        resource.LastName = 'Test LN';
        resource.pse__Is_Resource_Active__c = true;
        resource.pse__Is_Resource__c = true;
        resource.JIRA_User_Name__c = 'test';
        resource.pse__Salesforce_User__c = UserInfo.getUserId();
        insert resource;
        
        JIRAWSHtml.createIssue(proj.Id, null, UserInfo.getUserId());
	}
}