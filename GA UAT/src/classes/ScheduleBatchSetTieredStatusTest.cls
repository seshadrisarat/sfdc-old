/********************************************************************************************
Name   : ScheduleBatchSetTieredStatusTest
Author : Jyoti Singh
Usage  : Used to execute BatchSetTieredStatusOfAccount batch class.
********************************************************************************************/  
@istest
public class ScheduleBatchSetTieredStatusTest{
    
    public static testMethod void batchTest(){
       Test.startTest();
       ScheduleBatchSetTieredStatusOfAccount   m = new ScheduleBatchSetTieredStatusOfAccount  ();
       String sch = '00 27 06 * * ?';
       system.schedule('Test Batch Schedule', sch, m);
       Test.stopTest();
   }
}