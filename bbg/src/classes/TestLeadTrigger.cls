/*
Developer   : Poundarik, Shruti
Company 	: Bluewolf LLC

Modified By : Ruivo, Tiago
Date : 12/12/2013
Changes : Tested funtionality to update consumer action's boat_owner__c when lead is converted
*/
@isTest
public class TestLeadTrigger {

     static Lead ld;
     static Account dealer;
     static map<String,Id> selectedRecordTypes = new map<String,Id>();
     static Account dealerAcc1, dealerAcc2, dealerAcc3;
     
 	 static RecordType allowedLeadRecordType;
 	 
     private static void insertDisableRoutingSetting(){
     	List<DisableLeadRoutingTrigger__c> dlrtList= DisableLeadRoutingTrigger__c.getall().values();
     	if(dlrtList.size()>0)
     		delete dlrtList;
     	
     	DisableLeadRoutingTrigger__c dlrt= new DisableLeadRoutingTrigger__c();	
    	dlrt.Name='LeadRouting';
    	insert dlrt;
     }
     
     private static void insertAllowedLeadRecordTypeCS(){
     	
     	List<RecordType> recTypes= [SELECT Id, developerName from RecordType where SObjectType='Lead' and isActive=true LIMIT 2];
        List<LeadRoutingAllowedRecordTypes__c> csAllowedRecordTypes= new List<LeadRoutingAllowedRecordTypes__c>();
        allowedLeadRecordType = recTypes[0];
        csAllowedRecordTypes.add(new LeadRoutingAllowedRecordTypes__c(Name=allowedLeadRecordType.developerName));
        insert csAllowedRecordTypes;
     }
     
     @isTest (SeeAllData=true) static void createConsumerActions(){
     	
     	givenLeadCreation();
     	thenConsumerActionCreated();
     }
     
     private static void givenLeadCreation(){
     	insertDisableRoutingSetting();
     	ld = TestServices.getLead();
     	ld.Lead_Form_Name__c ='Bluewolf';
     	insert ld;
     }
     
     private static void thenConsumerActionCreated(){
     	list<ConsumerActions__c> cs = [Select Id from ConsumerActions__c where Lead_Name__c = :ld.Id];
     	
     	system.assertEquals(1,cs.size(),'Consumer Action not created');
     }
     
     
      @isTest (SeeAllData=true) static void updateConsumerActions(){
     	givenLeadCreation();
     	whenLeadUpdated();
     	thenConsumerActionGetsUpdated();
     }
     
     private static void whenLeadUpdated(){
     	 ld.Boat_Class_Interest__c = 'Runabouts';
     	 update ld;
     }
     
     private static void thenConsumerActionGetsUpdated(){
     	list<ConsumerActions__c> cs = [Select Boat_Class__c from ConsumerActions__c where Lead_Name__c = :ld.Id];
     	
     	system.assertEquals(1,cs.size(),'Consumer Action not created');
     	//system.assertEquals( 'Test Company',cs[0].Boat_Class__c,'Consumer Action not updated');
     }
     
     @isTest (SeeAllData=true) static void sendEmailAsAttachment(){
     	givenMarineMaxDealer();
     	whenleadCreated();
     	thenSendXMLAsAttachment();     	
     }
     
     private static void givenMarineMaxDealer(){
     	selectedRecordTypes = TestServices.getRecordTypes();
     	dealer = TestServices.getAccount();
     	dealer.RecordTypeId = selectedRecordTypes.get('Dealer');
     	dealer.CRM_System__c = 'Microsoft Dynamics';
     	dealer.ShippingStreet ='21 st';
     	dealer.ShippingState = 'New York';
     	dealer.ShippingCity = 'New York';
     	dealer.ShippingPostalCode ='11111';
     	insert dealer;
     	
     }
     
     private static void whenleadCreated(){
     	insertDisableRoutingSetting();
     	
     	ld = TestServices.getLead();
     	ld.Lead_Form_Name__c ='Bluewolf';
     	ld.Assigned_Dealer_1__c = dealer.Id;
     	ld.Street ='111 Street';
     	ld.City = 'New York';
     	ld.State ='New York';
     	ld.County__c ='United States';
     	
     	insert ld;
     }
     
