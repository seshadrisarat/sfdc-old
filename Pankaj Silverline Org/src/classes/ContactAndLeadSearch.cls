public class ContactAndLeadSearch
{
    public static List<List<Sobject>> searchContactsAndLeads(String str)
    {
        return [FIND :str IN ALL FIELDS RETURNING Contact(LastName),Lead(FirstName,LastName)];
    }
}