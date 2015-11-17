public with sharing class ProspectEventDashboardController 
{
    public List<Event> getEvents()
    {
        List<Event> l=[SELECT Account.Name, Account.Company_Name__c, ActivityDate FROM Event WHERE ActivityDate >= today AND ActivityDate <= NEXT_N_DAYS:120 AND Type='Prospect Meeting' order by ActivityDate asc];
        return l;
    }
    
    static testMethod void testController() {
        ProspectEventDashboardController t = new ProspectEventDashboardController();
        t.getEvents();
    }
}