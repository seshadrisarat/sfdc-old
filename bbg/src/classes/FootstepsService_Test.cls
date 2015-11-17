@isTest
public class FootstepsService_Test {

	static RecordType allowedLeadRecordType;
	
	private static void insertAllowedLeadRecordTypeCS(){
        
        List<RecordType> recTypes= [SELECT Id, developerName from RecordType where SObjectType='Lead' and isActive=true LIMIT 2];
        List<LeadRoutingAllowedRecordTypes__c> csAllowedRecordTypes= new List<LeadRoutingAllowedRecordTypes__c>();
        allowedLeadRecordType = recTypes[0];
        csAllowedRecordTypes.add(new LeadRoutingAllowedRecordTypes__c(Name=allowedLeadRecordType.developerName));
        insert csAllowedRecordTypes;
    }
    
    private static void insertDisableRoutingSetting(){
        List<DisableLeadRoutingTrigger__c> dlrtList= DisableLeadRoutingTrigger__c.getall().values();
        if(dlrtList.size()>0)
            delete dlrtList;
        
        DisableLeadRoutingTrigger__c dlrt= new DisableLeadRoutingTrigger__c();	
        dlrt.Name='LeadRouting';
        dlrt.Disabled__c=true;
        insert dlrt;
    }
	
	// this appears to test that the leads are grouped by lead source properly..
	public static testMethod void testGenerateXMLFromLeads(){
		
		LeadServices.leadFootstepsWebServiceIsRunning = true;
		
		insertAllowedLeadRecordTypeCS();
		
		insertDisableRoutingSetting();
		
		FootStepsService.ARI_FILTERD_LEADS = new Set<String>{
			'Bayliner.com',
			'SeaRay.com',
			'MarineMax.com'
		};
		
		UnitTest.addData(TestUtilities.createLeads(allowedLeadRecordType.Id, 4, true)).tag('Leads');
		UnitTest.get('Leads')
			.property('LeadSource').assignFrom(new List<String>(FootStepsService.ARI_FILTERD_LEADS));
			
		Test.startTest();
			List<Lead> leads = UnitTest.get('Leads').getList();
			
			LeadFootStepsService leadService = new LeadFootStepsService();
			
			List<FootstepsModel> models = new List<FootstepsModel>();
			for (Lead l : leads) {
				models.add(new FootstepsModel(l, null));
			}
			
			Map<String, String> xmlDataBySource = leadService.generateXMLFromLeadsBySource(models);
		
		Test.stopTest();
		
		System.assert(xmlDataBySource.size() == FootStepsService.ARI_FILTERD_LEADS.size(), 
			'Xml list size: ' + xmlDataBySource.size() + ', Lead size: ' + FootStepsService.ARI_FILTERD_LEADS.size() +
			' -  We expect to get back XML data for each lead source in the list of leads');
		for (String leadSource : FootStepsService.ARI_FILTERD_LEADS){
			System.assertNotEquals(null, xmlDataBySource.get(leadSource), 
				'We expect to have actual XML data for each lead source');
		}
		
	}
	
