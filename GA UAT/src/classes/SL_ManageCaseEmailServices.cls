/**
* \arg ClassName      : SL_ManageCaseEmailServices
* \arg JIRATicket     : GA-25
* \arg CreatedOn      : 12/May/2015
* \arg LastModifiedOn : 18/May/2015
* \arg CreatededBy    : Sandeep
* \arg ModifiedBy     : Sandeep
* \arg Description    : This class will create or update case based on the received email
*/
global class SL_ManageCaseEmailServices implements Messaging.InboundEmailHandler
{
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env) 
    {
    	String strMainBody ;
    	String strCaseCommentBody ;
    	
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        //if email subject startswith NEW: then create a new case
        if(email.subject.startsWith('NEW:'))
        {
            email.plainTextBody =  email.plainTextBody.length() > 32000 ? email.plainTextBody.substring(0, 31950) : email.plainTextBody;

            //fetch the case Assignement rule 
            List<AssignmentRule> lstAssignRule = [select id from AssignmentRule where SobjectType = 'Case' and Active = true ];
            
            //replace the NEW: string from email subject
            email.subject = email.subject.replaceFirst('NEW:', '');
            Case objCase = new Case(Subject = email.subject, 
                                    Description = email.plainTextBody, 
                                    Status = 'New');
            //apply the assignment rules for newly created case
            Database.DMLOptions dmlOpts = new Database.DMLOptions();
            if(!lstAssignRule.isEmpty())
            {
                dmlOpts.assignmentRuleHeader.assignmentRuleId = lstAssignRule[0].id;
                objCase.setOptions(dmlOpts);
            }                

            insert objCase;//insert the case
            //create task for newly created case with same subject and email body
            Task objTask = new Task(Subject = email.subject, 
                                    Description = email.plainTextBody, 
                                    Status='Not Started', whatId = objCase.Id );
            insert objTask;//insert the task
        }
        else
        {
            //if Subject is not starts with NEW: then check for existing record if found then reply user for confirmation
            email.subject = email.subject.startsWith('Re:') ? email.subject.replaceFirst('Re:', '').trim() : email.subject;
            email.subject = email.subject.startsWith('Sandbox:') ? email.subject.replaceFirst('Sandbox:', '').trim() : email.subject;
            
            strMainBody = String.isEmpty(email.plainTextBody) ? '' : email.plainTextBody.substring(0, 3).trim();

            //fetch the most recent case record based on email subject 
            List<Case> lstCase = [SELECT Id, IsClosed FROM Case WHERE Subject =: email.subject order by createdDate DESC ];
            if(!lstCase.isEmpty() && email.inReplyTo == null)
            {
            	EmailServicesFunction  objEmailServiceFunstion = [ Select (Select LocalPart, EmailDomainName From Addresses) From EmailServicesFunction WHERE FunctionName =: 'SL_ManageCaseEmailServices'];
                Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
                String strUserEmail = email.fromAddress;
                mail.setToAddresses(new String[]{strUserEmail});
                mail.setSubject(email.subject); 
                mail.setSaveAsActivity(false);
                if(objEmailServiceFunstion.Addresses[0].LocalPart != null && objEmailServiceFunstion.Addresses[0].EmailDomainName != null)
                	mail.setReplyTo(objEmailServiceFunstion.Addresses[0].LocalPart +'@'+objEmailServiceFunstion.Addresses[0].EmailDomainName) ;
                mail.setHtmlBody('Existing record found, Reply <b>YES</b> to Update the recent record.<br><br>'+email.plainTextBody);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
            }
            //if list is not empty and user confirm the email by using sending the YES in email body then get the recent case and create casecomment and task
            else if(!lstCase.isEmpty() && email.inReplyTo != null  && strMainBody.equalsIgnoreCase('yes'))
            {
                email.plainTextBodyIsTruncated = true;
                email.plainTextBody = email.plainTextBody.length() > 32000 ? email.plainTextBody.substring(0, 31950) : email.plainTextBody ;
                strCaseCommentBody = email.plainTextBody.length() > 4000 ? email.plainTextBody.substring(0, 3950) : email.plainTextBody;
                List<Sobject> lstSobject = new List<Sobject>();//intialize the list of sobject
                
                //iterate over the list and check for most recent open case and create task and comment for found case
                for(Case objCase :lstCase)
                {
                    if(!objCase.IsClosed)
                    {
                        lstSobject.add(new Task(Subject = email.subject, Description = email.plainTextBody, Status='Completed',whatId = objCase.Id ));
                        lstSobject.add(new CaseComment(CommentBody = strCaseCommentBody  , ParentId = objCase.Id));
                        break;
                    }
                }
                //if list is not empty then insert the Task and comment
                if(lstSobject.isEmpty())
                {
                    //iterate over the list and check for most recent closed case , create task and case comment for that case record
                    for(Case objCase :lstCase)
                    {
                        if(objCase.IsClosed)
                        {
                            lstSobject.add(new Task(Subject = email.subject, Description = email.plainTextBody, Status='Completed', whatId = objCase.Id ));
                            lstSobject.add(new CaseComment(CommentBody = strCaseCommentBody  , ParentId = objCase.Id));
                            break;
                        }
                    }
                }
                try{
                //if list is not empty then insert the Task and comment
                if(!lstSobject.isEmpty())
                    insert lstSobject;
                 }
                 catch(Exception ex)
                 {
                     System.debug('=======Exception============'+ex);
                 }
            }
            else
            {
                //if there is no existing record found for the email subject line then return a message 'No existing Case was found, please try again.'
                result.message = 'No existing Case was found, please try again.';
                result.success = true;
                return result;
            }
        }
        result.success = true;
        return result;
    }
}