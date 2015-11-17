@isTest
public class TestUtilities {
	
	public Contact 		aContac			{get; set;}
	public Attachment 	aAttachment		{get; set;}
	
	public void generateContact(){

	    this.aContac 				= new Contact();
	    this.aContac.firstName 		= 'Test';
	    this.aContac.LastName 		= 'Test'; 
	    
	    insert this.aContac;

	    this.aAttachment = new Attachment();
	    this.aAttachment.Body = Blob.valueOf('String');
	}
	
	public static TestUtilities generateTest(){
		TestUtilities e = new TestUtilities();
		e.generateContact();
		return e;
	}
	
	/*
	  Modified :Bluewolf
	*/
	
	public static User ADMIN_USER
    {
        get
        {
            if( ADMIN_USER == null )
                ADMIN_USER = [ SELECT Id FROM User WHERE (Profile.Name = 'System Administrator') AND IsActive=true LIMIT 1 ];
            return ADMIN_USER;
        }
        private set;
    }
    
	public static String DEALER = 'Dealer';
	public static String OWNER_ACCOUNT = 'Owner';

	
	public static Map<String, Id> getRecordTypesMap(){

		Set<String> recordTypeNames = new Set<String>{DEALER,OWNER_ACCOUNT};
    	Map<String,Id> selectedRecordTypes = new Map<String, Id>();
    	for(RecordType rt :[Select
                                Id,
                                DeveloperName
                            From RecordType
                            Where DeveloperName IN :recordTypeNames And SobjectType = 'Account']){
            selectedRecordTypes.put(rt.DeveloperName, rt.Id);
    	}
    	return selectedRecordTypes;
    }

    public static Map<String, Id> RECORD_TYPES{
    	get{
    		if(RECORD_TYPES==null){
    			RECORD_TYPES=getRecordTypesMap();
    		}
    		return RECORD_TYPES;
    	}
    	private set;
    }
    
	public static list<Account> createTestAccount(Integer accCount,
											String acctName, 
											String recordTypeId,
											String ShippingStreet,
											String ShippingCity,
											String ShippingState,
											String ShippingPostalCode,
											String ShippingCountry,
											String isoCode,
											String Phone,
											String Website,
											String brand){	
		
		list<Account> accountList = new list<Account>();
		for(Integer index=0; index < accCount; index++){
			Account acc = new Account();
		    acc.recordTypeId = recordTypeId;
		    acc.Name = acctName + index;
		    acc.ShippingStreet = ShippingStreet;
		    acc.ShippingCity = ShippingCity;
		    acc.ShippingState = ShippingState;
		    acc.ShippingPostalCode = ShippingPostalCode;
		    acc.ShippingCountry = ShippingCountry;
		    acc.Country_ISO_Code__c = isoCode;
		    acc.Phone = Phone;
		    acc.Website = Website;	
		    acc.Brand__c = brand;
		    accountList.add(acc);	
	    }
		  return accountList;
	}

	public static List<Contact> createContacts(Integer howMany, Boolean doInsert){
		List<Contact> contacts= new List<Contact>();
		for(Integer i=0; i<howMany;i++){
			contacts.add(new Contact(
				LastName='Test'+i));
		}
		if(doInsert){
			insert contacts;
		}
		return contacts;
	}



	private static Integer dealerOffset=0;
	public static List<Account> createTestDealerAccounts(Integer howMany, Boolean doInsert){
		List<Account> accounts= createTestAccount(howMany,
													'Test',
													RECORD_TYPES.get(DEALER),
													'Main Street',
													'Atlanta',
													'GA',
													'12345',
													'USA',
													'US',
													'1234567890',
													'www.why.com',
													'SR');
		for(Account a: accounts){
			a.Dealer_Number__c=''+dealerOffset;
			dealerOffset++;
		}
		if(doInsert){
			insert accounts;
		}
		return accounts;
	}
	public static List<Account> createTestOwnerAccounts(Integer howMany, Boolean doInsert){
		List<Account> accounts= new List<Account>();
		for(Integer index=0; index < howMany; index++){
			Account acc = new Account();
		    acc.recordTypeId = RECORD_TYPES.get(OWNER_ACCOUNT);
		    acc.FirstName='Test';
		    acc.LastName = 'Test' + index;
		    acc.ShippingStreet = 'Main Street';
		    acc.ShippingCity = 'Atlanta';
		    acc.ShippingState = 'GA';
		    acc.ShippingPostalCode = '12345';
		    acc.ShippingCountry = 'USA';
		    acc.Country_ISO_Code__c = 'US';
		    acc.Phone = '1234567890';
		    acc.Website = 'www.why.com';	
		    acc.Brand__c = 'SR';
		    accounts.add(acc);	
	    }

		if(doInsert){
			insert accounts;
		}
		return accounts;
	}

