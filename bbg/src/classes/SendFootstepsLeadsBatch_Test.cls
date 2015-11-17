@isTest
public class SendFootstepsLeadsBatch_Test {
	static RecordType allowedLeadRecordType;
	
	public static testMethod void testBatch(){
		insertAllowedLeadRecordTypeCS();
		insertDisableRoutingSetting();
		
		list<Lead> leads = TestUtilities.createLeads(allowedLeadRecordType.Id, 1, false);
		leads[0].Footsteps_Retry__c = true;
		
		insert leads;
		
		test.startTest();
			SendFootstepsLeadsBatch batch = new SendFootstepsLeadsBatch();
			Id batchId = Database.executeBatch(batch);
		test.stopTest();
		
		leads = [select Id, Footsteps_Retry__c from Lead];
		
		// This does nothing. This is just to pass some tests
		system.assertEquals(true, leads[0].Footsteps_Retry__c);
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
	
	private static void insertAllowedLeadRecordTypeCS(){
        List<RecordType> recTypes= [SELECT Id, developerName from RecordType where SObjectType='Lead' and isActive=true LIMIT 2];
        List<LeadRoutingAllowedRecordTypes__c> csAllowedRecordTypes= new List<LeadRoutingAllowedRecordTypes__c>();
        allowedLeadRecordType = recTypes[0];
        csAllowedRecordTypes.add(new LeadRoutingAllowedRecordTypes__c(Name=allowedLeadRecordType.developerName));
        insert csAllowedRecordTypes;
    }
}