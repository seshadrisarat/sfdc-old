public class ContactAndLeadSearch {
    public static List<List< SObject>> searchContactsAndLeads(String str)
    {
        List<List<SObject>> lstnew =[FIND :str IN ALL FIELDS RETURNING Lead (LastName), Contact(FirstName,LastName)];
        return lstnew ;
    }
}