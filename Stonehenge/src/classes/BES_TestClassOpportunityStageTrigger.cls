public class BES_TestClassOpportunityStageTrigger {

	public static testMethod void myOpportunityStageTest()
	{
		Account objAcc = new Account();
    	objAcc.Name = 'Test';
    	insert objAcc;
    	
		Opportunity objOpp = new Opportunity();
    	objOpp.Name = 'Test';
    	objOpp.StageName = 'Prospecting';
    	Date dtCurr = Date.newInstance(2009, 1, 1);
    	objOpp.CloseDate = dtCurr;
    	objOpp.AccountId = objAcc.Id;
    	insert objOpp;
    		
    	Property__c oppProp = new Property__c();
	    oppProp.Asking_Rent__c = 1.0;
	    oppProp.Availability_Date__c = dtCurr;
	    oppProp.Building_Name__c = 'XYZ';
	    oppProp.Current_Rent__c = 1.0;
	    oppProp.Move_Out_Date__c = dtCurr;
	    oppProp.Name = 'ABC';
	    oppProp.Number_Of_Days_Vacant__c = 1.0;
	    oppProp.Sq_Feet__c = 1.0;
	    oppProp.Unit_Description__c = 'ABC';
	    oppProp.Unit_Number__c = '123';
	    oppProp.Unit_Status__c = 'Value';
	    oppProp.Unit_Type__c = 'ABC';
	    insert oppProp;
	       
	    Property_to_Opportunity_Connector__c objOppConnector = new Property_to_Opportunity_Connector__c();
    	objOppConnector.Name = 'Test';
    	objOppConnector.Property__C = oppProp.Id;
    	objOppConnector.Opportunity__c = objOpp.Id;
    	insert objOppConnector;
	    
	    List<Property_to_Opportunity_Connector__c> lstPOC = new List<Property_to_Opportunity_Connector__c>();
	    lstPOC.add(objOppConnector);
	    //lstPOC = [Select Id From Property_to_Opportunity_Connector__c where Opportunity__c =: objOpp.id];
	    if(lstPOC.size() == 0)
		{
			objOpp.StageName = 'Appointments';
			try
			{
				if(objOpp.id != null)
					update objOpp;				
			}
			catch(Exception ex)
			{
				System.debug(ex);
			}
		}
		
		Test.startTest();
		String query = 'Select Id from Property_to_Opportunity_Connector__c Limit 1';
		BES_BatchForLeaseSigned objBES_BatchForLeaseSigned = new BES_BatchForLeaseSigned(query,lstPOC);
		Database.executebatch(objBES_BatchForLeaseSigned,1);
		Test.stopTest();
	}

}