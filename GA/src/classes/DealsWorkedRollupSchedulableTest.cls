//S-179419 - Created by Aditya Paliwal 
//Created to cover DealsWorkedRollupSchedulable

@istest
public class DealsWorkedRollupSchedulableTest{
public static testMethod void batchTest(){
Test.startTest();
DealsWorkedRollupSchedulable dealObj = new DealsWorkedRollupSchedulable(); 
String sch = '00 27 06 * * ?';
system.schedule('Test Batch Schedule', sch,dealObj);
Test.stopTest();
}
}