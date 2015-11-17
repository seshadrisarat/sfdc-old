public class ContactSearch
{
    public static List<Contact> searchForContacts(String prm1, String prm2)
    {
         return [select Id, Name from Contact where LastName =: prm1 AND MailingPostalCode =:prm2];
    }
}