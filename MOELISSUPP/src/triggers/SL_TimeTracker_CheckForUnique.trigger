/*
MOELIS-95 
trigger checks duplicated records of Time_Tracker__c object:
A unique compound key field (Check_for_Unique__c) consisting 
DP-TimeSheetSummaryId-DealId (Deal project) and NDP-TimeSheetSummaryId-NonDealName (Non-deal project) 
needs to be filled in the Time_Tracker__c object.
*/
trigger SL_TimeTracker_CheckForUnique on Time_Tracker__c (before insert, before update) 
{
	List<Time_Tracker__c> listNewValues = trigger.new;
    List<Time_Tracker__c> listUniqueTimeTrackers = new List<Time_Tracker__c>();
    List<Time_Tracker__c> listNotUniqueTimeTrackers = new List<Time_Tracker__c>(); 
    Set<String> listCheckForUnique = new Set<String>();
    String str_Check_for_Unique = '';
    if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate)) 
    {
        Integer uniqueCounter = 1;
        for (Time_Tracker__c item: listNewValues) 
        {   
            Datetime tmpDT = Datetime.now();
			String strDTuniqueCounter = tmpDT.format('yyyy-MM-dd-HH:mm:ss.S')+'-'+uniqueCounter;
            if(item.Non_Deal_Project__c != null && item.Non_Deal_Project__c != '')
                    str_Check_for_Unique = 'NDP-' + item.Time_Sheet_Summary__c + '-' + item.Non_Deal_Project__c.replaceAll(' ','') + '-' + strDTuniqueCounter;
            else    str_Check_for_Unique = 'DP-' + item.Time_Sheet_Summary__c + '-' + item.Deal__c;
            
            item.Check_for_Unique__c = str_Check_for_Unique;
            system.debug('======== item.Check_for_Unique__c ======== >>>> '+item.Check_for_Unique__c);
            uniqueCounter++;
            /*
            if(listCheckForUnique.contains(str_Check_for_Unique))   
            {
                //item.Check_for_Unique__c = '';
                listNotUniqueTimeTrackers.add(item);
                
                if(listUniqueTimeTrackers.size() > 0)
                {
                    for(Time_Tracker__c itemUnique: listUniqueTimeTrackers)
                    {
                        if(itemUnique.Check_for_Unique__c == item.Check_for_Unique__c && item.Hours__c != null) 
                            itemUnique.Hours__c = itemUnique.Hours__c + item.Hours__c;
                    }
                }
                
            }
            else 
            {
                //item.Check_for_Unique__c = str_Check_for_Unique;
                listUniqueTimeTrackers.add(item);
                listCheckForUnique.add(str_Check_for_Unique);
            }
            */
        }
        /*
        if (listNotUniqueTimeTrackers.size() > 0) 
        {
            //delete listNotUniqueTimeTrackers;
        }
        */
    }
}