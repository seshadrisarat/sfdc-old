@isTest
public with sharing class TestDealerBrandTrigger {
	private static Id DEALER_RECORD_TYPE = [Select Id from RecordType Where DeveloperName='DEALER' limit 1].Id;
	private static final String BRAND_NON_FW = 'SR';
	private static final String BRAND1 = 'CC';
	private static final string HIN1 = 'SERT8312B606';
	private static final string HIN2 = 'SERT8312B603';
	private static final string DEALER_NUMBER1 = '123456.000';
	private static final string DEALER_NUMBER2 = '123456.001';

	public static testMethod void testDealerBrandInsertFWBrand() {
		createConfiguration();
        createFreshwaterBrandsCustomSetting();
        User owner = createOwner();
        insert owner;
        Account dealer = createDealer(DEALER_NUMBER1);
        insert dealer;
        
        // Dealer should have no sharing rules
        list<AccountShare> accountShares = [Select Id, AccountId, UserOrGroupId, AccountAccessLevel, RowCause from AccountShare where AccountId=:dealer.Id and RowCause='Manual'];
        system.assertEquals(0, accountShares.size(), 'There should not be any account shares');
        
        Test.startTest();
        Dealer_Brand__c db = createDealerBrand(dealer, owner, BRAND1);
        insert db;
        Test.stopTest();
        
        // Dealer should have sharing rules
       	accountShares = [Select Id, AccountId, UserOrGroupId, AccountAccessLevel, RowCause from AccountShare where AccountId=:dealer.Id and RowCause='Manual'];
        system.assertEquals(1, accountShares.size(), 'There should be a single account share');
        system.assertEquals(owner.Id, accountShares[0].UserOrGroupId, 'The UserOrGroupId should be set to the owner of dealer brand');
        
        // Now we should be able to see this dealer and boat when we run as this user
        System.runAs(owner) {
        	// Can they see the dealer
        	list<Account> dealers = [select Id, Dealer_Number__c from Account where recordTypeId=:DEALER_RECORD_TYPE];
        	system.assertEquals(1, dealers.size());
        	system.assertEquals(dealer.Dealer_Number__c, dealers[0].Dealer_Number__c);
        }
	}
	
	public static testMethod void testDealerBrandInsertNonFWBrand() {
		createConfiguration();
        createFreshwaterBrandsCustomSetting();
        User owner = createOwner();
        insert owner;
        Account dealer = createDealer(DEALER_NUMBER1);
        insert dealer;
        
        Test.startTest();
        Dealer_Brand__c db = createDealerBrand(dealer, owner, BRAND_NON_FW);
        insert db;
        Test.stopTest();
        
        // Dealer should have sharing rules
        list<AccountShare> accountShares = [Select Id, AccountId, UserOrGroupId, AccountAccessLevel, RowCause from AccountShare where AccountId=:dealer.Id and RowCause='Manual'];
        system.assertEquals(0, accountShares.size(), 'There should not be any account shares');
        
        // Now we should be able to see this dealer and boat when we run as this user
        System.runAs(owner) {
        	// Can they see the dealer
        	list<Account> dealers = [select Id, Dealer_Number__c from Account where recordTypeId=:DEALER_RECORD_TYPE];
        	system.assertEquals(0, dealers.size());
        }
	}
	
	public static testMethod void testDealerBrandUpdateFWBrand() {
		createConfiguration();
        createFreshwaterBrandsCustomSetting();
        User owner = createOwner();
        insert owner;
        Account dealer = createDealer(DEALER_NUMBER1);
        insert dealer;
        
        Dealer_Brand__c db = createDealerBrand(dealer, owner, BRAND1);
        insert db;
        
        Boat__c boat = createBoat(dealer, db, HIN1);
        insert boat;
        
        // Now update the dealer brand
        Test.startTest();
        update db;
        Test.stopTest();
        
        // Dealer should have sharing rules
       	list<AccountShare> accountShares = [Select Id, AccountId, UserOrGroupId, AccountAccessLevel, RowCause from AccountShare where AccountId=:dealer.Id and RowCause='Manual'];
        system.assertEquals(1, accountShares.size(), 'There should be a single account share');
        system.assertEquals(owner.Id, accountShares[0].UserOrGroupId, 'The UserOrGroupId should be set to the owner of dealer brand');
        
        // We should have a single boat share created
        list<Boat__Share> boatShares = [Select Id, ParentId, UserOrGroupId, AccessLevel, RowCause from Boat__Share where ParentId=:boat.Id and RowCause=:Schema.Boat__Share.rowCause.DBM_Boat_Access__c];
        system.assertEquals(1, boatShares.size(), 'There should be a single boat share');
        system.assertEquals(owner.Id, boatShares[0].UserOrGroupId, 'The UserOrGroupId should be set to the owner of the dealer brand');
        system.assertEquals('Read', boatShares[0].AccessLevel);
        
        // Now we should be able to see this dealer and boat when we run as this user
        System.runAs(owner) {
        	// Can they see the dealer
        	list<Account> dealers = [select Id, Dealer_Number__c from Account where recordTypeId=:DEALER_RECORD_TYPE];
        	system.assertEquals(1, dealers.size());
        	system.assertEquals(dealer.Dealer_Number__c, dealers[0].Dealer_Number__c);
        	
        	// Can they see the boat
        	list<Boat__c> boats = [select Id, Name from Boat__c];
        	system.assertEquals(1, boats.size());
        	system.assertEquals(boat.Name, boats[0].Name);
        }
	}
	
	private static Id getIntegrationUserId() {
		User[] users = [select Id from User where Name='Integration User'];
		return users[0].Id;
	}
    
    private static void createConfiguration() {
		Configuration__c config = new Configuration__c(Name='BoatOwner',RecordId__c=getIntegrationUserId());
		insert config;
	}
	
	private static void createFreshwaterBrandsCustomSetting() {
		list<Freshwater_Brands__c> fwBrands = new list<Freshwater_Brands__c>();
		
		Freshwater_Brands__c fwb1 = new Freshwater_Brands__c(Name='CC', Brand__c='CC');
		
		fwBrands.add(fwb1);
		
		insert fwBrands;
	}
	
	private static User createOwner() {
		Profile p = [select Id from Profile where name = 'Freshwater DBM User' limit 1];
        return new User(
	      FirstName = 'testFirst'
	      , LastName = 'testLast'
	      , Username = 'DBMServicesTest@test.com'
	      , Email = 'test@test.com'
	      , IsActive = true
	      , Alias = 'DBMST'
	      , TimeZoneSidKey = 'GMT'
	      , LocaleSidKey = 'en_US'
	      , EmailEncodingKey = 'ISO-8859-1'
	      , LanguageLocaleKey = 'en_US'
	      , ProfileId = p.Id);
	}
    
  	private static Account createDealer(string dealerNumber) {
		Account dealer = new Account();
		
		dealer.recordTypeId = DEALER_RECORD_TYPE;
		dealer.Name = 'MarineMax TX-Seabrook';
		dealer.Dealer_Number__c = dealerNumber;
		dealer.ShippingStreet = '112 E. HIGH STREET';
		dealer.ShippingCity = 'HENNEPIN';
		dealer.ShippingState = 'IL';
		dealer.ShippingPostalCode = '61327';
		dealer.ShippingCountry = 'US';
		dealer.Country_ISO_Code__c = 'US';
		
		return dealer;
	}
    
    private static Dealer_Brand__c createDealerBrand(Account dealer, User owner, string brand) {
    	Dealer_Brand__c db = new Dealer_Brand__c();
    	db.Brand__c = brand;
    	db.Dealer__c = dealer.Id;
    	db.OwnerId = owner.Id;
    	
    	return db;
    }
    
    private static Boat__c createBoat(Account dealer, Dealer_Brand__c db, string hin) {
		Boat__c boat = new Boat__c();
		
		boat.Name = hin;
		boat.External_HIN_Number__c = hin;
		boat.Hin_migration__c = hin;
		boat.Model_Year__c = '2006';
		boat.Boat_Model__c = '320DA';
		boat.Brand_del__c = db.Brand__c;
		
		boat.DealerNumLoc__c = dealer.Dealer_Number__c;
		boat.Dealer__c = dealer.Id;
		boat.Dealer_Brand_Lookup__c = db.Id;
		
		return boat;
	}
}