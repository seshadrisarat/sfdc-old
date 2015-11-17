/**
 * \author Vladimir Dobrelya, Julia Kolesnik
 * \date 03 Sep 2012
 * \see https://silverline.jira.com/browse/SILVERLINE-113
 * \brief The test class for SL_Opportunity_Trigger_Handler
 */
 
@isTest
private class SL_Test_Opportunity_Trigger_Handler {

    /*@isTest static void UnitTest() {
        //INSERT TRIGGER
        
        //Inserting License_Price__c object for pPackageVersion
        License_Price__c oLicensePrice = pLicensePrice;
        
        //Inserting New Opportunity object with StageName = 'Closed Won'
        Opportunity oOpportunity = pOpportunity;
        
        //Getting all created Product Renewal Opportunities
        List<Opportunity> aOpportunities = [
            SELECT Name, AccountId, RecordTypeId, Probability
            FROM Opportunity
            WHERE Type = 'Renewal' AND
                StageName = 'Qualified Suspect' AND
                License__c = :pLicense.Id AND
                RecordTypeId = :pRecordTypeId_Product AND
                AccountId = :pLicense.sfLma__Account__c AND
                Number_of_Licenses__c = :pLicense.sfLma__Seats__c
        ];
        
        //Trigger must create just one Product Renewal Opportunity
        system.assertEquals( aOpportunities.size(), 1 );
        
        //Name of the Product Renewal Opportunity object should be like this:  Account.Name + 'some information' + ' Renewal';
        system.assert( aOpportunities[0].Name.startsWith( pAccount.Name ) );
        system.assert( aOpportunities[0].Name.endsWith( 'Renewal' ) );
        
        //Probability of the Product Renewal Opportunity object should be setted as 80%
        system.assertEquals( aOpportunities[0].Probability, 80 );
        system.assertEquals( aOpportunities[0].AccountId, pOpportunity.AccountId );
        
        //RecordType of the Product Renewal Opportunity object should be setted as Product RecordType
        system.assertEquals( aOpportunities[0].RecordTypeId, pRecordTypeId_Product );
        //-- END INSERT TRIGGER
        
        //UPDATE TRIGGER
        pOpportunity.Amount = 777;
        update pOpportunity;
        
        //Getting all created Product Renewal Opportunities
        aOpportunities = [
            SELECT Name, AccountId, RecordTypeId, Probability
            FROM Opportunity
            WHERE Type = 'Renewal' AND
                StageName = 'Qualified Suspect' AND
                License__c = :pLicense.Id AND
                RecordTypeId = :pRecordTypeId_Product AND
                AccountId = :pLicense.sfLma__Account__c AND
                Number_of_Licenses__c = :pLicense.sfLma__Seats__c
        ];
        
        //The trigger does not have to create a New Product Renewal Opportunity, because it already exists
        system.assertEquals( aOpportunities.size(), 1 );
        //-- END UPDATE TRIGGER
    }*/
    
    static Id pRecordTypeId_Product {
        get {
            if ( pRecordTypeId_Product == null ) {
                for ( RecordType oItem : [ SELECT Id FROM RecordType WHERE sObjectType = 'Opportunity' AND DeveloperName = 'Product' ] ) {
                    pRecordTypeId_Product = oItem.Id;
                }
            }
            return pRecordTypeId_Product;
        } private set;
    }
    
    static Id pRecordTypeId_Service {
        get {
            if ( pRecordTypeId_Service == null ) {
                for ( RecordType oItem : [ SELECT Id FROM RecordType WHERE sObjectType = 'Opportunity' AND DeveloperName = 'Services' ] ) {
                    pRecordTypeId_Service = oItem.Id;
                }
            }
            return pRecordTypeId_Service;
        } private set;
    }
    
    static Id pRecordTypeId_CO {
        get {
            if ( pRecordTypeId_CO == null ) {
                for ( RecordType oItem : [ SELECT Id FROM RecordType WHERE sObjectType = 'Opportunity' AND DeveloperName = 'Change_Orders' ] ) {
                    pRecordTypeId_CO = oItem.Id;
                }
            }
            return pRecordTypeId_CO;
        } private set;
    }
    