	public static testMethod void testfilterLeadsWithFootstepsCRMSystem(){
		
		LeadServices.leadFootstepsWebServiceIsRunning = true;
		
		insertAllowedLeadRecordTypeCS();
		
		insertDisableRoutingSetting();
		
		FootStepsService.ARI_FILTERD_LEADS = new Set<String>{
			'Bayliner.com',
			'SeaRay.com',
			'MarineMax.com'
		};
		
        UnitTest.addData(TestUtilities.createTestDealerAccounts(9, false))
            .tag('Accounts');
        UnitTest.get('Accounts')
            .divide(2)
            .part('CRM System Non Selected Dealers')
            .part('CRM System Selected Dealers');
            
        UnitTest.get('CRM System Selected Dealers')
            .divide(2)
            .part('Dealer with CRM System on Dealer')
            .part('Dealer with CRM System on Dealer Brand');
           
        for (Integer i=0; i < UnitTest.get('Accounts').getList().size(); i++){
        	List<Account> accounts = (List<Account>)UnitTest.get('Accounts').getList();
        	Account dealerAcc = accounts.get(i);
            dealerAcc.Dealer_Number__c = String.valueOf(i++);
        }
        
        UnitTest.get('Dealer with CRM System on Dealer')
        	.property('CRM_System__c').assign(FootStepsService.ARI_FOOTSTEPS_CRM_SYSTEM);
        
        UnitTest.get('Accounts').insertAll();
        
        
        List<Dealer_Brand__c> testDealerBrands1 = new List<Dealer_Brand__c>();
        List<Dealer_Brand__c> testDealerBrands2 = new List<Dealer_Brand__c>();
        
        for (Integer i=0; i < UnitTest.get('Dealer with CRM System on Dealer Brand').getList().size(); i++){
        	Account acc = ((List<Account>)UnitTest.get('Dealer with CRM System on Dealer Brand').getList()).get(i);
            Dealer_Brand__c dealerBrand1 = TestUtilities.createDealerBrand(acc, 100 + i++);
            dealerBrand1.Brand__c = 'SR';
            dealerBrand1.Dealer_CRM_System__c = FootStepsService.ARI_FOOTSTEPS_CRM_SYSTEM;
            testDealerBrands1.add(dealerBrand1);
        }
        for (Integer i=0; i < UnitTest.get('Dealer with CRM System on Dealer').getList().size(); i++){
        	Account acc = ((List<Account>)UnitTest.get('Dealer with CRM System on Dealer').getList()).get(i);
        	Dealer_Brand__c dealerBrand2 = TestUtilities.createDealerBrand(acc, i++);
            dealerBrand2.Brand__c = 'BW';
            testDealerBrands2.add(dealerBrand2);
        }
       	
        UnitTest.addData(testDealerBrands1)
            .tag('Dealer Brands with CRM System').tag('All Dealer Brands');
        UnitTest.addData(testDealerBrands2)
            .tag('Dealer Brands without CRM System').tag('All Dealer Brands');
            
        UnitTest.get('All Dealer Brands').insertAll();
        
		UnitTest.addData(TestUtilities.createLeads(allowedLeadRecordType.Id, 20, false)).tag('Leads');
		UnitTest.get('Leads')
			.property('LeadSource').assignFrom(new List<String>(FootStepsService.ARI_FILTERD_LEADS));
			
		UnitTest.get('Leads')
			.divide(2)
			.part('Leads with CRM System')
			.part('Other Leads');
			
		UnitTest.get('Leads with CRM System')
			.divide(2)
			.part('Bayliner Leads with CRM System')
			.part('Other Leads with CRM System');
	
		UnitTest.get('Bayliner Leads with CRM System')
			.property('Brand_Interest__c').assign('Bayliner')
			.property('Assigned_Dealer_1__c').assignFrom('Dealer with CRM System on Dealer')
			.property('Assigned_Dealer_9__c').assignFrom('Dealer with CRM System on Dealer');
			
		UnitTest.get('Other Leads with CRM System')
			.property('Brand_Interest__c').assign('Sea Ray')
			.property('Assigned_Dealer_2__c').assignFrom('Dealer with CRM System on Dealer Brand')
			.property('Assigned_Dealer_3__c').assignFrom('Dealer with CRM System on Dealer Brand');
			
		
		UnitTest.get('Leads').insertAll();	
		
		Test.startTest();
		
			LeadFootStepsService leadService = new LeadFootStepsService();
			
			map<Id, set<Id>> idToDealerMap = new map<Id, set<Id>>();
			for (Id id : UnitTest.getIds('Leads')) {
				idToDealerMap.put(id, new set<Id>());
			}
			Map<String, List<FootstepsModel>> filteredLeadsMap = leadService.filterLeadsWithFootstepsCRMSystem(idToDealerMap);
		
		Test.stopTest();
		
		List<FootstepsModel> filteredLeads = new List<FootstepsModel>();
		for (List<FootstepsModel> fList : filteredLeadsMap.values()){
			filteredLeads.addAll(fList);
		}
		
		Integer leadSize = UnitTest.get('Leads with CRM System').getList().size();
		Integer filteredLeadsSize = filteredLeads.size();
		System.assertEquals(leadSize, filteredLeadsSize, 'Expected the number of filtered leads to be ' + leadSize + ' instead found ' + filteredLeadsSize);
		
		for (Integer i = 0; i < UnitTest.get('Leads with CRM System').getList().size(); i++) {
			Lead l = ((List<Lead>)UnitTest.get('Leads with CRM System').getList()).get(i++);
			boolean foundLead = false;
			for (FootstepsModel model : filteredLeads) {
				if (model.sourceId == l.id) {
					foundLead = true;
					break;
				}
			}
			System.assert(foundLead, 'Could not find Lead ' + l.id + ' in filtered leads');
		}
		
	}
	
	
	public static testMethod void testLeadXML() {
		Lead testLead = TestUtilities.createLeads(null, 1, false)[0];
		testLead.Brand_Interest__c = 'Sea Ray';
		testLead.Birthday__c = Date.today();
		testLead.leadsource = 'test';
		LeadFootStepsService leadFootStepsService = new LeadFootStepsService();
		List<FootstepsModel> models = new List<FootstepsModel>();
		models.add(new FootstepsModel(testLead, null));
		Map<String, String> xmlMap = leadFootStepsService.generateIDSAstraXMLFromLeadsBySource(models);
		system.debug('xmlMap: ' + xmlMap);
		system.assert(!xmlMap.isEmpty(), 'xmlMap should contain lead xml');
	}
	
	
	public static testMethod void testOwnerXML() {
		Account owner = TestUtilities.createTestOwnerAccounts(1, false)[0];
		owner.Brand__C = 'SR';
		owner.Birthday__pc = Date.today();
		owner.personleadsource = 'test';
		LeadFootStepsService leadFootStepsService = new LeadFootStepsService();
		List<FootstepsModel> models = new List<FootstepsModel>();
		models.add(new FootstepsModel(owner, null));
		Map<String, String> xmlMap = leadFootStepsService.generateIDSAstraXMLFromLeadsBySource(models);
		system.debug('xmlMap: ' + xmlMap);
		system.assert(!xmlMap.isEmpty(), 'xmlMap should contain lead xml');
	}

}