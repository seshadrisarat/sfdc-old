/**
* \arg ClassName      		: SL_Test_HouseholdChildSharing
* \arg JIRATicket       	: HIL-21
* \arg CreatedOn        	: 13/OCT/2015
* \arg LastModifiedOn   	: 15/OCT/2015
* \arg CreatededBy      	: Pankaj Ganwani
* \arg LastModifiedBy       : Pankaj Ganwani
* \arg Description      	: This test class is used to check the functionality for household value population on custom objects of household.
*/
@isTest
private class SL_Test_HouseholdChildSharing 
{
    static final Id profileId = [SELECT Id FROM Profile WHERE Name = 'Financial Consultant' LIMIT 1].Id;
    static Account objAccount;
    static Relationship_Group__c objRG;
    static Group_Member__c objGM;
    static Group objGroup;
    static GroupMember objGroupMember;
    static Rep_Code__c objRepCode;
    static User objUser;
    
    private static void createData()
    {
    	objUser = new User(Alias = 'standt', Email='test8884444@testorg.com', 
				            	EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
				            	LocaleSidKey='en_US', ProfileId = profileId, 
				            	TimeZoneSidKey='America/Los_Angeles', UserName='fsdfdsf@testorg.com');  		
    	insert objUser;
    	
    	objAccount = new Account(Name = 'Test Account');
    	insert objAccount;
    	
    	objRG = new Relationship_Group__c(Name = 'Test Househod');
    	insert objRG;
    	
    	objGM = new Group_Member__c(Client_Prospect__c = objAccount.Id, Relationship_Group__c = objRG.Id);
    	insert objGM;
    	
    	objGroup = new Group(Name = 'Test Group');
    	insert objGroup;
    	
    	objGroupMember = new GroupMember(GroupId = objGroup.Id, UserOrGroupId = objUser.Id);
    	insert objGroupMember;
    	
    	objRepCode = new Rep_Code__c(Name = 'Test Rep Code', Public_Group_Id__c = objGroup.Id, Rep_Code__c = 'Test');
    	insert objRepCode;
    }
    
    private static testMethod void testForCustomObjects()
    {    	
    	createData();
  		
    	Opportunity objOpp = new Opportunity(Name = 'Test Opp', AccountId = objAccount.Id, CloseDate = Date.today(), StageName = 'Open');
    	insert objOpp;
    	
    	Insurance__c objI = new Insurance__c(Name = 'Test Insurance', Client_Prospect__c = objAccount.Id);
    	insert objI;
    	
    	Relationship__c objRelationship = new Relationship__c(Account__c = objAccount.Id);
    	insert objRelationship;
    	
    	Held_Away_Asset__c objHAA = new Held_Away_Asset__c(Name = 'Test Held away asset', Client_Prospect__c = objAccount.Id);
    	insert objHAA;
    	
    	Liability__c objLiability = new Liability__c(Name = 'Test Liability', Client_Prospect__c = objAccount.Id);
    	insert objLiability;
    	
    	Income_Source__c objIS = new Income_Source__c(Name = 'Test Income Source', Client_Prospect__c = objAccount.Id);
    	insert objIS;
    	
    	Interests__c objInterest = new Interests__c(Client_Prospect__c = objAccount.Id);
    	insert objInterest;
    	
    	Financial_Plan__c objFP = new Financial_Plan__c(Name = 'Test FP', Client_Prospect__c = objAccount.Id);
    	insert objFP;
    	
    	Household_To_Account_Affiliation__c objHAAff = new Household_To_Account_Affiliation__c(Relationship_Group__c = objRG.Id, Account__c = objAccount.Id);
    	insert objHAAff;
    }
    
    static testMethod void testForDocumentAndProductsServices() 
    {
    	createData();    	
    	Test.startTest();
    	
        Document__c objDocument = new Document__c(Name = 'Test Document', Client_Prospect__c = objAccount.Id);
    	insert objDocument;
    	
    	Products_Services__c objPS = new Products_Services__c(Client_Prospect__c = objAccount.Id);
    	insert objPS;
    	
    	Test.stopTest();
    }
}