    /*static User pSalesUser {
        get {
            if ( pSalesUser == null ) {
                for ( User oItem : [ SELECT Id FROM User WHERE Name = 'Athanasia Kotopoulos' ] ) {
                    pSalesUser = oItem;
                }
            }
            return pSalesUser;
        } private set;
    }*/
    
    /**
    Test to see if a post is made to the Sales Wins chatter group when an opportunity's stage
    is set to 'Closed - Won'
    **/
    @isTest static void test_makeChatterPost()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' limit 1]; 
        User u = new User(Alias = 'bTest', Email='brock@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='brock@testorg.com');
        
        CollaborationGroup sWins = new CollaborationGroup	(Name='Test Sales Wins',
        													CollaborationType='Private');
        insert sWins;
        
        if (region.Id==null) {
			insert region;
			insert new pse__Permission_Control__c(pse__User__c=UserInfo.getUserId(), pse__Region__c=region.Id, pse__Resource_Request_Entry__c=true, pse__Timecard_Ops_Edit__c = true, pse__Staffing__c = true);
		}
        
        Test.startTest();
        System.runAs(u)
        {   
            insert acct;
            insert testOpp;
        }
             
            insert resourceRequest;
	    System.runAs(u)
	    {  
        	testOpp.StageName = 'Closed Won';
       		update testOpp;  
        }
       	Test.stopTest();
        
        
        list<FeedItem> postsMade =  [SELECT Id 
                                	FROM FeedItem
                                	WHERE InsertedById = :u.Id
                                	AND parentId = :sWins.Id];
        
        System.assertEquals(postsMade.size(), 1);
    }
    
//TO UNCOMMENT    
    /*@isTest(seeAllData=true) static void createChangeOrderMilestones()
    {
    	createDataForCO();
    	String sResult = psaProjectSetupWS.projectSetup(testOpp.Id);
    	
    	try {
			insert oppCO;
    	} catch (exception e) {
    		
    	}
		
		insert pOpportunityLineItem;
		
		Test.startTest();
		oppCO.StageName = 'Closed Won';
		update oppCO;
		
		Test.stopTest();
    }
    
    private static void createDataForCO() {
		if (region.Id==null) {
			insert region;
			insert new pse__Permission_Control__c(pse__User__c=UserInfo.getUserId(), pse__Region__c=region.Id, pse__Resource_Request_Entry__c=true, pse__Timecard_Ops_Edit__c = true, pse__Staffing__c = true);
		}
		
		Map<String, JfrsnSettings__c> mapOCF = JfrsnSettings__c.getAll();
        if (mapOCF.containsKey('standard')) {
        	mapOCF.get('standard').EventHorizon__c = Date.today().addDays( 1 );
        	update mapOCF.get('standard');
        }
        insert testOpp;
        
		insert pMilestoneTemplate;
		insert dummyDeveloper;
		insert resourceRequest;
		
		testOpp.Dev__c = 25;
        update testOpp;
		
		testOpp.StageName = 'Closed Won';
		update testOpp;
	}*/

    /*static Opportunity pOpportunity {
        get {
            if ( pOpportunity == null ) {
                pOpportunity = new Opportunity();
                pOpportunity.OwnerId = SL_Settings.ProductSalesUser.Id;
                pOpportunity.Name = 'TestOpportunity';
                pOpportunity.CloseDate = Date.today();
                pOpportunity.AccountId = pAccount.Id;
                pOpportunity.StageName = 'Closed Won';
                pOpportunity.Projected_Start_Date__c = Date.today();
                pOpportunity.Type = 'Renewal';
                pOpportunity.Number_of_Licenses__c = 1;
                pOpportunity.RecordTypeId = pRecordTypeId_Product;
                pOpportunity.License__c = pLicense.Id;
                pOpportunity.pse__Practice__c = SL_Settings.idPracticeLicenses;
                pOpportunity.pse__Region__c = SL_Settings.idRegionAllSilveline;
                pOpportunity.Billing_Type__c = 'Checkout';
                insert pOpportunity;
            }
            return pOpportunity;
        } private set;
    }*/
   
