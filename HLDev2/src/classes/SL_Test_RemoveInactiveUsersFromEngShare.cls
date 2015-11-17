/**  
* \arg ClassName		: SL_Test_RemoveInactiveUsersFromEngShare
* \arg JIRATicket		: HL-32
* \arg CreatedOn		: 08/Oct/2014
* \arg LastModifiedOn	: 08/Oct/2014
* \arg CreatededBy		: Lodhi
* \arg ModifiedBy		: -
* \arg Description		: Test class for SL_Batch_RemoveInactiveUsersFromEngShare class.
*/
@isTest
private class SL_Test_RemoveInactiveUsersFromEngShare 
{
	static List<User> lstUser;
	static List<Engagement__c> lstEngagement;
	static List<Engagement_Internal_Team__c> lstEIT;
	static List<Delegate_Public_Group__c> lstDPG; 
	
    private static void createData() 
    {
        Id HLRecordtypeId = [SELECT Id FROM RecordType WHERE RecordType.DeveloperName = 'Houlihan_Employee'].Id;
    	
    	Profile objProfile = [SELECT Id,
    								 Name 
    							FROM Profile
    						   WHERE Name = 'Solution Manager'];	
    	
    	Integer i = 0;
    	Integer j = 0;
    	lstUser = new List<User>();
    	For(User objUser : SL_TestSetupUtils.CreateUser('User',3))
    	{
    		objUser.Lastname = 'User';
    		objUser.Email = 'tuser@yahoo.in';
    		objUser.Username =  i+'test543552542@hl2.com';
    		objUser.ProfileId = objProfile.Id;
    		objUser.Alias = 'tuser';
    		objUser.TimeZoneSidKey = 'GMT';
    		objUser.LocaleSidKey = 'en_US';
    		objUser.EmailEncodingKey = 'ISO-8859-1';
    		objUser.LanguageLocaleKey = 'en_US';
    		objUser.Has_Delegates__c = false;
    		objUser.IsActive = true;
    		lstUser.add(objUser);
    		i++;
    	}
    	insert lstUser;
    	
    	List<Account> lstAccount = SL_TestSetupUtils.CreateAccount('Account' , 1);
		insert lstAccount;
    	System.assertEquals(lstAccount.size(), 1);
    	
    	i = 0;
    	List<Contact> lstContactHL = new List<Contact>();
        for(Contact objContact : SL_TestSetupUtils.CreateContact('Contact', 3))
        {
            objContact.AccountId = lstAccount[0].Id;
            objContact.User__c = lstUser[i].Id;
            objContact.RecordTypeId = HLRecordtypeId;
            lstContactHL.add(objContact);
            i++;
        }
        insert lstContactHL;
    	System.assertEquals(lstContactHL.size(), 3);
    	
    	lstDPG = new List<Delegate_Public_Group__c>();
        For(Delegate_Public_Group__c objDPG : SL_TestSetupUtils.createDPG('Delegate_Public_Group__c', 1))
        {
        	objDPG.Banker__c = lstUser[0].Id;
        	lstDPG.add(objDPG);
        }
        insert lstDPG;
    	System.assertEquals(lstDPG.size(), 1);
    	
        lstEngagement = new List<Engagement__c>();
        For(Engagement__c objEngagement : SL_TestSetupUtils.CreateEngagement('Engagement__c', 2))
        {
        	objEngagement.Client__c = lstAccount[0].Id;
        	objEngagement.Subject__c = lstAccount[0].Id;
        	lstEngagement.add(objEngagement);
        }
        insert lstEngagement;
        System.assertEquals(lstEngagement.size(), 2);
        
        i = 0;
        List<Engagement_Counterparty__c> lstEC = new  List<Engagement_Counterparty__c>();
        for(Engagement_Counterparty__c objEC : SL_TestSetupUtils.CreateEC('Engagement_Counterparty__c', 4))
        {
            if(i>1)
                j = 1;
            objEC.Company__c = lstAccount[0].Id;
            objEC.Engagement__c = lstEngagement[j].Id;
            lstEC.add(objEC);
            i++;
        }
        insert lstEC;
        System.assertEquals(lstEC.size(), 4);
        
        List<Revenue_Accrual__c> lstRA = new List<Revenue_Accrual__c>{new Revenue_Accrual__c(Engagement__c = lstEngagement[0].Id, Month__c = 'Jan', Year__c = '2014'),
                                                                      new Revenue_Accrual__c(Engagement__c = lstEngagement[1].Id, Month__c = 'Feb', Year__c = '2015')};
        insert lstRA;
        System.assertEquals(lstRA.size(), 2);
        
        i = 0; j = 0;
        lstEIT = new List<Engagement_Internal_Team__c>();
        for(Engagement_Internal_Team__c objEIT : SL_TestSetupUtils.CreateEIT('Engagement_Internal_Team__c', 6))
        {
        	if(i > 2)
        	{
        		i = 0;
        		j = 1;
        	}
            objEIT.Contact__c = lstContactHL[i].Id;
            objEIT.Engagement__c = lstEngagement[j].Id;
            objEIT.End_Date__c = Date.today();
            objEIT.Staff_Start_Date__c = Date.today();
            lstEIT.add(objEIT);
            i++;
        }
        insert lstEIT;
    }
    
