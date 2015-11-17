@isTest(seealldata=true)
private class LeadAssignmentTest {
    
    @isTest static void testRequestMembership() {
        Test.startTest();
            DateTime now = DateTime.now();
            Lead l = new Lead(LastName='Foo', Company='Bar');
            l.Inbound_Lead_Record_Type_Visible__c = 'Investment Banker';
            l.Marketo_lastMQLtitle__c = 'Request';
            l.Marketo_lastMQLdate__c = now;
            insert l;

            l = [SELECT Id, Owner.UserRole.Name 
                      FROM Lead 
                      WHERE Marketo_lastMQLdate__c = :now 
                      AND LastName = 'Foo' AND Company='Bar'];
            System.assertEquals(l.Owner.UserRole.Name, 'MOA - Inbound');
        Test.stopTest();
    }

    @isTest static void testAssignLeadIB() {
        Test.startTest();
            DateTime now = DateTime.now();
            Lead l = new Lead(LastName='Foo', Company='Bar');
            l.Inbound_Lead_Record_Type_Visible__c = 'Investment Banker';
            l.Marketo_lastMQLdate__c = now;
            insert l;

            l = [SELECT Id, Owner.UserRole.Name 
                      FROM Lead 
                      WHERE Marketo_lastMQLdate__c = :now 
                      AND LastName = 'Foo' AND Company='Bar'];
            System.assertEquals(l.Owner.UserRole.Name, 'AE - IBA Team');
        Test.stopTest();
    }

    @isTest static void testAssignLeadPE() {
        Test.startTest();
            DateTime now = DateTime.now();
            Lead l = new Lead(LastName='PCM', Company='Test');
            l.Inbound_Lead_Record_Type_Visible__c = 'Professional Investor';
            l.Transaction_Types__c = 'Buy Companies';
            l.Marketo_lastMQLdate__c = now;
            insert l;

            l = [SELECT Id, Owner.UserRole.Name 
                      FROM Lead 
                      WHERE Marketo_lastMQLdate__c = :now 
                      AND LastName = 'PCM' AND Company='Test'];
            System.assertEquals(l.Owner.UserRole.Name, 'AE - PCM Team');
        Test.stopTest();
    }

    @isTest static void testExistingAE() {
        Test.startTest();
            User u = [SELECT Id FROM User WHERE UserRole.Name = 'AE - PCM Team' AND isActive = true LIMIT 1];

            DateTime now = DateTime.now();
            Lead l = new Lead(LastName='PCM', Company='Test');
            l.Inbound_Lead_Record_Type_Visible__c = 'Professional Investor';
            l.Transaction_Types__c = 'Buy Companies';
            l.OwnerId = u.Id;
            l.Marketo_lastMQLdate__c = now;
            insert l;

            l = [SELECT Id, Owner.UserRole.Name 
                      FROM Lead 
                      WHERE Marketo_lastMQLdate__c = :now 
                      AND LastName = 'PCM' AND Company='Test'];
            System.assertEquals(l.OwnerId, u.Id);
        Test.stopTest();
    }

    @isTest static void testAssignLeadPCS() {
        Test.startTest();
            DateTime now = DateTime.now();
            Lead l = new Lead(LastName='PCS', Company='Test');
            l.Inbound_Lead_Record_Type_Visible__c = 'CEO/CFO/President';
            l.Transaction_Types__c = 'Raise Capital';
            l.Marketo_lastMQLdate__c = now;
            insert l;

            l = [SELECT Id, Owner.UserRole.Name 
                      FROM Lead 
                      WHERE Marketo_lastMQLdate__c = :now 
                      AND LastName = 'PCS' AND Company='Test'];
            System.assertEquals(l.Owner.UserRole.Name, 'AE - Private Companies Team');
        Test.stopTest();
    }

    @isTest static void testExistingAEPCS() {
        Test.startTest();
            DateTime now = DateTime.now();
            User u = [SELECT Id FROM User WHERE UserRole.Name = 'AE - Private Companies Team' AND isActive = true LIMIT 1];
            Lead l = new Lead(LastName='PCS', Company='Test');
            l.Inbound_Lead_Record_Type_Visible__c = 'CEO/CFO/President';
            l.Transaction_Types__c = 'Raise Capital';
            l.OwnerId = u.Id;
            l.Marketo_lastMQLdate__c = now;

            insert l;

            l = [SELECT Id, Owner.UserRole.Name 
                      FROM Lead 
                      WHERE Marketo_lastMQLdate__c = :now 
                      AND LastName = 'PCS' AND Company='Test'];
            System.assertEquals(l.OwnerId, u.Id);
        Test.stopTest();
    }

