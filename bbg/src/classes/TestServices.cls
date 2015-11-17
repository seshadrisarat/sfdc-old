/*
Developer   : Poundarik, Shruti
Company   : Bluewolf LLC
*/
@isTest
public class TestServices {
  
  final static String DEALER = 'Dealer';
  final static String OWNER = 'Owner';
    final static map<String,Id> selectedRecordTypes = new map<String,Id>();
  
  public static map<String,Id> getRecordTypes(){
      
      final set<String> recordTypeNames = new Set<String>{DEALER,OWNER};      
      for(RecordType rt :[Select id,developerName from RecordType where developerName  In :recordTypeNames And SobjectType = 'Account']){        
        selectedRecordTypes.put(rt.developerName, rt.Id);
      }
      return selectedRecordTypes;
    }
    
  public static Id srTaskRecordTypeId {
  	get {
        if (srTaskRecordTypeId == null){
            srTaskRecordTypeId = [Select Id, DeveloperName From RecordType Where SobjectType = 'Task' and DeveloperName = 'Sea_Ray_Task'].Id;
        }
        return srTaskRecordTypeId;
  	}
  	set;
  }
    
     public static Lead getLead(){      
      return new Lead(
      firstName = 'first',
      LastName = 'Last',
      Company = 'Test Lead',
      status ='Open');
    }
    
    public static Task getLeadTask(Lead lead) {
    	Task t = new Task();
		t.WhoId = lead.Id;
		t.Subject = lead.Brand_Code__c + ': Test Lead';
		t.Status = 'Completed';
		t.RecordTypeId = srTaskRecordTypeId;
		t.Priority = 'Low';
		t.Description = 'Completed the ' + lead.Brand_Code__c + ': Test Lead';
		t.ActivityDate = Date.today();
		return t;
    }
    
    public static Account getAccount(){     
      return new Account(
      Name ='Test');      
    }
    
    public static list<Boat__c> getBoats(Integer size){
      list<Boat__c> bt = new list<Boat__c>();
      for(Integer i=0; i<size ;i++){
        Boat__c b = new Boat__c();
        b.Name = 'test '+i;             
        bt.add(b);
      }
      return  bt;
    }

    public static Boat__c createBoat(String boatName,String ownerLastName, String brand, Boolean doInsert){
    Boat__c boat= new Boat__c(Name=boatName, Owner_LastName__c=ownerLastName, Brand_del__c = brand);
    if(doInsert){
      insert boat;
    }
    return boat;
  }

  public static List<Boat__c> createBoats(Integer numToCreate, Boolean doInsert){
    List<Boat__c> boats= new List<Boat__c>();

    for(Integer i=0;i<numToCreate; i++){
      boats.add(TestServices.createBoat('Test' + i, 'TestOwner', 'SR', false));
    }

    if(doInsert){
      insert boats;
    }
    return boats;
  }
    
    public static Contact getContact(){
      return new Contact();
    }

    public static Owner_Boat_Relationship__c createOwnerBoatRelationship(Id accountID, Id boatId, Boolean doInsert){
      Owner_Boat_Relationship__c obr=new Owner_Boat_Relationship__c(HIN_Number__c=boatId, Owner__c=accountID, Status__c='Active');
      if(doInsert){
        insert obr;
      }
      return obr;
    }
    public static Dealer_Brand__c createDealerBrandRelationship(Id accountID, String brandName, Boolean doInsert){
      Dealer_Brand__c dbr = new Dealer_Brand__c(Dealer__c=accountID, Brand__c= brandName, Status__c='Active');
      if(doInsert){
        insert dbr;
      }
      return dbr;
    }

    public static List<Owner_Boat_Relationship__c> createOwnerBoatRelationships(List<Account> accounts, List<Boat__c> boats, Boolean doInsert){
      List<Owner_Boat_Relationship__c> boatRelationships = new List<Owner_Boat_Relationship__c>();
      for(Boat__c boat: boats){
        for(Account a: accounts){
          boatRelationships.add(TestServices.createOwnerBoatRelationship(a.Id, boat.Id, false));
        }
      }
      if(doInsert){
        insert boatRelationships;
      }
      return boatRelationships;
    }
    public static List<Dealer_Brand__c> createDealerBrandRelationships(List<Account> accounts, String brandName, Boolean doInsert){
      List<Dealer_Brand__c> dealerBrands = new List<Dealer_Brand__c>();
	    for(Account a: accounts){
	      dealerBrands.add(TestServices.createDealerBrandRelationship(a.Id, brandName, false));
	    }

      if(doInsert){
        insert dealerBrands;
      }
      return dealerBrands;
    }
    
    public static User getUser(String username){
        Profile p = [select Id from Profile where name = 'System Administrator' limit 1];
        return new User(
      FirstName = 'testFirst'
      , LastName = 'testLast'
      , Username = username
      , Email = 'test@test.com'
      , IsActive = true
      , Alias = 'jdoe'
      , TimeZoneSidKey = 'GMT'
      , LocaleSidKey = 'en_US'
      , EmailEncodingKey = 'ISO-8859-1'
      , LanguageLocaleKey = 'en_US'
      , ProfileId = p.Id);
  }
}