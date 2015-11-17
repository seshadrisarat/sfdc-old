//S-179419 - Created by Aditya Paliwal 
//Created to cover DealReferralRollupSchedulable
@istest
public class DealReferralRollupSchedulableTest{
public static testMethod void batchTest(){
Test.startTest();
DealReferralRollupSchedulable dealObj = new DealReferralRollupSchedulable(); 
String sch = '0 0 13 * * ?';
system.schedule('Test Batch Schedule', sch,dealObj);
Test.stopTest();
}
}