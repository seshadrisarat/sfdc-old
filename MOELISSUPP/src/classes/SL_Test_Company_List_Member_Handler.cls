@IsTest 
public class SL_Test_Company_List_Member_Handler{
    @IsTest
    private static void TestAll()
    {
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ps = [select id, name from Profile where name = 
                            'Standard User' or name = 'System Administrator'];
        
        for(Profile p : ps){
            profiles.put(p.name, p.id);
        }
        List<User> users = new List<User>();
        User adminUser = new User(alias = 'standt', 
                                  email='standarduser@testorg.com', 
                                  emailencodingkey='UTF-8', 
                                  lastname='Testing', languagelocalekey='en_US',
                                  localesidkey='en_US', 
                                  profileid = profiles.get('System Administrator'), 
                                  timezonesidkey='America/Los_Angeles', 
                                  username='thisisnotatakennameright@aol.com');
        
        User standUser = new User(alias = 'standt', 
                                  email='standarduser2@testorg.com', 
                                  emailencodingkey='UTF-8', 
                                  lastname='Testing', languagelocalekey='en_US', 
                                  localesidkey='en_US', 
                                  profileid = profiles.get('System Administrator'), 
                                  timezonesidkey='America/Los_Angeles', 
                                  username='thisisnotatakenname@aol.com');
        users.add(adminUser);
        users.add(standUser);
        insert users;
        
        List<Employee_Profile__c> employees = new List<Employee_Profile__c>();
        Employee_Profile__c empl = new Employee_Profile__c(Name='Admin', First_Name__c = 'Schmoe', Last_Name__c = 'Test', Title__c = 'Title', 
                                                           Business_Type__c = 'Advisory', Group__c = 'Group', Status__c = 'Active', 
                                                           Office_Location__c = 'Boston', User_Id__c = adminUser.id);
        Employee_Profile__c empl2 = new Employee_Profile__c(Name='Standard', First_Name__c = 'Schmoe', Last_Name__c = 'Test', Title__c = 'Title', 
                                                            Business_Type__c = 'Advisory', Group__c = 'Group', Status__c = 'Active', 
                                                            Office_Location__c = 'Boston', User_Id__c = standUser.id);
        employees.add(empl);
        employees.add(empl2);
        insert employees;
        
        List<Company_List__c> lstCL = new List<Company_List__c>();
        Company_List__c cl = new Company_List__c(Name = 'Test', Banker_Name__c = empl.id);
        Company_List__c cl2 = new Company_List__c(Name = 'Test1', Banker_Name__c = empl2.id);
        lstCL.add(cl);
        lstCL.add(cl2);
        
        //Ensure the normal insert works.
        insert lstCL;
        
        Account testAccount = new Account(Name='test Account');
        insert testAccount;
        
        Account testAccount1 = new Account(Name='test Account1');
        insert testAccount1;
        
        Id clmRecTypeId = [select Id from RecordType where SobjectType = 'Company_List_Member__c' LIMIT 1].Id;
        
        List <Company_List_Member__c> lstCompanyListMember = new List<Company_List_Member__c>();
        
        
        Company_List_Member__c clm = new Company_List_Member__c(Company_List__c = cl.Id,
                                                                Company__c = testAccount.Id,
                                                                Company_Category__c='3 - Small Cap',
                                                                Company_Relationship_Strength__c='3-Star',
                                                                RecordTypeId = clmRecTypeId);
        
        Company_List_Member__c clm1 = new Company_List_Member__c(Company_List__c = cl.Id,
                                                                Company__c = testAccount.Id,
                                                                Company_Category__c='6 - Private Funds Advisory',
                                                                Company_Relationship_Strength__c='3-Star',
                                                                RecordTypeId = clmRecTypeId);
        lstCompanyListMember.add(clm1);                                                        
        Company_List_Member__c clm2 = new Company_List_Member__c(Company_List__c = cl2.Id,
                                                                Company__c = testAccount1.Id,
                                                                Company_Category__c='6 - Private Funds Advisory',
                                                                Company_Relationship_Strength__c='3-Star',
                                                                RecordTypeId = clmRecTypeId);
        lstCompanyListMember.add(clm2);
                                                                
        Company_List_Member__c clm3 = new Company_List_Member__c(Company_List__c = cl2.Id,
                                                                Company__c = testAccount1.Id,
                                                                Company_Category__c='6 - Private Funds Advisory',
                                                                Company_Relationship_Strength__c='3-Star',
                                                                RecordTypeId = clmRecTypeId);
        lstCompanyListMember.add(clm3);                                                        
        Test.startTest();
        insert clm;
        
        insert lstCompanyListMember;
        
        clm = [SELECT Banker__c,Company_List__r.Banker_Name__c FROM Company_List_Member__c WHERE ID = :clm.id LIMIT 1];
        System.assertEquals(clm.Banker__c, empl.id);
        
        clm3.Company__c = testAccount.Id;
        update clm3;
        
        delete clm3;
        
        undelete clm3;
        
        List<Company_List_Member__c> lstCLM1 = [SELECT Company__c FROM Company_List_Member__c WHERE Company__c = :testAccount1.Id];
        
        System.assertEquals(lstCLM1.size(),1);
         
        cl.Banker_Name__c = empl2.id;
        update cl;
        
        clm = [SELECT Banker__c,Company_List__r.Banker_Name__c FROM Company_List_Member__c WHERE ID = :clm.id LIMIT 1];
        System.assertEquals(clm.Banker__c, empl2.id);
        Test.stopTest();
    }
}