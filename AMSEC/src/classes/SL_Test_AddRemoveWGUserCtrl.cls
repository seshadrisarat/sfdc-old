/**
ClassName        : SL_Test_AddRemoveWGUserCtrl
JIRA Ticket 	 : AMSEC-565
CreatedOn 		 : 22/Sept/15
LastModifiedOn   : 22/Sept/15
CreatededBy 	 : Praful Gadge
ModifiedBy 		 : Praful Gadge
Description      : Unit Test code for functionality that adds/removes WG Member on Deal__c(Inv. Opp.)
*/
@isTest
private class SL_Test_AddRemoveWGUserCtrl {

    static testMethod void testAddRemoveMeMethodDeal() {
        Test.startTest();

        //Creating New Contact
        Contact objContact = new Contact(LastName = 'TestContact1', Salesforce_User__c = UserInfo.getUserId());
        insert objContact;
        
        //Creating new Industry Group Record
        Industry_Group__c objInductryGroup = new Industry_Group__c(Name = 'TestIndustry');
        insert objInductryGroup; 
        
        //Creating new Deal Record
        Deal__c objDeal = new Deal__c(Name = 'Test Deal', Industry_Deal__c = objInductryGroup.Id);
        insert objDeal;

        External_Working_Group_Member__c objWGMembersToInsert = new External_Working_Group_Member__c(
	                                                            Contact__c = objContact.Id, 
	                                                            Initial_Participation_Date__c = System.today(),
	                                                            Deal__c = objDeal.Id
	                                                        );

        insert objWGMembersToInsert;
     		
 		ApexPages.currentPage().getParameters().put('Id', objDeal.Id);

        SL_AddRemoveWGUserCtrl objExtension = new SL_AddRemoveWGUserCtrl();
        
        objExtension.addRemoveMe();
            
        Test.stopTest();
    }

    static testMethod void testAddRemoveMeMethodProject() {
    	Test.startTest();

    	//Creating New Contact
        Contact objContact = new Contact(LastName = 'TestContact1', Salesforce_User__c = UserInfo.getUserId());
        insert objContact;

    	//Creating New Account
    	Account objAccount = new Account(Name = 'TestAccount1');
    	insert objAccount;

    	//Creating New AS_Project__c
    	AS_Project__c objProject = new AS_Project__c(Portfolio_Company__c = objAccount.Id, Start_Date__c = System.today(), Project_Health__c = 'On Track');
    	insert objProject;

    	ApexPages.currentPage().getParameters().put('Id', objProject.Id);

        SL_AddRemoveWGUserCtrl objExtension = new SL_AddRemoveWGUserCtrl();
        
        objExtension.addRemoveMe();

        objExtension.getButtonLabel();
            
        Test.stopTest(); 
    }

    static testMethod void testAddRemoveMeMethodAccount() {
    	Test.startTest();

    	//Creating New Contact
        Contact objContact = new Contact(LastName = 'TestContact1', Salesforce_User__c = UserInfo.getUserId());
        insert objContact;

    	//Creating New Account
    	Account objAccount = new Account(Name = 'TestAccount1');
    	insert objAccount;

    	//Creating New External_Working_Group_Member__c
    	External_Working_Group_Member__c objWGMembersToInsert = new External_Working_Group_Member__c(
	                                                            Contact__c = objContact.Id, 
	                                                            Initial_Participation_Date__c = System.today(),
	                                                            Company__c = objAccount.Id
	                                                        );

        insert objWGMembersToInsert;

    	ApexPages.currentPage().getParameters().put('Id', objAccount.Id);

        SL_AddRemoveWGUserCtrl objExtension = new SL_AddRemoveWGUserCtrl();
        
        objExtension.addRemoveMe();
            
        Test.stopTest(); 
    }
}