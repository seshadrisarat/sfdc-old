@isTest
private class SL_GiftControllerTest {

    //GREG - should be broken up into separate methods that verify discrete parts of functionality  and should use test.startTest() and test.stopTest()
    static testMethod void testGiftLogController() {

        /**************************************
        * Create some test data
        ***************************************/
        
        // Create some contacts to attach gifts
        List<Account> accounts = new List<Account>();
        Account a1 = new Account(Name = 'ABC Company', AccountNumber = '123456');
        accounts.add(a1);
        Account a2 = new Account(Name = 'DEF Company', AccountNumber = '987654');
        accounts.add(a2);
        insert accounts;
        accounts = [select Name from Account];
        System.assertEquals(2, accounts.size());
        
        // Contact for Submitted for
        // This must be a Houlihan Employee Record Type
        Contact submittedFor = new Contact(firstName = 'HL', lastName = 'Employee', RecordTypeId = '012i0000000tEheAAE');
        
        // Create some contacts to attach gifts
        // These must be External Contact Record Types
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 5; i++) {
            Contact c = new Contact(firstName = 'User' + i, lastName = 'Name' + i, RecordTypeId = '012i0000000tEhjAAE', AccountId = accounts.get(0).Id);
            contacts.add(c);
        }
        for (Integer i = 5; i < 10; i++) {
            Contact c = new Contact(firstName = 'User' + i, lastName = 'Name' + i, RecordTypeId = '012i0000000tEhjAAE', AccountId = accounts.get(1).Id);
            contacts.add(c);
        }
        insert contacts;
        System.assertEquals(10, [select Name from Contact].size());
        
        // Create 2 gift objects and attach to an External Contact type contact
        Gift__c gift = new Gift__c();
        gift.Gift_Type__c = 'Gift: Customers';
        gift.Submitted_For__c = submittedFor.Id ; //'005i0000000LakkAAC';
        gift.Name = 'Sees Candy';
        gift.Gift_Value__c = 25.00;
        gift.CurrencyIsoCode = 'USD';
        
        gift.Recipient__c = contacts.get(0).id;
        insert gift;
        
        Contact c = [Select Id, ( SELECT Gift_Value__C, Approved__c, Desired_Date__c FROM Gifts__r) FROM Contact where id=:contacts.get(0).id LIMIT 1];
        SL_GiftRecipient gr = new SL_GiftRecipient(c);
        SL_Gift g = new SL_Gift (gift, 0, 0, gr);
        
        gift = new Gift__c();
        gift.Gift_Type__c = 'Gift: Customers';
        gift.Submitted_For__c = submittedFor.Id; //'005i0000000LakkAAC';
        gift.Name = 'Sees Candy, 2';
        gift.Gift_Value__c = 33.00;
        gift.CurrencyIsoCode = 'USD';

        gift.Recipient__c = contacts.get(0).id;
        insert gift;

        // Make sure gifts have been correctly saved
        List<Gift__c> gifts = [select id, name from Gift__c where recipient__r.id = :contacts.get(0).id];
        System.assertEquals(2, gifts.size());


        /**************************************
        * Start testing Controller
        ***************************************/

        // Instantiate the controller to start testing methods
        SL_GiftApprovalController gac = new SL_GiftApprovalController();
        
        // Instantiate the standard controller
        SL_GiftPreApprovalController gpc = new SL_GiftPreApprovalController();
        
        // Verify the number of options returned for the search types
        List<SelectOption> opts =  gpc.getSearchOptions();
        System.assertEquals(4, opts.size());
        Boolean caughtException = false;
        gpc.addSelectedRecipients();
        gpc.saveGifts();
        gac.getYearFilterOptions();

        /**************************************
        * Test search functionality
        ***************************************/
        
        // First, test only contact name options
        String retSearchMessage = 'Records returned: 10 (max 1000).';
        gpc.searchTextAccount = '';
        gpc.searchOptionAccount = 'contains';

        // Test search functionality
        //     1. Test with no search message
        gpc.searchTextContact = '';
        gpc.searchOptionContact = 'contains';
        gpc.searchRecipients();
        System.assertEquals('You must enter at least one search term.', gpc.searchMessage);
        
