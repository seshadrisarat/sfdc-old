/**
 *
 * This class contains unit tests for validating the behavior class on SL_wsdl_EMG_Paragraph_History
 * author Vlad Gumenyuk 
 * date 10/23/2012
 * see https://silverline.jira.com/browse/WP-17
 * Test for class SL_wsdl_EMG_Paragraph_History
 */
@isTest(SeeAllData=true)
private class SL_test_EMG_Paragraph_History
{
	
	private static Deal__c testDeal1 = null;
	private static EMG_Comment__c testEMGComment1 = null;
	private static EMG_Paragraph__c testEMGParagraph1 = null;
	
	private static void init_data()
	{
        RecordType AccRecTypeId = [Select Id,DeveloperName,sObjectType From RecordType where DeveloperName = 'Operating_Company' and sObjectType = 'Account' limit 1];

        Account testAccount = new Account(
          Name='Test Account 003',
          RecordTypeId = AccRecTypeId.Id
        );
        insert testAccount;

        Account testAccount2 = new Account(
          Name='Test 201502 Account 004',
          RecordTypeId = AccRecTypeId.Id
        );
        insert testAccount2;

        RecordType ContRecTypeId = [Select Id,DeveloperName,sObjectType From RecordType where DeveloperName = 'Employee' and sObjectType = 'Contact' limit 1];

        Contact testContact = new Contact(
          AccountId = testAccount.Id
         ,RecordTypeId = ContRecTypeId.Id 
         ,LastName = 'Test Contact Name 2'
         ,Title = 'Principal'
         ,WP_Group__c = 'TMT'
         ,Status__c = 'Active'
         ,Archive_Permission__c = true
         ,User_ID__c = UserInfo.getUserId()
        );
        insert testContact;

        Contact testContact2 = new Contact(
          AccountId = testAccount.Id
         ,RecordTypeId = ContRecTypeId.Id 
         ,LastName = 'Test 201502 Contact Name 3'
         ,Title = 'Principal'
         ,WP_Group__c = 'TMT'
         ,Status__c = 'Active'
         ,Archive_Permission__c = true
//         ,User_ID__c = UserInfo.getUserId()
        );
        insert testContact2;

        testDeal1 = new Deal__c(
             Name = 'Test Deal 0030'
           , Company__c = testAccount2.Id
           , WP_Investment__c = 10
           , WP_Ownership__c = 10
           , Description__c = 'TestDescription'
           , RecordTypeId = [Select r.Id From RecordType r WHERE r.DeveloperName = 'Platform_Deal' AND r.SobjectType = 'Deal__c' LIMIT 1].Id
           , ISOPENSTAGE__c = 1
           , Stage__c = 'Prospect' 
           , Key_Dates_Next_Steps__c = 'Test Key_Dates_Next_Steps 0030'
           , WP_Groups_picklist__c = 'TMT'
           , Is_Energy_Opportunity__c = 'No'
        );
        insert testDeal1;
        
        testEMGParagraph1 = new EMG_Paragraph__c(
            EMG_Paragraph__c = 'Test Paragraph -0010'
          , EMG_Updated_on_behalf_of__c = testContact.Id
          , UNIQUE_KEY__c = '00010001'
          , Deal__c = testDeal1.Id  
        );
        insert testEMGParagraph1;

        testEMGComment1 = new EMG_Comment__c(
            EMG_Comment__c = 'Test Comment -0030'
          , EMG_Updated_on_behalf_of__c = testContact.Id
          , UNIQUE_KEY__c = '00010003'
          , Deal__c = testDeal1.Id  
        );
        insert testEMGComment1;
		
	} 
	
//    static testMethod void test_EMG_Paragraph_History() {
    @isTest(SeeAllData=true)
    static void test_EMG_Paragraph_History()
    {
        RecordType AccRecTypeId = [Select Id,DeveloperName,sObjectType From RecordType where DeveloperName = 'Operating_Company' and sObjectType = 'Account' limit 1];

        // Create dummy account
        Account testAccount = new Account(
          Name='Test 201502 Account 003',
          RecordTypeId = AccRecTypeId.Id
        );
        insert testAccount;

        Account testAccount2 = new Account(
          Name='Test 004 Account 004',
          RecordTypeId = AccRecTypeId.Id
        );
        insert testAccount2;

        RecordType ContRecTypeId = [Select Id,DeveloperName,sObjectType From RecordType where DeveloperName = 'Employee' and sObjectType = 'Contact' limit 1];

        Contact testContact = new Contact(
          AccountId = testAccount.Id
         ,RecordTypeId = ContRecTypeId.Id 
         ,LastName = 'Test Contact Name 2'
         ,Title = 'Principal'
         ,WP_Group__c = 'Test Group'
         ,Status__c = 'Active'
         , User_ID__c = UserInfo.getUserId()
        );
        insert testContact;

        Contact testContact2 = new Contact(
          AccountId = testAccount.Id
         ,RecordTypeId = ContRecTypeId.Id 
         ,LastName = 'Test 201502 Contact Name 3'
         ,Title = 'Principal'
         ,WP_Group__c = 'Test Group'
         ,Status__c = 'Active'
        );
        insert testContact2;

        Deal__c testDeal = new Deal__c(
             Name = 'Test Deal 003'
           , Company__c = testAccount2.Id
           , WP_Investment__c = 10
           , WP_Ownership__c = 10
           , Description__c = 'TestDescription'
           /*, Target_Sectors__c = 'Energy'*/
           , RecordTypeId = [Select r.Id From RecordType r WHERE r.DeveloperName = 'Platform_Deal' AND r.SobjectType = 'Deal__c' LIMIT 1].Id
           , ISOPENSTAGE__c = 1
           , Stage__c = 'Early-Prospect' 
//           , Expense_Code__c ='JAAUY'
           , Is_Energy_Opportunity__c = 'No'
        );
        insert testDeal;
        
        Test.startTest();

// WP-70
/* */
        EMG_Paragraph__c testEMGParagraph = new EMG_Paragraph__c(
            EMG_Paragraph__c = 'Test Paragraph -001'
          , EMG_Updated_on_behalf_of__c = testContact.Id
          , UNIQUE_KEY__c = '00010001'
          , Deal__c = testDeal.Id  
        );
        insert testEMGParagraph;

        EMG_Comment__c testEMGComment = new EMG_Comment__c(
            EMG_Comment__c = 'Test Comment -002'
          , EMG_Updated_on_behalf_of__c = testContact.Id
          , UNIQUE_KEY__c = '00010003'
          , Deal__c = testDeal.Id  
        );
        insert testEMGComment;
/* */
      Test.stopTest();
    }

