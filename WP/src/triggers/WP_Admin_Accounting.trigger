trigger WP_Admin_Accounting on Administrative_Accounting__c (after delete, after insert, after undelete, 
after update) {
string sEventType = '';
   Administrative_Accounting__c[] recs = null;
   if (Trigger.isDelete) {
      sEventType='DEL'; 
      recs = trigger.old;
   }  
   else if (Trigger.isUpdate) 
      { 
         sEventType='UPD'; 
         recs = trigger.new;
      } 
      else if (Trigger.IsInsert) 
      {
         sEventType = 'INS';
         recs = trigger.new; 
      }
      else if (Trigger.isUnDelete) 
         {
            sEventType='INS';
            recs = trigger.new;
         }
if (recs.size()==1) {         
   List<WP_Synch_Log__c> list_insert_wpsl = new List<WP_Synch_Log__c>();
   for (Administrative_Accounting__c recX : recs) {
         System.debug('--------------------------->>> acct rec:' + recX.Id);
         Id idCoInQuestion = null;
         Administrative_Accounting__c acctRec=recX;
         if (sEventType=='DEL') {
            System.debug('-------------------->>> getting OLD acct rec:' + acctRec.Id);
            acctRec = Trigger.oldMap.get(recX.ID);
            
         }
         if (acctRec.Portfolio_Company__c != null ) {
            System.debug('-------------------->>> acctrec co id is :' + acctRec.Portfolio_Company__c);
            List<Deal__c> deals = [select id from Deal__c where Company__c  = :acctRec.Portfolio_Company__c];
            for (Deal__c deal : deals)
            {     
            System.debug('------------------->>> deal rec:' + deal.Id); 
            WP_Synch_Log__c wpsl = new WP_Synch_Log__c();
            if (sEventType=='DEL') {
               string s = ''; 
               // if (deal.GUID__c!=null) s = String.valueOf(deal.GUID__c);
            wpsl = WP_handler_Synch_Log.CreateSynchLogEvent(sEventType, 'AdminAcctg', String.valueOf(acctRec.Id),String.valueOf(deal.Id), s );
            }
            else
            wpsl = WP_handler_Synch_Log.CreateSynchLogEvent(sEventType, 'AdminAcctg', String.valueOf(acctRec.Id),String.valueOf(deal.Id) );
            if(wpsl!=null) list_insert_wpsl.add(wpsl);
            }
         }
         else 
         {
            System.debug('-------------------->>> acctrec co id is null');
         
         }
    }
    if(list_insert_wpsl.size()>0)
      insert list_insert_wpsl;
}
}