@IsTest 
private class SL_Test_Company_List_Handler
{
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
        Company_List__c cl2 = new Company_List__c(Name = 'Test', Banker_Name__c = empl2.id);
        lstCL.add(cl);
        lstCL.add(cl2);
        
        Test.StartTest();
        //Ensure the normal insert works.
        insert lstCL;
        Map<Id,Company_List__c> clMap = new Map<Id,Company_List__c>([SELECT Id, OwnerId,Banker_Name__r.User_Id__c FROM Company_List__c]);
        for(Id clId: clMap.keySet())
        {
            system.assertEquals(clMap.get(clId).OwnerId, clMap.get(clId).Banker_Name__r.User_Id__c);
        }
        
        // Change the banker and update.
        cl.Banker_Name__c = empl2.id;
        update cl;
        Map<Id,Company_List__c> clMap2 = new Map<Id,Company_List__c>([SELECT Id, OwnerId,Banker_Name__r.User_Id__c FROM Company_List__c WHERE Id=:cl.Id]);
        system.AssertEquals(clMap2.get(cl.Id).OwnerId,standUser.id);
        
        //change something else and not the banker and update.
        cl2.Type__c ='Something';
        update cl2;
        system.AssertEquals(clMap.get(cl2.Id).OwnerId,standUser.id);
        Test.stopTest();       
    }
}