    @isTest static void testValuationAssign() {
        Test.startTest();
            DateTime now = DateTime.now();
            Account a = new Account();
            a.Name = 'TEST';

            Contact c = new Contact(LastName='Val', AccountId=a.id);
            c.Inbound_Lead_Record_Type_Master__c = 'CA';
            c.Transaction_Types__c = 'Raise Capital';
            c.Marketo_lastMQLdate__c = now;
            c.valuation_tool_valuation_id_c__c = '10';
            insert c;

            c = [SELECT Id, Owner.UserRole.Name 
                      FROM Contact 
                      WHERE Marketo_lastMQLdate__c = :now 
                      AND LastName = 'Val'];
            System.assertEquals(c.Owner.UserRole.Name, 'AE - Private Companies Team');
        Test.stopTest();
    }




    @isTest static void testMQLChanged() {
            Lead l = new Lead(LastName='Update', Company='Comp');
            DateTime now = DateTime.now();
            l.Inbound_Lead_Record_Type_Visible__c = 'CEO/CFO/President';
            l.Transaction_Types__c = 'Raise Capital';
            l.Marketo_lastMQLdate__c = now;

            insert l;
        Test.startTest();       
            Map<Id, SObject> triggerOldMap = new Map<Id, SObject>();
            triggerOldMap.put(l.id, l);
            System.assertNotEquals(LeadAssignment.mqlFieldChanged(triggerOldMap, l), true);
                      
        Test.stopTest();
    }

    @isTest static void testSelfSignupChanged() {
        Lead l = new Lead(LastName='Update', Company='Comp');
        Date now = Date.today();
        l.Inbound_Lead_Record_Type_Visible__c = 'CEO/CFO/President';
        l.Transaction_Types__c = 'Raise Capital';
        l.Self_Signup_Date__c = now;

        insert l;

        Test.startTest();       
            Map<Id, SObject> triggerOldMap = new Map<Id, SObject>();
            triggerOldMap.put(l.id, l);
            System.assertNotEquals(LeadAssignment.selfSignupFieldChanged(triggerOldMap, l), true);                
        Test.stopTest();
    }
    
    // To increase the test coverage as per AXIAl-1
    @isTest static void tesOwnerIsMOA(){
        Lead objLead = new Lead(LastName='Update', Company='Comp', ownerId = userInfo.getUserId());
        insert objLead;
        // will get TRUE if  of the above lead's-Owner's-UserRole contains MOA, else FALSE
        boolean isMOA = LeadAssignment.ownerIsMOA(objLead);
        system.assertEquals(isMOA, False);
    }
    
