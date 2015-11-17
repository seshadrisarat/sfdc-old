public with sharing class SendCallReport {

    public SelectOption[] allContacts { get; set; }
    public SelectOption[] toSelectedContacts { get; set; }
    public SelectOption[] toAllContacts { get; set; }
        
    public SelectOption[] ccSelectedContacts { get; set; }
    public SelectOption[] ccAllContacts { get; set; }
    
    public String toMessage { get; set; }
    public String ccMessage { get; set; }
    public String taskWhoName { get; set; }
    public String contactFirmName { get; set; }
    public String taskWhatName { get; set; }
    public String relationshipManager {get; set; }
    public String taskId { get; set; }
    public String taskSubject { get; set; }
    public String taskDescription { get; set; }
    public String taskHtmlDescription { get; set; }
    public String taskOwner { get; set; }
    public String taskActivityDate { get; set; }
    public String taskType { get; set; }
    public String taskUrl { get; set; }
    public Datetime taskCallReportDataTime { get; set; }
    
    
    private final Task tsk;
    private final Contact who;
    private final Contact contactFirm;
    private final User usr;
    
    public SendCallReport() {
        Datetime dt = Datetime.now();
        Date d = dt.date();
        Time t = dt.time();
        taskCallReportDataTime = Datetime.newInstance(d,t);
        
        taskId = ApexPages.currentPage().getParameters().get('Id');
        taskUrl = 'https://' + ApexPages.currentPage().getHeaders().get('Host') + '/' + taskId;
        
        tsk = [SELECT Id, whoId, who.name, who.type, whatId, what.name, what.type, ownerId, owner.name, activityDate, type, subject, description FROM Task WHERE Id = :taskId];
        if (tsk.whoId != null) {
            taskWhoName = tsk.who.name;
        } else if (tsk.whatId != null) {
            taskWhoName = tsk.what.name;
        }
        if (tsk.whoId != null && tsk.who.type.equals('Contact')) {
            contactFirm = [SELECT Id, FirstName, LastName, Account.Id, Account.Name from Contact where id = :tsk.whoId];
            contactFirmName = contactFirm.Account.Name;
        } else {
			contactFirmName = 'N/A';         	   
        }
        if (tsk.subject != null) {
            taskSubject = tsk.subject;
        }
        if (tsk.description != null) {
            taskDescription = tsk.description;
            taskHtmlDescription = tsk.Description.replaceAll('\n', '<br/>');
        }   
        taskOwner = tsk.owner.name;
        if (tsk.activityDate != null) {
            taskActivityDate = tsk.activityDate.Format();
        }
        if (tsk.type != null) {
            taskType = tsk.type;
        }
        
        toSelectedContacts = new List<SelectOption>();
        ccSelectedContacts = new List<SelectOption>();
        
        allContacts = new List<SelectOption>();
        
        List<DistributionList__c> distributionListEmails = [Select Name, Email__c From DistributionList__c order by Name];    
        for ( DistributionList__c u : distributionListEmails ) {
            allContacts.add(new SelectOption(u.Email__c, u.Name));
        }
        
        List<User> userEmails = [Select Name, Email From User where isActive = true and profile.Name like 'HAI%' order by Name];    
        for ( User u : userEmails ) {
            allContacts.add(new SelectOption(u.Email, u.Name));
        }    
        
        toAllContacts = allContacts;
        ccAllContacts = allContacts;
    }

    public PageReference send() {
       
        if (toSelectedContacts.size() > 0 || ccSelectedContacts.size() > 0) {
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            Boolean first;
            String[] toAddresses = new String[] {};
            toAddresses.clear();
            String toContacts = '';
            first = true;
            for ( SelectOption so : toSelectedContacts ) {
                toAddresses.add(so.getValue());
                
                if (!first) {
                    toContacts += ', ';
                }
                toContacts += so.getLabel();
                first = false;
            }
                        
            String[] ccAddresses = new String[] {};
            ccAddresses.clear();
            String ccContacts = '';
            first = true;
            for ( SelectOption so : ccSelectedContacts ) {
                ccAddresses.add(so.getValue());
                
                if (!first) {
                    ccContacts += ', ';
                }
                ccContacts += so.getLabel();
                first = false;
            }
            
            // Assign the addresses for the To and CC lists to the mail object. 
        
            mail.setToAddresses(toAddresses);
            
            mail.setCcAddresses(ccAddresses);
    
            // Specify the address used when the recipients reply to the email.  
        
            String userId = UserInfo.getUserId();
            User activeUser = [Select Email From User where Id = : userId limit 1];
            String userEmail = activeUser.Email;
            
            mail.setReplyTo(userEmail);
    
            // Specify the name used as the display name. 
        
            mail.setSenderDisplayName(UserInfo.getUserName());
    
            // Specify the subject line for your email address. 
        
            mail.setSubject('Salesforce Call Report: ' + taskWhoName);
    
            // Set to True if you want to BCC yourself on the email. 
        
            mail.setBccSender(false);
    
            // Optionally append the salesforce.com email signature to the email. 
            // The email address of the user executing the Apex Code will be used. 
        
            mail.setUseSignature(false);
    
            // Specify the text content of the email. 
        
            //mail.setPlainTextBody('Call Report: \n\t' + taskWhoName + '\n\nYour Task: \n\t' + taskSubject + '\n\nDescription: \n\t' + taskDescription);
           
                //'<p><b>Who: </b>' + taskWhoName + '</apex:outputText></p>' +
                //'<p><b>Subject: </b>' + taskSubject + '</apex:outputText></p>' +
                //'<p><b>Activity Date: </b>' + taskActivityDate + '</apex:outputText></p>' +
                //'<p><b>Type: </b>' + taskType + '</apex:outputText></p>' +
                //'<p><b>Owner: </b>' + taskOwner + '</apex:outputText></p>' +
                //'<p><b>Call Report Sent: </b>' + taskCallReportDataTime.format('MM/dd/yyyy hh:mm a', 'America/Chicago') + '</apex:outputText></p>' +
                            
            mail.setHtmlBody(
                '<table border="0">' +
                    '<tr>' +
                        '<td  align="right"><b>Contact: </b></td>' + 
                        '<td>' + taskWhoName + '</td>' +
                    '</tr>' +
                    '<tr>' +
                        '<td  align="right"><b>Firm: </b></td>' + 
                        '<td>' + contactFirmName + '</td>' +
                    '</tr>' +
                    '<tr>' +
                        '<td  align="right"><b>Subject: </b></td>' + 
                        '<td>' + taskSubject + '</td>' +
                    '</tr>' +
                    '<tr>' +
                        '<td  align="right"><b>Activity Date: </b></td>' + 
                        '<td>' + taskActivityDate + '</td>' +
                    '</tr>' +
                    '<tr>' +
                        '<td  align="right"><b>Type: </b></td>' + 
                        '<td>' + taskType + '</td>' +
                    '</tr>' +
                    '<tr>' +
                        '<td  align="right"><b>Owner: </b></td>' + 
                        '<td>' + taskOwner + '</td>' +
                    '</tr>' +
                    '<tr>' +
                        '<td  align="right"><b>Call Report Sent: </b></td>' + 
                        '<td>' + taskCallReportDataTime.format('MM/dd/yyyy hh:mm a', 'America/Chicago') + '</td>' +
                    '</tr>' +
                '</table>' +
                '<p><b>Note: </b><br/>' + taskHtmlDescription + '</p>' +
                'To view the activity <a href=' + taskUrl + '>click here.</a>');
    
            // Send the email you have created. 
        
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
            tsk.Call_Report_Sent__c = true;
            tsk.Call_Report_Sent_Date__c = taskCallReportDataTime;
            tsk.Call_Report_Cc_Addresses__c = ccContacts;
            tsk.Call_Report_To_Addresses__c = toContacts;
            // Save the Task
            try {
                update tsk;
            } catch(DMLException e) {
                tsk.addError(e.getMessage());
                return null;
            }
            
        }
        
        PageReference returnPage = new PageReference(ApexPages.currentPage().getParameters().get('retURL'));                                                      
        return returnPage;
    }
    
    public PageReference cancel() {
        PageReference returnPage = new PageReference(ApexPages.currentPage().getParameters().get('retURL'));
        return returnPage;
    }
}