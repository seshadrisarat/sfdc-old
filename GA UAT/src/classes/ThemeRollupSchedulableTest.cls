//S-168352 - Created by Aditya Paliwal on 01/06/2014
//Created to cover ThemeRollupSchedulable
 
@istest
public class ThemeRollupSchedulableTest{
public static testMethod void batchTest(){
Test.startTest();
ThemeRollupSchedulable theObj = new ThemeRollupSchedulable(); 
String sch = '00 27 06 * * ?';
system.schedule('Test Batch Schedule', sch,theObj);
Test.stopTest();
}
}