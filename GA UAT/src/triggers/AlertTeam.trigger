trigger AlertTeam on Task (after insert) {
    Set<Id> taskIds = new Set<Id>();
    for(Task t : trigger.new) {
        if (t.Notify_Deal_Team__c) {
            taskIds.add(t.Id);
        }
    }
    
    Map<Id,Messaging.SingleEmailMessage> dealEmail = new Map<Id,Messaging.SingleEmailMessage>();
    List<Id> deals = new List<Id>();
    
    if (!taskIds.isEmpty()) {
        for(Task t : [SELECT Id, Subject, ActivityDate, Priority, WhatId, What.Name, WhoId, Who.Name, Description FROM Task WHERE Id in: taskIds]) {
            // Build email body
            String textBody = '';
            String htmlBody = '';

            textBody += 'Subject: ' + t.Subject + '\n';
            textBody += 'Due Date: ' + t.ActivityDate.format() + '\n';
            textBody += 'Priority: ' + t.Priority + '\n';
            htmlBody += '<p>';
            htmlBody += '<b>Subject: </b>' + t.Subject + '<br/>';
            htmlBody += '<b>Due Date: </b>' + t.ActivityDate.format() + '<br/>';
            htmlBody += '<b>Priority: </b>' + t.Priority + '<br/>';
            if (t.WhatId != null) {
                textBody += 'Related To: ' + t.What + '\n';
                htmlBody += '<b>Related To: </b>' + t.What.Name + '<br/>';
            } else {
                textBody += 'Related To:\n';
                htmlBody += '<b>Related To:</b><br/>';
            }
            if (t.WhoId != null) {
                textBody += 'Name: ' + t.Who + '\n';
                htmlBody += '<b>Name: </b>' + t.Who.Name + '<br/>';
            } else {
                textBody += 'Name:\n';
                htmlBody += '<b>Name:</b><br/>';
            }
            if (t.Description != null) {
                textBody += 'Comments: ' + t.Description;
                htmlBody += '<b>Comments: </b>' + t.Description;
            } else {
                textBody += 'Comments:\n';
                htmlBody += '<b>Comments: </b><br/>';
            }
            htmlBody += '</p>';
            htmlBody += 'Click <a href=https://na1.salesforce.com/' + t.Id + '>here</a> to view the task.';

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();          
            mail.setSubject('New Task Alert: ' + t.Subject);
            mail.setPlainTextBody(textBody);
            mail.setHtmlBody(htmlBody);
            mail.setUseSignature(false);
            mail.setSaveAsActivity(false);
            
            deals.add(t.WhatId);
            dealEmail.put(t.WhatId,mail);
        }
        
        for (Team_Member__c tm : [SELECT Deal__c, Email__c FROM Team_Member__c WHERE isDeleted = FALSE AND Deal__c IN :deals]) {
            Messaging.SingleEmailMessage mail = dealEmail.get(tm.Deal__c);
            if (mail != null && tm.Email__c != null) {
                Set<String> e = new Set<String>();
                if (mail.getToAddresses() != null) {
                    e.addAll(mail.getToAddresses());
                }
                e.add(tm.Email__c);
                List<String> temp = new List<String>();
                temp.addAll(e);
                mail.setToAddresses(temp);
                dealEmail.put(tm.Deal__c, mail);
            }
        }
        for (Messaging.SingleEmailMessage mail : dealEmail.values()) {
            if (mail.getToAddresses() != null) {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
        }
    }
}