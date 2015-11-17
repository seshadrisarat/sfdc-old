/** 
* \author Vlad Gumenyuk 
* \date 11/02/2012
* \see https://silverline.jira.com/browse/WP-12
* \ "Clone" Custom Button to call a VF class that will copy Deal Detail Info and selected related list data 
*/
global class SL_wsdl_Deal_clone_fn
{
    WebService static String Clone_Deal(String Deal_Id_str)
    {

     // setup the save point for rollback
        Savepoint sp = Database.setSavepoint();
         
        String queryFields = '';
        String tmpFldName = '';
        
        for( Schema.SObjectField f : SObjectType.Deal__c.fields.getMap().values())
        {
            tmpFldName = ''+f.getDescribe().getSObjectField();
            if(tmpFldName.length()<5 || tmpFldName.substring(0, 4)!='Bid_') queryFields += ', ' + tmpFldName;
        }
     
     //List<Deal__c> list_deal_old = Database.query('SELECT d.Year_Ended__c, d.WP_Ownership__c, d.WP_Investment__c, d.WP_Groups__c, d.Type__c, d.Target_WP_Sub_Group__c, d.Target_Sectors_text__c, d.Target_Sectors__c, d.Target_Geography__c, d.SystemModstamp, d.Stage__c, d.Records_Management_Date__c, d.RecordTypeId, d.Project_Name__c, d.Prior_Record_Type__c, d.Portfolio_Company__c, d.Period_Ended__c, d.OwnerId, d.Net_Income__c, d.Name, d.Line_of_Equity_Remaining_Amount__c, d.Line_of_Equity_Amount__c, d.LastModifiedDate, d.LastModifiedById, d.LastActivityDate, d.Key_Dates_Next_Steps__c, d.IsDeleted, d.Id, d.ISOPENSTAGE__c, d.IM_Received__c, d.Grills_Value__c, d.Grills_Rank__c, d.Expense_Code__c, d.Equity_Value_Low_MM__c, d.Equity_Value_High__c, d.Enterprise_Value_Low_MM__c, d.Enterprise_Value_High__c, d.EMG_Paragraph__c, d.EMG_Last_Updated_Date__c, d.EMG_Last_Updated_By__c, d.EBITDA__c, d.Dormant_Deal__c, d.Description__c, d.Deal_Source__c, d.Deal_Source_Contact__c, d.Deal_Folder__c, d.Dead_Deal_Reason__c, d.Dead_Deal_Notes__c, d.Date_of_Record__c, d.Date_Received__c, d.CurrencyIsoCode, d.CreatedDate, d.CreatedById, d.Cost__c, d.Company__c, d.Circulate_to_EMG__c, d.Carrying_Value_MM__c, d.CA_Signed__c, d.CA_Link__c FROM Deal__c d WHERE d.ID = \''+Deal_Id_str+'\' LIMIT 1');
     List<Deal__c> list_deal_old = Database.query('SELECT '+(queryFields.substring(1))+' FROM Deal__c WHERE ID = \''+Deal_Id_str+'\' LIMIT 1');
     Id Deal_Id = list_deal_old[0].Id;
     List<Deal__c> list_deal = list_deal_old.deepClone();
     list_deal[0].Name = 'Clone of '+list_deal_old[0].Name;
     list_deal[0].Project_Name__c = '';
     list_deal[0].Expense_Code__c = '';
     list_deal[0].GUID__c = '';
     list_deal[0].SP_DateTimeReq__c = null;
     list_deal[0].Deal_Folder__c = '';

    try
    {
         insert list_deal;
    
         List<Deal_Team__c> list_deal_team_old = [Select d.Role__c, d.Name, d.Id, d.Employee__c, d.Deal__c, d.CurrencyIsoCode, d.Company_Team_Member__c From Deal_Team__c d WHERE d.Deal__c = :Deal_Id];
         List<Deal_Team__c> list_deal_team = list_deal_team_old.deepClone();
         for(Deal_Team__c deal_team : list_deal_team) {
           deal_team.Deal__c = list_deal[0].Id;
         }
         if(list_deal_team.size()>0)
           insert list_deal_team;
    
         return String.valueOf(list_deal[0].Id);
     } catch (Exception e) {
         // roll everything back in case of error
         Database.rollback(sp);
         ApexPages.addMessages(e);
         return '';
     }   
   }

}