/*
Developer   : Poundarik, Shruti
Company 	: Bluewolf LLC
*/
@isTest
private class TestBoatTrigger{
	private static Id OWNER_RECORD_TYPE_ID = [select Id from recordtype where developerName='Owner' limit 1].Id;
	private static Id DEALER_RECORD_TYPE = [Select Id from RecordType Where DeveloperName='DEALER' limit 1].Id;
	private static final String BRAND_NON_FW = 'SR';
	private static final String BRAND1 = 'CC';
	private static final string HIN1 = 'SERT8312B606';
	private static final string HIN2 = 'SERT8312B603';
	private static final string DEALER_NUMBER1 = '123456.000';
	private static final string DEALER_NUMBER2 = '123456.001';
	static Account acc, dealerAcc, ownerAcc;
	static list<Boat__c> bt = new list<Boat__c>();
	static Contact con;
	final static String OWNER = 'Owner';
	final static String DEALER = 'Dealer';	
	static map<String,Id> selectedRecordTypes = new map<String,Id>();
	static Configuration__c config;
	private static User boatOwner;
	
	// Tests that a new boat created with owner info will create the owner record and set it to active
	@isTest static void insertNewBoatWithNoOwner(){
		createConfiguration();
		
    	Boat__c boat = createBoat();
    	insert boat;
    	
    	list<Account> accList = [Select Id, FirstName,LastName,PersonEmail, Dealer_Number__c from Account order by CreatedDate];
		system.assertEquals(1, accList.size(), 'One owner should exist for the Account');
		system.assertEquals('Lamphere', accList[0].LastName);
				
		list<Owner_Boat_Relationship__c> boatOwnershipList = [Select HIN_Number__c,	Owner__c, status__c from Owner_Boat_Relationship__c order by CreatedDate];
		system.assertEquals(1, boatOwnershipList.size(),'One Boat Ownership relationship should have been created');
		system.assertEquals('Active',boatOwnershipList[0].status__c,'Status should have been Active');		  	
    } 
    
    // Tests that when a new boat is created it will find an existing owner match by first, last, and address and set the relationship to active
    @isTest static void insertNewBoatWithExistingOwner(){
    	createConfiguration();
		
		Account o = createOwner();
		insert o;
		
    	Boat__c boat = createBoat();
    	insert boat;
    	
    	list<Account> accList = [Select Id, FirstName,LastName,PersonEmail, Dealer_Number__c from Account order by CreatedDate];
		system.assertEquals(1, accList.size(), 'One owner should exist for the Account');
		system.assertEquals('Lamphere', accList[0].LastName);
				
		list<Owner_Boat_Relationship__c> boatOwnershipList = [Select HIN_Number__c,	Owner__c, status__c from Owner_Boat_Relationship__c order by CreatedDate];
		system.assertEquals(1, boatOwnershipList.size(),'One Boat Ownership relationship should have been created');
		system.assertEquals('Active',boatOwnershipList[0].status__c,'Status should have been Active');		  	   
    } 
    
     // Tests that when a new boat is created it will find an existing owner match, but since that owner was updated by SROC it will not overwrite the fields
    @isTest static void insertNewBoatWithExistingOwnerSROCWillNotOverwrite(){
    	createConfiguration();
		
		Account o = createOwner();
		o.brand__c = 'SR';
		o.Entry_Source__c = 'SROC';
		o.PersonMailingPostalCode = '';
		insert o;
		
    	Boat__c boat = createBoat();
    	boat.Brand_del__c = 'SR';
    	boat.Model_Description__c ='Sea Ray';
    	insert boat;
    	
    	list<Account> accList = [Select Id, FirstName,LastName,PersonEmail, PersonMailingPostalCode, Dealer_Number__c from Account order by CreatedDate];
		system.assertEquals(1, accList.size(), 'One owner should exist for the Account');
		system.assertEquals('Lamphere', accList[0].LastName);
		system.assertEquals('37929', accList[0].PersonMailingPostalCode, 'The postal code should not have been updated');
				
		list<Owner_Boat_Relationship__c> boatOwnershipList = [Select HIN_Number__c,	Owner__c, status__c from Owner_Boat_Relationship__c order by CreatedDate];
		system.assertEquals(1, boatOwnershipList.size(),'One Boat Ownership relationship should have been created');
		system.assertEquals('Active',boatOwnershipList[0].status__c,'Status should have been Active');		  	   
    } 
    
