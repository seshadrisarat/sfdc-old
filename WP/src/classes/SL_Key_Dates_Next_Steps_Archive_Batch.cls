/** 
* \author Vladislav Gumenyuk
* \date 03/08/2013
* \see https://silverline.jira.com/browse/WP-68
* \ Archive Page 
* \details An “Archive” button on the page will run the archive process using the values selected from the multi-select picklists. The archive process will find last run dates from Archive_Settings__c. Each row in the list pertains to a WP Group (Name will match WP Group).
* \details  The current archive process will be modified to happen as it does now, except that the dates from custom settings will be used instead of EMG_Paragraph__c .Last_Paragraph_History_Update_c to determine the records to select for archival, as well as the Source and Target Objects (i.e. EMG Comment to EMG Comment History). In addition, archiving will only be done for records modified before End Date. After archiving is completed, the appropriate custom settings will be updated with End Date.
* \
*/
global class SL_Key_Dates_Next_Steps_Archive_Batch implements Database.Batchable<sObject> {
   public String query;
   public Boolean isError = false;

   public list<String> wp_groups_str = new list<String>();
   public Date date_end_archive = Date.today();
   public Datetime datetime_prev_archive = Datetime.now().addYears(-30);//Date.today();
   public Datetime datetime_end_archive = Datetime.now();
   public map<String,Datetime> map_wp_group_datetime_prev_archive = new map<String,Datetime>(); 

   private list<String> emg_param_is_run = new list<String>();
   
//	global  SL_Key_Dates_Next_Steps_Archive_Batch(list<String> wp_groups, Date date_end) 
   global  SL_Key_Dates_Next_Steps_Archive_Batch(list<String> wp_groups, Datetime datetime_end, list<String> emg_param) 
	{
		isError = true;
		wp_groups_str = wp_groups;
      emg_param_is_run = new list<String>();
      for(String emg_str : emg_param)
          if(emg_str != 'SL_Key_Dates_Next_Steps_Archive_Batch')
             emg_param_is_run.add(emg_str);
		//date_end_archive = date_end;
		
		//datetime_end_archive = Datetime.newInstance(date_end_archive.year(),date_end_archive.month(),date_end_archive.day(),Datetime.now().hour(),Datetime.now().minute(),Datetime.now().second());
		datetime_end_archive = datetime_end;
			
		for(Archive_Settings__c cs_Archive_Settings : Archive_Settings__c.getall().values()) 
		{
				datetime_prev_archive = cs_Archive_Settings.Key_Dates_Next_Steps__c;
			if(datetime_prev_archive == null)
				datetime_prev_archive = Datetime.now().addYears(-30);	
			for(Integer i = 0; i < wp_groups_str.size(); i++)
				if(cs_Archive_Settings.Name == wp_groups_str[i]) 
				{
						map_wp_group_datetime_prev_archive.put(wp_groups_str[i],datetime_prev_archive);
				}		 
		}	
		
		for(Integer i = 0; i < wp_groups_str.size(); i++)
			if(!map_wp_group_datetime_prev_archive.containsKey(wp_groups_str[i]))
				map_wp_group_datetime_prev_archive.put(wp_groups_str[i],Datetime.now().addYears(-30));
		
		isError = false;
		if(wp_groups_str.size() == 0) isError = true;
       system.debug('###### 1 isError = '+isError);
	}
	
   global Database.QueryLocator start(Database.BatchableContext BC){
   	   boolean temp_isError = isError;
   	   isError = true;
   	   
       String query_wp_groups = '';
       for(Integer i = 0; i < wp_groups_str.size(); i++)
         query_wp_groups = query_wp_groups+(query_wp_groups.length()>0?'\',\'':'')+wp_groups_str[i];
       query_wp_groups = '(\''+query_wp_groups+'\')';  
       
       String query_by_wp_groups = '';
       String query_by_wp_groups2 = ' AND Is_Archive_Older__c = 1 ';
       for(Integer i = 0; i < wp_groups_str.size(); i++)
       {
//       		String str_query_from_date_for_wp_group = ' ( Deal__r.WP_Groups_picklist__c includes (\''+wp_groups_str[i]+'\') AND EMG_Last_Updated_Date__c > '+map_wp_group_datetime_prev_archive.get(wp_groups_str[i]).format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'')+' ) '; 
         if(datetime_end_archive > map_wp_group_datetime_prev_archive.get(wp_groups_str[i]) )
         {
            String str_prev_datetime_tmp = map_wp_group_datetime_prev_archive.get(wp_groups_str[i]).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
//            query_by_wp_groups2 = ' AND (Key_Dates_Last_Archive_Date__c = null OR (Key_Dates_Last_Archive_Date__c >= '+str_prev_datetime_tmp+' AND Key_Dates_Last_Archive_Date__c <= '+datetime_end_archive.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')+'))';
            String str_query_from_date_for_wp_group = ' ( WP_Groups_picklist__c includes (\''+wp_groups_str[i]+'\') AND Key_Dates_Last_Update_Date__c > '+str_prev_datetime_tmp+' ) '; 
//            String str_query_from_date_for_wp_group = ' ( WP_Groups_picklist__c includes (\''+wp_groups_str[i]+'\') AND Key_Dates_Last_Update_Date__c > '+map_wp_group_datetime_prev_archive.get(wp_groups_str[i]).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')+' ) '; 
            query_by_wp_groups = query_by_wp_groups+(query_by_wp_groups.length()>0?' OR ':' ')+str_query_from_date_for_wp_group;       
            query_by_wp_groups = query_by_wp_groups.trim();       
         }
       }
       if(query_by_wp_groups.length()>0) query_by_wp_groups = ' AND ('+query_by_wp_groups+')';
       else query_by_wp_groups = 'AND Key_Dates_Last_Update_Date__c > '+datetime_end_archive.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
       
       isError = temp_isError;
       
       //query = 'Select ID, EMG_Comment__c, UNIQUE_KEY__c, EMG_Updated_on_behalf_of__c, EMG_Last_Updated_Date__c, EMG_Last_Updated_By__c, Deal__c, Deal__r.WP_Groups_picklist__c From EMG_Comment__c Where EMG_Last_Updated_Date__c <= '+datetime_end_archive.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'')+' AND Deal__r.WP_Groups_picklist__c includes '+query_wp_groups+' AND EMG_Last_Updated_Date__c > '+datetime_prev_archive.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
//       query = 'Select ID, EMG_Comment__c, UNIQUE_KEY__c, EMG_Updated_on_behalf_of__c, EMG_Last_Updated_Date__c, EMG_Last_Updated_By__c, Deal__c, Deal__r.WP_Groups_picklist__c From EMG_Comment__c Where EMG_Last_Updated_Date__c <= '+datetime_end_archive.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'')+query_by_wp_groups;
       query = 'Select ID, Key_Dates_Next_Steps__c, Key_Dates_Last_Update_Date__c, Key_Dates_Last_Update_By__c, WP_Groups_picklist__c From Deal__c Where Key_Dates_Last_Update_Date__c <= '+datetime_end_archive.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')+query_by_wp_groups+query_by_wp_groups2;
       system.debug('###### 2 isError = '+isError);
       system.debug('###### query = '+query);

      return Database.getQueryLocator(query);
   }

   global void execute(
                Database.BatchableContext BC, 
                List<sObject> scope)
   {
   	   boolean temp_isError = isError;
   	   isError = true;
   	
      List<Key_Dates_Next_Steps_History__c> list_insert_Key_Dates_Next_Steps_History = new List<Key_Dates_Next_Steps_History__c>();
      List<Deal__c> list_update_Deal = new List<Deal__c>();
      
      Key_Dates_Next_Steps_History__c eph = new Key_Dates_Next_Steps_History__c();
      Deal__c ep = new Deal__c();  
      for(sObject emg : scope) {
      	ep = (Deal__c)emg;
      	if(ep.Key_Dates_Next_Steps__c !=null && ep.Key_Dates_Next_Steps__c != '')   // don't archive Deal with balank Key_Dates_Next_Steps__c
      	{
      		eph = new Key_Dates_Next_Steps_History__c();
      		eph.Deal__c = ep.Id;
      		eph.Key_Dates_Next_Steps__c = ep.Key_Dates_Next_Steps__c;
      		eph.EMG_Last_Updated_Date__c = ep.Key_Dates_Last_Update_Date__c;
      		eph.EMG_Last_Updated_By__c = ep.Key_Dates_Last_Update_By__c;  
      		list_insert_Key_Dates_Next_Steps_History.add(eph);

            ep.Key_Dates_Last_Archive_Date__c = datetime_end_archive;
            list_update_Deal.add(ep);
      	}
      }
      if(list_insert_Key_Dates_Next_Steps_History.size() > 0) insert list_insert_Key_Dates_Next_Steps_History;
      if(!list_update_Deal.isEmpty()) update list_update_Deal; 

       isError = temp_isError;
       system.debug('###### 3 isError = '+isError);
   }
  
   global void finish(Database.BatchableContext BC){
       system.debug('###### 4 isError = '+isError);
		AsyncApexJob aBatch = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :BC.getJobId() LIMIT 1];
//		if(!isError && aBatch != null && aBatch.Status == 'Completed' && aBatch.NumberOfErrors == 0) 
      if(aBatch != null && aBatch.Status == 'Completed' && aBatch.NumberOfErrors == 0) 
		{
			list<Archive_Settings__c> list_update_cs_Archive_Settings = new list<Archive_Settings__c>();
			set<String> set_wp_groups = new set<String>(); 
			for(Archive_Settings__c cs_Archive_Settings : Archive_Settings__c.getall().values()) 
			{
				for(Integer i = 0; i < wp_groups_str.size(); i++)
					if(cs_Archive_Settings.Name == wp_groups_str[i]) 
					{
						if(datetime_end_archive > map_wp_group_datetime_prev_archive.get(wp_groups_str[i]) )
                     cs_Archive_Settings.Key_Dates_Next_Steps__c = datetime_end_archive;
						set_wp_groups.add(wp_groups_str[i]);
						list_update_cs_Archive_Settings.add(cs_Archive_Settings);	
					}		 
			}

			for(Integer i = 0; i < wp_groups_str.size(); i++)
				if(!set_wp_groups.contains(wp_groups_str[i]))
					list_update_cs_Archive_Settings.add(
					  new Archive_Settings__c(
					  	Name = wp_groups_str[i]
					  	,Key_Dates_Next_Steps__c = datetime_end_archive
					  )
					);

         system.debug('###### list_update_cs_Archive_Settings = '+list_update_cs_Archive_Settings);
			if(list_update_cs_Archive_Settings.size()>0) upsert list_update_cs_Archive_Settings;
		}
	  Id batch_id = null;
      for(String emg_param_str : emg_param_is_run) {
            if(emg_param_str == 'SL_EMS_Paragraph_Archive_Batch')
               batch_id = Database.executeBatch(new SL_EMS_Paragraph_Archive_Batch(wp_groups_str, datetime_end_archive, emg_param_is_run), 1000);
            if(emg_param_str == 'SL_EMS_Comment_Archive_Batch')
               batch_id = Database.executeBatch(new SL_EMS_Comment_Archive_Batch(wp_groups_str, datetime_end_archive, emg_param_is_run), 1000);
            break;   
      }
      Boolean isLastBatch = false;
        	list<EMG_Archiving_Progress__c> EMG_Archiving_Progress = new list<EMG_Archiving_Progress__c>([SELECT Id,Name,Current_Process_ID__c,Current_Process_Number__c,percentComplete__c,Total_Processes__c FROM EMG_Archiving_Progress__c WHERE Name = :UserInfo.getUserId() limit 1]);
        	if(EMG_Archiving_Progress.size()>0) 
        	{
        		Integer percentInitComplete = 100;
            	if(EMG_Archiving_Progress[0].Total_Processes__c != 0){
              		percentInitComplete = ((EMG_Archiving_Progress[0].Current_Process_Number__c / EMG_Archiving_Progress[0].Total_Processes__c) * 100.0).intValue();
                  isLastBatch = (EMG_Archiving_Progress[0].Current_Process_Number__c==EMG_Archiving_Progress[0].Total_Processes__c?true:false);
            	}
        		
        		EMG_Archiving_Progress[0].Current_Process_ID__c = batch_id;
        		EMG_Archiving_Progress[0].Current_Process_Number__c += (EMG_Archiving_Progress[0].Current_Process_Number__c<EMG_Archiving_Progress[0].Total_Processes__c?1:0);
        		EMG_Archiving_Progress[0].percentComplete__c = (Double)percentInitComplete;
            if(isLastBatch) EMG_Archiving_Progress[0].Process_start_time__c = null;
        	} 
        	if(EMG_Archiving_Progress.size()>0)
        		upsert EMG_Archiving_Progress;
        		
         //if(isLastBatch) 
         //{
          try {
            User curUser = [SELECT Id, Name, Email FROM User WHERE id = :Userinfo.getUserId() LIMIT 1];
            String to_email_address = curUser.Email;
            //Messaging.reserveSingleEmailCapacity(2);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {to_email_address}; 
            mail.setToAddresses(toAddresses);
            mail.setSenderDisplayName('Salesforce EMG Archive');
            mail.setBccSender(false);
            mail.setUseSignature(false);
            //mail.setSubject('Archive completed at ' + String.valueOf(Datetime.now()) );
            //mail.setPlainTextBody('EMG Archive batches have been completed at : ' + String.valueOf(Datetime.now()) );
            mail.setSubject('Archiving completed for Key Dates and Next Steps');
            String wp_groups = '';
            for(Integer i = 0; i < wp_groups_str.size(); i++)
               wp_groups=wp_groups+(wp_groups.length()>0?'/':'')+wp_groups_str[i];
            mail.setPlainTextBody('Archiving has been completed for Key Dates and Next Steps for '+wp_groups+' Group(s).');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
          } catch(Exception ex) {}  
         //}
   }

}