        // Test search functionality
        //     2. Test 'contains' value
        gpc.searchTextContact = 'u';
        gpc.searchOptionContact = 'contains';
        gpc.searchRecipients();
        System.assertEquals(10, gpc.allRecipientsList.size());
        System.assertEquals(25, gpc.allRecipientsList.get(0).recipient.Gifts__r.get(0).Gift_Value__c);
        System.assertEquals('ABC Company', gpc.allRecipientsList.get(0).recipient.Account.Name);
        System.assertEquals(retSearchMessage, gpc.searchMessage);
                
        // Test search functionality
        //     3. Test 'startswith' value to return all
        gpc.searchTextContact = 'u';
        gpc.searchOptionContact = 'startswith';
        gpc.searchRecipients();
        System.assertEquals(10, gpc.allRecipientsList.size());
        System.assertEquals(25, gpc.allRecipientsList.get(0).recipient.Gifts__r.get(0).Gift_Value__c);
        System.assertEquals(retSearchMessage, gpc.searchMessage);

        // Test search functionality
        //     4. Test 'startswith' value to return 1
        gpc.searchTextContact = 'User0';
        gpc.searchOptionContact = 'startswith';
        gpc.searchRecipients();
        System.assertEquals(1, gpc.allRecipientsList.size());

        // Test search functionality
        //     5. Test 'endswith' value to return 1
        gpc.searchTextContact = 'Name0';
        gpc.searchOptionContact = 'endswith';
        gpc.searchRecipients();
        System.assertEquals(1, gpc.allRecipientsList.size());

        // Test search functionality
        //     6. Test 'exact' value to return 1
        gpc.searchTextContact = 'User0 Name0';
        gpc.searchOptionContact = 'exact';
        gpc.searchRecipients();
        System.assertEquals(1, gpc.allRecipientsList.size());

        // Now, test the account options
        gpc.searchTextContact = '';
        gpc.searchOptionContact = 'contains';
        
        // Test search functionality
        //     1. Test 'contains' value
        gpc.searchTextAccount = 'om';
        gpc.searchOptionAccount = 'contains';
        gpc.searchRecipients();
        System.assertEquals(10, gpc.allRecipientsList.size());
                
        // Test search functionality
        //     2. Test 'startswith' value to return 5
        gpc.searchTextAccount = 'abc';
        gpc.searchOptionAccount = 'startswith';
        gpc.searchRecipients();
        System.assertEquals(5, gpc.allRecipientsList.size());

        // Test search functionality
        //     3. Test 'endswith' value to return 10
        gpc.searchTextAccount = 'any';
        gpc.searchOptionAccount = 'endswith';
        gpc.searchRecipients();
        System.assertEquals(10, gpc.allRecipientsList.size());

        // Test search functionality
        //     4. Test 'exact' value to return 5
        gpc.searchTextAccount = 'DEF Company';
        gpc.searchOptionAccount = 'exact';
        gpc.searchRecipients();
        System.assertEquals(5, gpc.allRecipientsList.size());

        
        
        // Reset to continue tests
        // Now, start to select contacts and either
        //      a. Add them to the selected side
        //      -- or --
        //      b. Remove a selected contact
        gpc.searchTextAccount = '';
        gpc.searchOptionAccount = 'contains';
        gpc.searchTextContact = 'u';
        gpc.searchOptionContact = 'contains';
        gpc.searchRecipients();
        List<SL_GiftRecipient> all = gpc.allRecipientsList;
        System.assertEquals(10, all.size());

        gpc.allRecipientsList.get(1).selected = true;
        System.assertEquals(true, gpc.allRecipientsList.get(1).selected);

        gpc.addSelectedRecipients();
        System.assertEquals(false, gpc.allRecipientsList.get(1).selected);
        System.assertEquals(1, gpc.selRecipientsList.size());

        gpc.selRecipientsList.get(0).selected = true;
        System.assertEquals(true, gpc.allRecipientsList.get(1).selected);
        
        gpc.removeSelectedRecipients();
        System.assertEquals(0, gpc.selRecipientsList.size());
        
        
        // Add a new gift to a selected contact and verify it has been saved
        gpc.allRecipientsList.get(1).selected = true;
        gpc.addSelectedRecipients();
        
