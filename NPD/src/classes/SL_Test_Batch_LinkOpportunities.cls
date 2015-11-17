/**
* \arg ClassName      : SL_Test_Batch_LinkOpportunities
* \arg JIRATicket     : NPD-219
* \arg CreatedOn      : 12/Oct/15
* \arg LastModifiedOn : 12/Oct/15
* \arg CreatededBy    : Praful Gadge
* \arg ModifiedBy     : Praful Gadge
* \arg Description    : This class serves as test class to Link Opportunities to ISO Goals
*/
@isTest
private class SL_Test_Batch_LinkOpportunities {

	private static testMethod void createData() {
        List<Opportunity> lstOpps = new List<Opportunity>{
            new Opportunity(Name='Opp1', Opportunity_Brief_Description__c='PLEASE FILL-IN', StageName='Contacted', CloseDate=System.today()),
            new Opportunity(Name='Opp2', Opportunity_Brief_Description__c='PLEASE FILL-IN', StageName='Contacted', CloseDate=System.today()),
            new Opportunity(Name='Opp3', Opportunity_Brief_Description__c='PLEASE FILL-IN', StageName='Contacted', CloseDate=System.today())
        };
        insert lstOpps;
        
        List<ISO_Goal__c> lstISOs = new List<ISO_Goal__c>{
            new ISO_Goal__c(Start_Date__c=System.today()-2, End_Date__c=System.today()+3),
            new ISO_Goal__c(Start_Date__c=System.today()-3, End_Date__c=System.today()+2)
        };
        insert lstISOs;
	}
	
	static testMethod void checkForBatch() {
		createData();
		
	 	Test.startTest();
	 	Database.executeBatch(new SL_Batch_LinkOpportunities());
	 	Test.stopTest();
	}
	
	static testMethod void coverageForScheduler() {
		createData();
		
		Test.startTest();
		System.schedule('Test','0 0 * * * ?', new SL_BatchScheduler_LinkOpportunities());
		Test.stopTest();
	}

}