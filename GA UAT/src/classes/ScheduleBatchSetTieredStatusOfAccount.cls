/********************************************************************************************
Name   : ScheduleBatchSetTieredStatusOfAccount
Author : Jyoti Singh
Usage  : Used to execute BatchSetTieredStatusOfAccount batch class.
********************************************************************************************/  
global class ScheduleBatchSetTieredStatusOfAccount implements Schedulable{
    
    global void execute(SchedulableContext sc){
        try{ 
            BatchSetTieredStatusOfAccount batch = new BatchSetTieredStatusOfAccount();    
            Database.executeBatch(batch, 200);             
        }catch(Exception ex){
            System.debug('Exception in updating tiered status:::'+ex.getMessage());
        } 
    }
   
   
}