     private static void thenSendXMLAsAttachment(){
     	
     }
    
     @isTest (SeeAllData=true) static void t() {
     	givenDealers();
     	
     	insertDisableRoutingSetting();
     	LeadServices.bypassTaskTrigger = true;
     	
     	ld = TestServices.getLead();
     	ld.Lead_Form_Name__c ='Bluewolf';
     	ld.Assigned_Dealer_1__c = dealerAcc1.Id;
     	ld.Assigned_Dealer_2__c = dealerAcc2.Id;
     	ld.Assigned_Dealer_3__c = dealerAcc3.Id;
     	ld.Brand_Interest__c = 'Bayliner';
     	insert ld;
     	
     	Task task = TestServices.getLeadTask(ld);
     	insert task;
     	
     	ld = [SELECT  
                Id,
                Name,
                Brand_Code__c, 
                Lead_Emails_Sent__c,
                Street,
                City, 
                State,
                Country, 
                county__c,
                PostalCode,
                Phone,
                Home_Phone__c,
                Work_Phone__c,
                Email,
                Alternate_Email_Address__c,
                Lead_Form_Name__c,
                Type_of_inquiry__c,
                LeadSource, 
                latitude__c, 
                longitude__c, 
                GeoLocation__Latitude__s,
                GeoLocation__Longitude__s,
                GeoNames_WebService_Error__c,
                Country_ISO_Code__c,
                CreatedDate,
                Previous_Boat_Owner__c,
                Current_Owned_Brand__c,
                Current_Owned_Boat_Class__c,
                Currently_Owned_Year__c,
                Current_Owned_ID_Number__c,
                Current_Owned_Model__c,
                Boat_Model_Interest__c,
                Boat_Class_Interest__c,
                Boat_Category_of_Interest__c,
                Boat_Year_Interest__c,
                Interested_in_Stock_Number__c,
                Interested_in_Length__c,
                Interested_in_ID_Number__c,
                Buying_horizon__c,
                RecordTypeId,
                Notes__c,
                (Select t.Subject, t.LastModifiedDate, t.WhoId From Tasks t Order By t.LastModifiedDate Desc Limit 7)  //BS-225
                FROM Lead 
                WHERE id = :ld.Id];
     	
     	System.assertNotEquals(null, LeadServices.getXML(dealerAcc1, ld));
     	System.assertEquals(2, LeadServices.uniqueIds(new List<Id>{dealerAcc1.Id,dealerAcc2.Id,dealerAcc1.Id}).size());
     }
     
     @isTest (SeeAllData=true) static void testTaskInsert() {
     	givenDealers();
     	
     	insertDisableRoutingSetting();
     	LeadServices.bypassTaskTrigger = true;
     	
     	ld = TestServices.getLead();
     	ld.Lead_Form_Name__c ='Bluewolf';
     	ld.Assigned_Dealer_1__c = dealerAcc1.Id;
     	ld.Assigned_Dealer_2__c = dealerAcc2.Id;
     	ld.Assigned_Dealer_3__c = dealerAcc3.Id;
     	ld.Brand_Interest__c = 'Sea Ray';
     	insert ld;
     	
     	Task task = TestServices.getLeadTask(ld);
     	insert task;
     	
     	ld = [SELECT  
                Id,
                Name,
                Brand_Code__c, 
                Lead_Emails_Sent__c,
                Street,
                City, 
                State,
                Country, 
                county__c,
                PostalCode,
                Phone,
                Home_Phone__c,
                Work_Phone__c,
                Email,
                Alternate_Email_Address__c,
                Lead_Form_Name__c,
                Type_of_inquiry__c,
                LeadSource, 
                latitude__c, 
                longitude__c, 
                GeoLocation__Latitude__s,
                GeoLocation__Longitude__s,
                GeoNames_WebService_Error__c,
                Country_ISO_Code__c,
                CreatedDate,
                Previous_Boat_Owner__c,
                Current_Owned_Brand__c,
                Current_Owned_Boat_Class__c,
                Currently_Owned_Year__c,
                Current_Owned_ID_Number__c,
                Current_Owned_Model__c,
                Boat_Model_Interest__c,
                Boat_Class_Interest__c,
                Boat_Category_of_Interest__c,
                Boat_Year_Interest__c,
                Interested_in_Stock_Number__c,
                Interested_in_Length__c,
                Interested_in_ID_Number__c,
                Buying_horizon__c,
                RecordTypeId,
                Notes__c,
                (Select t.Subject, t.LastModifiedDate, t.WhoId From Tasks t Order By t.LastModifiedDate Desc Limit 7)  //BS-225
                FROM Lead 
                WHERE id = :ld.Id];
     	
     	System.assertNotEquals(null, LeadServices.getXML(dealerAcc1, ld));
     	System.assertEquals(2, LeadServices.uniqueIds(new List<Id>{dealerAcc1.Id,dealerAcc2.Id,dealerAcc1.Id}).size());
     }     
    
