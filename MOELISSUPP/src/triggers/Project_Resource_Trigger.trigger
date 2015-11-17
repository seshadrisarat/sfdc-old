trigger Project_Resource_Trigger on Project_Resource__c (before delete, after insert, before update) 
{

    //DealSharingRules.shareFrom_ProjectResource(Trigger.old, Trigger.new, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete);
                                            
    //DealSharingRules.Set_UpdateDealSharing_True(Trigger.old,Trigger.new,Trigger.isInsert,Trigger.isUpdate,Trigger.isDelete);
    
    
    List<Project_Resource__c> List_Project_Resource = new List<Project_Resource__c>();
    List<Project_Resource__c> Trigger_list;
    if(trigger.isInsert || trigger.isUpdate) Trigger_list = Trigger.new;
    if(trigger.isDelete) Trigger_list = Trigger.old;
    Boolean isFireTrigger = false;
    Id oneEmployee_Id;
    Id secondEmployee_Id;
    for (Project_Resource__c item : Trigger_list) 
    {
        Project_Resource__c oldResource;
        Project_Resource__c newResource;
        if(trigger.isUpdate || trigger.isDelete){
            oldResource = trigger.oldmap.get(item.Id);
        }
        if(trigger.isUpdate || trigger.isInsert){
            newResource = trigger.newmap.get(item.Id);
        }
        if(trigger.isInsert){
            if(newResource != null){
                isFireTrigger = true;
                List_Project_Resource.add(item);
            }
        }
        else if(trigger.isUpdate){
            if(newResource.Banker__c != oldResource.Banker__c || newResource.Status__c != oldResource.Status__c){
                isFireTrigger = true;
                List_Project_Resource.add(item);
            }
        }
        else if(trigger.isDelete){
            if(oldResource.Banker__c != null){
                isFireTrigger = true;
                List_Project_Resource.add(item);
            }
        }
    }
    if (isFireTrigger) 
    {
        List<Schedule_Data__c> List_toInsert = new List<Schedule_Data__c>();
        List<Id> List_DealId = new List<Id>();
        for(Project_Resource__c item :List_Project_Resource)    List_DealId.add(item.Project__c);
        /*  "Deal Team Members" should be adde to the Deal Share*/
        system.debug('List_DealId --------------->'+List_DealId);
        if(List_DealId.size() > 0)
        {
            for(Id itemId : List_DealId)
            {
                Schedule_Data__c newSD = new Schedule_Data__c();
                newSD.Object_Id__c = itemId;
                newSD.Type__c = 'Deal';
                List_toInsert.add(newSD);
                System.debug('Schedule Data: ' + newSD);
            }
            /*
            try{
                Batch_DealShareUPD batch = new Batch_DealShareUPD(List_DealId);
                Database.executeBatch(batch, 100);
                //DealSharingRules.UpdateShare(List_Deal_Id);
            }catch(Exception e){throw new MyException('Please, wait. Previous batch process has not complited yet.');}
            */
        }
        System.debug('==========List_toInsert============'+List_toInsert);
        /* The sharing rules for the Deal Team Membership will need to be amended to apply to related PBI as well. */
        List<Id> List_PBI_Id = new List<Id>();
        List<Potential_Buyer_Investor__c> List_PBI = [SELECT Id
                                        FROM Potential_Buyer_Investor__c
                                        WHERE Project__c IN :List_DealId];
        
        for(Potential_Buyer_Investor__c item: List_PBI) 
        {
            List_PBI_Id.add(item.Id);
        }
        
        system.debug('List_PBI_Id------------------->'+List_PBI_Id);
        if(List_PBI_Id.size() > 0)
        {
            for(Id itemId : List_PBI_Id)
            {
                Schedule_Data__c newSD = new Schedule_Data__c();
                newSD.Object_Id__c = itemId;
                newSD.Type__c = 'PBI';
                List_toInsert.add(newSD);
            }
        }
        
        /* A "Call Log" is related to a "Deal" must be accessible to the "Deal Team Members". */
        List<Id> List_CallLogId = new List<Id>();
        system.debug('List_DealId------------------->'+List_DealId);
        List<Call_Log_Deal__c> List_CLD = [ SELECT Deal__c, Call_Log__c
                                        FROM Call_Log_Deal__c
                                        WHERE Deal__c IN :List_DealId]; 
                                                
        for(Call_Log_Deal__c item: List_CLD)
        {
            List_CallLogId.add(item.Call_Log__c);
        }
        
        system.debug('List_CallLogId------------------->'+List_CallLogId);
        if(List_CallLogId.size() > 0)
        {
            for(Id itemId : List_CallLogId)
            {
                Schedule_Data__c newSD = new Schedule_Data__c();
                newSD.Object_Id__c = itemId;
                newSD.Type__c = 'Call Log';
                List_toInsert.add(newSD);
            }
        }
        //if(List_toInsert.size() > 0) insert List_toInsert;
        if(List_toInsert.size() > 0) 
        {
            if(List_toInsert.size() > (Limits.getLimitDMLRows() - Limits.getDMLRows() - 1000)){
                Batch_ScheduleData_UPD batch = new Batch_ScheduleData_UPD(List_toInsert); // 
                Database.executeBatch(batch, 100);
            }
            else{
                insert List_toInsert;
            }
        }
    }
}