    // Tests that when a new boat is created it will find an existing owner match by first, last, and address ignoring case and set the relationship to active
    @isTest static void insertNewBoatWithExistingOwnerCaseInsensitive(){
    	createConfiguration();
		
		Account o = createOwner();
		o.FirstName = o.FirstName.toLowerCase();
    	o.LastName = o.LastName.toLowerCase();
    	o.PersonMailingStreet  = o.PersonMailingStreet.toLowerCase();
		insert o;
		
    	Boat__c boat = createBoat();
    	insert boat;
    	
    	list<Account> accList = [Select Id, FirstName,LastName,PersonEmail, Dealer_Number__c from Account order by CreatedDate];
		system.assertEquals(1, accList.size(), 'One owner should exist for the Account');
		system.assertEquals('lamphere', accList[0].LastName);
				
		list<Owner_Boat_Relationship__c> boatOwnershipList = [Select HIN_Number__c,	Owner__c, status__c from Owner_Boat_Relationship__c order by CreatedDate];
		system.assertEquals(1, boatOwnershipList.size(),'One Boat Ownership relationship should have been created');
		system.assertEquals('Active',boatOwnershipList[0].status__c,'Status should have been Active');		  	   
    } 
    
    // Tests that when a new boat is created it will find an existing owner match by first, last, and email and set the relationship to active for 
    // more than one boat. The owner should be active for 2 boats
    @isTest static void insertNewBoatWithExistingOwnerForMultipleBoats(){
    	createConfiguration();
		
		Account o = createOwner();
		insert o;
		
    	Boat__c boat1 = createBoat();
    	insert boat1;
    	
    	Boat__c boat2 = createBoat();
    	boat2.Name = '9822323';
		boat2.External_HIN_Number__c = '9822323';
		boat2.Hin_migration__c = '9822323';
		boat2.Boat_Model__c = 'TestModel 2';
    	insert boat2;
    	
    	list<Account> accList = [Select Id, FirstName,LastName,PersonEmail, Dealer_Number__c from Account order by CreatedDate];
		system.assertEquals(1, accList.size(), 'One owner should exist for the Account');
		system.assertEquals('Lamphere', accList[0].LastName);
				
		list<Owner_Boat_Relationship__c> boatOwnershipList = [Select HIN_Number__c,	Owner__c, status__c from Owner_Boat_Relationship__c order by CreatedDate];
		system.assertEquals(2, boatOwnershipList.size(),'Two Boat Ownership relationship should have been created');
		system.assertEquals('Active',boatOwnershipList[0].status__c,'Status should have been Active');	
		system.assertEquals('Active',boatOwnershipList[1].status__c,'Status should have been Active');
		system.assertEquals(boat1.Id, boatOwnershipList[0].HIN_Number__c,'HIN should match');	
		system.assertEquals(boat2.Id,boatOwnershipList[1].HIN_Number__c,'HIN should match');	  	   
    } 
    
    // Tests that a new boat is created with the owner email not matching an existing owner record will not match the existing 
    // owner, but will create a new owner record
    @isTest static void insertNewBoatWithExistingOwnerNoMatch(){
    	createConfiguration();
		
		// If the street is not set then we should not have a match
		Account o = createOwner();
		o.PersonMailingStreet = '';
		insert o;
		
    	Boat__c boat = createBoat();
    	insert boat;
    	
    	list<Account> accList = [Select Id, FirstName,LastName,PersonEmail, Dealer_Number__c from Account order by CreatedDate];
		system.assertEquals(2, accList.size(), 'A new owner should have been created');
		system.assertEquals('test@newboat.com', accList[1].PersonEmail);
				
		list<Owner_Boat_Relationship__c> boatOwnershipList = [Select HIN_Number__c,	Owner__c, status__c from Owner_Boat_Relationship__c order by CreatedDate];
		system.assertEquals(1, boatOwnershipList.size(),'One Boat Ownership relationship should have been created');
		system.assertEquals('Active',boatOwnershipList[0].status__c,'Status should have been Active');		  	   
    }
    
