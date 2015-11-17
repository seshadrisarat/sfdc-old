@isTest(SeeAllData=true)
private class AdallomTriggersTests {
	  public static sObject cloneObject(sObject sObjectId,
	                                        Schema.SObjectType objectType){
	    
	    List<String> sObjectFields = new List<String>{};
	    sObject clonedsObject = null;
	    
	    if (sObjectId == null) {
	    	return null;
	    }
	    
	    if(objectType != null){
	      sObjectFields.addAll(
	        objectType.getDescribe().fields.getMap().keySet());
	    }
	
	      String allSObjectFieldsQuery = 'SELECT ' + sObjectFields.get(0); 
	    
	      for (Integer i=1 ; i < sObjectFields.size() ; i++){
	        allSObjectFieldsQuery += ', ' + sObjectFields.get(i);
	      }
	    
	      allSObjectFieldsQuery += ' FROM ' + 
	                               objectType.getDescribe().getName() + 
	                               ' WHERE ID = \'' + sObjectId.Id + '\'';
	    
	      try{
	      
	        SObject sObjectFromDatabase = Database.query(allSObjectFieldsQuery);
	        clonedSObject = sObjectFromDatabase.clone(false,true);  
	    
	      } catch (exception e){}  
	    
	    return clonedSObject;
	 }
	
    static testMethod void testAccounts() {
    	try {
	        Boolean inserted = false;
	        Account testAccount = null;
	        
	        try {
	            testAccount = new Account(Name = 'TestAccount', BillingStreet = 'TestStreet', BillingCity = 'TestCity', BillingCountry = 'TestCountry');
	            insert testAccount;
	            inserted = true;
	        } catch (Exception e) {}
	        
	        if (!inserted) {	            
	            try {
	            	testAccount = [select Id from Account limit 1];	  	        
	            	Account testAccount2 = (Account)cloneObject(testAccount, testAccount.getsObjectType());
	            	insert testAccount2;
	            	testAccount = testAccount2;
	            } catch (Exception e) { }
	        }
	        
	        try {
	            update testAccount;
	        } catch (Exception e) { }
	        try {
	            delete testAccount;
	        } catch (Exception e) { }
    	} catch (Exception e) { }
    }
    
    static testMethod void testLeads() {
    	try {
	        Boolean inserted = false;
	        Lead testLead = null;
	        
	        try {
	            testLead = new Lead(LastName = 'TestLead', Company = 'TestCompany');        
	            insert testLead;
	            inserted = true;
	        } catch (Exception e) {}
	        
	        if (!inserted) {
	        	try {
	            	testLead = [select Id from Lead limit 1];
	            	Lead testLead2 = (Lead)cloneObject(testLead, testLead.getsObjectType());
	            	insert testLead2;
	            	testLead = testLead2;
	        	} catch (Exception e) { }
	        }
	        
	        try {
	            update testLead;
	        } catch (Exception e) { }
	        try {
	            delete testLead;
	        } catch (Exception e) { }
    	} catch (Exception e) { }
    }
    static testMethod void testContacts() {
    	try {
	        Boolean inserted = false;
	        Contact testContact = null;
	        
	        try {
	            testContact = new Contact(LastName = 'TestContact', MailingStreet = 'TestStreet', MailingCity = 'TestCity', MailingCountry = 'TestCountry');
	            insert testContact;
	            inserted = true;
	        } catch (Exception e) { }
	        
	        if (!inserted) {
	        	try {
	            	testContact = [select Id from Contact limit 1];
	            	Contact testContact2 = (Contact)cloneObject(testContact, testContact.getsObjectType());
	            	insert testContact2;
	            	testContact = testContact2;
	        	} catch (Exception e) { }
	        }
	        
	        try {
	            update testContact;
	        } catch (Exception e) { }
	        try {
	            delete testContact;
	        } catch (Exception e) { }
    	} catch (Exception e) { }
    }
    static testMethod void testOpportunities() {
    	try {
	        Boolean inserted = false;    
	        Opportunity testOpportunity = null;
	        
	        try {
	            testOpportunity = new Opportunity(Name = 'TestOpportunity', StageName = 'Closed Won', CloseDate = system.now().date());
	            insert testOpportunity;    
	            inserted = true;
	        } catch (Exception e) { }
	        
	        if (!inserted) {
	        	try {
	            	testOpportunity = [select Id from Opportunity limit 1];
	            	Opportunity testOpportunity2 = (Opportunity)cloneObject(testOpportunity, testOpportunity.getsObjectType());
	            	insert testOpportunity2;
	            	testOpportunity = testOpportunity2;
	        	} catch (Exception e) { }
	        }
	        
	        try {
	            update testOpportunity;    
	        } catch (Exception e) { }
	        try {
	            delete testOpportunity;
	        } catch (Exception e) { }
    	} catch (Exception e) { }
    }
    
    static testMethod void testProduct2() {
    	try {
	        Boolean inserted = false;
	        Product2 testProduct = null;
	        
	        try {
	            testProduct = new Product2(Name = 'TestProduct');
	            insert testProduct;
	            inserted = true;
	        } catch (Exception e) { }
	        
	        if (!inserted) {
	        	try {
		            testProduct = [select Id from Product2 limit 1];
		            Product2 testProduct2 = (Product2)cloneObject(testProduct, testProduct.getsObjectType());
		            insert testProduct2;
		            testProduct = testProduct2;
	        	} catch (Exception e) { }
	        }
	        
	        try {        
	            update testProduct;
	        } catch (Exception e) { }
	        try {
	            delete testProduct;
	        } catch (Exception e) { }
    	} catch (Exception e) { }
    }
    
    static testMethod void testTasks() {
    	try {
	        Boolean inserted = false;
	        Task testTask = null;
	        
	        try {
	            testTask = new Task(Subject = 'TestTask');
	            insert testTask;
	            inserted = true;
	        } catch (Exception e) { }
	        
	        if (!inserted) {
	        	try {
	            	testTask = [select Id from Task limit 1];
	            	Task testTask2 = (Task)cloneObject(testTask, testTask.getsObjectType());
	            	insert testTask2;
	            	testTask = testTask2;
	        	} catch (Exception e) { }
	        }
	        
	        try {
	            update testTask;
	        } catch (Exception e) { }
	        try {
	            delete testTask;
	        } catch (Exception e) { }
    	} catch (Exception e) { }
    }
}