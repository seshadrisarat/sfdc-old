/*
*Class: SL_ContactViewPageController_Test
*Description: This test class is used to check the functionality of SL_ContactViewPageController class.
*Copyright 2013 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
@isTest
private with sharing class SL_ContactViewPageController_Test{

    public static testmethod void testMyController()
    {
          Test.startTest();
        
          List<Portal__c> lstPortalBranding = new List<Portal__c>{new Portal__c(Name = 'Test Portal', Portal_Id__c='000000000'),
																new Portal__c(Name = 'DEFAULT_PORTAL_UI', Portal_Id__c='10000000')};
		  insert lstPortalBranding;
		
		
		
          
          
          list<Account> lstAccount = new list<Account>{ new Account( Name = 'TestAccount') ,new Account( Name = 'TestAccount1')};
          insert lstAccount;
          
          list<Contact> lstcontact = new list<Contact>{new contact(LastName ='Test Contact' ,AccountId = lstAccount.get(0).Id),new Contact(LastName ='Test Contact1' ,AccountId = lstAccount.get(1).Id)};
          insert lstcontact;
          
          
          
        
          Profile objMihinHpdProiderUserProfile = [SELECT Id FROM Profile WHERE Name='MIHN - HPD Provider User']; 
          
          Profile objMihinHpdOrgAdminProfile = [SELECT Id FROM Profile WHERE Name='MIHN - HPD Organization Administrator']; 
          
          Profile objSystemAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
          
          User objHpdProviderUser = new User(Alias = 'HPD', Email='standarduser@testorg.com', 
                                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                             LocaleSidKey='en_US', ProfileId = objMihinHpdProiderUserProfile.Id, 
                                             TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com' , ContactID = lstcontact.get(0).Id);              
                             
          insert objHpdProviderUser; 
          
          User objMihinHpdOrgAdminProfileUser = new User(Alias = 'Admin', Email='standarduser1@testorg.com', 
                                                         EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                                         LocaleSidKey='en_US', ProfileId = objMihinHpdOrgAdminProfile.Id, 
                                                         TimeZoneSidKey='America/Los_Angeles', UserName='standarduser1@testorg.com' , ContactID =  lstcontact.get(1).Id);
                             
                             
           insert objMihinHpdOrgAdminProfileUser;
           
            User objSystemAdmin = new User(Alias = 'Testabcd', Email='sysadmin@silverlinecrm.com', 
                                                         EmailEncodingKey='UTF-8', LastName='SysTesting', LanguageLocaleKey='en_US', 
                                                         LocaleSidKey='en_US', ProfileId = objSystemAdminProfile.Id, 
                                                         TimeZoneSidKey='America/Los_Angeles', UserName='sysadminusername@silverlinecrm.com');
                             
                             
           insert objSystemAdmin;             
          
           list<Specialty__c> lstSpeciality = new list<Specialty__c>{ new Specialty__c(Name = 'Test Speciality'), new Specialty__c(Name = 'Test Speciality1')};
           insert lstSpeciality;
           
           // creating Affiliation records for contacts
           list<Affiliation__c> lstAffiliation = new list<Affiliation__c>{new Affiliation__c( Organization__c = lstAccount.get(0).Id , Provider__c = lstcontact.get(0).Id , Type__c = 'Employed By'),
                                                                          new Affiliation__c( Organization__c = lstAccount.get(1).Id , Provider__c = lstcontact.get(0).Id , Type__c = 'Employed By'),
                                                                          new Affiliation__c( Organization__c = lstAccount.get(1).Id , Provider__c = lstcontact.get(1).Id , Type__c = 'Employed By')};
           insert lstAffiliation;
           
           Provider_Specialty__c objProviderSpeciality = new Provider_Specialty__c ( Provider__c = lstcontact.get(0).Id , Specialty__c =lstSpeciality.get(0).Id );
           insert objProviderSpeciality;
           
           Provider_Specialty__c objProviderSpeciality1 = new Provider_Specialty__c ( Provider__c = lstcontact.get(0).Id , Specialty__c =lstSpeciality.get(1).Id ,Primary_Indicator__c = true);
           insert objProviderSpeciality1;
           
           
           Provider_Credential__c objProviderCredential = new Provider_Credential__c( Name = 'Test Credential-01' , Provider__c = lstcontact.get(0).Id);
           insert objProviderCredential;  
           
           Provider_Credential__c objProviderCredential1 = new Provider_Credential__c( Name = 'Test Credential-02' , Provider__c = lstcontact.get(1).Id);
           insert objProviderCredential1;  
           
           Care_Team__c objCareTeam = new Care_Team__c(Name='Test Care Team', Organization__c=lstAccount.get(0).Id);
           insert objCareTeam;
           
           Care_Team__c objCareTeam1 = new Care_Team__c(Name='Test Care Team1', Organization__c=lstAccount.get(1).Id);
           insert objCareTeam1;           
           
           Provider_Care_Team__c objProviderCareTeam = new Provider_Care_Team__c(Care_Team__c = objCareTeam.Id,Provider__c = lstcontact.get(1).Id);
           insert objProviderCareTeam;
           
           Provider_Address__c objProviderAddress = new Provider_Address__c(Provider__c = lstcontact.get(0).Id, Type__c = 'Other', City__c = 'Test City');
           insert objProviderAddress;
           
           list<SL_ProviderCredRecordTypeToFieldset__c> lstCustomSettingRecToInsert = new list<SL_ProviderCredRecordTypeToFieldset__c>();
           
           SL_ProviderCredRecordTypeToFieldset__c objCustomSetting = new SL_ProviderCredRecordTypeToFieldset__c(Name = 'Provider_Certificate',Fieldset_Name__c = 'ProviderCredentialCertificateType',Label__c ='Certificate');
           lstCustomSettingRecToInsert.add(objCustomSetting);
           SL_ProviderCredRecordTypeToFieldset__c objCustomSetting1 = new SL_ProviderCredRecordTypeToFieldset__c(Name = 'Provider_Education',Fieldset_Name__c = 'ProviderCredentialFieldSet',Label__c ='Education');
           lstCustomSettingRecToInsert.add(objCustomSetting1);
           SL_ProviderCredRecordTypeToFieldset__c objCustomSetting2 = new SL_ProviderCredRecordTypeToFieldset__c(Name = 'Provider_License',Fieldset_Name__c = 'ProviderCredentialLicenseType',Label__c ='License');
           lstCustomSettingRecToInsert.add(objCustomSetting2);
          
           insert lstCustomSettingRecToInsert;
           
            //Testing User context i.e logged in user is of MIHN - HPD Provider User profile and viewing his own contact
           System.runAs(objHpdProviderUser) 
           {  
                Apexpages.Standardcontroller stndctrl = new Apexpages.Standardcontroller(lstcontact.get(0));
                
                SL_ContactViewPageController objContactViewPageController = new SL_ContactViewPageController(stndctrl);
                system.assertEquals(objContactViewPageController.isEditRendered, true);
                system.assertEquals(objContactViewPageController.isAnotherprofileUser, false);
                system.assertEquals(objContactViewPageController.lstAffiliation.size(),2);
                system.assertEquals(objContactViewPageController.lstProviderSpecialty.size(),2);
                system.assertEquals(objContactViewPageController.lstProviderCredential.size(),1);
                
                objContactViewPageController.strContactSection = 'General Information'; 
                objContactViewPageController.EditContact();
                
                objContactViewPageController.objContact.NPI__c = '12345';
                objContactViewPageController.objStandardController.save();
                system.assert( objContactViewPageController.objContact.NPI__c == '12345');
             
                objContactViewPageController.strContactSection = 'ESI Data'; 
                objContactViewPageController.EditContact();
                objContactViewPageController.objContact.Department = 'Test department';
                objContactViewPageController.objStandardController.save();
                system.assert( objContactViewPageController.objContact.Department == 'Test department');
                
                objContactViewPageController.strContactSection = 'Contact Information'; 
                objContactViewPageController.EditContact();
                objContactViewPageController.objContact.Answering_Service__c = '809999999';
                objContactViewPageController.objStandardController.save();
                system.assert( objContactViewPageController.objContact.Answering_Service__c == '809999999');
                
                // checking for creation ,updation and deletion of ProviderSpecialty related list
                objContactViewPageController.strRelatedlistName = 'ProviderSpecialty Edit';
                objContactViewPageController.addNewRecordForContactRelatedList();
                system.assert(objContactViewPageController.objProviderSpecialityForInsertOrEdit.Id == null);
                system.assert(objContactViewPageController.lstProviderSpecialtyWrapper.size() == 2);
                objContactViewPageController.objProviderSpecialityForInsertOrEdit.Specialty__c = lstSpeciality.get(0).Id;
                objContactViewPageController.createOrEditRelatedlistRecordForContact();
                system.assert(objContactViewPageController.lstProviderSpecialtyWrapper.size() == 3); // checking with insertion of record.
                system.assert(objContactViewPageController.objProviderSpecialityForInsertOrEdit.Id != null);
                system.assert(objContactViewPageController.objProviderSpecialityForInsertOrEdit.Specialty__c == lstSpeciality.get(0).Id);
                objContactViewPageController.strRelatedListRecordIdToEdit = objContactViewPageController.objProviderSpecialityForInsertOrEdit.Id ;
                objContactViewPageController.editRelatedListRecordForContact();
                objContactViewPageController.objProviderSpecialityForInsertOrEdit.Specialty__c = lstSpeciality.get(1).Id;
                objContactViewPageController.createOrEditRelatedlistRecordForContact();
                system.assert(objContactViewPageController.objProviderSpecialityForInsertOrEdit.Specialty__c == lstSpeciality.get(1).Id); // checking with updation of record.
                objContactViewPageController.lstProviderSpecialtyWrapper[0].isDelete = true;
                system.assert(objContactViewPageController.lstProviderSpecialtyWrapper.size() == 3);
                objContactViewPageController.editOrDeleteProviderSpecialityRecord();
                system.assert(objContactViewPageController.lstProviderSpecialtyWrapper.size() == 2); // checking with deletion of record.
                
                // checking for creation ,updation and deletion of ProviderCareTeam related list
                objContactViewPageController.strRelatedlistName = 'ProviderCareTeam Edit';
                objContactViewPageController.addNewRecordForContactRelatedList();
                system.assert(objContactViewPageController.objProviderCareTeamForInsertOrEdit.Id == null);
                system.assert(objContactViewPageController.lstProviderCareTeamWrapper.size() == 0);
                objContactViewPageController.objProviderCareTeamForInsertOrEdit.Care_Team__c = objCareTeam.Id;
                objContactViewPageController.createOrEditRelatedlistRecordForContact();
                system.assert(objContactViewPageController.lstProviderCareTeamWrapper.size() == 1); // checking with insertion of record.
                system.assert(objContactViewPageController.objProviderCareTeamForInsertOrEdit.Id != null);
                system.assert(objContactViewPageController.objProviderCareTeamForInsertOrEdit.Care_Team__c == objCareTeam.Id);
                objContactViewPageController.strRelatedListRecordIdToEdit = objContactViewPageController.objProviderCareTeamForInsertOrEdit.Id ;
                objContactViewPageController.editRelatedListRecordForContact();
                objContactViewPageController.objProviderCareTeamForInsertOrEdit.Direct_Email__c = 'test@silverline.com';
                objContactViewPageController.createOrEditRelatedlistRecordForContact();
                system.assert(objContactViewPageController.objProviderCareTeamForInsertOrEdit.Direct_Email__c == 'test@silverline.com'); // checking with updation of record.
                objContactViewPageController.lstProviderCareTeamWrapper[0].isDelete = true;
                system.assert(objContactViewPageController.lstProviderCareTeamWrapper.size() == 1);
                objContactViewPageController.editOrDeleteProviderSpecialityRecord();
                system.assert(objContactViewPageController.lstProviderCareTeamWrapper.size() == 1); // checking with deletion of record.
                
                // checking for creation ,updation and deletion of ProviderAddress related list
                objContactViewPageController.strRelatedlistName = 'ProviderAddress Edit';
                objContactViewPageController.addNewRecordForContactRelatedList();
                system.assert(objContactViewPageController.objProviderAddressForInsertOrEdit.Id == null);
                system.assert(objContactViewPageController.lstProviderAddressWrapper.size() == 1);
                objContactViewPageController.objProviderAddressForInsertOrEdit.Provider__c = lstcontact.get(0).Id;
                objContactViewPageController.createOrEditRelatedlistRecordForContact();
                system.assert(objContactViewPageController.lstProviderAddressWrapper.size() == 2); // checking with insertion of record.
                system.assert(objContactViewPageController.objProviderAddressForInsertOrEdit.Id != null);
                system.assert(objContactViewPageController.objProviderAddressForInsertOrEdit.Provider__c == lstcontact.get(0).Id);
                objContactViewPageController.strRelatedListRecordIdToEdit = objContactViewPageController.objProviderAddressForInsertOrEdit.Id ;
                objContactViewPageController.editRelatedListRecordForContact();
                objContactViewPageController.objProviderAddressForInsertOrEdit.City__c = 'Test City';
                objContactViewPageController.createOrEditRelatedlistRecordForContact();
                system.assert(objContactViewPageController.objProviderAddressForInsertOrEdit.City__c == 'Test City'); // checking with updation of record.
                objContactViewPageController.lstProviderAddressWrapper[0].isDelete = true;
                system.assert(objContactViewPageController.lstProviderAddressWrapper.size() == 2);
                objContactViewPageController.editOrDeleteProviderAddressRecord();
                system.assert(objContactViewPageController.lstProviderAddressWrapper.size() == 1); // checking with deletion of record.
                
                // checking for creation ,updation and deletion of ProviderCredential related list
                objContactViewPageController.strRelatedlistName = 'ProviderCredential Edit';
                RecordType objRecType = [Select Name,DeveloperName from RecordType where DeveloperName = 'Provider_Education'];
                objContactViewPageController.strSelectedRecordType = objRecType.id;
                objContactViewPageController.addNewRecordForContactRelatedList();
                system.assert(objContactViewPageController.objProviderCredentialForInsertOrEdit.Id == null);
                system.assert(objContactViewPageController.lstProviderCredentialWrapper.size() == 1);
                objContactViewPageController.objProviderCredentialForInsertOrEdit.Name = 'Test Credential Name';
                objContactViewPageController.createOrEditRelatedlistRecordForContact();
                system.assert(objContactViewPageController.lstProviderCredentialWrapper.size() == 2); // checking with insertion of record.
                system.assert(objContactViewPageController.objProviderCredentialForInsertOrEdit.Id != null);
                
                RecordType objRecType1 = [Select Name,DeveloperName from RecordType where DeveloperName = 'Provider_License'];
                objContactViewPageController.strSelectedRecordType = objRecType.id;
                objContactViewPageController.addNewRecordForContactRelatedList();
                objContactViewPageController.objProviderCredentialForInsertOrEdit.Name = 'Test Credential Name1';
                objContactViewPageController.createOrEditRelatedlistRecordForContact();
                
                system.assert(objContactViewPageController.lstProviderCredentialWrapper.size() == 3); 
                
                RecordType objRecType2 = [Select Name,DeveloperName from RecordType where DeveloperName = 'Provider_Certificate'];
                objContactViewPageController.strSelectedRecordType = objRecType2.id;
                objContactViewPageController.addNewRecordForContactRelatedList();
                objContactViewPageController.objProviderCredentialForInsertOrEdit.Name = 'Test Credential Name1';
                objContactViewPageController.createOrEditRelatedlistRecordForContact();
                system.assert(objContactViewPageController.objProviderCredentialForInsertOrEdit.RecordTypeID == objRecType2.id);
                
                system.assert(objContactViewPageController.lstProviderCredentialWrapper.size() == 4); 
                
               /* SL_ContactViewPageController.strRecordTypeName = 'License';
                objContactViewPageController.addNewRecordForContactRelatedList();
                objContactViewPageController.objProviderCredentialForInsertOrEdit.Name = 'Test Credential Name2';
                objContactViewPageController.objProviderCredentialForInsertOrEdit.Credential_Number__c = 'Test Number';
                objContactViewPageController.createOrEditRelatedlistRecordForContact();
                system.assert(objContactViewPageController.lstProviderCredentialWrapper.size() == 5); */
             
                objContactViewPageController.strRelatedListRecordIdToEdit = objContactViewPageController.objProviderCredentialForInsertOrEdit.Id ;
                objContactViewPageController.editRelatedListRecordForContact();
                objContactViewPageController.objProviderCredentialForInsertOrEdit.Credential_Number__c = '9999';
                objContactViewPageController.createOrEditRelatedlistRecordForContact();
                system.assert(objContactViewPageController.objProviderCredentialForInsertOrEdit.Credential_Number__c == '9999'); // checking with updation of record.
                objContactViewPageController.lstProviderCredentialWrapper[0].isDelete = true;
                system.assert(objContactViewPageController.lstProviderCredentialWrapper.size() == 4);
                objContactViewPageController.editOrDeleteProviderCredentialRecord();
                
                 // Checking with Updation of contact AccountId on click of primary in affiliation related list
                 Contact objContact = [select Id,Name,AccountId from Contact where Id=: lstcontact.get(0).Id]; 
                 system.assert(objContact.AccountId == lstAccount.get(0).Id);
                 objContactViewPageController.strAffiliationAccountId = lstAccount.get(1).Id ;
                 objContactViewPageController.updateContactAccountId();
                 Contact objContact1 = [select Id,Name,AccountId from Contact where Id=: lstcontact.get(0).Id];
                 system.assert(objContact1.AccountId == lstAccount.get(1).Id);
                 
                 // checking with updation of ProviderSpecialty records on click of primary in ProviderSpecialty Related list
                 system.assert(objProviderSpeciality.Primary_Indicator__c == false);
                 system.assert(objProviderSpeciality1.Primary_Indicator__c == true);
                 objContactViewPageController.idProviderSpeciality = objProviderSpeciality.id;
                 objContactViewPageController.updateProviderSpecialityRecord();
                 list<Provider_Specialty__c> lstProvSpec = [ Select Id,Primary_Indicator__c 
                                                            from Provider_Specialty__c 
                                                            where Provider__c =: lstcontact.get(0).Id];
                                                            
                 system.assert(lstProvSpec.size() == 2);                                            
                 system.assert(lstProvSpec.get(0).Primary_Indicator__c == true);
                 system.assert(lstProvSpec.get(1).Primary_Indicator__c == false);
            
           }    
            //Testing User context i.e logged in user is of MIHN - HPD Provider User profile and viewing others contact
            System.runAs(objHpdProviderUser) 
            {  
                // Checking with the contact which is not asscociated to current User 
                Apexpages.Standardcontroller stndctrl = new Apexpages.Standardcontroller(lstContact.get(1));
              
                SL_ContactViewPageController objContactViewPageController = new SL_ContactViewPageController(stndctrl);  
                system.assertEquals(objContactViewPageController.isEditRendered, false);
                system.assertEquals(objContactViewPageController.isAnotherprofileUser, false);
                system.assertEquals(objContactViewPageController.lstAffiliation.size(),1);
                system.assertEquals(objContactViewPageController.lstProviderSpecialty.size(),0);
                system.assertEquals(objContactViewPageController.lstProviderCredential.size(),1);
            }
            //Testing User context i.e logged in user is of different profile other than MIHN - HPD Provider User profile 
            System.runAs(objMihinHpdOrgAdminProfileUser) 
            {
                Apexpages.Standardcontroller stndctrl = new Apexpages.Standardcontroller(lstContact.get(1));
                SL_ContactViewPageController objContactViewPageController = new SL_ContactViewPageController(stndctrl);  
                system.assertEquals(objContactViewPageController.isAnotherprofileUser, true);
                system.assertEquals(objContactViewPageController.isEditRendered, false);
            } 
            //Testing User context i.e logged in user is of MIHN - HPD Provider User profile and viewing his own contact and checking for related list records Editability
            System.runAs(objHpdProviderUser) 
            {  
                Apexpages.Standardcontroller stndctrl = new Apexpages.Standardcontroller(lstcontact.get(0));
                
                SL_ContactViewPageController objContactViewPageController = new SL_ContactViewPageController(stndctrl);
                
                integer noEditableRecord = 0;
                for(SL_ContactViewPageController.AffiliationWrapper obj :objContactViewPageController.lstAffiliationWrapper)
                {   
                    if(obj.isEditable)
                        noEditableRecord ++;    
                }
                
                //Check for Affiliation__c records
                system.assertEquals(noEditableRecord,0);    
                
                noEditableRecord = 0;
                for(SL_ContactViewPageController.ProviderSpecialtyWrapper obj :objContactViewPageController.lstProviderSpecialtyWrapper)
                {   if(obj.isEditable)
                        noEditableRecord ++;
                }   
                
                //Check for Provide_Care_Team__c records
                System.assertEquals(noEditableRecord,1);
                
                noEditableRecord = 0;
                for(SL_ContactViewPageController.ProviderCareTeamWrapper obj :objContactViewPageController.lstProviderCareTeamWrapper)
                {   if(obj.isEditable)
                        noEditableRecord ++;
                }   
                //Check for Provider_Specialty__c records
                system.assertEquals(noEditableRecord,1);
                
                noEditableRecord = 0;
                for(SL_ContactViewPageController.ProviderCredentialWrapper obj :objContactViewPageController.lstProviderCredentialWrapper)
                {   if(obj.isEditable)
                        noEditableRecord ++;
                }   
                
                //Check for Provider_Credential__c records
                system.assertEquals(noEditableRecord,3);
           }
           
           System.runAs(objSystemAdmin)
           {
           		Apexpages.Standardcontroller stndctrl = new Apexpages.Standardcontroller(lstcontact.get(0));
                
                SL_ContactViewPageController objContactViewPageController = new SL_ContactViewPageController(stndctrl);
           		
           		// checking for creation ,updation and deletion of Affiliation related list
                objContactViewPageController.strRelatedlistName = 'Affiliation Edit';
                objContactViewPageController.addNewRecordForContactRelatedList();
                system.assert(objContactViewPageController.objAffiliationForInsertOrEdit.Id == null);
                system.assert(objContactViewPageController.lstAffiliationWrapper.size() == 2);
                objContactViewPageController.objAffiliationForInsertOrEdit.Organization__c = lstAccount.get(1).Id;
                objContactViewPageController.objAffiliationForInsertOrEdit.Type__c = 'Employed By';
                objContactViewPageController.createOrEditRelatedlistRecordForContact();
                system.assert(objContactViewPageController.lstAffiliationWrapper.size() == 3);  // checking with insertion of record.
                system.assert(objContactViewPageController.objAffiliationForInsertOrEdit.Id != null);
                system.assert(Userinfo.getUserId() == objSystemAdmin.Id);
                system.assert(objContactViewPageController.objAffiliationForInsertOrEdit.Type__c == 'Employed By');
                objContactViewPageController.strRelatedListRecordIdToEdit = objContactViewPageController.objAffiliationForInsertOrEdit.Id ;
                objContactViewPageController.editRelatedListRecordForContact();
                objContactViewPageController.objAffiliationForInsertOrEdit.Type__c = 'Practices In';
                objContactViewPageController.createOrEditRelatedlistRecordForContact();
                system.assert(objContactViewPageController.objAffiliationForInsertOrEdit.Type__c == 'Practices In'); // checking with updation of record.
                objContactViewPageController.lstAffiliationWrapper[0].isDelete = true;
                system.assert(objContactViewPageController.lstAffiliationWrapper.size() == 3);
                objContactViewPageController.editOrDeleteAffiliationRecord();
                system.assert(objContactViewPageController.lstAffiliationWrapper.size() == 2); // checking with deletion of record.
           }    
    }         
}