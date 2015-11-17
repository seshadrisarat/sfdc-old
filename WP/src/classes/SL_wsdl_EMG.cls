/** 
* \author Vlad Gumenyuk 
* \date 03/05/2013
* \see https://silverline.jira.com/browse/WP-70
* \see https://silverline.jira.com/browse/WP-71
* \ "EMG Comment && Paragraph" Custom Button 
* \details Additional 
* \  New JS “Update” button added to EMG Comment and EMG Paragraph related lists. Button will look for existing record of same type (on this Deal). If one exists, user is redirected to Edit page for that record. If not User is sent to New page.
*/
global class SL_wsdl_EMG {
    
    WebService static String EMG_Paragraph_from_Deal(String deal_id_str,String url_field_id) 
    {
      Deal__c curDeal = null;
      if(deal_id_str.length()>14)
         curDeal = [Select id, name, RecordTypeId, WP_Groups_picklist__c From Deal__c where ID = :deal_id_str limit 1];

      Contact uContact = getContact_by_current_User();
      if(curDeal != null)
      {
         list<EMG_Paragraph__c> list_emg_paragraphs = new list<EMG_Paragraph__c>();
         if(uContact != null)
             list_emg_paragraphs = new list<EMG_Paragraph__c>([Select id, Deal__c From EMG_Paragraph__c where Deal__c = :curDeal.Id limit 1]);
//             list_emg_paragraphs = new list<EMG_Paragraph__c>([Select id, Deal__c From EMG_Paragraph__c where Deal__c = :curDeal.Id AND EMG_Last_Updated_By__c = :uContact.Id limit 1]);
         String str_link = '/'+Schema.getGlobalDescribe().get('EMG_Paragraph__c').getDescribe().getKeyPrefix()+'/e?'+'retURL=%2F'+String.valueOf(curDeal.Id)+'&'+'saveURL=%2F'+String.valueOf(curDeal.Id);
         if(url_field_id.length()>0)
             str_link = '/'+Schema.getGlobalDescribe().get('EMG_Paragraph__c').getDescribe().getKeyPrefix()+'/e?'+url_field_id+'='+EncodingUtil.urlEncode( curDeal.Name, 'UTF-8' ).trim()+'&'+url_field_id+'_lkid='+String.valueOf(curDeal.Id)+'&'+'retURL=%2F'+String.valueOf(curDeal.Id)+'&'+'saveURL=%2F'+String.valueOf(curDeal.Id);
         if(list_emg_paragraphs.size()>0)
             str_link = '/'+String.valueOf(list_emg_paragraphs[0].Id)+'/e?'+'retURL=%2F'+String.valueOf(curDeal.Id)+'&'+'saveURL=%2F'+String.valueOf(curDeal.Id);
         return str_link;
      }
      return '';
    }

   WebService static String EMG_Comment_from_Deal(String deal_id_str,String url_field_id) 
   {
    Deal__c curDeal = null;
    if(deal_id_str.length()>14)
         curDeal = [Select id, name, RecordTypeId, WP_Groups_picklist__c From Deal__c where ID = :deal_id_str limit 1];

      Contact uContact = getContact_by_current_User();
      if(curDeal != null)
    {
        list<EMG_Comment__c> list_emg_comments = new list<EMG_Comment__c>();
        if(uContact != null)
            list_emg_comments = new list<EMG_Comment__c>([Select id, Deal__c From EMG_Comment__c where Deal__c = :curDeal.Id limit 1]);
//            list_emg_comments = new list<EMG_Comment__c>([Select id, Deal__c From EMG_Comment__c where Deal__c = :curDeal.Id AND EMG_Last_Updated_By__c = :uContact.Id limit 1]);
        String str_link = '/'+Schema.getGlobalDescribe().get('EMG_Comment__c').getDescribe().getKeyPrefix()+'/e?'+'retURL=%2F'+String.valueOf(curDeal.Id)+'&'+'saveURL=%2F'+String.valueOf(curDeal.Id);
        if(url_field_id.length()>0)
            str_link = '/'+Schema.getGlobalDescribe().get('EMG_Comment__c').getDescribe().getKeyPrefix()+'/e?'+url_field_id+'='+EncodingUtil.urlEncode( curDeal.Name, 'UTF-8' ).trim()+'&'+url_field_id+'_lkid='+String.valueOf(curDeal.Id)+'&'+'retURL=%2F'+String.valueOf(curDeal.Id)+'&'+'saveURL=%2F'+String.valueOf(curDeal.Id);
        if(list_emg_comments.size()>0)
            str_link = '/'+String.valueOf(list_emg_comments[0].Id)+'/e?'+'retURL=%2F'+String.valueOf(curDeal.Id)+'&'+'saveURL=%2F'+String.valueOf(curDeal.Id);
        return str_link;
    }
      return '';
   }
   
   WebService static Integer is_show_EMG_Archive_Page()
   {
      Contact uContact = getContact_by_current_User();
      if(uContact != null && uContact.Archive_Permission__c)
         return 1;
      return 0;
   }

   WebService static Integer set_Deal_SP_DateTimeReq_to_Now(String deal_id_str) 
   {
    Deal__c curDeal = null;
    if(deal_id_str.length()>14)
         curDeal = [Select id, name, SP_DateTimeReq__c, Stage__c,Expense_Code__c,SP_UserEmail__c,WP_Senior_Groups__c,WP_Groups__c, RecordTypeId, WP_Groups_picklist__c From Deal__c where ID = :deal_id_str limit 1];
      //system.debug('##### Deal curDeal '+curDeal);
      if(curDeal != null)
      {
      	curDeal.SP_DateTimeReq__c = Datetime.now();
      	if(curDeal.Expense_Code__c!=null && curDeal.Stage__c!=null && curDeal.SP_UserEmail__c!=null && curDeal.WP_Senior_Groups__c!=null && curDeal.WP_Groups__c!=null) update curDeal;
      	return 1;
      }
      return 0;
   }

   WebService static String set_Deal_Sharepoint(String deal_id_str) 
   {
    Deal__c curDeal = null;
    if(deal_id_str.length()>14)
         curDeal = [Select id, name, SP_DateTimeReq__c, Stage__c,Expense_Code__c,SP_UserEmail__c,WP_Senior_Groups__c,WP_Groups__c, RecordTypeId, WP_Groups_picklist__c From Deal__c where ID = :deal_id_str limit 1];
      if(curDeal != null)
      {
         curDeal.SP_DateTimeReq__c = Datetime.now();
         User curUser = [SELECT id, Email FROM User WHERE id = :Userinfo.getUserId() LIMIT 1];
         curDeal.SP_UserEmail__c = curUser.Email;
         
         String All_WP_Group = '';
         for (Deal_Team__c Deal_Team : [Select Role__c, Id, Employee__r.WP_Group__c, Employee__c, Deal__c From Deal_Team__c where Role__c='Senior Team Member' and  Deal__c=:curDeal.Id])
         {
         	if(!All_WP_Group.contains(Deal_Team.Employee__r.WP_Group__c + ', ') ) All_WP_Group = All_WP_Group + Deal_Team.Employee__r.WP_Group__c + ', ';
         }
         if(All_WP_Group.length()>2){ All_WP_Group=All_WP_Group.substring(0,All_WP_Group.length()-2);}
         if(All_WP_Group.length()>254){ All_WP_Group=All_WP_Group.substring(0,254);}
         curDeal.WP_Senior_Groups__c = All_WP_Group;
//         if(curDeal.Expense_Code__c!=null && curDeal.Stage__c!=null && curDeal.SP_UserEmail__c!=null && curDeal.WP_Senior_Groups__c!=null && curDeal.WP_Groups__c!=null)
//            curDeal.SP_DateTimeReq__c = Datetime.now(); 

         try {
         	update curDeal;
         } catch(System.DmlException ex) {
            return ex.getDmlMessage(0);
         }
      }
      return '';
   }

   // Get Contact (Employee) record ID by current running User ID
   public static ID getContactID_by_current_User() 
   {
      ID uContactId = null;         
      RecordType ContRecTypeId = [Select Id,DeveloperName,sObjectType From RecordType where DeveloperName = 'Employee' and sObjectType = 'Contact' limit 1];
      Contact uCont = [Select id, RecordTypeId, User_ID__c From Contact where RecordTypeId = :ContRecTypeId.Id AND User_ID__c = :UserInfo.getUserId() limit 1];
      if(uCont != null && uCont.RecordTypeId != null && ContRecTypeId != null && uCont.RecordTypeId == ContRecTypeId.Id)
         uContactId = uCont.Id;
      return uContactId;
   }

   // Get Contact (Employee) record by current running User ID
   public static Contact getContact_by_current_User() 
   {
      RecordType ContRecTypeId = [Select Id,DeveloperName,sObjectType From RecordType where DeveloperName = 'Employee' and sObjectType = 'Contact' limit 1];
      Contact uCont = null;
      list<Contact> lCont = new list<Contact>([Select id, RecordTypeId, User_ID__c, Archive_Permission__c, WP_Group__c From Contact where RecordTypeId = :ContRecTypeId.Id AND User_ID__c = :UserInfo.getUserId() limit 1]);
      if(!lCont.isEmpty()) uCont = lCont[0]; 
      return uCont;
   }
   
}