@isTest
public with sharing class OwnerClassOfInterestUpdateJob_Test {
	
	private static Id OWNER_RECORD_TYPE_ID = [select Id from recordtype where developerName='Owner' limit 1].Id;
	
	static testMethod void test() {
		
		// create some boats, owners and owner boat relationships
		List<Account> owners = new List<Account>();
		
		// create boats
		List<Boat__c> boats = createBoats();
		insert boats;
		
		// create owners
		owners.add(createOwner('Owner1'));
		owners.add(createOwner('Owner2'));
		owners.add(createOwner('Owner3'));
		owners.add(createOwner('Owner4'));
		insert owners;

		// create owner boat relationship
		List<Owner_Boat_Relationship__c> obrs = new List<Owner_Boat_Relationship__c>();
		// owner1 - has 2 Active boats, most recent one is a cruiser
		obrs.add(createOwnerBoatRelationship(owners.get(0).id, boats.get(0).id, 'Active', Date.newInstance(2000, 1, 1)));
		obrs.add(createOwnerBoatRelationship(owners.get(0).id, boats.get(1).id, 'Active', Date.newInstance(2010, 1, 1)));
		
		// owner2 - has 1 inactive boat
		obrs.add(createOwnerBoatRelationship(owners.get(1).id, boats.get(2).id, 'Inactive', Date.newInstance(2010, 1, 1)));
		
		// owner3 - has inactive boat and active boat
		obrs.add(createOwnerBoatRelationship(owners.get(2).id, boats.get(3).id, 'Inactive', Date.newInstance(2010, 1, 1)));
		obrs.add(createOwnerBoatRelationship(owners.get(2).id, boats.get(4).id, 'Active', Date.newInstance(2000, 1, 1)));
		
		// owner4 - has two inactive boats
		obrs.add(createOwnerBoatRelationship(owners.get(3).id, boats.get(5).id, 'Inactive', Date.newInstance(2010, 1, 1)));
		obrs.add(createOwnerBoatRelationship(owners.get(3).id, boats.get(6).id, 'Active', Date.newInstance(2000, 1, 1)));
		insert obrs;
		
		Test.startTest();
		Id batchJobId = Database.executeBatch(new OwnerClassOfInterestUpdateJob('SR', 100));
		Test.stopTest();
		
		// check owner class
		String cruiserClass = [select Boat_Category_of_Interest__pc from Account where firstName = 'Owner1'].Boat_Category_of_Interest__pc;
		system.assertEquals('Sport Cruisers', cruiserClass, 'Owner 1 should be cruiser boat class');
		
		String yachtClass = [select Boat_Category_of_Interest__pc from Account where firstName = 'Owner2'].Boat_Category_of_Interest__pc;
		system.assertEquals('Yachts', yachtClass, 'Owner 2 should be yacht boat class');
		
		String owner3Class = [select Boat_Category_of_Interest__pc from Account where firstName = 'Owner3'].Boat_Category_of_Interest__pc;
		system.assertEquals('Sport Cruisers', owner3Class, 'Owner 3 should be cruiser boat class');
		
		String owner4Class = [select Boat_Category_of_Interest__pc from Account where firstName = 'Owner4'].Boat_Category_of_Interest__pc;
		system.assertEquals('Sport Boats', owner4Class, 'Owner 4 should be sport boat class');
	}
	
	private static Owner_Boat_Relationship__c createOwnerBoatRelationship(Id accountID, Id boatId, String status, Date purchaseDate){
      Owner_Boat_Relationship__c obr=new Owner_Boat_Relationship__c(HIN_Number__c=boatId, Owner__c=accountID, Status__c= status, Purchase_Date__c=purchaseDate);
      return obr;
    }
	
	private static Account createOwner(String firstName) {
		Account bo = new Account();
		bo.RecordTypeId = OWNER_RECORD_TYPE_ID;
       // bo.OwnerId = Configuration__c.getInstance('BoatOwner').RecordId__c;
		bo.FirstName = firstName;
    	bo.LastName = 'Owner';
    	bo.PersonEmail = 'test@newboat.com';
    	bo.PersonMailingStreet  = '123 Main St';
        bo.PersonMailingState = 'CO';
        bo.PersonMailingCity = 'Boulder';
        bo.PersonMailingPostalCode = '80305';
        bo.Brand__c = 'SR';
    	
    	return bo;
	}
	
	private static List<Boat__c> createBoats() {
		List<Boat__c> boats = new List<Boat__c>();
		String[] boatModelClasses = new String[]{'Sport Boats', 'Sport Cruisers', 'Yachts'};
		boats.add(createBoat('SR1001', '2001', boatModelClasses[0]));
		boats.add(createBoat('SR1002', '2001', boatModelClasses[1]));
		boats.add(createBoat('SR1003', '2001', boatModelClasses[2]));
		boats.add(createBoat('SR1004', '2001', boatModelClasses[0]));
		boats.add(createBoat('SR1005', '2001', boatModelClasses[1]));
		boats.add(createBoat('SR1006', '2001', boatModelClasses[2]));
		boats.add(createBoat('SR1007', '2001', boatModelClasses[0]));
		boats.add(createBoat('SR1008', '2001', boatModelClasses[1]));
		boats.add(createBoat('SR1009', '2001', boatModelClasses[2]));
		return boats;
	}
	
	private static Boat__c createBoat(String hin, String modelYear, String boatClass) {
		Boat__c boat = new Boat__c();
		boat.Name = hin;
		boat.Model_Year__c = modelYear;
		boat.Boat_Class__c = boatClass;
		boat.Brand_del__c = 'SR';
		return boat;
	}
}