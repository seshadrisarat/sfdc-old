/**
* \arg ClassName      : SL_Test_CompanyReport
* \arg JIRATicket     : HL-25
* \arg CreatedOn      : 21/Aug/2014
* \arg LastModifiedOn : 21/AUg/2014
* \arg CreatededBy    : Lodhi
* \arg ModifiedBy     : -
* \arg Description    : Test class for SL_CompanyReport page.
*/
@isTest
private class SL_Test_CompanyReport 
{
    static testMethod void Test_CompanyReport () 
    {
		Id HLRecordtypeId = [SELECT Id FROM RecordType WHERE RecordType.DeveloperName = 'Houlihan_Employee'].Id;
		Id ExternalRTId = [SELECT Id FROM RecordType WHERE RecordType.DeveloperName = 'External_Contact'].Id;
		
		Profile objProfile = [SELECT Id,
    								 Name 
    							FROM Profile
    						   WHERE Name = 'Solution Manager'];
		
		List<User> lstUser = new List<User>();
    	For(User objUser : SL_TestSetupUtils.CreateUser('User',1))
    	{
    		objUser.Lastname = 'User';
    		objUser.Email = 'tuser@yahoo.in';
    		objUser.Username = 'test@hl2.com';
    		objUser.ProfileId = objProfile.Id;
    		objUser.Alias = 'tuser';
    		objUser.TimeZoneSidKey = 'GMT';
    		objUser.LocaleSidKey = 'en_US';
    		objUser.EmailEncodingKey = 'ISO-8859-1';
    		objUser.LanguageLocaleKey = 'en_US';
    		objUser.Has_Delegates__c = false;
    		lstUser.add(objUser);
    	}
    	insert lstUser;
    	
    	List<Delegate_Public_Group__c> lstDPG = new List<Delegate_Public_Group__c>();
        For(Delegate_Public_Group__c objDPG : SL_TestSetupUtils.createDPG('Delegate_Public_Group__c', 1))
        {
        	objDPG.Banker__c = lstUser[0].Id;
        	lstDPG.add(objDPG);
        }
        insert lstDPG;
		
		List<Account> lstAccount1 = SL_TestSetupUtils.CreateAccount('Account' , 1);
		insert lstAccount1;
		
		List<Account> lstAccount2 = new List<Account>();
        For(Account objAccount : SL_TestSetupUtils.CreateAccount('Account' , 1))
        {
            objAccount.ParentId = lstAccount1[0].Id;
            objAccount.Phone = '9800225544';
            objAccount.Website = 'silverlinecrm.com';
            objAccount.EBITDA_MM__c = 54545;
            objAccount.AnnualRevenue = 78754;
            objAccount.BillingStreet = '20A, RC Road';
            objAccount.BillingCity = 'Bangalore';
            objAccount.BillingState = 'Karnataka';
            objAccount.BillingPostalCode = '455544';
            objAccount.BillingCountry = 'India';
            objAccount.Total_Debt_MM__c = 4500;
            objAccount.Industry = 'Banking';
            objAccount.OwnerId = Userinfo.getUserId();
            objAccount.Description = 'Cisco Systems, Inc. designs, manufactures';
            lstAccount2.add(objAccount);                            
        }
		insert lstAccount2;
		
		List<Account> lstAccount3 = SL_TestSetupUtils.CreateAccount('Account' , 1);
		lstAccount3[0].ParentId = lstAccount2[0].Id;
		insert lstAccount3;
		
		List<Contact> lstContactHL = new List<Contact>();
        for(Contact objContact : SL_TestSetupUtils.CreateContact('Contact', 10))
        {
            objContact.AccountId = lstAccount2[0].Id;
            objContact.RecordTypeId = HLRecordtypeId;
            objContact.User__c = lstUser[0].Id;
            lstContactHL.add(objContact);
        }
        insert lstContactHL;
        System.assertEquals(lstContactHL.size(), 10);
        
        List<Contact> lstContactEX = new List<Contact>();
        for(Contact objContact : SL_TestSetupUtils.CreateContact('Contact', 10))
        {
            objContact.AccountId = lstAccount2[0].Id;
            objContact.RecordTypeId = ExternalRTId;
            lstContactEX.add(objContact);
        }
        insert lstContactEX;
        System.assertEquals(lstContactEX.size(), 10);
        
        List<Opportunity__c> lstOpportunity = new List<Opportunity__c>();
        for(Opportunity__c objOpportunity : SL_TestSetupUtils.CreateOpp('Opportunity__c', 5))
        {
            objOpportunity.Client__c = lstAccount2[0].Id;
            objOpportunity.Subject__c = lstAccount1[0].Id;
            objOpportunity.Stage__c = 'Low';
            objOpportunity.Pitch_Date__c = Date.today();
            objOpportunity.Referral_Company__c = lstAccount3[0].Id; 
            objOpportunity.Estimated_Engagement_Date__c = Date.today().addDays(3);
            objOpportunity.Estimated_Fee__c = 2500;
            lstOpportunity.add(objOpportunity);
        }
        insert lstOpportunity;
        System.assertEquals(lstOpportunity.size(), 5);
        
        List<Opportunity_Internal_Team__c> lstOIT = new List<Opportunity_Internal_Team__c>();
        for(Opportunity_Internal_Team__c objOIT : SL_TestSetupUtils.CreateOIT('Opportunity_Internal_Team__c', 5))
        {
            objOIT.Opportunity__c = lstOpportunity[0].Id;
            objOIT.Contact__c = lstContactHL[0].Id;
            objOIT.Principal__c = true;
            lstOIT.add(objOIT);
        }
        insert lstOIT;
        System.assertEquals(lstOIT.size(), 5);
        
        List<Engagement__c> lstEngagement = new List<Engagement__c>();
        for(Engagement__c objEngagement : SL_TestSetupUtils.CreateEngagement('Engagement__c', 5))
        {
            objEngagement.Client__c = lstAccount2[0].Id;
            objEngagement.Subject__c = lstAccount2[0].Id;
            objEngagement.Status__c = 'Active';
            objEngagement.Start_Date__c = Date.Today();
            objEngagement.Job_Type__c = 'Special Situations';
            lstEngagement.add(objEngagement);
        }
        insert lstEngagement;
        System.assertEquals(lstEngagement.size(), 5);
        
        List<Engagement_Counterparty__c> lstEC = new  List<Engagement_Counterparty__c>();
        for(Engagement_Counterparty__c objEC : SL_TestSetupUtils.CreateEC('Engagement_Counterparty__c', 10))
        {
            objEC.Company__c = lstAccount2[0].Id;
            objEC.Engagement__c = lstEngagement[0].Id;
            lstEC.add(objEC);
        }
        insert lstEC;
        System.assertEquals(lstEC.size(), 10);
        
        List<Engagement_Counterparty_Contact__c> lstECC = new List<Engagement_Counterparty_Contact__c>();
        for(Engagement_Counterparty_Contact__c objECC : SL_TestSetupUtils.CreateECC('Engagement_Counterparty_Contact__c', 10))
        {
            objECC.Counterparty__c = lstEC[0].Id;
            objECC.Contact__c = lstContactHL[0].Id;
            objECC.Type__c = 'Primary';
            lstECC.add(objECC);
        }
        insert lstECC;
        System.assertEquals(lstECC.size(), 10);
        
        List<Engagement_Internal_Team__c> lstEIT = new List<Engagement_Internal_Team__c>();
        for(Engagement_Internal_Team__c objEIT : SL_TestSetupUtils.CreateEIT('Engagement_Internal_Team__c', 2))
        {
            objEIT.Contact__c = lstContactHL[0].Id;
            objEIT.Engagement__c = lstEngagement[0].Id;
            objEIT.Principal__c = true;
            lstEIT.add(objEIT);
        }
        insert lstEIT;
        System.assertEquals(lstEIT.size(), 2);
        
        Integer i = 0, j = 0;
        List<Event> lstEvent = new List<Event>();
        for(Event objEvent : SL_TestSetupUtils.CreateEvent('Event', 5))
        {
            objEvent.StartDateTime = datetime.now();
            objEvent.EndDateTime = datetime.now();
            objEvent.ActivityDate = date.Today();
            objEvent.OwnerId = Userinfo.getUserId();
            objEvent.Subject = 'Email';
            objEvent.WhatId = lstEC[0].Id;
            lstEvent.add(objEvent);
        }
        
        for(Event objEvent : SL_TestSetupUtils.CreateEvent('Event', 5))
        {
            objEvent.StartDateTime = datetime.now();
            objEvent.EndDateTime = datetime.now();
            objEvent.ActivityDate = date.Today();
            objEvent.OwnerId = Userinfo.getUserId();
            objEvent.Subject = 'Email';
            objEvent.WhatId = lstEngagement[0].Id;
            lstEvent.add(objEvent);
        }
        
        for(Event objEvent : SL_TestSetupUtils.CreateEvent('Event', 5))
        {
            objEvent.StartDateTime = datetime.now();
            objEvent.EndDateTime = datetime.now();
            objEvent.ActivityDate = date.Today();
            objEvent.OwnerId = Userinfo.getUserId();
            objEvent.Subject = 'Email';
            objEvent.WhatId = lstOpportunity[0].Id;
            lstEvent.add(objEvent);
        }
        
        for(Event objEvent : SL_TestSetupUtils.CreateEvent('Event', 5))
        {
            objEvent.StartDateTime = datetime.now().addHours(-2);
            objEvent.EndDateTime = datetime.now().addHours(-2);
            objEvent.ActivityDate = date.Today();
            objEvent.OwnerId = Userinfo.getUserId();
            objEvent.WhatId = lstAccount2[0].Id;
            objEvent.Subject = 'Email';
            lstEvent.add(objEvent);
        }
        
        for(Event objEvent : SL_TestSetupUtils.CreateEvent('Event', 5))
        {
            objEvent.StartDateTime = datetime.now();
            objEvent.EndDateTime = datetime.now();
            objEvent.ActivityDate = date.Today();
            objEvent.OwnerId = Userinfo.getUserId();
            objEvent.WhatId = lstAccount2[0].Id;
            objEvent.Subject = 'Email';
            lstEvent.add(objEvent);
        }
        
        for(Event objEvent : SL_TestSetupUtils.CreateEvent('Event', 5))
        {
            objEvent.StartDateTime = datetime.now();
            objEvent.EndDateTime = datetime.now().addHours(2);
            objEvent.ActivityDate = date.Today().addDays(-1);
            objEvent.OwnerId = Userinfo.getUserId();
            objEvent.WhoId = lstContactHL[j].Id;
            objEvent.Subject = 'Email';
            lstEvent.add(objEvent);
            i++;
            if (i > 2)
            	j = 1; 
        }
        
        for(Event objEvent : SL_TestSetupUtils.CreateEvent('Event', 5))
        {
            objEvent.StartDateTime = datetime.now().addHours(-2);
            objEvent.EndDateTime = datetime.now().addHours(-2);
            objEvent.ActivityDate = date.Today().addDays(-1);
            objEvent.OwnerId = Userinfo.getUserId();
            objEvent.WhoId = lstContactEX[0].Id;
            objEvent.Subject = 'Email';
            lstEvent.add(objEvent);
        }
        
        i = 0; j = 0; 
      	for(Event objEvent : SL_TestSetupUtils.CreateEvent('Event', 5))
        {
            objEvent.StartDateTime = datetime.now();
            objEvent.EndDateTime = datetime.now();
            objEvent.ActivityDate = date.Today().addDays(-1);
            objEvent.OwnerId = Userinfo.getUserId();
            objEvent.WhoId = lstContactHL[j].Id;
            objEvent.Subject = 'Email';
            lstEvent.add(objEvent);
            i++;
            if(i > 2)
            	j = 1;
        }
        insert lstEvent;
        System.assertEquals(lstEvent.size(), 40);
		
        List<Task> lstTask = new List<Task>();
        
        for(Task objTask : SL_TestSetupUtils.CreateTask('Task', 5))
        {
            objTask.ActivityDate = date.Today();
            objTask.Subject = 'Email';
            objTask.OwnerId = Userinfo.getUserId();
            objTask.WhoId = lstContactEX[0].Id;
            objTask.Status = 'Not Started';
            lstTask.add(objTask);
        }
        
        for(Task objTask : SL_TestSetupUtils.CreateTask('Task', 5))
        {
            objTask.ActivityDate = date.Today();
            objTask.Subject = 'Email';
            objTask.OwnerId = Userinfo.getUserId();
            objTask.WhoId = lstContactEX[0].Id;
            objTask.Status = 'Completed';
            lstTask.add(objTask);
        }
        
        for(Task objTask : SL_TestSetupUtils.CreateTask('Task', 5))
        {
            objTask.ActivityDate = date.Today();
            objTask.Subject = 'Email';
            objTask.OwnerId = Userinfo.getUserId();
            objTask.WhatId = lstECC[0].Id;
            objTask.Status = 'Completed';
            lstTask.add(objTask);
        }
        
        for(Task objTask : SL_TestSetupUtils.CreateTask('Task', 5))
        {
            objTask.ActivityDate = date.Today();
            objTask.Subject = 'Email';
            objTask.OwnerId = Userinfo.getUserId();
            objTask.WhatId = lstEngagement[0].Id;
            objTask.Status = 'Completed';
            lstTask.add(objTask);
        }
        
        for(Task objTask : SL_TestSetupUtils.CreateTask('Task', 5))
        {
            objTask.ActivityDate = date.Today();
            objTask.Subject = 'Email';
            objTask.OwnerId = Userinfo.getUserId();
            objTask.WhatId = lstOpportunity[0].Id;
            objTask.Status = 'Completed';
            lstTask.add(objTask);
        }
        
        i = 0; j = 0;
        for(Task objTask : SL_TestSetupUtils.CreateTask('Task', 5))
        {
        	objTask.Subject = 'Email';
            objTask.ActivityDate = date.Today();
            objTask.OwnerId = Userinfo.getUserId();
            objTask.WhoId = lstContactHL[j].Id;
            lstTask.add(objTask);
            i++;
            if(i > 2)
            	j = 1;
        }
        
        i = 0; j = 0;
        for(Task objTask : SL_TestSetupUtils.CreateTask('Task', 5))
        {
        	objTask.Subject = 'Email';
            objTask.ActivityDate = date.Today();
            objTask.OwnerId = Userinfo.getUserId();
            objTask.WhoId = lstContactHL[j].Id;
            objTask.Status = 'Completed';
            lstTask.add(objTask);
            i++;
            if(i > 2)
            	j = 1;
        }
        
        for(Task objTask : SL_TestSetupUtils.CreateTask('Task', 5))
        {
            objTask.ActivityDate = date.Today();
            objTask.OwnerId = Userinfo.getUserId();
            objTask.WhoId = lstContactEX[0].Id;
            lstTask.add(objTask);
        }
        
        for(Task objTask : SL_TestSetupUtils.CreateTask('Task', 5))  
        {
            objTask.ActivityDate = date.Today().addDays(-180);
            objTask.OwnerId = Userinfo.getUserId();
            objTask.WhatId = lstAccount2[0].Id;
            lstTask.add(objTask);
        }
        
        for(Task objTask : SL_TestSetupUtils.CreateTask('Task', 5))  
        {
            objTask.ActivityDate = date.Today().addDays(-180);
            objTask.Status = 'Completed';
            objTask.OwnerId = Userinfo.getUserId();
            objTask.WhatId = lstAccount2[0].Id;
            lstTask.add(objTask);
        }
        insert lstTask;
		System.assertEquals(lstTask.size(), 50);
		
		System.currentPageReference().getParameters().put('Id',''+lstAccount2[0].Id);  
        SL_CompanyReport objCompanyReport = new SL_CompanyReport();
        objCompanyReport.getCompany();
        objCompanyReport.getCompanyRelationship();
        objCompanyReport.getHLRelationship();
        objCompanyReport.getRecentActivities();
        objCompanyReport.getOpenOpportunities();
        objCompanyReport.getTransInvolvement(); 
        objCompanyReport.getDealsData();
    }
}