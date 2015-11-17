//S-168352 - Created by Aditya Paliwal on 01/03/2014
//Created to cover EmployeeRollupSchedulable
@istest
public class EmployeeRollupSchedulableTest{
public static testMethod void batchTest(){


Test.startTest();
EmployeeRollupSchedulable dealObj = new EmployeeRollupSchedulable(); 
String sch = '00 27 06 * * ?';
system.schedule('Test Batch Schedule', sch,dealObj);
Test.stopTest();
}
}