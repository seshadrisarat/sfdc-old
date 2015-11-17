global class AccountPlan1 
{
    webservice String area;
    webservice String region;
    
    
     global class Plan {
      webservice String name;
      webservice Integer planNumber;
      webservice Date planningPeriod;
      webservice Id planId;
   }
     
     webservice static Plan createAccountPlan(Plan vPlan) {
       Account acct = new Account();
       acct.Name = vPlan.name;
       acct.AccountNumber = String.valueOf(vPlan.planNumber);
       insert acct;        

       vPlan.planId=acct.Id;
       return vPlan;     
     }  
}