    // Tests that a boat created with an initial owner when updated with a new owner will create it and set it to active and the old one to inactive
    @isTest static void updateBoatWithNewOwner(){
		createConfiguration();
		
		// Create boat - new owner should be created
    	Boat__c boat = createBoat();
    	insert boat;
    	
    	// Update owner info and boat. This should not find a match and should create a new owner
    	BoatServices.isWorkFlowRunning = false;
    	boat.Owner_FirstName__c = 'New';
    	boat.Owner_LastName__c = 'Owner';
    	update boat;
    	
    	list<Account> accList = [Select Id, FirstName,LastName,PersonEmail, Dealer_Number__c, Brand_Relationships__c from Account order by CreatedDate];
		system.assertEquals(2, accList.size(), 'A new owner should have been created');
		system.assertEquals('Owner', accList[1].LastName);
		system.assertEquals(null, accList[0].Brand_Relationships__c, 'The first owner should not have any brand relationship');
		system.assertEquals(boat.Brand_del__c, accList[1].Brand_Relationships__c, 'The second owner should have a brand relationship');
				
		list<Owner_Boat_Relationship__c> boatOwnershipList = [Select HIN_Number__c,	Owner__c, status__c from Owner_Boat_Relationship__c order by CreatedDate];
		system.assertEquals(2, boatOwnershipList.size(),'Two Boat Ownership relationships should have been created');
		system.assertEquals('Inactive',boatOwnershipList[0].status__c,'Status should have been InActive');	
		system.assertEquals('Active',boatOwnershipList[1].status__c,'Status should have been Active');		  
	}
	
	// Tests that when a boat is inserted a dealer brand is assigned
    @isTest static void insertBoatDealerBrandAssigned(){
		createConfiguration();
		createFreshwaterBrandsCustomSetting();
		User dbmOwner = createDBMOwner();
        insert dbmOwner;
        Account dbmDealer = createDealer(DEALER_NUMBER1);
        insert dbmDealer;
        Dealer_Brand__c db = createDealerBrand(dbmDealer, dbmOwner, BRAND1);
        insert db;
		
		// Create boat - new owner should be created
		Test.startTest();
    	Boat__c boat = createDBMBoat(dbmDealer, db, HIN1);
    	insert boat;
    	Test.stopTest();
    	
    	// We should have a single boat share created
        list<Boat__Share> boatShares = [Select Id, ParentId, UserOrGroupId, AccessLevel, RowCause from Boat__Share where ParentId=:boat.Id and RowCause=:Schema.Boat__Share.rowCause.DBM_Boat_Access__c];
        system.assertEquals(1, boatShares.size(), 'There should be a single boat share');
        system.assertEquals(dbmOwner.Id, boatShares[0].UserOrGroupId, 'The UserOrGroupId should be set to the owner of the dealer brand');
        system.assertEquals('Read', boatShares[0].AccessLevel);
        
        // Now we should be able to see this dealer and boat when we run as this user
        System.runAs(dbmOwner) {
        	// Can they see the boat
        	list<Boat__c> boats = [select Id, Name from Boat__c];
        	system.assertEquals(1, boats.size());
        	system.assertEquals(boat.Name, boats[0].Name);
        }	  
	}
	
