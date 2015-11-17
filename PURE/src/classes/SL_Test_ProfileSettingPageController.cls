@isTest
private class SL_Test_ProfileSettingPageController 
{

    static testMethod void profileSettingPageTest() 
    {
		Profile objCommunityUserProfile = [SELECT Id FROM Profile WHERE Name='Pure Customer Community Login User'];
        
        RecordType objRecordtype = [Select Id from RecordType where SobjectType =:'Account' AND Name='Member' limit 1];
        
        List<Account> lstAccount = new List<Account>{new Account(Name = 'Test Account', RecordTypeId = objRecordtype.Id, Billing_Document_Delivery_Method__c = 'Electronic', OwnerId = [Select Id from User where UserRoleId != null limit 1].Id),
        											 new Account(Name = 'Test Account 1', RecordTypeId = objRecordtype.Id, Billing_Document_Delivery_Method__c = 'Paper', OwnerId = [Select Id from User where UserRoleId != null limit 1].Id)
        											};
        insert lstAccount;
        
        List<Contact> lstContact = new List<Contact>{new Contact(LastName = 'Test Contact', AccountId = lstAccount[0].Id),
        											 new Contact(LastName = 'Test Contact 1', AccountId = lstAccount[1].Id)
        											};
        insert lstContact;
        
        User objHpdProviderUser = new User(Alias = 'HPD4', Email='standarduser4@testorg.com', 
                                             EmailEncodingKey='UTF-8', LastName='Testing4', LanguageLocaleKey='en_US', 
                                             LocaleSidKey='en_US', ProfileId = objCommunityUserProfile.Id, 
                                             TimeZoneSidKey='America/Los_Angeles', UserName='standarduser4@testorg.com' , ContactID = lstContact[0].Id);              
                             
        insert objHpdProviderUser;
        
        List<Contact_Info__c> lstContactInfo = new List<Contact_Info__c>{new Contact_Info__c(Phone__c = '304042',Email__c = 'test@silverlinecrm.com',Type__c = 'Email', Account__c = lstAccount[0].Id, Is_Primary__c = true, Street__c = 'Broadway', City__c = 'New York City', State__c = 'NY', Zip__c = '03933', Street_2__c = '20th',Receive_Company_Updates__c = true, Receive_PURE_Press__c= true,Receive_PURE_Situation_Room__c= true,Receive_PURE_Prevention__c= true,Receive_Annual_Report__c= true,Receive_SSA_Statements__c= true,Receive_PURE_Events__c= true,Is_Updated__c =true),
        																  new Contact_Info__c(Phone__c = '304041',Email__c = 'test@silverlinecrm.com',Type__c = 'Phone', Account__c = lstAccount[0].Id, Is_Primary__c = true, Street__c = 'Broadway', City__c = 'New York City', State__c = 'NY', Zip__c = '03933', Street_2__c = '20th',Receive_Company_Updates__c = true, Receive_PURE_Press__c= true,Receive_PURE_Situation_Room__c= true,Receive_PURE_Prevention__c= true,Receive_Annual_Report__c= true,Receive_SSA_Statements__c= true,Receive_PURE_Events__c= true,Is_Updated__c = true),
        																  new Contact_Info__c(Phone__c = '304041',Email__c = 'test@silverlinecrm.com',Type__c = 'Billing', Account__c = lstAccount[0].Id, Is_Primary__c = true, Street__c = 'Broadway', City__c = 'New York City', State__c = 'NY', Zip__c = '03933', Street_2__c = '20th',Receive_Company_Updates__c = true, Receive_PURE_Press__c= true,Receive_PURE_Situation_Room__c= true,Receive_PURE_Prevention__c= true,Receive_Annual_Report__c= true,Receive_SSA_Statements__c= true,Receive_PURE_Events__c= true),
        																  new Contact_Info__c(Phone__c = '304041',Email__c = 'test@silverlinecrm.com',Type__c = 'Mailing', Account__c = lstAccount[0].Id, Is_Primary__c = true, Street__c = 'Broadway', City__c = 'New York City', State__c = 'NY', Zip__c = '03933', Street_2__c = '20th',Receive_Company_Updates__c = true, Receive_PURE_Press__c= true,Receive_PURE_Situation_Room__c= true,Receive_PURE_Prevention__c= true,Receive_Annual_Report__c= true,Receive_SSA_Statements__c= true,Receive_PURE_Events__c= true),
        																  new Contact_Info__c(Phone__c = '3040400',Email__c = 'test@silverlinecrm.com',Type__c = 'Mailing', Account__c = lstAccount[0].Id, Is_Primary__c = false, Street__c = 'Broadway', City__c = 'New York City', State__c = 'NY', Zip__c = '03933', Street_2__c = '20th',Receive_Company_Updates__c = true, Receive_PURE_Press__c= true,Receive_PURE_Situation_Room__c= true,Receive_PURE_Prevention__c= true,Receive_Annual_Report__c= true,Receive_SSA_Statements__c= true,Receive_PURE_Events__c= true,Is_Updated__c =true),
        																  new Contact_Info__c(Phone__c = '304041',Email__c = 'test@silverlinecrm.com',Type__c = 'Phone-Home', Account__c = lstAccount[0].Id, Is_Primary__c = true, Street__c = 'Broadway', City__c = 'New York City', State__c = 'NY', Zip__c = '03933', Street_2__c = '20th',Receive_Company_Updates__c = true, Receive_PURE_Press__c= true,Receive_PURE_Situation_Room__c= true,Receive_PURE_Prevention__c= true,Receive_Annual_Report__c= true,Receive_SSA_Statements__c= true,Receive_PURE_Events__c= true,Is_Updated__c =true),
        																  new Contact_Info__c(Phone__c = '304041',Email__c = 'test@silverlinecrm.com',Type__c = 'Billing', Account__c = lstAccount[0].Id, Is_Primary__c = true, Street__c = 'Broadway1', City__c = 'Los Angeles', State__c = 'CA', Zip__c = '039334', Street_2__c = '21th',Receive_Company_Updates__c= false, Receive_PURE_Press__c= false,Receive_PURE_Situation_Room__c= false,Receive_PURE_Prevention__c= false,Receive_Annual_Report__c= false,Receive_SSA_Statements__c= false,Receive_PURE_Events__c= false,Is_Updated__c =true)
        																};
        
        insert lstContactInfo;
         
        System.runAs(objHpdProviderUser)
        {
         	SL_ProfileSettingPageController objSL_ProfileSettingPageController = new SL_ProfileSettingPageController();
         	objSL_ProfileSettingPageController.pageAction();
         	objSL_ProfileSettingPageController.objAccount = lstAccount[0];
         	objSL_ProfileSettingPageController.strAddresType = 'Mailing';
         	objSL_ProfileSettingPageController.strNewStreet = 'Broadway';
         	objSL_ProfileSettingPageController.strNewStreet1 = '20th';
         	objSL_ProfileSettingPageController.strNewCity = 'New York City';
         	objSL_ProfileSettingPageController.strNewState = 'NY';
         	objSL_ProfileSettingPageController.strNewZipCode = '03933';
         	objSL_ProfileSettingPageController.contInfoId = '';
         	objSL_ProfileSettingPageController.strNewlyCreatedContactInfoId = lstContactInfo[0].Id;
         	objSL_ProfileSettingPageController.newAddresAdd();
         	
         	objSL_ProfileSettingPageController.contInfoId = lstContactInfo[0].Id;
         	objSL_ProfileSettingPageController.newAddresAdd();
         	
         	objSL_ProfileSettingPageController.strAddresType = 'Mailing';
         	objSL_ProfileSettingPageController.contInfoId = lstContactInfo[6].Id;
         	objSL_ProfileSettingPageController.newAddresAdd();
         	
         	
         	objSL_ProfileSettingPageController.strAddresType = 'Billing';
         	objSL_ProfileSettingPageController.strNewlyCreatedContactInfoId = lstContactInfo[0].Id;
         	objSL_ProfileSettingPageController.contInfoId = '';
         	objSL_ProfileSettingPageController.newAddresAdd();
         	
         	objSL_ProfileSettingPageController.strAddresType = 'Billing';
         	objSL_ProfileSettingPageController.contInfoId = lstContactInfo[0].Id;
         	objSL_ProfileSettingPageController.newAddresAdd();
         	
         	objSL_ProfileSettingPageController.strAddresType = 'Billing';
         	objSL_ProfileSettingPageController.contInfoId = lstContactInfo[6].Id;
         	objSL_ProfileSettingPageController.newAddresAdd();
         	
         	objSL_ProfileSettingPageController.strAddresType = 'Email';
         	objSL_ProfileSettingPageController.contInfoId = '';
         	objSL_ProfileSettingPageController.strNewlyCreatedContactInfoId = lstContactInfo[0].Id;
         	objSL_ProfileSettingPageController.newAddresAdd();
         	
         	objSL_ProfileSettingPageController.strAddresType = 'Email';
         	objSL_ProfileSettingPageController.strNewEmail = 'aa@gmail.com';
         	objSL_ProfileSettingPageController.contInfoId = lstContactInfo[0].Id;
         	objSL_ProfileSettingPageController.newAddresAdd();
         	
         	objSL_ProfileSettingPageController.strAddresType = 'Email';
         	objSL_ProfileSettingPageController.strNewEmail = 'aa@gmail.com';
         	objSL_ProfileSettingPageController.contInfoId = lstContactInfo[1].Id;
         	objSL_ProfileSettingPageController.newAddresAdd();
         	
         	objSL_ProfileSettingPageController.strAddresType = 'Home';
         	objSL_ProfileSettingPageController.contInfoId = '';
         	objSL_ProfileSettingPageController.strNewlyCreatedContactInfoId = lstContactInfo[0].Id;         	
         	objSL_ProfileSettingPageController.newAddresAdd();
         	
         	objSL_ProfileSettingPageController.strAddresType = 'Home';
         	objSL_ProfileSettingPageController.strNewEmail = 'aa@gmail.com';
         	objSL_ProfileSettingPageController.contInfoId = lstContactInfo[0].Id;       	
         	objSL_ProfileSettingPageController.newAddresAdd();
         	
         	objSL_ProfileSettingPageController.strAddresType = 'Home';
         	objSL_ProfileSettingPageController.strNewEmail = 'aa@gmail.com';
         	objSL_ProfileSettingPageController.strNewPhone = '30404';
         	objSL_ProfileSettingPageController.contInfoId = lstContactInfo[1].Id;       	
         	objSL_ProfileSettingPageController.newAddresAdd();
         	
         	objSL_ProfileSettingPageController.strAddresType = 'Work';
         	objSL_ProfileSettingPageController.contInfoId = '';
         	objSL_ProfileSettingPageController.strNewlyCreatedContactInfoId = lstContactInfo[0].Id;
         	objSL_ProfileSettingPageController.newAddresAdd();
         	
         	objSL_ProfileSettingPageController.strAddresType = 'Work';
         	objSL_ProfileSettingPageController.strNewEmail = 'aa@gmail.com';
         	objSL_ProfileSettingPageController.contInfoId = lstContactInfo[0].Id;       	
         	objSL_ProfileSettingPageController.newAddresAdd();
         	
         	objSL_ProfileSettingPageController.strAddresType = 'Work';
         	objSL_ProfileSettingPageController.strNewEmail = 'aa@gmail.com';
         	objSL_ProfileSettingPageController.contInfoId = lstContactInfo[1].Id;       	
         	objSL_ProfileSettingPageController.newAddresAdd();
         	
         	objSL_ProfileSettingPageController.strAddresType = 'Mobile';
         	objSL_ProfileSettingPageController.contInfoId = '';
         	objSL_ProfileSettingPageController.strNewlyCreatedContactInfoId = lstContactInfo[0].Id;
         	objSL_ProfileSettingPageController.newAddresAdd();
         	
         	objSL_ProfileSettingPageController.strAddresType = 'Mobile';
         	objSL_ProfileSettingPageController.strNewEmail = 'aa@gmail.com';
         	objSL_ProfileSettingPageController.contInfoId = lstContactInfo[0].Id;       	
         	objSL_ProfileSettingPageController.newAddresAdd();
         	
         	objSL_ProfileSettingPageController.strAddresType = 'Mobile';
         	objSL_ProfileSettingPageController.strNewEmail = 'aa@gmail.com';
         	objSL_ProfileSettingPageController.contInfoId = lstContactInfo[1].Id;       	
         	objSL_ProfileSettingPageController.newAddresAdd();
         	
         	
         	objSL_ProfileSettingPageController.strOrgnalPrimaryMailing = lstContactInfo[3].Id;
         	objSL_ProfileSettingPageController.strPrimaryMailingAddId = lstContactInfo[4].Id;
         	
         	objSL_ProfileSettingPageController.profileSaveChanges();
         	
         	objSL_ProfileSettingPageController.strPrimaryMailingAddId = lstContactInfo[0].Id;
         	objSL_ProfileSettingPageController.updatedContactInfoWithIsPrimary(); 
         	
         	objSL_ProfileSettingPageController.strPrimaryMailingAddId = lstContactInfo[3].Id;
         	objSL_ProfileSettingPageController.updatedContactInfoWithIsPrimary();
         	
         	objSL_ProfileSettingPageController.strPrimaryBillingAddId = lstContactInfo[0].Id;
         	objSL_ProfileSettingPageController.updatedContactInfoWithIsPrimary();
         	
         	objSL_ProfileSettingPageController.strPrimaryBillingAddId = lstContactInfo[3].Id;
         	objSL_ProfileSettingPageController.updatedContactInfoWithIsPrimary();
         	
         	objSL_ProfileSettingPageController.strPrimaryMailAddId = lstContactInfo[0].Id;
         	objSL_ProfileSettingPageController.updatedContactInfoWithIsPrimary();
         	
         	objSL_ProfileSettingPageController.strPrimaryMailAddId = lstContactInfo[3].Id;
         	objSL_ProfileSettingPageController.updatedContactInfoWithIsPrimary();    
         	
         	objSL_ProfileSettingPageController.strPrimaryPhoneAddId = lstContactInfo[0].Id;
         	objSL_ProfileSettingPageController.updatedContactInfoWithIsPrimary(); 
         	
         	objSL_ProfileSettingPageController.strPrimaryPhoneAddId = lstContactInfo[3].Id;
         	objSL_ProfileSettingPageController.updatedContactInfoWithIsPrimary();       	
         	
         	///objSL_ProfileSettingPageController.updateSelectedPrimary();
         	
         	objSL_ProfileSettingPageController.strSelectedDelvryPref = 'Standard Email';
         	
         	
         	objSL_ProfileSettingPageController.delivaryPreferencesSaveChanges();
         	
         	objSL_ProfileSettingPageController.strSelectedDelvryPref = 'Standard Email';
         	objSL_ProfileSettingPageController.strAcctDeliverPreference = null;
         	objSL_ProfileSettingPageController.delivaryPreferencesSaveChanges();
         	objSL_ProfileSettingPageController.strAcctDeliverPreference = 'Standard Email';
         	objSL_ProfileSettingPageController.delivaryPreferencesSaveChanges();
         	
         	objSL_ProfileSettingPageController.strSelectedCommPreferences =  lstContactInfo[0].Id + '_SubscriberEmail,' + lstContactInfo[1].Id + '_PurePrevention,' + lstContactInfo[2].Id + '_PureSituation';
         	objSL_ProfileSettingPageController.strUnSelectedCommPreferences = lstContactInfo[3].Id +  '_SubscriberEmail,' + lstContactInfo[4].Id + '_SubscriberStndMail,' + lstContactInfo[5].Id + '_SubscriberStndMail,' + lstContactInfo[2].Id + '_PurePrevention,' + lstContactInfo[3].Id + '_PureSituation';
         	objSL_ProfileSettingPageController.commPreferencesSaveChanges();

            //objSL_ProfileSettingPageController.strDeletedEmailAddress = 'aa@gmail.com';
            //objSL_ProfileSettingPageController.strDeletedMailingAddress = '20 Broadway New York City, NY 03933';
            //objSL_ProfileSettingPageController.strDeletedBillingAddress = '123 test billing';
            //objSL_ProfileSettingPageController.strDeletedPhoneAddress = '30404';

            objSL_ProfileSettingPageController.deleteEmailAddress();
            objSL_ProfileSettingPageController.deleteMailingAddress();
            objSL_ProfileSettingPageController.deleteBillingAddress();
            objSL_ProfileSettingPageController.deletePhoneAddress();
            objSL_ProfileSettingPageController.dummy();
        }
    }
}