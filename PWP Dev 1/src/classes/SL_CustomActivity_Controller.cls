/**
* \arg ClassName        : SL_CustomActivity_Controller
* \arg JIRATicket     	: PWP-285
* \arg CreatedOn      	: 16/SEP/2015
* \arg LastModifiedOn	: 24/SEP/2015
* \arg CreatededBy    	: Harsh 
* \arg ModifiedBy     	: Pankaj Ganwani
* \arg Description      : Controller class for SL_CustomActivityInlineVF Page.
*/
public with sharing class SL_CustomActivity_Controller {
	
	/* Start - Variables */
	public List<ActivityHistoryWrapper> lstActivityHistory {get;set;}	// list for conatins all the ActivityHistory record for current account id
   	public Boolean isNativeSubject = false;
   	private Id accountId;												// id store the current account which is present in url
   	public Id selectedActivityId 		{get;set;}
   	public String strRelatedToId		{get;set;}	
   	public String strActivityId			{get;set;}
   	public Id shadowActivityId			{get;set;}
   	public String strUserId             {get;set;}
   	/* End - Variables */
   	
	/* Start - Constructor */
    public SL_CustomActivity_Controller(Apexpages.StandardController stdCtrl)
    {
        accountId = stdCtrl.getId();
        initialize();
    }
    
    /*
        * MethodName   : initialize
        * Param        : 
        * Description  : This method is used for intialize the variable and query the Account and its related Activity histories.
    */
	public void initialize()
	{
		lstActivityHistory = new List<ActivityHistoryWrapper>();
		strUserId = UserInfo.getUserId();
		// Added as per PWP-116 for checking whether current logged in user is present in "Account team member" then only we displaying the actual subject 
		if([SELECT Id FROM AccountTeamMember WHERE AccountId =: accountId  AND UserId =:Userinfo.getUserId()].size()>0)
		{
			isNativeSubject = true;
		}

		for(Task objTask : [Select Id, Subject, Who.Name, WhoId, Status, WhatId, What.Name, ActivityDate, OwnerId, Owner.Name From Task Where WhatId =: accountId ORDER BY ActivityDate DESC, LastModifiedDate DESC])
		{
			boolean isAccessToUser = isNativeSubject || objTask.OwnerId == Userinfo.getUserId();
			String subject = isAccessToUser ? objTask.Subject : 'Subject Masked';
			Date dueDate = objTask.ActivityDate;
			lstActivityHistory.add(new ActivityHistoryWrapper(objTask.Id, subject, objTask.What.Name, objTask.WhatId, dueDate, objTask.Who.Name, objTask.WhoId, objTask.Owner.Name, objTask.OwnerId, isAccessToUser));
		}
		
		for(Event objEvent : [Select Id, (Select RelationId From EventRelations Where RelationId =: Userinfo.getUserId()), Subject, Who.Name, WhoId, WhatId, What.Name, EndDateTime, OwnerId, Owner.Name  From Event Where WhatId =: accountId AND isChild = false ORDER BY EndDateTime DESC, LastModifiedDate DESC])
		{
			boolean isAccessToUser = isNativeSubject || objEvent.OwnerId == Userinfo.getUserId() || objEvent.EventRelations.size() > 0;
			String subject =  isAccessToUser ? objEvent.Subject : 'Subject Masked';
			lstActivityHistory.add(new ActivityHistoryWrapper(objEvent.Id, subject, objEvent.What.Name, objEvent.WhatId, Date.valueOf(objEvent.EndDateTime), objEvent.Who.Name, objEvent.WhoId, objEvent.Owner.Name, objEvent.OwnerId, isAccessToUser));
		}
	}
	
	 /*
        * MethodName   : getTimeZoneValue
        * Param        : -
        * Description  : This method is used to get the time zone value as per the current user's locale.
    */
	public String getTimeZoneValue()
	{
		Map<String,String> mappedValues = new Map<String,String>();
		mappedValues = MapValues();
		String userLocale = Userinfo.getLocale();
		String datetime_format = '{0, date, M/d/yyyy h:mm a}'; //Setting US locale as default locale.
		if(mappedValues.containskey(userLocale))
			return '{0, date, '+mappedValues.get(userLocale)+'}';
		return datetime_format;
	}
    
    
    public void deleteActivity()
    {
    	if(selectedActivityId != NULL && String.valueOf(selectedActivityId).startsWith('00T'))
    		delete [Select Id From Task where Id =: selectedActivityId ];
    	else if(selectedActivityId != NULL && String.valueOf(selectedActivityId).startsWith('00U'))
    		delete [Select Id From Event where Id =: selectedActivityId ];
    }
    
    public class ActivityHistoryWrapper {
    	public Id id {get;set;}
    	public String subject {get;set;}
    	public String relatedToName {get;set;}
    	public Id relatedToId 	{get;set;}
    	public Date dueDate	{get;set;}
    	public String primaryContact 	{get;set;}
    	public Id primaryContactId		{get;set;}
    	public String assignToName {get;set;}
    	public Id assignToId 	{get;set;}
    	public Boolean isNativeSubject {get;set;}
    	
    	public ActivityHistoryWrapper(Id recId, String subject, String relatedToName, Id relatedToId, Date dueDate, String primaryContact, Id primaryContactId, String assignToName, Id assignToId, Boolean isNativeSubject){
    		this.id = recId;
    		this.subject = subject;
    		this.relatedToName = relatedToName;
    		this.relatedToId = relatedToId;
    		this.dueDate = dueDate;
    		this.primaryContact = primaryContact;
    		this.assignToName = assignToName;
    		this.assignToId = assignToId;
    		this.isNativeSubject = isNativeSubject;
    		this.primaryContactId = primaryContactId;
    	}
    }
    
     /*
        * MethodName   : fetchCallReportId
        * Param        : 
        * Description  : This method is called from Page
    */
    
    public void fetchCallReportId()
    {
        shadowActivityId = strActivityId;
    }
    
    private Map<String, String> MapValues() 
    {
		Map<String, String> locale_map = new Map<String, String>(); //holds the locale to timedate formats
		locale_map.put('ar', 'dd/MM/yyyy hh:mm a');
		locale_map.put('ar_AE', 'dd/MM/yyyy hh:mm a');
		locale_map.put('ar_BH', 'dd/MM/yyyy hh:mm a');
		locale_map.put('ar_JO', 'dd/MM/yyyy hh:mm a');
		locale_map.put('ar_KW', 'dd/MM/yyyy hh:mm a');
		locale_map.put('ar_LB', 'dd/MM/yyyy hh:mm a');
		locale_map.put('ar_SA', 'dd/MM/yyyy hh:mm a');
		locale_map.put('bg_BG', 'yyyy-M-d H:mm');
		locale_map.put('ca', 'dd/MM/yyyy HH:mm');
		locale_map.put('ca_ES', 'dd/MM/yyyy HH:mm');
		locale_map.put('ca_ES_EURO', 'dd/MM/yyyy HH:mm');
		locale_map.put('cs', 'd.M.yyyy H:mm');
		locale_map.put('cs_CZ', 'd.M.yyyy H:mm');
		locale_map.put('da', 'dd-MM-yyyy HH:mm');
		locale_map.put('da_DK', 'dd-MM-yyyy HH:mm');
		locale_map.put('de', 'dd.MM.yyyy HH:mm');
		locale_map.put('de_AT', 'dd.MM.yyyy HH:mm');
		locale_map.put('de_AT_EURO', 'dd.MM.yyyy HH:mm');
		locale_map.put('de_CH', 'dd.MM.yyyy HH:mm');
		locale_map.put('de_DE', 'dd.MM.yyyy HH:mm');
		locale_map.put('de_DE_EURO', 'dd.MM.yyyy HH:mm');
		locale_map.put('de_LU', 'dd.MM.yyyy HH:mm');
		locale_map.put('de_LU_EURO', 'dd.MM.yyyy HH:mm');
		locale_map.put('el_GR', 'd/M/yyyy h:mm a');
		locale_map.put('en_AU', 'd/MM/yyyy HH:mm');
		locale_map.put('en_B', 'M/d/yyyy h:mm a');
		locale_map.put('en_BM', 'M/d/yyyy h:mm a');
		locale_map.put('en_CA', 'dd/MM/yyyy h:mm a');
		locale_map.put('en_GB', 'dd/MM/yyyy HH:mm');
		locale_map.put('en_GH', 'M/d/yyyy h:mm a');
		locale_map.put('en_ID', 'M/d/yyyy h:mm a');
		locale_map.put('en_IE', 'dd/MM/yyyy HH:mm');
		locale_map.put('en_IE_EURO', 'dd/MM/yyyy HH:mm');
		locale_map.put('en_NZ', 'd/MM/yyyy HH:mm');
		locale_map.put('en_SG', 'M/d/yyyy h:mm a');
		locale_map.put('en_US', 'M/d/yyyy h:mm a');
		locale_map.put('en_ZA', 'yyyy/MM/dd hh:mm a');
		locale_map.put('es', 'd/MM/yyyy H:mm');
		locale_map.put('es_AR', 'dd/MM/yyyy HH:mm');
		locale_map.put('es_BO', 'dd-MM-yyyy hh:mm a');
		locale_map.put('es_CL', 'dd-MM-yyyy hh:mm a');
		locale_map.put('es_CO', 'd/MM/yyyy hh:mm a');
		locale_map.put('es_CR', 'dd/MM/yyyy hh:mm a');
		locale_map.put('es_EC', 'dd/MM/yyyy hh:mm a');
		locale_map.put('es_ES', 'd/MM/yyyy H:mm');
		locale_map.put('es_ES_EURO', 'd/MM/yyyy H:mm');
		locale_map.put('es_GT', 'd/MM/yyyy hh:mm a');
		locale_map.put('es_HN', 'MM-dd-yyyy hh:mm a');
		locale_map.put('es_MX', 'd/MM/yyyy hh:mm a');
		locale_map.put('es_PE', 'dd/MM/yyyy hh:mm a');
		locale_map.put('es_PR', 'MM-dd-yyyy hh:mm a');
		locale_map.put('es_PY', 'dd/MM/yyyy hh:mm a');
		locale_map.put('es_SV', 'MM-dd-yyyy hh:mm a');
		locale_map.put('es_UY', 'dd/MM/yyyy hh:mm a');
		locale_map.put('es_VE', 'dd/MM/yyyy hh:mm a');
		locale_map.put('et_EE', 'd.MM.yyyy H:mm');
		locale_map.put('fi', 'd.M.yyyy H:mm');
		locale_map.put('fi_FI', 'd.M.yyyy H:mm');
		locale_map.put('fi_FI_EURO', 'd.M.yyyy H:mm');
		locale_map.put('fr', 'dd/MM/yyyy HH:mm');
		locale_map.put('fr_BE', 'd/MM/yyyy H:mm');
		locale_map.put('fr_CA', 'yyyy-MM-dd HH:mm');
		locale_map.put('fr_CH', 'dd.MM.yyyy HH:mm');
		locale_map.put('fr_FR', 'dd/MM/yyyy HH:mm');
		locale_map.put('fr_FR_EURO', 'dd/MM/yyyy HH:mm');
		locale_map.put('fr_LU', 'dd/MM/yyyy HH:mm');
		locale_map.put('fr_MC', 'dd/MM/yyyy HH:mm');
		locale_map.put('hr_HR', 'yyyy.MM.dd HH:mm');
		locale_map.put('hu', 'yyyy.MM.dd. H:mm');
		locale_map.put('hy_AM', 'M/d/yyyy h:mm a');
		locale_map.put('is_IS', 'd.M.yyyy HH:mm');
		locale_map.put('it', 'dd/MM/yyyy H.mm');
		locale_map.put('it_CH', 'dd.MM.yyyy HH:mm');
		locale_map.put('it_IT', 'dd/MM/yyyy H.mm');
		locale_map.put('iw', 'HH:mm dd/MM/yyyy');
		locale_map.put('iw_IL', 'HH:mm dd/MM/yyyy');
		locale_map.put('ja', 'yyyy/MM/dd H:mm');
		locale_map.put('ja_JP', 'yyyy/MM/dd H:mm');
		locale_map.put('kk_KZ', 'M/d/yyyy h:mm a');
		locale_map.put('km_KH', 'M/d/yyyy h:mm a');
		locale_map.put('ko', 'yyyy. M. d a h:mm');
		locale_map.put('ko_KR', 'yyyy. M. d a h:mm');
		locale_map.put('lt_LT', 'yyyy.M.d HH.mm');
		locale_map.put('lv_LV', 'yyyy.d.M HH:mm');
		locale_map.put('ms_MY', 'dd/MM/yyyy h:mm a');
		locale_map.put('nl', 'd-M-yyyy H:mm');
		locale_map.put('nl_BE', 'd/MM/yyyy H:mm');
		locale_map.put('nl_NL', 'd-M-yyyy H:mm');
		locale_map.put('nl_SR', 'd-M-yyyy H:mm');
		locale_map.put('no', 'dd.MM.yyyy HH:mm');
		locale_map.put('no_NO', 'dd.MM.yyyy HH:mm');
		locale_map.put('pl', 'yyyy-MM-dd HH:mm');
		locale_map.put('pt', 'dd-MM-yyyy H:mm');
		locale_map.put('pt_AO', 'dd-MM-yyyy H:mm');
		locale_map.put('pt_BR', 'dd/MM/yyyy HH:mm');
		locale_map.put('pt_PT', 'dd-MM-yyyy H:mm');
		locale_map.put('ro_RO', 'dd.MM.yyyy HH:mm');
		locale_map.put('ru', 'dd.MM.yyyy H:mm');
		locale_map.put('sk_SK', 'd.M.yyyy H:mm');
		locale_map.put('sl_SI', 'd.M.y H:mm');
		locale_map.put('sv', 'yyyy-MM-dd HH:mm');
		locale_map.put('sv_SE', 'yyyy-MM-dd HH:mm');
		locale_map.put('th', 'M/d/yyyy h:mm a');
		locale_map.put('th_TH', 'd/M/yyyy, H:mm ?.');
		locale_map.put('tr', 'dd.MM.yyyy HH:mm');
		locale_map.put('ur_PK', 'M/d/yyyy h:mm a');
		locale_map.put('vi_VN', 'HH:mm dd/MM/yyyy');
		locale_map.put('zh', 'yyyy-M-d ah:mm');
		locale_map.put('zh_CN', 'yyyy-M-d ah:mm');
		locale_map.put('zh_HK', 'yyyy-M-d ah:mm');
		locale_map.put('zh_TW', 'yyyy/M/d a h:mm');
		return locale_map; //return the map
	}
}