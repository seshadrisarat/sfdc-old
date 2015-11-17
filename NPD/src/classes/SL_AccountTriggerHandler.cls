/**  
* \arg ClassName        : SL_AccountTriggerHandler
* \arg JIRATicket       : NPD-84, NPD-88, NPD-214
* \arg CreatedOn        : 
* \arg LastModifiedOn   : 
* \arg CreatededBy      : Sandeep
* \arg ModifiedBy       : Pankaj Ganwani
* \arg Description      : Handler class for Account object.
*/
global class SL_AccountTriggerHandler extends SL_TriggerHandlerBase {

	static final Map<Id, RecordType> mapIdToRecordType = new Map<Id, RecordType>([SELECT id, DeveloperName FROM RecordType WHERE SobjectType =: 'Account']);
	
	public override void beforeInsert(List<SObject> newListGeneric){
		List<Account> newList = (List<Account>) newListGeneric;
		/*BEFORE INSERT METHODS START*/
		updateParentAccount(newList,NULL);
		/*BEFORE INSERT METHODS END*/
	}
	
	public override void beforeUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric){
		Map<Id, Account> oldMap = (Map<Id, Account>) oldMapGeneric;
		Map<Id, Account> newMap = (Map<Id, Account>) newMapGeneric;
		/*BEFORE UPDATE METHODS START*/
		updateParentAccount(newMap.values(),oldMap);
		/*BEFORE UPDATE METHODS END*/
	}
	
	public override void beforeDelete(Map<Id, SObject> oldMapGeneric){
		Map<Id, Account> oldMap = (Map<Id, Account>) oldMapGeneric;
		/*BEFORE DELETE METHODS START*/
		
		/*BEFORE DELETE METHODS END*/
	}
	
	public override void afterInsert(Map<Id, SObject> newMapGeneric){
		Map<Id, Account> newMap = (Map<Id, Account>) newMapGeneric;
		/*AFTER INSERT METHODS START*/
		createGroupAndShareAccount(newMap);
		createChatterGroup(newMap);
		/*AFTER INSERT METHODS END*/
	}
	
	public override void afterUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric){
		Map<Id, Account> oldMap = (Map<Id, Account>) oldMapGeneric;
		Map<Id, Account> newMap = (Map<Id, Account>) newMapGeneric;
		/*AFTER UPDATE METHODS START*/
		
		/*AFTER UPDATE METHODS END*/
	}
	
	public override void afterDelete(Map<Id, SObject> oldMapGeneric){
		Map<Id, Account> oldMap = (Map<Id, Account>) oldMapGeneric;
		/*AFTER DELETE METHODS START*/
		
		/*AFTER DELETE METHODS END*/
	}
	
	public override void afterUndelete(Map<Id, SObject> newMapGeneric){
		Map<Id, Account> newMap = (Map<Id, Account>) newMapGeneric;
		/*AFTER UNDELETE METHODS START*/
		
		/*AFTER UNDELETE METHODS END*/
	}
	
	/* Start  - This method has been created as per the requirement of NPD-214 by Pankaj Ganwani on 9th Oct, 2015 */
	/*
        * MethodName        : updateParentAccount
        * param             : List of Accounts, old map of Account records
        * Description       : This function will be called on before insert and on before events to populate the value of parent account and Record_Type_Dev_Name__c field value.
    */
	private void updateParentAccount(List<Account> lstAccount, Map<Id, Account> mapIdToAccount)
	{
		for(Account objAccount : lstAccount)
		{
			if(Trigger.isInsert || (Trigger.isUpdate && (objAccount.Company_Account__c!=mapIdToAccount.get(objAccount.Id).Company_Account__c || objAccount.Corporate_Account__c!=mapIdToAccount.get(objAccount.Id).Corporate_Account__c)))
			{
    			if(objAccount.Company_Account__c!=NULL)
    				objAccount.ParentId = objAccount.Company_Account__c;
    			else if(objAccount.Corporate_Account__c!=NULL)
    				objAccount.ParentId = objAccount.Corporate_Account__c;
    			
    			if(Trigger.isInsert)
    			{
    			    objAccount.Group_Name__c = objAccount.Name+' NPD Team';
    			    if(mapIdToRecordType.containsKey(objAccount.RecordTypeId))
    			        objAccount.Record_Type_Dev_Name__c = mapIdToRecordType.get(objAccount.RecordTypeId).DeveloperName;
    			}
			}
		}
	}
	/* End  - This method has been created as per the requirement of NPD-214 by Pankaj Ganwani on 9th Oct, 2015 */
	
	/*
        * MethodName        : createAccountShare
        * param             : Map<Id, NPD_Account_Team__c> oldMap, Map<Id, NPD_Account_Team__c> newMap
        * Description       : This function will share account with users.
    */
	private void createGroupAndShareAccount(Map<Id, Account> newMap)
	{
	    List<Group> lstGroup = new List<Group>(); //list of group 
	    List<AccountShare> lstAccountShare = new List<AccountShare>();//list for Account share 
	    map<String, List<Account>> mapParentAccountNameToLstAccount = new map<String, List<Account>>();//map to store the Account Parent name to list of Account
	    
	    //get the reocrdtype 
	    List<RecordType> lstRecordTypeParentAccount = [SELECT Id FROM RecordType WHERE SobjectType ='Account' AND DeveloperName ='Parent_Account'];
	    List<RecordType> lstRecordTypePracticeAccount = [SELECT Id FROM RecordType WHERE SobjectType ='Account' AND DeveloperName ='Practice_Account'];
	    
	    //fetch all accounts and if record type is Parent Account then create group and share with that group
	    // if record type Practice Account and Company_Account__c not null then share the account with parent Account name matching group 
	    for(Account objAccount:[SELECT Id, Name, Group_Name__c, RecordTypeId, Company_Account__c, Company_Account__r.Group_Name__c FROM Account WHERE Id IN: newMap.keySet()])
	    {
	        if(!lstRecordTypeParentAccount.isEmpty() && objAccount.RecordTypeId == lstRecordTypeParentAccount[0].Id)
	        {
	            lstGroup.add(new Group(Name = objAccount.Group_Name__c));
	        }
	        if(!lstRecordTypePracticeAccount.isEmpty() && objAccount.RecordTypeId == lstRecordTypePracticeAccount[0].Id && objAccount.Company_Account__c != null)
	        {
	            if(!mapParentAccountNameToLstAccount.containsKey(objAccount.Company_Account__r.Group_Name__c))
	                mapParentAccountNameToLstAccount.put(objAccount.Company_Account__r.Group_Name__c, new List<Account>{objAccount});
	            else
	                mapParentAccountNameToLstAccount.get(objAccount.Company_Account__r.Group_Name__c).add(objAccount);
	        }
	    }
	    
	    //query all the groups based on account parent Account name
	    for(Group objGroup:[SELECT Id, Name FROM Group WHERE Name IN: mapParentAccountNameToLstAccount.KeySet()])
	    {
	        for(Account objAccount:mapParentAccountNameToLstAccount.get(objGroup.Name))
	        {
	            lstAccountShare.add(new AccountShare(AccountId = objAccount.Id, AccountAccessLevel = 'Edit', 
                                                        OpportunityAccessLevel = 'Read',
                                                        UserOrGroupId = objGroup.Id));
	        }
	    }
	    insert lstGroup;
	}
	
	/*
        * MethodName        : createChatterGroup
        * param             : Map<Id, Account> newMap
        * Description       : This method will create chatter group
    */
	private void createChatterGroup(Map<Id, Account> newMap)
	{
	    List<CollaborationGroup> lstCollaborationGroup = new List<CollaborationGroup>(); //list of CollaborationGroup 
	    
	    List<RecordType> lstRecordTypeParentAccount = [SELECT Id FROM RecordType WHERE SobjectType ='Account' AND DeveloperName ='Parent_Account'];
	    
	    for(Account objAccount: newMap.values())
	    {
	        if(!lstRecordTypeParentAccount.isEmpty() && lstRecordTypeParentAccount[0].Id == objAccount.RecordTypeId)
	            lstCollaborationGroup.add(new CollaborationGroup(Name = objAccount.Group_Name__c, CollaborationType = 'Private'));
	    }
	    insert lstCollaborationGroup;
	}
}