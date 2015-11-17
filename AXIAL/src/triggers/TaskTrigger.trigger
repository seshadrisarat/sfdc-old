trigger TaskTrigger on Task (before insert, before update, after insert, after update) {

  /* 
    This logic is DUPLICATED in the Event trigger.
  */
  if(trigger.isBefore){
    List<Task> triggerNew = trigger.new;
    if(triggerNew.size() == 1){
      Task t = triggerNew[0];
      if(t.whoId != null){
          List<Contact> cons = [Select Id, Highest_Call__c FROM Contact WHERE Id = :t.WhoId];
          if(cons.size() > 0){
              Contact c = cons[0];
              Decimal highestCall = 0;
              if(c.Highest_Call__c != null){
                highestCall = c.Highest_Call__c;
              }
              if(t.Call_Number__c != null){
                  if(Decimal.valueOf(t.Call_Number__c) > highestCall){
                    c.Highest_Call__c = Decimal.valueOf(t.Call_Number__c);
                    update c;
                  }                  
              }
           
        }
      }
    }
  }
}