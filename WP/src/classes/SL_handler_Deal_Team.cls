/** 
* \author Vlad Gumenyuk 
* \date 10/10/2012
* \see https://silverline.jira.com/browse/WP-8, https://silverline.jira.com/browse/WP-7
* \ Company Team Member Trigger
* \details Additional 
* \ Trigger logic on Deal Team on Insert/Update/Delete to keep "Company Team Member" object up-to-date with all deals in the system. Only the Deal, Company, Employee (Contact), and Status information will be shared in the resulting record.
*/


public without sharing class SL_handler_Deal_Team
{
   private boolean m_isExecuting = false;
   private integer BatchSize = 0;
   private static boolean isDealWPGroupInserted = false;
   private static boolean isDealWPGroupUpdated = false;
   private static boolean isDealWPGroupDeleted = false;

   public SL_handler_Deal_Team(boolean isExecuting, integer size)
   {
       m_isExecuting = isExecuting;
       BatchSize = size;
   }

    public void OnBeforeInsert(list<Deal_Team__c> newlist_Deal_Teams) 
    { 

////      list<Company_Team_Member__c> list_Company_Team_Members = create_list_Company_Team_Member(newlist_Deal_Teams);
      
      map<String,Company_Team_Member__c> map_str_Company_Team_Members = create_list_Company_Team_Member(newlist_Deal_Teams); 
        
      map<String,List<String>> map_str_list_str_ctm = new map<String,List<String>>();
      set<ID> set_deal_id_s = new set<ID>(); 
      set<ID> set_contact_id_s = new set<ID>(); 
      set<ID> set_company_id_s = new set<ID>();

        set<ID> set_deal_ids = new set<ID>(); 
        for(Deal_Team__c deal_team : newlist_Deal_Teams) {
           set_deal_ids.add(deal_team.Deal__c);
        }
        map<ID,Deal__c> map_deals = new map<ID,Deal__c>([SELECT id, Company__c, Name, Stage__c  FROM Deal__c WHERE ID in :set_deal_ids]);
      
//      if(list_Company_Team_Members != null && list_Company_Team_Members.size() == newlist_Deal_Teams.size()) 
////      if(list_Company_Team_Members != null && list_Company_Team_Members.size() > 0)
      // If there have some new Company_Team_Member__c inserted, put inserted and existing Company_Team_Member__c.Id into Deal_Team__c.Company_Team_Member__c 
      if(map_str_Company_Team_Members != null && !map_str_Company_Team_Members.isEmpty()) 
      {

      	String str_key;
        for(Integer i=0;i<newlist_Deal_Teams.size();i++) 
        {
          str_key = String.valueOf(newlist_Deal_Teams[i].Deal__c)+' - '+String.valueOf(newlist_Deal_Teams[i].Employee__c)+' - '+String.valueOf(map_deals.get(newlist_Deal_Teams[i].Deal__c).Company__c);
          if(map_str_Company_Team_Members.keySet().contains(str_key) )
            newlist_Deal_Teams[i].Company_Team_Member__c = map_str_Company_Team_Members.get(str_key).id;
////          newlist_Deal_Teams[i].Company_Team_Member__c = list_Company_Team_Members[i].Id;
//          newlist_Deal_Teams[i].Company_Team_Member_ID__c = String.valueOf(list_Company_Team_Members[i].Id);
          else {
          	 List<String> list_str = new list<String>();
//          	 list_str.add(String.valueOf(newlist_Deal_Teams[i].Deal__c));
          	 set_deal_id_s.add(newlist_Deal_Teams[i].Deal__c);
//          	 list_str.add(String.valueOf(newlist_Deal_Teams[i].Employee__c));
          	 set_contact_id_s.add(newlist_Deal_Teams[i].Employee__c);
//          	 list_str.add(String.valueOf(map_deals.get(newlist_Deal_Teams[i].Deal__c).Company__c));
          	 set_company_id_s.add(map_deals.get(newlist_Deal_Teams[i].Deal__c).Company__c);
             map_str_list_str_ctm.put(str_key,list_str);
          }   
        }
      } else {
      	// If there have not any new Company_Team_Member__c inserted, just put existing Company_Team_Member__c.Id into Deal_Team__c.Company_Team_Member__c 
      	String str_key;
        for(Integer i=0;i<newlist_Deal_Teams.size();i++) 
        {
          str_key = String.valueOf(newlist_Deal_Teams[i].Deal__c)+' - '+String.valueOf(newlist_Deal_Teams[i].Employee__c)+' - '+String.valueOf(map_deals.get(newlist_Deal_Teams[i].Deal__c).Company__c);
          	 List<String> list_str = new list<String>();
//          	 list_str.add(String.valueOf(newlist_Deal_Teams[i].Deal__c));
          	 set_deal_id_s.add(newlist_Deal_Teams[i].Deal__c);
//          	 list_str.add(String.valueOf(newlist_Deal_Teams[i].Employee__c));
          	 set_contact_id_s.add(newlist_Deal_Teams[i].Employee__c);
//          	 list_str.add(String.valueOf(map_deals.get(newlist_Deal_Teams[i].Deal__c).Company__c));
          	 set_company_id_s.add(map_deals.get(newlist_Deal_Teams[i].Deal__c).Company__c);
             map_str_list_str_ctm.put(str_key,list_str);
        }
      }

      if(!map_str_list_str_ctm.isEmpty()) {
         for(Company_Team_Member__c ctm : [SELECT Id, Company__c, Contact__c, Deal__c FROM Company_Team_Member__c WHERE Company__c IN :set_company_id_s AND Contact__c IN :set_contact_id_s AND Deal__c IN :set_deal_id_s ])
         {
           for(Deal_Team__c deal_team : newlist_Deal_Teams) {
              if(deal_team.Company_Team_Member__c == null)
                if(  deal_team.Deal__c == ctm.Deal__c
                && deal_team.Employee__c == ctm.Contact__c
                && map_deals.get(deal_team.Deal__c).Company__c == ctm.Company__c
                ) { 
                  deal_team.Company_Team_Member__c = ctm.Id;
                }  
           } 
         }
      	
      }
      
    }

    public void OnAfterInsert(map<ID,Deal_Team__c> newmap_Deal_Teams)
    {
    	setRollUpDealTeamFields(newmap_Deal_Teams.values());//WP-34
    	setDealWPSeniorTeamMemberGroup(newmap_Deal_Teams.values());
    	//https://silverline.jira.com/browse/WP-7
    	/* remove logic (WP-40)
    	if(!isDealWPGroupInserted)
    	{
	    	isDealWPGroupInserted = true;
	    	list<Deal_Team__c> newlist_Deal_Teams = new list<Deal_Team__c>();
    		for(Id ItemId : newmap_Deal_Teams.keySet()) newlist_Deal_Teams.add(newmap_Deal_Teams.get(ItemId));
	    	setDealWPGroup(newlist_Deal_Teams);
    	}
    	*/
    } 
     
    @future public static void OnAfterInsertAsync(Set<ID> new_Contact_IDs){ }
     
    public void OnBeforeUpdate(map<ID,Deal_Team__c> oldmap_Deal_Teams, map<ID,Deal_Team__c> newmap_Deal_Teams){ }
     
    public void OnAfterUpdate(map<ID,Deal_Team__c> oldmap_Deal_Teams, map<ID,Deal_Team__c> newmap_Deal_Teams)
    {
       update_list_Company_Team_Member(newmap_Deal_Teams.values());
       setRollUpDealTeamFields(newmap_Deal_Teams.values());//WP-34
       setDealWPSeniorTeamMemberGroup(newmap_Deal_Teams.values());
       //https://silverline.jira.com/browse/WP-7
       /* remove logic (WP-40)
    	if(!isDealWPGroupUpdated)
    	{
	    	isDealWPGroupUpdated = true;
	    	list<Deal_Team__c> newlist_Deal_Teams = new list<Deal_Team__c>();
    		for(Id ItemId : newmap_Deal_Teams.keySet()) newlist_Deal_Teams.add(newmap_Deal_Teams.get(ItemId));
	    	setDealWPGroup(newlist_Deal_Teams);
    	}
    	*/
    } 
     
    @future public static void OnAfterUpdateAsync(Set<ID> updated_Contact_IDs){ }
     
    public void OnBeforeDelete(map<ID,Deal_Team__c> oldmap_Deal_Teams)
    {
    	delete_list_Company_Team_Member(oldmap_Deal_Teams.values()); 
    }
     
    public void OnAfterDelete(map<ID,Deal_Team__c> oldmap_Deal_Teams)
    { 
       
       setRollUpDealTeamFields(oldmap_Deal_Teams.values());//WP-34
       setDealWPSeniorTeamMemberGroup(oldmap_Deal_Teams.values());
       /* remove logic (WP-40)
       if(!isDealWPGroupDeleted)
    	{
	    	isDealWPGroupDeleted = true;
	    	list<Deal_Team__c> oldlist_Deal_Teams = new list<Deal_Team__c>();
    		for(Id ItemId : oldmap_Deal_Teams.keySet()) oldlist_Deal_Teams.add(oldmap_Deal_Teams.get(ItemId));
	    	setDealWPGroup(oldlist_Deal_Teams);
    	}
    	*/
    }
     
    @future public static void OnAfterDeleteAsync(Set<ID> deleted_Contact_IDs){ }
     
    public void OnUndelete(list<Deal_Team__c> restored_Deal_Teams){ }
             
    public boolean IsTriggerContext{ get{ return m_isExecuting;} }
     
    public boolean IsVisualforcePageContext{ get{ return !IsTriggerContext;} }
     
    public boolean IsWebServiceContext{ get{ return !IsTriggerContext;} }
     
    public boolean IsExecuteAnonymousContext{ get{ return !IsTriggerContext;} }   

	

/*
Trigger logic on Deal Team on Insert/Update/Delete to keep "Company Team Member" object up-to-date with all deals in the system. Only the Deal, Company, Employee (Contact), and Status information will be shared in the resulting record.

Deal (Deal__c.Name) will be stored on both a Text field and a Lookup field. This will allow users with no access to the deal to still see the value.
 Company_Team_Member_c field 	Mapping
   Company__c 	                     Deal_Team_r.Deal_r.Company_c
   Contact_c 	                         Deal_Team_r.Employee_c  
   Date_c 	                             TODAY()
   Deal_c 	                             Deal_Team_r.Deal_c
   Deal_Name_c 	                     Deal_Team_r.Deal_r.Name
   Status_c 	                         Deal_Team_r.Deal_r.Stage_c

After creating the Company_Team_Member_c record, update the Deal_Team_r.Company_Team_Member_ID_c field with the record ID. You can use this field to keep the Company_Team_Member_c in sync after updates and deletes to Deal_Team_c records.
*/
//    private list<Company_Team_Member__c> create_list_Company_Team_Member(list<Deal_Team__c> list_Deal_Teams) {
    private map<String,Company_Team_Member__c> create_list_Company_Team_Member(list<Deal_Team__c> list_Deal_Teams) {
      list<Company_Team_Member__c> list_Company_Team_Member = new list<Company_Team_Member__c>();
      set<ID> set_deal_ids = new set<ID>(); 
      for(Deal_Team__c deal_team : list_Deal_Teams) {
         set_deal_ids.add(deal_team.Deal__c);
      }
      map<ID,Deal__c> map_deals = new map<ID,Deal__c>([SELECT id, Company__c, Name, Stage__c  FROM Deal__c WHERE ID in :set_deal_ids limit 2000]);

      //https://silverline.jira.com/browse/WP-8
      // Contacts should not be duplicated for a Deal
      set<ID> set_deal_companies = new set<ID>(); 
      for(Deal_Team__c deal_team : list_Deal_Teams) {
         set_deal_companies.add(map_deals.get(deal_team.Deal__c).Company__c);
      }
      // ?
      set<String> set_ctm_deal_contact = new set<String>(); 
      for(Company_Team_Member__c ctm : [SELECT Id, Company__c, Contact__c, Deal__c FROM Company_Team_Member__c WHERE Company__c IN :set_deal_companies limit 2000]){
         set_ctm_deal_contact.add(String.valueOf(ctm.Deal__c)+' - '+String.valueOf(ctm.Contact__c)+' - '+String.valueOf(ctm.Company__c) );
      }
      
      for(Deal_Team__c deal_team : list_Deal_Teams) {
      	if(set_ctm_deal_contact.contains(String.valueOf(deal_team.Deal__c)+' - '+String.valueOf(deal_team.Employee__c)+' - '+String.valueOf(map_deals.get(deal_team.Deal__c).Company__c) ) ) 
      	  continue;
        Company_Team_Member__c Company_Team_Member = new Company_Team_Member__c();
        Company_Team_Member.Company__c = map_deals.get(deal_team.Deal__c).Company__c;
        Company_Team_Member.Contact__c = deal_team.Employee__c;
        Company_Team_Member.Date__c = Date.today();
        Company_Team_Member.Deal__c = deal_team.Deal__c;
        Company_Team_Member.Deal_Name__c = map_deals.get(deal_team.Deal__c).Name;
        Company_Team_Member.Status__c = map_deals.get(deal_team.Deal__c).Stage__c;
        if(Company_Team_Member.Company__c != null && Company_Team_Member.Contact__c != null) {
          list_Company_Team_Member.add(Company_Team_Member);
        }
        set_ctm_deal_contact.add(String.valueOf(deal_team.Deal__c)+' - '+String.valueOf(deal_team.Employee__c)+' - '+String.valueOf(map_deals.get(deal_team.Deal__c).Company__c) );
      }
      if(list_Company_Team_Member.size()>0) {
        insert list_Company_Team_Member;
        
        map<String,Company_Team_Member__c> map_str_Company_Team_Members = new map<String,Company_Team_Member__c>(); 
        for(Company_Team_Member__c ctm: list_Company_Team_Member) {
        	map_str_Company_Team_Members.put(String.valueOf(ctm.Deal__c)+' - '+String.valueOf(ctm.Contact__c)+' - '+String.valueOf(ctm.Company__c) , ctm);
        }
        
        return map_str_Company_Team_Members;
         //return list_Company_Team_Member;
      } else 
         return null;
    }

    private void update_list_Company_Team_Member(list<Deal_Team__c> list_Deal_Teams) {
      list<Company_Team_Member__c> list_Company_Team_Member = new list<Company_Team_Member__c>();
      set<ID> set_compteammemb_ids = new set<ID>(); 
      set<ID> set_deal_ids = new set<ID>(); 
      for(Deal_Team__c deal_team : list_Deal_Teams) {
         set_deal_ids.add(deal_team.Deal__c);
      	if(deal_team.Company_Team_Member__c != null)
          set_compteammemb_ids.add(deal_team.Company_Team_Member__c);
      }
      map<ID,Company_Team_Member__c> map_Company_Team_Member = new map<ID,Company_Team_Member__c>([Select c.Id, c.Status__c, c.Name, c.Deal__c, c.Deal_Name__c, c.Date__c, c.Contact__c, c.Company__c From Company_Team_Member__c c WHERE c.ID in :set_compteammemb_ids limit 2000]);
      map<ID,Deal__c> map_deals = new map<ID,Deal__c>([SELECT id, Company__c, Name, Stage__c  FROM Deal__c WHERE ID in :set_deal_ids limit 2000]);
      
      for(Deal_Team__c deal_team : list_Deal_Teams) {
        Company_Team_Member__c Company_Team_Member = new Company_Team_Member__c();
        if(deal_team.Company_Team_Member__c != null) { 
          Company_Team_Member = map_Company_Team_Member.get(deal_team.Company_Team_Member__c);
         if(Company_Team_Member != null) {
       	  // Master-detail non changeable field
          //Company_Team_Member.Company__c = map_deals.get(deal_team.Deal__c).Company__c;
       	  // Master-detail non changeable field
          //Company_Team_Member.Contact__c = deal_team.Employee__c;
          Company_Team_Member.Date__c = Date.today();
          Company_Team_Member.Deal__c = deal_team.Deal__c;
          Company_Team_Member.Deal_Name__c = map_deals.get(deal_team.Deal__c).Name;
          Company_Team_Member.Status__c = map_deals.get(deal_team.Deal__c).Stage__c;
          list_Company_Team_Member.add(Company_Team_Member);
         }
        }  
      }
      if(list_Company_Team_Member.size()>0) 
        update list_Company_Team_Member;
    }

	private void delete_list_Company_Team_Member(list<Deal_Team__c> list_Deal_Teams)
	{
		set<ID> set_compteammemb_ids = new set<ID>(); 
		set<ID> set_deal_team_ids = new set<ID>(); 
      
		for(Deal_Team__c deal_team : list_Deal_Teams)
		{
			set_deal_team_ids.add(deal_team.id);
			if(deal_team.Company_Team_Member__c != null){set_compteammemb_ids.add(deal_team.Company_Team_Member__c);}
		}

		if(set_deal_team_ids.size()>0)
		{
			for(Deal_Team__c dt :[SELECT ID,Deal__c,Employee__c,Company_Team_Member__c FROM Deal_Team__c WHERE Company_Team_Member__c in :set_compteammemb_ids limit 1000])
			{
				if(!set_deal_team_ids.contains(dt.ID) && set_compteammemb_ids.contains(dt.Company_Team_Member__c)){ set_compteammemb_ids.remove(dt.Company_Team_Member__c);}
			}
		}
		
		if(set_compteammemb_ids.size()>0)
		{
			//list<Company_Team_Member__c> list_Company_Team_Member = [Select Id From Company_Team_Member__c c WHERE c.ID in :set_compteammemb_ids];
			list<Company_Team_Member__c> list_Company_Team_Member = new list<Company_Team_Member__c>();
			for(Id itemID : set_compteammemb_ids)
			{
				list_Company_Team_Member.add(new Company_Team_Member__c(ID=itemID));
			}
        	delete list_Company_Team_Member;
		}
    }    
    
    // The method is used in class SL_handler_User
    public void updDealInitialsByUser(Set<ID> set_ids) {
      List<Deal_Team__c> list_dt = [SELECT Deal__r.Name, ID,Deal__c,Employee__c FROM Deal_Team__c WHERE Employee__c IN :set_ids limit 2000];
    	setRollUpDealTeamFields(list_dt);
    }    
  
    public void setRollUpDealTeamFields(list<Deal_Team__c> newDealTeam)
    {
    	system.debug('eeeeeeeeeeeeeeeeeeeeeeeeeeeee kipp');
    	map<Id,set<String>> mapDealId_EmployeeLNs = new map<Id,set<String>> ();
    	map<Id,set<String>> mapDealId_EmployeeInitials = new map<Id,set<String>> ();
    	map<Id,String> mapDealId_EmployeeInitialsString = new map<Id,String> ();
    	map<Id,String> mapDealId_EmployeeLNsString = new map<Id,String> ();
    	Set<Id> dealIds = new Set<Id>();
    	for(Deal_Team__c item : newDealTeam)
    	{
    		if(item.Deal__c != null) dealIds.add(item.Deal__c);
    	}
    	system.debug ('eeeeeeeeeeeeeeeeee setRollUpDealTeamFields list size:' + dealIds.size()); //kck3
    	if(dealIds.size() > 0)
    	{
    		
         for(Deal_Team__c item : [SELECT ID,Deal__c,Employee__c,Employee__r.LastName,Employee__r.Initials__c, Employee__r.Status__c,Employee__r.User_ID__c, Employee__r.User_ID__r.IsActive, Employee__r.FirstName FROM Deal_Team__c WHERE Deal__c IN : dealIds order by Deal__c, Employee__r.Status__c, Employee__r.Employee_Level__r.Rank__c desc, Employee__r.Employee_Level_Precedence_Sorter__c desc limit 2000])
	    	{	
	    		if (item.Deal__c!=null) system.debug('eeeeeeeeeeeeeeeeeeeeeeeee setting deal team initials for the deal ' + item.Deal__c);
	    		
	    		
	    		if(item.Employee__c != null) 
	    		{
	    			
	    			if(!mapDealId_EmployeeLNs.containsKey(item.Deal__c))	
	    			{ 
	    				mapDealId_EmployeeLNs.put(item.Deal__c,new set<String>());
	    				mapDealId_EmployeeLNsString.put(item.Deal__c,'');
	    			}
	    			
	    			system.debug('--------------adding dealteam name = '+item.Employee__r.LastName);
	    			
	    			mapDealId_EmployeeLNs.get(item.Deal__c).add(item.Employee__r.LastName);
	    			
	    			string sN = mapDealId_EmployeeLNsString.get(item.Deal__c);
	    			if (sN != '') sN = sN + ',';
	    			sN +=  item.Employee__r.LastName;
	    			mapDealId_EmployeeLNsString.remove(item.Deal__c);
	    			mapDealId_EmployeeLNsString.put(item.Deal__c,sN);
	    			system.debug('-------------- dealteam for ' + item.Deal__c + ' string is now = '+mapDealId_EmployeeLNsString.get(item.Deal__c));
    			
               if(!mapDealId_EmployeeInitials.containsKey(item.Deal__c))   
               		{ 
               			mapDealId_EmployeeInitials.put(item.Deal__c,new set<String>());
               			mapDealId_EmployeeInitialsString.put(item.Deal__c,''); 	
               		}
               	if (/*item.Employee__r.Status__c == 'Active' &&*/ item.Employee__r.User_ID__r.IsActive == true) {
	    		if(item.Employee__r.Initials__c != null )
	    		  {
	    		  	system.debug('--------------adding dealteam initials = '+item.Employee__r.Initials__c);
	    			mapDealId_EmployeeInitials.get(item.Deal__c).add(item.Employee__r.Initials__c);
	    			string sX = mapDealId_EmployeeInitialsString.get(item.Deal__c);
	    			if (sX != '') sX = sX + ',';
	    			sX +=  item.Employee__r.Initials__c;
	    			mapDealId_EmployeeInitialsString.remove(item.Deal__c);
	    			mapDealId_EmployeeInitialsString.put(item.Deal__c,sX);
	    			system.debug('-------------- initials string for deal ' + item.Deal__c + ' is now = '+mapDealId_EmployeeInitialsString.get(item.Deal__c));
	    		  }
	    		  else 
	    		  system.debug('-------------- WARNING WARNING Missing Initials -- couldnt add dealteam initials because they were blank for active employee '+item.Employee__r.LastName);
               	}
               	else 
	    		  system.debug('--------------DIDNT add dealteam initials due to inactive = '+item.Employee__r.LastName);
	    		  
	    		  
	    		}
	    	}
	    	system.debug('----------------mapDealId_EmployeeLNs = '+mapDealId_EmployeeLNs);
	    	system.debug('----------------mapDealId_EmployeeInitials = '+mapDealId_EmployeeInitials);
	    	
	    	list<Deal__c> deals2Update = new list<Deal__c>();
	    	Deal__c tmpDeal;
	    	String tmpStr = '';
	    	for(Id dealId : dealIds)
	    	{
	    		tmpDeal = new Deal__c(Id = dealId);
    			tmpStr = '';
    			
    			
    			
    			if(mapDealId_EmployeeLNsString.get(dealId) != null)
    				tmpStr = mapDealId_EmployeeLNsString.get(dealId);
    			if(tmpStr.length() > 254) tmpStr = tmpStr.substring(0, 254);
    			/*if(mapDealId_EmployeeLNs.get(dealId) != null && mapDealId_EmployeeLNs.get(dealId).size() > 0)
    			{
	    			for(String EmpLN : mapDealId_EmployeeLNs.get(dealId)) tmpStr += ','+EmpLN;
	    			if(tmpStr.length() > 0) tmpStr = tmpStr.substring(1, tmpStr.length());
	    			if(tmpStr.length() > 254) tmpStr = tmpStr.substring(0, 254);
    			}
    			*/
    			tmpDeal.Deal_team__c = tmpStr;
    			tmpStr = '';
    			
    			
    			if(mapDealId_EmployeeInitialsString.get(dealId) != null && mapDealId_EmployeeInitialsString.get(dealId)!='')
    			{
    				tmpStr = mapDealId_EmployeeInitialsString.get(dealId);
    				if(tmpStr.length() > 254) tmpStr = tmpStr.substring(0, 254);
    			}
    			 
    			/*if(mapDealId_EmployeeInitials.get(dealId) != null && mapDealId_EmployeeInitials.get(dealId).size() > 0)
    			{
	    			for(String EmpInitial : mapDealId_EmployeeInitials.get(dealId)) 
	    			   if(EmpInitial != null && EmpInitial.length()>0) tmpStr += ','+EmpInitial;
	    			if(tmpStr.length() > 0) tmpStr = tmpStr.substring(1, tmpStr.length());
	    			if(tmpStr.length() > 254) tmpStr = tmpStr.substring(0, 254);
    			}
    			*/
    			tmpDeal.Deal_Team_Initials__c = tmpStr;
    			deals2Update.add(tmpDeal); 
	    	}
	    	if(deals2Update.size() > 0)	update deals2Update;
    	}
    }
    
    
    
    private void setRollUpDealTeamFieldsHOLD(list<Deal_Team__c> newDealTeam)
    {
    	map<Id,set<String>> mapDealId_EmployeeLNs = new map<Id,set<String>> ();
    	map<Id,set<String>> mapDealId_EmployeeInitials = new map<Id,set<String>> ();
    	Set<Id> dealIds = new Set<Id>();
    	for(Deal_Team__c item : newDealTeam)
    	{
    		if(item.Deal__c != null) dealIds.add(item.Deal__c);
    	}
    	
    	if(dealIds.size() > 0)
    	{
         for(Deal_Team__c item : [SELECT ID,Deal__c,Employee__c,Employee__r.LastName,Employee__r.Initials__c, Employee__r.Status__c,Employee__r.User_ID__c, Employee__r.FirstName FROM Deal_Team__c WHERE Deal__c IN : dealIds limit 2000])
	    	{
	    		if(item.Employee__c != null) 
	    		{
	    			
	    			if(!mapDealId_EmployeeLNs.containsKey(item.Deal__c))	mapDealId_EmployeeLNs.put(item.Deal__c,new set<String>());
	    			mapDealId_EmployeeLNs.get(item.Deal__c).add(item.Employee__r.LastName);
    			
               if(!mapDealId_EmployeeInitials.containsKey(item.Deal__c))   mapDealId_EmployeeInitials.put(item.Deal__c,new set<String>());
	    		  if(item.Employee__r.Initials__c != null && item.Employee__r.Status__c == 'Active'
	    		  ){
	    			mapDealId_EmployeeInitials.get(item.Deal__c).add(item.Employee__r.Initials__c);
	    		  }
	    		 
	    		}
	    	}
	    	//system.debug('mapDealId_EmployeeLNs = '+mapDealId_EmployeeLNs);
	    	//system.debug('mapDealId_EmployeeInitials = '+mapDealId_EmployeeInitials);
	    	
	    	list<Deal__c> deals2Update = new list<Deal__c>();
	    	Deal__c tmpDeal;
	    	String tmpStr = '';
	    	for(Id dealId : dealIds)
	    	{
	    		tmpDeal = new Deal__c(Id = dealId);
    			tmpStr = '';
    			if(mapDealId_EmployeeLNs.get(dealId) != null && mapDealId_EmployeeLNs.get(dealId).size() > 0)
    			{
	    			for(String EmpLN : mapDealId_EmployeeLNs.get(dealId)) tmpStr += ','+EmpLN;
	    			if(tmpStr.length() > 0) tmpStr = tmpStr.substring(1, tmpStr.length());
	    			if(tmpStr.length() > 254) tmpStr = tmpStr.substring(0, 254);
    			}
    			tmpDeal.Deal_team__c = tmpStr;
    			tmpStr = '';
    			if(mapDealId_EmployeeInitials.get(dealId) != null && mapDealId_EmployeeInitials.get(dealId).size() > 0)
    			{
	    			for(String EmpInitial : mapDealId_EmployeeInitials.get(dealId)) 
	    			   if(EmpInitial != null && EmpInitial.length()>0) tmpStr += ','+EmpInitial;
	    			if(tmpStr.length() > 0) tmpStr = tmpStr.substring(1, tmpStr.length());
	    			if(tmpStr.length() > 254) tmpStr = tmpStr.substring(0, 254);
    			}
    			tmpDeal.Deal_Team_Initials__c = tmpStr;
    			deals2Update.add(tmpDeal); 
	    	}
	    	if(deals2Update.size() > 0)	update deals2Update;
    	}
    }
    
    @future public static void updDealWPSeniorTeamMemberByUserAsync(Set<ID> set_ids)
    {
      List<Deal_Team__c> list_dt = [SELECT ID,Deal__c,Employee__c FROM Deal_Team__c WHERE Employee__c IN :set_ids limit 2000];
		SL_handler_Deal_Team dt_handler = new SL_handler_Deal_Team(false, Trigger.size);
		
    	dt_handler.setDealWPSeniorTeamMemberGroup(list_dt);
    }
     // The method is used in class SL_handler_Contact
    public void updDealWPSeniorTeamMemberByUser(Set<ID> set_ids) {
      List<Deal_Team__c> list_dt = [SELECT ID,Deal__c,Employee__c FROM Deal_Team__c WHERE Employee__c IN :set_ids limit 2000];
    	setDealWPSeniorTeamMemberGroup(list_dt);
    }
    
    // The method is used in class SL_handler_Deal
    public void updDealWPSeniorTeamMemberByDeal(Set<ID> set_ids) {
      List<Deal_Team__c> list_dt = [SELECT ID,Deal__c,Employee__c FROM Deal_Team__c WHERE Deal__c IN :set_ids limit 2000];
    	setDealWPSeniorTeamMemberGroup(list_dt);
    }    
 
    public void setDealWPSeniorTeamMemberGroup(list<Deal_Team__c> newDealTeam)
    {
    	
    	System.debug('zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz 111111-> with list size '+newDealTeam.size());
    	list<Id> dealIds = new list<Id>();
    	map<Id,Deal_Team__c> mapDealId_SeniorTeamMemberGroups = new map<Id,Deal_Team__c> ();
    	map<Id,Integer> mapDealId_SeniorTeamMemberCount = new map<Id,Integer>();
    	map<Id,Integer> mapDealId_TieRankCount = new map<Id,Integer>();
    	map<Id,Integer> mapDealId_SeniorAndTieRankCount = new map<Id,Integer>();
    	    	
    	map<Id,Id> dealsUpdateMap = new map<Id,Id>(); 
    	list<Deal__c> deals2Update = new list<Deal__c>();
    	Deal__c tmpDeal;
    	
    	list<Deal_Team__c> dealTeams = new list<Deal_Team__c>();
    	list<Deal_Team__c> dealTeamsSortedByUIOrder = new list<Deal_Team__c>(); 
    	list<Deal_Team__c> dealTeamsSortedByRankOrder = new list<Deal_Team__c>();    
    	list<Deal_Team__c> dealTeamsAfter1stPass = new list<Deal_Team__c>();  	
    	map<Id,list<Deal_Team__c>> map_dealTeamsByDealId = new map<Id,list<Deal_Team__c>>();     	
    	
    	for(Deal_Team__c item : newDealTeam)
    	{      		  	
    		
    		if(item.Deal__c != null)
    		{    			
    		//Deal__c d = [select Name from Deal__c where Id = :item.Deal__c limit 1];
    		//System.Debug ('heeeer-->'+d.Name);
    			if(!dealsUpdateMap.containsKey(item.Deal__c))
    			{
    				dealsUpdateMap.put(item.Deal__c,item.Deal__c);
    				dealIds.add(item.Deal__c);
    			}
    		}
    	}  
    	
    	map<ID,Deal__c> map_deals = new map<ID,Deal__c>([SELECT id, Company__c, Name, Stage__c, WP_Groups__c  FROM Deal__c WHERE ID in :dealIds limit 2000]); 
		
		//Do all three selects at once.  This keeps us from hitting a soql limit
		
		//Pass one, select the higest ranking team member by rank to see if we have any MD's		
		dealTeams = [SELECT Deal__r.Name, ID,Deal__c,Role__c,Employee__c,Employee__r.LastName,Employee__r.Initials__c, Employee__r.Status__c,Employee__r.Employee_Level_Precedence_Sorter__c, Employee__r.Employee_Level__r.Rank__c, Employee__r.Employee_Level__r.Name, Employee__r.User_ID__c, Employee__r.FirstName, Employee__r.WP_Group__c 
					   FROM Deal_Team__c WHERE Deal__c IN:dealIds and Employee__r.Status__c = 'Active' and Employee__r.WP_Group__c !=null
				   order BY Deal__c, Employee__r.Employee_Level__r.Rank__c desc, Role__c, Employee__r.LastName asc   limit 2000]; 
			  	   //order BY Deal__c, Role__c, Employee__r.Employee_Level__r.Rank__c desc,  Employee__r.LastName asc   limit 2000]; 
			  	   
		dealTeamsSortedByUIOrder =  [SELECT ID,Deal__c,Role__c,Employee__c,Employee__r.LastName,Employee__r.Initials__c, Employee__r.Status__c,Employee__r.Employee_Level_Precedence_Sorter__c, Employee__r.Employee_Level__r.Rank__c, Employee__r.Employee_Level__r.Name, Employee__r.User_ID__c, Employee__r.FirstName, Employee__r.WP_Group__c FROM Deal_Team__c WHERE Deal__c IN: dealIds and Employee__r.Status__c = 'Active' and Employee__r.WP_Group__c !=null 
    												 order BY Deal__c, Role__c, Id   limit 2000];
		
		dealTeamsSortedByRankOrder =  [SELECT ID,Deal__c,Role__c,Employee__c,Employee__r.LastName,Employee__r.Initials__c, Employee__r.Status__c,Employee__r.Employee_Level_Precedence_Sorter__c, Employee__r.Employee_Level__r.Rank__c, Employee__r.Employee_Level__r.Name, Employee__r.User_ID__c, Employee__r.FirstName, Employee__r.WP_Group__c FROM Deal_Team__c WHERE Deal__c IN: dealIds and Employee__r.Status__c = 'Active' and Employee__r.WP_Group__c !=null
									  order BY Deal__c, Employee__r.Employee_Level__r.Rank__c desc,  Employee__r.LastName asc  limit 2000];
									 //order by Deal__c, Employee__r.Status__c, Employee__r.Employee_Level__r.Rank__c desc, Role__c, Id   limit 2000];
		
	    //Build a map of senior team members for the set of deals
	    System.debug('zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz 222  size->'+dealTeams.size());
	    for(Deal_Team__c item: dealTeams)	  
	    { 
	    	System.debug('zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz 333 ->'+item.Deal__r.Name);
	    	if(item.Employee__c != null)
	    	{
	    		String dealId = item.Deal__c;	    	
	    		String wpGroup =  map_deals.get(dealId).WP_Groups__c;
	    		string[] groups = wpGroup.split(','); 
	    		boolean containsGroup = false;
	    		for(String wpgroupTemp: groups )
	    		{
	    			if(wpgroupTemp.contains(item.Employee__r.WP_Group__c))
	    			{
	    				containsGroup = true;
	    			}
	    		}	    		
	    		system.debug('Name: ' + item.Employee__r.FirstName + ' ' + item.Employee__r.LastName  +' Deal WPGroup:' + wpGroup + ' Team WPGroup:' + item.Employee__r.WP_Group__c + ' Rank: ' + item.Employee__r.Employee_Level__r.Rank__c + ' Level: ' + item.Employee__r.Employee_Level__r.Name); // ' Precedence_Sorter: '+ item.Employee__r.Employee_Level_Precedence_Sorter__c );
	   	    		
	    		//add the first on to the map
	    		if(!mapDealId_SeniorTeamMemberGroups.containsKey(dealId) &&  containsGroup)
	    		{
	    			mapDealId_SeniorTeamMemberGroups.put(dealId, item );
	    				system.debug('ADDING TO MAP - Name: ' + item.Employee__r.FirstName + ' ' + item.Employee__r.LastName  +' Deal WPGroup:' + wpGroup + ' Team WPGroup:' + item.Employee__r.WP_Group__c + ' Rank: ' + item.Employee__r.Employee_Level__r.Rank__c + ' Level: ' + item.Employee__r.Employee_Level__r.Name);// + ' Precedence_Sorter: '+ item.Employee__r.Employee_Level_Precedence_Sorter__c );
	    			//mapDealId_SeniorTeamMemberCount.put(dealId, 1);
	    		}  		
    	
    			if(item.Role__c == 'Senior Team Member')
    			{
    			  	Integer seniorCount = mapDealId_SeniorTeamMemberCount.get(dealId);
    			  	if(seniorCount != null)
    					seniorCount++;
    				else
    					seniorCount = 1;
    				
    				mapDealId_SeniorTeamMemberCount.put(dealId,seniorCount);
    				system.debug(' Senior Count: ' + seniorCount);    	 				  
    			}
    			/*
    			if(item.Employee__r.Employee_Level__r.Name == 'Managing Director')
    			{
    			  	Integer mdCount = mapDealId_mDCount.get(dealId);
    			  	if(mdCount != null)
    					mdCount++;
    				else
    					mdCount = 1;
    				
    				mapDealId_mDCount.put(dealId,mdCount);
    				system.debug(' MD Count: ' + mdCount);    	 				  
    			} 
    			
    			if(item.Role__c == 'Senior Team Member' && item.Employee__r.Employee_Level__r.Name == 'Managing Director' )
    			{
    				Integer mdAndSeniorCount = mapDealId_mDAndSeniorCount.get(dealId);    		
    				
    				if(mdAndSeniorCount != null)
    					mdAndSeniorCount++;
    				else
    					mdAndSeniorCount = 1;  
    				
    				mapDealId_mDAndSeniorCount.put(dealId,mdAndSeniorCount);
    				system.debug(' MD And Senior Count: ' + mdAndSeniorCount);	  				
    			} */   			
    			   					
	    		
	    		if(mapDealId_SeniorTeamMemberGroups.get(dealId) != null)
	    		{	
	    			if(item.Employee__r.Employee_Level__r.Rank__c > mapDealId_SeniorTeamMemberGroups.get(dealId).Employee__r.Employee_Level__r.Rank__c  //&&	    	
	    				//(item.Employee__r.Employee_Level_Precedence_Sorter__c > mapDealId_SeniorTeamMemberGroups.get(dealId).Employee__r.Employee_Level_Precedence_Sorter__c)	    		
	     			  // &&  item.Role__c == 'Senior Team Member') 
	     			   &&  containsGroup )	    			   	
	    			{
	    				system.debug(' GOT TO IF - Name: ' + item.Employee__r.FirstName + ' ' + item.Employee__r.LastName  +' Deal WPGroup:' + wpGroup + ' Team WPGroup:' + item.Employee__r.WP_Group__c + ' Rank: ' + item.Employee__r.Employee_Level__r.Rank__c + ' Level: ' + item.Employee__r.Employee_Level__r.Name);// + ' Precedence_Sorter: '+ item.Employee__r.Employee_Level_Precedence_Sorter__c );
	    				
	    				//Replace this record as the senior 	team member for the deal	    				 
	    				mapDealId_SeniorTeamMemberGroups.put(dealId, item);	  
	    			}
	    			else if(item.Employee__r.Employee_Level__r.Rank__c == mapDealId_SeniorTeamMemberGroups.get(dealId).Employee__r.Employee_Level__r.Rank__c)
	    			{
	    				//if(item.Role__c == 'Senior Team Member')
    					//{    						
		    				Integer tieRankCount = mapDealId_TieRankCount.get(dealId);
		    				
		    				if(tieRankCount != null)
		    					tieRankCount++;
		    				else
		    					tieRankCount = 1;
		    				
		    				mapDealId_TieRankCount.put(dealId,tieRankCount);
    						system.debug(' Tie Rank Count: ' + tieRankCount);			    					
    					//}
    					
    					if(item.Role__c == 'Senior Team Member')
		    			{
		    				Integer seniorAndTieRankCount = mapDealId_SeniorAndTieRankCount.get(dealId);    		
		    				
		    				if(seniorAndTieRankCount != null)
		    					seniorAndTieRankCount++;
		    				else
		    					seniorAndTieRankCount = 1;  
		    				
		    				mapDealId_SeniorAndTieRankCount.put(dealId,seniorAndTieRankCount);
		    				system.debug(' Senior and Tie Rank Count: ' + seniorAndTieRankCount);	  				
		    			}  
    					
	    			}	    			
	    		}	    		
	    		else
	    		{ 	 
	    			system.debug(' GOT TO ELSE - Name: ' + item.Employee__r.FirstName + ' ' + item.Employee__r.LastName  +' Deal WPGroup:' + wpGroup + ' Team WPGroup:' + item.Employee__r.WP_Group__c + ' Rank: ' + item.Employee__r.Employee_Level__r.Rank__c + ' Precedence_Sorter: '+ item.Employee__r.Employee_Level_Precedence_Sorter__c );
	    				 			
	    			//mapDealId_SeniorTeamMemberGroups.put(dealId, item );
	    		} 
	    	}
	    }
	    
	  
	    //If the rank of the senior team members is tied then we chose the first one on the deal team	    
	    //If we have a tie between  
	    for(Id dealId : dealIds)
	    {	    	  
    		if(mapDealId_SeniorTeamMemberCount.get(dealId) != null) 
    		{    			
    			Integer seniorCount = mapDealId_SeniorTeamMemberCount.get(dealId);
    			Integer tieRankCount = mapDealId_TieRankCount.get(dealId);    			
    			Integer seniorAndTieRankCount = mapDealId_SeniorAndTieRankCount.get(dealId);     
    			
    			 
    			//If we have tie we need to pick a winner.
    			if(tieRankCount > 1)
    			//if(seniorCount > 1 || ((tieRankCount == seniorAndTieRankCount) && seniorCount > 1) )
    			//if((seniorCount > 1  || mdCount > 1) && mdAndSeniorCount != 1 )
    			{ 
    				//Clear out the item from the map and find the new one again
    				mapDealId_SeniorTeamMemberGroups.remove(dealId);
    				
    				//string dealIdAsString = dealId; 
    				//list<Id> dealIdAsList = new list<Id>();
    				//dealIdAsList.add(dealId);    				
    				
    				//We have one or more senior team members sort by order in the deal team
    				if( seniorCount >= 1) // || ((tieRankCount == seniorAndTieRankCount) && seniorCount > 1)  ) 
    				{
    				    system.debug('Senior or rank count 1 or more.');			
    					//dealTeamsSortedByUIOrder =  [SELECT ID,Deal__c,Role__c,Employee__c,Employee__r.LastName,Employee__r.Initials__c, Employee__r.Status__c,Employee__r.Employee_Level_Precedence_Sorter__c, Employee__r.Employee_Level__r.Rank__c, Employee__r.Employee_Level__r.Name, Employee__r.User_ID__c, Employee__r.FirstName, Employee__r.WP_Group__c FROM Deal_Team__c WHERE Deal__c IN: dealIdAsList and Employee__r.Status__c = 'Active' and Employee__r.WP_Group__c !=null 
    												// order BY Deal__c, Role__c, Id   limit 2000];	
    					dealTeamsAfter1stPass = dealTeamsSortedByUIOrder; 												
    				}
    				else // no senior team members but a tie so sort by last name.
    				{
    					system.debug('Senior Count or MD count 1 or more.');
    					//dealTeamsSortedByUIOrder =  [SELECT ID,Deal__c,Role__c,Employee__c,Employee__r.LastName,Employee__r.Initials__c, Employee__r.Status__c,Employee__r.Employee_Level_Precedence_Sorter__c, Employee__r.Employee_Level__r.Rank__c, Employee__r.Employee_Level__r.Name, Employee__r.User_ID__c, Employee__r.FirstName, Employee__r.WP_Group__c FROM Deal_Team__c WHERE Deal__c IN: dealIdAsList and Employee__r.Status__c = 'Active' and Employee__r.WP_Group__c !=null
    												 // order BY Deal__c, Employee__r.Employee_Level__r.Rank__c desc,  Employee__r.LastName asc  limit 2000];
    												 ////order by Deal__c, Employee__r.Status__c, Employee__r.Employee_Level__r.Rank__c desc, Role__c, Id   limit 2000];
    					dealTeamsAfter1stPass = dealTeamsSortedByRankOrder; 
    				}    				
    
    			
    				for(Deal_Team__c item: dealTeamsAfter1stPass)
    				{
    					if(item.Deal__c == dealId )
    					{
							//String dealId = item.Deal__c;	    	
				    		String wpGroup =  map_deals.get(dealId).WP_Groups__c;
				    		string[] groups = wpGroup.split(','); 
				    		boolean containsGroup = false;
				    		for(String wpgroupTemp: groups )
				    		{
				    			if(wpgroupTemp.contains(item.Employee__r.WP_Group__c))
				    			{
				    				containsGroup = true;
				    			}
				    		}    					
							
							//add the first to the map
				    		if( !mapDealId_SeniorTeamMemberGroups.containsKey(dealId) &&  containsGroup )
				    		{
				    			mapDealId_SeniorTeamMemberGroups.put(dealId, item );
				    				system.debug('ADDING TO MAP PART 2 - Name: ' + item.Employee__r.FirstName + ' ' + item.Employee__r.LastName  +' Deal WPGroup:' + wpGroup + ' Team WPGroup:' + item.Employee__r.WP_Group__c + ' Rank: ' + item.Employee__r.Employee_Level__r.Rank__c + ' Level: ' + item.Employee__r.Employee_Level__r.Name);// + ' Precedence_Sorter: '+ item.Employee__r.Employee_Level_Precedence_Sorter__c );
				    			//mapDealId_SeniorTeamMemberCount.put(dealId, 1);
				    		}
    					
    					}
    				}
    			
    			}//end senior if 
    		}	    
	    }
	    
	    
	    
	    for(Id dealId : dealIds)
	    {
			tmpDeal = new Deal__c(Id = dealId);
			
			if(mapDealId_SeniorTeamMemberGroups.get(dealId) != null)   
			{
				tmpDeal.Senior_Team_Member_Group__c = mapDealId_SeniorTeamMemberGroups.get(dealId).Employee__r.WP_Group__c;
				System.debug('zzzzzzzzzzzzzzzzzz 444a setting senior team member group for deal' + tmpDeal.Id + ' to ' + tmpDeal.Senior_Team_Member_Group__c);
				deals2Update.add(tmpDeal);
			}
			else// There are no senior team members so clear the group
			{
				tmpDeal.Senior_Team_Member_Group__c = '';
				System.debug('zzzzzzzzzzzzzzzzzz 444b clearing senior team member group for deal' + tmpDeal.Id);
				deals2Update.add(tmpDeal);
			} 	
	    } 	    	    	
    	System.debug ('zzzzzzzzzzzzzz 555 deals to update size:' + deals2Update.size());
    	if(deals2Update.size() > 0)	update deals2Update;
    }
    
        
    /*
    private void setDealWPGroup(list<Deal_Team__c> newDealTeam)
    {
    	map<Id,set<String>> mapDealId_setWPGroup = new map<Id,set<String>>();
    	map<Id,String> mapEmployeeId_WPGroup = new map<Id,String> ();
    	list<Id> dealIds = new list<Id>();
    	for(Deal_Team__c item : newDealTeam)
    	{
    		//if(item.Employee__c != null) mapEmployeeId_WPGroup.put(item.Employee__c, null);
    		if(item.Deal__c != null) dealIds.add(item.Deal__c);
    	}
    	
    	
    	list<Deal_Team__c> listDealTeamAll = new list<Deal_Team__c>();
    	listDealTeamAll = [SELECT ID,Deal__c,Employee__c FROM Deal_Team__c WHERE Deal__c IN : dealIds ];
    	if(listDealTeamAll.size() > 0)
    	{
	    	for(Deal_Team__c item : listDealTeamAll)
	    	{
	    		if(item.Employee__c != null) mapEmployeeId_WPGroup.put(item.Employee__c, null);
	    	}
    	}
		//system.debug('mapEmployeeId_WPGroup = '+mapEmployeeId_WPGroup);
 
    	if(mapEmployeeId_WPGroup.keySet().size() > 0)
    	{
    		for(Contact item : [SELECT ID,WP_Group__c FROM Contact WHERE ID IN : mapEmployeeId_WPGroup.keySet()])
    		{
    			if(item.WP_Group__c!=null && item.WP_Group__c!=''){ mapEmployeeId_WPGroup.put(item.Id, item.WP_Group__c);}
    		}	
    	}
		//system.debug('mapEmployeeId_WPGroup = '+mapEmployeeId_WPGroup);

    	if(listDealTeamAll.size() > 0)
    	{
	    	for(Deal_Team__c item : listDealTeamAll)
	    	{
	    		if(!mapDealId_setWPGroup.containsKey(item.Deal__c)) mapDealId_setWPGroup.put(item.Deal__c, new set<String>());
	    		if(item.Employee__c != null && mapEmployeeId_WPGroup.get(item.Employee__c) != null) mapDealId_setWPGroup.get(item.Deal__c).add(mapEmployeeId_WPGroup.get(item.Employee__c));
	    	}
    	}
    	//system.debug('mapDealId_setWPGroup = '+mapDealId_setWPGroup);
    	
    	if(mapDealId_setWPGroup.keyset().size() > 0)
    	{
    		Deal__c tmpDeal;
    		list<Deal__c> deals2Insert = new list<Deal__c>();
    		String tmpWPGroupsStr = '';
    		for(Id dealId : mapDealId_setWPGroup.keyset())
    		{
    			if(mapDealId_setWPGroup.containsKey(dealId) && mapDealId_setWPGroup.get(dealId).size() > 0)
    			{
    				tmpDeal = new Deal__c(Id = dealId);
    				tmpWPGroupsStr = '';
    				for(String WPgroup : mapDealId_setWPGroup.get(dealId)) tmpWPGroupsStr += ','+WPgroup;
    				if(tmpWPGroupsStr.length() > 0) tmpWPGroupsStr = tmpWPGroupsStr.substring(1, tmpWPGroupsStr.length());
    				if(tmpWPGroupsStr.length() > 254) tmpWPGroupsStr = tmpWPGroupsStr.substring(0, 254);
    				tmpDeal.WP_Groups__c = tmpWPGroupsStr;
    				
    				deals2Insert.add(tmpDeal); 
    			}
    		}
    		if(deals2Insert.size() > 0)	update deals2Insert;
    	}
    	
    }
*/

/* public static testMethod void testMe(   )
      {
      SL_handler_Deal_Team x = new SL_handler_Deal_Team(false,1);
      x.DummyMethod();
      Deal_Team__c fo = new Deal_Team__c();
     Contact emp = [Select Id from Contact where lastname = 'Chiu' limit 1];
      Deal__c dlX = [Select Id From Deal__c limit 1];
      //insert dlX;
      //Fund__c fX = [Select Id From Fund__c limit 1];
      fo.Employee__c=emp.Id;
      fo.Deal__c = dlX.Id;
      //fo.Fund__c = fX.Id;
      //fo.Fund__c
      insert fo;
      
      
      }
public string DummyMethod()
 {
 string s = '1213';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 s='abc';
 return s;
 }
 */

}