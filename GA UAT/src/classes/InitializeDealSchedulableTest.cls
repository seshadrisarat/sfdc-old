//S-168352 - Created by Aditya Paliwal on 01/03/2014
//Created to cover InitializeDealSchedulable

@istest
public class InitializeDealSchedulableTest{
public static testMethod void batchTest(){
Test.startTest();
InitializeDealSchedulable dealObj = new InitializeDealSchedulable(); 
String sch = '00 27 06 * * ?';
system.schedule('Test Batch Schedule', sch,dealObj);
Test.stopTest();
}
}