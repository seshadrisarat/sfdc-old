/*
* Handles the account trigger
*
* @author Mike Regan
*/
public class AccountTriggerHandler extends TriggerHandler {
	private list<Account> newAccountList;
	private list<Account> oldAccountList;
	private map<Id, Account> newAccountMap;
	private map<Id, Account> oldAccountMap;

	public AccountTriggerHandler() {
		newAccountList = (list<Account>)Trigger.new;
		oldAccountList = (list<Account>)Trigger.old;
		newAccountMap = (map<Id, Account>)Trigger.newMap;
		oldAccountMap = (map<Id, Account>)Trigger.oldMap;
  	}
  	
  	public override void afterInsert() {
  		OwnerServices.writeNewOwnerAccountsToPardotObjectChangeLog(newAccountList);
  	}
  	
  	public override void afterUpdate() {
  		OwnerServices.writeUpdatedOwnerAccountsToPardotObjectChangeLog(newAccountList);
  	}
  	
  	public override void beforeDelete() {
  		OwnerServices.writeDeletedOwnerAccountsToPardotObjectChangeLog(oldAccountList);	
  	}
  	
  	public override void afterUndelete() {
  		OwnerServices.writeUnDeletedOwnerAccountsToPardotObjectChangeLog(newAccountList);	
  	}
}