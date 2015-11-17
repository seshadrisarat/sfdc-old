/** 
* \author Vlad Gumenyuk 
* \date 01/29/2013
* \see https://silverline.jira.com/browse/WP-64
* \  Create a new "Deal Sharing" Visualforce Page for custom Sharing of the Deal only to users. 
*/
public without sharing class SL_ctrl_Deal_SharingDetail {
	public Id curDealId {get;set;}
   public list<Deal_Share_Show> list_DealShare {get;set;}
   	public Deal__c curDeal {get;set;}

   public class Deal_Share_Show {
   	public String action_link {get; set;}
   	public String action_link_edit {get; set;}
   	public String action_link_del {get; set;}
   	public String Row_Cause {get; set;}
   	public String WP_Group {get; set;}
   	public Deal__Share Deal_Share  {get; set;}
   	public Deal_Share_Show() {
   		action_link = '';
   		action_link_edit = '';
   		action_link_del = '';
   		Row_Cause = '';
   		Deal_Share = new Deal__Share();
   	} 
   }
	
   private ApexPages.StandardController controller;
   	
	public SL_ctrl_Deal_SharingDetail(){
	  this.curDealId = ApexPages.currentPage().getParameters().get('parentId');
	  if(this.curDealId != null) {
	  	 set_Deal();
	     set_List_Deal_Share();
	  }   
	  
	}
	
  	public Deal__Share share {get; set;}
  	public User user {get; set;}
  	public Group theGroup {get; set;}
  	

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

   public PageReference delDealShare() {
        String delID_str = '';
        delID_str = ApexPages.currentPage().getParameters().get('delID');
        if(delID_str!= null && delID_str.length()>14) {
        	
           List<Deal_Share_Compliance_Email__c> lst2InsDSComplEmail_unshare = new List<Deal_Share_Compliance_Email__c>();
        	
           Id curDelDealShareId = delID_str;
           if(curDelDealShareId != null) {
            list<Deal__Share> list_Deal_Share_tmp = new list<Deal__Share>();
            list_Deal_Share_tmp = [Select d.UserOrGroupId, d.RowCause, d.ParentId, d.LastModifiedDate, d.LastModifiedById, d.IsDeleted, d.Id, d.AccessLevel From Deal__Share d WHERE Id = :curDelDealShareId LIMIT 1];
            if(list_Deal_Share_tmp.size()>0) {
               String user_id_str = ''+list_Deal_Share_tmp[0].UserOrGroupId;  
               Deal_Share_Compliance_Email__c dsce = new Deal_Share_Compliance_Email__c();
            	if(user_id_str.substring(0,3)=='005') {
            		Map<ID,User> mapUserInfo = new Map<ID,User>();
            		mapUserInfo = new Map<ID, User>([SELECT Id, Name FROM User where ID = :user_id_str]);
                  dsce.is_Delete_flag__c = true;
              	   dsce.Deal__c = list_Deal_Share_tmp[0].ParentId;
            	   dsce.Shared_To_User__c = user_id_str;
            	   dsce.Shared_By_User__c = UserInfo.getUserId();
            	   dsce.Shared_Type__c = 'User';
            	   if(mapUserInfo.size()>0) {
            	   	dsce.Shared_To_Name__c = mapUserInfo.get(user_id_str).Name;
            	      lst2InsDSComplEmail_unshare.add(dsce);
            	   }
            	}
            	
               delete list_Deal_Share_tmp[0];
               
               if(lst2InsDSComplEmail_unshare.size()>0)
                  insert lst2InsDSComplEmail_unshare;
            } 
           }
        }
      
        PageReference AddSharePage = new PageReference('/apex/SL_Deal_SharingDetail?parentId='+String.valueOf(curDealId));
        AddSharePage.setRedirect(true);
        return AddSharePage; 
   }  
	
   public PageReference addDealShareUser() {
        PageReference AddSharePage = new PageReference('/apex/SL_Deal_SharingEdit?parentId='+String.valueOf(curDealId));
        AddSharePage.setRedirect(true);
        return AddSharePage; 
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
      } 
   } 

	private void set_List_Deal_Share() {
      list<Deal__Share> list_DealShare_tmp = new list<Deal__Share>();
      list_DealShare = new list<Deal_Share_Show>();
		if(curDealId != null) {
		 list_DealShare_tmp = [Select d.UserOrGroupId, d.RowCause, d.ParentId, d.LastModifiedDate, d.LastModifiedById, d.IsDeleted, d.Id, d.AccessLevel From Deal__Share d WHERE ParentId = :curDealId];
	    
	    set<Id> set_user_ids = new set<Id>();  
	    map<Id,String> map_user_id_contact_WP_Group = new map<Id,String>();   
       for(Deal__Share ds : list_DealShare_tmp) 
       {
       	String UserOrGroupId1 = String.valueOf(ds.UserOrGroupId);
         if(UserOrGroupId1.startsWith('005'))
         {
         	set_user_ids.add(UserOrGroupId1);
         }
       }
       if(set_user_ids.size()>0)
       for(Contact cont : [Select c.WP_Group__c, c.User_ID__c, c.Id From Contact c Where c.User_ID__c IN :set_user_ids])
       {
       	String WP_Group = cont.WP_Group__c; 
       	if(WP_Group != null && WP_Group.length()>0 && !map_user_id_contact_WP_Group.containsKey(cont.User_ID__c)) {
       		map_user_id_contact_WP_Group.put(cont.User_ID__c,WP_Group);
       	}
       }
       
       for(Deal__Share ds : list_DealShare_tmp) {
         String UserOrGroupId = String.valueOf(ds.UserOrGroupId);
         Deal_Share_Show dss = new Deal_Share_Show();
         dss.Deal_Share = ds;
         dss.Row_Cause = String.valueOf(ds.RowCause);
         if(dss.Row_Cause == 'Manual') {
   		    dss.action_link_edit = '/apex/SL_Deal_SharingEdit?id='+String.valueOf(ds.Id)+'&parentId='+String.valueOf(curDealId)+'&retURL=%2Fapex%2FSL_Deal_SharingDetail%3FparentId%3D'+String.valueOf(curDealId);
   		    dss.action_link_del = '/apex/SL_Deal_SharingDetail?delID='+String.valueOf(ds.Id)+'&parentId='+String.valueOf(curDealId)+'&retURL=%2Fapex%2FSL_Deal_SharingDetail%3FparentId%3D'+String.valueOf(curDealId);
         	dss.action_link = '';
         } else 
  	       dss.action_link = 'display: none;';
  	      
  	      if(map_user_id_contact_WP_Group.containsKey(UserOrGroupId))
  	         dss.WP_Group = map_user_id_contact_WP_Group.get(UserOrGroupId); 
  	      else
  	         dss.WP_Group = '';
  	         
         if(dss.Row_Cause == 'Manual') dss.Row_Cause = 'Manual Sharing';
          
         if(UserOrGroupId.startsWith('005'))
           list_DealShare.add(dss);
       }
		 
		} 
	} 
	 
	public String getDeal_Name() {
      if(curDeal.Name != null) 
         return curDeal.Name;
      return '';
	}

	public String getDeal_ShareCount() {
      return String.valueOf(list_DealShare.size());
	}
	
}