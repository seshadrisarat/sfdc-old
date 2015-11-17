@isTest
private class SL_Test_PolicyDetailPage 
{
    static testMethod void policyDetailPage() 
    {        
        SL_PolicyStatusValues__c objSPS = new SL_PolicyStatusValues__c();
        objSPS.Name = 'In-Force';
        Insert objSPS;
        
        insert new States_Not_Display_Id_Cards__c(Name='States',List_Of_States__c='Test1,NJ');
        
        OperatorStatus__c objOS = new OperatorStatus__c();
        objOS.Name = 'Open';
        objOS.statusDescription__c = 'Open';
        Insert objOS;
        
        RecordType objRecordtype = [Select Id from RecordType where SobjectType =:'Account' AND Name='Member' limit 1];
        RecordType objRecordtypeBroker = [Select Id from RecordType where SobjectType =:'Account' AND Name='Broker' limit 1];

        Account objAccount1 = new Account(Name='TestSandeep1', RecordTypeId = objRecordtypeBroker.Id, Broker_Status__c = 'Suspended With Access', OwnerId = [Select Id from User where UserRoleId != null limit 1].Id);
        insert objAccount1;

        Account objAccount = new Account(Name='TestSandeep', RecordTypeId = objRecordtype.Id, Broker__c = objAccount1.Id,Broker_Status__c = 'Suspended With Access', OwnerId = [Select Id from User where UserRoleId != null limit 1].Id);
        insert objAccount;
        

        Contact objContact = new Contact();
        objContact.LastName = 'TestCOntact';
        objContact.AccountId = objAccount.Id;
        insert objContact;

        Contact objContact1 = new Contact();
        objContact1.LastName = 'TestCOntact1';
        objContact1.AccountId = objAccount.Id;
        insert objContact1;
        
        Profile objCommunityUserProfile1 = [SELECT Id FROM Profile WHERE Name='PURE Broker View Partner Login User']; 
    
        Profile objCommunityUserProfile = [SELECT Id FROM Profile WHERE Name='Pure Customer Community Login User'];
        
        Profile objStandardUserProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
        Profile objGuestUserProfile = [Select Id From Profile WHERE Name = 'Guest License User'];
        
        User objProtalUser = new User(Alias = 'HPD7', Email='standarduser7@testorg.com', 
                                        EmailEncodingKey='UTF-8', LastName='Testing7', LanguageLocaleKey='en_US', 
                                        LocaleSidKey='en_US', ProfileId = objCommunityUserProfile1.Id, ContactId = objContact1.Id,
                                        TimeZoneSidKey='America/Los_Angeles', UserName='standarduser7@testorg.com');
        
        User objStandardUser = new User(Alias = 'HPD5', Email='standarduser5@testorg.com', 
                                            EmailEncodingKey='UTF-8', LastName='Testing5', LanguageLocaleKey='en_US', 
                                            LocaleSidKey='en_US', ProfileId = objStandardUserProfile.Id, 
                                            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser5@testorg.com');                                
        
        User objHpdProviderUser = new User(Alias = 'HPD6', Email='standarduser6@testorg.com', 
                                                 EmailEncodingKey='UTF-8', LastName='Testing6', LanguageLocaleKey='en_US', 
                                                 LocaleSidKey='en_US', ProfileId = objCommunityUserProfile.Id, 
                                                 TimeZoneSidKey='America/Los_Angeles', UserName='standarduser6@testorg.com' , ContactID = objContact.Id);
        
        User objGuestUser = new User(Alias = 'HPD6', Email='standarduser6@testorg.com', 
                                                 EmailEncodingKey='UTF-8', LastName='Testing6', LanguageLocaleKey='en_US', 
                                                 LocaleSidKey='en_US', ProfileId = objGuestUserProfile.Id, 
                                                 TimeZoneSidKey='America/Los_Angeles', UserName='guestuseree6@testorg.com');
        
        /*Added by Sanath */                                         
        System.runAs(new User(Id = Userinfo.getUserId()))
        {
            Test.startTest();
                /*Profile objCommunityUserProfile1 = [SELECT Id FROM Profile WHERE Name='PURE Broker View Partner Login User']; 
        
                Profile objCommunityUserProfile = [SELECT Id FROM Profile WHERE Name='Pure Customer Community Login User'];
                
                Profile objStandardUserProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
                
                User objProtalUser = new User(Alias = 'HPD7', Email='standarduser7@testorg.com', 
                                                EmailEncodingKey='UTF-8', LastName='Testing7', LanguageLocaleKey='en_US', 
                                                LocaleSidKey='en_US', ProfileId = objCommunityUserProfile1.Id, ContactId = objContact1.Id,
                                                TimeZoneSidKey='America/Los_Angeles', UserName='standarduser7@testorg.com');*/
                insert objProtalUser;
        
                /*User objStandardUser = new User(Alias = 'HPD5', Email='standarduser5@testorg.com', 
                                                EmailEncodingKey='UTF-8', LastName='Testing5', LanguageLocaleKey='en_US', 
                                                LocaleSidKey='en_US', ProfileId = objStandardUserProfile.Id, 
                                                TimeZoneSidKey='America/Los_Angeles', UserName='standarduser5@testorg.com');*/
                insert objStandardUser;
                
                /*User objHpdProviderUser = new User(Alias = 'HPD6', Email='standarduser6@testorg.com', 
                                                     EmailEncodingKey='UTF-8', LastName='Testing6', LanguageLocaleKey='en_US', 
                                                     LocaleSidKey='en_US', ProfileId = objCommunityUserProfile.Id, 
                                                     TimeZoneSidKey='America/Los_Angeles', UserName='standarduser6@testorg.com' , ContactID = objContact.Id);*/              
                                     
                insert objHpdProviderUser;
                
                insert objGuestUser;
            Test.stopTest();
        }
        /*Added by Sanath */
        RecordType objRecordtypePolicy = [Select Id from RecordType where SobjectType =:'Policy__c' AND Name='Auto' limit 1];
        
        RecordType objRecordtypePolicycollection = [Select Id from RecordType where SobjectType =:'Policy__c' AND Name='Collections' limit 1];
        
        
        RecordType objRecordtypePolicyWatercraft = [Select Id from RecordType where SobjectType =:'Policy__c' AND Name='Watercraft' limit 1];
        
        
        RecordType objRecordtypePolicyExcess = [Select Id from RecordType where SobjectType =:'Policy__c' AND Name='Excess' limit 1];
        
        RecordType objRecordtypePolicyHome = [Select Id from RecordType where SobjectType =:'Policy__c' AND Name='Homeowners' limit 1];
        
        RecordType objRecordtypeWorkersCompensation = [Select Id from RecordType where SobjectType =:'Policy__c' AND Name='worker\'s compensation' limit 1];
        
        List<Policy__c> lstPolicy = new List<Policy__c>{new Policy__c(Member__c = objAccount.Id, Policy_Number__c = '12332452', RecordTypeId = objRecordtypePolicycollection.Id, Effective_Date__c = date.today(),
                                                        Policy_Status__c = 'In-Force',Expiration_Date__c = date.today()+1, Fine_Arts_Collectible_Blanket__c = '120', Fine_Arts_Collectible_Scheduled__c = '120', Risk_State__c = 'NJ'),
                                                        new Policy__c(Member__c = objAccount.Id, Policy_Number__c = '12355452', RecordTypeId = objRecordtypePolicyWatercraft.Id, Effective_Date__c = date.today(),
                                                        Policy_Status__c = 'In-Force',Expiration_Date__c = date.today()+1, Fine_Arts_Collectible_Blanket__c = '120', Fine_Arts_Collectible_Scheduled__c = '120',Risk_State__c = 'NJ'),
                                                        new Policy__c(Member__c = objAccount.Id, Policy_Number__c = '123222452', RecordTypeId = objRecordtypePolicyExcess.Id, Effective_Date__c = date.today(),
                                                        Policy_Status__c = 'In-Force',Expiration_Date__c = date.today()+1, Fine_Arts_Collectible_Blanket__c = '120', Fine_Arts_Collectible_Scheduled__c = '120',Risk_State__c = 'NJ'),
                                                        new Policy__c(Member__c = objAccount.Id, Policy_Number__c = '1223452', RecordTypeId = objRecordtypePolicyHome.Id, Effective_Date__c = date.today(),
                                                        Policy_Status__c = 'In-Force',Expiration_Date__c = date.today()+1, Fine_Arts_Collectible_Blanket__c = '120', Fine_Arts_Collectible_Scheduled__c = '120',Risk_State__c = 'NJ'),
                                                        new Policy__c(Member__c = objAccount.Id, Policy_Number__c = '12345', RecordTypeId = objRecordtypePolicy.Id, Effective_Date__c = date.today(),
                                                        Policy_Status__c = 'In-Force',Expiration_Date__c = date.today()+1, Fine_Arts_Collectible_Blanket__c = '120', Fine_Arts_Collectible_Scheduled__c = '120',Risk_State__c = 'NJ'),
                                                        new Policy__c(Member__c = objAccount.Id, Policy_Number__c = '123333452', RecordTypeId = objRecordtypeWorkersCompensation.Id, Effective_Date__c = date.today(),
                                                        Policy_Status__c = 'In-Force',Expiration_Date__c = date.today()+1, Fine_Arts_Collectible_Blanket__c = '120', Fine_Arts_Collectible_Scheduled__c = '120',Risk_State__c = 'NJ'),
                                                        new Policy__c(Member__c = objAccount.Id, Policy_Number__c = '123333457', RecordTypeId = objRecordtypeWorkersCompensation.Id, Effective_Date__c = date.today(),
                                                        Policy_Status__c = 'In-Force',Expiration_Date__c = date.today()+1, Fine_Arts_Collectible_Blanket__c = '120', Fine_Arts_Collectible_Scheduled__c = '120')               
                                                        };
        insert lstPolicy;
        
        
        Claim__c objClaim = new Claim__c(Policy__c = lstPolicy[3].Id, Member__c = objAccount.Id);
        
        insert objClaim;
        
        Transactions__c objTran = new Transactions__c(  Policy__c = lstPolicy[3].Id, Type__c = 'NEW',   Process_Date__c = date.today(), Description__c = 'ss', Do_Not_Show__c = false);
        insert objTran;
        
        Transactions__c objTran1 = new Transactions__c(  Policy__c = lstPolicy[5].Id, Type__c = 'NEW',   Process_Date__c = date.today(), Description__c = 'ss', Do_Not_Show__c = false, Policy_Term_Sequence__c = 3);
        insert objTran1;
        
        Transactions__c objTran2 = new Transactions__c(  Policy__c = lstPolicy[5].Id, Type__c = 'NEW',   Process_Date__c = date.today(), Description__c = 'ss', Do_Not_Show__c = false, Policy_Term_Sequence__c = 4);
        insert objTran2;
        
        Property__c objProperty = new Property__c(  Policy__c = lstPolicy[3].Id, Street__c = 'sas', City__c = 'New York');
        insert objProperty;
        
        Property__c objProperty1 = new Property__c(  Policy__c = lstPolicy[5].Id, Street__c = 'sas', City__c = 'New York', Extended_Liability__c = true, Street_2__c = 'Test', State__c = 'NY');
        insert objProperty1;
        
       
        
        List<CoverageClasslabel__c> lstCoverageClasslabel = new List<CoverageClasslabel__c>{new CoverageClasslabel__c(Name = 'KS', 
                                                                                                                      AOP_Deductible__c = 'KS - AOP', 
                                                                                                                      Contents_Amount__c = 'KS - Contents',
                                                                                                                      Dwelling_Amount__c = 'KS - Dewelling',
                                                                                                                      Hurricane_Deductible__c = 'KS - Hurricane',
                                                                                                                      Liability_Limit_Amount__c = 'KS - Liability Amount',
                                                                                                                      Loss_of_Use__c = 'KS - Loss of use',
                                                                                                                      Medical_Payments_Amount__c = 'KS - Medical',
                                                                                                                      Other_Structures_Amount__c = 'KS - Other'),
                                                                                                                      
                                                                                            new CoverageClasslabel__c(Name = 'MO', 
                                                                                                                      AOP_Deductible__c = 'MO - AOP', 
                                                                                                                      Contents_Amount__c = 'MO - Contents',
                                                                                                                      Dwelling_Amount__c = 'MO - Dewelling',
                                                                                                                      Hurricane_Deductible__c = 'MO - Hurricane',
                                                                                                                      Liability_Limit_Amount__c = 'MO - Liability Amount',
                                                                                                                      Loss_of_Use__c = 'MO - Loss of use',
                                                                                                                      Medical_Payments_Amount__c = 'MO - Medical',
                                                                                                                      Other_Structures_Amount__c = 'MO - Other')
            
                                                                                            };
        insert lstCoverageClasslabel;
        
        Property__c objProperty2 = new Property__c(  Policy__c = lstPolicy[5].Id, Street__c = 'sas', City__c = 'New York', Extended_Liability__c = false, Street_2__c = 'Test', State__c = 'CT');
        insert objProperty2;
        
        list<Covered_Vessels__c> lstCoveredVehicles = new list<Covered_Vessels__c>{new Covered_Vessels__c(Year__c = 1231, Policy__c = lstPolicy[1].Id, Model__c='12221211', Make__c = '21211', Length__c = '1212', Hull_Value__c = 12 ),
                                                                                    new Covered_Vessels__c(Year__c = 1232, Policy__c = lstPolicy[2].Id, Model__c='12221212', Make__c = '21212', Length__c = '1212', Hull_Value__c = 12 ),
                                                                                    new Covered_Vessels__c(Year__c = 1233, Policy__c = lstPolicy[3].Id, Model__c='12221213', Make__c = '21213', Length__c = '1212', Hull_Value__c = 12 ),
                                                                                    new Covered_Vessels__c(Year__c = 1234, Policy__c = lstPolicy[4].Id, Model__c='12221214', Make__c = '21214', Length__c = '1212', Hull_Value__c = 12 ),
                                                                                    new Covered_Vessels__c(Year__c = 1234, Policy__c = lstPolicy[5].Id, Model__c='12221215', Make__c = '21215', Length__c = '1212', Hull_Value__c = 12 )};
        insert lstCoveredVehicles;
        
        Operator__c objOperators = new Operator__c(Policy__c = lstPolicy[0].Id, License__c='2121', DOB__c = date.today(), Status__c = 'Open' );
        insert objOperators;
        
        Operator__c objOperators1 = new Operator__c(Policy__c = lstPolicy[1].Id, License__c='2122', DOB__c = date.today(), Status__c = 'Open' );
        insert objOperators1;
        
        Operator__c objOperators2 = new Operator__c(Policy__c = lstPolicy[2].Id, License__c='2123', DOB__c = date.today(), Status__c = 'Open' );
        insert objOperators2;
        
        Operator__c objOperators3 = new Operator__c(Policy__c = lstPolicy[3].Id, License__c='2124', DOB__c = date.today(), Status__c = 'Open' );
        insert objOperators3;
        
        Operator__c objOperators4 = new Operator__c(Policy__c = lstPolicy[4].Id, License__c='2125', DOB__c = date.today(), Status__c = 'Open' );
        insert objOperators4;
        
        Operator__c objOperators5 = new Operator__c(Policy__c = lstPolicy[5].Id, License__c='2126', DOB__c = date.today(), Status__c = 'Open' );
        insert objOperators5;
        
        Operator__c objOperators6 = new Operator__c(Policy__c = lstPolicy[5].Id, License__c='2126', DOB__c = date.today());
        insert objOperators6;
        
        List<Vehicle__c> lstVehicle = new List<Vehicle__c>{new Vehicle__c(Name = 'Test Vehicle', Make__c = 'Test Make', Model__c = 'Test Model', VIN__c = 'Test VIN', Year__c = 1990, Policy__c = lstPolicy[0].Id, Can_Download__c = true),
                                                           new Vehicle__c(Name = 'Test Vehicle 1', Make__c = 'Test Make1', Model__c = 'Test Model1', VIN__c = 'Test VIN1', Year__c = 1991, Policy__c = lstPolicy[1].Id, Can_Download__c = true),
                                                           new Vehicle__c(Name = 'Test Vehicle 2', Make__c = 'Test Make1', Model__c = 'Test Model1', VIN__c = 'Test VIN1', Year__c = 1991, Policy__c = lstPolicy[2].Id, Can_Download__c = true),
                                                           new Vehicle__c(Name = 'Test Vehicle 3', Make__c = 'Test Make1', Model__c = 'Test Model1', VIN__c = 'Test VIN1', Year__c = 1991, Policy__c = lstPolicy[3].Id, Can_Download__c = true),
                                                           new Vehicle__c(Name = 'Test Vehicle 4', Make__c = 'Test Make1', Model__c = 'Test Model1', VIN__c = 'Test VIN1', Year__c = 1991, Policy__c = lstPolicy[4].Id, Can_Download__c = true),
                                                           new Vehicle__c(Name = 'Test Vehicle 5', Make__c = 'Test Make1', Model__c = 'Test Model1', VIN__c = 'Test VIN1', Year__c = 1991, Policy__c = lstPolicy[5].Id, Can_Download__c = true),
                                                           new Vehicle__c(Name = 'Test Vehicle 6', Make__c = 'Test Make1', Model__c = 'Test Model1', VIN__c = 'Test VIN1', Year__c = 1991, Policy__c = lstPolicy[5].Id, Can_Download__c = true)                                                       
                                                          
                                                          };
        insert lstVehicle; 
        
        list<Risk_Management_Report__c> lstRiskMangRep = new list<Risk_Management_Report__c>{new Risk_Management_Report__c(Policy__c = lstPolicy[1].Id, Address__c = 'Test Address',EDW_Last_Modified_Date__c = date.today()),
                                                                                         new Risk_Management_Report__c(Policy__c = lstPolicy[2].Id, Address__c = 'Test Address',EDW_Last_Modified_Date__c = date.today()),
                                                                                         new Risk_Management_Report__c(Policy__c = lstPolicy[3].Id, Address__c = 'Test Address',EDW_Last_Modified_Date__c = date.today()),
                                                                                         new Risk_Management_Report__c(Policy__c = lstPolicy[4].Id, Address__c = 'Test Address',EDW_Last_Modified_Date__c = date.today()),
                                                                                         new Risk_Management_Report__c(Policy__c = lstPolicy[5].Id, Address__c = 'Test Address',EDW_Last_Modified_Date__c = date.today()) };
        insert lstRiskMangRep; 

        Agency_Contact__c objAgencyCont = new Agency_Contact__c(Contact__c = objContact1.Id,User_Status__c = 'Active',Agency__c = objAccount1.Id);
        insert objAgencyCont;

        System.runAs(objHpdProviderUser) 
        {           
            SL_PolicyDetailPage objSL_PolicyDetailControllerWithoutURL = new SL_PolicyDetailPage();
            objSL_PolicyDetailControllerWithoutURL.pageAction();
            
            ApexPages.CurrentPage().getParameters().put('url','');
            SL_PolicyDetailPage objSL_PolicyDetailControllerBlankURL = new SL_PolicyDetailPage();
            objSL_PolicyDetailControllerBlankURL.pageAction();
            
            ApexPages.CurrentPage().getParameters().put('url','5454');
            SL_PolicyDetailPage objSL_PolicyDetailControllerWrongURL = new SL_PolicyDetailPage();
            objSL_PolicyDetailControllerWrongURL.pageAction();
            
            ApexPages.CurrentPage().getParameters().put('url', lstPolicy[0].Policy_Number__c);
            SL_PolicyDetailPage objSL_PolicyDetailController = new SL_PolicyDetailPage();
            objSL_PolicyDetailController.pageAction();
            
            ApexPages.currentPage().getParameters().put('url',lstPolicy[1].Policy_Number__c);
            SL_PolicyDetailPage objSL_PolicyDetailControllerHome = new SL_PolicyDetailPage();
            objSL_PolicyDetailControllerHome.pageAction();
            
            ApexPages.currentPage().getParameters().put('url',lstPolicy[2].Policy_Number__c);
            SL_PolicyDetailPage objSL_PolicyDetailControllerColl = new SL_PolicyDetailPage();
            objSL_PolicyDetailControllerColl.pageAction();
            
            ApexPages.currentPage().getParameters().put('url',lstPolicy[3].Policy_Number__c);
            SL_PolicyDetailPage objSL_PolicyDetailControllerWatercraft = new SL_PolicyDetailPage();
            objSL_PolicyDetailControllerWatercraft.pageAction();
            
           ApexPages.CurrentPage().getParameters().put('url', lstPolicy[4].Policy_Number__c);
            SL_PolicyDetailPage objSL_PolicyDetailControllerExcess = new SL_PolicyDetailPage();
            objSL_PolicyDetailControllerExcess.pageAction();
            
            ApexPages.currentPage().getParameters().put('pid',lstPolicy[3].Id);
          SL_PolicyDetailPage objSL_PolicyDetailController12 = new SL_PolicyDetailPage();
          objSL_PolicyDetailController12.pageAction();
           
            
       }
       
       System.runAs(objStandardUser) 
       {
            ApexPages.currentPage().getParameters().put('pid','');
            SL_PolicyDetailPage objSL_PolicyDetailControllerBlankPolicyId = new SL_PolicyDetailPage();
            objSL_PolicyDetailControllerBlankPolicyId.pageAction();
            
            ApexPages.currentPage().getParameters().put('pid','123');
            SL_PolicyDetailPage objSL_PolicyDetailControllerWrongPolicyId = new SL_PolicyDetailPage();
            objSL_PolicyDetailControllerWrongPolicyId.pageAction();
            
            ApexPages.currentPage().getParameters().put('pid',lstPolicy[3].Id);
            SL_PolicyDetailPage objSL_PolicyDetailController = new SL_PolicyDetailPage();
            objSL_PolicyDetailController.pageAction();
       }
       
       System.runAs(objProtalUser){ 
            Apexpages.currentPage().getParameters().put('mId',objAccount.Id);
            ApexPages.CurrentPage().getParameters().put('url', lstPolicy[5].Policy_Number__c);
            SL_PolicyDetailPage objSL_PolicyDetailControllerWorkersCompensation = new SL_PolicyDetailPage();
            objSL_PolicyDetailControllerWorkersCompensation.pageAction();           
       }
       
       /*Added by Sanath */
       delete [Select Id from Agency_Contact__c]; 
       System.runAs(objProtalUser)
       { 
          Apexpages.currentPage().getParameters().put('mId',objAccount.Id);
          ApexPages.CurrentPage().getParameters().put('url', lstPolicy[5].Policy_Number__c);
          SL_PolicyDetailPage objSL_PolicyDetailControllerWorkersCompensation1 = new SL_PolicyDetailPage();
          objSL_PolicyDetailControllerWorkersCompensation1.strLimit = 'test limit';
          objSL_PolicyDetailControllerWorkersCompensation1.pageAction();          
       }
       /*Added by Sanath */
       
       /* Start - Added by Pankaj Ganwani on 15/JUNE/2015 */
       System.runAs(objGuestUser)
       {
       	  Apexpages.currentPage().getParameters().put('mId',objAccount.Id);
          ApexPages.CurrentPage().getParameters().put('url', lstPolicy[5].Policy_Number__c);
          SL_PolicyDetailPage objSL_PolicyDetailControllerWorkersCompensation = new SL_PolicyDetailPage();
          objSL_PolicyDetailControllerWorkersCompensation.pageAction();
          
          Apexpages.currentPage().getParameters().remove('mId');
          SL_PolicyDetailPage objSL_PolicyDetailControllerWorkersCompensation1 = new SL_PolicyDetailPage();
          objSL_PolicyDetailControllerWorkersCompensation1.pageAction();
       }       
       /* End - Added by Pankaj Ganwani on 15/JUNE/2015 */
    }
}