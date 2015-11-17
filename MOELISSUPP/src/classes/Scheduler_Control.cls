public with sharing class Scheduler_Control {
    
    public Scheduler_Control() {
        isTest = false;
    }
    
    public Boolean isTest{get;set;}
    
    private String infoMsg_p = null;
    public String infoMsg {
        get {
            if (infoMsg_p == null) {
                infoMsg_p = '';
            }
            return infoMsg_p;
        }
        set {
            infoMsg_p = value;
        }
    }
    
    private String errMsg_p = null;
    public String errMsg {
        get {
            if (errMsg_p == null) {
                errMsg_p = '';
            }
            return errMsg_p;
        }
        set {
            errMsg_p = value;
        }
    }
    
    private Integer minutes_p = null; // Number of minutes to next actuation
    public Integer minutes {
        get {
            if (minutes_p == null) {
                minutes_p = 1;
            }
            return minutes_p;
        }
        set {
            minutes_p = value;
        }
    }
    
    public void createScheduler() { // Remove all Schedule jobs and create a new job
        
        DateTime nowTime = datetime.now();
        Integer minuteOfHours = 0;
        Integer nowMinute = nowTime.minute();
        
        if (minutes < 1 || minutes > 59) {
            errMsg = 'Enter a valid number of minutes.';
            infoMsg = '';
            minutes = 1;
        } else {
            Scheduled_Job__c toInsert = new Scheduled_Job__c();
            List<Scheduled_Job__c> toDelete = [SELECT Name,Cron_Id__c FROM Scheduled_Job__c WHERE Name = 'Sharing Schedule'];
            if (toDelete.size() > 0) 
            {
                List<Id> toDeleteId = new List<Id>();
                for (Scheduled_Job__c item:toDelete) 
                {
                    toDeleteId.add(item.Cron_Id__c);
                }
                List<CronTrigger> listCronTrigger = [select Id from CronTrigger Where Id IN :toDeleteId];
                for (CronTrigger item:listCronTrigger) 
                {
                    System.abortJob(item.Id);
                }
                try {
                	delete toDelete;
                } catch (Exception e) {
                	
                }
            }
            
            minuteOfHours = nowMinute + minutes;
            if (minuteOfHours >= 60) {
                minuteOfHours -= 60;
            }
            system.debug('======== minuteOfHours ========= >>>> '+minuteOfHours);
            infoMsg = 'Job is scheduled after '+minutes+' min. This is '+minuteOfHours+' minute in hours.';
            errMsg = '';
            
            String cronId;
            if (isTest) {
                try {
	            	cronId = System.schedule('Sharing Schedule Test', '0 '+minuteOfHours+' * * * ?', new SharingScheduler());
	            } catch (Exception e) {
	            	
	            }
            } else {
                cronId = System.schedule('Sharing Schedule', '0 '+minuteOfHours+' * * * ?', new SharingScheduler());
            }
            toInsert.Cron_Id__c = cronId;
            toInsert.Name = 'Sharing Schedule';
            try {
            	insert toInsert;
            } catch (Exception e) {
            	
            }
        }
    }
    
}