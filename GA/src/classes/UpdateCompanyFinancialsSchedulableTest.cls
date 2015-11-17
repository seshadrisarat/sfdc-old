//S-168352 - Created by Aditya Paliwal on 01/06/2014
//Created to cover UpdateCompanyFinancialsSchedulable

@istest
public class UpdateCompanyFinancialsSchedulableTest{
public static testMethod void batchTest(){
Test.startTest();
UpdateCompanyFinancialsSchedulable updObj = new UpdateCompanyFinancialsSchedulable(); 
String sch = '00 27 06 * * ?';
system.schedule('Test Batch Schedule', sch,updObj);
Test.stopTest();
}
}