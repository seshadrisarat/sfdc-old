/**
* \arg TriggerName    		: SL_RollUpDealTeamMembersToDeal_Test
* \arg JIRATicket     		: MOELISSUPP-17,MOELISSUPP-34
* \arg CreatedOn      		: 21/01/2014
* \arg LastModifiedOn       : 09/10/2014
* \arg CreatededBy    		: Pankaj Ganwani
* \arg ModifiedBy     		: Pankaj Ganwani
* \arg Description    		: This class is used to check the functionality for rolling up of deal team members and senior deal team members to deal object record.
*/
@isTest
private class SL_RollUpDealTeamMembersToDeal_Test 
{

    static Account objAccount;
    static Ibanking_Project__c objDeal;
    static List<Employee_Profile__c> lstEmployee;
    static List<Project_Resource__c> lstDealTeamMember;
    static List<SL_SeniorBankerTitle__c> lstSeniorBankerTitle;
    
    static void createData()
    {
    	objAccount = new Account(Name = 'Test Account');
        insert objAccount;
        
        objDeal = new Ibanking_Project__c(Name = 'Test Deal', Client__c = objAccount.Id);
        insert objDeal;
        
        lstEmployee = new List<Employee_Profile__c> { 
														new Employee_Profile__c(First_Name__c = 'Test', Last_Name__c='Employee', User_ID__c = Userinfo.getUserId(), Title__c = 'Managing Director'),
						  								new Employee_Profile__c(First_Name__c = 'Test1', Last_Name__c='Employee', User_ID__c = Userinfo.getUserId(), Title__c = 'Analyst')
						  							};
        				
        insert lstEmployee;
        
        lstSeniorBankerTitle = new List<SL_SeniorBankerTitle__c>{
        															new SL_SeniorBankerTitle__c(Name = 'Managing Director'),
        															new SL_SeniorBankerTitle__c(Name = 'Senior Advisor'),
        															new SL_SeniorBankerTitle__c(Name = 'Senior Vice President')
        														};
        insert lstSeniorBankerTitle;
        
        lstDealTeamMember = new List<Project_Resource__c>{
															new Project_Resource__c(Banker__c = lstEmployee[0].Id, Project__c = objDeal.Id, Status__c = 'Active'),
															new Project_Resource__c(Banker__c = lstEmployee[1].Id, Project__c = objDeal.Id, Status__c = 'Active')
														 };
		insert lstDealTeamMember;
    }
    
    static testMethod void checkForInsert() 
    {
        createData();        
        
        System.assertEquals([SELECT Deal_Team_Members__c FROM Ibanking_Project__c WHERE Id =: objDeal.Id].Deal_Team_Members__c,'T.  Employee, T.  Employee');
        System.assertEquals([SELECT Senior_Banker_Deal_Team_Member__c FROM Ibanking_Project__c WHERE Id =: objDeal.Id].Senior_Banker_Deal_Team_Member__c,'T.  Employee');                  																
    }
    
    static testMethod void checkForUpdate()
    {
    	createData();
    	List<Project_Resource__c> lstUpdatedDealTeamMember = new List<Project_Resource__c>{
																							   new Project_Resource__c(Id = lstDealTeamMember[0].Id, Banker__c = lstEmployee[1].Id, Project__c = objDeal.Id, Status__c = 'Active'),
																						       new Project_Resource__c(Id = lstDealTeamMember[1].Id, Banker__c = lstEmployee[0].Id, Project__c = objDeal.Id, Status__c = 'Inctive')
																					   	  };
        Test.startTest();
        update lstUpdatedDealTeamMember;
        Test.stopTest();
        
        System.assertEquals([SELECT Deal_Team_Members__c FROM Ibanking_Project__c WHERE Id =: objDeal.Id].Deal_Team_Members__c,'T.  Employee'); 
        System.assertEquals([SELECT Senior_Banker_Deal_Team_Member__c FROM Ibanking_Project__c WHERE Id =: objDeal.Id].Senior_Banker_Deal_Team_Member__c,null);    
    }
    
    static testMethod void checkForDelete()
    {
    	createData();
    	List<Project_Resource__c> lstDeletedDealTeamMember = new List<Project_Resource__c>{
    																						new Project_Resource__c(Id = lstDealTeamMember[0].Id),
        																			        new Project_Resource__c(Id = lstDealTeamMember[1].Id)
        																			      };
        Test.startTest();
        delete lstDeletedDealTeamMember; 
        Test.stopTest();       
        
        System.assertEquals([SELECT Deal_Team_Members__c FROM Ibanking_Project__c WHERE Id =: objDeal.Id].Deal_Team_Members__c,null);
        System.assertEquals([SELECT Senior_Banker_Deal_Team_Member__c FROM Ibanking_Project__c WHERE Id =: objDeal.Id].Senior_Banker_Deal_Team_Member__c,null);
    }
}