    static Opportunity oppCO {
        get {
            if ( oppCO == null ) {
            	
			   oppCO = new Opportunity (
			   	Name = 'Test_CO',
				AccountId = acct.Id,
				Billing_Notes__c = 'BillingNotes',
				Billing_Type__c = 'T&M',
				StageName = 'Needs Analysis',
				Type = 'Existing Business',
				CurrencyIsoCode = 'USD',
				SOW_or_CO__c = 'CO',
				Original_Opportunity__c = testOpp.Id,
				CloseDate = Date.today().addDays( 1 ),
				Changes_to_Scope_Deliverables__c = 'abc',
		   		RecordTypeId = pRecordTypeId_CO);
            }
            return oppCO;
        } private set;
    }
    
    static Opportunity testOpp {
        get {
            if ( testOpp == null ) {
            	
            	testOpp = new Opportunity (
               AccountId = acct.Id, 
               Name = 'TEST00 - Big Sales Opp',
               StageName='Negotiation/Review', 
               SOW_or_CO__c='SOW',
               Amount=800000, 
//TO UNCOMMENT                 Dev__c = 5,
               Billing_Notes__c='TEST - no bill',
               RecordTypeId = pRecordTypeId_Service, 
               pse__Region__c = region.Id,
               CloseDate=(Date.Today() + 10),
               Projected_Start_Date__c=(Date.Today() + 30));
            }
            return testOpp;
        } private set;
    }
    
    static Account acct {
        get {
            if ( acct == null ) {
                acct = new Account(Name='this account', BillingStreet='13 Hell\'s Kitchen Road',
                                        BillingCity='Manhattan', BillingState='NY', 
                                        BillingPostalCode='33333', BillingCountry='USA');
            }
            return acct;
        } private set;
    }
/*    
    static Account pAccount {
        get {
            if ( pAccount == null ) {
                pAccount = new Account();
                pAccount.Name = 'TestAccountName';
                insert pAccount;
            }
            return pAccount;
        } private set;
    }
    
    static sfLma__Package__c pPackage {
        get {
            if ( pPackage == null ) {
                pPackage = new sfLma__Package__c();
                pPackage.Name = 'TestPackageName';
                insert pPackage;
            }
            return pPackage;
        } private set;
    }
    
    static sfLma__Package_Version__c pPackageVersion {
        get {
            if ( pPackageVersion == null ) {
                pPackageVersion = new sfLma__Package_Version__c();
                pPackageVersion.Name = 'TestPackageVersionName';
                pPackageVersion.sfLma__Package__c = pPackage.Id;
                pPackageVersion.sfLma__Version__c = 'TestVersion';
                pPackageVersion.sfLma__Is_Beta__c = false;
                pPackageVersion.Version_Number__c = '1.0';
                insert pPackageVersion;
            }
            return pPackageVersion;
        } private set;
    }
    
    static License_Price__c pLicensePrice {
        get {
            if ( pLicensePrice == null ) {
                pLicensePrice = new License_Price__c();
                pLicensePrice.Package_Version__c = pPackageVersion.Id;
                pLicensePrice.Price__c = 100.0d;
                pLicensePrice.Min__c = 0;
                pLicensePrice.Max__c = 50;
                insert pLicensePrice; 
            }
            return pLicensePrice;
        } private set;
    }
    
// fake_license_changes
    static sfLma__License__c pLicense {
//    static License__c pLicense {
        get {
            if ( pLicense == null ) {
// fake_license_changes
                pLicense = new sfLma__License__c();
                pLicense.sfLma__Seats__c = 1;
                pLicense.sfLma__Used_Licenses__c = 1;
                pLicense.sfLma__Status__c = 'Active';
                pLicense.sfLma__Account__c = pAccount.Id;
                pLicense.sfLma__License_Type__c = 'TestType';
                pLicense.sfLma__Package_License_ID__c = 'TestPL_Id';
                pLicense.sfLma__Package_Version__c = pPackageVersion.Id;
                pLicense.sfLma__Subscriber_Org_ID__c = '00De0000005Orpq';
                pLicense.sfLma__Expiration__c = Date.today().addDays( 5 );
//              pLicense = new License__c();
//              pLicense.sfLma_Seats__c = 1;
//              pLicense.sfLma_Used_Licenses__c = 1;
//              pLicense.sfLma_Status__c = 'Active';
//              pLicense.sfLma_Account__c = pAccount.Id;
//              pLicense.sfLma_License_Type__c = 'TestType';
//              pLicense.sfLma_Package_License_ID__c = 'TestPL_Id';
//              pLicense.sfLma_Package_Version__c = pPackageVersion.Id;
//              pLicense.sfLma_Subscriber_Org_ID__c = 'TestSubscriber';
//              pLicense.sfLma_Expiration__c = Date.today().addDays( 5 );
                insert pLicense;
            }
            return pLicense;
        } private set;
    }*/
   
