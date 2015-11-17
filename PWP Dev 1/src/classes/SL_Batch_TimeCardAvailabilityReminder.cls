/**
* \arg ClassName      : SL_Batch_TimeCardAvailabilityReminder
* \arg JIRATicket     : PWP-215
* \arg CreatedOn      : 08/SEP/2015
* \arg LastModifiedOn : 11/SEP/2015
* \arg CreatededBy    : Lodhi
* \arg ModifiedBy     : Lodhi
* \arg Description    : This class serves the purpose for sending emails to the time card users for their availability.
*/
global class SL_Batch_TimeCardAvailabilityReminder implements Database.Batchable<Sobject>
{ 
    private static String strQuery;//variable to hold the dynamic soql framed by email template
    private static final String strHTMLBody;//variable to hold html body of email template
    private static final String strSubject;//variable to hold subject line of email template
    private Date dtWeekStart = Date.today().toStartofWeek();
    private Date dtWeekEnd = dtWeekStart.addDays(6);
    private String strPreferredDay;
    private String strPreferredTime;
    private String strOtherEmails;
    
    static
    {
        SL_Batch_TimeCardReminderUtility objUtility = new SL_Batch_TimeCardReminderUtility();
        strQuery = 'SELECT Id, Name, Project__r.Name, Resource__r.Name, Owner.Name';
        List<EmailTemplate> lstEmailTemplate = [SELECT HtmlValue, Subject 
                                                  FROM EmailTemplate 
                                                 WHERE DeveloperName = 'Time_Card_Availability_Reminder'];
        if(!lstEmailTemplate.isEmpty())
        {
            EmailTemplate objEmailTemplate = lstEmailTemplate[0];
            strHTMLBody = objEmailTemplate.HtmlValue;
            strSubject = objEmailTemplate.Subject;
            
            if(objEmailTemplate.HtmlValue.contains('{!Time_Card__c.'))
                strQuery = SL_Batch_TimeCardReminderUtility.replaceMergeFields(objEmailTemplate.HtmlValue, strQuery);
            
            if(objEmailTemplate.Subject.contains('{!Time_Card__c.'))
                strQuery = SL_Batch_TimeCardReminderUtility.replaceMergeFields(objEmailTemplate.Subject, strQuery);
        }
        strQuery += ' FROM Time_Card__c WHERE Project__c != null AND Resource__c != null AND Start_Date__c >=: dtWeekStart AND End_Date__c <=: dtWeekEnd';
    }
    
    /* Start - Constructor */
    global SL_Batch_TimeCardAvailabilityReminder(String strPreferredDay, String strPreferredTime, String strOtherEmails)
    {
        this.strPreferredDay = strPreferredDay;
        this.strPreferredTime = strPreferredTime;
        this.strOtherEmails = strOtherEmails;
    }
    /* End - Constructor */
    
    /**
        @MethodName : start
        @Param      : reference of Database.BatchableContext to track the progress of batch job.
        @Description: This method is used to pass the list of Event records to the execute method of interface.
    **/
    global Database.Querylocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(strQuery);
    }	
    /* End */
    
    /**
        @MethodName : execute
        @Param      : reference of Database.BatchableContext to track the progress of batch job and 
                      list of Time_Card__c records received from start method
        @Description: This method is used to send an email alert to the time card user to fill thier hours or percentage
    **/
    global void execute(Database.BatchableContext BC, List<Time_Card__c> lstTimeCards)
    {
        SL_Batch_TimeCardReminderUtility.sendTimeCardEmailReminder(lstTimeCards, strHTMLBody, strSubject, 'Availability', 
                                                                   strPreferredDay, strPreferredTime, strOtherEmails);
    }
    /* End */
    
    /**
        @MethodName : finish
        @Param      : reference of Database.BatchableContext to track the progress of batch job
        @Description: finish method of the interface
    **/
    global void finish(Database.BatchableContext BC)
    {
        //Do nothing
    }
    /* End */
}