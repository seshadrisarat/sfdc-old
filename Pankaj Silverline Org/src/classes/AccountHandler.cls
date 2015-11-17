public class AccountHandler{
      public static Account insertNewAccount(String strName)
      {
             try{
             Account objAccount = new Account(Name = strName);
             insert objAccount;
             return objAccount;
             }
             catch(DMLException ex)
             {
                 return null;
             }
      }
}