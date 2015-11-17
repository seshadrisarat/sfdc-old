trigger AccountAssignBeforeInsertUpdate on Account_Assignment__c (before insert,before update) {

       for(Account_Assignment__c newAccountAssignment : Trigger.new) {
                   newAccountAssignment.Owner_2__c = newAccountAssignment.OwnerId;   
       }
       
}