@isTest
public class TestLeadModel {
	
	/*
	static final String TEST_STREET = '112 E. HIGH STREET';
    static final String TEST_CITY = 'HENNEPIN';
    static final String TEST_STATE = 'IL';
    static final String TEST_POSTAL_CODE = '61327';
    static final String TEST_COUNTRY = 'United States';
    static final String TEST_COUNTY = 'Cook';
    static final String TEST_ISO_CODE = 'US';
    static final String TEST_INTERNATIONAL_ISO_CODE = 'IN';
    static final String TEST_PHONE = '111 555 2222';
    static final String TEST_WEBSITE = 'bluewolf.com';
    static final String TEST_BRAND = 'SR';
    static final String TEST_BRAND_OF_INTEREST_FOR_LEAD = 'Sea Ray';
    static final String TEST_DIFF_BRAND_OF_INTEREST_FOR_LEAD = 'Bayliner';
    static final Decimal TEST_LONGITUDE_FOR_LEAD = -121.895;
    static final Decimal TEST_LATITUDE_FOR_LEAD = 37.4352;
    static RecordType allowedLeadRecordType;
    static final String TEST_BOAT_CLASS = 'Test Boat Class';
    
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
       
    public static testMethod void CreateALeadModelThatMatchesADoNotSendCustomSetting_IsSendableShouldBeFalse(){
    	
    	LeadServices.isBatch=true;
    	insertAllowedLeadRecordTypeCS();
    	insertDisableRoutingSetting();
    	
    	//Create Custom Settings for test
        Lead_Routing_Do_Not_Send__c dns = new Lead_Routing_Do_Not_Send__c();
        dns.Name = 'new';
        dns.Brand_Code__c = 'SR';
        dns.Lead_Form_Name__c = 'Test Lead Form';
        insert dns;
		
		
    
		//Lead but do not insert
		List<Lead> leads= TestUtilities.createLeads(allowedLeadRecordType.Id, 1,false);
        Lead testLead = leads[0];
        testLead.PostalCode = TEST_POSTAL_CODE;
        testLead.Brand_Interest__c = TEST_BRAND_OF_INTEREST_FOR_LEAD;
        testLead.Country_ISO_Code__c = TEST_ISO_CODE;
        testLead.Boat_Category_of_Interest__c = TEST_BOAT_CLASS;
        testLead.GeoLocation__Longitude__s = TEST_LONGITUDE_FOR_LEAD;
        testLead.GeoLocation__Latitude__s = TEST_LATITUDE_FOR_LEAD;
        testLead.pi__Score__c = 1;
		testLead.Lead_Form_Name__c = 'Test Lead Form';
	    
		insert testLead;
		
		Lead l = [SELECT Id, Lead_Form_Name__c, Brand_Code__c,PostalCode, Brand_Interest__c, Country_ISO_Code__c, Boat_Category_of_Interest__c, GeoLocation__Latitude__s, GeoLocation__Longitude__s, Assigned_Dealer_1__c,Assigned_Dealer_2__c,Assigned_Dealer_3__c,Assigned_Dealer_4__c FROM Lead WHERE Id = :testLead.Id];
		
		
		Test.startTest();
		LeadModel lm = new LeadModel(l); 
		
		Test.stopTest();
	    
	    system.assertEquals(false,lm.isSendable);
    }
    */
    
}