//This is the Call Down List Test Class

@isTest
private class BTG_CallDownListTest {

    static testMethod void testCallDownListController() {
        Campaign c = new Campaign(name = 'test campaign');
        c.Call_Down_List__c = TRUE;
        c.Minimum_Attempts__c = 9;
        c.Action_1_Name__c = 'test 1';
        c.Action_2_Name__c = 'test 2';
        c.Action_3_Name__c = 'test 3';
        c.Action_4_Name__c = 'test 4';
        c.Action_5_Name__c = 'test 5';
        c.Action_6_Name__c = 'test 6';
        c.Action_7_Name__c = 'test 7';
        c.Action_8_Name__c = 'test 8';
        c.Action_9_Name__c = 'test 9';
        c.Action_10_Name__c = 'test 10';
        c.Action_1_Type__c = 'Call';
        c.Action_2_Type__c = 'Call';
        c.Action_3_Type__c = 'Call';
        c.Action_4_Type__c = 'Call';
        c.Action_5_Type__c = 'Call';
        c.Action_6_Type__c = 'Call';
        c.Action_7_Type__c = 'Call';
        c.Action_8_Type__c = 'Call';
        c.Action_9_Type__c = 'Call';
        c.Action_10_Type__c = 'Call';
        insert c;
        
        Account acc = new Account(name = 'test account');
        insert acc;
        
        Contact con = new Contact(firstname = 'test', lastname = 'contact');
        con.AccountId = acc.id;
        insert con;
        
        //Contact Task
        Task conTask = new Task(subject = 'test task');
        conTask.WhatId = acc.id;
        conTask.WhoId = con.id;
        insert conTask;
        
        Lead l = new Lead(firstname = 'test', lastname = 'lead', company = 'test company');
        insert l;
        
        //Lead Task
        Task lTask = new Task(subject = 'lead test task');
        lTask.WhoId = l.id;
        insert lTask;
        
        CampaignMember cmC = new CampaignMember();
        cmC.CampaignId = c.Id;
        cmC.ContactId = con.Id;
        cmC.Attempts__c = 1;
        insert cmC;
        
        CampaignMember cmL = new CampaignMember();
        cmL.CampaignId = c.id;
        cmL.LeadId = l.Id;
        cmL.Attempts__c = 1;
        insert cmL;
        
        Action_Result__c ar = new Action_Result__c();
        ar.Campaign__c = c.Id;
        ar.Contact__c = con.Id;
        ar.Message_Note__c = 'Test Action Result';
        ar.Result__c = 'Successful';
        ar.Attempt_Number__c = 1;
        insert ar;
        
        Action_Result__c arL = new Action_Result__c();
        arL.Campaign__c = c.Id;
        arL.Lead__c = l.Id;
        arL.Message_Note__c = 'Test Action Result';
        arL.Result__c = 'Successful';
        arL.Attempt_Number__c = 1;
        insert arL;
        
        
        callDownListController controller = new callDownListController();
        
        controller.campaignID = c.id;
        
        String baseURL = controller.baseURL;
        controller.leadID = l.id;
        
        //Create mock page and page parameters
        PageReference pageRef = Page.Call_Down_List;
        Test.setCurrentPage(pageRef);
        
        
        List<SelectOption> callDownLists = controller.getCallDownLists();
        System.assert(callDownLists.size() > 0);
        
        Campaign controllerTestCampaign = controller.getCurrentCampaign();
        System.assert(controllerTestCampaign != null);
        
        List<CampaignMember> campaignMembers = controller.getCampaignMembers();
        System.assert(campaignMembers.size() > 0);
        
        Campaign testCampaignActions = controller.getCampaignActions();
        System.assert(testCampaignActions != null);
        
        List<SelectOption> actionNumberPicklistValues = controller.getActionNumberPicklistValues();
        System.assert(actionNumberPicklistValues.size() > 0);
        
        controller.toggleCampaignMemberSortOrder();
        controller.toggleCampaignMemberSortOrder();
        
        controller.contactID = String.valueOf(con.id);
        controller.completeAction();
        controller.contactID = String.valueOf(con.id);
        controller.completeAction();
        controller.contactID = String.valueOf(con.id);
        controller.completeAction();
        controller.contactID = String.valueOf(con.id);
        controller.completeAction();
        controller.contactID = String.valueOf(con.id);
        controller.completeAction();
        controller.contactID = String.valueOf(con.id);
        controller.completeAction();
        controller.contactID = String.valueOf(con.id);
        controller.completeAction();
        controller.contactID = String.valueOf(con.id);
        controller.completeAction();
        controller.contactID = String.valueOf(con.id);
        controller.completeAction();
        controller.contactID = String.valueOf(con.id);
        controller.completeAction();
        controller.contactID = String.valueOf(con.id);
        controller.completeActionWithMessage();
        controller.completeActionSuccess();
        controller.closeAction();
        controller.popupRecordID = String.valueOf(l.id);
        system.debug('LEAD ID:' + controller.popupRecordID);
        controller.getFields();
        controller.fsm = SObjectType.Lead.FieldSets.LeadCallDownFS.getFields();
        controller.getLead();
        controller.popupRecordID = String.valueOf(con.id);
        system.debug('Contact ID:' + controller.popupRecordID);
        controller.fsm = SObjectType.Contact.FieldSets.ContactCallDownFS.getFields();
        controller.getContact();
        controller.popupRecordID = String.valueOf(acc.Id);
        system.debug('Account ID:' + controller.popupRecordID);
        controller.getAccountFields();
        controller.AccountFsm = SObjectType.Account.FieldSets.AccountCallDownFS.getFields();
        controller.getAccount();
        
        //Test Activity History
        ApexPages.currentPage().getParameters().put('recordID', l.id);
        controller.updatePopupInfo();
        controller.getActivityHistory();
        ApexPages.currentPage().getParameters().put('recordID', con.id);
        controller.updatePopupInfo();
        controller.getActivityHistory();
        
        //Lead saveActionResult
		for(Integer i = 0; i < 11; i++){
			ApexPages.currentPage().getParameters().put('leadID', l.id);
			cmL.Attempts__c = i;
			update cmL;
			controller.saveActionResult('This is a test message', 'Successful');
		}
        
        //Contact saveActionResult
        for(Integer i = 0; i < 11; i++){
			ApexPages.currentPage().getParameters().put('leadID', '');
			ApexPages.currentPage().getParameters().put('contactID', con.Id);
			cmC.Attempts__c = i;
			update cmC;
			controller.saveActionResult('This is a test message', 'Successful');
		}
    }
}