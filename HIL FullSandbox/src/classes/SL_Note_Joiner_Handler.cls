public class SL_Note_Joiner_Handler
{
     /* start - global variables*/
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    public Set<Note_Joiner__c> setNJ;
    public map<Id,Set<Id>> noteRCMap;
    /* end - global variables*/

    //Constructor of a Handler Class
    public SL_Note_Joiner_Handler(boolean isExecuting, integer size)
    {
        m_isExecuting = isExecuting;
        BatchSize = size;

        setNJ = new Set<Note_Joiner__c>();
        noteRCMap = new map<Id,Set<Id>>();
    }

    // This function will be called on OnAfterInsert of Task record.
    public void onAfterInsert(Map<Id, Note_Joiner__c> newMap)
    {
        //Updating Activities
        //updateTasks(mapNewTask, null);
        //updateSLA(null,newMap);
        Set<Id> nIds = new Set<Id>();


        for(Note_Joiner__c nj : newMap.values())
        {
            nIds.add(nj.Note__c);
        }

        SL_NoteHandler.myUpdateSLA(nIds,false);
    }
    
    // This function will be called on onAfterUpdate of Task record.
    public void onAfterUpdate(Map<Id, Note_Joiner__c> oldMap, Map<Id, Note_Joiner__c> newMap)
    {
        //Updating Activities
        //updateTasks(mapNewTask, mapOldTask);
        //updateSLA(oldMap,newMap);
    }
    
    // This function will be called on onAfterUndelete of Task record.
    public void onAfterUndelete(Map<Id, Note_Joiner__c> newMap)
    {
        //Updating Activities
        //updateTasks(mapNewTask, null);
    }

    public void createJoinerRecs(map<Id,Note__c> newMap)
    {
        Set<Id> nIds = new Set<Id>();
        Set<Id> ownerIds = new Set<Id>();
        Note__c[] nList = new Note__c[]{};
        Note_Joiner__c[] njList = new Note_Joiner__c[]{};
        Set<Id> myRcIds = new Set<Id>();

        map<Id,Set<Id>> noteRelGrpMap = new map<Id,Set<Id>>();
        map<Id,Set<Id>> noteAcctMap = new map<Id,Set<Id>>();

        /*for(Note__c n : newMap.values())
        {
            if(n.Create_Joiner_Records__c)
            {
                nIds.add(n.Id);
            }
        }*/

        /*if(nIds != null && !nIds.isEmpty())
        {
            nList = [Select Id,OwnerId,
                            Account_del__c,
                            Relationship_Group__c,
                            Rep_Code__c
                     From Note__c
                     WHERE Id IN: nIds];

            System.debug(nList);*/

            for(Note__c n : newMap.values())
            {
                if(n.Create_Joiner_Records__c && n.Count_Joiners__c == 0)
                {
                    if(n.Relationship_Group__c != null)
                    {
                        if(noteRelGrpMap.containsKey(n.Relationship_Group__c))
                        {
                            noteRelGrpMap.get(n.Relationship_Group__c).add(n.Id);
                        }else
                        {
                            noteRelGrpMap.put(n.Relationship_Group__c,new Set<Id>{n.Id});
                        }
                    }
                    
                    if(n.Account_del__c != null)
                    {
                        if(noteAcctMap.containsKey(n.Account_del__c))
                        {
                            noteAcctMap.get(n.Account_del__c).add(n.Id);
                        }else
                        {
                            noteAcctMap.put(n.Account_del__c,new Set<Id>{n.Id});
                        }

                        ownerIds.add(n.OwnerId);
                    }
                    
                    if(n.Rep_Code__c != null)
                    {
                        myRcIds.add(n.Rep_Code__c);
                    }
                }
            }

            if(noteRelGrpMap != null && !noteRelGrpMap.isEmpty())
            {
                populateGroupMembers(noteRelGrpMap);
            }

            if(noteAcctMap != null && !noteAcctMap.isEmpty())
            {
                populateRelatedGroups(noteAcctMap,ownerIds,myRcIds);
            }

            njList.addAll(setNJ);

            insert njList;
            
            SL_Util_SharingController.RepCodeType[] shareList = new SL_Util_SharingController.RepCodeType[] {};

            if(noteRCMap != null && !noteRCMap.isEmpty())
            {
                for(Id i : noteRCMap.keySet())
                {
                    for(Id j : noteRCMap.get(i))
                    {
                        shareList.add(new SL_Util_SharingController.RepCodeType(i, j));
                    }
                }
            }                
            Database.insert(SL_Util_SharingController.createSharingRecords(shareList, 'Edit'),false);
        //}
    }

    public void populateGroupMembers(map<Id,Set<Id>> noteRelGrpMap)
    {
        Set<Note_Joiner__c> njSet = new Set<Note_Joiner__c>();
    
        List<Group_Member__c> groupMembers = [Select Client_Prospect__c,
                                                     Relationship_Group__c,
                                                     Relationship_Group__r.Rep_Code__c
                                              From Group_Member__c
                                              Where Relationship_Group__c IN: noteRelGrpMap.keyset()];
        
        for(Id i : noteRelGrpMap.keyset())
        {
            for(Id j : noteRelGrpMap.get(i))
            {
                Note_Joiner__c nj = new Note_Joiner__c();

                nj.Relationship_Group__c = i;
                nj.Note__c = j;

                njSet.add(nj);
            }
        }
        
        for(Group_Member__c gm : groupMembers)
        {
            Set<Id> iTemp = noteRelGrpMap.get(gm.Relationship_Group__c);
            
            for(Id i : iTemp)
            {
                Note_Joiner__c nj2 = new Note_Joiner__c();

                nj2.Client_Prospect__c = gm.Client_Prospect__c;
                nj2.Note__c = i;

                njSet.add(nj2);

                if(noteRCMap.containsKey(i))
                {
                    noteRCMap.get(i).add(gm.Relationship_Group__r.Rep_Code__c);
                }else
                {
                    noteRCMap.put(i, new Set<Id>{gm.Relationship_Group__r.Rep_Code__c});
                }
            }
        }

        setNJ.addAll(njSet);
    }

    public void populateRelatedGroups(map<Id,Set<Id>> noteAcctMap, Set<Id> ownerIds, Set<Id> myRcIds)
    {
        Set<Note_Joiner__c> njSet = new Set<Note_Joiner__c>();

        List<Rep_Code_User__c> rcuList = [select Rep_Code__c from Rep_Code_User__c where User__c IN: ownerIds];
        Set<Id> rcIds = new Set<Id>();
        
        for(Rep_Code_User__c r : rcuList)
        {
            rcIds.add(r.Rep_Code__c);
        }
        
        if(myRcIds != null && !myRcIds.isEmpty())
        {
            rcIds.clear();
            rcIds.addAll(myRcIds);
        }
              
        List<Group_Member__c> groupMembers = [select Client_Prospect__c,
                                                     Relationship_Group__c,
                                                     Relationship_Group__r.Rep_Code__c
                                              From Group_Member__c
                                              where Client_Prospect__c IN: noteAcctMap.keyset() AND Relationship_Group__r.Rep_Code__c IN: rcIds];

        for(Id i : noteAcctMap.keyset())
        {
            for(Id j : noteAcctMap.get(i))
            {
                Note_Joiner__c nj = new Note_Joiner__c();

                nj.Client_Prospect__c = i;
                nj.Note__c = j;

                njSet.add(nj);
            }
        }
        
        for(Group_Member__c gm : groupMembers)
        {

            Set<Id> iTemp = noteAcctMap.get(gm.Client_Prospect__c);
            
            for(Id i : iTemp)
            {        
                Note_Joiner__c nj2 = new Note_Joiner__c();

                nj2.Relationship_Group__c = gm.Relationship_Group__c;
                nj2.Note__c = i;
        
                njSet.add(nj2);

                if(noteRCMap.containsKey(i))
                {
                    noteRCMap.get(i).add(gm.Relationship_Group__r.Rep_Code__c);
                }else
                {
                    noteRCMap.put(i, new Set<Id>{gm.Relationship_Group__r.Rep_Code__c});
                }
            }
        }

        setNJ.addAll(njSet);
    }
    
    public void updateSLA(Map<Id, Note_Joiner__c> oldMap, Map<Id, Note_Joiner__c> newMap)
    {
        Set<Id> noteIds = new Set<Id>();
        Set<Id> acctIds = new Set<Id>();
        Set<Id> relGrpIds = new Set<Id>();

        map<Id,Group_Member__c> mapGMs = new map<Id,Group_Member__c>();

        map<Id,Account> mapAccts = new map<Id,Account>();
        map<Id,Group_Member__c[]> acctGmMap = new map<Id,Group_Member__c[]>();
        
        for(Note_Joiner__c n : newMap.values())
        {
            if(n.Note__c != null)
            {
                noteIds.add(n.Note__c);
            }
            
            if(n.Client_Prospect__c != null)
            {
                acctIds.add(n.Client_Prospect__c);
            }
            
            if(n.Relationship_Group__c != null)
            {
                relGrpIds.add(n.Relationship_Group__c);
            }
        }
        
        map<Id,Account> acctMap = new map<Id,Account>([Select Id,Last_Contact_Date__c,Last_Meeting_Date__c From Account WHERE Id IN: acctIds]);
        
        map<Id,Note__c> nMap = new map<Id,Note__c>([Select Id,ActivityDate__c,Type__c,Status__c,Count_Towards_SLA__c From Note__c WHERE Id IN: noteIds AND Count_Towards_SLA__c = true]);
        
        Group_Member__c[] gmList = [Select Id,Relationship_Group__c, Client_Prospect__c,Last_Contact_Date__c,Last_Meeting_Date__c From Group_Member__c WHERE Client_Prospect__c IN: acctIds OR Relationship_Group__c IN : relGrpIds];
        
        for(Group_Member__c gm : gmList)
        {
            if(acctGmMap.containsKey(gm.Client_Prospect__c))
            {
                acctGmMap.get(gm.Client_Prospect__c).add(gm);
            }else
            {
                acctGmMap.put(gm.Client_Prospect__c,new Group_Member__c[]{gm});
            }
        }
        
        for(Note_Joiner__c n : newMap.values())
        {
            Note__c nTemp = nMap.get(n.Note__c);
            
            Group_Member__c[] gmTempSet = acctGmMap.get(n.Client_Prospect__c);
            Account aTemp = acctMap.get(n.Client_Prospect__c);
            
            if(aTemp != null && nTemp != null)
            {
                System.debug(aTemp);
                System.debug(nTemp);

                if(((aTemp.Last_Contact_Date__c < nTemp.ActivityDate__c) || aTemp.Last_Contact_Date__c == null)  && nTemp.Type__c != 'Meeting' && nTemp.Type__c != 'Note')
                {
                    aTemp.Last_Contact_Date__c = nTemp.ActivityDate__c;                        
                }
                
                // if(nTemp.Type__c == 'Meeting' && (((aTemp.Last_Meeting_Date__c < nTemp.ActivityDate__c) || aTemp.Last_Meeting_Date__c == null)))
                // if(nTemp.Type__c == 'Meeting' && mapAccountIdToMaxDate.containsKey(n.Client_Prospect__c))
                // {
                //     aTemp.Last_Meeting_Date__c = mapAccountIdToMaxDate.get(n.Client_Prospect__c);
                //     aTemp.Last_Contact_Date__c = mapAccountIdToMaxDate.get(n.Client_Prospect__c); //added by Lodhi
                    
                // }

                mapAccts.put(aTemp.Id,aTemp);
            }
            
            System.debug(gmTempSet);
            
            if(gmTempSet != null && !gmTempSet.isEmpty())
            {
                for(Group_Member__c gm : gmTempSet)
                {
                    if(gm != null && nTemp != null)
                    {
                        if(((gm.Last_Contact_Date__c < nTemp.ActivityDate__c) || gm.Last_Contact_Date__c == null) && nTemp.Type__c != 'Meeting' && nTemp.Type__c != 'Note')
                        {
                            gm.Last_Contact_Date__c = nTemp.ActivityDate__c;                        
                        }
                        
                        // if(nTemp.Type__c == 'Meeting' && ((gm.Last_Meeting_Date__c < nTemp.ActivityDate__c) || gm.Last_Meeting_Date__c == null))
                        // if(nTemp.Type__c == 'Meeting' && mapRelGrpIdToMaxDate.containsKey(gm.Relationship_Group__c))
                        // {
                        //     gm.Last_Meeting_Date__c = mapRelGrpIdToMaxDate.get(gm.Relationship_Group__c);
                        //     gm.Last_Contact_Date__c = mapRelGrpIdToMaxDate.get(gm.Relationship_Group__c);
                        // }
                        
                        mapGMs.put(gm.Id,gm);
                    }
                }
            }
        }
        update mapGMs.values();
        update mapAccts.values();
    }
}