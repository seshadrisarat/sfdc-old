/**  
* \arg TriggerName    : SL_Test_AccountHandler
* \arg JIRATicket     : HL-23
* \arg CreatedOn      : 07/AUG/2014
* \arg LastModifiedOn : 07/AUG/2014
* \arg CreatededBy    : Lodhi
* \arg ModifiedBy     : -
* \arg Description    : Test class for SL_AccountHandler
*/
@isTest
private class SL_Test_AccountHandler 
{
    static testMethod void Test_AccountHandler() 
    {
        List<Account> lstAccount = SL_TestSetupUtils.CreateAccount('Account', 2);
        insert lstAccount;

        List<Account> lstAccount1 = new List<Account>();
        For(Account objAccount : SL_TestSetupUtils.CreateAccount('Account', 2))
     	{
     		objAccount.ParentId = lstAccount[0].Id;
     		lstAccount1.add(objAccount);
     	}
        
        For(Account objAccount : SL_TestSetupUtils.CreateAccount('Account', 2))
     	{
     		objAccount.ParentId = lstAccount[1].Id;
     		lstAccount1.add(objAccount);
     	}
        insert lstAccount1;

        Account acc = [SELECT Ultimate_Parent__c FROM Account WHERE Id =:lstAccount1[0].Id];
        System.assertEquals(acc.Ultimate_Parent__c, lstAccount[0].Id);

        List<Account> lstAccount2 = new List<Account>();
        For(Account objAccount : SL_TestSetupUtils.CreateAccount('Account', 2))
        {
            objAccount.ParentId = lstAccount1[0].Id;
            lstAccount2.add(objAccount);
        }

        For(Account objAccount : SL_TestSetupUtils.CreateAccount('Account', 2))
        {
            objAccount.ParentId = lstAccount1[2].Id;
            lstAccount2.add(objAccount);
        }
        insert lstAccount2;

        List<Account> lstAccount3 = new List<Account>();
        For(Account objAccount : SL_TestSetupUtils.CreateAccount('Account', 2))
        {
            objAccount.ParentId = lstAccount2[1].Id;
            lstAccount3.add(objAccount);
        }

        For(Account objAccount : SL_TestSetupUtils.CreateAccount('Account', 2))
        {
            objAccount.ParentId = lstAccount2[3].Id;
            lstAccount3.add(objAccount);
        }
        insert lstAccount3;

        lstAccount1[0].ParentId = lstAccount1[3].Id;
        update lstAccount1[0];

        Account acc1 = [SELECT Ultimate_Parent__c FROM Account WHERE Id =:lstAccount3[1].Id];
        System.assertEquals(acc1.Ultimate_Parent__c, lstAccount[1].Id);

        lstAccount[1].ParentId = lstAccount[0].Id;
        update lstAccount[1];

        Account acc2 = [SELECT Ultimate_Parent__c FROM Account WHERE Id =:lstAccount3[3].Id];
        System.assertEquals(acc2.Ultimate_Parent__c, lstAccount[0].Id);

        delete lstAccount1[0];

        Account acc3 = [SELECT Ultimate_Parent__c FROM Account WHERE Id =:lstAccount3[1].Id];
        System.assertEquals(acc3.Ultimate_Parent__c, lstAccount2[1].Id);
        
        Account acc4 = [SELECT ParentId,Ultimate_Parent__c FROM Account WHERE Id =:lstAccount2[1].Id];

        System.assertEquals(acc4.ParentId, null);
        System.assertEquals(acc4.Ultimate_Parent__c, null);
    }
}