    private static testMethod void Test_RemoveInactiveUsersFromEngShare()
    {
    	createData();
    	System.assertEquals([SELECT Id FROM Engagement__Share WHERE RowCause='Manual' AND AccessLevel ='Edit'].size(), 6);	
    	lstUser[0].IsActive = false;
        system.runAs(new user(Id = UserInfo.getUserId()))
        {    
            test.startTest();
            update lstUser[0];
        	SL_Batch_RemoveInactiveUsersFromEngShare objBatchRIU = new SL_Batch_RemoveInactiveUsersFromEngShare();
    	    Database.executeBatch(objBatchRIU, 50); 
    	    test.stopTest();
        }
	    System.assertEquals([SELECT Id FROM Engagement__Share WHERE RowCause='Manual' AND AccessLevel ='Edit'].size(), 4);	
    }
    
    private static testMethod void Test_UpdateCase()
    {
        createData();
        test.startTest();
        lstEIT[0].End_Date__c = Date.today().addDays(-2);
        update lstEIT[0];
        System.assertEquals([SELECT Id FROM Engagement__Share WHERE RowCause='Manual' AND AccessLevel ='Edit'].size(), 5);	
        System.assertEquals([SELECT Id FROM Engagement_Counterparty__Share WHERE RowCause='Manual' AND AccessLevel ='Edit'].size(), 10);
        System.assertEquals([SELECT Id FROM Revenue_Accrual__Share WHERE RowCause='Manual' AND AccessLevel ='Edit'].size(), 5);
    }   
    
    private static testMethod void Test_DNDCase()
    {
        createData();  
        delete[SELECT Id FROM Engagement__Share WHERE RowCause='Manual' AND AccessLevel ='Edit'];
        System.assertEquals([SELECT Id FROM Engagement__Share WHERE RowCause='Manual' AND AccessLevel ='Edit'].size(), 0);	
        system.runAs(new user(Id = UserInfo.getUserId()))
        {    
            test.startTest();
        	SL_Batch_RemoveInactiveUsersFromEngShare objBatchRIU = new SL_Batch_RemoveInactiveUsersFromEngShare();
    	    Database.executeBatch(objBatchRIU, 50); 
    	    test.stopTest();
        }
        System.assertEquals([SELECT Id FROM Engagement__Share WHERE RowCause='Manual' AND AccessLevel ='Edit'].size(), 6);	
        System.assertEquals([SELECT Id FROM Engagement_Counterparty__Share WHERE RowCause='Manual' AND AccessLevel ='Edit'].size(), 16);
        System.assertEquals([SELECT Id FROM Revenue_Accrual__Share WHERE RowCause='Manual' AND AccessLevel ='Edit'].size(), 8);
    } 
    
    private static testMethod void Test_OnChangeParentName()
    {
        createData();
        test.startTest();
        lstEngagement[1].Name = 'DNDTestEngagement';
        update lstEngagement[1];
        test.stopTest();
        System.assertEquals([SELECT Id FROM Engagement__Share WHERE RowCause='Manual' AND AccessLevel ='Edit'].size(), 6);	
        System.assertEquals([SELECT Id FROM Engagement_Counterparty__Share WHERE RowCause='Manual' AND AccessLevel ='Edit'].size(), 12);
        System.assertEquals([SELECT Id FROM Revenue_Accrual__Share WHERE RowCause='Manual' AND AccessLevel ='Edit'].size(), 6);
    }    
    
    private static testMethod void Test_createDeleteShareOnUpdate()
    {
        createData();   
        test.startTest();
        lstEIT[0].Staff_Start_Date__c = Date.today().addDays(2);
        update lstEIT[0];
        lstEIT[0].Staff_Start_Date__c = Date.today();
        update lstEIT[0];
        lstEIT[1].End_Date__c = Date.today().addDays(-2);
        update lstEIT[1];
        lstEIT[1].End_Date__c = Date.today();
        update lstEIT[1];
        lstEIT[2].Staff_Start_Date__c = Date.today().addDays(2);
        lstEIT[2].End_Date__c = Date.today().addDays(-2);
        update lstEIT[2];
        lstEIT[2].Staff_Start_Date__c = Date.today();
        lstEIT[2].End_Date__c = Date.today();
        update lstEIT[2];
        test.stopTest();
        System.assertEquals([SELECT Id FROM Engagement__Share WHERE RowCause='Manual' AND AccessLevel ='Edit'].size(), 6);	
        System.assertEquals([SELECT Id FROM Engagement_Counterparty__Share WHERE RowCause='Manual' AND AccessLevel ='Edit'].size(), 12);
        System.assertEquals([SELECT Id FROM Revenue_Accrual__Share WHERE RowCause='Manual' AND AccessLevel ='Edit'].size(), 6);
    }    
}