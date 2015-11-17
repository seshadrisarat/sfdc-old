@IsTest
private class SL_Test_Jira_Connect_Key_Create{
    
    @IsTest
    private static void testNotFound(){
        SL_Jira_Connect_Key_Create kc = new SL_Jira_Connect_Key_Create();
        string key1 = kc.MakeKey('apex');
        string key2 = kc.MakeKey('apex project');
        system.assertequals(key1,'APE');
        system.assertequals(key2,'AP');
        
    }
    
    @IsTest
    private static void testIsFound(){
    	SL_Jira_Connect_Key_Create kc = new SL_Jira_Connect_Key_Create();
        datetime T = datetime.Now();
        Project__c p = new Project__c(Name = 'Argh', Jira_Project_Name__c = 'AP', Estimated_Start_Date__c = T.date());
        insert p;
        string key2 = kc.MakeKey('apex project');
        system.assertequals(key2,'APII');
        
    }
    
    @IsTest
    private static void testIsLarge(){
        datetime T = datetime.Now();
    	SL_Jira_Connect_Key_Create kc = new SL_Jira_Connect_Key_Create();
        Project__c p1 = new Project__c(Name = 'Argh', Jira_Project_Name__c = 'AP', Estimated_Start_Date__c = T.date());
        insert p1;
        
        Project__c p2 = new Project__c(Name = 'Argh', Jira_Project_Name__c = 'APII', Estimated_Start_Date__c = T.date());
        insert p2;
        
        Project__c p3 = new Project__c(Name = 'Argh', Jira_Project_Name__c = 'APIII', Estimated_Start_Date__c = T.date());
        insert p3;
        
        Project__c p4 = new Project__c(Name = 'Argh', Jira_Project_Name__c = 'APIV', Estimated_Start_Date__c = T.date());
        insert p4;
        
        Project__c p5 = new Project__c(Name = 'Argh', Jira_Project_Name__c = 'APV', Estimated_Start_Date__c = T.date());
        insert p5;
        
        Project__c p6 = new Project__c(Name = 'Argh', Jira_Project_Name__c = 'APVI', Estimated_Start_Date__c = T.date());
        insert p6;
        
        Project__c p7 = new Project__c(Name = 'Argh', Jira_Project_Name__c = 'APVII', Estimated_Start_Date__c = T.date());
        insert p7;
        
        Project__c p8 = new Project__c(Name = 'Argh', Jira_Project_Name__c = 'APVIII', Estimated_Start_Date__c = T.date());
        insert p8;
        
        Project__c p9 = new Project__c(Name = 'Argh', Jira_Project_Name__c = 'APIX', Estimated_Start_Date__c = T.date());
        insert p9;
        
        
        string key2 = kc.MakeKey('apex project');
        system.assertequals(key2,'APX');
    }

}