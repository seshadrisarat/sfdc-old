/** 
* \author Vlad Gumenyuk 
* \date 10/11/2012
* \see https://silverline.jira.com/browse/WP-17
* \see https://silverline.jira.com/browse/WP-43
* \ "Run EMG Paragraph History Update" Custom Button 
* \details Additional 
* \ Custom button on the EMG Paragraph History Tab Views (https://na9.salesforce.com/a0Q?fcf=00BE0000002wX6h) that will call a Visualforce function to select "EMG Paragraph", "EMG Last Updated By" and "EMG Last Updated Date" fields from ALL open deals (with Deal__c.ISOPENSTAGE = 1) and insert them into the "EMG Paragraph History" object, BUT only if the EMG Paragraph has changed since the last run.
*/
global class SL_wsdl_EMG_Paragraph_History
{

// WP-70
/* */
    WebService static integer EMG_Paragraph_from_Deal()
    {
    return EMG_Paragraph_from_Deal_for_Group_and_deal('','');
    }

    WebService static integer EMG_Paragraph_from_Deal_for_Group_and_deal(string sGroup, string sDeal)
    {
        
        System.Debug('-------START------->deal is ' + sDeal + ' and group is ' + sGroup);
    
      set<ID> set_deal_ids = new set<ID>(); 
      list<EMG_Paragraph__c> list_update_EMG_Paragraph = new list<EMG_Paragraph__c>();
      map<ID,EMG_Paragraph__c> mapDealID2EMGParag = new map<ID,EMG_Paragraph__c>();
      list<EMG_Paragraph__c> lst1 = null;
      
      if (sGroup=='' && sDeal=='')
            { 
    System.Debug('------>executing without like');
      
// WP-70
////      lst1=[Select WP_Groups__c, UNIQUE_KEY__c, Last_Paragraph_History_Update__c, EMG_Updated_on_behalf_of__c, Id, EMG_Paragraph__c, EMG_Last_Updated_Date__c, EMG_Last_Updated_By__c, EMG_Category__c, Deal__c From EMG_Paragraph__c where Deal__c <> '' and (DIF_Last_Upd_Date_and_History__c = 1 OR Last_Paragraph_History_Update__c = NULL OR EMG_Last_Updated_Date__c = NULL) limit 2000];
      lst1=[Select UNIQUE_KEY__c, EMG_Updated_on_behalf_of__c, Id, EMG_Paragraph__c, EMG_Last_Updated_Date__c, EMG_Last_Updated_By__c, Deal__c From EMG_Paragraph__c where Deal__c <> '' and (EMG_Last_Updated_Date__c = NULL) limit 2000];
            }
      else
      {
            System.Debug('---------> executing WITH like');

        string soqlx = 'Select UNIQUE_KEY__c, Last_Paragraph_History_Update__c, EMG_Updated_on_behalf_of__c, Id, EMG_Paragraph__c, EMG_Last_Updated_Date__c, EMG_Last_Updated_By__c, EMG_Category__c, Deal__c From EMG_Paragraph__c where Deal__r.WP_Groups__c like   \'%' + sGroup  + '%\' ';
        if (sDeal=='')
        soqlx = soqlx + ' and Deal__c <> \'\' and (Last_Paragraph_History_Update__c = NULL OR EMG_Last_Updated_Date__c = NULL) limit 2000';
        else
        soqlx = soqlx + ' and Deal__c = \'' + sDeal + '\' and (Last_Paragraph_History_Update__c = NULL OR EMG_Last_Updated_Date__c = NULL) limit 2000';
        System.Debug('-----soql:');
        System.Debug(soqlx);
      lst1=Database.query(soqlx);// [Select UNIQUE_KEY__c, Last_Paragraph_History_Update__c, EMG_Updated_on_behalf_of__c, Id, EMG_Paragraph__c, EMG_Last_Updated_Date__c, EMG_Last_Updated_By__c, EMG_Category__c, Deal__c From EMG_Paragraph__c where WP_Groups__c like '% Deal__c <> '' and (DIF_Last_Upd_Date_and_History__c = 1 OR Last_Paragraph_History_Update__c = NULL OR EMG_Last_Updated_Date__c = NULL) limit 2000];
}
        
    //  for(EMG_Paragraph__c item:[Select UNIQUE_KEY__c, Last_Paragraph_History_Update__c, EMG_Updated_on_behalf_of__c, Id, EMG_Paragraph__c, EMG_Last_Updated_Date__c, EMG_Last_Updated_By__c, EMG_Category__c, Deal__c From EMG_Paragraph__c where Deal__c <> '' and (DIF_Last_Upd_Date_and_History__c = 1 OR Last_Paragraph_History_Update__c = NULL OR EMG_Last_Updated_Date__c = NULL) limit 2000])
      for(EMG_Paragraph__c item:lst1)//[Select UNIQUE_KEY__c, Last_Paragraph_History_Update__c, EMG_Updated_on_behalf_of__c, Id, EMG_Paragraph__c, EMG_Last_Updated_Date__c, EMG_Last_Updated_By__c, EMG_Category__c, Deal__c From EMG_Paragraph__c where Deal__c <> '' and ( Last_Paragraph_History_Update__c = NULL OR EMG_Last_Updated_Date__c = NULL) limit 2000])
      
      {
        System.Debug('--------list size is------------>');
System.Debug(lst1.size());

        
        if(!Test.isRunningTest() || mapDealID2EMGParag.size()<3)
        {
            if (item.EMG_Paragraph__c !=null && item.EMG_Paragraph__c != '')  // don't archive balank paragraphs
            mapDealID2EMGParag.put(item.Deal__c, item);
            set_deal_ids.add(item.Deal__c);
        }
      }

      if(set_deal_ids!=null && set_deal_ids.size()>0)
      {
          list<EMG_Paragraph_History__c> list_insert_EMG_Paragraph_History = new list<EMG_Paragraph_History__c>();

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
               
//               if(ep.EMG_Updated_on_behalf_of__c != null) {
//                 eph.EMG_Last_Updated_By_Contact__c = ep.EMG_Updated_on_behalf_of__c;
//               } else  
//                 eph.EMG_Last_Updated_By_Contact__c = ep.EMG_Last_Updated_By__c;
//               ep.EMG_Updated_on_behalf_of__c = null;
               eph.EMG_Last_Updated_By_Contact__c = ep.EMG_Last_Updated_By__c;
               
// WP-70
////               ep.Last_Paragraph_History_Update__c = ep.EMG_Last_Updated_Date__c;
               
               list_insert_EMG_Paragraph_History.add(eph);
               list_update_EMG_Paragraph.add(ep);
            }
         }
         if(list_insert_EMG_Paragraph_History.size() > 0) { insert list_insert_EMG_Paragraph_History;} 
         if(list_update_EMG_Paragraph.size() > 0) { update list_update_EMG_Paragraph;} 

         return list_insert_EMG_Paragraph_History.size();
      }
        
        return 0;
    }
/* */    
}