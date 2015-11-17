@isTest
public class SL_Test_Credit_Request_Handler {
    //Test method for class SL_Credit_Requests_Handler
    static testmethod void testSL_Credit_Requests_Handler()
    {
    	Account objAccount = new Account(Name = 'Test');
    	insert objAccount;
    	System.assertNotEquals(objAccount.Id, null);
    	
    	Account objAccount2 = new Account(Name = 'Test2');
    	insert objAccount2;
    	System.assertNotEquals(objAccount2.Id, null);
    	
    	Opportunity objOpportunity = new Opportunity(AccountId = objAccount.Id, Name = 'TestOpp', CloseDate = Date.today() + 10 , StageName = 'Lost');
    	insert objOpportunity;
    	System.assertNotEquals(objOpportunity.Id, null);
    	
    	//Letter_of_Intent__c sObjLOI = new Letter_of_Intent__c(Opportunity__c = objOpportunity.Id, Account__c = objAccount.Id);
    	//insert sObjLOI;
    	//System.assertNotEquals(sObjLOI.Id, null);
    	
    	List<Letter_of_Intent__c> lstLOIToInsert = new List<Letter_of_Intent__c>{
    																				new Letter_of_Intent__c(Opportunity__c = objOpportunity.Id, Account__c = objAccount.Id),
    																				new Letter_of_Intent__c(Opportunity__c = objOpportunity.Id, Account__c = objAccount.Id),
    																				new Letter_of_Intent__c(Opportunity__c = objOpportunity.Id, Account__c = objAccount2.Id)
    																		    };
    	insert lstLOIToInsert;
    	
    	Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Funding_Source__c;   
		Map<String,Schema.RecordTypeInfo> FundingSourceRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
    	  
    	List<Funding_Source__c> lstFSToInsert = new List<Funding_Source__c>{
    																			new Funding_Source__c(Letter_of_Intent__c = lstLOIToInsert[0].Id, Collateral__c = 'Test',
    																								  Financial_Product__c = 'First Amendment Deal',
    																								  Approved_Spread__c = 12, Status__c='Approved', 
    																								  Proposed_Spread__c = 2144, 
    																								  RecordTypeId=FundingSourceRecordTypeInfo.get('Internal').getRecordTypeId()),
    																			new Funding_Source__c(Letter_of_Intent__c = lstLOIToInsert[0].Id, Collateral__c = 'Test',
    																								  Financial_Product__c = 'First Amendment Deal', 
    																								  Approved_Spread__c = 1254, Status__c='Approved',
    																								  Proposed_Spread__c = 755, 
    																								  RecordTypeId=FundingSourceRecordTypeInfo.get('Internal').getRecordTypeId()),
    																			new Funding_Source__c(Letter_of_Intent__c = lstLOIToInsert[2].Id, Collateral__c = 'Test',
    																								  Financial_Product__c = 'First Amendment Deal', 
    																								  Approved_Spread__c = 54, Status__c='In Progress',
    																								  Proposed_Spread__c = 232, 
    																								  RecordTypeId=FundingSourceRecordTypeInfo.get('Internal').getRecordTypeId()),
    																			new Funding_Source__c(Letter_of_Intent__c = lstLOIToInsert[0].Id, Collateral__c = 'Test',
    																								  Financial_Product__c = 'First Amendment Deal', 
    																								  Approved_Spread__c = 21, Status__c='Approved',
    																								  Proposed_Spread__c = 244, 
    																								  RecordTypeId=FundingSourceRecordTypeInfo.get('Internal').getRecordTypeId()),
    																			new Funding_Source__c(Letter_of_Intent__c = lstLOIToInsert[1].Id, Collateral__c = 'Test',
    																								  Financial_Product__c = 'First Amendment Deal', 
    																								  Approved_Spread__c = 66, Status__c='In Progress',
    																								  Proposed_Spread__c = 1734, 
    																								  RecordTypeId=FundingSourceRecordTypeInfo.get('Internal').getRecordTypeId())
    																	   };	
    	insert lstFSToInsert;
    	
    	List<Schedule__c> lstScheduleToInsert = new List<Schedule__c>{
    																	new Schedule__c(Letter_of_Intent__c = lstLOIToInsert[2].Id, Account_Lookup__c=objAccount.Id,Notice_Days_Required__c = 13,Extension_Period_Months__c = 2, Base_Lease_Termination_Date__c = Date.newInstance(2015,3,9),
    																				    Stage__c = 'Credit Review in Process', Funding_Source__c=lstFSToInsert[2].Id),
																		new Schedule__c(Letter_of_Intent__c = lstLOIToInsert[1].Id, Account_Lookup__c=objAccount.Id,Notice_Days_Required__c = 13,Extension_Period_Months__c = 2, Base_Lease_Termination_Date__c = Date.newInstance(2015,3,9),
    																				    Stage__c = 'Approved Balance', Funding_Source__c=lstFSToInsert[4].Id), 
																		new Schedule__c(Letter_of_Intent__c = lstLOIToInsert[0].Id, Account_Lookup__c=objAccount.Id,Notice_Days_Required__c = 13,Extension_Period_Months__c = 2, Base_Lease_Termination_Date__c = Date.newInstance(2015,3,9),
    																				    Stage__c = 'Declined', Funding_Source__c=lstFSToInsert[0].Id),
																		new Schedule__c(Letter_of_Intent__c = lstLOIToInsert[0].Id, Account_Lookup__c=objAccount.Id,Notice_Days_Required__c = 13,Extension_Period_Months__c = 2, Base_Lease_Termination_Date__c = Date.newInstance(2015,3,9),
    																				    Stage__c = 'Pending Equipment Delivery', Funding_Source__c=lstFSToInsert[0].Id),
																		new Schedule__c(Letter_of_Intent__c = lstLOIToInsert[0].Id, Account_Lookup__c=objAccount.Id,Notice_Days_Required__c = 13,Extension_Period_Months__c = 2, Base_Lease_Termination_Date__c = Date.newInstance(2015,3,9),
    																				    Stage__c = 'Booked', Funding_Source__c=lstFSToInsert[0].Id)       																				    
    																 };
    	insert lstScheduleToInsert;
    	
    	List<Credit_Requests__c> lstCR = new List<Credit_Requests__c>{
    																		new Credit_Requests__c(Funding_Source__c = lstFSToInsert[0].Id,Status__c= 'Approved',Decision_Date__c = Date.today()),
    																		new Credit_Requests__c(Funding_Source__c = lstFSToInsert[0].Id,Status__c= 'Approved',Decision_Date__c = Date.today()),
    																		new Credit_Requests__c(Funding_Source__c = lstFSToInsert[1].Id,Status__c= 'Awaiting Information',Decision_Date__c = Date.today()),
    																		new Credit_Requests__c(Funding_Source__c = lstFSToInsert[1].Id,Status__c= 'Awaiting Information',Decision_Date__c = Date.today()),
    																		new Credit_Requests__c(Funding_Source__c = lstFSToInsert[2].Id,Status__c= 'Pending Approval',Decision_Date__c = Date.today()),
    																		new Credit_Requests__c(Funding_Source__c = lstFSToInsert[2].Id,Status__c= 'Pending Approval',Decision_Date__c = Date.today()),
    																		new Credit_Requests__c(Funding_Source__c = lstFSToInsert[3].Id,Status__c= 'Declined',Decision_Date__c = Date.today()),
    																		new Credit_Requests__c(Funding_Source__c = lstFSToInsert[3].Id,Status__c= 'Declined',Decision_Date__c = Date.today()),
    																		new Credit_Requests__c(Funding_Source__c = lstFSToInsert[4].Id,Status__c= 'Test',Decision_Date__c = Date.today()),
    																		new Credit_Requests__c(Funding_Source__c = lstFSToInsert[4].Id,Status__c= 'Test',Decision_Date__c = Date.today())
    																 };	
    	insert lstCR;
    	
    	lstCR[3].Status__c = 'Approved';
    	lstCR[5].Status__c = 'Approved';
    	lstCR[7].Status__c = 'Approved';
    	lstCR[9].Status__c = 'Approved';
    	update lstCR;
    	delete lstCR;
    	
    	undelete lstCR;
    }
}