        gift = new Gift__c();
        gpc.gift.Gift_Type__c = 'Gift: Customers';
        gpc.gift.Submitted_For__c = submittedFor.Id;
        gpc.gift.Name = 'Sees Candy, 3';
        gpc.gift.Gift_Value__c = 33.00;
        gpc.gift.CurrencyIsoCode = 'USD';
        System.assertEquals(33, gpc.gift.Gift_Value__c);

        gpc.saveGifts();

        Gift__c newGift = [select id, name, Gift_value__c from Gift__c where name = 'Sees Candy, 3']; 
        System.assertEquals(33, newGift.Gift_Value__c);

        /**************************************
        * Start testing Congrats process
        ***************************************/
        
        List<SL_Gift> giftTest = gpc.getGiftsJustAdded();
        System.assertEquals(1, giftTest.size());
        
        
        /**************************************
        * Start testing Approval process
        ***************************************/
        opts =  gac.getApprovalOptions();
        System.assertEquals(3, opts.size());
        
        // Make sure none are approved
        gac.searchGifts();
        gac.viewType = 'Yes';
        gac.giftList.clear();
        List<SL_Gift> savedGifts = gac.giftList;
        gac.searchGifts();
        System.assertEquals(0, savedGifts.size());
        
        // Make sure none are denied
        gac.viewType = 'No';
        gac.searchGifts();
        savedGifts = gac.giftList;
        System.assertEquals(0, savedGifts.size());
        
        // Make sure there are 3 pending gifts
        gac.viewType = 'Pending';
        gac.yearFilter = Date.Today().Year();
        gac.nameFilter = '';
        gac.searchGifts();
        savedGifts = gac.giftList;
        System.assertEquals(3, savedGifts.size());

        // Select a gift to Approve and then verify it has been approved
        savedGifts[0].selected = true;
        gac.approveSelectedGifts();
        
        // Approve the gift
        gac.viewType = 'Approved';
        gac.searchGifts();
        savedGifts = gac.giftList;
        System.assertEquals(1, savedGifts.size());

        // Get the Pending, verify there are 2
        gac.viewType = 'Pending';
        gac.searchGifts();
        savedGifts = gac.giftList;
        //System.assertEquals(2, savedGifts.size());
        
        savedGifts[0].selected = true;
        gac.denySelectedGifts();
        
        // Deny the gift
        gac.searchGifts();
        gac.viewType = 'Denied';
        savedGifts = gac.giftList;
        System.assertEquals(1, savedGifts.size());
        
        // Get the Pending, verify there is only 1 left, then approve it
        gac.viewType = 'Pending';
        gac.searchGifts();
        savedGifts = gac.giftList;
        System.assertEquals(1, savedGifts.size());
        
        savedGifts[0].selected = true;
        gac.processSelectedGifts('Approve');
        gac.viewType = 'Approved';
        gac.searchGifts();
        savedGifts = gac.giftList;
        System.assertEquals(2, savedGifts.size());
        
        // Verify there are no Pending gifts left
        gac.viewType = 'Pending';
        gac.searchGifts();
        savedGifts = gac.giftList;
        System.assertEquals(0, savedGifts.size());

        gift = new Gift__c();
        gpc.gift.Gift_Type__c = 'Gift: Customers';
        gpc.gift.Submitted_For__c = submittedFor.Id;
        gpc.gift.Name = 'Excessive';
        gpc.gift.Gift_Value__c = 150.00;
        gpc.gift.CurrencyIsoCode = 'USD';
        /*
        gpc.saveGifts();
        gpc.proceedToCongratulations();
        gac.searchGifts();
        savedGifts = gac.giftList;
        savedGifts[savedGifts.size()-1].selected = true;
        gac.processSelectedGifts('Approve');
        */
        /**************************************
        * Test clone
        ***************************************/
        
        ApexPages.CurrentPage().getparameters().put('id', newGift.Id);
        ApexPages.CurrentPage().getparameters().put('clone', '1');
        SL_GiftPreApprovalController gpcClone = new SL_GiftPreApprovalController();
        System.assertEquals(33, gpcClone.gift.Gift_Value__c);
    }
}