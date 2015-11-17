@isTest
private class psaProjectHandlerTest {

	@isTest(seeAllData=true)
	static void testPSAProjectBuild() {
		createData();

		Test.startTest();
		String sResult = psaProjectSetupWS.projectSetup( pOpportunityLineItem.OpportunityId );
		Test.stopTest();

		//system.assertEquals( null, sResult ); 
		system.debug(LoggingLevel.ERROR, sResult);
		pProject = getProject( pOpportunity.Id );
		pMilestone = getMilestone( pProject.Id );
		
		system.assertEquals(pProject.OwnerId, UserInfo.getUserId());

		system.assertEquals( pMilestone.RecordTypeId, psaUtils.idRTParentTask );
		system.assertEquals( pMilestone.pse__Project__c, pProject.Id );
		//system.assertEquals( pMilestone.OpportunityLineItem_Id__c, pOpportunityLineItem.Id );
		//system.assertEquals( pMilestone.pse__Default_Bill_Rate__c, pOpportunityLineItem.UnitPrice );
		//system.assertEquals( pMilestone.Budget_Hours__c, pOpportunityLineItem.Quantity );
		//system.assertEquals( pMilestone.pse__Milestone_Amount__c, pOpportunityLineItem.TotalPrice );
		//system.assertEquals( pMilestone.Estimated_Hours__c, pOpportunityLineItem.Quantity );
		
		//system.assertEquals( pMilestone.Project_Phase__r.Name, pMilestoneTemplate.Phase__c );
		
		pProject.pse__Project_Manager__c = sfContact.Id;
		update pProject;
		
		pProject = getProject(pOpportunity.Id);
		//system.assertEquals(pProject.OwnerId, sfUser.Id);
		
	}

	private static void createData() {
		if (region.Id==null) insert region;
		pse__Permission_Control__c pc = new pse__Permission_Control__c(pse__User__c=UserInfo.getUserId(), pse__cascading_permission__c = true, pse__Region__c=region.Id, pse__Resource_Request_Entry__c=true, pse__Timecard_Ops_Edit__c = true, pse__Staffing__c = true);
		insert pc;
		system.debug(LoggingLevel.ERROR, pc);

		insert pOpportunity;
		insert pOpportunityLineItem;
		pOpportunityLineItem = getOpportunityLineItem();
		pOpportunity.StageName = 'Closed Won';
		update pOpportunity;
		insert pMilestoneTemplate;
		insert dummyDeveloper;
		insert resourceRequest;
		
		//psaProjectSetup.dEventHorizon = Date.today().addDays( 1 );
		Map<String, JfrsnSettings__c> mapOCF = JfrsnSettings__c.getAll();
        if (mapOCF.containsKey('standard')) {
        	mapOCF.get('standard').EventHorizon__c = Date.today().addDays( 10 );
        	psaProjectSetup.dEventHorizon = Date.today().addDays( 10 );
        	update mapOCF.get('standard');
        }
        
        insert sfContact;
	}

	private static pse__Proj__c pProject { get; set; }
	private static pse__Milestone__c pMilestone { get; set; }

	private static Opportunity pOpportunity {
		get {
			if ( pOpportunity == null ) {
				pOpportunity = new Opportunity(
					Name = 'Test Opportunity',
					StageName = 'Qualified Suspect',
					pse__Region__c = region.Id,
					CloseDate = Date.today(),
					Projected_Start_Date__c = Date.today().addDays( 20 ),
					RecordTypeId = psaUtils.idRTOpportunityServices
				);
			}
			return pOpportunity;
		} set; 	
	}

	private static OpportunityLineItem pOpportunityLineItem {
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
					OpportunityId = pOpportunity.Id,
					UnitPrice = 1,
					Role__c = 'Technical Architect',
					Quantity = 2,
					ServiceDate = Date.today(),
					PricebookEntryId = oPricebookEntry.Id
				);
			}
			return pOpportunityLineItem;
		} set;
	}

	private static OpportunityLineItem getOpportunityLineItem() {
		return [
			SELECT Id, OpportunityId, UnitPrice, Quantity, ServiceDate, TotalPrice
			FROM OpportunityLineItem
			WHERE Id = :pOpportunityLineItem.Id
		].get( 0 );
	}

	private static pse__Milestone__c getMilestone( ID idProject ) {
		return [
			SELECT RecordTypeId, pse__Project__c, OpportunityLineItem_Id__c, pse__Default_Bill_Rate__c,
				Budget_Hours__c, pse__Milestone_Amount__c, Estimated_Hours__c, Project_Phase__r.Name 
			FROM pse__Milestone__c
			WHERE pse__Project__c = :idProject
			limit 1
		].get( 0 );
	}
	
	private static pse__Proj__c getProject( ID idOpp ) {
		return [
			SELECT Id, OwnerId FROM pse__Proj__c
			WHERE pse__Opportunity__c = :idOpp
			limit 1
		].get( 0 );
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
	}
	
	private static Milestone_Template__c pMilestoneTemplate {
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
	}
	
	private static pse__Resource_Request__c resourceRequest {
		get {
			if ( resourceRequest == null ) {
				resourceRequest = new pse__Resource_Request__c(
					pse__Opportunity__c = pOpportunity.Id,
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
	
	private static Contact dummyDeveloper {
		get {
			if ( dummyDeveloper == null ) {
				dummyDeveloper = new Contact(
					pse__Resource_Role__c = 'Generic',
					LastName = 'Developer',
					pse__Region__c = region.id
				);
			}
			return dummyDeveloper;
		} set;
	}
	
	
	private static User sfUser {
		get {
			if ( sfUser == null ) {
				Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1]; 
		        sfUser = new User(Alias = 'sfUser', Email='sfUser@testorg.com', 
		        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
		        LocaleSidKey='en_US', ProfileId = p.Id,
		        TimeZoneSidKey='America/Los_Angeles', UserName='sfUser@testorg.com');
				insert sfUser;
			}
			return sfUser;
		} set;
	}
	
	private static Contact sfContact {
		get {
			if ( sfContact == null ) {
				sfContact = new Contact(
					pse__Is_Resource__c = true,
					pse__Is_Resource_Active__c = true,
					pse__Salesforce_User__c = sfUser.Id,
					LastName = 'sfContact test'
				);
			}
			return sfContact;
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
	
}