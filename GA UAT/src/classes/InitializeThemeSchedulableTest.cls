//S-168352 - Created by Aditya Paliwal on 01/03/2014
//Created to cover InitializeThemeSchedulable

@istest
public class InitializeThemeSchedulableTest{
public static testMethod void batchTest(){
Test.startTest();
InitializeThemeSchedulable theObj = new InitializeThemeSchedulable(); 
String sch = '00 27 06 * * ?';
system.schedule('Test Batch Schedule', sch,theObj);
Test.stopTest();
}
}