trigger WP_EMGComment on EMG_Comment__c (after delete, after insert, after undelete, 
after update) {
string sEventType = '';
  EMG_Comment__c[] recs = null;
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
  List<WP_Synch_Log__c> list_insert_wpsl = new List<WP_Synch_Log__c>();
  for (EMG_Comment__c recX : recs) {
    boolean bFire=true;
    if (sEventType=='UPD')// we don't fire trigger on updates to deal guid__c
    {
      //bFire=true;
      string dlGuidNew = recX.Deal__c != null ? recX.Deal__r.GUID__c : '' ;
      EMG_Comment__c foOld = Trigger.oldMap.get(recX.ID);
      string dlGuidOld = foOld!=null &&  foOld.Deal__c != null ? foOld.Deal__r.GUID__c : '' ;
      System.debug('----->>> emg comment update -- new deal guid:' + dlGuidNew);
      System.debug('----->>> emg comment update old deal guid:' + dlGuidOld);
      //System.debug('bFire:' + bFire);
      //if (foOld.Deal__c != recX.Deal__c ) bFire=true;
      if (
      ( String.isBlank( dlGuidOld  ) && !String.isBlank(dlGuidNew)  )
      ||
      ( !String.isBlank( dlGuidOld  ) && String.isBlank(dlGuidNew)  )
      ||
      ( !String.isBlank( dlGuidOld  ) && !String.isBlank(dlGuidNew) 
        &&
        dlGuidOld != dlGuidNew
       )
      )
      bFire = false;
      
    }
    if (bFire){
          WP_Synch_Log__c wpsl = WP_handler_Synch_Log.CreateSynchLogEvent(sEventType, 'EMG_Comment', String.valueOf(recX.Id), String.valueOf( recX.Deal__c) ); 
          if(wpsl!=null) list_insert_wpsl.add(wpsl);
    }
    }
    if(list_insert_wpsl.size()>0)
      insert list_insert_wpsl;
}