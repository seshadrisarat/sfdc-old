public class RandomContactFactory
{
    public static List<Contact> generateRandomContacts(integer intNoOfContacts, String strContactLastName)
    {
        List<Contact> lstContactToInsert = new List<Contact>();
        for(Integer i = 1; i <= intNoOfContacts; i++)
        {
            lstContactToInsert.add(new Contact(FirstName ='Test '+i, LastName = strContactLastName));    
        }
        
        return lstContactToInsert;
    }
}