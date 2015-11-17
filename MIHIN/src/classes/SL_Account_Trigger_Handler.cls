/*
*Class: SL_Account_Trigger_Handler
*Description: This is a handler class for Account trigger that is used for following purpose:
			  - To validate the transfer of Account record
			  - To update the Geocoding_Required__c field based on the status of shipping address of Account
*Copyright 2014 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
public without sharing class SL_Account_Trigger_Handler{
private boolean m_isExecuting = false;
    private integer BatchSize = 0;
     
    public SL_Account_Trigger_Handler(boolean isExecuting, integer size)
    {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
         
    public void OnBeforeInsert(list<Account> newAccounts){
        callUpdateTOCSubscriptions(newAccounts);
    }
     
    public void OnAfterInsert(map<ID,Account> newAccountMap){ }
     
    @future public static void OnAfterInsertAsync(Set<ID> newOpportunityIDs){ }
     
    public void OnBeforeUpdate(map<ID,Account> oldAccountMap, map<ID,Account> newAccountMap){
        set<Id> setRecordIds = new set<Id>();//To store the contacts where ownerId is changed.
    	set<Id> setErrorRecordIds = new set<Id>();
        
        for(Account a : newAccountMap.values()){
        	
        	//Added by Sandeep regarding MIHIN-92: To check if ownerId is changed.
    		if(oldAccountMap.get(a.Id).OwnerId != newAccountMap.get(a.Id).OwnerId)
    				setRecordIds.add(a.Id);	
    				
            //if the account had a shipping address but doesn't anymore, clear the geocode
            if(a.ShippingStreet == '' || a.ShippingStreet == null){
                if(!(oldAccountMap.get(a.id).ShippingStreet == '' ||oldAccountMap.get(a.id).ShippingStreet == null)){
                    a.Location__Latitude__s = null;
                    a.Location__Longitude__s = null;
                }
            //if the accounts address changed, prepare to geocode
            }else if((a.ShippingStreet != oldAccountMap.get(a.id).ShippingStreet)||(a.ShippingState != oldAccountMap.get(a.id).ShippingState)||(a.ShippingCity != oldAccountMap.get(a.id).ShippingCity) || (a.ShippingPostalCode != oldAccountMap.get(a.id).ShippingPostalCode)){
                a.Geocoding_Required__c = true;
            }
        }    
        
        //Added by Sandeep MIHIN-92
    	if(!setRecordIds.isEmpty()) {
    		
    		SL_ValidateRecordTransfer objSL_ValidateRecordTransfer = new SL_ValidateRecordTransfer();
    		setErrorRecordIds = objSL_ValidateRecordTransfer.validateUpdatedRecords(setRecordIds);
    		
    		if(!setErrorRecordIds.isEmpty()) {
	    		//Iterating the records and throwing error on records those not satisfied the required conditions.
		    	for(Account objAccount : newAccountMap.values())
		    	{
		    		if(setErrorRecordIds.contains(objAccount.Id))
		    			objAccount.addError(Label.SL_UnauthorizedRecordTransferError);
		    	}
    		}
    	}

        callUpdateTOCSubscriptions(newAccountMap.values());


    }
     
    public void OnAfterUpdate(map<ID,Account> oldAccountMap, map<ID,Account> newAccountMap){ 

        SL_ScriptPrecedenceUtil precedenceUtil = new SL_ScriptPrecedenceUtil('Account');
        precedenceUtil.getNewMap(oldAccountMap, newAccountMap);

    }
     
    @future public static void OnAfterUpdateAsync(Set<ID> updatedAccountIDs){ }
     
    public void OnBeforeDelete(map<ID,Account> oldAccountMap){ }
     
    public void OnAfterDelete(map<ID,Account> oldAccountMap){ }
     
    @future public static void OnAfterDeleteAsync(Set<ID> deletedAccountIDs){ }
     
    public void OnBeforeUndelete(list<Account> restoredAccounts){ }
 
    public void OnAfterUndelete(list<Account> restoredAccounts){ }

    private void callUpdateTOCSubscriptions(list<Account> newAccounts){
        list<Account> updateTOCSubscriptions = new list<Account>();
        for(Account a : newAccounts){
            if(!String.isBlank(a.Add_TOC_Subscription__c) || !String.isBlank(a.Remove_TOC_Subscription__c)){
                updateTOCSubscriptions.add(a);
            }
        }
        if(!updateTOCSubscriptions.isEmpty()){
            updateTOCSubscriptions(updateTOCSubscriptions);
        }
        for(Account a : newAccounts){
            a.Add_TOC_Subscription__c = null;
            a.Remove_TOC_Subscription__c = null;
        }
    }

    public void updateTOCSubscriptions(list<Account> newAccounts){
        for(Account a : newAccounts){
            list<String> addValues;
            list<String> removeValues;
            if(!String.isBlank(a.Add_TOC_Subscription__c)){
                addValues = getSeparatedValues(a,'Add_TOC_Subscription__c');
                if(addValues != null && !addValues.isEmpty()){
                    for(String picklistValue : addValues){
                        if(!String.isBlank(picklistValue)){
                            if(!String.isBlank(a.TOC_Subscriptions__c)){
                                a.TOC_Subscriptions__c += ';';
                            }
                            a.TOC_Subscriptions__c += picklistValue;
                        }
                    }
                }
            }
            if(!String.isBlank(a.Remove_TOC_Subscription__c)){
                removeValues = getSeparatedValues(a,'Remove_TOC_Subscription__c');
                if(removeValues != null && !removeValues.isEmpty()){
                    for(String picklistValue : removeValues){
                        if(!String.isBlank(picklistValue)){
                            if(a.TOC_Subscriptions__c.endsWithIgnoreCase(picklistValue)){
                                a.TOC_Subscriptions__c =  a.TOC_Subscriptions__c.removeEndIgnoreCase(picklistValue);
                            }
                            if(a.TOC_Subscriptions__c.contains(';' + picklistValue + ';')){
                                a.TOC_Subscriptions__c = a.TOC_Subscriptions__c.replace(';' + picklistValue + ';', ';');
                                a.TOC_Subscriptions__c = a.TOC_Subscriptions__c.removeEndIgnoreCase(';');
                            }
                            if(a.TOC_Subscriptions__c.startsWithIgnoreCase(picklistValue)){
                                a.TOC_Subscriptions__c = a.TOC_Subscriptions__c.removeStartIgnoreCase(picklistValue);
                                a.TOC_Subscriptions__c = a.TOC_Subscriptions__c.removeStartIgnoreCase(';');
                            }
                        }
                    }
                }
            }
        }
    }

    private list<String> getSeparatedValues (Account a, String field){
        list<String> output;
        String fieldValue = (String)a.get(field);
        fieldValue = fieldValue.removeEndIgnoreCase(',');
        a.put(field,fieldValue);

        if(fieldValue.contains(',')){
            output = fieldValue.split(',');
        }
        else{
            output = new list<String>{fieldValue};
        }
        return output;
    }
             
    public boolean IsTriggerContext{
        get{ return m_isExecuting;}
    }
     
    public boolean IsVisualforcePageContext{
        get{ return !IsTriggerContext;}
    }
     
    public boolean IsWebServiceContext{
        get{ return !IsTriggerContext;}
    }
     
    public boolean IsExecuteAnonymousContext{
        get{ return !IsTriggerContext;}
    }  
 
}