    @isTest(SeeAllData=true)
    static void test_EMG_Paragraph_History2()
    {
        RecordType AccRecTypeId = [Select Id,DeveloperName,sObjectType From RecordType where DeveloperName = 'Operating_Company' and sObjectType = 'Account' limit 1];

        // Create dummy account
        Account testAccount = new Account(
          Name='Test Account 003',
          RecordTypeId = AccRecTypeId.Id
        );
        insert testAccount;

        Account testAccount2 = new Account(
          Name='Test 201502 Account 004',
          RecordTypeId = AccRecTypeId.Id
        );
        insert testAccount2;

        RecordType ContRecTypeId = [Select Id,DeveloperName,sObjectType From RecordType where DeveloperName = 'Employee' and sObjectType = 'Contact' limit 1];

        Contact testContact = new Contact(
          AccountId = testAccount.Id
         ,RecordTypeId = ContRecTypeId.Id 
         ,LastName = 'Test Contact Name 2'
         ,Title = 'Principal'
         ,Is_Investment_Professional__c = true
         ,WP_Group__c = 'Test Group'
         ,Status__c = 'Active'
         , User_ID__c = UserInfo.getUserId()
        );
        insert testContact;

        Contact testContact2 = new Contact(
          AccountId = testAccount.Id
         ,Is_Investment_Professional__c = true
         ,RecordTypeId = ContRecTypeId.Id 
         ,LastName = 'Test 201502 Contact Name 3'
         ,Title = 'Principal'
         ,WP_Group__c = 'Test Group'
         ,Status__c = 'Active'
        );
        insert testContact2;

        Deal__c testDeal = new Deal__c(
             Name = 'Test Deal 003'
           , Company__c = testAccount2.Id
           , WP_Investment__c = 10
           , WP_Ownership__c = 10
           , Description__c = 'TestDescription'
           /*, Target_Sectors__c = 'Energy'*/
           , RecordTypeId = [Select r.Id From RecordType r WHERE r.DeveloperName = 'Platform_Deal' AND r.SobjectType = 'Deal__c' LIMIT 1].Id
           , ISOPENSTAGE__c = 1
           , Stage__c = 'Early-Prospect' 
//           , Expense_Code__c ='JAAUY'
           , Is_Energy_Opportunity__c = 'No'
        );
        insert testDeal;
        

// WP-70
/* */
        EMG_Paragraph__c testEMGParagraph = new EMG_Paragraph__c(
            EMG_Paragraph__c = 'Test Paragraph -001'
          , EMG_Updated_on_behalf_of__c = testContact.Id
          , UNIQUE_KEY__c = '00010001'
          , Deal__c = testDeal.Id  
        );
        insert testEMGParagraph;

        EMG_Comment__c testEMGComment = new EMG_Comment__c(
            EMG_Comment__c = 'Test Comment -003'
          , EMG_Updated_on_behalf_of__c = testContact.Id
          , UNIQUE_KEY__c = '00010003'
          , Deal__c = testDeal.Id  
        );
        insert testEMGComment;

		Test.startTest();

        testEMGParagraph.EMG_Paragraph__c = 'Test Paragraph -002';
        update testEMGParagraph;

        testEMGComment.EMG_Comment__c = 'Test Comment -004';
        update testEMGComment;

		Test.stopTest();
/* */        
    }    
    
