public with sharing class sf1_ListService {
      
	@RemoteAction
	public static String createCompanyListMembers(ID contactid)
	{
        
        List<Contact> lstInital = [Select c.Initials__c, ID From Contact c where c.User_ID__c= :UserInfo.getUserId()];
        System.debug('createcompanylistmem 1 ' + lstInital.isEmpty());
		if (!lstInital.isEmpty())
		{
            System.debug('createcompanylistmem 2a ' + lstInital[0].Initials__c);
			String userInital = lstInital[0].Initials__c;
            
			String listname = '*My Sync List (' + userInital + ')';
			List<Company_List__c> clc = [Select c.Id from Company_List__c c where c.Name= :listname];
			
			if (!clc.isEmpty())
			{
				List<Company_List_Member__c> listmember = [Select Id from Company_List_Member__c where Company_List__c= :clc[0].Id and Contact__c= :contactid];
				if (listmember.isEmpty()) {
					Company_List_Member__c objCompanyListMember = new Company_List_Member__c(Company_List__c = clc[0].Id, Contact__c = contactid);
					System.debug('createcompanylistmem ' + objCompanyListMember);
					Database.insert(objCompanyListMember, true);
					 return 'This contact has been added to your My Sync List.';
                }
			}
			return 'This contact is already on your My Sync List.';
		}
        else {
            return 'My Sync List does not exist.';
        }
		
	}
    @RemoteAction
    public static String ContactToAddName(ID contactid) {
        List<Contact> contactlst = [Select c.Name from Contact c where c.ID = :contactid];
        return contactlst[0].Name;
    }
    
    @RemoteAction
    public static List<Company_List__c> GetMyLists() {
        List<Company_List__c> clc = [Select c.Id, c.Name from Company_List__c c where c.Status__c = 'Current'];
        return clc;
    }
}