	// Tests that when a boat is inserted a dealer brand is assigned
    @isTest static void updateBoatDealerBrandAssigned(){
		createConfiguration();
		createFreshwaterBrandsCustomSetting();
		User dbmOwner = createDBMOwner();
        insert dbmOwner;
        Account dbmDealer = createDealer(DEALER_NUMBER1);
        insert dbmDealer;
        Dealer_Brand__c db = createDealerBrand(dbmDealer, dbmOwner, BRAND1);
        insert db;
		
		// Create boat but disable assignment of permissions since we are testing update
		DBMServices.disableTriggerProcessing = true;
    	Boat__c boat = createDBMBoat(dbmDealer, db, HIN1);
    	insert boat;
    	DBMServices.disableTriggerProcessing = false;
    	
    	list<Boat__Share> boatShares = [Select Id, ParentId, UserOrGroupId, AccessLevel, RowCause from Boat__Share where ParentId=:boat.Id and RowCause=:Schema.Boat__Share.rowCause.DBM_Boat_Access__c];
        system.assertEquals(0, boatShares.size(), 'There should be no boat shares');
        
        Test.startTest();
        update boat;
        Test.stopTest();
    	
    	// We should have a single boat share created
        boatShares = [Select Id, ParentId, UserOrGroupId, AccessLevel, RowCause from Boat__Share where ParentId=:boat.Id and RowCause=:Schema.Boat__Share.rowCause.DBM_Boat_Access__c];
        system.assertEquals(1, boatShares.size(), 'There should be a single boat share');
        system.assertEquals(dbmOwner.Id, boatShares[0].UserOrGroupId, 'The UserOrGroupId should be set to the owner of the dealer brand');
        system.assertEquals('Read', boatShares[0].AccessLevel);
        
        // Now we should be able to see this dealer and boat when we run as this user
        System.runAs(dbmOwner) {
        	// Can they see the boat
        	list<Boat__c> boats = [select Id, Name from Boat__c];
        	system.assertEquals(1, boats.size());
        	system.assertEquals(boat.Name, boats[0].Name);
        }	  
	}
	
	@isTest static void ownerWithMultipleBoatsHasBothBrandsActive(){
		createConfiguration();
		
		Account o = createOwner();
		insert o;
		
    	Boat__c boat = createBoat();
    	insert boat;
    	
    	Boat__c boat2 = createBoat();
    	boat2.Brand_del__c = 'SR';
    	boat2.Name = '1234567';
		boat2.External_HIN_Number__c = '1234567';
		boat2.Hin_migration__c = '1234567';
    	insert boat2;
    	
    	
    	list<Account> accList = [Select Id, FirstName,LastName,PersonEmail, Dealer_Number__c, Brand__c from Account order by CreatedDate];
		system.assertEquals(2, accList.size(), 'Two owners should exist');
		system.assertEquals('BL', accList[0].Brand__C, 'BL should be the brand for the first account');
		system.assertEquals('SR', accList[1].Brand__C, 'SR should be the brand for the second account');
				
		list<Owner_Boat_Relationship__c> boatOwnershipList = [Select HIN_Number__c,	Owner__c, status__c from Owner_Boat_Relationship__c order by CreatedDate];
		system.assertEquals(2, boatOwnershipList.size(),'Two Boat Ownership relationships should have been created');
		system.assertEquals('Active',boatOwnershipList[0].status__c,'Status should have been Active');	
		system.assertEquals('Active',boatOwnershipList[1].status__c,'Status should have been Active');	
				  
	} 
	
	@isTest static void ownerWithMultipleBoatsHasBothActive(){
		createConfiguration();
		
		// Create a BL owner
		Account o = createOwner();
		insert o;
		
		// Create a BL boat that should pickup the prior owner
    	Boat__c boat = createBoat();
    	insert boat;
    	
    	// Create a new BL boat that will pickup the prior owner
    	Boat__c boat2 = createBoat();
    	boat2.Name = '1234567';
		boat2.External_HIN_Number__c = '1234567';
		boat2.Hin_migration__c = '1234567';
    	insert boat2;
    	
    	list<Account> accList = [Select Id, FirstName,LastName,PersonEmail, Dealer_Number__c, Brand_Relationships__c from Account order by CreatedDate];
		system.assertEquals(1, accList.size(), 'One owner should exist');
    	
    	list<Owner_Boat_Relationship__c> boatOwnershipList = [Select Id, Status__c from Owner_Boat_Relationship__c order by CreatedDate];
		system.assertEquals(2, boatOwnershipList.size(),'Two Boat Ownership relationships should have been created');
		system.assertEquals('Active',boatOwnershipList[0].status__c,'Status should have been Active');	
		system.assertEquals('Active',boatOwnershipList[1].status__c,'Status should have been Active');	
				  
	}
	
