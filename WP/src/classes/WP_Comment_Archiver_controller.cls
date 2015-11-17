public with sharing class WP_Comment_Archiver_controller {
    public integer iParaHisRecs=0;
   public integer NumberOfParagraphHistories { get { return iParaHisRecs; } }
    
   public boolean ActuallyPostData { get {  if(ApexPages.currentPage().getparameters().get('post') != null)  return true;  else return false;} }
   public boolean OverrideSpecified { get { if (GroupOverride!=null && GroupOverride!='') return true; else return false; } }
/*
   public list<EMG_Paragraph_History__c> list_insert_EMG_Paragraph_History = null;//new list<EMG_Paragraph_History__c>();
                  list<EMG_Paragraph__c> list_update_EMG_Paragraph = null;//new list<EMG_Paragraph__c>();
   
   public list<EMG_Paragraph__c>  ListOfUpdatedParagraphs {
        get { 
        if ( list_update_EMG_Paragraph==null) {

            System.Debug('-----------> CONSTRUCTING THE LIST');
            iParaHisRecs=0;        
                  list_insert_EMG_Paragraph_History = new list<EMG_Paragraph_History__c>();
                  set<ID> set_deal_ids = new set<ID>(); 
                  list_update_EMG_Paragraph = new list<EMG_Paragraph__c>();
                  map<ID,EMG_Paragraph__c> mapDealID2EMGParag = new map<ID,EMG_Paragraph__c>();
                  list<EMG_Paragraph__c> lst1 = null;
                  string soqlx = 'Select WP_Groups__c, UNIQUE_KEY__c, Last_Paragraph_History_Update__c, EMG_Updated_on_behalf_of__c, Id, EMG_Paragraph__c, EMG_Last_Updated_Date__c, EMG_Last_Updated_By__r.Name, EMG_Last_Updated_By__c, EMG_Category__c, Deal__r.Name, Deal__r.WP_Groups__c, Deal__c From EMG_Paragraph__c where WP_Groups__c like   \'%' + GroupToUse  + '%\' and Deal__c <> \'\' and (DIF_Last_Upd_Date_and_History__c = 1 OR Last_Paragraph_History_Update__c = NULL OR EMG_Last_Updated_Date__c = NULL) order by Deal__r.Name limit 2000';
                  lst1=Database.query(soqlx);
        
              for(EMG_Paragraph__c item:lst1)
              {
              
//              if(mapDealID2EMGParag.size()<3)
if (item.EMG_Paragraph__c != null && item.EMG_Paragraph__c != '')
                {
                mapDealID2EMGParag.put(item.Deal__c, item);
                set_deal_ids.add(item.Deal__c);
                }      
              }
        
        System.Debug ('------- between passes, size of set_deal_ids is ' + set_deal_ids.size());
      if(set_deal_ids!=null && set_deal_ids.size()>0)
      {
          //list<EMG_Paragraph_History__c> list_insert_EMG_Paragraph_History = new list<EMG_Paragraph_History__c>();

          EMG_Paragraph__c ep = new EMG_Paragraph__c();
          EMG_Paragraph_History__c eph = new EMG_Paragraph_History__c(); 
          for(ID deal_id : set_deal_ids)
          {
            if(mapDealID2EMGParag.containsKey(deal_id))
            {
               ep = mapDealID2EMGParag.get(deal_id);
               eph = new EMG_Paragraph_History__c();
               eph.Deal__c = deal_id;
               eph.EMG_Paragraph__c = ep.EMG_Paragraph__c;
               eph.EMG_Last_Updated_Date__c = ep.EMG_Last_Updated_Date__c;
               eph.EMG_Last_Updated_By_Contact__c = ep.EMG_Last_Updated_By__c;
           if (ActuallyPostData)    
               ep.Last_Paragraph_History_Update__c = ep.EMG_Last_Updated_Date__c;
               
                System.Debug('--------> before add to list, size is ' + list_insert_EMG_Paragraph_History.size());

               list_insert_EMG_Paragraph_History.add(eph);
                 System.Debug('--------> added to list, size is ' + list_insert_EMG_Paragraph_History.size());
                iParaHisRecs++;
               list_update_EMG_Paragraph.add(ep);
            }
         }
         System.Debug(' ------  about to actually post - var is ' + ActuallyPostData);
        if (ActuallyPostData) {
                 System.Debug(' ------------ in the POST DATA section - var is ' + ActuallyPostData);
System.Debug('--------------- insert size is '+list_insert_EMG_Paragraph_History.size());
System.Debug('--------------- update size is ' + list_update_EMG_Paragraph.size());
         if(list_insert_EMG_Paragraph_History.size() > 0) { insert list_insert_EMG_Paragraph_History;} 
         if(list_update_EMG_Paragraph.size() > 0) { update list_update_EMG_Paragraph;} 
       
          }
     else
      {
     System.Debug('-------------NOT actually posting data');
       } 
         //  return list_insert_EMG_Paragraph_History.size();
      }        
     }
     System.Debug('--------> at exit, size is ' + list_update_EMG_Paragraph.size());
    return list_update_EMG_Paragraph;
        
    
    }
    }

*/






    public string sUserId = ''; 
    public string sGroupOverride='';



    public boolean ShowPreview { get {  if(ApexPages.currentPage().getparameters().get('preview') != null)  return true;  else return false;} }

    public string GroupToUse { get {  string sG = WPGroupForThisUser; if (GroupOverride!=null && GroupOverride!='') sG = GroupOverride; return sG; } }
    public String WPGroupForThisUser { get {  Contact ct = [Select c.Name, c.WP_Group__c, c.Id from Contact c where User_ID__c = :UserId limit 1]; string sGroup = 'unspecified'; if (ct != null && ct.WP_Group__c!=null && ct.WP_Group__c!= '') sGroup = ct.WP_Group__c; return sGroup; }}
    public string UserId { get { if (sUserId == null || sUserId=='') {   sUserId=UserInfo.getUserId(); }  return sUserId; } }
    public string GroupOverride { get { if(ApexPages.currentPage().getparameters().get('groupoverride') != null) { sGroupOverride = ApexPages.currentPage().getparameters().get('groupoverride');} return sGroupOverride ; } }



}