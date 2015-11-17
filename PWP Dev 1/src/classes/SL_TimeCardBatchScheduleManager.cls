/**
    * \arg ClassName      : SL_TimeCardBatchScheduleManager
    * \arg JIRATicket     : PWP-215
    * \arg CreatedOn      : 09/Sep/2015
    * \arg LastModifiedOn : 13/Sep/2015
    * \arg CreatededBy    : Lodhi
    * \arg ModifiedBy     : Lodhi
    * \arg Description    : This class for the SL_TimeCardBatchScheduleManager page.
*/
public without sharing class SL_TimeCardBatchScheduleManager 
{
    public Time_Card_Batch_Scheduler__c objTCBS             {get;set;}
    public String strBatchOption                            {get;set;}
    public Boolean isScheduled                              {get;set;}
    public Boolean isFilling                                {get;set;}
    public List<SelectOption> lstBatchOptions               {get;set;}
    private Set<String> setCronTriggerId;
    private String strRecordId;
    private Map<String, String> mapTimeStringToValue;
    
    /* Start - Constructor */
    public SL_TimeCardBatchScheduleManager(Apexpages.StandardController stdController)
    {
        objTCBS = new Time_Card_Batch_Scheduler__c();
        strBatchOption = 'availability'; 
        isFilling = false;
        isScheduled = false;
        lstBatchOptions = new List<SelectOption>{
            new SelectOption('availability','Time Card Availability'), 
            new SelectOption('filling','Time Card Filling')
        };
        mapTimeStringToValue = new Map<String, String>{
            '12:00am'=>'0', '12:30am'=>'0.5', '1:00am'=>'1', '1:30am'=>'1.5', '2:00am'=>'2', '2:30am'=>'2.5', '3:00am'=>'3', '3:30am'=>'3.5', 
            '4:00am'=>'4', '4:30am'=>'4.5', '5:00am'=>'5', '5:30am'=>'5.5', '6:00am'=>'6', '6:30am'=>'6.5', '7:00am'=>'7', '7:30am'=>'7.5',
            '8:00am'=>'8', '8:30am'=>'8.5', '9:00am'=>'9', '9:30am'=>'9.5', '10:00am'=>'10', '10:30am'=>'10.5', '11:00am'=>'11', '11:30am'=>'11.5',
            '12:00pm'=>'12', '12:30pm'=>'12.5', '1:00pm'=>'13', '1:30pm'=>'13.5', '2:00pm'=>'14', '2:30pm'=>'14.5', '3:00pm'=>'15', '3:30pm'=>'15.5',
            '4:00pm'=>'16', '4:30pm'=>'16.5', '5:00pm'=>'17', '5:30pm'=>'17.5', '6:00pm'=>'18', '6:30pm'=>'18.5', '7:00pm'=>'19', '7:30pm'=>'19.5',
            '8:00pm'=>'20', '8:30pm'=>'20.5', '9:00pm'=>'21', '9:30pm'=>'21.5', '10:00pm'=>'22', '10:30pm'=>'22.5', '11:00pm'=>'23','11:30pm'=>'23.5'
        };
        if(stdController.getId() != null)
            strRecordId = stdController.getId();
    }
    /* End - Constructor */
    
    /**
        @MethodName : scheduleJOB
        @Param      : NA
        @Description: This method used to update the records.
    **/
    public void updateRecord()
    {
        if(!String.isEmpty(strRecordId))
        {
            objTCBS = fetchUpdateRecord(strRecordId);
            strBatchOption = (objTCBS.Is_Availability_Reminder__c == true) ? 'availability' : 'filling';    
            isFilling = (strBatchOption == 'availability') ? false : true;
            if(objTCBS.Cron_Trigger_Ids__c != null)
            {
                setCronTriggerId = new Set<String>();
                setCronTriggerId.addAll(objTCBS.Cron_Trigger_Ids__c.split(','));
                List<CronTrigger> lstCroneTrigger = [SELECT Id FROM CronTrigger WHERE Id IN : setCronTriggerId];
                if(!lstCroneTrigger.isEmpty())
                    isScheduled = true; 
                else
                    update new Time_Card_Batch_Scheduler__c(Id = strRecordId, Status__c = 'ABORTED', Cron_Trigger_Ids__c = null);
            }  
            objTCBS = fetchUpdateRecord(strRecordId);
        }
    }
    
    /**
        @MethodName : scheduleJOB
        @Param      : NA
        @Description: This method will be used to shcedule the JOB.
    **/
    public void scheduleJOB()
    {
        upsert objTCBS;
        objTCBS = fetchUpdateRecord(objTCBS.Id);
                     
        String strCronTriggerId = '';
        String strCronName = '';
        Boolean isAvailability = (strBatchOption == 'availability') ? true : false;
        String strPreferredTime = mapTimeStringToValue.get(objTCBS.Time__c);
        
        if(isAvailability)
        {
            strCronName = 'Time Card Availability - '+objTCBS.Name;
            strCronTriggerId = system.schedule(strCronName+ ' - 1', '0 30 * * * ?', new SL_Schedule_TimeCardAvailability(objTCBS.Day__c, strPreferredTime, objTCBS.Additional_Recipients__c));
            strCronTriggerId += ','+system.schedule(strCronName+ ' - 2', '0 0 * * * ?', new SL_Schedule_TimeCardAvailability(objTCBS.Day__c, strPreferredTime, objTCBS.Additional_Recipients__c));
        }    
        else
        {
            strCronName = 'Time Card Filling - '+objTCBS.Name;
            
            if(objTCBS.Frequency__c == null || objTCBS.Frequency__c == 'Every 1 hour')  
                strCronTriggerId = system.schedule(strCronName, '0 1 * * * ?', new SL_Schedule_TimeCardFilling(objTCBS.Day__c, strPreferredTime, objTCBS.Additional_Recipients__c));
            
            if(objTCBS.Frequency__c == 'Every 30 minutes')
            {
                strCronTriggerId = system.schedule(strCronName+' - 1', '0 30 * * * ?', new SL_Schedule_TimeCardFilling(objTCBS.Day__c, strPreferredTime, objTCBS.Additional_Recipients__c));
                strCronTriggerId += ','+system.schedule(strCronName+' - 2', '0 0 * * * ?', new SL_Schedule_TimeCardFilling(objTCBS.Day__c, strPreferredTime, objTCBS.Additional_Recipients__c));
            } 
        }
        setCronTriggerId = new Set<String>();
        setCronTriggerId.addAll(strCronTriggerId.split(','));
        List<CronTrigger> lstCronTrigger = [SELECT Id, State FROM CronTrigger WHERE Id IN : setCronTriggerId];
        update new Time_Card_Batch_Scheduler__c(Id = objTCBS.Id, Cron_Trigger_Ids__c = strCronTriggerId, Status__c = lstCronTrigger[0].State,
                                                Is_Availability_Reminder__c = isAvailability);
        objTCBS = fetchUpdateRecord(objTCBS.Id);
        isScheduled = true;    
        Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.info, 'Job sucessfully scheduled'));
    }
    /* End */
    
    /**
        @MethodName : abortJOB
        @Param      : NA
        @Description: This method will abort the shceduled JOB
    **/
    public void abortJOB()
    {
        objTCBS = [SELECT Id, Name, Additional_Recipients__c, Is_Availability_Reminder__c, 
                          Day__c, Status__c, Time__c, Cron_Trigger_Ids__c, Frequency__c
                     FROM Time_Card_Batch_Scheduler__c WHERE Id =: objTCBS.Id];
                     
        if(objTCBS.Cron_Trigger_Ids__c != null)
        {
            setCronTriggerId = new Set<String>();
            setCronTriggerId.addAll(objTCBS.Cron_Trigger_Ids__c.split(','));
            for(CronTrigger objCron : [SELECT ID, State FROM CronTrigger WHERE Id=: setCronTriggerId])
            {
                System.abortJob(objCron.Id);
            }
            
            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.info, 'Job sucessfully aborted'));
            update new Time_Card_Batch_Scheduler__c(Id = objTCBS.Id, Cron_Trigger_Ids__c = null, Status__c = 'ABORTED');
            isScheduled = false; 
        }
        objTCBS = fetchUpdateRecord(objTCBS.Id); 
    }
    /* End */
    
        /**
        @MethodName : fetchUpdateRecord
        @Param      : recordId
        @Description: This method used to fetch updated record.
    **/
    private Time_Card_Batch_Scheduler__c fetchUpdateRecord(Id recordId)
    {
        return [SELECT Id, Name, Additional_Recipients__c, Is_Availability_Reminder__c, 
                       Day__c, Status__c, Time__c, Cron_Trigger_Ids__c, Frequency__c
                  FROM Time_Card_Batch_Scheduler__c WHERE Id =: recordId];
    }
    
    /**
        @MethodName : changeBatchType
        @Param      : NA
        @Description: This method will show and hide the frequency column on page based on the batch type.
    **/
    public void changeBatchType()
    {
        isFilling = (strBatchOption == 'availability') ? false : true;
        objTCBS.Frequency__c = (isFilling == false) ? null : objTCBS.Frequency__c; 
    }
    /* End */
}