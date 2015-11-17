/**
* Test methods are in Test_CallLog.cls
**/

/*
MOELIS-26:'Calendar Events' - Create a custom button that resides on the Calendar Event page that creates a New Call Log
It must also retain the information of the new Call Log and update the Calendar Event record from which it was created with a reference to the newly created Call Log.
In essence, The "New Call Log" button launches the Call Log Detail form to create a new call log record that is related to the activity (event). This means that a hidden activity lookup field needs to be created to create a parent-child relationship between activities and call logs. This is very similar logic that that recently created between call log and call log contacts.
08/10/2010 Additional detail:
When creating the Call Log from the Calendar Event, the function should pre-populate the "Organizer" field with the name in the "Assigned To" field on the Calendar Event.
MOELIS-33:'Calendar Events' - Create a custom button that resides on the Calendar Event page that creates a New Call Log (Additional requests)
Client has one change of course and one new requirement.
1) The linking of the Organizer on the Call Log to the Assigned To on the Calendar Event should be removed. We thought of use cases that did not fit the behavior and will just leave them to be manually populated.
2) When creating the Call Log, copy the End Date of the Event into the Date field on the Call Log. 
*/
public with sharing class Call_Log_Create 
{
	public String CurActivityId {get; set;}
	public Call_Log__c CurCallLog {get; set;}
	public Event CurEvent {get; set;}
	public String OwnerName {get; set;}
	public Call_Log_Create()
	{
		if(System.currentPageReference().getParameters().get('eid')!=null && System.currentPageReference().getParameters().get('eid')!='')
            this.CurActivityId = System.currentPageReference().getParameters().get('eid');
        CurEvent = [SELECT Id,EndDateTime,StartDateTime, WhatId,OwnerId FROM Event WHERE Id=:this.CurActivityId LIMIT 1];
     //   system.debug('CurEvent ---------------- >'+CurEvent);
        CurCallLog = new Call_Log__c();
        if(CurEvent.EndDateTime != null)CurCallLog.Date__c = CurEvent.EndDateTime.dateGMT();//Date.newInstance(CurEvent.EndDateTime.year(),CurEvent.EndDateTime.month(),CurEvent.EndDateTime.day());
		
	//	system.debug('dddd ---------------- >'+CurEvent.EndDateTime.year()+'-'+CurEvent.EndDateTime.month()+'-'+CurEvent.EndDateTime.dateGMT());
	//	system.debug('CurEvent.EndDateTime ---------------- >'+CurEvent.EndDateTime);
	//	system.debug('CurCallLog ---------------- >'+CurCallLog);	
        this.OwnerName = UserInfo.getName();
	}
  
	private Boolean saveObj()
	{
		if(CurActivityId != null && CurActivityId != '' && CurEvent != null)
		{
			insert this.CurCallLog;
			//system.debug('Organizer__c = '+this.CurCallLog.Organizer__c);
			/*
			//MOELIS-33: changing
			if(this.CurCallLog.Organizer__c != null)
			{
				Employee_Profile__c tmpEmpl = [SELECT Id,User_ID__c FROM Employee_Profile__c WHERE Id =: this.CurCallLog.Organizer__c LIMIT 1];
				system.debug('tmpEmpl -------- '+tmpEmpl);
				if(tmpEmpl!= null)
				{
					system.debug('this.CurCallLog.Id - '+ this.CurCallLog.Id);
					system.debug('tmpEmpl.User_ID__c- '+ tmpEmpl.User_ID__c);
					this.CurEvent.OwnerId = tmpEmpl.User_ID__c;
				}
			}
			*/
			this.CurEvent.WhatId = this.CurCallLog.Id;
			//system.debug(this.CurEvent);
			update this.CurEvent;
			
			return true;
		}
		return false;
	}

    public PageReference save()
    {
        this.saveObj();
        PageReference pageRef = new PageReference('/'+CurActivityId);
		pageRef.setRedirect(true);
        return pageRef;
     }
     
    public PageReference save_new()
    {
     	this.saveObj();
     	PageReference pageRef = new PageReference('/apex/Call_Log_Create?clid='+CurActivityId);
		pageRef.setRedirect(true);
        return pageRef;
    }
	
	public PageReference cancel()
    {
    	PageReference pageRef = new PageReference('/'+CurActivityId);
		pageRef.setRedirect(true);
        return pageRef;
    }
     
}