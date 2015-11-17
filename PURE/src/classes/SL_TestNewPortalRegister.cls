@isTest
public class SL_TestNewPortalRegister {
    static testMethod void SL_TestNewPortalRegister() {
        RecordType objRecordtype = [Select Id from RecordType where SobjectType =:'Account' AND Name='Member' limit 1];
        
        Account objAccount = new Account(Name='TestSandeep', RecordTypeId = objRecordtype.Id, OwnerId = [Select Id from User where UserRoleId != null limit 1].Id
                                        ,Member_Key_EDW__c = '12345',BillingPostalCode = '50506');
        insert objAccount;
        
        Account objAccount1 = new Account(Name='TestSandeep-01', RecordTypeId = objRecordtype.Id, OwnerId = [Select Id from User where UserRoleId != null limit 1].Id
                                        ,Member_Key_EDW__c = '123456',BillingPostalCode = '50506');
        insert objAccount1;
        
         Account objAccount11 = new Account(Name='TestSandeep-02', RecordTypeId = objRecordtype.Id, OwnerId = [Select Id from User where UserRoleId != null limit 1].Id
                                        ,Member_Key_EDW__c = null,BillingPostalCode = '50506');
        insert objAccount11;
        
        
        RecordType objRecordtypePolicy = [Select Id from RecordType where SobjectType =:'Policy__c' AND Name='Auto' limit 1];
        
        RecordType objRecordtypePolicycollection = [Select Id from RecordType where SobjectType =:'Policy__c' AND Name='Collections' limit 1];
        
        
        RecordType objRecordtypePolicyWatercraft = [Select Id from RecordType where SobjectType =:'Policy__c' AND Name='Watercraft' limit 1];
        
        
        RecordType objRecordtypePolicyExcess = [Select Id from RecordType where SobjectType =:'Policy__c' AND Name='Excess' limit 1];
        
        RecordType objRecordtypePolicyHome = [Select Id from RecordType where SobjectType =:'Policy__c' AND Name='Homeowners' limit 1];
        
        List<Policy__c> lstPolicy = new List<Policy__c>{new Policy__c(Member__c = objAccount.Id, Policy_Number__c = '12332452', RecordTypeId = objRecordtypePolicycollection.Id, Effective_Date__c = date.today(),
                                                        Policy_Status__c = 'In-Force',Expiration_Date__c = date.today()+1, Fine_Arts_Collectible_Blanket__c = '120', Fine_Arts_Collectible_Scheduled__c = '120', Risk_State__c = 'NJ'),
                                                        new Policy__c(Member__c = objAccount.Id, Policy_Number__c = '12355452', RecordTypeId = objRecordtypePolicyWatercraft.Id, Effective_Date__c = date.today(),
                                                        Policy_Status__c = 'In-Force',Expiration_Date__c = date.today()+1, Fine_Arts_Collectible_Blanket__c = '120', Fine_Arts_Collectible_Scheduled__c = '120',Risk_State__c = 'NJ'),
                                                        new Policy__c(Member__c = objAccount.Id, Policy_Number__c = '123222452', RecordTypeId = objRecordtypePolicyExcess.Id, Effective_Date__c = date.today(),
                                                        Policy_Status__c = 'In-Force',Expiration_Date__c = date.today()+1, Fine_Arts_Collectible_Blanket__c = '120', Fine_Arts_Collectible_Scheduled__c = '120',Risk_State__c = 'NJ'),
                                                        new Policy__c(Member__c = objAccount.Id, Policy_Number__c = '1223452', RecordTypeId = objRecordtypePolicyHome.Id, Effective_Date__c = date.today(),
                                                        Policy_Status__c = 'In-Force',Expiration_Date__c = date.today()+1, Fine_Arts_Collectible_Blanket__c = '120', Fine_Arts_Collectible_Scheduled__c = '120'),
                                                        new Policy__c(Member__c = objAccount11.Id, Policy_Number__c = '12345', RecordTypeId = objRecordtypePolicy.Id, Effective_Date__c = date.today(),
                                                        Policy_Status__c = 'In-Force',Expiration_Date__c = date.today()+1, Fine_Arts_Collectible_Blanket__c = '120', Fine_Arts_Collectible_Scheduled__c = '120')                
                                                        };
        insert lstPolicy;
        
        Contact objContact = new Contact();
        objContact.LastName = 'TestContactLast';
        objContact.FirstName = 'TestContactFirst';
        objContact.AccountId = objAccount.Id;
        objContact.Primary__c = true;
        insert objContact;
        
        Contact objContact1 = new Contact();
        objContact1.LastName = 'TestContactLast';
        objContact1.FirstName = 'TestContactFirst';
        objContact1.AccountId = objAccount1.Id;
        objContact1.Primary__c = true;
        insert objContact1;
        
        Profile objCommunityUserProfile = [SELECT Id FROM Profile WHERE Name='Pure Customer Community Login User'];
        
        User objHpdProviderUser = new User(Alias = 'HPD5', Email='standarduser5@testorg.com', 
                                             EmailEncodingKey='UTF-8', LastName='Testing5', LanguageLocaleKey='en_US', 
                                             LocaleSidKey='en_US', ProfileId = objCommunityUserProfile.Id, 
                                             TimeZoneSidKey='America/Los_Angeles', UserName='standarduser5@testorg.com' , ContactID = objContact.Id);              
                             
        insert objHpdProviderUser;
        
        //User objHpdProviderUser1 = new User(Alias = 'HPD6', Email='standarduser6@testorg.com', 
        //                                     EmailEncodingKey='UTF-8', LastName='Testing6', LanguageLocaleKey='en_US', 
        //                                     LocaleSidKey='en_US', ProfileId = objCommunityUserProfile.Id, 
        //                                     TimeZoneSidKey='America/Los_Angeles', UserName='standarduser6@testorg.com' , ContactID = objContact1.Id);              
                             
        //insert objHpdProviderUser1;
        
        System.runAs(objHpdProviderUser)
        {
             // Create new user for portal
            SL_PortalRegisterController controller = new SL_PortalRegisterController();
            controller.memberId = '123456';         
            controller.zip = '50506';
            controller.email = 'test@silverlinecrm.com';
            controller.password = 'Test1234';
            //controller.confirmPwd = 'Test1234';
            
            System.assertEquals(controller.register(),null); 
        }   
        
        System.runAs(objHpdProviderUser) 
        {
             // Create new user for portal
            SL_PortalRegisterController controller = new SL_PortalRegisterController();
            controller.memberId = '12355452';       
            controller.zip = '50506';
            controller.email = 'test@silverlinecrm.com';
            controller.password = 'Test1234';
            //controller.confirmPwd = 'Test1234';
            
            System.assertEquals(controller.register(),null); 
        }
        
         System.runAs(objHpdProviderUser) 
        {
             // Create new user for portal
            SL_PortalRegisterController controller = new SL_PortalRegisterController();
            controller.memberId = '12345';      
            controller.zip = '50506';
            controller.email = 'test@silverlinecrm.com';
            controller.password = 'Test1234';
            //controller.confirmPwd = 'Test1234';
            
            System.assertEquals(controller.register(),null); 
        }
        
         
         System.runAs(objHpdProviderUser) 
        {
             // Create new user for portal
            SL_PortalRegisterController controller = new SL_PortalRegisterController();
            controller.memberId = '12345';      
            controller.zip = '50506';
            controller.email = 'test@silverlinecrm.com';
            controller.password = 'Tes';
            //controller.confirmPwd = 'Tes';
            
            System.assertEquals(controller.register(),null); 
        }
        
        System.runAs(objHpdProviderUser) 
        {
             // Create new user for portal
            SL_PortalRegisterController controller = new SL_PortalRegisterController();
            controller.memberId = '123222452';      
            controller.zip = '50506';
            controller.email = 'test@silverlinecrm.com';
            controller.password = 'Tes1';
            //controller.confirmPwd = 'Tes';
            
            System.assertEquals(controller.register(),null); 
        }
        
        // Test zip code not having 5 digits
        System.runAs(objHpdProviderUser) 
        {
             // Create new user for portal
            SL_PortalRegisterController controller = new SL_PortalRegisterController();
            controller.memberId = '123222452';      
            controller.zip = '5050';
            controller.email = 'test@silverlinecrm.com';
            controller.password = 'Tes1';
            //controller.confirmPwd = 'Tes';
            
            System.assertEquals(controller.register(),null); 
        }

        // Test member ID not matching
        System.runAs(objHpdProviderUser) 
        {
             // Create new user for portal
            SL_PortalRegisterController controller = new SL_PortalRegisterController();
            controller.memberId = '1';      
            controller.zip = '50506';
            controller.email = 'test@silverlinecrm.com';
            controller.password = 'Tes1';
            //controller.confirmPwd = 'Tes';
            
            System.assertEquals(controller.register(),null); 
        }
    }
}