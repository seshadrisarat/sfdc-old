/**
* \arg ClassName      : SL_RelationshipTearsheet_Report
* \arg JIRATicket     : HL-24
* \arg CreatedOn      : 27/Aug/2014
* \arg LastModifiedOn : 27/AUg/2014
* \arg CreatededBy    : Sathya
* \arg ModifiedBy     : -
* \arg Description    : Test class for SL_RelationshipTearsheet_Report.
*/
@isTest
private class SL_Test_RelationshipTearsheet_Report 
{
    static testMethod void Test_RelationshipTearsheet_Report() 
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
    	
    	List<Account> lstAccount = new List<Account>();
        For(Account objAccount : SL_TestSetupUtils.CreateAccount('Account' , 1))
        {
            objAccount.Name = 'Abc';
            objAccount.EBITDA_MM__c = 54545;
            objAccount.Total_Debt_MM__c = 4500;
            objAccount.AnnualRevenue = 78754;
            lstAccount.add(objAccount);                            
        }
		insert lstAccount;
		
		List<Contact> lstContactEX = SL_TestSetupUtils.CreateContact('Contact', 1);
		lstContactEX[0].RecordTypeId = ExternalRTId;
		insert lstContactEX;
		
		List<Contact> lstContactHL = new List<Contact>();
        for(Contact objContact : SL_TestSetupUtils.CreateContact('Contact', 1))
        {
            objContact.AccountId = lstAccount[0].Id;
            objContact.Title = 'Title-1';
            objContact.Phone = '989898989';
            objContact.MobilePhone = '989898989';
            objContact.Email = 'abc@silverlinecrm.com';      
            objContact.AssistantName = 'TestAsst.-1';
            objContact.AssistantPhone = '9875487884';
            objContact.RecordTypeId = HLRecordtypeId;
            objContact.User__c = lstUser[0].Id;
            lstContactHL.add(objContact);
        }
        insert lstContactHL;
        
        List<Affiliation__c> lstAffiliation = new List<Affiliation__c>();
        for(Affiliation__c objAffiliation : SL_TestSetupUtils.CreateAffiliation('Affiliation__c', 7))
        {
        	objAffiliation.Account__c = lstAccount[0].Id;
        	objAffiliation.Contact__c = lstContactHL[0].Id;
        	objAffiliation.End_Date__c = Date.today();
        	objAffiliation.Status__c = 'Former';
        	objAffiliation.End_Date__c = Date.today().addDays(5);
        	objAffiliation.Type__c = 'Outside Board Member';
        	lstAffiliation.add(objAffiliation);
        }
        
        for(Affiliation__c objAffiliation : SL_TestSetupUtils.CreateAffiliation('Affiliation__c', 7))
        {
        	objAffiliation.Account__c = lstAccount[0].Id;
        	objAffiliation.Contact__c = lstContactHL[0].Id;
        	objAffiliation.End_Date__c = Date.today();
        	objAffiliation.Status__c = 'Current';
        	objAffiliation.End_Date__c = Date.today().addDays(5);
        	objAffiliation.Type__c = 'Parent';
        	lstAffiliation.add(objAffiliation);
        }
        insert lstAffiliation;
        System.assertEquals(lstAffiliation.size(), 14);
        
        List<Event> lstEvent = new List<Event>();
        for(Event objEvent : SL_TestSetupUtils.CreateEvent('Event', 5))
        {
            objEvent.StartDateTime = datetime.now();
            objEvent.EndDateTime = datetime.now().addHours(2);
            objEvent.ActivityDate = date.Today().addDays(-1);
            objEvent.OwnerId = Userinfo.getUserId();
            objEvent.WhoId = lstContactHL[0].Id;
            lstEvent.add(objEvent);
        }
        