	@isTest static void ownerWithMultipleBoatsAndNewOwnerForSecondBoatChangesFirstRelationshipToInActive(){
		createConfiguration();
		
		// Create a BL owner
		AccountServices.disableTriggerProcessing = true;
		Account o = createOwner();
		insert o;
		AccountServices.disableTriggerProcessing = false;
		
		// Create a BL boat that should pickup the prior owner
    	Boat__c boat = createBoat();
    	insert boat;
    	
    	// Create a new BL boat that will pickup the prior owner
    	Boat__c boat2 = createBoat();
    	boat2.Name = '1234567';
		boat2.External_HIN_Number__c = '1234567';
		boat2.Hin_migration__c = '1234567';
    	insert boat2;
    	
    	list<Account> accList = [Select Id, FirstName,LastName,PersonEmail, Dealer_Number__c, Brand_Relationships__c from Account order by CreatedDate];
		system.assertEquals(1, accList.size(), 'One owner should exist');
		
		list<Owner_Boat_Relationship__c> boatOwnershipList = [Select Id, Status__c from Owner_Boat_Relationship__c order by CreatedDate];
		system.assertEquals(2, boatOwnershipList.size(),'Two Boat Ownership relationships should have been created');
		
		// Now create a second owner
		AccountServices.disableTriggerProcessing = true;
		Account o2 = createOwner();
		o2.FirstName = 'Second';
    	o2.LastName = 'Owner';
    	o2.PersonEmail = 'test2@newboat.com';
		insert o2;
		AccountServices.disableTriggerProcessing = false;
		
		accList = [Select Id, FirstName,LastName,PersonEmail, Dealer_Number__c, Brand_Relationships__c from Account order by CreatedDate];
		system.assertEquals(2, accList.size(), 'Two owners should exist');
		
		// Create obr to second owner and second boat
		Owner_Boat_Relationship__c obr = createOwnerBoatRelationship(o2, boat2);
		insert obr;
		
		boatOwnershipList = [Select Id, Status__c from Owner_Boat_Relationship__c order by CreatedDate];
		system.assertEquals(3, boatOwnershipList.size(), 'Three relationships should exist');
		system.assertEquals('Active',boatOwnershipList[0].status__c,'Status should have been Active');	
		system.assertEquals('Inactive',boatOwnershipList[1].status__c,'Status should have been InActive');	
		system.assertEquals('Active',boatOwnershipList[2].status__c,'Status should have been Active');	  
	}
	
	// Tests that a boat is created with a new owner and then updated with an existing owner. There should be 2 owners in the system and both assigned to the boat. The original
	// owner created with the boat should be inactive
	@isTest static void updateBoatWithExistingOwner(){
		createConfiguration();
		
		Account o = createOwner();
		o.FirstName = 'New';
		o.LastName = 'Owner';
		o.PersonMailingStreet  = '21 Jump street';
		insert o;
		
    	Boat__c boat = createBoat();
    	insert boat;
    	
    	BoatServices.isWorkFlowRunning = false;
    	boat.Owner_FirstName__c = 'New';
    	boat.Owner_LastName__c = 'Owner';
    	boat.Owner_Street__c = '21 Jump street';
    	update boat;
    	
    	list<Account> accList = [Select Id, FirstName,LastName,PersonEmail, Dealer_Number__c from Account order by CreatedDate];
		system.assertEquals(2, accList.size(), 'A new owner should have been created');
		system.assertEquals('Owner', accList[0].LastName);
				
		list<Owner_Boat_Relationship__c> boatOwnershipList = [Select HIN_Number__c,	Owner__c, status__c from Owner_Boat_Relationship__c order by CreatedDate];
		system.assertEquals(2, boatOwnershipList.size(),'Two Boat Ownership relationships should have been created');
		system.assertEquals('Inactive',boatOwnershipList[0].status__c,'Status should have been InActive');	
		system.assertEquals('Active',boatOwnershipList[1].status__c,'Status should have been Active');	
		system.assertEquals(o.Id ,boatOwnershipList[1].Owner__c,'Existing owner should be related to boat');		  
	}
	 
