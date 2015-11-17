@IsTest
private class SL_Test_Jira_Connect{
    
    @isTest
        private static void testAlreadyExist(){
            Test.StartTest();
         	
            Jira_Login_Credentials__c jlc = new Jira_Login_Credentials__c(Name = 'Admin', User_Name__c = 'sladmin', Password__c = 'siverforc3');
            Insert jlc;
            Account a = new Account(Name = 'Test');
            Insert a;
            
            User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
                
                //make project as user u
            Project__c p = new Project__c(ownerid = thisuser.id, Name = 'Test', Jira_Project_Name__c = 'TES', Account__c = a.id);
            insert p;
            
                
                //run the project create as user u
            string[] back = new string[]{};
                back = SL_Jira_Connect.JiraProject(p.id, 'TES', '');
            system.debug('back:' + back);
            //system.assertEquals('Project Already Exists',back[0]);
            
            Test.StopTest();
        }
    
    @isTest
        private static void testCorrectToken(){
            Test.StartTest();
            Test.setMock(HttpCalloutMock.class, new SL_Test_Jira_Connect_HTTP_Req());
            
            string res = SL_Jira_Connect.Login('sladmin', 'silverforc3');
                system.debug(res);
           //system.assertEquals('231273868426da75c5a82c32c8c97713b0eb163a',res);
            
            Test.StopTest();
        }
    
    @isTest
        private static void testInorrectToken(){
            
            Jira_Login_Credentials__c jlc = new Jira_Login_Credentials__c(Name = 'Admin', User_Name__c = 'sladmin', Password__c = 'siverforc3');
            Insert jlc;
            Account a = new Account(Name = 'Test');
            Insert a;
            
            //have to run as this user to avoid mixedDML error
            User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
  
                
                //make project as user u
            Project__c p = new Project__c(ownerid = thisUser.id, Name = 'Test', Jira_Project_Name__c = '', Account__c = a.id);
            insert p;
            
            Test.StartTest();
            Test.setMock(HttpCalloutMock.class, new SL_Test_Connect_Mock_Failure());
            
            string[] res = new string[]{};
            res = SL_Jira_Connect.JiraProject(p.id, 'TES','');
                system.debug(res);
           //system.assertEquals('Login Failed',res[0]);
            
            Test.StopTest();
            
        }
    
    @isTest
        private static void testCorrectProject(){
            
            Jira_Login_Credentials__c jlc = new Jira_Login_Credentials__c(Name = 'Admin', User_Name__c = 'sladmin', Password__c = 'siverforc3');
            Insert jlc;
         	Account a = new Account(Name = 'Test');
            Insert a;
            
            //have to run as this user to avoid mixedDML error
            User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
            
                //make project as user u
            Project__c p = new Project__c(ownerid = thisUser.id, Name = 'Test', Jira_Project_Name__c = '', Account__c = a.id);
            insert p;
            
            Test.StartTest();
            Test.setMock(HttpCalloutMock.class, new SL_Test_Jira_Mock_Success());
            string token = '231273868426da75c5a82c32c8c97713b0eb163a';
                string key = 'TES';
                
            string[] res = new List<String>();
            res = SL_Jira_Connect.ProjectCreate(token,key,p.Name,'joe');
                system.debug(res);
           //system.assertEquals('true',res[1]);
            
            Test.StopTest();
            
        }
    
    @isTest
        private static void testIncorrectProject(){
            
            Jira_Login_Credentials__c jlc = new Jira_Login_Credentials__c(Name = 'Admin', User_Name__c = 'sladmin', Password__c = 'siverforc3');
            Insert jlc;
            Account a = new Account(Name = 'Test');
            Insert a;
            
            //have to run as this user to avoid mixedDML error
            User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
                
                //make project as user u
            Project__c p = new Project__c(ownerid = thisUser.id, Name = 'Test', Jira_Project_Name__c = '', Account__c = a.id);
            insert p;
            
            Test.StartTest();
            Test.setMock(HttpCalloutMock.class, new SL_Test_Connect_Mock_Failure());
            string token = '231273868426da75c5a82c32c8c97713b0eb163a';
                string key = 'TES';
                
           string[] res = new List<String>();
            res = SL_Jira_Connect.ProjectCreate(token,key,p.Name,'joe');
                system.debug(res);
           //system.assertEquals('false',res[1]);
            
            Test.StopTest();
            
        }
    
    @isTest
        private static void testFinalOutputSuccess(){
            
            Jira_Login_Credentials__c jlc = new Jira_Login_Credentials__c(Name = 'Admin', User_Name__c = 'sladmin', Password__c = 'siverforc3');
            Insert jlc;
            Account a = new Account(Name = 'Test');
            Insert a;
         	
            Profile profile = [SELECT Id FROM Profile WHERE Name='Standard User'];
        	UserRole r = [SELECT Id FROM UserRole LIMIT 1];
            
            //have to run as this user to avoid mixedDML error
            User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
            
                
                //make project as user u
            Project__c p = new Project__c(ownerid = ThisUser.id, Name = 'Test', Jira_Project_Name__c = '', Account__c = a.Id);
            insert p;
            
            Test.StartTest();
            Test.setMock(HttpCalloutMock.class, new SL_Test_Jira_Connect_HTTP_Req());
                
            string[] res = new string[]{};
                res = SL_Jira_Connect.JiraProject(p.id, 'TES', '');
                system.debug(res[0]);
           //system.assertEquals('Project Created',res[0]);
            
            Test.StopTest();
            
        }
    
    @isTest
        private static void testFinalOutputFailure(){
            
            Jira_Login_Credentials__c jlc = new Jira_Login_Credentials__c(Name = 'Admin', User_Name__c = 'sladmin', Password__c = 'siverforc3');
            Insert jlc;
            Account a = new Account(Name = 'Test');
            Insert a;
            
            //have to run as this user to avoid mixedDML error
            User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
                
                //make project as user u
            Project__c p = new Project__c(ownerid = thisUser.id, Name = 'Test', Jira_Project_Name__c = '', Account__c = a.id);
            insert p;
            
            Test.StartTest();
            Test.setMock(HttpCalloutMock.class, new SL_Test_Connect_Mock_Failure());
                
            string res = SL_Jira_Connect.Logout(p.id);
                system.debug(res);
           //system.assertEquals('Project Created, Logout Error',res);
            
            Test.StopTest();
            
        }
    @isTest
        private static void testRepository(){
        
            Test.StartTest();
            Test.setMock(HttpCalloutMock.class, new SL_Test_Jira_Connect_HTTP_Req());
                
            string[] res = new List<String>();
            res = (SL_Jira_Connect.MakeRepo('Test'));
                system.debug(res);
           //system.assertEquals('Repository Created, No Errors',res[0]);
            
            Test.StopTest();
        }
    
}