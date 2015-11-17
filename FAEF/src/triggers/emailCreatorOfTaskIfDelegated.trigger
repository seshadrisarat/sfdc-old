trigger emailCreatorOfTaskIfDelegated on Task (after insert, after update) {
    
    List<Task> taskList = new List<Task>();
    
    //Send Email If Notify_Creator_When_Complete__c is TRUE && Status = 'Completed'
    for(Task t : Trigger.new){
        System.debug(t.Notify_Creator_When_Complete__c + ' ' + t.Status);
        if(t.Notify_Creator_When_Complete__c == true && t.Status == 'Completed'){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            User sender = [SELECT id, name, email FROM User WHERE Id = :t.OwnerId LIMIT 1];
            User recipient = [SELECT id, name, email FROM USER WHERE Id = :t.CreatedById LIMIT 1];
            
            String[] toAddresses = new String[] {recipient.email};
            
            mail.setReplyTo(sender.email);
            mail.setToAddresses(toAddresses);
            mail.setSenderDisplayName(sender.name);
            mail.setSubject(sender.name + ' has completed a task.');
            mail.setPlainTextBody(sender.name + ' has completed the following task: \n' +
                                  'Task Subject: ' + t.Subject + '\n' +
                                  'Call Note: ' + t.Call_Note__c + '\n' +
                                  'Comments: ' + t.Description + '\n' +
                                  'Record Link: ' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + t.id);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            System.debug('Sending email to ' + recipient.email);
            
            Task task = new Task( id = t.id, Notify_Creator_When_Complete__c = false);
            taskList.add(task);
        }
    }
    
    if(taskList.size() > 0){
    	update taskList;
    }
}