	// Tests that a boat inserted with no owner and then updated with an owner creates the new owner and sets it to active
	@isTest static void insertBoatWithNoOwnerAndThenUpdateWithNewOwner(){
		createConfiguration();
		
    	Boat__c boat = createBoat();
    	boat.Owner_FirstName__c = '';
    	boat.Owner_LastName__c = '';
    	boat.Owner_Email__c = '';
    	insert boat;

		BoatServices.isWorkFlowRunning = false;
		boat.Owner_FirstName__c = 'New';
    	boat.Owner_LastName__c = 'Owner';
    	boat.Owner_Email__c = 'new@owner.com';
    	update boat;
    	
    	list<Account> accList = [Select Id, FirstName,LastName,PersonEmail, Dealer_Number__c from Account order by CreatedDate];
		system.assertEquals(1, accList.size(), 'A new owner should have been created');
		system.assertEquals('Owner', accList[0].LastName);
				
		list<Owner_Boat_Relationship__c> boatOwnershipList = [Select HIN_Number__c,	Owner__c, status__c from Owner_Boat_Relationship__c order by CreatedDate];
		system.assertEquals(1, boatOwnershipList.size(),'One Boat Ownership relationships should have been created');
		system.assertEquals('Active',boatOwnershipList[0].status__c,'Status should have been Active');		
	}
	
	// Tests that a boat updated with non SROC will not update the owner boat relationship set with SROC
	@isTest static void updateBoatWithNonSROCDoesNotUpdateRelationship(){
		createConfiguration();
		
    	Boat__c boat = createBoat();
    	boat.Brand_del__c = 'SR';
    	boat.Model_Description__c ='Sea Ray';
    	insert boat;
    	
    	// Now we need to get the Owner and update the source to SROC
    	list<Account> accList = [Select Id, Entry_Source__c from Account order by CreatedDate];
    	accList[0].Entry_Source__c = 'SROC';
    	update accList[0];
    	
    	// Now update the boat with a changed zip, but since the owner was set with SROC it should not update
    	boat.Owner_Zip__c = '9999';
    	update boat;
    	
    	accList = [Select Id, FirstName,LastName,PersonEmail, PersonMailingPostalCode, Dealer_Number__c from Account order by CreatedDate];
		system.assertEquals(1, accList.size(), 'A new owner should have been created');
		system.assertEquals('37929', accList[0].PersonMailingPostalCode, 'The postal code should not have been updated');
				
		list<Owner_Boat_Relationship__c> boatOwnershipList = [Select HIN_Number__c,	Owner__c, status__c from Owner_Boat_Relationship__c order by CreatedDate];
		system.assertEquals(1, boatOwnershipList.size(),'One Boat Ownership relationships should have been created');
		system.assertEquals('Active',boatOwnershipList[0].status__c,'Status should have been Active');		
	}
	
	private static void createConfiguration() {
		boatOwner = TestServices.getUser('insertNewBoat@test.com');
		insert boatOwner;
		Configuration__c c = new Configuration__c(Name='BoatOwner',RecordId__c=boatOwner.Id);
		insert c;
	}
	
	
	private static void createFreshwaterBrandsCustomSetting() {
		list<Freshwater_Brands__c> fwBrands = new list<Freshwater_Brands__c>();
		
		Freshwater_Brands__c fwb1 = new Freshwater_Brands__c(Name='CC', Brand__c='CC');
		
		fwBrands.add(fwb1);
		
		insert fwBrands;
	}
	
