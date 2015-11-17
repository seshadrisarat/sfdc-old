/*
    Author: Mike Petrillo (Black Tab Group)
    Date: 2/16/12
    Purpose: Fires when a new contact is created. If the accociated account type
    is "Prospect" or "Customer" change the contact owner to the account owner.
    
*/  

trigger ContactTypeTrigger on Contact (before insert) {

    set<id> soap=new set<id>();
    for(contact c:trigger.new)
        {
            soap.add(c.accountid);
        }
    map<id,account>must=new map<id,account>([select id,ownerid,Account_Type__c from account where id in:soap]);
    List <Account> currentAccounts = new List <Account>();
    currentAccounts = [select id,ownerid,Account_Type__c from account where id in:soap limit 1];
    
    if(currentAccounts.Size() > 0){
	    for(contact g:trigger.new)
	        {
	            if(currentAccounts[0].Account_Type__c == 'Prospect' || currentAccounts[0].Account_Type__c == 'Customer')
	                {
	                    g.ownerid=must.get(g.accountid).ownerid;
	                    System.debug('The value in the g.ownerid is'+g.ownerid);
	                }
	    }	
    }

}