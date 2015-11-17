trigger AccountAddressTrigger on Account (before insert, before update) 
{
       if(Trigger.isBefore)
       {
          for(Account objAccount: Trigger.new)
          {
              if(objAccount.Match_Billing_Address__c && objAccount.BillingPostalCode != null)
                  objAccount.ShippingPostalCode = objAccount.BillingPostalCode;
          }
       }
       
}