/**  
* \arg ClassName        : SL_ContactTriggerHandler
* \arg JIRATicket       : NPD-212
* \arg CreatedOn        : 09/Oct/2015
* \arg LastModifiedOn   : 09/Oct/2015
* \arg CreatededBy      : Lodhi
* \arg ModifiedBy       : Lodhi
* \arg Description      : Handler class for Contact object.
*/
global class SL_ContactTriggerHandler extends SL_TriggerHandlerBase {

	public override void beforeInsert(List<SObject> newListGeneric){
		List<Contact> newList = (List<Contact>) newListGeneric;
		/*BEFORE INSERT METHODS START*/
		
		/*BEFORE INSERT METHODS END*/
	}
	
	public override void beforeUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric){
		Map<Id, Contact> oldMap = (Map<Id, Contact>) oldMapGeneric;
		Map<Id, Contact> newMap = (Map<Id, Contact>) newMapGeneric;
		/*BEFORE UPDATE METHODS START*/
		
		/*BEFORE UPDATE METHODS END*/
	}
	
	public override void beforeDelete(Map<Id, SObject> oldMapGeneric){
		Map<Id, Contact> oldMap = (Map<Id, Contact>) oldMapGeneric;
		/*BEFORE DELETE METHODS START*/
		
		/*BEFORE DELETE METHODS END*/
	}
	
	public override void afterInsert(Map<Id, SObject> newMapGeneric){
		Map<Id, Contact> newMap = (Map<Id, Contact>) newMapGeneric;
		/*AFTER INSERT METHODS START*/
		updateContactParentId(newMap);
		/*AFTER INSERT METHODS END*/
	}
	
	public override void afterUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric){
		Map<Id, Contact> oldMap = (Map<Id, Contact>) oldMapGeneric;
		Map<Id, Contact> newMap = (Map<Id, Contact>) newMapGeneric;
		/*AFTER UPDATE METHODS START*/
		
		/*AFTER UPDATE METHODS END*/
	}
	
	public override void afterDelete(Map<Id, SObject> oldMapGeneric){
		Map<Id, Contact> oldMap = (Map<Id, Contact>) oldMapGeneric;
		/*AFTER DELETE METHODS START*/
		
		/*AFTER DELETE METHODS END*/
	}
	
	public override void afterUndelete(Map<Id, SObject> newMapGeneric){
		Map<Id, Contact> newMap = (Map<Id, Contact>) newMapGeneric;
		/*AFTER UNDELETE METHODS START*/
		
		/*AFTER UNDELETE METHODS END*/
	}
	
	/*
        * MethodName        : updateContactParentId
        * param             : new Map<Id, Contact> 
        * Description       : This method will update AccountId field on inserted Contact if its parent is practice account.
    */
	private void updateContactParentId(Map<Id, Contact> mapIdToContactNew)
	{
	    Map<Id, List<Contact>> mapAccountIdToLstContact = new Map<Id, List<Contact>>();
	    Map<Id, Id> mapAccIdToCmpnyAccId = new Map<Id, Id>();
	    List<Contact> lstContactToUpdate = new List<Contact>();
	    List<Contact_Relationship__c> lstConRelationship = new List<Contact_Relationship__c>();
	    
	    //Iterating over new map of contact to collect a map of account id to list of contact.
	    for(Contact objContact : mapIdToContactNew.values())
	    {
	        if(objContact.AccountId != null)
	        {
	            if(!mapAccountIdToLstContact.containsKey(objContact.AccountId))
	                mapAccountIdToLstContact.put(objContact.AccountId, new List<Contact>());
                mapAccountIdToLstContact.get(objContact.AccountId).add(objContact); 
	        }
	    }
	    
	    //Itertaing over practice accounts
	    for(Account objAccount : [SELECT Id, Company_Account__c 
	                                FROM Account 
	                               WHERE Company_Account__c != null 
	                                 AND RecordType.DeveloperName = 'Practice_Account' 
	                                 AND Id IN : mapAccountIdToLstContact.keySet()])
        {
            mapAccIdToCmpnyAccId.put(objAccount.Id, objAccount.Company_Account__c);
        }
        
        //Updating the accountId on new contact and creating a Contact_Relationship__c relationship record corresponding to the previous accountid
        for(Id accountId : mapAccIdToCmpnyAccId.keySet())
        {
            Id cmpnyAccountId = mapAccIdToCmpnyAccId.get(accountId);
            for(Contact objContact : mapAccountIdToLstContact.get(accountId))
            {
                lstConRelationship.add(new Contact_Relationship__c(Contact__c = objContact.Id, Account__c = objContact.AccountId));
                lstContactToUpdate.add(new Contact(Id = objContact.Id, AccountId = cmpnyAccountId));
            }
        }
        
        insert lstConRelationship;
        update lstContactToUpdate;
	}
	/* End */
}