/**
* \arg ClassName      : SL_Test_FinancialAccountHandler
* \arg JIRATicket     : HIL-7
* \arg CreatedOn      : 18/FEB/2015
* \arg LastModifiedOn : -
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : -
* \arg Description    : This class serves as test class for SL_FinancialAccount trigger handler and is used to check the functionality for updation of HL account records corresponding to updated financial accounts which in turn updates the Group member records.
*/
@isTest
private class SL_Test_FinancialAccountHandler 
{
    static final String strPersonRecordType = [SELECT Id FROM RecordType WHERE SobjectType=:'Account' AND IsPersonType = true LIMIT 1].Id;
    
    static List<Financial_Account__c> lstFA;
    static List<Hilliard_Lyons_Account__c> lstHLAccount;
    static List<Account> lstAccount;
    static List<Group_Member__c> lstGM;
    static List<Relationship_Group__c> lstRG;
    
    //function to prepare test data
    private static void createData()
    {
    	lstRG = new List<Relationship_Group__c>{
    												new Relationship_Group__c(Name = 'Test RG 1'),
    												new Relationship_Group__c(Name = 'Test RG 2')
    										   };
    	insert lstRG;
    	
    	lstAccount = new List<Account>{
    										new Account(FirstName = 'Test', LastName = 'Account 1', RecordTypeId = strPersonRecordType),
    										new Account(FirstName = 'Test', LastName = 'Account 2', RecordTypeId = strPersonRecordType)
    								  };
    	insert lstAccount;
    	
    	lstGM = new List<Group_Member__c>{
    										new Group_Member__c(Client_Prospect__c = lstAccount[0].Id, Relationship_Group__c = lstRG[0].Id),
    										new Group_Member__c(Client_Prospect__c = lstAccount[0].Id, Relationship_Group__c = lstRG[1].Id),
    										new Group_Member__c(Client_Prospect__c = lstAccount[1].Id, Relationship_Group__c = lstRG[0].Id),
    										new Group_Member__c(Client_Prospect__c = lstAccount[1].Id, Relationship_Group__c = lstRG[1].Id)
    									 };
    	insert lstGM;
    	
    	lstFA = new List<Financial_Account__c>{
    												new Financial_Account__c(Name = 'Test FA 1', Money_Market_Balance__c = 123, Revenue__c = 900, Total_Account_Equity__c = 981),
    												new Financial_Account__c(Name = 'Test FA 1', Money_Market_Balance__c = 123, Revenue__c = 900, Total_Account_Equity__c = 901)
    										  };
    	insert lstFA;
    	
    	lstHLAccount = new List<Hilliard_Lyons_Account__c>{
    															new Hilliard_Lyons_Account__c(Financial_Account__c	 = lstFA[0].Id, Client__c = lstAccount[0].Id, Role__c = 'Primary'),
    															new Hilliard_Lyons_Account__c(Financial_Account__c	 = lstFA[0].Id, Client__c = lstAccount[1].Id, Role__c = 'Primary'),
    															new Hilliard_Lyons_Account__c(Financial_Account__c	 = lstFA[1].Id, Client__c = lstAccount[0].Id, Role__c = 'Primary'),
    															new Hilliard_Lyons_Account__c(Financial_Account__c	 = lstFA[1].Id, Client__c = lstAccount[1].Id, Role__c = 'Primary')
    													  };
    	insert lstHLAccount;
    }
    
    //function to check the functionality of update
    static testMethod void checkForUpdate() 
    {
        createData();
        
        lstFA[0].Money_Market_Balance__c = 222;
        
        Test.startTest();
        update lstFA[0];
        Test.stopTest();
        
        //System.assertEquals([SELECT Asset_Value_RU__c FROM Hilliard_Lyons_Account__c WHERE Id =: lstHLAccount[0].Id].Asset_Value_RU__c, 981);
        //System.assertEquals([SELECT Total_Primary_Asset_RU__c FROM Group_Member__c WHERE Id =: lstGM[0].Id].Total_Primary_Asset_RU__c, 1882);
    }
    
    //function to check the functionality of delete
    static testMethod void checkForDelete()
    {
    	createData();
    	delete lstFA[0];
    }
}