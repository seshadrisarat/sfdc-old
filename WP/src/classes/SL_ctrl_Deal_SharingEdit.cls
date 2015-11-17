/** 
* \author Vlad Gumenyuk 
* \date 01/29/2013
* \see https://silverline.jira.com/browse/WP-64
* \  Create a new "Deal Sharing" Visualforce Page for custom Sharing of the Deal only to users. 
*/
public without sharing class SL_ctrl_Deal_SharingEdit {
      public Id curDealId {get;set;}
      public Id curDealShareId {get;set;}
      public String sHidden {get;set;}
      public String findUserName {get;set;}
      public Deal__c curDeal {get;set;}

      String[] users = new String[]{};
      String[] users2 = new String[]{};
      Set<Id> set_deal_shared_user_ids = new Set<Id>();
      
      User[] users3 = new User[]{};
      
      String accesslevel = 'Edit';
       
      public SL_ctrl_Deal_SharingEdit(){
      	findUserName = '';
      	
         this.curDealId = ApexPages.currentPage().getParameters().get('parentId');
         if(this.curDealId != null) {
            set_Deal();
         }
                  
         this.curDealShareId = ApexPages.currentPage().getParameters().get('Id');
   	     if(curDealShareId != null) {
   	     	list<Deal__Share> list_Deal_Share_tmp = new list<Deal__Share>(); 
		    list_Deal_Share_tmp = [Select d.UserOrGroupId, d.RowCause, d.ParentId, d.LastModifiedDate, d.LastModifiedById, d.IsDeleted, d.Id, d.AccessLevel From Deal__Share d WHERE Id = :curDealShareId LIMIT 1];
   	  		if(list_Deal_Share_tmp.size()>0) 
   	  			accesslevel = list_Deal_Share_tmp[0].AccessLevel;
   	  	 }
      }

      public PageReference checkSession() {
         if(curDealId != null) {
            if(SL_wsdl_Deal_Sharing_fn.is_Share_Deal(String.valueOf(curDealId)) == '0') {
               PageReference AddSharePage = new PageReference('/'+String.valueOf(curDealId));
               AddSharePage.setRedirect(true);
               return AddSharePage;
            } 
         }   
         return null;
      }

      public String getEdit_Style() {
         if(curDealShareId != null)
           return 'display: none;'; 
         return ''; 
      }

   private void set_Deal() {
      curDeal = new Deal__c(); 
      if(curDealId != null) {
         String queryFields = '';
         String tmpFldName = '';
        
         for( Schema.SObjectField f : SObjectType.Deal__c.fields.getMap().values())
         {
            tmpFldName = ''+f.getDescribe().getSObjectField();
            if(tmpFldName.length()<5 || tmpFldName.substring(0, 4)!='Bid_') queryFields += ', ' + tmpFldName;
         }
     
         List<Deal__c> list_deal = Database.query('SELECT '+(queryFields.substring(1))+' FROM Deal__c WHERE ID = \''+String.valueOf(curDealId)+'\' LIMIT 1');
         if(!list_deal.isEmpty()) 
            curDeal = list_deal[0];
            
	 	 for(Deal__Share ds : [Select d.UserOrGroupId, d.RowCause, d.ParentId, d.LastModifiedDate, d.LastModifiedById, d.IsDeleted, d.Id, d.AccessLevel From Deal__Share d WHERE ParentId = :curDealId]) 
	 	 {
		      String UserOrGroupId = String.valueOf(ds.UserOrGroupId);
              if(UserOrGroupId.startsWith('005'))
           		set_deal_shared_user_ids.add(ds.UserOrGroupId);
		 }	
            
      } 
   } 
   
   public String getDeal_Name() {
      if(curDeal.Name != null) 
         return curDeal.Name;
      return '';
   }
   
   
	  public List<SelectOption> getItems() {
		List<SelectOption> options = new List<SelectOption>();
      	List<User> list_users = new List<User>();

        String id_not_in_query = ''; 
        
        // Do not find again choosed user
        if(sHidden!=null && sHidden.length()>14) {
            users2 = new list<String>();
            users2 = sHidden.split(',', 0);
            set<Id> set_user_id = new set<Id>();
            if(users2.size()>0) 
            for(String stu: users2) {
               if(stu.length()>14)  
                  set_user_id.add(stu);
            }
            if(set_user_id.size()>0)
              for(Id user_id  : set_user_id)
                 id_not_in_query+=(id_not_in_query.length()==0?'':'\',\'')+String.valueOf(user_id);
        }    
        
        if(set_deal_shared_user_ids.size()>0)
        for(Id user_id  : set_deal_shared_user_ids)
           id_not_in_query+=(id_not_in_query.length()==0?'':'\',\'')+String.valueOf(user_id);
        if(id_not_in_query.length()>0)
          id_not_in_query = ' Id NOT IN (\''+id_not_in_query+'\')';    

        String user_license_id_not_in_query = '';
        for(UserLicense user_lic  : [Select ul.Id From UserLicense ul where ul.name like 'Chatter%'])
           user_license_id_not_in_query+=(user_license_id_not_in_query.length()==0?'':'\',\'')+String.valueOf(user_lic.Id);
        if(user_license_id_not_in_query.length()>0)
          user_license_id_not_in_query = ' u.Profile.UserLicenseId NOT IN (\''+user_license_id_not_in_query+'\')';    

	    String soql = 'SELECT Name,Id FROM User u where name != null';
	    if (!id_not_in_query.equals(''))
      		soql += ' and '+id_not_in_query+' ';
       if (!user_license_id_not_in_query.equals(''))
            soql += ' and '+user_license_id_not_in_query+' ';
    	if (!findUserName.equals('')) {
      		soql += ' and (firstname LIKE \''+String.escapeSingleQuotes(findUserName)+'%\'';
      		soql += ' or lastname LIKE \''+String.escapeSingleQuotes(findUserName)+'%\'';
      		soql += ' or name LIKE \''+String.escapeSingleQuotes(findUserName)+'%\')';
    	}    
        
    	try {
      		list_users = Database.query(soql + ' limit 200');
    	} catch (Exception e) {
      		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Ooops!'));
    	}
      	
      	for(User us: list_users) 
      		options.add(new SelectOption(String.valueOf(us.Id),us.Name));
      	if(options.size()==0)	
      	   options.add(new SelectOption('0','--None--'));
		return options;
	  }      

      public String[] getUsers() {
         return users;
      }
      public void setUsers(String[] inUsers) {
         this.users = inUsers;
      }
      
     public List<SelectOption> getItems2() {
      List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('0','--None--'));
      return options;
     }

      public String[] getUsers2() {
         return users2;
      }
      public void setUsers2(String[] usrs2) {
         this.users2 = usrs2;
      }


   	  public PageReference cancelDealShare() {
        PageReference AddSharePage = new PageReference('/apex/SL_Deal_SharingDetail?parentId='+String.valueOf(curDealId));
        AddSharePage.setRedirect(true);
        return AddSharePage; 
   	  }

   	  public PageReference saveDealShare() {
   	  	list<Deal__Share> list_Deal_Share = new list<Deal__Share>();  

   	    if(curDealShareId != null) {
		    list_Deal_Share = [Select d.UserOrGroupId, d.RowCause, d.ParentId, d.LastModifiedDate, d.LastModifiedById, d.IsDeleted, d.Id, d.AccessLevel From Deal__Share d WHERE Id = :curDealShareId LIMIT 1];
   	  		if(list_Deal_Share.size()>0) {
   	  			Deal__Share ds = list_Deal_Share[0];
	   	  		ds.AccessLevel=accesslevel;
   	  			update ds; 
   	  		}
   	    } else {

         	users2 = new list<String>();
         	users2 = sHidden.split(',', 0);
         
      		users3 = new List<User>();
      		set<Id> set_user_id = new set<Id>();
      		if(users2.size()>0) 
      		for(String stu: users2) {
	      		if(stu.length()>14)  
      	   		set_user_id.add(stu);
      		}   
      		if(set_user_id.size()>0)
      	  	  users3 = new List<User>([SELECT Name,Id FROM User WHERE id in :set_user_id LIMIT 2000]);

            if(users3.size()>0)
   	  		for(User us: users3) {
   	  			Deal__Share ds = new Deal__Share();
   	  			ds.ParentId = curDealId; 
   	  			ds.UserOrGroupId=us.Id;
   	  			//ds.AccessLevel='Edit';
   	  			ds.AccessLevel=accesslevel;
   	  	    	if(String.valueOf(us.Id)!='0')
   	  				list_Deal_Share.add(ds); 
   	  		}
   	  		if(list_Deal_Share.size()>0)
   	  		   insert list_Deal_Share;
   	  	}
//        PageReference AddSharePage = new PageReference('/apex/SL_Deal_SharingDetail?parentId='+String.valueOf(curDealId));
        PageReference AddSharePage = new PageReference('/'+String.valueOf(curDealId));
        AddSharePage.setRedirect(true);
        return AddSharePage; 
   	  }	


        public PageReference runSearch() {
            findUserName = Apexpages.currentPage().getParameters().get('findUserName');
            system.debug('>>>>>>>> sHidden '+sHidden);
            sHidden = Apexpages.currentPage().getParameters().get('dontFindUserIds');
            return null;
        }

      public String getAccessLevel() {
         return AccessLevel;
      }
      public void setAccessLevel(String al) {
         this.AccessLevel = al;
      }


      public String getUserNames() {
          if(users2.size()>0)
            return String.valueOf(users2.size());
          return '';
      }
      public String getDealId() {
          if(curDealId!=null)
            return String.valueOf(curDealId);
          return '';
      }

}