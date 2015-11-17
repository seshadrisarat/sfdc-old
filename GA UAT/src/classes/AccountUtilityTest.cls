//S-144144 - Created by Anuradha Suthar on 9/26/2013
//Created to cover class AccountUtility
@isTest
public class AccountUtilityTest{

  @isTest
  public static void checkClaimOwnershipNotification(){
    Account acc = Test_Utility.createAccount('TestAcc',null,'Company');
    insert acc;
    Test.startTest();
    AccountUtility.sendClaimOwnershipEmail(acc.ID);
    Test.stopTest();
  }
}