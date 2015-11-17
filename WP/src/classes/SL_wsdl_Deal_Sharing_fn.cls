/** 
* \author Vlad Gumenyuk 
* \date 01/30/2013
* \see https://silverline.jira.com/browse/WP-64
* \  Create a new "Deal Sharing" Visualforce Page for custom Sharing of the Deal only to users. 
* \  Sharing runs only for users from Deal_Team and Deal.OwnerId
*/
global class SL_wsdl_Deal_Sharing_fn
{
   WebService static String is_Share_Deal(String Deal_Id_str)
   {
   	 List<Deal__c> list_deal = new List<Deal__c>(); 
       list_deal = Database.query('SELECT d.id,d.Name,d.OwnerId FROM Deal__c d WHERE d.ID = \''+Deal_Id_str+'\' LIMIT 1');
       if(list_deal.size()>0) {
         Id Deal_Id = list_deal[0].Id;

           set<Id> set_user_ids = new set<Id>();
           set_user_ids.add(list_deal[0].OwnerId);

         for(Deal_Team__c item : [SELECT ID,Deal__c,Employee__c,Employee__r.LastName,Employee__r.Initials__c, Employee__r.Status__c,Employee__r.User_ID__c, Employee__r.FirstName FROM Deal_Team__c WHERE Deal__c = :Deal_Id limit 100])
         {
            if(item.Employee__c!=null && item.Employee__r.User_ID__c!=null)
                  set_user_ids.add(item.Employee__r.User_ID__c);
         }
         if(set_user_ids.contains(UserInfo.getUserId()))
            return '1';
       }     
       return '0';
   }

}