    @isTest static void tesMarketoFieldsChanged(){
        Lead objLead = new Lead(LastName='Update', Company='Comp', ownerId = userInfo.getUserId(), Last_RSVP_Date__c = Date.Today().addDays(-1));
        insert objLead;
        //IF Anyof the Count_Last_RSVP_Date__c OR Count_Last_Attended_Date__c OR Count_Last_Webinar_Date__c OR Count_Last_Download_Date__c changed then we will get true..else FALSE
        boolean isMarketoFieldsChanged = LeadAssignment.marketoFieldsChanged(new Map<Id, Lead>{objLead.Id => objLead}, objLead);
        system.assertEquals(isMarketoFieldsChanged, false);
    }
    
    
    @isTest static void testRotateLeadOwner(){
        UserRole objMarketingRole = [Select ParentRoleId, Name, DeveloperName From UserRole Where Name = 'Marketing' limit 1];
        UserRole objAEStartingRole = [Select ParentRoleId, Name, DeveloperName From UserRole Where Name = 'AE - Advisor/Broker Team' limit 1];
        
        Profile objProfile = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        
        // user-1 & user-3 are having Marketing Role and USer-3 has recent Last_Lead_Assigned_Date__c  value AND  User-2 & User-4 having AE-Role and user-4 having recent latest value
        List<User> lstUsersToInsert = new List<User>{new User(UserRoleId = objMarketingRole.Id,   Last_Lead_Assigned_Date__c = DateTime.now().addMinutes(-10), Alias = 'new1', Email='standarduser_new1@testorg.com',  EmailEncodingKey='UTF-8', LastName='User-1', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = objProfile.Id,TimeZoneSidKey='America/Los_Angeles', UserName='user_01@testorg.com'),
                                                      new User(UserRoleId = objAEStartingRole.Id, Last_Lead_Assigned_Date__c = DateTime.now().addMinutes(-6), Alias = 'new2', Email='standarduser_new2@testorg.com',  EmailEncodingKey='UTF-8', LastName='User-2', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = objProfile.Id,TimeZoneSidKey='America/Los_Angeles', UserName='user_02@testorg.com'),
                                                      new User(UserRoleId = objMarketingRole.Id,  Last_Lead_Assigned_Date__c = DateTime.now().addMinutes(-5), Alias = 'new3', Email='standarduser_new3@testorg.com',  EmailEncodingKey='UTF-8', LastName='User-3', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = objProfile.Id,TimeZoneSidKey='America/Los_Angeles', UserName='user_03@testorg.com'),
                                                      new User(UserRoleId = objMarketingRole.Id, Last_Lead_Assigned_Date__c = DateTime.now().addMinutes(-9), Alias = 'new4', Email='standarduser_new4@testorg.com',  EmailEncodingKey='UTF-8', LastName='User-4', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = objProfile.Id,TimeZoneSidKey='America/Los_Angeles', UserName='user_04@testorg.com')};
        insert lstUsersToInsert;
        system.assert(lstUsersToInsert[3].Id != NULL);
        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
           /* Start - Updated By Pankaj Ganwani on 29/JUNE/2015 as per the requirement of AXIAL-2 */
           List<Lead> lstLeadsToInsert = new List<Lead>{new Lead(LastName='New_Update_1', Company='Comp1', ownerId = lstUsersToInsert[0].Id, Marketo_lastMQLdate__c = DateTime.now().addDays(-20), Lead_Rotator_Role_Name__c = 'Marketing'),    // owner -> User-1 (marketing Role)
                                                         new Lead(LastName='New_Update_2', Company='Comp2', ownerId = lstUsersToInsert[1].Id, Marketo_lastMQLdate__c = DateTime.now().addDays(-40), Lead_Rotator_Role_Name__c = 'Marketing'),   // owner -> User-1 (marketing Role), will not consdier on update of this as it's owner Rol contains "AE-"
                                                         new Lead(LastName='New_Update_3', Company='Comp2', ownerId = lstUsersToInsert[2].Id, Marketo_lastMQLdate__c = DateTime.now().addDays(-60), Lead_Rotator_Role_Name__c = 'Marketing'),   // owner -> User-3 (marketing Role), who has recent Last_Lead_Assigned_Date__c 
                                                         new Lead(LastName='New_Update_4', Company='Comp4', ownerId = lstUsersToInsert[3].Id, Marketo_lastMQLdate__c = DateTime.now().addDays(-70), Lead_Rotator_Role_Name__c = 'Marketing')};   // owner -> User-4 (marketing Role), who has 2nd recent Last_Lead_Assigned_Date__c 
            /* Start - Updated By Pankaj Ganwani on 29/JUNE/2015 as per the requirement of AXIAL-2 */
            insert lstLeadsToInsert;
            system.assert(lstLeadsToInsert[3].Id != NULL);
             
            Test.startTest();
            lstLeadsToInsert[0].Marketo_lastMQLdate__c = lstLeadsToInsert[1].Marketo_lastMQLdate__c = lstLeadsToInsert[1].Marketo_lastMQLdate__c = lstLeadsToInsert[2].Marketo_lastMQLdate__c = lstLeadsToInsert[3].Marketo_lastMQLdate__c = DateTime.now().addDays(-10);
            update lstLeadsToInsert; 
            List<Lead> lstUpdatedLeads = [Select Id, UserRole__c, LastName, OwnerId, Marketo_lastMQLdate__c From lead Where Id IN : lstLeadsToInsert order by LastName];
            
            system.assert(lstUpdatedLeads[0].ownerId == lstUsersToInsert[0].Id);          //  changed to User-3. this user has recent Last_Lead_assigned_Date__c and same userRole marketing as per the lead record
            system.assert(lstUpdatedLeads[1].ownerId == lstUsersToInsert[1].Id);           //  No Change, as user-2 ahs the Role that contains "AE-""
            system.assert(lstUpdatedLeads[2].ownerId == lstUsersToInsert[2].Id);           //  remained same as the owner is User-3 and has recent Last_Lead_assigned_Date__c and same userRole marketing as per the lead record

            List<User> lstUpdatedUsers = [Select Id, Last_Lead_Assigned_Date__c From User Where Id IN : lstUsersToInsert order BY Last_Lead_Assigned_Date__c desc NULLS LAST limit 1]; 
            system.assert(lstUpdatedUsers[0].Id == lstUsersToInsert[2].Id );
            Test.stopTest();            
        }
    }
}