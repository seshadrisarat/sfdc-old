trigger AccountBeforeInsertUpdate on Account (before insert,before update) {

       for(Account newAccount : Trigger.new) {
                   newAccount.Account_Owner_2__c = newAccount.OwnerId;   
       }
       
}