/**
* \arg ClassName      : SL_Test_ManageMassGroupMembers
* \arg JIRATicket     : AMSEC-12
* \arg CreatedOn      : 02/APRIL/2015
* \arg LastModifiedOn : 06/APRIL/2015
* \arg CreatededBy    : Lodhi
* \arg ModifiedBy     : Lodhi
* \arg Description    : Test class for SL_ManageMassGroupMembers class.
*/
@isTest
private class SL_Test_ManageMassGroupMembers 
{
    static Deal__c objDeal;
    static AS_Project__c objASP;
    static Account objAccount;
    static List<Contact> lstContact;
    static List<External_Working_Group_Member__c> lstEWGM;
    
    private static void createData() 
    {
	    Id profileId = [SELECT Id From Profile WHERE Name = 'Standard User' LIMIT 1].Id;
	    Id roleIdRGM = [SELECT Id From UserRole WHERE Name = 'Resource Group Member' LIMIT 1].Id;
	    Id roleIdITM = [SELECT Id From UserRole WHERE Name = 'Investment Team Member' LIMIT 1].Id;
	    Id recordTypeId = [SELECT Id From RecordType WHERE Name = 'AS Employee' LIMIT 1].Id;
	    
	    List<user> lstUser = new List<User>{
	                                        new User(Lastname = 'TestUser-01', Email = 'testuser1245@yahoo.in', ProfileId = profileId, IsActive = true,
	                                                 Alias = 'tuser', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', UserName = 'testUser0254@sl.com',
	                                                 EmailEncodingKey = 'ISO-8859-1', UserRoleId = roleIdRGM, LanguageLocaleKey='en_US'),
	                                        new User(Lastname = 'TestUser-02', Email = 'testuser54321@yahoo.in', ProfileId = profileId, IsActive = true, 
	                                                 Alias = 'tuser', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', UserName = 'testUser9723@sl.com',
	                                                 EmailEncodingKey = 'ISO-8859-1', UserRoleId = roleIdITM, LanguageLocaleKey='en_US'),
                                            new User(Lastname = 'TestUser-03', Email = 'testuser87923336@yahoo.in', ProfileId = profileId, IsActive = true, 
	                                                 Alias = 'tuser', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', UserName = 'testUser12314h@sl.com',
	                                                 EmailEncodingKey = 'ISO-8859-1', UserRoleId = roleIdITM, LanguageLocaleKey='en_US')	                                                 
	    };
	    system.runAs(new user(Id = UserInfo.getUserId()))
        {
    	    insert lstUser;
        }    	    
	    
	    objAccount = new Account(Name = 'TestAccount');
	    insert objAccount;
	    
	    lstContact = new List<Contact>{
	                                   new Contact(Lastname = 'TestCon-01', RecordTypeId = recordTypeId, AccountId = objAccount.Id, Salesforce_User__c = lstUser[0].Id),
	                                   new Contact(Lastname = 'TestCon-02', RecordTypeId = recordTypeId, AccountId = objAccount.Id, Salesforce_User__c = lstUser[0].Id),
	                                   new Contact(Lastname = 'TestCon-03', RecordTypeId = recordTypeId, AccountId = objAccount.Id, Salesforce_User__c = lstUser[1].Id),
	                                   new Contact(Lastname = 'TestCon-04', AccountId = objAccount.Id, Salesforce_User__c = lstUser[1].Id),
	                                   new Contact(Lastname = 'TestCon-05', RecordTypeId = recordTypeId, AccountId = objAccount.Id, Salesforce_User__c = lstUser[2].Id),
	                                   new Contact(Lastname = 'TestCon-06', RecordTypeId = recordTypeId, AccountId = objAccount.Id, Salesforce_User__c = lstUser[2].Id),
	                                   new Contact(Lastname = 'TestCon-07', RecordTypeId = recordTypeId, AccountId = objAccount.Id, Salesforce_User__c = lstUser[0].Id),
	                                   new Contact(Lastname = 'TestCon-07', RecordTypeId = recordTypeId, AccountId = objAccount.Id, Salesforce_User__c = lstUser[1].Id)
	    };
	    insert lstContact;
	    
        Industry_Group__c objIG = new Industry_Group__c(Name = 'TestIG');
        insert objIG;
        
        objDeal = new Deal__c(Name = 'TestDeal', Industry_Deal__c = objIG.Id, Process_Status__c = 'Open',
                              Deal_Status__c = 'Idea', CA_Status__c = 'Pending');
        insert objDeal; 
        
        objASP = new AS_Project__c(Name = 'TestASProject', Project_Type__c = 'Other', Project_Lead__c = 'DT', Portfolio_Company__c = objAccount.Id,
                                   Project_Health__c = 'On Track', End_Date__c = Date.today(), Start_Date__c = Date.today());
        insert objASP; 
        
        lstEWGM = new List<External_Working_Group_Member__c>{
															new External_Working_Group_Member__c(Deal__c = objDeal.Id, Contact__c = lstContact[0].Id),
                                                            new External_Working_Group_Member__c(AS_Project__c = objASP.Id, Contact__c = lstContact[2].Id),
                                                            new External_Working_Group_Member__c(Company__c = objAccount.Id, Contact__c = lstContact[4].Id)
        };
        insert lstEWGM;
        ShowTypeAheadCompany__c objTACompany = new ShowTypeAheadCompany__c(Name = 'Show Type Ahead', DisplayTypeAhead__c = true);
        insert objTACompany;
        ShowTypeAheadInvOpp__c objTAInvOpp = new ShowTypeAheadInvOpp__c(Name = 'Show Type Ahead', DisplayTypeAhead__c = true);
        insert objTAInvOpp;
        ShowTypeAheadASProject__c objTAProject = new ShowTypeAheadASProject__c(Name = 'Show Type Ahead', DisplayTypeAhead__c = true);
        insert objTAProject;
    }
    
