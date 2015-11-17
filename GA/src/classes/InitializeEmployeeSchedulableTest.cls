//S-168352 - Created by Aditya Paliwal on 01/03/2014
//Created to cover InitializeEmployeeSchedulable

@istest
public class InitializeEmployeeSchedulableTest{
public static testMethod void batchTest(){
Test.startTest();
InitializeEmployeeSchedulable empObj = new InitializeEmployeeSchedulable(); 
String sch = '00 27 06 * * ?';
system.schedule('Test Batch Schedule', sch,empObj);
Test.stopTest();
}
}