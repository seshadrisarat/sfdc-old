/*
New logic for Sharing: use schedule process once an hour. 
1. create an object (ScheduleData) where we'll be keep Id of main object which sharing is need to be updated (Deal or Call Log or PBI)
2. each triggered object (Deal Team, CallLog, CallLogAttendees, PBITeam, Employee, ....  )  will fill ScheduleData object 
3. every hour the schedule process runs, update Sharing for records of objects (from SceduleData) and empty SceduleData
*/
global class SharingScheduler implements Schedulable
{
    global void execute(SchedulableContext SC) 
    {
        Map<Id,Id> DealID = new Map<Id,Id>(); // Deal Id list (will use values())
        Map<Id,Id> CallLogID = new Map<Id,Id>();// CallLog list (will use values())
        Map<Id,Id> PBIID = new Map<Id,Id>();// PBI Id list (will use values())
        List<Schedule_Data__c> ListToDelete_ScheduleData = new List<Schedule_Data__c>();
        List<Id> ListToDelete_ScheduleData_IDs = new List<Id>();
        for(Schedule_Data__c item : [Select Object_Id__c, Id From Schedule_Data__c Where Type__c = 'Deal']) 
        {
            //DealID.add(item.Object_Id__c);
            DealID.put(item.Object_Id__c,item.Object_Id__c); // used Map construction to exclude duplicates
            ListToDelete_ScheduleData.add(item);
            ListToDelete_ScheduleData_IDs.add(item.Id);
        }
        for(Schedule_Data__c item : [Select Object_Id__c, Id From Schedule_Data__c Where Type__c = 'Call Log']) 
        {
            CallLogID.put(item.Object_Id__c,item.Object_Id__c); 
            ListToDelete_ScheduleData.add(item);
            ListToDelete_ScheduleData_IDs.add(item.Id);
        }
        for(Schedule_Data__c item : [Select Object_Id__c, Id From Schedule_Data__c Where Type__c = 'PBI'])  
        {
            PBIID.put(item.Object_Id__c,item.Object_Id__c);
            ListToDelete_ScheduleData.add(item);
            ListToDelete_ScheduleData_IDs.add(item.Id);
        }
        if(ListToDelete_ScheduleData_IDs.size() > 0)
        {
            if(DealID.size() > 0) 
            {
                //runs batch process to update Deal sharing rules ( used with parametr: list of Deal Ids )
                Batch_DealShareUPD batch = new Batch_DealShareUPD(DealID.values()); // 
                if(!Test.isRunningTest()){
                    Database.executeBatch(batch, 100);
                }
            }
            if(CallLogID.size() > 0) 
            {
                //runs batch process to update CallLog sharing rules ( used with parametr: list of CallLog Ids )
                Batch_CallLogShareUPD batch = new Batch_CallLogShareUPD(CallLogID.values());
                if(!Test.isRunningTest()){
                    Database.executeBatch(batch, 100);
                }
            }
            if(PBIID.size() > 0) 
            {
                //runs batch process to update PBI sharing rules ( used with parametr: list of PBI Ids )
                Batch_PBIShareUPD batch = new Batch_PBIShareUPD(PBIID.values());
                if(!Test.isRunningTest()){
                    Database.executeBatch(batch, 100);
                }
            }
            //clearning Schedule_Data__c object 
            //delete ListToDelete_ScheduleData;
            //if some datas was deleted by onother schedular process
            //ListToDelete_ScheduleData = [SELECT Id From Schedule_Data__c Where Id IN : ListToDelete_ScheduleData_IDs];
            if(ListToDelete_ScheduleData.size() > 0){
                if(ListToDelete_ScheduleData.size() > (Limits.getLimitDMLRows() - Limits.getDMLRows() - 1000)){
                    SL_Batch_DeleteScheduleData batchDelete = new SL_Batch_DeleteScheduleData(ListToDelete_ScheduleData_IDs);
                    if(!Test.isRunningTest()){
                        Database.executeBatch(batchDelete, 200);
                    }
                }
                else{
                    delete ListToDelete_ScheduleData;
                }
            }
        }
        
           
    }


}