     private static void  givenDealers(){
       selectedRecordTypes = TestUtilities.getRecordTypesMap();
       list<Account> dealerLists = TestUtilities.createTestAccount(3,'test',selectedRecordTypes.get('Dealer'),'112 E. HIGH STREET', 'HENNEPIN','IL','61327','United States','US', '111 555 2222','bluewolf.com','SR');
       insert dealerLists;
       dealerAcc1 = dealerLists[0];
       dealerAcc2 = dealerLists[1]; 
       dealerAcc3 = dealerLists[2];
       
       Dealer_Brand__c db1 = TestUtilities.createDealerBrand(dealerLists[0],1);
       insert db1;
       Dealer_Brand__c db2 = TestUtilities.createDealerBrand(dealerLists[1],1);
       insert db2;
                                    
    }
   
    
    //Check if changes boat owner of consumer action when converted
    @isTest static void convertedLeadUpdate(){
    	
    	final Integer NUM_OF_ACTIONS_PER_LEAD = 3;
    	
    	selectedRecordTypes = TestServices.getRecordTypes();
    	Account acct = TestUtilities.createTestAccount(1,'test',selectedRecordTypes.get('Dealer'),'112 E. HIGH STREET', 'HENNEPIN','IL','61327','United States','US', '111 555 2222','bluewolf.com','SR')[0];
		insert acct;
    	
    	insertDisableRoutingSetting();
    	
    	//Get 10 leads with false convertion status
    	List<Lead> leads= new List<Lead>();
    	for (Integer i=0;i<3;i++){
    		Lead l=TestServices.getLead();
    		l.Lead_Form_Name__c ='Bluewolf';
    		leads.add(l);
    		  		  		
    	}
    	
    	//Insert them
    	 insert leads;
    	
    	//Get Ids
    	Map <Id, Lead> leadsId=new Map <Id,Lead>( leads );
		List<ConsumerActions__c> actionsToCreate = new List<ConsumerActions__c>();
		
		for( Lead leadCreated : leads )
    	{
    		for( ConsumerActions__c cAction : TestUtilities.createConsumerActions( 'Test Consumer', NUM_OF_ACTIONS_PER_LEAD, false ) )
    		{
    			cAction.Lead_Name__c = leadCreated.Id;
				actionsToCreate.add( cAction );    			
    		}
    	}
    	
    	insert actionsToCreate;
    		
    	Test.startTest();
    	//Get lead convert
    	List <Database.LeadConvert> leadsToConvert = new List <Database.LeadConvert>();
    	List <Database.LeadConvertResult> lcr= new List <Database.LeadConvertResult>();
		String status=[SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true limit 1].MasterLabel;
		
		for(Integer i=0; i<leads.size(); i++){
			leadsToConvert.add(new Database.LeadConvert());
			leadsToConvert[i].setLeadId(leads[i].id);
			leadsToConvert[i].setAccountId(acct.Id);
			leadsToConvert[i].setConvertedStatus(status);
		}
		Database.LeadConvertResult[] lcResults = Database.convertLead(leadsToConvert);
		
		List<ConsumerActions__c> consumerActions= [SELECT Boat_Owner__c, Lead_Name__c FROM ConsumerActions__c];
		
		Test.stopTest();
    	
    	System.assert( consumerActions.size() >= (NUM_OF_ACTIONS_PER_LEAD * 3), 'We should have the same size, if not more, of the consumer actions that we created'  );
    	
    	Map<Id, Lead> actualLeadsMap = new Map<Id, Lead>([Select Id, ConvertedAccountId from Lead ]);
		
		//Leads converted correctly
		for (Database.LeadConvertResult cr: lcResults){
			System.assert(cr.isSuccess());	
		}
		
		//Changes have been made
		for (ConsumerActions__c ca: consumerActions){
			System.assertEquals(actualLeadsMap.get(ca.Lead_Name__c).ConvertedAccountId,ca.Boat_Owner__c);
		}

    	
    }