	public static List<Event> createEvents(Integer howMany, Id recordTypeId, Id whatId, Id whoId, Boolean doInsert){
		List<Event> events = new List<Event>();
		for (Integer i = 0 ; i < howMany ; i++){
			events.add(new Event(Subject='SubjectTest_'+i, WhatId = whatId, WhoId = whoId, RecordTypeId = recordTypeId,
								StartDateTime=Datetime.now().addDays(1), EndDateTime=Datetime.now().addDays(4)));
		}
		if (doInsert)
			insert events;
		return events;
	}
	public static List<Task> createTasks(Integer howMany, Id recordTypeId, Id whatId, Id whoId, Boolean doInsert){
		List<Task> tasks = new List<Task>();
		for (Integer i = 0 ; i < howMany ; i++){
			tasks.add(new Task(Subject='SubjectTest_'+i, WhatId = whatId, WhoId = whoId,
			 					RecordTypeId = recordTypeId, Status = 'In Progress', Priority='Normal'));
		}
		if (doInsert)
			insert tasks;
		return tasks;
	}
	
	public static list <Lead> createLeads(Id recTypeId, Integer numLeads, Boolean doInsert){
		List <Lead> leads=new List <Lead>();
		for (Integer i=0;i<numLeads;i++){
			leads.add(new Lead(
		   		firstName = 'first',
		   		LastName = 'Last',
		   		Company = 'Test Lead',
		   		status ='Open',
		   		RecordTypeId=recTypeId));
		}
		if(doInsert){
			insert leads;
		}
		return leads;
	}
	
	public static list <Lead> createLeads(Id recTypeId, string brandName, Integer numLeads, Boolean doInsert){
		List <Lead> leads=new List <Lead>();
		for (Integer i=0;i<numLeads;i++){
			leads.add(new Lead(
		   		firstName = 'first',
		   		LastName = 'Last',
		   		Brand_Interest__c = brandName,
		   		Company = 'Test Lead',
		   		status ='Open',
		   		RecordTypeId=recTypeId));
		}
		if(doInsert){
			insert leads;
		}
		return leads;
	}
	
	public static list<Dealer_Brand__c> createDealerBrand(list<Account> dealerAcc){
		list<Dealer_Brand__c> dbList = new list<Dealer_Brand__c>();
		for(Integer index=0; index < dealerAcc.size(); index++){
			Dealer_Brand__c db = new Dealer_Brand__c();
			db.Name = 'dealerBrand-'+index;
			db.Status__c = 'Active';
			db.Dealer__c = dealerAcc[index].Id;
			dbList.add(db);
		}
		return dbList;
	}
	
	public static Dealer_Brand__c createDealerBrand(Account dealerAcc ,Integer index){
		Dealer_Brand__c db = new Dealer_Brand__c();
		db.Name = 'dealerBrand-'+index;
		db.Status__c = 'Active';
		db.Dealer__c = dealerAcc.Id;
		
		return db;
	}
	
	public static List<Territory__c> createTerritories( Dealer_Brand__c dBrand, Integer size, Boolean doInsert )
	{
		List<Territory__c> territoryList = new List<Territory__c>();
		
		for( Integer i = 0; i< size; i++)
		{
			territoryList.add( new Territory__c ( Dealer_Brand__c = dBrand.Id ) );
		}
		
		if( doInsert )
			insert territoryList;
		return territoryList;
	}

