/** 
* \author Vladislav Gumenyuk
* \date 03/06/2013
* \see https://silverline.jira.com/browse/WP-68
* \see https://silverline.jira.com/browse/WP-85
* \ Archive Page 
* \details 
* \Archive Screen
* \A new Visualforce Page will be built to run the archive processes for each specific WP Group (i.e. TMT) and Note (i.e. EMG Paragraph) selected. The page will have two multi-select lists:
* \1) WP Group(s) – Page will get values dynamically from Deal.WP_Groups_picklist__c (defined picklist values).
* \2) EMG Note – Preset Values: EMG Comment, EMG Paragraph, Key Dates / Next Steps
* \
* \There will also be a Date field called End Date. This field will be defaulted to today’s date.
* \
* \An “Archive” button on the page will run the archive process using the values selected from the multi-select picklists. The archive process will find last run dates from Archive_Settings__c. Each row in the list pertains to a WP Group (Name will match WP Group).
* \
* \The current archive process will be modified to happen as it does now, except that the dates from custom settings will be used instead of EMG_Paragraph__c .Last_Paragraph_History_Update_c to determine the records to select for archival, as well as the Source and Target Objects (i.e. EMG Comment to EMG Comment History). In addition, archiving will only be done for records modified before End Date. After archiving is completed, the appropriate custom settings will be updated with End Date.
* \
* \Page security:
* \Access and usability of this page will be controlled in the code. In order to view the page, users most have the Archive Permission (new field) checkbox checked on their Employee Contact record. Users attempting to access the page without this permission will be notified that they do not have permissions to view the page.
* \Additionally, users will be limited as to what Groups they can archive. If the User has the WP EMG Group SSO or WP EMG Group profile, the picklist will show all groups. If not, they will only see picklist values for their Group (from their Employee Contact record).
* \
*/
public without sharing class SL_ctrl_EMG_Archive {
   public SelectOption[] input_list {get;set;}
   public SelectOption[] output_list {get;set;}
   
   public Boolean note_emg_comment {get;set;}
   public Boolean note_emg_paragraph {get;set;}
   public Boolean note_key_dates_next_steps {get;set;}

   public Boolean isProcessRun {get;set;}
   
   public String end_date {get;set;}
   // variable for SL_LIB46_DatePicker
   public String end_datetime {get;set;}
   
   public String sHiddKeys {get;set;}
   
   public SL_ctrl_LIB20_BaseParam BaseParam {get;set;} 
   list<String> wp_groups_str = new list<String>();
   
   private String strWPGroup = ''; 

   public list<String> sel_values = new list<String>();

   Datetime datetime_end_archive2 = Datetime.now();
   map<String,Datetime> map_wp_group_datetime_prev_archive = new map<String,Datetime>(); 
   map<String,map<String,Datetime>> map_archive_type_wp_group_datetime_prev_archive = new map<String,map<String,Datetime>>(); 

	public SL_ctrl_EMG_Archive()
	{
		iArchiveProgress = 0;
		isProcessRun = false;
		
		note_emg_comment = true;
		note_emg_paragraph = true;
		note_key_dates_next_steps = true;
		
        input_list = new List<SelectOption>();
        output_list = new List<SelectOption>();
        
        sHiddKeys = '';
        wp_groups_str = new list<String>();
        BaseParam = new SL_ctrl_LIB20_BaseParam();
        
        strWPGroup = '';
        
        end_date = '';
        end_datetime = '';
        end_date = String.valueOf(Date.today());

        end_datetime = String.valueOf(Datetime.now());
        
        Contact uContact = null; 
        uContact =SL_wsdl_EMG.getContact_by_current_User();
        if(uContact == null) 
        {
        	   ApexPages.Message myMsg1 = new ApexPages.Message(ApexPages.Severity.FATAL,'Your User does not have an Employee record. Please contact your System Administrator.');
        	   ApexPages.addMessage(myMsg1);
        	   // go away from page (bad user without contact)
        	   //PageReference page_ref = new PageReference('/');
            //page_ref.setRedirect(true);
         } else 
        {
        	   if(!uContact.Archive_Permission__c) {
        	      ApexPages.Message myMsg1 = new ApexPages.Message(ApexPages.Severity.FATAL,'Your User\'s Employee record does not have “Archive Permission” set. Please contact your System Administrator.');
               ApexPages.addMessage(myMsg1);
        	   }
        	User curUser = [SELECT u.id,u.Profile.Name, u.ProfileId, u.Name FROM User u WHERE u.ID = :UserInfo.getUserId() Limit 1];
        	if(curUser.Profile.Name == 'System Administrator' || curUser.Profile.Name == 'WP EMG Group SSO' || curUser.Profile.Name == 'WP EMG Group') 
         {
               Schema.DescribeFieldResult fieldResult = Deal__c.WP_Groups_picklist__c.getDescribe();
               List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
               for( Schema.PicklistEntry f : ple)
               {
                  input_list.add(new SelectOption(f.getLabel(), f.getValue()));
               }       
           
        	} else {
                  input_list.add(new SelectOption(uContact.WP_Group__c , uContact.WP_Group__c));
                  strWPGroup = uContact.WP_Group__c;
        	}

        }
        
	}
	
   public SL_ctrl_LIB20_BaseParam getBaseParam() {
      if(BaseParam == null)
        BaseParam = new SL_ctrl_LIB20_BaseParam();
      return BaseParam;
   }
	
	public PageReference RunArchiveProcess()
	{
        // WP-92 - Add in a lockout process so the user can not run the batch more than once. (custom setting EMG_Archiving_Progress__c.Process_start_time__c)
        list<EMG_Archiving_Progress__c> EMG_Archiving_Progress0 = new list<EMG_Archiving_Progress__c>([SELECT Id,Name,Process_start_time__c,Current_Process_ID__c,Current_Process_Number__c,percentComplete__c,Total_Processes__c FROM EMG_Archiving_Progress__c WHERE Name = :UserInfo.getUserId()]);
        if(EMG_Archiving_Progress0.size()>0 && EMG_Archiving_Progress0[0].Process_start_time__c!=null && EMG_Archiving_Progress0[0].Process_start_time__c.addHours(1) > Datetime.now() )
            return null;
		
         isProcessRun = true;
         		
         sel_values = new list<String>();
         
         wp_groups_str = new list<String>();
         
         if(strWPGroup.length() > 0) {
            BaseParam.sHiddenKeys = strWPGroup; 
         }
         
         sHiddKeys = BaseParam.sHiddenKeys;
         wp_groups_str = sHiddKeys.split(';', 0);
         for(Integer i=0; i < wp_groups_str.size() ; i++) 
         {
            if(wp_groups_str[i].trim().length()<2) wp_groups_str.remove(i);
         }
         
         Datetime dtm_end = Datetime.now();
         try{ 
            dtm_end = Datetime.valueOf(end_datetime);
         } catch (Exception ex2) {
            ApexPages.Message myMsg3 = new ApexPages.Message(ApexPages.Severity.FATAL,'Please enter an End DateTime');
            ApexPages.addMessage(myMsg3);
         }
         end_datetime = String.valueOf(dtm_end);
         datetime_end_archive2 = dtm_end; 

         // Setting of archive types
         list<String> emg_param_is_run = new list<String>();  
         if(note_emg_paragraph)
            emg_param_is_run.add('SL_EMS_Paragraph_Archive_Batch');
         if(note_emg_comment)
            emg_param_is_run.add('SL_EMS_Comment_Archive_Batch');
         if(note_key_dates_next_steps)   
            emg_param_is_run.add('SL_Key_Dates_Next_Steps_Archive_Batch');
            
         iArchiveProgress = 0;
         

       // Setting previous datetime of archive from the Archive_Settings__c custom setting
       Datetime datetime_prev_archive = null; 
       for(String emg_param_str : emg_param_is_run) {
      	map_wp_group_datetime_prev_archive = new map<String,Datetime>();
         for(Integer i = 0; i < wp_groups_str.size(); i++)
            if(!map_wp_group_datetime_prev_archive.containsKey(wp_groups_str[i]))
               map_wp_group_datetime_prev_archive.put(wp_groups_str[i],Datetime.now().addYears(-30));

         for(Archive_Settings__c cs_Archive_Settings : Archive_Settings__c.getall().values()) 
         {
         	datetime_prev_archive = Datetime.now().addYears(-30);
            if(emg_param_str == 'SL_EMS_Paragraph_Archive_Batch')
               datetime_prev_archive = cs_Archive_Settings.EMG_Paragraph__c;
            if(emg_param_str == 'SL_EMS_Comment_Archive_Batch')
               datetime_prev_archive = cs_Archive_Settings.EMG_Comment__c;
            if(emg_param_str == 'SL_Key_Dates_Next_Steps_Archive_Batch')
               datetime_prev_archive = cs_Archive_Settings.Key_Dates_Next_Steps__c;
            if(datetime_prev_archive == null)
               datetime_prev_archive = Datetime.now().addYears(-30); 
            for(Integer i = 0; i < wp_groups_str.size(); i++)
               if(cs_Archive_Settings.Name == wp_groups_str[i]) 
               {
                     map_wp_group_datetime_prev_archive.put(wp_groups_str[i],datetime_prev_archive);
               }      
         }  
         map_archive_type_wp_group_datetime_prev_archive.put(emg_param_str,map_wp_group_datetime_prev_archive);
       }

       iArchiveProgress = 0;
       
       // !!! Use this block with batches in case of large amount of data
       // Running of the batch archiving processes
		 Id batch_id = null;

       iArchiveProgress = 100;
         for(String emg_param_str : emg_param_is_run) {
         	iArchiveProgress = 0;
         	
            if(emg_param_str == 'SL_EMS_Paragraph_Archive_Batch')
               batch_id = Database.executeBatch(new SL_EMS_Paragraph_Archive_Batch(wp_groups_str, dtm_end, emg_param_is_run), 1000);
            if(emg_param_str == 'SL_EMS_Comment_Archive_Batch')
               batch_id = Database.executeBatch(new SL_EMS_Comment_Archive_Batch(wp_groups_str, dtm_end, emg_param_is_run), 1000);
            if(emg_param_str == 'SL_Key_Dates_Next_Steps_Archive_Batch')
               batch_id = Database.executeBatch(new SL_Key_Dates_Next_Steps_Archive_Batch(wp_groups_str, dtm_end, emg_param_is_run), 1000);
            break;   
         }
            
        // WP-85 - progress bar custom setting EMG_Archiving_Progress__c
        list<EMG_Archiving_Progress__c> EMG_Archiving_Progress = new list<EMG_Archiving_Progress__c>([SELECT Id,Name,Process_start_time__c,Current_Process_ID__c,Current_Process_Number__c,percentComplete__c,Total_Processes__c FROM EMG_Archiving_Progress__c WHERE Name = :UserInfo.getUserId()]);
        if(EMG_Archiving_Progress.size()==0) 
        {
        	EMG_Archiving_Progress__c eap = new EMG_Archiving_Progress__c(
        		 Name = String.valueOf(UserInfo.getUserId()) 
        		,Current_Process_ID__c = batch_id
        		,Current_Process_Number__c = (emg_param_is_run.size()>0?1:0)
        		,percentComplete__c = 0.0
        		,Total_Processes__c = emg_param_is_run.size()
        		,Process_start_time__c = Datetime.now()
        	);
        	EMG_Archiving_Progress.add(eap);
        } else
        {
        		EMG_Archiving_Progress[0].Name = String.valueOf(UserInfo.getUserId()); 
        		EMG_Archiving_Progress[0].Current_Process_ID__c = batch_id;
        		EMG_Archiving_Progress[0].Current_Process_Number__c = (emg_param_is_run.size()>0?1:0);
        		EMG_Archiving_Progress[0].percentComplete__c = 0.0;
        		EMG_Archiving_Progress[0].Total_Processes__c = emg_param_is_run.size();
        		EMG_Archiving_Progress[0].Process_start_time__c = Datetime.now();
        } 
        if(EMG_Archiving_Progress.size()>0)
        	upsert EMG_Archiving_Progress;

/*     
       // !!! DO NOT ERASE THIS COMMENTED BLOCK! IT'S NOT A TRASH!
       
       // !!! Use this block of archiving processes in the page controller in case of small amount of data (It works faster)
       // Running of archiving processes in the page controller  
         iArchiveProgress = 100;
         for(String emg_param_str : emg_param_is_run) {
            iArchiveProgress = 0;
            if(emg_param_str == 'SL_EMS_Paragraph_Archive_Batch')
               executeArchive_EMG_Paragraph();
            if(emg_param_str == 'SL_EMS_Comment_Archive_Batch')
               executeArchive_EMG_Comment();
            if(emg_param_str == 'SL_Key_Dates_Next_Steps_Archive_Batch')
               executeArchive_Key_Dates_Next_Steps();
         }   
*/        

        return null;
	}
	

   // Archive EMG Comment in the page controller
	private void executeArchive_EMG_Comment()
	{
      if(map_archive_type_wp_group_datetime_prev_archive!=null && map_archive_type_wp_group_datetime_prev_archive.containsKey('SL_EMS_Comment_Archive_Batch'))
      {
       map_wp_group_datetime_prev_archive = map_archive_type_wp_group_datetime_prev_archive.get('SL_EMS_Comment_Archive_Batch');
       system.debug('###### map_wp_group_datetime_prev_archive 1 '+map_wp_group_datetime_prev_archive);

       String query_by_wp_groups = '';
       String query_by_wp_groups2 = ' AND Is_Archive_Older__c = 1 ';
       for(Integer i = 0; i < wp_groups_str.size(); i++)
       {
         if(datetime_end_archive2 > map_wp_group_datetime_prev_archive.get(wp_groups_str[i]) )
         {
         	String str_prev_datetime_tmp = map_wp_group_datetime_prev_archive.get(wp_groups_str[i]).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
//         	query_by_wp_groups2 = ' AND (EMG_Comment_Last_Archive_Date__c = null OR (EMG_Comment_Last_Archive_Date__c >= '+str_prev_datetime_tmp+' AND EMG_Comment_Last_Archive_Date__c <= '+datetime_end_archive2.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')+'))';
//            String str_query_from_date_for_wp_group = ' ( Deal__r.WP_Groups_picklist__c includes (\''+wp_groups_str[i]+'\') AND EMG_Last_Updated_Date__c > '+str_prev_datetime_tmp+query_by_wp_groups2+' ) '; 
//            query_by_wp_groups2 = ' AND (EMG_Comment_Last_Archive_Date__c = null OR EMG_Comment_Last_Archive_Date__c < EMG_Last_Updated_Date__c)';
            String str_query_from_date_for_wp_group = ' ( Deal__r.WP_Groups_picklist__c includes (\''+wp_groups_str[i]+'\') AND EMG_Last_Updated_Date__c > '+str_prev_datetime_tmp+' ) '; 
//            String str_query_from_date_for_wp_group = ' ( Deal__r.WP_Groups_picklist__c includes (\''+wp_groups_str[i]+'\') AND EMG_Last_Updated_Date__c > '+str_prev_datetime_tmp+' ) '; 
            query_by_wp_groups = query_by_wp_groups+(query_by_wp_groups.length()>0?' OR ':' ')+str_query_from_date_for_wp_group;
            query_by_wp_groups = query_by_wp_groups.trim();
         }         
       }
       if(query_by_wp_groups.trim().length()>0) query_by_wp_groups = ' AND ('+query_by_wp_groups+')';
       else query_by_wp_groups = ' AND EMG_Last_Updated_Date__c > '+datetime_end_archive2.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');

       String query = 'Select ID, EMG_Comment__c, EMG_Comment_Last_Archive_Date__c, UNIQUE_KEY__c, EMG_Updated_on_behalf_of__c, EMG_Last_Updated_Date__c, EMG_Last_Updated_By__c, Deal__c, Deal__r.WP_Groups_picklist__c From EMG_Comment__c Where EMG_Last_Updated_Date__c <= '+datetime_end_archive2.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')+query_by_wp_groups+query_by_wp_groups2;
       system.debug('###### query 1 '+query);
       list<sObject> scope = Database.query(query);

         List<EMG_Comment_History__c> list_insert_EMG_Comment_History = new List<EMG_Comment_History__c>();
         List<EMG_Comment__c> list_update_EMG_Comment = new List<EMG_Comment__c>();
         EMG_Comment_History__c eph = new EMG_Comment_History__c();
         EMG_Comment__c ep = new EMG_Comment__c();  
         for(sObject emg : scope) {
            ep = (EMG_Comment__c)emg;
            if(ep.EMG_Comment__c !=null && ep.EMG_Comment__c != '')   // don't archive balank Comments
            {
               eph = new EMG_Comment_History__c();
               eph.Deal__c = ep.Deal__c;
               eph.EMG_Comment__c = ep.EMG_Comment__c;
               eph.EMG_Last_Updated_Date__c = ep.EMG_Last_Updated_Date__c;
               eph.EMG_Last_Updated_By_Contact__c = ep.EMG_Last_Updated_By__c;  
               list_insert_EMG_Comment_History.add(eph);
               
               ep.EMG_Comment_Last_Archive_Date__c = datetime_end_archive2;
               list_update_EMG_Comment.add(ep);
            }
         }
         if(list_insert_EMG_Comment_History.size() > 0) insert list_insert_EMG_Comment_History;
         if(!list_update_EMG_Comment.isEmpty()) update list_update_EMG_Comment; 

         // Set new datetime in Archive_Settings__c
         list<Archive_Settings__c> list_update_cs_Archive_Settings = new list<Archive_Settings__c>();
         set<String> set_wp_groups = new set<String>(); 
         for(Archive_Settings__c cs_Archive_Settings : Archive_Settings__c.getall().values()) 
         {
            for(Integer i = 0; i < wp_groups_str.size(); i++)
               if(cs_Archive_Settings.Name == wp_groups_str[i]) 
               {
                  if(datetime_end_archive2 > map_wp_group_datetime_prev_archive.get(wp_groups_str[i]) )
                     cs_Archive_Settings.EMG_Comment__c = datetime_end_archive2;
                  set_wp_groups.add(wp_groups_str[i]);
                  list_update_cs_Archive_Settings.add(cs_Archive_Settings);   
               }      
         }
         for(Integer i = 0; i < wp_groups_str.size(); i++)
            if(!set_wp_groups.contains(wp_groups_str[i]))
               list_update_cs_Archive_Settings.add(
                 new Archive_Settings__c(
                  Name = wp_groups_str[i]
                  ,EMG_Comment__c = datetime_end_archive2
                 )
               );
         if(list_update_cs_Archive_Settings.size()>0) upsert list_update_cs_Archive_Settings;
         
         update_EMG_Archiving_Progress_after_block();
      }
	}

   // Archive EMG Paragraph in the page controller
   private void executeArchive_EMG_Paragraph()
   {
      if(map_archive_type_wp_group_datetime_prev_archive!=null && map_archive_type_wp_group_datetime_prev_archive.containsKey('SL_EMS_Paragraph_Archive_Batch'))
      {
       map_wp_group_datetime_prev_archive = map_archive_type_wp_group_datetime_prev_archive.get('SL_EMS_Paragraph_Archive_Batch');
       system.debug('###### map_wp_group_datetime_prev_archive 2 '+map_wp_group_datetime_prev_archive);
            
       String query_by_wp_groups = '';
       String query_by_wp_groups2 = ' AND Is_Archive_Older__c = 1 ';
       for(Integer i = 0; i < wp_groups_str.size(); i++)
       {
         if(datetime_end_archive2 > map_wp_group_datetime_prev_archive.get(wp_groups_str[i]) )
         {
            String str_prev_datetime_tmp = map_wp_group_datetime_prev_archive.get(wp_groups_str[i]).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
//            query_by_wp_groups2 = ' AND (EMG_Paragraph_Last_Archive_Date__c = null OR (EMG_Paragraph_Last_Archive_Date__c >= '+str_prev_datetime_tmp+' AND EMG_Paragraph_Last_Archive_Date__c <= '+datetime_end_archive2.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')+'))';
//            String str_query_from_date_for_wp_group = ' ( Deal__r.WP_Groups_picklist__c includes (\''+wp_groups_str[i]+'\') AND EMG_Last_Updated_Date__c > '+str_prev_datetime_tmp+query_by_wp_groups2+' ) '; 
//            query_by_wp_groups2 = ' AND (EMG_Paragraph_Last_Archive_Date__c = null OR EMG_Paragraph_Last_Archive_Date__c < EMG_Last_Updated_Date__c)';
            String str_query_from_date_for_wp_group = ' ( Deal__r.WP_Groups_picklist__c includes (\''+wp_groups_str[i]+'\') AND EMG_Last_Updated_Date__c > '+str_prev_datetime_tmp+' ) '; 
//            String str_query_from_date_for_wp_group = ' ( Deal__r.WP_Groups_picklist__c includes (\''+wp_groups_str[i]+'\') AND EMG_Last_Updated_Date__c > '+map_wp_group_datetime_prev_archive.get(wp_groups_str[i]).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')+' ) '; 
            query_by_wp_groups = query_by_wp_groups+(query_by_wp_groups.length()>0?' OR ':' ')+str_query_from_date_for_wp_group;
            query_by_wp_groups = query_by_wp_groups.trim();
         }         
       }
       if(query_by_wp_groups.trim().length()>0) query_by_wp_groups = ' AND ('+query_by_wp_groups+')';
       else query_by_wp_groups = ' AND EMG_Last_Updated_Date__c > '+datetime_end_archive2.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');

       String query = 'Select ID, EMG_Paragraph__c, UNIQUE_KEY__c, EMG_Updated_on_behalf_of__c, EMG_Last_Updated_Date__c, EMG_Last_Updated_By__c, Deal__c, Deal__r.WP_Groups_picklist__c From EMG_Paragraph__c Where EMG_Last_Updated_Date__c <= '+datetime_end_archive2.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')+query_by_wp_groups+query_by_wp_groups2;
       system.debug('###### query 2 '+query);
       list<sObject> scope = Database.query(query);

         List<EMG_Paragraph_History__c> list_insert_EMG_Paragraph_History = new List<EMG_Paragraph_History__c>();
         List<EMG_Paragraph__c> list_update_EMG_Paragraph = new List<EMG_Paragraph__c>();
         EMG_Paragraph_History__c eph = new EMG_Paragraph_History__c();
         EMG_Paragraph__c ep = new EMG_Paragraph__c();  
         for(sObject emg : scope) {
            ep = (EMG_Paragraph__c)emg;
            if(ep.EMG_Paragraph__c !=null && ep.EMG_Paragraph__c != '')   // don't archive balank paragraphs
            {
               eph = new EMG_Paragraph_History__c();
               eph.Deal__c = ep.Deal__c;
               eph.EMG_Paragraph__c = ep.EMG_Paragraph__c;
               eph.EMG_Last_Updated_Date__c = ep.EMG_Last_Updated_Date__c;
               eph.EMG_Last_Updated_By_Contact__c = ep.EMG_Last_Updated_By__c;  
               list_insert_EMG_Paragraph_History.add(eph);
               
               ep.EMG_Paragraph_Last_Archive_Date__c = datetime_end_archive2;
               list_update_EMG_Paragraph.add(ep);
            }
         }
         if(list_insert_EMG_Paragraph_History.size() > 0) insert list_insert_EMG_Paragraph_History;
         if(!list_update_EMG_Paragraph.isEmpty()) update list_update_EMG_Paragraph; 

         // Set new datetime in Archive_Settings__c
         list<Archive_Settings__c> list_update_cs_Archive_Settings = new list<Archive_Settings__c>();
         set<String> set_wp_groups = new set<String>(); 
         for(Archive_Settings__c cs_Archive_Settings : Archive_Settings__c.getall().values()) 
         {
            for(Integer i = 0; i < wp_groups_str.size(); i++)
               if(cs_Archive_Settings.Name == wp_groups_str[i]) 
               {
                  if(datetime_end_archive2 > map_wp_group_datetime_prev_archive.get(wp_groups_str[i]) )
                     cs_Archive_Settings.EMG_Paragraph__c = datetime_end_archive2;
                  set_wp_groups.add(wp_groups_str[i]);
                  list_update_cs_Archive_Settings.add(cs_Archive_Settings);   
               }      
         }
         for(Integer i = 0; i < wp_groups_str.size(); i++)
            if(!set_wp_groups.contains(wp_groups_str[i]))
               list_update_cs_Archive_Settings.add(
                 new Archive_Settings__c(
                  Name = wp_groups_str[i]
                  ,EMG_Paragraph__c = datetime_end_archive2
                 )
               );
         if(list_update_cs_Archive_Settings.size()>0) upsert list_update_cs_Archive_Settings;
         
         update_EMG_Archiving_Progress_after_block();
      }
   }


   // Archive Key Dates/Next Steps in the page controller
   private void executeArchive_Key_Dates_Next_Steps()
   {
      if(map_archive_type_wp_group_datetime_prev_archive!=null && map_archive_type_wp_group_datetime_prev_archive.containsKey('SL_Key_Dates_Next_Steps_Archive_Batch'))
      {
       map_wp_group_datetime_prev_archive = map_archive_type_wp_group_datetime_prev_archive.get('SL_Key_Dates_Next_Steps_Archive_Batch');
       system.debug('###### map_wp_group_datetime_prev_archive 3 '+map_wp_group_datetime_prev_archive);
            
       String query_by_wp_groups = '';
       String query_by_wp_groups2 = ' AND Is_Archive_Older__c = 1 ';
       for(Integer i = 0; i < wp_groups_str.size(); i++)
       {
         if(datetime_end_archive2 > map_wp_group_datetime_prev_archive.get(wp_groups_str[i]) )
         {
            String str_prev_datetime_tmp = map_wp_group_datetime_prev_archive.get(wp_groups_str[i]).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
//            query_by_wp_groups2 = ' AND (Key_Dates_Last_Archive_Date__c = null OR (Key_Dates_Last_Archive_Date__c >= '+str_prev_datetime_tmp+' AND Key_Dates_Last_Archive_Date__c <= '+datetime_end_archive2.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')+'))';
//            String str_query_from_date_for_wp_group = ' ( WP_Groups_picklist__c includes (\''+wp_groups_str[i]+'\') AND Key_Dates_Last_Update_Date__c > '+str_prev_datetime_tmp+query_by_wp_groups2+' ) '; 
//            query_by_wp_groups2 = ' AND (Key_Dates_Last_Archive_Date__c = null OR Key_Dates_Last_Archive_Date__c < Key_Dates_Last_Update_Date__c)';
            String str_query_from_date_for_wp_group = ' ( WP_Groups_picklist__c includes (\''+wp_groups_str[i]+'\') AND Key_Dates_Last_Update_Date__c > '+str_prev_datetime_tmp+' ) '; 
//            String str_query_from_date_for_wp_group = ' ( WP_Groups_picklist__c includes (\''+wp_groups_str[i]+'\') AND Key_Dates_Last_Update_Date__c > '+map_wp_group_datetime_prev_archive.get(wp_groups_str[i]).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')+' ) '; 
            query_by_wp_groups = query_by_wp_groups+(query_by_wp_groups.length()>0?' OR ':' ')+str_query_from_date_for_wp_group;
            query_by_wp_groups = query_by_wp_groups.trim();
         }         
       }
       if(query_by_wp_groups.trim().length()>0) query_by_wp_groups = ' AND ('+query_by_wp_groups+')';
       else query_by_wp_groups = ' AND Key_Dates_Last_Update_Date__c > '+datetime_end_archive2.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');

       String query = 'Select ID, Key_Dates_Next_Steps__c, Key_Dates_Last_Update_Date__c, Key_Dates_Last_Update_By__c, WP_Groups_picklist__c From Deal__c Where Key_Dates_Last_Update_Date__c <= '+datetime_end_archive2.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')+query_by_wp_groups+query_by_wp_groups2;
       system.debug('###### query 3 '+query);
       list<sObject> scope = Database.query(query);

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
               
               ep.Key_Dates_Last_Archive_Date__c = datetime_end_archive2;
               list_update_Deal.add(ep);
            }
         }
         if(list_insert_Key_Dates_Next_Steps_History.size() > 0) insert list_insert_Key_Dates_Next_Steps_History;
         if(!list_update_Deal.isEmpty()) update list_update_Deal; 
         
         // Set new datetime in Archive_Settings__c
         list<Archive_Settings__c> list_update_cs_Archive_Settings = new list<Archive_Settings__c>();
         set<String> set_wp_groups = new set<String>(); 
         for(Archive_Settings__c cs_Archive_Settings : Archive_Settings__c.getall().values()) 
         {
            for(Integer i = 0; i < wp_groups_str.size(); i++)
               if(cs_Archive_Settings.Name == wp_groups_str[i]) 
               {
                  if(datetime_end_archive2 > map_wp_group_datetime_prev_archive.get(wp_groups_str[i]) )
                     cs_Archive_Settings.Key_Dates_Next_Steps__c = datetime_end_archive2;
                  set_wp_groups.add(wp_groups_str[i]);
                  list_update_cs_Archive_Settings.add(cs_Archive_Settings);   
               }      
         }
         for(Integer i = 0; i < wp_groups_str.size(); i++)
            if(!set_wp_groups.contains(wp_groups_str[i]))
               list_update_cs_Archive_Settings.add(
                 new Archive_Settings__c(
                  Name = wp_groups_str[i]
                  ,Key_Dates_Next_Steps__c = datetime_end_archive2
                 )
               );
         if(list_update_cs_Archive_Settings.size()>0) upsert list_update_cs_Archive_Settings;
         
         update_EMG_Archiving_Progress_after_block();
      }
   }

   // Update custom setting EMG_Archiving_Progress after execution of archive block
   private void update_EMG_Archiving_Progress_after_block()
   {
         list<EMG_Archiving_Progress__c> EMG_Archiving_Progress = new list<EMG_Archiving_Progress__c>([SELECT Id,Name,Current_Process_ID__c,Current_Process_Number__c,percentComplete__c,Total_Processes__c FROM EMG_Archiving_Progress__c WHERE Name = :UserInfo.getUserId() limit 1]);
         if(EMG_Archiving_Progress.size()>0) 
         {
            Integer percentInitComplete = 100;
               if(EMG_Archiving_Progress[0].Total_Processes__c != 0){
                  percentInitComplete = ((EMG_Archiving_Progress[0].Current_Process_Number__c / EMG_Archiving_Progress[0].Total_Processes__c) * 100.0).intValue();
               }
            EMG_Archiving_Progress[0].Current_Process_ID__c = null;
            EMG_Archiving_Progress[0].Current_Process_Number__c += (EMG_Archiving_Progress[0].Current_Process_Number__c<EMG_Archiving_Progress[0].Total_Processes__c?1:0);
            EMG_Archiving_Progress[0].percentComplete__c = (Double)percentInitComplete;
         } 
         if(EMG_Archiving_Progress.size()>0)
            upsert EMG_Archiving_Progress;
   }

   public list<EMG_Comment_History__c> getNew_EMG_Comment_History()
   {
   	list<EMG_Comment_History__c> list_EMG_Comment_History = new list<EMG_Comment_History__c>();
   	
   	if(map_archive_type_wp_group_datetime_prev_archive!=null && map_archive_type_wp_group_datetime_prev_archive.containsKey('SL_EMS_Comment_Archive_Batch'))
   	{
       map_wp_group_datetime_prev_archive = map_archive_type_wp_group_datetime_prev_archive.get('SL_EMS_Comment_Archive_Batch');
          	
       String query_by_wp_groups = '';
       for(Integer i = 0; i < wp_groups_str.size(); i++)
       {
         if(datetime_end_archive2 > map_wp_group_datetime_prev_archive.get(wp_groups_str[i]) )
         {
            String str_query_from_date_for_wp_group = ' ( Deal__r.WP_Groups_picklist__c includes (\''+wp_groups_str[i]+'\') AND EMG_Last_Updated_Date__c > '+map_wp_group_datetime_prev_archive.get(wp_groups_str[i]).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')+' ) '; 
            query_by_wp_groups = query_by_wp_groups+(query_by_wp_groups.length()>0?' OR ':' ')+str_query_from_date_for_wp_group;
            query_by_wp_groups = query_by_wp_groups.trim();
         }         
       }
       if(query_by_wp_groups.trim().length()>0) query_by_wp_groups = ' AND ('+query_by_wp_groups+')';
       else query_by_wp_groups = ' AND EMG_Last_Updated_Date__c > '+datetime_end_archive2.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');

       String query = 'Select e.Name, e.Id, e.EMG_Last_Updated_Date__c, e.EMG_Last_Updated_By_Contact__c, e.EMG_Last_Updated_By_Contact__r.Name, e.EMG_Comment__c, e.Deal__c, e.Deal__r.Name, e.Deal__r.WP_Groups_picklist__c From EMG_Comment_History__c e  Where EMG_Last_Updated_Date__c <= '+datetime_end_archive2.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')+query_by_wp_groups;
       system.debug('###### query 1_1 '+query);
       list_EMG_Comment_History = Database.query(query);
   	}
   	return list_EMG_Comment_History;
   }

   public list<EMG_Paragraph_History__c> getNew_EMG_Paragraph_History()
   {
      list<EMG_Paragraph_History__c> list_EMG_Paragraph_History = new list<EMG_Paragraph_History__c>();
      
      if(map_archive_type_wp_group_datetime_prev_archive!=null && map_archive_type_wp_group_datetime_prev_archive.containsKey('SL_EMS_Paragraph_Archive_Batch'))
      {
       map_wp_group_datetime_prev_archive = map_archive_type_wp_group_datetime_prev_archive.get('SL_EMS_Paragraph_Archive_Batch');
            
       String query_by_wp_groups = '';
       for(Integer i = 0; i < wp_groups_str.size(); i++)
       {
         if(datetime_end_archive2 > map_wp_group_datetime_prev_archive.get(wp_groups_str[i]) )
         {
            String str_query_from_date_for_wp_group = ' ( Deal__r.WP_Groups_picklist__c includes (\''+wp_groups_str[i]+'\') AND EMG_Last_Updated_Date__c > '+map_wp_group_datetime_prev_archive.get(wp_groups_str[i]).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')+' ) '; 
            query_by_wp_groups = query_by_wp_groups+(query_by_wp_groups.length()>0?' OR ':' ')+str_query_from_date_for_wp_group;
            query_by_wp_groups = query_by_wp_groups.trim();
         }         
       }
       if(query_by_wp_groups.trim().length()>0) query_by_wp_groups = ' AND ('+query_by_wp_groups+')';
       else query_by_wp_groups = ' AND EMG_Last_Updated_Date__c > '+datetime_end_archive2.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');

       String query = 'Select e.Name, e.Id, e.EMG_Last_Updated_Date__c, e.EMG_Last_Updated_By_Contact__c, e.EMG_Last_Updated_By_Contact__r.Name, e.EMG_Paragraph__c, e.Deal__c, e.Deal__r.Name, e.Deal__r.WP_Groups_picklist__c From EMG_Paragraph_History__c e  Where EMG_Last_Updated_Date__c <= '+datetime_end_archive2.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')+query_by_wp_groups;
       system.debug('###### query 2_1 '+query);
       list_EMG_Paragraph_History = Database.query(query);
      }      
      return list_EMG_Paragraph_History;
   }

   public list<Key_Dates_Next_Steps_History__c> getNew_Key_Dates_Next_Steps_History()
   {
      list<Key_Dates_Next_Steps_History__c> list_Key_Dates_Next_Steps_History = new list<Key_Dates_Next_Steps_History__c>();
      
      if(map_archive_type_wp_group_datetime_prev_archive!=null && map_archive_type_wp_group_datetime_prev_archive.containsKey('SL_Key_Dates_Next_Steps_Archive_Batch'))
      {
       map_wp_group_datetime_prev_archive = map_archive_type_wp_group_datetime_prev_archive.get('SL_Key_Dates_Next_Steps_Archive_Batch');
            
       String query_by_wp_groups = '';
       for(Integer i = 0; i < wp_groups_str.size(); i++)
       {
         if(datetime_end_archive2 > map_wp_group_datetime_prev_archive.get(wp_groups_str[i]) )
         {
            String str_query_from_date_for_wp_group = ' ( Deal__r.WP_Groups_picklist__c includes (\''+wp_groups_str[i]+'\') AND EMG_Last_Updated_Date__c > '+map_wp_group_datetime_prev_archive.get(wp_groups_str[i]).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')+' ) '; 
            query_by_wp_groups = query_by_wp_groups+(query_by_wp_groups.length()>0?' OR ':' ')+str_query_from_date_for_wp_group;
            query_by_wp_groups = query_by_wp_groups.trim();
         }         
       }
       if(query_by_wp_groups.trim().length()>0) query_by_wp_groups = ' AND ('+query_by_wp_groups+')';
       else query_by_wp_groups = ' AND EMG_Last_Updated_Date__c > '+datetime_end_archive2.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');

       String query = 'Select e.Name, e.Id, e.EMG_Last_Updated_Date__c, e.EMG_Last_Updated_By__c, e.EMG_Last_Updated_By__r.Name, e.Key_Dates_Next_Steps__c, e.Deal__c, e.Deal__r.Name, e.Deal__r.WP_Groups_picklist__c From Key_Dates_Next_Steps_History__c e  Where EMG_Last_Updated_Date__c <= '+datetime_end_archive2.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')+query_by_wp_groups;
       system.debug('###### query 3_1 '+query);
       
       list_Key_Dates_Next_Steps_History = Database.query(query);
      }      
      return list_Key_Dates_Next_Steps_History;
   }

    public Integer pageSize_Key_Dates_Next_Steps_History {
        get {
            if(note_key_dates_next_steps!=null && !note_key_dates_next_steps) return 0;        	
            if(iArchiveProgress != 100 && !isProcessRun) return 0;
            list<Key_Dates_Next_Steps_History__c> list_History = getNew_Key_Dates_Next_Steps_History(); 
            return (list_History!=null?list_History.size():0);
        }
    }
   
    public Integer pageSize_EMG_Comment_History {
        get {
            if(note_emg_comment!=null && !note_emg_comment) return 0;           
            if(iArchiveProgress != 100 && !isProcessRun) return 0;
            list<EMG_Comment_History__c> list_History = getNew_EMG_Comment_History(); 
            return (list_History!=null?list_History.size():0);
        }
    }

    public Integer pageSize_EMG_Paragraph_History {
        get {
            if(note_emg_paragraph!=null && !note_emg_paragraph) return 0;           
            if(iArchiveProgress != 100 && !isProcessRun) return 0;
            list<EMG_Paragraph_History__c> list_History = getNew_EMG_Paragraph_History(); 
            return (list_History!=null?list_History.size():0);
        }
    }

   public Integer iArchiveProgress = 0;

   // WP-85
   // Calculation of procent in progress bar
   public void ArchiveProgressRun() 
   {
      for(EMG_Archiving_Progress__c cs_progress : EMG_Archiving_Progress__c.getall().values()) 
      	if(cs_progress.Name == UserInfo.getUserId()) {
      		ID batch_id = null;
        	iArchiveProgress = (cs_progress.percentComplete__c).intValue();
        	
        	Integer percentComplete = 0;
        	
        	Integer percentInitComplete = 0;
        	Integer percentPerJob = 0;	
            if(cs_progress.Total_Processes__c != 0){
              	percentInitComplete = (((cs_progress.Current_Process_Number__c-1)  / cs_progress.Total_Processes__c) * 100.0).intValue();
              	if(percentInitComplete < 0) percentInitComplete = 0;
              	percentPerJob = (( 1  / cs_progress.Total_Processes__c) * 100.0).intValue(); 
            } else percentInitComplete  = 100;
        		
        	Integer percentJobComplete = 0;	 
        	if(cs_progress.Current_Process_ID__c != null) {
        		batch_id = cs_progress.Current_Process_ID__c;

        		if(batch_id!= null)
        		//Query the Batch apex jobs
        		for(AsyncApexJob a : [select TotalJobItems, Status, NumberOfErrors, MethodName, JobType, JobItemsProcessed, Id, CreatedDate, CreatedById, CompletedDate, ApexClassId, ApexClass.Name From AsyncApexJob WHERE Id = :batch_id order by CreatedDate desc limit 1])
        		{
            		Double itemsProcessed = a.JobItemsProcessed;
            		Double totalItems = a.TotalJobItems;
            		
            		percentJobComplete = 100;
		            //Determine the pecent complete based on the number of batches complete
            		if(totalItems != 0){
                		//A little check here as we don't want to divide by 0.
                		percentJobComplete = ((itemsProcessed  / totalItems) * 100.0).intValue();
            		}
        		}        		
        	}
        	
        	percentComplete = percentInitComplete + ((percentPerJob/100.0)*percentJobComplete).intValue();
        	if(percentComplete >= iArchiveProgress) { 
        		iArchiveProgress = percentComplete;
        		cs_progress.percentComplete__c = (Double)iArchiveProgress; 
        		upsert cs_progress;	
        	}
      		break; 
      	}
      	
      if(iArchiveProgress>100) iArchiveProgress = 100;
   }

   public String getArchiveProgress()
   {
   	String str = '0';
 	   str = String.valueOf(iArchiveProgress);
   	return str;
   }

	public Boolean getProcessRun()
	{
		return isProcessRun;
	}
	
	public list<String> getSel_values()
	{
            for(Integer i=0; i < wp_groups_str.size() ; i++)
               sel_values.add( wp_groups_str[i] );
//               contact_names.add( sel_contacts1.get( contacts_str[i] ).Name );
            
//        User curUser = [SELECT u.id,u.Profile.Name, u.ProfileId, u.Name FROM User u WHERE u.ID = :UserInfo.getUserId() Limit 1];
//            sel_values.add( curUser.Profile.Name );

// get list of users with profile WP EMG Group SSO
//        for(User curUser : [SELECT u.id,u.Profile.Name, u.ProfileId, u.Name FROM User u WHERE u.Profile.Name like 'WP EMG%' Limit 1000])
//            sel_values.add( curUser.Name+' = '+curUser.Profile.Name );
            
            return sel_values;
	}
	
	public boolean getnote_emg_comment1(){
		return note_emg_comment;
	}
   public boolean getnote_emg_paragraph1(){
      return note_emg_paragraph;
   }
   public boolean getnote_key_dates_next_steps1(){
      return note_key_dates_next_steps;
   }
   
   public string getend_date() {
   	return end_date;
   }

   public string getend_datetime() {
      return end_datetime;
   }
   
   public integer getIs_show_EMG_Archive_Page()
   {
      Contact uContact = SL_wsdl_EMG.getContact_by_current_User();
      if(uContact != null && uContact.Archive_Permission__c)
         return 1;
      return 0;
   }
   
   public String getError_Style() {
         if(getIs_show_EMG_Archive_Page() == 1)
           return 'display: none;'; 
         return ''; 
   }
   public String getForm_Style() {
         if(getIs_show_EMG_Archive_Page() != 1)
           return 'display: none;'; 
         return ''; 
   }

   public String getOneWPGroup() 
   {
        return strWPGroup;
   }
   
   public String getForm_one_WP_Group() {
         if(getOneWPGroup().length() > 0) {
            return '';
         }   
         return 'display: none;'; 
   }

   public String getForm_many_WP_Groups() {
         if(getOneWPGroup().length() == 0)
            return '';
         return 'display: none;'; 
   }
   
}