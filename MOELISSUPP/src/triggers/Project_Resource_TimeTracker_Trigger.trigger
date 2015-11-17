/*
For each 'Active' Deal Team Members:
Trigger generates list of TimeTracker records (where TimeSheetSummary Stage  is 'New') for employee of each current Deal Team Member where 
- Deal Name NOT 'Non-Deal Project'
- Deal Stage NOT ('Closed - Completed' , 'Closed - Dead', 'Closed - Lost' )
- Deal Status 'Active' or 'Hold'

For each 'Inactive' Deal Team Members or Deal Team Members which were deleted:
- for all TimeTracker records (where TimeSheetSummary Stage  is 'New') the DealTeamMember_Inactive_Date__c sets 'today date'
*/
//trigger Project_Resource_TimeTracker_Trigger on Project_Resource__c (before insert, before update)
trigger Project_Resource_TimeTracker_Trigger on Project_Resource__c (after insert, after update, after delete) 
{
    Map<ID,List<ID>> Map_EmplID_ListDEALId = new Map<ID,List<ID>>();
    Map<ID,List<ID>> Map_EmplID_ListDEALId_toDEL = new Map<ID,List<ID>>();

    
    if (trigger.isDelete) 
    { 
        for(integer i=0; i<trigger.old.size(); i++)
        {
            Project_Resource__c pr_old = trigger.old[i];
            if (Map_EmplID_ListDEALId_toDEL.containsKey(pr_old.Banker__c))  
                Map_EmplID_ListDEALId_toDEL.get(pr_old.Banker__c).add(pr_old.Project__c);
            else 
            {
                if(pr_old.Banker__c != null)
                {
                    List<ID> tmp1 = new List<ID>();
                    tmp1.add(pr_old.Project__c);
                    Map_EmplID_ListDEALId_toDEL.put(pr_old.Banker__c,tmp1);
                }
            }
        }
    }
    
    
    List<Project_Resource__c> ListUpdate_Project_Resource = new List<Project_Resource__c>();
    if (trigger.isInsert || trigger.isUpdate) 
    { 
        List<Id> listDeals = new List<Id>();
        for(integer i=0; i<trigger.new.size(); i++)
        {
            listDeals.add(trigger.new[i].Project__c);
        }
        Map<ID,Ibanking_Project__c> mapDeals = new Map<ID,Ibanking_Project__c>([
                                                    select ID,Name,Stage__c,Status__c 
                                                    from Ibanking_Project__c 
                                                    where ID in :listDeals]);
       
       //system.debug('_------------------> mapDeals'+ mapDeals);
        for(integer i=0; i<trigger.new.size(); i++)
        {
            Project_Resource__c pr = trigger.new[i];
            if (pr.Status__c == 'Active' && mapDeals != null && mapDeals.get(pr.Project__c) != null &&
                mapDeals.get(pr.Project__c).Name != 'Non-Deal Project' &&
                 /* old logic
                mapDeals.get(pr.Project__c).Stage__c != 'Closed - Completed' &&
                mapDeals.get(pr.Project__c).Stage__c != 'Closed - Dead' &&
                mapDeals.get(pr.Project__c).Stage__c != 'Closed - Lost' &&
                */
                (mapDeals.get(pr.Project__c).Status__c == 'Active' || mapDeals.get(pr.Project__c).Status__c == 'Hold')
                )
            {
                if (Map_EmplID_ListDEALId != null && Map_EmplID_ListDEALId.containsKey(pr.Banker__c))   Map_EmplID_ListDEALId.get(pr.Banker__c).add(pr.Project__c);
                else 
                {
                    
                    List<ID> tmp = new List<ID>();
                    tmp.add(pr.Project__c);
                    Map_EmplID_ListDEALId.put(pr.Banker__c,tmp);
                }
            }
            
            if(trigger.isUpdate && (pr.Status__c == 'Inactive' || trigger.old[i].Banker__c != pr.Banker__c))
            {
                if (Map_EmplID_ListDEALId_toDEL.containsKey(trigger.old[i].Banker__c))  Map_EmplID_ListDEALId_toDEL.get(trigger.old[i].Banker__c).add(pr.Project__c);
                else 
                {
                    if(trigger.old[i].Banker__c != null)
                    {
                        List<ID> tmp1 = new List<ID>();
                        tmp1.add(pr.Project__c);
                        Map_EmplID_ListDEALId_toDEL.put(trigger.old[i].Banker__c,tmp1);
                    }
                }
            }
            
        }
    }
    
    System.debug('===========Map_EmplID_ListDEALId_toDEL================'+Map_EmplID_ListDEALId_toDEL);
    List<String> List_EmplID_ListDEALId_toDEL_Srt = new List<String>();
    for (Id EmplID : Map_EmplID_ListDEALId_toDEL.keySet()) 
    {
        List<Id> tmp_list = Map_EmplID_ListDEALId_toDEL.get(EmplID);
        if (tmp_list != null && tmp_list.size()>0)
        {
            for (Id DealId : tmp_list) 
            {
                //TT_toDEl_Deal_IDs.add(DealId);
                List_EmplID_ListDEALId_toDEL_Srt.add((EmplID+'').substring(0,15)+'_'+(DealId+'').substring(0,15));
            }
        }
    }
    
    system.debug('==================List_EmplID_ListDEALId_toDEL_Srt====================='+List_EmplID_ListDEALId_toDEL_Srt);
    
    if(List_EmplID_ListDEALId_toDEL_Srt.size() > 0)
    {
        /*
        List<Time_Tracker__c> TT_toDEl = [  SELECT Id
                                            FROM Time_Tracker__c 
                                            WHERE EmplID_DealID__c IN : List_EmplID_ListDEALId_toDEL_Srt 
                                            //AND Time_Sheet_Summary__r.Stage__c = 'New'
                                            ];
                                            
                                            
                                            
        system.debug('TT_toDEl----------------------'+TT_toDEl);
        if(TT_toDEl.size() > 0) delete TT_toDEl;
        */
        
        List<Time_Tracker__c> TT_toDEl = new List<Time_Tracker__c>();
        for (Time_Tracker__c TT_tmp : [SELECT Id, DealTeamMember_Inactive_Date__c,Deal__c
                                       FROM Time_Tracker__c 
                                       WHERE EmplID_DealID__c IN : List_EmplID_ListDEALId_toDEL_Srt 
                                       AND Time_Sheet_Summary__r.Stage__c =: 'New'
                                       LIMIT 50000     ])
        {
            TT_tmp.DealTeamMember_Inactive_Date__c = Date.today();
            TT_toDEl.add(TT_tmp);
        }
        system.debug('TT_toDEl----------------------'+TT_toDEl);
        system.debug('==========TT_toDElInside==============='+TT_toDEl);
        if(TT_toDEl.size() > 0) 
            update TT_toDEl;
        
    }
    
    
    system.debug('Map_EmplID_ListDEALId'+Map_EmplID_ListDEALId);
    Set<Id> Map_EmplID_ListDEALId_Keys = Map_EmplID_ListDEALId.keySet();
    Map<String,Time_Tracker__c> TT_to_insert = new Map<String,Time_Tracker__c>();
    if(Map_EmplID_ListDEALId_Keys.size() > 0)
    {
        List<TimeSheet_Summary__c> tmp_tss = [SELECT Id,    Employee__c,    Week_Start_Date__c
                                    FROM TimeSheet_Summary__c 
                                    WHERE Employee__c IN : Map_EmplID_ListDEALId_Keys 
                                        AND Stage__c =: 'New'
                                    LIMIT 50000];
        System.debug('===========Map_EmplID_ListDEALId_Keys=============='+Map_EmplID_ListDEALId_Keys);
        for (TimeSheet_Summary__c tss : tmp_tss)
        {
            List<Id> tmp_ListDEALId = new List<Id>();
            if(tss.Employee__c!=null)
                tmp_ListDEALId = Map_EmplID_ListDEALId.get(tss.Employee__c);
            if (tmp_ListDEALId != null && tmp_ListDEALId.size()>0)
            {
                for (Id dealID : tmp_ListDEALId) 
                {
                    String TSSid_DEALid = tss.Id+'_'+dealID;
                    //if (!TT_to_insert.containsKey(TSSid_DEALid) && !TT_toDEl_Deal_IDs.contains(dealID))
                    if (!TT_to_insert.containsKey(TSSid_DEALid))
                    {
                        Time_Tracker__c tt = new Time_Tracker__c();
                                    tt.Week_Start_Date__c = tss.Week_Start_Date__c;
                                    tt.Employee__c = tss.Employee__c;
                                    tt.Time_Sheet_Summary__c = tss.Id;
                                    tt.Deal__c = dealID;
                        TT_to_insert.put(TSSid_DEALid,tt);
                    }
                }
            }
        }
        System.debug('==============TT_to_insert============='+TT_to_insert);
        if(TT_to_insert.values().size() > 0)    
        {
            system.debug('TT_to_insert.values()------------------->'+TT_to_insert.values());
            insert TT_to_insert.values();
        }                                       
    }
}