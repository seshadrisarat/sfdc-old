/**
* Test methods are in Test_Account.cls
**/
global class Account_Change_DevCode2 
{
    WebService static Boolean AutoUpdate(String AccountId) 
    {
        
        if (AccountId != null && AccountId != '')
        {
            Account AccountO = [SELECT Id, Client_Code__c, Business_Development_Code__c, Business_CodeSwap_Field__c FROM Account WHERE Id =: AccountId limit 1];
            system.debug(AccountO);
            
            if(AccountO != null && (AccountO.Business_Development_Code__c == null || AccountO.Business_Development_Code__c == '') && AccountO.Client_Code__c != null && AccountO.Client_Code__c != '')
            {
                AccountO.Business_Development_Code__c = AccountO.Client_Code__c+ '_NB_000';
                update AccountO;
                return true;
            }
            else if(AccountO != null && (AccountO.Business_Development_Code__c == null || AccountO.Business_Development_Code__c == '')) 
           {
                AccountO.Business_CodeSwap_Field__c = '000_NB_000';
                update AccountO;
                return true;
            }
            
        }
        return false;
    }
}