	public static List<ConsumerActions__c> createConsumerActions( String name, Integer size, Boolean doInsert )
	{
		List<ConsumerActions__c> consumerActionList = new List<ConsumerActions__c>();
		
		for( Integer i = 0; i< size; i++)
		{
			consumerActionList.add( new ConsumerActions__c ( Name = name + i) );
		}
		
		if( doInsert )
			insert consumerActionList;
		return consumerActionList;
	}
	
	
	public static Dealer_Locator_Rule__c createDealerLocatorRule(
																	String brandCode, 
																	String countryCode, 
																	String domesticOrNot, 
																	string website,
																	Boolean doInsert)
	{
		Dealer_Locator_Rule__c dealerLocatorRule = new Dealer_Locator_Rule__c();
		dealerLocatorRule.Brand_Code__c = brandCode;
		dealerLocatorRule.Country_Code__c = countryCode;
		dealerLocatorRule.Domestic_or_International__c = domesticOrNot;
		dealerLocatorRule.Website__c = website;
		
		if (doInsert)
			insert dealerLocatorRule;
		return dealerLocatorRule;
	}
	
	public static List<Country_ISO_Code_Lookup__c> createCountryISOCodeCS( Map<String, String> countryISOMap, Boolean doInsert )
	{
		List<Country_ISO_Code_Lookup__c> isoCustomSettingList = new List<Country_ISO_Code_Lookup__c>();
		
		for( String countryName : countryISOMap.keySet())
		{
			isoCustomSettingList.add( new Country_ISO_Code_Lookup__c ( Name = countryISOMap.get(countryName), Country__c = countryName ) );
		}
		
		if( doInsert )
			insert isoCustomSettingList;
		return isoCustomSettingList;
	}
	
	static Integer offsetForDummyInsert = 1;
    
    public static void dummyInsert(List<SObject> objects)
    {
           String Id_Prefix = objects[0].getSObjectType().getDescribe().getKeyPrefix();
           for( Integer i = 0; i < objects.size(); i++ )
           {
                   String idSuffix = String.valueOf( offsetForDummyInsert ).leftPad(12);
                   idSuffix = idSuffix.replace(' ', '0');
                   
                   objects[i].id= Id_Prefix + idSuffix;
                   offsetForDummyInsert+=1;
           }
   }
   
   public static Boolean pageMessageContains(String messageNeedle)
       {
               if( ApexPages.getMessages().size() > 0 )
               {
                       for (ApexPages.Message message : ApexPages.getMessages() ){

	                       if(message.getSummary().contains(messageNeedle))
	                               return true;
                       }
               }

               return false;
       }
       
    //Create test data for Lead Routing Rules. 
    public static Lead_Routing_Rule__c createLeadRoutingRule(String Brand, String brandCode, String countryCode, Integer numberOfAssignmentsToTry, String routingAttemptName, Boolean doDML){
    	Lead_Routing_Rule__c lrr = new Lead_Routing_Rule__c();
    	lrr.Name = Brand + CountryCode;
    	lrr.Brand_Code__c = brandCode;
    	lrr.Country_Code__c = countryCode;
    	lrr.Number_of_Leads_1__c = string.valueOf(numberOfAssignmentsToTry);
    	lrr.Routing_Attempt_1_Type__c = routingAttemptName;
   	    system.debug('lrr looks like: ' + lrr);
   	    if(doDML){
   	    	insert lrr;
   	    }
   	    return lrr;
    }   
    
    public static Lead_Routing_Rule__c createMultipleLeadRoutingRule(String Brand, String brandCode, String countryCode, Integer numberOfAssignmentsToTry, String routingAttemptName, String routingAttemptName1, Boolean doDML){
    	Lead_Routing_Rule__c lrr = new Lead_Routing_Rule__c();
    	lrr.Name = Brand + CountryCode;
    	lrr.Brand_Code__c = brandCode;
    	lrr.Country_Code__c = countryCode;
    	lrr.Number_of_Leads_1__c = string.valueOf(numberOfAssignmentsToTry);
    	lrr.Routing_Attempt_1_Type__c = routingAttemptName;
    	lrr.Routing_Attempt_2_Type__c = routingAttemptName1;
    	lrr.Number_of_Leads_2__c = string.valueOf(numberOfAssignmentsToTry);
    	
   	    system.debug('lrr looks like: ' + lrr);
   	    if(doDML){
   	    	insert lrr;
   	    }
   	    return lrr;
    }
}