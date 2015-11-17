/**
*  ClassName      : SL_EventAutoUpdater
*  JIRATicket     : PWP-122
*  CreatedOn      : 5/AUG/2015
*  CreatededBy    : Sanath Kumar
*  Description    : Updates assoicated Event.
*/
public class SL_EventAutoUpdater 
{
    public SL_EventAutoUpdater()
    {
        //DML cannot be performed in Constructor
        //so Do Nothing
    }
    
    public PageReference saveRecord()
    {
        try{
             Id ActivityId = ApexPages.currentPage().getParameters().get('EventId');
             Event objEvent = new Event();
             set<Id> setCoverageTeamMembers = new set<Id>();
            //  PageReference redirectToDetail = new PageReference('/' + ActivityId);
            //  redirectToDetail.setRedirect(true);
             for(Event objEventDML : [select Id , Don_t_Send_Call_Report_Reminder__c, OwnerId, WhatId, Subject from Event where Id=:ActivityId])
             {
                objEvent = objEventDML;
             }
             if(objEvent.Id != null && objEvent.WhatId.getSobjectType() == Account.SobjectType)
             {
                if(!objEvent.Don_t_Send_Call_Report_Reminder__c)
                {
                    update new Event(Id=ActivityId , Don_t_Send_Call_Report_Reminder__c = true);
                    ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info, 'Call Report Reminder is canceled for Meeting: '+objEvent.Subject));
                    return null;
                }
                else
                {
                    ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info, 'Call Report Reminder already turned off'));
                    return null;
                }
             }
             else
             {
                 ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Warning, 'Invalid Event'));
                 return null;
             }
        }catch(Exception e){
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Error, e.getMessage()));
            return null;
        }
    }
}