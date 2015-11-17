/** 
* \author Vladislav Gumenyuk
* \date 01/08/2012
* \see https://silverline.jira.com/browse/WP-60
* \details 
* \   handling Deal.Deal_Team_Intials__c with changes in User.Initials
*/
public without sharing class SL_handler_User
{
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    public SL_handler_User(boolean isExecuting, integer size)
    {
        m_isExecuting = isExecuting;
        BatchSize = size;
    } 

    public void OnBeforeInsert(list<User> newlist_Users) { }

    /*
        @MethodName : OnAfterInsert.
        @param      : map of user records.
        @Description: This function will call After insertion of the user records.
    */
    public void OnAfterInsert(map<Id,User> newmap_Users) 
    {
        
        list<Company_List__c> lstCompanyList = new list<Company_List__c>();
        list<String> lstCompanyLst = new list<String>();
        set<Id> setProfileId = new set<Id>();
        set<Id> setUserLicenseId = new set<Id>();
        map<Id, Boolean> mapProfileId_Boolean = new map<Id, Boolean>();
        
        // Iterating new user records to get the set of Profile Ids.
        for(User objUser : newmap_Users.values())
        {
            setProfileId.add(objUser.ProfileId);
        }
        
        // Query the UserLicense object to get the UserLicenseId whose name is 'Salesforce' or 'Salesforce Platform'.
        for(UserLicense objUserLicense : [Select Name, Id From UserLicense where Name='Salesforce' or Name='Salesforce Platform'])
        {
            setUserLicenseId.add(objUserLicense.Id);
        }
        
        // Query Profile to get the map of profile id and set that value as true.
        for(Profile objProfile : [select Id from Profile where UserLicenseId IN :setUserLicenseId and Id IN : setProfileId])
        {
            mapProfileId_Boolean.put(objProfile.Id, true);
        }
        
        
        // Iterating through map of new user records
        for(User objUser : newmap_Users.values())
        {
            // If Profile Id map contains the current user profileId and its value is true then create Contact List record and add in list with some field mapping. 
            if(mapProfileId_Boolean.containsKey(objUser.ProfileId))
            {
                if(mapProfileId_Boolean.get(objUser.ProfileId) == true)
                {
                	if(objUser.UserRoleId == null )
                	{
                		Company_List__c objList = new Company_List__c();
	                    objList.Name = '*My Sync List '+'('+objUser.Initials__c+')';
	                    objList.Outlook_Sync__c = true;
	                    objList.OwnerId = objUser.Id;
	                    objList.Show_in_Quick_Add__c = true;
	                    lstCompanyList.add(objList);
                	}
                	else
                	{
                		lstCompanyLst.add(objUser.Id);
                	}
                }
            }
        }
        	methodToCreateCL(lstCompanyLst);
        // If list is not empty then insert the list
        if(lstCompanyList.size() > 0)
        {
        	insert lstCompanyList;
        	for(Company_List__c cList : lstCompanyList)
			{
			if (cList.Id != null) {
				Sync_List_Subscriber__c slc = new Sync_List_Subscriber__c ();
				slc.List__c = cList.Id;
				slc.Subscriber__c = cList.OwnerId;
				insert slc;
				}
			}	
        	
        }
        
    } 
	
	@future
	private static void methodToCreateCL(List<String> lstCompanyIds)
	{
		List<Company_List__c> lstCL = new List<Company_List__c>();
		Map<String, String> mapUserIdToInitials = new Map<String, String>();
		
		for(User sObjUser : [Select Id, Initials__c From User where Id IN:lstCompanyIds])
		{
			mapUserIdToInitials.put(sObjUser.Id, sObjUser.Initials__c);
		}
		for(String strIds : lstCompanyIds)
		{
			Company_List__c objList = new Company_List__c();
			if(mapUserIdToInitials.ContainsKey(strIds) && mapUserIdToInitials.get(strIds) !=null)
			{
				 objList.Name = '*My Sync List '+'('+mapUserIdToInitials.get(strIds)+')';
			}
			else
		    objList.Name = '*My Sync List';
		    objList.Outlook_Sync__c = true;
		    objList.OwnerId = strIds;
		    objList.Show_in_Quick_Add__c = true;
		    lstCL.add(objList);
		}
	   
	    if(lstCL.size()>0)
	    {
		insert lstCL;
		for(Company_List__c cList : lstCL)
			{
			if (cList.Id != null) {
				Sync_List_Subscriber__c slc = new Sync_List_Subscriber__c ();
				slc.List__c = cList.Id;
				slc.Subscriber__c = cList.OwnerId;
				insert slc;
				}
			}
	    }
	}
	
    public void OnBeforeUpdate(map<ID,User> oldmap_Users, map<ID,User> newmap_Users) {

    }
     
    public void OnAfterUpdate(map<ID,User> oldmap_Users, map<ID,User> newmap_Users)
    {
       //AR:Task 8713:Define a separate listmap to assign all deleted Users 
       //System.Debug('DEBUG AR:OnAfterUpdate=>Entering>');
       map<ID,User> map_Users = new map<ID,User>();
       
       for(ID id1 : newmap_Users.keySet()) {
       	   Boolean bAdded=false;
       	   if(/*newmap_Users.get(id1).IsActive == true &&*/ (
                   (newmap_Users.get(id1).Initials__c == null && oldmap_Users.get(id1).Initials__c != null)
                || (newmap_Users.get(id1).Initials__c != null && oldmap_Users.get(id1).Initials__c == null)
                || newmap_Users.get(id1).Initials__c != oldmap_Users.get(id1).Initials__c
                || newmap_Users.get(id1).IsActive != oldmap_Users.get(id1).IsActive
               )
           ) 
           {
           		map_Users.put(id1,newmap_Users.get(id1));
           		system.debug('eeeeeeeeeeeeeeeeeeee DEBUG AR:OnAfterUpdate=>USER->IsActive=>' + newmap_Users.get(id1).IsActive);
           		bAdded=true;
           }
           if(!bAdded && newmap_Users.get(id1).IsActive == false)
           {
               map_Users.put(id1,newmap_Users.get(id1));  
               System.Debug('eeeeeeeeeeeeeeeeeeeeee DEBUG AR:OnAfterUpdate=>USER->IsActive=false>' + id1);	
           }           
       	}
       	List<String> lstUserIds = new List<String>();
	    for(ID id1:map_Users.keyset())
	    {
	    	lstUserIds.add(id1);
	   	}  	   			
	   	System.Debug('eeeeeeeeeeeee map_users size is ' + map_Users.size()); //kck
       	if(map_Users.size()>0)
	    { 
	    	//updDealInitials(map_Users);//WP-60
	    	System.Debug ('eeeeeeeeeeeeeeeee here 2');//kck3
	    	System.debug(LoggingLevel.Debug, 'eeeeeeeeeeeeeeeeeeee  list of usersid is ' + lstUserIds.size() ); //kck3
	    	
	    	
	    	
      // kck4
      	Set<Id> set_contact_ids = new Set<Id>();
        List<Contact> list_contact = [SELECT ID,User_ID__c FROM Contact WHERE User_ID__c IN :lstUserIds limit 2000];
        for(Contact cont: list_contact) {
           set_contact_ids.add(cont.Id);
           System.debug('eeeeeeeeeeeeeeeeeeeeeeeee kipp DEBUG AR:updDealInitials->USER set to be deleted cont.Id=>' + cont.Id + ' for user ' + cont.User_ID__c);
        }
	    	SL_handler_User.updDealInitials(set_contact_ids);//WP-60 
	    	//system.debug('DEBUG AR:updDealInitials=>JustCalled>');
	    }
	    	
	    	{
		    	List<String> lstIds = new List<String>();
	    		for(ID id1:newmap_Users.keyset())
	    		{
	    			lstIds.add(id1);
	   			}  
	    		ensureSyncListSubscriber(lstIds);     
	    	     		
	    	}
	    	
	    	//system.debug('DEBUG AR:OnAfterUpdate=>Exiting>');	    	
    }
    
    @future
    public static void ensureSyncListSubscriber(/*map<ID,User>*/ List<ID> list_Users)
    {
    	System.Debug('ensureSyncListSubscriber start');
    	List<User> lstUsers = [Select u.IsActive, u.LastName, u.Id, u.FirstName, u.Initials__c, (Select Subscriber__c, List__c From Sync_List_Subscribers__r) From User u where Id in :list_Users]; 
		List<Sync_List_Subscriber__c> lstSubscribersToDelete = new List<Sync_List_Subscriber__c>();
		for(User usr : lstUsers)
		{
			System.Debug('USER ACTIVE STATE ------->' + usr.Id + ' name ' + usr.LastName + ' isactive:' + usr.IsActive);
			for(Sync_List_Subscriber__c sls : usr.Sync_List_Subscribers__r)
			{
			if (usr.IsActive == false)
				{
				// if they're NOT active and they have one, delete it
				lstSubscribersToDelete.add(sls);
				}
			}

			// if they're active and they don't have one, create it (and the 'my sync list' object as well if it doesn't exist
			if (usr.IsActive == true)
			{
			// make sure their "my sync list" object exists, creating if necessary
			Company_List__c cl = null;//[select Id, Name, OwnerId from Company_List__c where OwnerId = :usr.id and Name like '%*My Sync List (%)' limit 1];
			if ([select Id, Name, OwnerId from Company_List__c where OwnerId = :usr.id and Name like '%*My Sync List (%)' limit 1].size()==0)
			{
				System.Debug('NEED TO CREATE SYNC LIST FOR user ' + usr.FirstName);
				cl = new Company_List__c();
				cl.Name = '*My Sync List '+'('+usr.Initials__c+')';
				cl.Outlook_Sync__c = true;
				cl.OwnerId = usr.Id;
				cl.Show_in_Quick_Add__c = true;
				System.Debug('ABOUT TO CREATE for user ' + user.FirstName + ' --->>>> ' + cl.Name);
				insert cl;
				System.Debug('CREATED for user ' + user.FirstName + ' --->>>> ' + cl.Name + ' with id ' + cl.Id);
			}
			else 
				{ 
				cl = [select Id, Name, OwnerId from Company_List__c where OwnerId = :usr.id and Name like '%*My Sync List (%)' limit 1];
				}			
			// make sure a record in the sync list subscriber table links to it
			if (cl!=null)
			{
				if ([select Id from Sync_List_Subscriber__c where List__c = :cl.Id and Subscriber__c = :usr.Id].size()==0)
				{
				System.Debug('NEED TO CREATE SYNC LIST SUBSCRIBER OBJECT for sync list ' + cl.Name + ' for user ' + usr.LastName);
				Sync_List_Subscriber__c slc = new Sync_List_Subscriber__c ();
				slc.List__c = cl.Id;
				slc.Subscriber__c = cl.OwnerId;
				insert slc;
				}
			}
			}

		}
		if (lstSubscribersToDelete.size()>0)
		{
			for(Sync_List_Subscriber__c sls : lstSubscribersToDelete)
			{
			System.Debug('WILL BE DELETING subscriber id ------->' + sls.Id);
			}

		delete lstSubscribersToDelete;
		}
    
    } 
     
//    public void OnBeforeDelete(map<ID,User> oldmap_Users) {  
        //updDealInitials(oldmap_Users);//WP-60  
//    }
//    public void OnAfterDelete(map<ID,User> oldmap_Users) { }
//    public void OnUndelete(list<User> restored_Users) { }

    // Using method in class SL_handler_Deal_Team
    @future
    public static void updDealInitials(Set<ID> set_contact_ids){//listUsersId){
        SL_handler_Deal_Team dt_handler = new SL_handler_Deal_Team(false, Trigger.size); 
        dt_handler.updDealInitialsByUser(set_contact_ids);
    }
}