        for(Event objEvent : SL_TestSetupUtils.CreateEvent('Event', 5))
        {
            objEvent.StartDateTime = datetime.now();
            objEvent.EndDateTime = datetime.now();
            objEvent.ActivityDate = date.Today().addDays(-1);
            objEvent.OwnerId = Userinfo.getUserId();
            objEvent.WhoId = lstContactHL[0].Id;
            lstEvent.add(objEvent);
        }

        for(Event objEvent : SL_TestSetupUtils.CreateEvent('Event', 5))
        {
            objEvent.StartDateTime = datetime.now();
            objEvent.EndDateTime = datetime.now();
            objEvent.ActivityDate = date.Today().addYears(-2);
            objEvent.OwnerId = Userinfo.getUserId();
            objEvent.WhoId = lstContactHL[0].Id;
            lstEvent.add(objEvent);
        }
        insert lstEvent;
		System.assertEquals(lstEvent.size(), 15);
		
        Integer i=0;        
        List<Task> lstTask = new List<Task>();
        for(Task objTask : SL_TestSetupUtils.CreateTask('Task', 5))
        {
            objTask.ActivityDate = date.Today();
            objTask.OwnerId = Userinfo.getUserId();
            objTask.WhoId = lstContactHL[0].Id;
            lstTask.add(objTask);
        }
        for(Task objTask : SL_TestSetupUtils.CreateTask('Task', 5))
        {
            objTask.ActivityDate = date.Today().addDays(-180);
            objTask.OwnerId = Userinfo.getUserId();
            objTask.WhatId = lstAccount[0].Id;
            lstTask.add(objTask);
        }
        insert lstTask;
        System.assertEquals(lstTask.size(), 10);
        
        List<Engagement__c> lstEngagement = new List<Engagement__c>();
        for(Engagement__c objEngagement : SL_TestSetupUtils.CreateEngagement('Engagement__c', 10))
        {
            objEngagement.Client__c = lstAccount[0].Id;
            objEngagement.Subject__c = lstAccount[0].Id;
            objEngagement.Status__c = 'Closed';
            objEngagement.Fixed_Fee__c = 1500.0;
            objEngagement.Close_Date__c = Date.today().addYears(5);
            objEngagement.Referral_Contact__c = lstContactHL[0].Id;
            lstEngagement.add(objEngagement);
        }
        insert lstEngagement;
        System.assertEquals(lstEngagement.size(), 10);
        
        i = 0;
        List<Engagement_External_Team__c> lstEET = new List<Engagement_External_Team__c>();
        for(Engagement_External_Team__c objEET : SL_TestSetupUtils.CreateEET('Engagement_External_Team__c', 10))
        {
            objEET.Contact__c = lstContactHL[0].Id;
            objEET.Engagement__c = lstEngagement[i].Id;
            objEET.Type__c ='Referral';
            lstEET.add(objEET);
            i++;
        }
        insert lstEET;
        System.assertEquals(lstEET.size(), 10);
        
        List<Engagement_Counterparty__c> lstEC = new  List<Engagement_Counterparty__c>();
        for(Engagement_Counterparty__c objEC : SL_TestSetupUtils.CreateEC('Engagement_Counterparty__c', 5))
        {
            objEC.Company__c = lstAccount[0].Id;
            objEC.Engagement__c = lstEngagement[0].Id;
            objEC.Coverage_Officer__c = lstContactHL[0].Id;
            lstEC.add(objEC);
        }
        insert lstEC;
        System.assertEquals(lstEC.size(), 5);
        
        i = 0;
        List<Engagement_Counterparty_Contact__c> lstECC = new List<Engagement_Counterparty_Contact__c>();
        for(Engagement_Counterparty_Contact__c objECC : SL_TestSetupUtils.CreateECC('Engagement_Counterparty_Contact__c', 5))
        {
        	objECC.Contact__c = lstContactHL[0].Id;
        	objECC.Counterparty__c = lstEC[i].Id;
        	lstECC.add(objECC);
        	i++;
        }
        insert lstECC;
        System.assertEquals(lstECC.size(), 5);
        
