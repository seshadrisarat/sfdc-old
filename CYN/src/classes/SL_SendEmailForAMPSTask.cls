public class SL_SendEmailForAMPSTask 
{
    /*@InvocableMethod(label='Send Email to Marketing Users' description='Send Email to Marketing Users for AMPS Task')
    public static void sendEmail(List<String> CompositeUserIdTaskId)
    {
        String IdString = CompositeUserIdTaskId[0];
        List<String> lstofIds = new List<String>(IdString.trim().split(';'));
        String UserId = lstofIds[0].trim();
        String TaskId = lstofIds[1].trim();
        User objUser = [Select Id,email from User where Id =:UserId LIMIT 1];
        Task objTask = [Select Id,Subject,Description,Account.Name from Task where Id =:TaskId LIMIT 1];
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> sendTo = new List<String>();
        mail.setToAddresses(new List<String>{objUser.email});
        mail.setReplyTo(UserInfo.getUserEmail());
        mail.setSenderDisplayName(UserInfo.getName());
        mail.setSubject(objTask.Subject);
        String body = 'Practice: ' + objTask.Account.Name + '<br/>';
        body += 'Comments:' + ((objTask.Description == null) ? ' - ' : objTask.Description) + '<br/>';
        body += 'Link To Activity :' + URL.getSalesforceBaseUrl().toExternalForm() + '/'+ TaskId ;
        mail.setHtmlBody(body);
        mails.add(mail);
        Messaging.sendEmail(mails);
    }*/
    
    @InvocableMethod(label='Send Email to Marketing Users' description='Send Email to Marketing Users for AMPS Task')
    public static void sendEmail(List<String> CompositeUserIdTaskId)
    {
        String TaskId = CompositeUserIdTaskId[0];
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Task objTask = [Select Id,User_1_Id__c , User_2__c ,User_3__c , User_4__c , User_5__c , User_6__c , User_7__c , Subject , Description , Account.Name from Task where Id =: TaskId Limit 1];
        Set<String> setUserId = new set<String>{objTask.User_1_Id__c ,
                                        objTask.User_2__c,
                                        objTask.User_3__c,
                                        objTask.User_4__c,
                                        objTask.User_5__c,
                                        objTask.User_6__c,
                                        objTask.User_7__c
        };
        for(User objUser : [Select Id , Email from User where Id IN:setUserId])
        {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new List<String>{objUser.email});
            mail.setReplyTo(UserInfo.getUserEmail());
            mail.setSenderDisplayName(UserInfo.getName());
            mail.setSubject(objTask.Subject);
            String body = 'Practice: ' + objTask.Account.Name + '<br/>';
            body += 'Comments:' + ((objTask.Description == null) ? ' - ' : objTask.Description) + '<br/>';
            body += 'Link To Activity :' + URL.getSalesforceBaseUrl().toExternalForm() + '/'+ TaskId ;
            mail.setHtmlBody(body);
            mails.add(mail);
        }
        
        if(!mails.isEmpty())
            Messaging.sendEmail(mails);
    }
}