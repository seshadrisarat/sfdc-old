public class ContactSearch 
{
    public static List<Contact> searchForContacts( string str1 , string str2)
    {
        List<Contact> lst =[SELECT Id,Name FROM Contact WHERE LASTNAME =: str1 AND MailingPostalCode=: str2];
        return lst;
    }
}