    private static pse__Resource_Request__c resourceRequest {
		get {
			if ( resourceRequest == null ) {
				resourceRequest = new pse__Resource_Request__c(
					pse__Opportunity__c = testOpp.Id,
					pse__Resource_Role__c = 'Developer',
					pse__SOW_Hours__c = 20,
					pse__Region__c = region.Id,
					pse__Start_Date__c = Date.today(),
					pse__End_Date__c = Date.today().addDays(6),
					pse__Requested_Bill_Rate__c = 100,
					pse__Resource_Held__c = false
				);
			}
			return resourceRequest;
		} set;
	}
	
	private static pse__Region__c region {
		get {
			if ( region == null ) {
				for (pse__Region__c item:[SELECT Id FROM pse__Region__c WHERE Name = 'All Silverline']) {
					region = item;
				}
				if (region==null) {
					region = new pse__Region__c(Name = 'All Silverline', pse__Action_Update_Current_Time_Period__c=false, pse__Current_Time_Period__c = null);
				}
			}
			return region;
		} set;
	}
	private static Contact dummyDeveloper {
		get {
			if ( dummyDeveloper == null ) {
				dummyDeveloper = new Contact(
					pse__Resource_Role__c = 'Generic',
					LastName = 'Developer'
				);
			}
			return dummyDeveloper;
		} set;
	}
	
	
	
	/*private static OpportunityLineItem pOpportunityLineItem {
		get {
			if ( pOpportunityLineItem == null ) {
				Pricebook2 oPricebook2 = [ SELECT Id FROM Pricebook2 WHERE IsStandard = true AND isActive = true limit 1 ];

				PricebookEntry oPricebookEntry = new PricebookEntry (
					Product2Id = oProduct2.id,
					Pricebook2Id = oPricebook2.id,
					UnitPrice = 3,
					isActive = true
				);
				insert oPricebookEntry;

				pOpportunityLineItem = new OpportunityLineItem(
					OpportunityId = oppCO.Id,
					UnitPrice = 1,
					Quantity = 2,
					ServiceDate = Date.today(),
					PricebookEntryId = oPricebookEntry.Id
				);
			}
			return pOpportunityLineItem;
		} set;
	}

	
	private static Product2 oProduct2 {
		get {
			if ( oProduct2 == null ) {
				oProduct2 = new Product2(
					Name = 'Test Product Entry',
					Description = 'Test Product Entry',
					isActive = true
				);
				insert oProduct2;
			}
			return oProduct2;
		} set;
	}*/
	
	/*private static Milestone_Template__c pMilestoneTemplate {
		get {
			if ( pMilestoneTemplate == null ) {
				pMilestoneTemplate = new Milestone_Template__c(
					Name = oProduct2.Name,
					Product__c = oProduct2.Id,
					Phase__c = 'Test Phase'
				);
			}
			return pMilestoneTemplate;
		} set;
	}*/
	
}