    private static testMethod void Test_InsertDeal()
    {
        createData();
        system.assertEquals([SELECT Id FROM External_Working_Group_Member__c WHERE Deal__c =: objDeal.Id].size(), 1);
        Apexpages.currentPage().getParameters().put('parentId', ''+objDeal.Id);
        SL_ManageMassGroupMembers objMGM = new SL_ManageMassGroupMembers();
        objMGM.updateRecords();
        objMGM.cancel();
        if(!objMGM.lstGroupMemberWrapper.isEmpty())
        {
            objMGM.lstGroupMemberWrapper[0].contact = lstContact[0];
            objMGM.lstGroupMemberWrapper[0].EWGMember = new External_Working_Group_Member__c(Contact__c = lstContact[1].Id, Deal__c = objDeal.Id);
            objMGM.lstGroupMemberWrapper[0].isSelected = true;
        }
        objMGM.strContactId = lstContact[3].Id;
        objMGM.addGroupMember();
        objMGM.strContactId = lstContact[3].Id;
        objMGM.addGroupMember();
        objMGM.save();
        //system.assertEquals([SELECT Id FROM External_Working_Group_Member__c WHERE Deal__c =: objDeal.Id].size(), 2);
	}
	
	private static testMethod void Test_AddMemberFromProject()
    {
        createData();
        system.assertEquals([SELECT Id FROM External_Working_Group_Member__c WHERE AS_Project__c =: objASP.Id].size(), 1);
        Apexpages.currentPage().getParameters().put('parentId', ''+objASP.Id);
        SL_ManageMassGroupMembers objMGM = new SL_ManageMassGroupMembers();
        objMGM.updateRecords();
        objMGM.cancel();
        if(!objMGM.lstGroupMemberWrapper.isEmpty())
        {
        objMGM.lstGroupMemberWrapper[0].contact = lstContact[0];
        objMGM.lstGroupMemberWrapper[0].EWGMember = new External_Working_Group_Member__c(Contact__c = lstContact[1].Id, AS_Project__c = objASP.Id);
        objMGM.lstGroupMemberWrapper[0].isSelected = true;
        }
        objMGM.save();
        //system.assertEquals([SELECT Id FROM External_Working_Group_Member__c WHERE AS_Project__c =: objASP.Id].size(), 2);
	}
	
	private static testMethod void Test_AddMemberFromCompany()
    {
        createData();
        system.assertEquals([SELECT Id FROM External_Working_Group_Member__c WHERE Company__c =: objAccount.Id].size(), 1);
        Apexpages.currentPage().getParameters().put('parentId', ''+objAccount.Id);
        SL_ManageMassGroupMembers objMGM = new SL_ManageMassGroupMembers();
        objMGM.updateRecords();
        objMGM.cancel();
        if(!objMGM.lstGroupMemberWrapper.isEmpty())
        {
        objMGM.lstGroupMemberWrapper[0].contact = lstContact[0];
        objMGM.lstGroupMemberWrapper[0].EWGMember = new External_Working_Group_Member__c(Contact__c = lstContact[1].Id, Company__c = objAccount.Id);
        objMGM.lstGroupMemberWrapper[0].isSelected = true;
        }
        objMGM.save();
        //system.assertEquals([SELECT Id FROM External_Working_Group_Member__c WHERE Company__c =: objAccount.Id].size(), 2);
	}
	
	private static testMethod void Test_UpdateCase()
	{
	    createData();
	    Apexpages.currentPage().getParameters().put('parentId', ''+objDeal.Id);
	    Apexpages.currentPage().getParameters().put('isEditAll', '');
        SL_ManageMassGroupMembers objMGM = new SL_ManageMassGroupMembers();
        objMGM.lstEWGMember = [SELECT Contact__c FROM External_Working_Group_Member__c WHERE Deal__c =: objDeal.Id];
        system.assertEquals([SELECT Contact__c FROM External_Working_Group_Member__c WHERE Deal__c =: objDeal.Id].Contact__c, lstContact[0].Id);
        objMGM.lstEWGMember[0].Contact__c = lstContact[1].Id;
        objMGM.updateRecords();
        system.assertEquals([SELECT Contact__c FROM External_Working_Group_Member__c WHERE Deal__c =: objDeal.Id].Contact__c, lstContact[1].Id);
	}
	
	private static testMethod void Test_NullParent()
	{
	    createData();
	    SL_ManageMassGroupMembers objMGM = new SL_ManageMassGroupMembers();
	}
}