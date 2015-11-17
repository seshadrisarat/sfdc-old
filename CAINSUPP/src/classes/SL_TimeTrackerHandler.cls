/*
    *  ClassName    : SL_TimeTrackerHandler 
    *  JIRATicket   : CAINSUPP-13
    *  CreatedOn    : 6/11/15
    *  CreatedBy    : Sanath
    *  Description  : Handler for trigger on Time_Tracking__c for updating Employee__c field with its related Contact 
*/
public class SL_TimeTrackerHandler 
{
     /* start - constructor */ 
    public SL_TimeTrackerHandler()
    {
        
    }
    /* end - constructor */ 
    
    /*
        * MethodName : onBeforeInsert
        * Param      : List<Time_Tracking__c>(Trigger.new) 
        * Description: Triggers on before insert of Time_Tracking__c record
    */ 
    
    public void onBeforeInsert(List<Time_Tracking__c> lstTimeTracking)
    {
        updateEmployee(lstTimeTracking , null);
    }
    
    /*
        * MethodName : onBeforeInsert
        * Param      : List<Time_Tracking__c>(Trigger.new),map<Id , Time_Tracking__c>(Trigger.oldMap)
        * Description: Triggers on before update of Time_Tracking__c record
    */ 
    
    public void onBeforeUpdate(List<Time_Tracking__c> lstTimeTracking , map<Id , Time_Tracking__c> mapIdToTimetracking)
    {
        updateEmployee(lstTimeTracking , mapIdToTimetracking);
    }
    
    /*
        * MethodName : updateEmployee
        * Param      : list<Time_Tracking__c>(trigger.new) , map<Id , Time_Tracking__c>(Trigger.oldMap)  
        * Description: method for Updating Employee__c field on Time_Tracking__c
    */
    
    private void updateEmployee(List<Time_Tracking__c> lstTimeTracking , map<Id , Time_Tracking__c> mapIdToTimetracking)
    {
        set<Id> setOwnerId = new set<Id>();
        for(Time_Tracking__c objTimeTracking : lstTimeTracking)
        {
            if(mapIdToTimetracking == null || 
               objTimeTracking.OwnerId != mapIdToTimetracking.get(objTimeTracking.Id).OwnerId || 
               objTimeTracking.Employee__c != mapIdToTimetracking.get(objTimeTracking.Id).Employee__c)
               {
                   setOwnerId.add(objTimeTracking.OwnerId);
               }
        }
        if(!setOwnerId.isEmpty())
        {
            set<String> setUserEmails = new set<String>();
            map<String , Contact> mapEmailToContact = new map<String , Contact>();
            map<Id , User> mapIdToUsers = new map<Id , User>();
            for(User objUser : [Select Id,Email from User where Id IN:setOwnerId])
            {
                setUserEmails.add(objUser.Email);
                mapIdToUsers.put(objUser.Id , objUser);
            }
            for(Contact objContact : [Select Id,Email from Contact where Email IN:setUserEmails])
            {
                mapEmailToContact.put(objContact.Email , objContact); 
            }
            for(Time_Tracking__c objTrigger : lstTimeTracking)
            {
                if(mapIdToUsers.containsKey(objTrigger.OwnerId))
                {
                    String strEmail = mapIdToUsers.get(objTrigger.OwnerId).Email;
                    objTrigger.Employee__c = (mapEmailToContact.containsKey(strEmail)) ? mapEmailToContact.get(strEmail).Id : null;
                }
            }
        }
    }
}