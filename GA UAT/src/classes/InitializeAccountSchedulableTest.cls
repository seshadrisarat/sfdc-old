//S-168352 - Created by Aditya Paliwal on 01/03/2014
//Created to cover InitializeAccountSchedulable

@istest
public class InitializeAccountSchedulableTest{
public static testMethod void batchTest(){
Test.startTest();
InitializeAccountSchedulable accObj = new InitializeAccountSchedulable(); 
String sch = '00 27 06 * * ?';
system.schedule('Test Batch Schedule', sch,accObj);
Test.stopTest();
}
}