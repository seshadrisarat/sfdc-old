public class AccountHandler {
    public static Account insertNewAccount(String str )
    {
        if(str != null && str != '')
        {
            Account obj  = new Account(Name = str);
            insert obj;
            return obj;
        }
        else
        {
            return null;
        }
    }
}