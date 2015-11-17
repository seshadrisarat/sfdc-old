/**
ClassName 		: SL_EndProcessController
JIRA Ticket 	: AMSEC-634
CreatedOn 		: 05/Oct/15
LastModifiedOn  : 06/Oct/15
CreatededBy 	: Praful Gadge
ModifiedBy 		: Praful Gadge
Description 	: To End Closed/Dead Deal process on deal__c detail page.
*/
public with sharing class SL_EndProcessController {

	private String strDealId = '';
	private String strAccId = '';
	private Id portFolioRecTypeId;
	private Id generalRecTypeId;
	private Id activeProcessRecTypeId;
	private List<External_Working_Group_Member__c> lstWGMembers;
	private List<Deal__c> lstDeal;
	private List<Account> lstAccount; 

	public String strStatus					{ get; set; }
	public Boolean isError					{ get; set; }
	public Deal__c objClosedDeal 			{ get; set; }
	public Deal__c objDeadDeal 				{ get; set; }
        
    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','--None--'));
        options.add(new SelectOption('Closed','Closed'));
        options.add(new SelectOption('Dead','Dead'));
        return options;
    }

	public SL_EndProcessController(ApexPages.StandardController stdCtrl) {

		objClosedDeal = objDeadDeal = (Deal__c)stdCtrl.getRecord();
		objClosedDeal = new Deal__c(Id= objClosedDeal.Id, Deal_Status__c='Closed', Buyer__c='American Securities', Close_Date__c=System.today());
		objDeadDeal = new Deal__c(Id= objClosedDeal.Id, Deal_Status__c='Dead', Buyer__c='American Securities', Close_Date__c=System.today());

		initialize();
	} 

	private void initialize(){
		isError = false;
		lstDeal = new List<Deal__c>();
		lstAccount = new List<Account>();
		lstWGMembers = new List<External_Working_Group_Member__c>();
		portFolioRecTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'Portfolio_Company' LIMIT 1].Id;
		activeProcessRecTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'Active_Process' LIMIT 1].Id;
		generalRecTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'General' LIMIT 1].Id;
	}

	public void saveClosedProcess(){

		try {
			update objClosedDeal;
		}   
		catch (System.DMLException e) {
			isError = true;
		    ApexPages.addMessages(e);
		}

		for(Deal__c objDeal : [SELECT Id, 
									  Process_Status__c,
									  Final_AS_Stage__c,
									  Salesforce_Company__c
								 FROM Deal__c
								WHERE Id =: objClosedDeal.Id]){

			if(objDeal.Salesforce_Company__c != null)
				strAccId = objDeal.Salesforce_Company__c;
			objDeal.Process_Status__c = 'Closed';
			objDeal.Final_AS_Stage__c = 'Closed';
			lstDeal.add(objDeal);
		}

		if(strAccId != '') 
			lstAccount.add(new Account(Id=strAccId, RecordTypeId=portFolioRecTypeId));
		
		for(External_Working_Group_Member__c objWGM : [SELECT Id, 
															  End_Date__c,
															  Company__c 
													     FROM External_Working_Group_Member__c 
													    WHERE Deal__c =: objClosedDeal.Id 
													 ORDER BY CreatedDate DESC LIMIT 1]){

			objWGM.End_Date__c = System.today();

			/*if(strAccId != '')
				objWGM.Company__c = strAccId;*/

			lstWGMembers.add(objWGM);
		}

		if(!lstDeal.isEmpty())
			update lstDeal;

		if(!lstAccount.isEmpty())
			update lstAccount;

		if(!lstWGMembers.isEmpty())
			update lstWGMembers;
	}

	public void saveDeadProcess(){

		try {
			update objDeadDeal;
		}   
		catch (System.DMLException e) {
			isError = true;
		    ApexPages.addMessages(e);
		}

		for(Deal__c objDeal : [SELECT Id, 
									  Process_Status__c,
									  Salesforce_Company__c
								 FROM Deal__c
								WHERE Id =: objDeadDeal.Id]){

			if(objDeal.Salesforce_Company__c != null)
				strAccId = objDeal.Salesforce_Company__c;
			objDeal.Process_Status__c = 'Closed';
			lstDeal.add(objDeal);
		}

		for(External_Working_Group_Member__c objWGM : [SELECT Id, 
															  End_Date__c
													     FROM External_Working_Group_Member__c 
													    WHERE Deal__c =: objDeadDeal.Id 
													 ORDER BY CreatedDate DESC LIMIT 1]){

			objWGM.End_Date__c = System.today();
			lstWGMembers.add(objWGM);
		}

		for(Account objAcc : [SELECT Id, RecordTypeId FROM Account WHERE Id =: strAccId]){
			if(objAcc.RecordTypeId == activeProcessRecTypeId)
				lstAccount.add(new Account(Id = objAcc.Id, RecordTypeId = generalRecTypeId));
		}	

		if(!lstDeal.isEmpty())
			update lstDeal;

		if(!lstAccount.isEmpty())
			update lstAccount;

		if(!lstWGMembers.isEmpty())
			update lstWGMembers;
	}

}