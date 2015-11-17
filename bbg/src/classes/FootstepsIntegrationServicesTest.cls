@isTest
public class FootstepsIntegrationServicesTest {
	
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
	
	public static testMethod void testGenerateXMLFromLeads(){
		
		FootstepsIntegrationServices.ARI_FILTERD_LEADS = new Set<String>{
			'Bayliner.com',
			'SeaRay.com',
			'MarineMax.com'
		};
		
		UnitTest.addData(TestUtilities.createLeads(null, 200, false)).tag('Leads');
		UnitTest.get('Leads')
			.property('LeadSource').assignFrom(new List<String>(FootstepsIntegrationServices.ARI_FILTERD_LEADS));
			
		Test.startTest();
			
			Map<String, String> xmlDataBySource = FootstepsIntegrationServices.generateXMLFromLeadsBySource((List<Lead>)UnitTest.get('Leads').getList());
		
		Test.stopTest();
		
		System.assert(xmlDataBySource.size() == FootstepsIntegrationServices.ARI_FILTERD_LEADS.size(), 
			'We expect to get back XML data for each lead source in the list of leads');
		for (String leadSource : FootstepsIntegrationServices.ARI_FILTERD_LEADS){
			System.assertNotEquals(null, xmlDataBySource.get(leadSource), 
				'We expect to have actual XML data for each lead source');
		}
		
	}
	
	public static testMethod void testLeadFieldValue(){
		
		Lead testLead = TestUtilities.createLeads(null, 1, false)[0];
		testLead.Brand_Interest__c = 'Sea Ray';
		testLead.Birthday__c = Date.today();
		
		Test.startTest();
			
			String result1 = FootstepsIntegrationServices.leadFieldValue(testLead, 'Brand_Interest__c', false);
			String result2 = FootstepsIntegrationServices.leadFieldValue(testLead, 'Birthday__c', true);
			String result3 = FootstepsIntegrationServices.leadFieldValue(testLead, 'Spouse_Name__c', false);
			
		Test.stopTest();
		
		System.assertEquals('Sea Ray', result1, 
			'We expect to get back non-null data when data is present on the lead');
		System.assertEquals(((Datetime)Date.today()).format(), result2, 
			'We expect to get back non-null data when data is present on the lead');
		System.assertEquals('', result3, 
			'We expect to get back non-null data when data is present on the lead');
		
	}
	
	public static testMethod void testfilterLeadsWithFootstepsCRMSystem(){
		
		LeadServices.leadFootstepsWebServiceIsRunning = true;
		
		insertAllowedLeadRecordTypeCS();
		
		insertDisableRoutingSetting();
		
		FootstepsIntegrationServices.ARI_FILTERD_LEADS = new Set<String>{
			'Bayliner.com',
			'SeaRay.com',
			'MarineMax.com'
		};
		
		Integer i = 0;
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
            
        for (Account dealerAcc : (List<Account>)UnitTest.get('Accounts').getList()){
            dealerAcc.Dealer_Number__c = String.valueOf(i++);
        }
        
        UnitTest.get('Dealer with CRM System on Dealer')
        	.property('CRM_System__c').assign(FootstepsIntegrationServices.ARI_FOOTSTEPS_CRM_SYSTEM);
        
        UnitTest.get('Accounts').insertAll();
        
        
        List<Dealer_Brand__c> testDealerBrands1 = new List<Dealer_Brand__c>();
        List<Dealer_Brand__c> testDealerBrands2 = new List<Dealer_Brand__c>();
        
        for (Account acc : (List<Account>)UnitTest.get('Dealer with CRM System on Dealer Brand').getList()){
            Dealer_Brand__c dealerBrand1 = TestUtilities.createDealerBrand(acc, i++);
            dealerBrand1.Brand__c = 'SR';
            dealerBrand1.Dealer_CRM_System__c = FootstepsIntegrationServices.ARI_FOOTSTEPS_CRM_SYSTEM;
            testDealerBrands1.add(dealerBrand1);
        }
        for (Account acc : (List<Account>)UnitTest.get('Dealer with CRM System on Dealer').getList()){
            Dealer_Brand__c dealerBrand2 = TestUtilities.createDealerBrand(acc, i++);
            dealerBrand2.Brand__c = 'BW';
            testDealerBrands2.add(dealerBrand2);
        }
       	
        UnitTest.addData(testDealerBrands1)
            .tag('Dealer Brands with CRM System').tag('All Dealer Brands');
        UnitTest.addData(testDealerBrands2)
            .tag('Dealer Brands without CRM System').tag('All Dealer Brands');
            
        UnitTest.get('All Dealer Brands').insertAll();
        
		UnitTest.addData(TestUtilities.createLeads(allowedLeadRecordType.Id, 200, false)).tag('Leads');
		UnitTest.get('Leads')
			.property('LeadSource').assignFrom(new List<String>(FootstepsIntegrationServices.ARI_FILTERD_LEADS));
			
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
			
			Map<String, List<Lead>> filteredLeadsMap = FootstepsIntegrationServices.filterLeadsWithFootstepsCRMSystem(UnitTest.getIds('Leads'));
		
		Test.stopTest();
		
		List<Lead> filteredLeads = new List<Lead>();
		for (List<Lead> fList : filteredLeadsMap.values()){
			filteredLeads.addAll(fList);
		}
		
		UnitTest.analyze('Leads with CRM System').assertEquivalence(filteredLeads, 
			'We expect to get back leads with CRM System selected as their Dealer CRM System or Dealer Brand CRM System');
		
		
		
		
		
		
	}

}