	private static Account createOwner() {
		Account bo = new Account();
		bo.RecordTypeId = OWNER_RECORD_TYPE_ID;
        bo.OwnerId = Configuration__c.getInstance('BoatOwner').RecordId__c;
		bo.FirstName = 'Kirsten';
    	bo.LastName = 'Lamphere';
    	bo.PersonEmail = 'test@newboat.com';
    	bo.PersonMailingStreet  = '123 Main St';
        bo.PersonMailingState = 'CO';
        bo.PersonMailingCity = 'Boulder';
        bo.PersonMailingPostalCode = '80305';
        bo.Brand__c = 'BL';
    	
    	return bo;
	}
	
	private static User createDBMOwner() {
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
		Account d = new Account();
		
		d.recordTypeId = DEALER_RECORD_TYPE;
		d.Name = 'MarineMax TX-Seabrook';
		d.Dealer_Number__c = dealerNumber;
		d.ShippingStreet = '112 E. HIGH STREET';
		d.ShippingCity = 'HENNEPIN';
		d.ShippingState = 'IL';
		d.ShippingPostalCode = '61327';
		d.ShippingCountry = 'US';
		d.Country_ISO_Code__c = 'US';
		
		return d;
	}
    
    private static Dealer_Brand__c createDealerBrand(Account d, User o, string brand) {
    	Dealer_Brand__c db = new Dealer_Brand__c();
    	db.Brand__c = brand;
    	db.Dealer__c = d.Id;
    	db.OwnerId = o.Id;
    	
    	return db;
    }
    
    private static Boat__c createDBMBoat(Account d, Dealer_Brand__c db, string hin) {
		Boat__c boat = new Boat__c();
		
		boat.Name = hin;
		boat.External_HIN_Number__c = hin;
		boat.Hin_migration__c = hin;
		boat.Model_Year__c = '2006';
		boat.Boat_Model__c = '320DA';
		boat.Brand_del__c = db.Brand__c;
		
		boat.DealerNumLoc__c = d.Dealer_Number__c;
		boat.Dealer__c = d.Id;
		
		return boat;
	}
	
	private static Boat__c createBoat() {
		Boat__c boat = new Boat__c();
		
		boat.Name = '123456';
		boat.External_HIN_Number__c = '123456';
		boat.Hin_migration__c = '123456';
		boat.Boat_Model__c = 'TestModel';
		boat.Invoice_Date__c = system.today();
    	boat.Invoice_Number__c = '12345678';
    	boat.Model_Description__c ='Bayliner';
    	boat.Model_Year__c = '2010';
    	boat.Brand_del__c = 'BL';
    	boat.Warranty_Checklist_Date__c = system.today();
    	boat.Warranty_Entry_Date__c = system.today();
    	boat.Warranty_Registration_Date__c = system.today(); 
    	boat.Purchase_Date__c = system.today();
    	boat.Owner_Street__c = '123 Main St';   		
    	boat.Owner_State__c = 'CO';
    	boat.Owner_City__c = 'Boulder';
    	boat.Owner_Zip__c = '80305'; 
    	boat.Owner_FirstName__c = 'Kirsten';
    	boat.Owner_LastName__c = 'Lamphere';
    	boat.Owner_Email__c = 'test@newboat.com';
    	boat.Status__c = 'Active';
    	
    	return boat;
	}
	
	private static Owner_Boat_Relationship__c createOwnerBoatRelationship(Account o, Boat__c boat) {
		Owner_Boat_Relationship__c  boatOwnerShip = new Owner_Boat_Relationship__c();
        boatOwnerShip.HIN_Number__c = boat.Id;
        boatOwnerShip.Owner__c = o.Id;
        boatOwnerShip.Status__c = 'Active';
        
        return boatOwnerShip;	
	}
}