    @isTest static void convertedLeadErrorHandlingTest(){
    	
    	insertDisableRoutingSetting();
    	
    	List<Lead> leads= new List<Lead>();
    	
    	for (Integer i=0;i<2;i++){
    		Lead l=TestServices.getLead();
    		l.Lead_Form_Name__c ='Bluewolf';
    		leads.add(l);
    		  		  		
    	}
    	
    	insert leads;
    	Map <Id, Lead> leadsMap = new Map <Id,Lead>( leads );
    	
    	//Create some valid actions on lead 1
    	ConsumerActions__c cAction1 = TestUtilities.createConsumerActions( 'Test Consumer', 1, false )[0];
		cAction1.Lead_Name__c = leads[0].Id;

		insert cAction1;
			
    	//Create some invalid actions on lead 2
    	ConsumerActions__c cAction2 = TestUtilities.createConsumerActions( 'Test Consumer', 1, false )[0];
		cAction2.Lead_Name__c = leads[1].Id;
		TestUtilities.dummyInsert (new List<ConsumerActions__c> {cAction2});
		
		List<ConsumerActions__c> actionsToUpdate = new List<ConsumerActions__c>();
		
		actionsToUpdate.add( cAction1 );    			
		actionsToUpdate.add( cAction2 );    			

		Test.startTest();
			LeadServices.updateConsumerActions(actionsToUpdate, leadsMap );
		Test.stopTest();
			
		System.assert( TestUtilities.pageMessageContains( leads[1].id ), 'The lead with the error should be contained in the error message');	
		System.assert( !TestUtilities.pageMessageContains( leads[0].id ), 'The lead without the error should not be contained in the error message');	
    	
    	
    }
    
    @isTest static void testBatchBehavior(){
    	GeoNamesWebService.isApexTest=true;
    	LeadServices.isBatch=true;
    	
    	insertDisableRoutingSetting();
    	insertAllowedLeadRecordTypeCS();
    	
    	List <Lead> leads= TestUtilities.createLeads(allowedLeadRecordType.Id, 100,false);
    	for (Lead l: leads){
    		l.PostalCode='60622';
    	}
    	
    	Test.startTest();
    	try{
    	insert leads;
    	} catch (Exception e){
    		System.assert(false, 'Cannot handle more than 10 leads. Error: ' + e.getMessage());
    	}
    	
    	List <Lead> insertedLeads = [SELECT County__c from Lead where Id IN :leads]; 
    	
    	for (Lead l: leads){
    		l.PostalCode='60616';
    	}
    	
    	update leads;
    	List <Lead> updatedLeads = [SELECT County__c from Lead where Id IN :leads]; 
    	Test.stopTest();
    	
    	System.assertEquals(leads.size(), insertedLeads.size(), 'Insertion was not sucessful');
    	for(Lead l: insertedLeads){
    		System.assertEquals(null, l.County__c, 'GeoNames service was called when inserting lead');
    	}
    	
    	System.assertEquals(leads.size(), updatedLeads.size(), 'Update was not sucessful');
    	for(Lead l: updatedLeads){
    		System.assertEquals(null, l.County__c, 'GeoNames service was called when updating lead');
    	}
    	   	
    }

}