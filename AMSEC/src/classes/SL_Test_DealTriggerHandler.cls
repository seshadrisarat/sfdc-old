@isTest
private class SL_Test_DealTriggerHandler {
    
    static List<Account> lstAccount;
    static List<Contact> lstcontacts;
    static List<Deal__c> lstDeals;
    static List<External_Working_Group_Member__c> lstWGMembers;
    static Id recTypePortFolioID;
    static Id recTypeActiveDealID;

    /*
        * MethodName : setup()
        * Param      : 
        * Description: Generic method to create Custom setting record...
    */
    @testSetup static void setup() {
        // inserting the custom setting values..
        List<Status_Buckets__c> lstStatusBuckets = new List<Status_Buckets__c>{new Status_Buckets__c(Name = 'Active-1', Am_Sec_Status__c = 'Bid/Active'),
                                                                                new Status_Buckets__c(Name = 'Active-2', Am_Sec_Status__c = 'Idea')};
        insert lstStatusBuckets;
    } 
/*
    // Method to create Data
    private static void createData()
    {
        List<RecordType> recTypeActiveDeal = [SELECT ID FROM RecordType where Name ='Active Process' limit 1];
        if(recTypeActiveDeal.size()>0)
        {
            recTypeActiveDealID = recTypeActiveDeal[0].ID;
        }
        List<RecordType> recTypePortFolio = [SELECT ID FROM RecordType where Name =:'Portfolio Company' limit 1];
        if(recTypePortFolio.size()>0)
        {
            recTypePortFolioID = recTypePortFolio[0].ID; 
        }
        lstAccount = new List<Account>{ 
            new Account(Name = 'TestAcc-01'),new Account(Name = 'TestAcc-02',RecordTypeID=recTypeActiveDealID)
        };            
        insert lstAccount;
        
        lstcontacts = new List<Contact>{
            new Contact(LastName = 'Test Contact', AccountId = lstAccount[0].Id)
        
        };
        insert lstcontacts;
        
        lstDeals = new List<Deal__c>{
            new Deal__c(Box_ID__c = '12323',AS_Team_Rollup__c = 'New, Test',  Name='testDeal',   Salesforce_Company__c =lstAccount[0].ID,  Deal_Status__c='Bid/Active',Deal_Process__c = 'Auction;Limited Auction;',Close_Date__c = Date.today()),
            new Deal__c(Box_ID__c = '123121',AS_Team_Rollup__c = 'New, Hello',  Name='testDeal2', Salesforce_Company__c =lstAccount[1].ID,  Deal_Status__c='Bid/Active',  Deal_Process__c = 'Auction;',  Close_Date__c = Date.today().addDays(2)),
            new Deal__c(Box_ID__c = '11111',AS_Team_Rollup__c = 'New, Latest', Name='testDeal3', Salesforce_Company__c = lstAccount[0].id, Deal_Status__c ='Bid/Active', Deal_Process__c ='Auction;Limited Auction;Exclusive',Close_Date__c = Date.today().addDays(1))};
        insert lstDeals;
        
        lstWGMembers = new List<External_Working_Group_Member__c>{
            new External_Working_Group_Member__c(Deal__c = lstDeals[2].Id,End_Date__c = Date.Today(),Contact__c = lstcontacts[0].Id )
        };
        
        insert lstWGMembers;

    }
    
    @isTest static void test_method_one() {
        createData();
        lstDeals[0].Box_ID__c = lstDeals[1].Box_ID__c = NULL;
        lstDeals[0].Deal_Status__c = 'Dead';
        lstDeals[1].Deal_Status__c = 'Dead';
        update lstDeals;
        List<Account> checkAcc = [SELECT ID,RecordTypeID FROM Account where ID =: lstAccount[1].ID];
        System.assert(checkAcc[0].RecordTypeID != NULL);
    }
    
    //test data for checking negative usecase
    @isTest static void test_DealCloseNegative() {
        createData();
        lstDeals = new List<Deal__c>{
                        new Deal__c(Salesforce_Company__c = lstAccount[1].id, Box_ID__c = '11111', Deal_Status__c = 'Bid/Active',Deal_Process__c ='Auction;Limited Auction;Exclusive',Close_Date__c = Date.today().addDays(2))};
        insert lstDeals;
        
        Test.startTest(); 
        lstDeals[0].Box_ID__c = NULL;    
        lstDeals[0].Deal_Status__c = 'Open';
        lstDeals[0].Deal_Process__c = 'Auction;Limited Auction';
        update lstDeals;
        
        List<Account> checkAcc = [SELECT ID,RecordTypeID FROM Account where ID =: lstAccount[1].ID];
        System.assertEquals(checkAcc[0].RecordTypeID,recTypeActiveDealID);
        Test.stopTest();
     }
    
    
    //test data for creating WGMember records
    @isTest static void test_DealClosePositive() {
        createData();
        lstDeals[0].Box_ID__c = lstDeals[1].Box_ID__c = NULL;
        lstDeals[2].Deal_Status__c = 'Closed';
        update lstDeals;
    }
    
    // As per AMSEC-334 and AMSEC-340
    @isTest static void rollUpToCompany() {
        createData();
        // After Inerting the Deal records with their AS_Team_Rollup__c value the related Account field values will be as below..
        List<Account> lstAccRetrieved = [Select Id, Inv_Opp_Team__c From Account Where Id IN : lstAccount];
        // only "TestAcc-02"'s 'Inv_Opp_Team__c' field will be cahnged and "TestAcc-01" will not becoz not belongs to with "Portfolio" OR 'Active Process' recordType 
        system.assertEquals(lstAccRetrieved[0].Inv_Opp_Team__c, NULL);
        system.assertEquals(lstAccRetrieved[1].Inv_Opp_Team__c, 'New,Hello');

        Test.startTest();

        // Updating the Account Recort Type of "TestAcc-01"
        lstAccRetrieved[0].RecordTypeId = recTypePortFolioID;
        update lstAccRetrieved[0];
        
        lstDeals[0].Box_ID__c = lstDeals[1].Box_ID__c = lstDeals[2].Box_ID__c = NULL;
        // updating the Deal records 
        lstDeals[2].AS_Team_Rollup__c = 'Latest';
        update lstDeals;
        //checiking the TestAcc-01's 'Inv_Opp_Team__c' field value 
        system.assertEquals([Select Id, Inv_Opp_Team__c From Account Where Id =: lstAccRetrieved[0].Id].Inv_Opp_Team__c, 'Latest,New,Test');
        
        // Checking when updating the Salesforce_Company__c lookup field...i.e changing the company from TestAcc-01 to TestAcc-02 on "Deal-3"
        lstAccRetrieved = [Select Id, Inv_Opp_Team__c From Account Where Id IN : lstAccRetrieved];
        system.assertEquals(lstAccRetrieved[0].Inv_Opp_Team__c, 'Latest,New,Test');  // TestAcc-01
        system.assertEquals(lstAccRetrieved[1].Inv_Opp_Team__c, 'New,Hello');       // TestAcc-02 
        lstDeals[2].Salesforce_Company__c = lstAccRetrieved[1].Id;
        update lstDeals[2];
        Test.stopTest();
        lstAccRetrieved = [Select Id, Inv_Opp_Team__c From Account Where Id IN : lstAccRetrieved];
        system.assertEquals(lstAccRetrieved[0].Inv_Opp_Team__c, 'New,Test');  // TestAcc-01
        system.assertEquals(lstAccRetrieved[1].Inv_Opp_Team__c, 'Latest,New,Hello');       // TestAcc-02 

        // After deleing all the Deal records...the Inv_Opp_Team__c will be null on both the Account records.
        delete lstDeals;
        system.assertEquals([Select Id, Inv_Opp_Team__c From Account Where Id IN : lstAccRetrieved][0].Inv_Opp_Team__c , NULL);
        
    }
    

    // As per AMSEC-318, 328, 344
    @isTest static void createFolders() {
        Account objAcc = new Account(Name = 'TestAcc-00');
        insert objAcc;

        // Inserting a single deal record.. so trigger will get called...
        Deal__c objDeal = new Deal__c(Salesforce_Company__c = objAcc.Id,Deal_Status__c = 'Bid/Active', Name='testDeal-000', Process_Status__c = 'Open');

        Test.startTest();
        // Inserting a single Deal Record...
        insert objDeal;

        Delete objDeal;

        Test.stopTest();
    }

    @isTest static void createFolders_1()
    {
        Account objAcc = new Account(Name = 'TestAcc-00');
        insert objAcc;
        Test.startTest();
        // Inserting a list of deal records.. so Batch will get fired...
        List<Deal__c> lstDealsToInsert = new List<Deal__c>{
            new Deal__c(Name='testDeal-001', Salesforce_Company__c = objAcc.ID,  Deal_Status__c = 'Bid/Active', Close_Date__c = Date.today()),
            new Deal__c(Name='testDeal-002', Salesforce_Company__c = objAcc.ID,  Deal_Status__c = 'Bid/Active', Close_Date__c = Date.today().addDays(2)),
            new Deal__c(Name='testDeal-003', Salesforce_Company__c = objAcc.ID,  Deal_Status__c = 'Bid/Active', Close_Date__c = Date.today().addDays(1))};

        // Inserting the updated list of records...
        insert lstDealsToInsert; 
        Test.stopTest();  
    }

    @isTest static void createFolders_2()
    {
        Account objAcc = new Account(Name = 'TestAcc-00');
        insert objAcc;
        Test.startTest();
        // Inserting a list of deal records.. so Batch will get fired...Where Company.Alt_Box_Folder_Name__c != NULL
        List<Deal__c> lstDealsToInsertLatest = new List<Deal__c>{
            new Deal__c(Name='testDeal-004',   Salesforce_Company__c =objAcc.ID,  Deal_Status__c = 'Bid/Active', Close_Date__c = Date.today()),
            new Deal__c(Name='testDeal-005', Salesforce_Company__c =objAcc.ID,   Deal_Status__c = 'Bid/Active', Close_Date__c = Date.today().addDays(2)),
            new Deal__c(Name='testDeal-006', Salesforce_Company__c = objAcc.ID,  Deal_Status__c = 'Bid/Active', Close_Date__c = Date.today().addDays(1))};

        // Inserting the updated list of records...
        insert lstDealsToInsertLatest; 
        Test.stopTest();  
    }

    @isTest static void UpdateFolders() {
        Account objAcc = new Account(Name = 'TestAcc-00');
        insert objAcc;

        // Inserting a single deal record.. so trigger will get called...
        Deal__c objDeal = new Deal__c(Box_ID__c = '2123', Salesforce_Company__c = objAcc.Id, Name='testDeal-000', Process_Status__c = 'Open', Deal_Status__c = 'Bid/Active');
        // Inserting a single Deal Record...
        insert objDeal;
        
        Test.startTest();
        objAcc.Alt_Box_Folder_Name__c = 'NEW';
        update objAcc;

        // Updating the Deal.Salesforce_Company to NULL, then folderName will be the Deal Name only..
        objDeal.Salesforce_Company__c = NULL;
        update objDeal;

        Test.stopTest();
    }
*/
    @isTest static void testBatch() {
        Account objAcc = new Account(Name = 'TestAcc-00');
        insert objAcc;

        // Inserting a single deal record.. so trigger will get called...
        Deal__c objDeal = new Deal__c(Box_ID__c = '2123', Salesforce_Company__c = objAcc.Id, Name='testDeal-000', Process_Status__c = 'Open', Deal_Status__c = 'Bid/Active');
        // Inserting a single Deal Record...
        insert objDeal;


        Map<Id,boolean> mapOfDealIdToStausChanged = new Map<Id, boolean>{objDeal.Id => true };
        Map<Id,String> folderNameMap = new Map<Id, String>{ objDeal.Id => 'testDeal-00011'};

        Test.startTest();
        
        SL_BoxAPI handler = new SL_BoxAPI();
        handler.checkAuthentication();
        SL_BoxBatch objBoxBatch = new SL_BoxBatch('createFolder', folderNameMap, mapOfDealIdToStausChanged,null);
        // Database.executeBatch(objBoxBatch, 1);
        
        Test.stopTest();
    }


 }