/*
*  ClassName    : SL_EmploymentHistoryHandler
*  JIRATicket   : GA_24
*  CreatedOn    : 05/05/2015
*  ModifiedBy   : Sanath Kumar
*  Description  : Handler for trigger on ts2__Employment_History__c
*/
public class SL_EmploymentHistoryHandler 
{
    /* start - constructor */ 
    public SL_EmploymentHistoryHandler()
    {
        //Do Nothing
    }
    /* end - constructor */
    
    /*
        * MethodName : onAfterInsert
        * Param      : list<ts2__Employment_History__c>(Trigger.new) 
        * Description: Triggers on after insert of ts2__Employment_History__c record respective Contact records
    */
    
    public void onAfterInsert(list<ts2__Employment_History__c> lstEmploymentHistory)
    {
        updateContactOldEmployment(lstEmploymentHistory);
    }
    
    /*
        * MethodName : onAfterUpdate
        * Param      : list<ts2__Employment_History__c>(Trigger.new) 
        * Description: Triggers on after update of ts2__Employment_History__c record respective Contact records
    */
    
    public void onAfterUpdate(list<ts2__Employment_History__c> lstEmploymentHistory)
    {
        updateContactOldEmployment(lstEmploymentHistory);
    }
    
    /*
        * MethodName : onAfterDelete
        * Param      : list<ts2__Employment_History__c>(Trigger.old) 
        * Description: Triggers on after delete of ts2__Employment_History__c record respective Contact records
    */
    
    public void onAfterDelete(list<ts2__Employment_History__c> lstEmploymentHistory)
    {
        updateContactOldEmployment(lstEmploymentHistory);
    }
    
    /*
        * MethodName : updateContactOldEmployment
        * Param      : list<ts2__Employment_History__c> 
        * Description: method to update Contact records of respective ts2__Employment_History__c record.
    */
    
    private void updateContactOldEmployment(list<ts2__Employment_History__c> lstEmploymentHistory)
    {
        set<Id> setContactId = new Set<Id>();
        for(ts2__Employment_History__c objEmploymentHistory : lstEmploymentHistory)
        {
            setContactId.add(objEmploymentHistory.ts2__Contact__c);
        }
        List<Contact> lstContactToUpdate = new List<Contact>();
        for(Contact objContact : [Select Id , Previous_Employer__c , Previous_Employer_End_Date__c ,
                                              Previous_Title__c , 
                                              (Select Id,ts2__Employment_End_Date__c,
                                                     ts2__Job_Title__c,ts2__Name__c
                                                    from ts2__Employment__r where ts2__Employment_End_Date__c!=null
                                                    ORDER BY ts2__Employment_End_Date__c DESC , LastModifiedDate DESC LIMIT 1 ) 
                                from Contact where Id IN :setContactId])
        {
           if(objContact.ts2__Employment__r.size() > 0)
           {
               if(objContact.Previous_Employer__c != objContact.ts2__Employment__r[0].ts2__Name__c 
                                                    || objContact.Previous_Employer_End_Date__c != objContact.ts2__Employment__r[0].ts2__Employment_End_Date__c
                                                    || objContact.Previous_Title__c != objContact.ts2__Employment__r[0].ts2__Job_Title__c)
                     lstContactToUpdate.add(new Contact( Id=objContact.Id , Previous_Employer__c =objContact.ts2__Employment__r[0].ts2__Name__c ,
                                                          Previous_Employer_End_Date__c = objContact.ts2__Employment__r[0].ts2__Employment_End_Date__c,
                                                          Previous_Title__c = objContact.ts2__Employment__r[0].ts2__Job_Title__c));
           }
           else
           {
                    lstContactToUpdate.add(new Contact( Id=objContact.Id , Previous_Employer__c = '' ,
                                                          Previous_Employer_End_Date__c = null,
                                                          Previous_Title__c = ''));
           }
        }
        if(!lstContactToUpdate.isEmpty())
             update lstContactToUpdate;
    }
}