    @isTest(SeeAllData=true)
    static void test_wsdl_EMG()
    {
        RecordType AccRecTypeId = [Select Id,DeveloperName,sObjectType From RecordType where DeveloperName = 'Operating_Company' and sObjectType = 'Account' limit 1];

        // Create dummy account
        Account testAccount = new Account(
          Name='Test Account 003',
          RecordTypeId = AccRecTypeId.Id
        );
        insert testAccount;

        Account testAccount2 = new Account(
          Name='Test 201502 Account 004',
          RecordTypeId = AccRecTypeId.Id
        );
        insert testAccount2;

        RecordType ContRecTypeId = [Select Id,DeveloperName,sObjectType From RecordType where DeveloperName = 'Employee' and sObjectType = 'Contact' limit 1];

        Contact testContact = new Contact(
          AccountId = testAccount.Id
         ,RecordTypeId = ContRecTypeId.Id 
         ,Is_Investment_Professional__c = true
         ,LastName = 'Test Contact Name 2'
         ,Title = 'Principal'
         ,WP_Group__c = 'Test Group'
         ,Status__c = 'Active'
         , User_ID__c = UserInfo.getUserId()
        );
        insert testContact;

        Contact testContact2 = new Contact(
          AccountId = testAccount.Id
         ,RecordTypeId = ContRecTypeId.Id 
         ,Is_Investment_Professional__c = true
         ,LastName = 'Test Contact Name 3'
         ,Title = 'Principal'
         ,WP_Group__c = 'Test Group'
         ,Status__c = 'Active'
        );
        insert testContact2;

        Deal__c testDeal = new Deal__c(
             Name = 'Test Deal 003'
           , Company__c = testAccount2.Id
           , WP_Investment__c = 10
           , WP_Ownership__c = 10
           , Description__c = 'TestDescription'
           /*, Target_Sectors__c = 'Energy'*/
           , RecordTypeId = [Select r.Id From RecordType r WHERE r.DeveloperName = 'Platform_Deal' AND r.SobjectType = 'Deal__c' LIMIT 1].Id
           , ISOPENSTAGE__c = 1
           , Stage__c = 'Early-Prospect' 
           , Expense_Code__c ='JAAUY'
           , SP_UserEmail__c = 'test_user001@gamil.com'
           , WP_Senior_Groups__c = 'TMT'
           , WP_Groups__c = 'TMT'
           , Is_Energy_Opportunity__c = 'No'
        );
        insert testDeal;

// WP-70
/* */
        EMG_Paragraph__c testEMGParagraph = new EMG_Paragraph__c(
            EMG_Paragraph__c = 'Test Paragraph -001'
          , EMG_Updated_on_behalf_of__c = testContact.Id
          , UNIQUE_KEY__c = '00010001'
          , Deal__c = testDeal.Id  
        );
        insert testEMGParagraph;

        testEMGParagraph.EMG_Paragraph__c = 'Test Paragraph -002';

        EMG_Comment__c testEMGComment = new EMG_Comment__c(
            EMG_Comment__c = 'Test Comment -003'
          , EMG_Updated_on_behalf_of__c = testContact.Id
          , UNIQUE_KEY__c = '00010003'
          , Deal__c = testDeal.Id  
        );
        insert testEMGComment;

        testEMGComment.EMG_Comment__c = 'Test Comment -004';

/* */
		Test.startTest();
// WP-70
/* */
        update testEMGParagraph;

        update testEMGComment;
/* */

		// Not necessary part after WP-43
//		testDeal.EMG_Paragraph__c = 'Test EMG_Paragraph';
//		update testDeal;
        
        // TO DO: implement unit test
/////        SL_wsdl_EMG_Paragraph_History.EMG_Paragraph_from_Deal();
         SL_wsdl_EMG.getContact_by_current_User();
         SL_wsdl_EMG.getContactID_by_current_User();
         SL_wsdl_EMG.is_show_EMG_Archive_Page();
         SL_wsdl_EMG.EMG_Comment_from_Deal(String.valueOf(testDeal.Id), '0002');
         SL_wsdl_EMG.EMG_Paragraph_from_Deal(String.valueOf(testDeal.Id), '0003');
         SL_wsdl_EMG.set_Deal_SP_DateTimeReq_to_Now(String.valueOf(testDeal.Id));
         SL_wsdl_EMG.set_Deal_Sharepoint(String.valueOf(testDeal.Id));

      Test.stopTest();
    } 

//    static testMethod void test_EMS_Comment_Archive_Batch() {
    @isTest(SeeAllData=true)
    static void test_EMS_Archive_Batches()
    {  
    	 init_data();
    	 
       Datetime datetime_end_archive = Datetime.now().addDays(-2);
       Datetime datetime_prev_archive = Datetime.now().addDays(-2);
       list<String> wp_groups_str = new list<String>();
       wp_groups_str.add('TMT');
       wp_groups_str.add('Financial Services');
       
       map<String,Datetime> map_wp_group_datetime_prev_archive = new map<String,Datetime>(); 

       for(Integer i = 0; i < wp_groups_str.size(); i++)
         if(!map_wp_group_datetime_prev_archive.containsKey(wp_groups_str[i]))
            map_wp_group_datetime_prev_archive.put(wp_groups_str[i],Datetime.now().addDays(-2));


         list<Archive_Settings__c> list_update_cs_Archive_Settings = new list<Archive_Settings__c>();
         set<String> set_wp_groups = new set<String>(); 
         for(Archive_Settings__c cs_Archive_Settings : Archive_Settings__c.getall().values()) 
         {
            for(Integer i = 0; i < wp_groups_str.size(); i++)
               if(cs_Archive_Settings.Name == wp_groups_str[i]) 
               {
                  if(datetime_end_archive > map_wp_group_datetime_prev_archive.get(wp_groups_str[i]) ) {            
                     cs_Archive_Settings.EMG_Comment__c = datetime_end_archive;
                     cs_Archive_Settings.EMG_Paragraph__c = datetime_end_archive;
                     cs_Archive_Settings.Key_Dates_Next_Steps__c = datetime_end_archive;
                  }   
                  set_wp_groups.add(wp_groups_str[i]);
                  list_update_cs_Archive_Settings.add(cs_Archive_Settings);   
               }      
         }

         for(Integer i = 0; i < wp_groups_str.size(); i++)
            if(!set_wp_groups.contains(wp_groups_str[i]))
               list_update_cs_Archive_Settings.add(
                 new Archive_Settings__c(
                  Name = wp_groups_str[i]
                  ,EMG_Comment__c = datetime_end_archive
                  ,EMG_Paragraph__c = datetime_end_archive
                  ,Key_Dates_Next_Steps__c = datetime_end_archive
                 )
               );

         if(list_update_cs_Archive_Settings.size()>0) upsert list_update_cs_Archive_Settings;
         
         datetime_end_archive = Datetime.now();
    	
       Test.startTest();

         list<String> emg_param_is_run = new list<String>();  
            emg_param_is_run.add('SL_EMS_Paragraph_Archive_Batch');
            emg_param_is_run.add('SL_EMS_Comment_Archive_Batch');
            emg_param_is_run.add('SL_Key_Dates_Next_Steps_Archive_Batch');
            
         for(String emg_param_str : emg_param_is_run) {
            if(emg_param_str == 'SL_EMS_Paragraph_Archive_Batch') {
               SL_EMS_Paragraph_Archive_Batch epab = new SL_EMS_Paragraph_Archive_Batch(wp_groups_str,datetime_end_archive, emg_param_is_run);
               Database.executebatch(epab,500);
            }
            if(emg_param_str == 'SL_EMS_Comment_Archive_Batch') {
               SL_EMS_Comment_Archive_Batch ecab = new SL_EMS_Comment_Archive_Batch(wp_groups_str,datetime_end_archive, emg_param_is_run);
               Database.executebatch(ecab,500);            	
            }
            if(emg_param_str == 'SL_Key_Dates_Next_Steps_Archive_Batch') {
               SL_Key_Dates_Next_Steps_Archive_Batch kdnsab = new SL_Key_Dates_Next_Steps_Archive_Batch(wp_groups_str,datetime_end_archive, emg_param_is_run);
               Database.executebatch(kdnsab,500);
            }
            break;   
         }   
       
//         SL_EMS_Comment_Archive_Batch ecab = new SL_EMS_Comment_Archive_Batch(wp_groups_str,datetime_end_archive);
//         Database.executebatch(ecab,500);

//         SL_EMS_Paragraph_Archive_Batch epab = new SL_EMS_Paragraph_Archive_Batch(wp_groups_str,datetime_end_archive);
//         Database.executebatch(epab,500);
         
//         SL_Key_Dates_Next_Steps_Archive_Batch kdnsab = new SL_Key_Dates_Next_Steps_Archive_Batch(wp_groups_str,datetime_end_archive);
//         Database.executebatch(kdnsab,500);

       Test.stopTest();
    	
    }
    
    
//    @isTest(SeeAllData=true)
    @isTest
    static void test_EMS_Archive_Controller()
    {  
       init_data();
       
       Datetime datetime_end_archive = Datetime.now().addDays(-2);
       Datetime datetime_prev_archive = Datetime.now().addDays(-2);
       list<String> wp_groups_str = new list<String>();
       wp_groups_str.add('TMT');
       wp_groups_str.add('Financial Services');
       
       map<String,Datetime> map_wp_group_datetime_prev_archive = new map<String,Datetime>(); 

       for(Integer i = 0; i < wp_groups_str.size(); i++)
         if(!map_wp_group_datetime_prev_archive.containsKey(wp_groups_str[i]))
            map_wp_group_datetime_prev_archive.put(wp_groups_str[i],Datetime.now().addDays(-2));


         list<Archive_Settings__c> list_update_cs_Archive_Settings = new list<Archive_Settings__c>();
         set<String> set_wp_groups = new set<String>(); 
         for(Archive_Settings__c cs_Archive_Settings : Archive_Settings__c.getall().values()) 
         {
            for(Integer i = 0; i < wp_groups_str.size(); i++)
               if(cs_Archive_Settings.Name == wp_groups_str[i]) 
               {
                  if(datetime_end_archive > map_wp_group_datetime_prev_archive.get(wp_groups_str[i]) ) {            
                     cs_Archive_Settings.EMG_Comment__c = datetime_end_archive;
                     cs_Archive_Settings.EMG_Paragraph__c = datetime_end_archive;
                     cs_Archive_Settings.Key_Dates_Next_Steps__c = datetime_end_archive;
                  }   
                  set_wp_groups.add(wp_groups_str[i]);
                  list_update_cs_Archive_Settings.add(cs_Archive_Settings);   
               }      
         }

         for(Integer i = 0; i < wp_groups_str.size(); i++)
            if(!set_wp_groups.contains(wp_groups_str[i]))
               list_update_cs_Archive_Settings.add(
                 new Archive_Settings__c(
                  Name = wp_groups_str[i]
                  ,EMG_Comment__c = datetime_end_archive
                  ,EMG_Paragraph__c = datetime_end_archive
                  ,Key_Dates_Next_Steps__c = datetime_end_archive
                 )
               );

         if(list_update_cs_Archive_Settings.size()>0) upsert list_update_cs_Archive_Settings;
         
         datetime_end_archive = Datetime.now();
      
       Test.startTest();
       
         SL_ctrl_EMG_Archive scea = new SL_ctrl_EMG_Archive();

         scea.note_emg_comment = true;
         scea.note_emg_paragraph = true;
         scea.note_key_dates_next_steps = true;
         scea.isProcessRun = true;
         scea.end_datetime = String.valueOf(Datetime.now());
         scea.BaseParam = new SL_ctrl_LIB20_BaseParam();
         scea.BaseParam.sHiddenKeys = 'TMT;Financial Services';
         //User curUser = [SELECT u.id,u.Profile.Name, u.ProfileId, u.Name FROM User u WHERE u.ID = :UserInfo.getUserId() Limit 1];

         scea.getBaseParam();
         scea.RunArchiveProcess();

         scea.ArchiveProgressRun();
         scea.getArchiveProgress();
         scea.getProcessRun();
         
         scea.getSel_values();
         scea.getNew_EMG_Comment_History();
         scea.getNew_EMG_Paragraph_History();
         scea.getNew_Key_Dates_Next_Steps_History();
         Integer iv = scea.pageSize_Key_Dates_Next_Steps_History;
         iv = scea.pageSize_EMG_Comment_History;
         iv = scea.pageSize_EMG_Paragraph_History;
         
         scea.getnote_emg_comment1();
         scea.getnote_key_dates_next_steps1();
         scea.getnote_emg_paragraph1();
         scea.getend_date();
         scea.getend_datetime();
         scea.getIs_show_EMG_Archive_Page();
         scea.getError_Style();
         scea.getForm_Style();
         scea.getOneWPGroup();
         scea.getForm_one_WP_Group();
         scea.getForm_many_WP_Groups();

       Test.stopTest();
      
    }
      
}