        i = 0;
        Date dtStartDate = Date.today().addDays(5);
        List<Campaign> lstCampaign = new List<Campaign>();
        for(Campaign objCampaign : SL_TestSetupUtils.CreateCampaign('Campaign', 5))
        {
        	objCampaign.Engagement__c = lstEngagement[i].Id;
        	objCampaign.StartDate = dtStartDate;
        	objCampaign.Type = 'Conference';
        	lstCampaign.add(objCampaign);
        	i++;
        	if(i > 2)
        		dtStartDate = Date.today().addDays(-5);
        }
        insert lstCampaign;
        System.assertEquals(lstCampaign.size(), 5);
        
        i = 0;
        List<CampaignMember> lstCampaignMember = new List<CampaignMember>();
        for(CampaignMember objCampaignMember : SL_TestSetupUtils.CreateCampaignMember('CampaignMember', 5))
        {
        	objCampaignMember.CampaignId = lstCampaign[i].Id;
        	objCampaignMember.ContactId = lstContactHL[0].Id;
        	lstCampaignMember.add(objCampaignMember);
        	i++;
        }
        insert lstCampaignMember;
        System.assertEquals(lstCampaignMember.size(), 5);
        
        List<Opportunity__c> lstOpportunity = new List<Opportunity__c>();
        for(Opportunity__c objOpportunity : SL_TestSetupUtils.CreateOpp('Opportunity__c', 10))
        {
            objOpportunity.Client__c = lstAccount[0].Id;
            objOpportunity.Estimated_Engagement_Date__c = Date.today();
            lstOpportunity.add(objOpportunity);
        }
        insert lstOpportunity;
        System.assertEquals(lstOpportunity.size(), 10);
        
        List<Opportunity_External_Team__c> lstOET = new List<Opportunity_External_Team__c>();
        for(Opportunity_External_Team__c objOET : SL_TestSetupUtils.CreateOET('Opportunity_External_Team__c', 10))
        {
            objOET.Opportunity__c = lstOpportunity[0].Id;
            objOET.Contact__c = lstContactHL[0].Id;
            lstOET.add(objOET);
        }
        insert lstOET;
        System.assertEquals(lstOET.size(), 10);
        
        List<Opportunity_Internal_Team__c> lstOIT = new List<Opportunity_Internal_Team__c>();
        for(Opportunity_Internal_Team__c objOIT : SL_TestSetupUtils.CreateOIT('Opportunity_Internal_Team__c', 10))
        {
        	objOIT.Role_Description__c = 'Principal';
            objOIT.Opportunity__c = lstOpportunity[0].Id;
            objOIT.Contact__c = lstContactHL[0].Id;
            lstOIT.add(objOIT);
        }
        insert lstOIT;
        System.assertEquals(lstOET.size(), 10);
        
        i = 0;
        List<Relationship__c> lstRelationship = new List<Relationship__c>();
        for(Relationship__c objRelationship : SL_TestSetupUtils.CreateRelationship('Relationship__c', 10))
        {
            lstRelationship.add(new Relationship__c(External_Contact__c = lstContactEX[0].Id, 
            										HL_Contact__c = lstContactHL[0].Id,
            										Strength_Rating__c = '2',
            										Number_of_Activities_LTM__c = 3, 
            										Last_Activity_Date__c = Date.today()));
			i++;            										
        }
        insert lstRelationship;
        
        System.currentPageReference().getParameters().put('Id',''+lstContactHL[0].Id);
        SL_RelationshipTearsheet_Report objRTP = new SL_RelationshipTearsheet_Report();
        objRTP.getReportData();
        objRTP.getMostActiveHLRelationship();
        objRTP.getMostRecentActitivites();
        objRTP.getEngagementHistory();
        objRTP.getOpenOpportunities();
        objRTP.getRefferalFeesHistory();
        objRTP.getDealsShown();
        objRTP.getConferenceAttendance();
        objRTP.getCareerInformation();
        objRTP.getBoardInformation();
    }
}