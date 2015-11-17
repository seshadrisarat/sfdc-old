/**
* \arg ClassName      : SL_Test_GenerateEmail
* \arg JIRATicket     : PWP-3
* \arg CreatedOn      : 10/DEC/2014
* \arg LastModifiedOn : 12/FEB/2014
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : Pradeep
* \arg Description    : This class serves as test class to check the funtionality of SL_GenerateEmail controller.
*/
@isTest
private class SL_Test_GenerateEmail 
{
    static Call_Report__c objCallReport;
    static List<Call_Report_Attendees__c> lstCRA;
    static List<Call_Report_Company__c> lstCRC;
    static List<Contact> lstContact;
    static List<Account> lstAccount;
    static List<Coverage_Team_Members__c> lstCTM;
    
    //Function to prepare data for testing the email functionality
    static void createData()
    {
    	
    	lstAccount = new List<Account>{
    										new Account(Name = 'Test Account1'),
    										new Account(Name = 'Test Account2')
    								  };
    	insert lstAccount;

		objCallReport = new Call_Report__c(Name = 'Test Call Report', Reference_Account__c = lstAccount[0].Id, Call_Report_Date__c = Date.today(), Interaction_Type__c = 'Call', Notes__c = 'Test Notes');
    	insert objCallReport;
    	    	
    	lstCTM = new List<Coverage_Team_Members__c>{
    													new Coverage_Team_Members__c(Company__c = lstAccount[0].Id),
    													new Coverage_Team_Members__c(Company__c = lstAccount[1].Id)
    											   };
		insert lstCTM;   											   
    								  
    	lstContact = new List<Contact>{
    										new Contact(LastName = 'Test Contact 1', Email = 'test1@silverlinecrm.com', AccountId = lstAccount[0].Id),
    										new Contact(LastName = 'Test Contact 2', Email = 'test2@silverlinecrm.com', AccountId = lstAccount[1].Id)
    								  };
    	insert lstContact;
    	
    	lstCRC = new List<Call_Report_Company__c>{
    												new Call_Report_Company__c(Call_Report__c = objCallReport.Id, Relevant_Company__c = lstAccount[0].Id),
    												new Call_Report_Company__c(Call_Report__c = objCallReport.Id, Relevant_Company__c = lstAccount[1].Id)
    											 };
    	insert lstCRC;
    	
    	lstCRA = new List<Call_Report_Attendees__c>{
    													new Call_Report_Attendees__c(Call_Report__c = objCallReport.Id, Call_Report_Attendee__c = lstContact[0].Id),
    													new Call_Report_Attendees__c(Call_Report__c = objCallReport.Id, Call_Report_Attendee__c = lstContact[1].Id)
    											   };
        insert lstCRA;
        
    }
    
    //This function is used to check for whether the Id of call report has been passed from URL or not
    static testMethod void checkForEmptyCallReport() 
    {
       createData();
       
       Test.startTest();
       ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(objCallReport);
       SL_GenerateEmail objGenerateEmail = new SL_GenerateEmail(sc);
       Test.stopTest();
    }
    
    //This function is used to check picklist values for coverage team members.
  	static testMethod void checkForCoverageTeamMembers() 
    {
       createData();
       
       Apexpages.currentPage().getParameters().put('id',objCallReport.Id);
       
       Test.startTest();
       ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(objCallReport);
       SL_GenerateEmail objGenerateEmail = new SL_GenerateEmail(sc);
       Test.stopTest();
       
       System.assertEquals(objGenerateEmail.mutiselectCoverageTeamMember.selected.size(), 1);
    }
    
    //This function is used to check for email sending functionality.
    static testmethod void checkForEmail()
    {
    	createData();       
        Apexpages.currentPage().getParameters().put('id',objCallReport.Id);
        
        Test.startTest();
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(objCallReport);
       	SL_GenerateEmail objGenerateEmail = new SL_GenerateEmail(sc);
        //objGenerateEmail.strCCAddresses = 'test1@pwppartners.com,test2@pwppartners.com';
        //objGenerateEmail.strBCCAddresses = 'test3@pwppartners.com,test4@pwppartners.com';
        objGenerateEmail.strBody = 'Test Body';
        objGenerateEmail.mutiselectCoverageTeamMember.selected = new List<SelectOption>{new SelectOption('test2@silverlinecrm.com','Test Contact 2 : test2@silverlinecrm.com')};
        objGenerateEmail.sendEmail();
        objGenerateEmail.cancel();
        Test.stopTest();
        
        System.assertEquals(objGenerateEmail.mutiselectCoverageTeamMember.selected.size(), 1);
    }
    
    //This function is used to check email exception
  	static testMethod void checkForException() 
    {
       createData();
       
       Apexpages.currentPage().getParameters().put('id',objCallReport.Id);
       
       Test.startTest();
       ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(objCallReport);
       SL_GenerateEmail objGenerateEmail = new SL_GenerateEmail(sc);
       objGenerateEmail.sendEmail();
       Test.stopTest();       
       
       System.assertEquals(objGenerateEmail.mutiselectCoverageTeamMember.selected.size(), 1);
       //System.assertEquals(objGenerateEmail.strCCAddresses, '');
       //System.assertEquals(objGenerateEmail.strBCCAddresses, '');
    }
    
}