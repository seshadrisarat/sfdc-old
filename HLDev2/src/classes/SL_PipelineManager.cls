/**  
* \arg ClassName      : SL_PipelineManager
* \arg JIRATicket     : HL-16
* \arg CreatedOn      : 4/JUNE/2014
* \arg LastModifiedOn : 4/JUNE/2014
* \arg CreatededBy    : Lodhi
* \arg ModifiedBy     : -
* \arg Description    : This is controller class for SL_PipelineManager page.
*/
public with sharing class SL_PipelineManager 
{
    /* Start Variables */
    public String strOpportunityOption          			{   get;set;    }//!< variable for opportunity option.
    public String strEngagementOption           			{   get;set;    }//!< variable for engagement option.
    public String strOpportunityOpenOrClosed    			{   get;set;    }//!< variable for Opportunity Open Or Closed option.
    public String strEngagementOpenOrClosed     			{   get;set;    }//!< variable for Engagement Open Or Closed option.
    public String dtOpportunityFromDate           			{   get;set;    }//!< variable for Opportunity From date.
    public String dtOpportunityToDate             			{   get;set;    }//!< variable for Opportunity To date.
    public String dtEngagementFromDate            			{   get;set;    }//!< variable for Enagagement From date.
    public String dtEngagementToDate              			{   get;set;    }//!< variable for Enagagement To date.
    
    public SL_Paginator opportunityRecords      			{   get;set;    }//!< to display the opportunity records.
    public SL_Paginator engagementRecords       			{   get;set;    }//!< to display the engagement records.
    public List<ColumnWrapper> lstColumnWrapperOpportunity	{   get;set;    }//!< fields api name and lable for opportunity.
    public List<ColumnWrapper> lstColumnWrapperEngagement	{   get;set;    }//!< fields api name and lable for engagement.
    public Boolean enableOpportunity						{	get;set;	}
    public Boolean enableEngagement							{	get;set;	}
    
    private String strCSVOpportunityFields = '';
    private String strCSVEngagementFields = '';
    private Set<Id> setSobjectIdOpportunity;
    private Set<Id> setSobjectIdEngagement;
    private static final Integer PAGE_SIZE = 10;
    private static Map<String, Schema.SObjectType> mapGlobalDescribe = Schema.getGlobalDescribe();
    private static Map<String, Map<String, Schema.SObjectField>> mapSobjectNameToFieldsDescription;
    private Pipeline_Column_Selection__c objPCS;
    
    public Boolean isDisabled	{	get;set;	}
    /* End Variables */
    static
    {    
    	mapSobjectNameToFieldsDescription =  new Map<String, Map<String, Schema.SObjectField>>();
    	mapSobjectNameToFieldsDescription.put('Opportunity__c', Schema.getGlobalDescribe().get('Opportunity__c').getDescribe().fields.getMap());
        mapSobjectNameToFieldsDescription.put('Engagement__c', Schema.getGlobalDescribe().get('Engagement__c').getDescribe().fields.getMap());
    }
    
    /* Start - Constructor */
    public SL_PipelineManager() 
    {
    	try
    	{
	    	intilization();
	    	objPCS = getPCS();
	       	lstColumnWrapperOpportunity = getColumnWrapper(objPCS.Opportunity_Columns__c.split(','), 'Opportunity__c');
	       	lstColumnWrapperEngagement = getColumnWrapper(objPCS.Engagement_Columns__c.split(','), 'Engagement__c');
	       	setSobjectIdOpportunity = getSobjectRecordIdToQuery('Opportunity_Internal_Team__c','Opportunity__c');
	       	setSobjectIdEngagement = getSobjectRecordIdToQuery('Engagement_Internal_Team__c', 'Engagement__c');
	       	if(!lstColumnWrapperOpportunity.isEmpty())
	       	{
	       		enableOpportunity = true;
		       	String strOppoirtunityFieldAPIToSort = (lstColumnWrapperOpportunity[0].isSortable)? lstColumnWrapperOpportunity[0].strFieldAPI : 'Id';
		       	opportunityRecords = intializePagination(strCSVOpportunityFields, PAGE_SIZE, 'Opportunity__c', prepareWhereClause('Opportunity__c'), 
	       											  	 false, new Set<Id>(), false, strOppoirtunityFieldAPIToSort, 'ASC');
	       	}
	       	if(!lstColumnWrapperEngagement.isEmpty())
	       	{
	       		enableEngagement = true;
		       	String strEngagementFieldAPIToSort = (lstColumnWrapperEngagement[0].isSortable)? lstColumnWrapperOpportunity[0].strFieldAPI : 'Id';
				engagementRecords = intializePagination(strCSVEngagementFields, PAGE_SIZE, 'Engagement__c', prepareWhereClause('Engagement__c'), 
														  false, new Set<Id>(), false, strEngagementFieldAPIToSort, 'ASC');
	       	}
		}
       	catch(Exception e)
       	{
       		system.debug('======Exception======'+e.getMessage() +'======Linenumber======'+ e.getlineNumber());
		}
    } 
    /* End - Constructor */
    
    /* Start - Wrapper class for columns*/
    public class ColumnWrapper
    {
		public String strFieldAPI				{	get;set;	}
		public String strFieldLabel				{	get;set;	}
		public Boolean isSortable				{	get;set;	}
		
		public ColumnWrapper(String strFieldAPI, String strFieldLabel, Boolean isSortable)
		{
			this.strFieldAPI = strFieldAPI;
			this.strFieldLabel = strFieldLabel;
			this.isSortable = isSortable;
		}    	
    }
    /* End - Wrapper class for columns*/
    
    /* 
        @MethodName : intilization.
        @param      : NA.
        @Description: intilize all global variables of the class.
    */
    private void intilization()
    {
    	enableOpportunity = enableEngagement = false;
        strOpportunityOption = 'allopportunities';
        strEngagementOption = 'allengagements';
        strOpportunityOpenOrClosed = 'active';
        strEngagementOpenOrClosed = 'active';
        Date dtStart = date.newInstance(Date.today().Year(), 1, 1);//Date.today().addDays(-30);
        Date dtEnd = date.newInstance(Date.today().Year(), 12, 31);//Date.today();
        dtOpportunityFromDate = dtStart.month() + '/' + dtStart.day() + '/' + dtStart.year();
        dtOpportunityToDate = dtEnd.month() + '/' + dtEnd.day() + '/' + dtEnd.year();
        setSobjectIdOpportunity = new Set<Id>();
        setSobjectIdEngagement = new Set<Id>();
        
        isDisabled = true;
    }
    /* End */
    
    /* 
        @MethodName : getPCS.   
        @param      : NA.
        @Description: to insert fields of selected from the picklist in the Pipeline_Column_Selection__c.
    */
    private Pipeline_Column_Selection__c getPCS()
    {
    	List<Pipeline_Column_Selection__c> lstPCS = [SELECT Id, 
    														Engagement_Columns__c, 
    														Opportunity_Columns__c 
    												   FROM Pipeline_Column_Selection__c
    												  WHERE User__c =: Userinfo.getUserId() LIMIT 1];
    	if(lstPCS.isEmpty())
    	{
    		Pipeline_Column_Selection__c objPCS = new Pipeline_Column_Selection__c(Opportunity_Columns__c = 'Name,Stage__c,Pitch_Date__c', 
    												  							   Engagement_Columns__c = 'Name,Stage__c,Status__c,Close_Date__c', 
    												  							   User__c = Userinfo.getUserId());
    		return objPCS;
    		
    	}
    	else
    	{
    		return lstPCS[0];
    	}
    }
    /* End */
     
    /*
        @MethodName : getOpportunityOptions.
        @param      : NA.
        @Description: to get the options to display the opportunities records.
    */
    public List<SelectOption> getOpportunityOptions()
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('teamopportunities', 'My Opportunities'));
        options.add(new SelectOption('allopportunities', 'All Opportunities'));
        for(SelectOption objOptions : getPicklistValues('Opportunity__c', 'Line_of_Business__c'))
        {
        	options.add(new SelectOption(objOptions.getValue(), objOptions.getLabel()+ ' Opportunities'));
        }
        return options;
    }
    /* End */
    
    /*
        @MethodName : getOpenOrClosed.
        @param      : NA.
        @Description: to get the options to display the Open Or Close options.
    */
    public List<SelectOption> getOpenOrClosed()
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('active', 'Active'));
        options.add(new SelectOption('hold', 'Hold'));
        options.add(new SelectOption('activehold', 'Active & On Hold'));
        options.add(new SelectOption('closed', 'Closed'));
        return options;
    }
    /* End */
    
    /*
        @MethodName : getEngagementOptions.
        @param      : NA.
        @Description: to get the options to display the engagements records.
    */
    public List<SelectOption> getEngagementOptions()
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('teamengagements', 'My Engagements'));
        options.add(new SelectOption('allengagements', 'All Engagements'));
        for(SelectOption objOptions : getPicklistValues('Engagement__c', 'Line_of_Business__c'))
        {
        	options.add(new SelectOption(objOptions.getValue(), objOptions.getLabel()+ ' Engagements'));
        }
        return options;
    }
    /* End */  
    
    /*
        @MethodName : getColumnWrapper.
        @param      : List<SelectOption> optionsSelected and sobject name.
        @Description: to get the slected field to display on page.
    */
    private List<ColumnWrapper> getColumnWrapper(List<String> lstSelectedFields, String SobjectName)
    {
    	List<ColumnWrapper> lstColumnWrapper = new List<ColumnWrapper>();
    	for(String strFieldAPI : lstSelectedFields)
    	{
    		if(mapSobjectNameToFieldsDescription.get(SobjectName).containsKey(strFieldAPI.trim()))
    		{
    			Schema.SObjectField field = mapSobjectNameToFieldsDescription.get(SobjectName).get(strFieldAPI.trim());
    			if(field.getDescribe().isAccessible())
    			{
    				lstColumnWrapper.add(new ColumnWrapper(field.getDescribe().getName(), field.getDescribe().getLabel(), field.getDescribe().isSortable()));
    				if(SobjectName == 'Opportunity__c')
						strCSVOpportunityFields += (strCSVOpportunityFields == '') ? field.getDescribe().getName() : ', ' +	field.getDescribe().getName();
					else
						strCSVEngagementFields += (strCSVEngagementFields == '') ? field.getDescribe().getName() : ', ' + field.getDescribe().getName();
    			}
    			
    		}
    	}
    	
    	return lstColumnWrapper;
    }
    /* End */
    
    /*
        @MethodName : prepareWhereClause.
        @param      : Sobject Name.
        @Description: to prepare the where clause as per the filters.
    */
	private String prepareWhereClause(String strSobjectName)
	{
		String strWhereClause = '';
		
		if(strSobjectName == 'Opportunity__c')
		{
			if(!String.isBlank(dtOpportunityFromDate) && !String.isBlank(dtOpportunityToDate))
			{
				String dateFormat = 'yyyy-MM-dd\'T\'HH:mm:ss\'Z\'';
				Datetime dtStart = Datetime.newInstance(Integer.valueOf(dtOpportunityFromDate.split('/')[2]), 
														Integer.valueOf(dtOpportunityFromDate.split('/')[0]), 
														Integer.valueOf(dtOpportunityFromDate.split('/')[1]));
				DateTime dtEnd = Datetime.newInstance(Integer.valueOf(dtOpportunityToDate.split('/')[2]), 
													  Integer.valueOf(dtOpportunityToDate.split('/')[0]), 
													  Integer.valueOf(dtOpportunityToDate.split('/')[1]),
													  23, 59, 59);
				strWhereClause += (dtStart != null && dtEnd != null) 
								  ? ' CreatedDate >= ' + dtStart.format(dateFormat) + ' AND CreatedDate <= ' + dtEnd.format(dateFormat) + ' AND ': '';
			}
			strWhereClause += (strOpportunityOption != 'teamopportunities' && strOpportunityOption != 'allopportunities') ? ' Line_of_Business__c = \''+ strOpportunityOption +'\' AND ' : '';
			strWhereClause += (strOpportunityOpenOrClosed == 'active') ? ' Active__c = true ' 
							  :(strOpportunityOpenOrClosed == 'hold') ? ' On_Hold__c = true ' 
							  :(strOpportunityOpenOrClosed == 'activehold') ? ' Active_and_On_Hold__c = true '
							  :(strOpportunityOpenOrClosed == 'closed') ? ' Closed__c = true ' : '';
		}
		else
		{  
			if(strEngagementOpenOrClosed == 'Closed' && !String.isBlank(dtEngagementFromDate) && !String.isBlank(dtEngagementToDate))
			{
				String dateFormat = 'yyyy-MM-dd';
				Datetime dtStart = Datetime.newInstance(Integer.valueOf(dtEngagementFromDate.split('/')[2]), 
														Integer.valueOf(dtEngagementFromDate.split('/')[0]), 
														Integer.valueOf(dtEngagementFromDate.split('/')[1]));
														
				Datetime dtEnd = Datetime.newInstance(Integer.valueOf(dtEngagementToDate.split('/')[2]), 
											  		  Integer.valueOf(dtEngagementToDate.split('/')[0]), 
											  		  Integer.valueOf(dtEngagementToDate.split('/')[1]));
											  		  
				strWhereClause += (dtStart != null && dtEnd != null) 
								  ? ' Close_Date__c >= ' + dtStart.format(dateFormat) + ' AND Close_Date__c <= ' + dtEnd.format(dateFormat) + ' AND ': '';
			}
			strWhereClause += (strEngagementOption != 'teamengagements' && strEngagementOption != 'allengagements') ? ' Line_of_Business__c = \''+ strEngagementOption +'\' AND ' : '';
			strWhereClause += (strEngagementOpenOrClosed == 'active') ? ' Active__c = true ' 
							  :(strEngagementOpenOrClosed == 'hold') ? ' On_Hold__c = true ' 
							  :(strEngagementOpenOrClosed == 'activehold') ? ' Active_And_On_Hold__c = true ' 
							  :(strEngagementOpenOrClosed == 'closed') ? ' Closed__c = true ' : '';
		}
		
		return strWhereClause;
	}
    /* End */
    /*
        @MethodName : getSobjectRecordIdToQuery.
        @param      : String strSobjectName and String strRelationshipName
        @Description: to get the sobject ids for query.
    */
    private Set<Id> getSobjectRecordIdToQuery(String strSobjectName, String strRelationshipName)
    {
    	Set<Id> setSobjectIds = new Set<Id>();
    	String strQuery = 'SELECT Id, ' +strRelationshipName + ' FROM ' + strSobjectName + ' WHERE Contact__r.User__c =\'' + Userinfo.getUserId() + '\'';
    	for(Sobject sobj : Database.query(strQuery))
    	{
    		setSobjectIds.add((Id)sobj.get(strRelationshipName));
    	}
    	return setSobjectIds;
    }
    /* End */
    
    /*
        @MethodName : intializePagination.
        @param      : 
        @Description: to get the paginator class instance to intilize opportunity and engagement pagination variables.
    */
    private SL_Paginator intializePagination(String fieldDef, Integer paramPageSize, String paramObjectName, 
    											String paramWhereCondition , boolean isFieldSet, Set<Id> setSobjectIdToQuery, 
    											Boolean isIdFilter, String strSortBy, String strSortDirection)
    {
    	SL_Paginator objPaginator = new SL_Paginator(fieldDef, paramPageSize, paramObjectName, paramWhereCondition, isFieldSet, setSobjectIdToQuery, isIdFilter);
    	if(objPaginator.isValidParameters)
		{
			objPaginator.setSortingQueryString(strSortBy, strSortDirection);
			objPaginator.gotoFirstPage();
		}
		return objPaginator;
    }
    /* End */
    
    /*
        @MethodName : searchRecords.
        @param      : NA


        
        @Description: to filter the records on the basis of the filter section on vf page
    */
    public void searchRecords()
    {
    	if(!lstColumnWrapperOpportunity.isEmpty())
    	{
    		String strOppField = (lstColumnWrapperOpportunity[0].isSortable)? lstColumnWrapperOpportunity[0].strFieldAPI : 'Id';
    		opportunityRecords = (strOpportunityOption == 'teamopportunities') 
    						 	  ? intializePagination(strCSVOpportunityFields, PAGE_SIZE, 'Opportunity__c', prepareWhereClause('Opportunity__c'), false, setSobjectIdOpportunity, true, strOppField, 'ASC') 
							 	  : intializePagination(strCSVOpportunityFields, PAGE_SIZE, 'Opportunity__c', prepareWhereClause('Opportunity__c'), false, new Set<Id>(), false, strOppField, 'ASC');
    	}
    	
    	if(!lstColumnWrapperEngagement.isEmpty())
    	{
	       	String strEngField = (lstColumnWrapperEngagement[0].isSortable)? lstColumnWrapperOpportunity[0].strFieldAPI : 'Id';
			engagementRecords = (strEngagementOption == 'teamengagements')
								? intializePagination(strCSVEngagementFields, PAGE_SIZE, 'Engagement__c', prepareWhereClause('Engagement__c'), false, setSobjectIdEngagement, true,strEngField , 'ASC')
								: intializePagination(strCSVEngagementFields, PAGE_SIZE, 'Engagement__c', prepareWhereClause('Engagement__c'), false, new Set<Id>(), false, strEngField, 'ASC');
    	}
							
    }
    /* End */ 
    
    /*
        @MethodName : changeColumns.
        @param      : NA
        @Description: to change the columns of the opportunity and engagement tables.
    */
    public Pagereference changeColumns()
    {
    	Pagereference pageref = new Pagereference('/apex/SL_ChangeColumns');
	   	return pageref;
    }
    /* End */
    
    
   /*
		@MethodName : updateSobjectRecord 
		@param 	    : 
		@Description: method to update Opportunity or Engagement record.
	*/
	@RemoteAction
	public static String updateSobjectRecord(String strSobjectName, String strSobjectId, String strFieldAPIName, String strValue)
	{
		Schema.SobjectType sobjectType = mapGlobalDescribe.get(strSobjectName);
		Sobject sobj = sobjectType.newSObject(strSobjectId); 
		sobj = fieldTypeCasting(sobj, mapSobjectNameToFieldsDescription.get(strSobjectName), strValue, strFieldAPIName);
		Database.SaveResult[] srList = Database.update(new List<Sobject>{sobj}, false);
		Database.SaveResult sr = srList[0];
		if (sr.isSuccess())
			return '';
		else
			return sr.getErrors()[0].getMessage();
	} 	
	/* End */
	
	/*
    	@MethodName : fieldTypeCasting
        @param      :     
        @Description: This method is called to do the type casting.
	*/
	private static Sobject fieldTypeCasting(Sobject sObjTarget, Map<String, Schema.SObjectField> mapFieldDef, String fieldValue, String TargetFieldAPIName)
   	{
   		try
   		{	
   			if(TargetFieldAPIName != null && TargetFieldAPIName != '' && mapFieldDef.containsKey(TargetFieldAPIName) && mapFieldDef.get(TargetFieldAPIName) != null)
   			{
	   			Schema.SObjectField field = mapFieldDef.get(TargetFieldAPIName);
		        Schema.DisplayType fieldType = field.getDescribe().getType();
		        
		        if(fieldValue != null && fieldValue != '' && field.getDescribe().isAccessible())
		        {
		        	if ((fieldType == Schema.DisplayType.DOUBLE) || (fieldType == Schema.DisplayType.CURRENCY))
	             	{
	                 	// Validating field is double or not else giving custom exception
	                 	if(fieldValue.remove('.').isNumeric())	
	                 		sObjTarget.put(TargetFieldAPIName,double.valueOf(fieldValue));
	                 	else
	                 		sObjTarget.addError('Incorrect value for decimal field');
	             	}
	                else if (fieldType == Schema.DisplayType.BOOLEAN)
	                	sObjTarget.put(TargetFieldAPIName,Boolean.valueOf(fieldValue));
	                else if (fieldType == Schema.DisplayType.INTEGER)
	                	sObjTarget.put(TargetFieldAPIName,Integer.valueOf(fieldValue));
	                else if (fieldType == Schema.DisplayType.Date)
	            	{
                		//Replacing '-' to '/'. Date.Parse() method take string in a specific format which takes '/' 
                		List<String> lstDate = new List<String>();
                		fieldValue = fieldValue.replace('00:00:00', '').replaceAll('-', '/').trim();
                		lstDate.addAll(fieldValue.split('/'));
                		Integer intYear = (lstDate[0].length() == 4) ? Integer.valueOf(lstDate[0]) :  Integer.valueOf(lstDate[2]);	
	            		Integer intMonth = (lstDate[0].length() == 4) ? Integer.valueOf(lstDate[1]): Integer.valueOf(lstDate[0]);
	            		Integer intDate = (lstDate[0].length() == 4) ? Integer.valueOf(lstDate[2]): Integer.valueOf(lstDate[1]);
	            		
                		sObjTarget.put(TargetFieldAPIName, Date.newinstance(intYear,intMonth,intDate));
	            	}
	        	 	else if (fieldType == Schema.DisplayType.Id)
	        	 		sObjTarget.put(TargetFieldAPIName,Id.valueOf(fieldValue));
	        	 	else if(fieldType == Schema.DisplayType.DateTime)
	        	 	{
	        	 		fieldValue = fieldValue.replaceAll('/','-');
	        	 		if(fieldValue.split('/')[0].length() == 4)
	        	 		{
		        	 		List<String> lstDate = new List<String>();
							String strDate = fieldValue.split(' ')[0];
							String strTime = (fieldValue.split(' ').size() > 1) ? fieldValue.split(' ')[1] : '00:00:00';
							lstDate.addAll(strDate.split('-'));
							fieldValue = lstDate[2] + '-' + lstDate[0] + '-' + lstDate[1] + ' ' + strTime;
	        	 		}
	        	 		
                		sObjTarget.put(TargetFieldAPIName,DateTime.valueOf(fieldValue));
	        	 	}
	                else  // Checking with field length and populating string with accommodate size
	               	{
	                	sObjTarget.put(TargetFieldAPIName,String.valueOf(fieldValue).length() > field.getDescribe().getLength() 
	                														? String.valueOf(fieldValue).substring(0,field.getDescribe().getLength()) 
	                														:String.valueOf(fieldValue));
	               	}
		        }
		        else if(fieldValue == '')
		        {
		        	sObjTarget.put(TargetFieldAPIName, null);
		        }
   			}
   		}
   		catch(Exception ex)
   		{
   			sObjTarget.addError(''+ ex.getMessage());
   		}
   		return sObjTarget;
   }
    /* End */
    
    /*
        @MethodName : displayCloseDate 
        @param      : NA.
        @Description: method to display the close date on engagement filters section based on Active & Closed picklist values.
    */
	public void displayCloseDate()
	{
		if(strEngagementOpenOrClosed == 'Closed')
		{
			isDisabled = false;
			Date dtStart = date.newInstance(Date.today().Year(), 1, 1);//Date.today().addDays(-30);
	        Date dtEnd = date.newInstance(Date.today().Year(), 12, 31);//Date.today();
	        dtEngagementFromDate = dtStart.month() + '/' + dtStart.day() + '/' + dtStart.year();
	        dtEngagementToDate = dtEnd.month() + '/' + dtEnd.day() + '/' + dtEnd.year();
		}
		else
		{
			isDisabled = true;
	        dtEngagementFromDate = '';
	        dtEngagementToDate = '';
		}
	}
	/* End */
	
	/*
        @MethodName : getPicklistValue 
        @param      : Sobject name and filed api name.
        @Description: method to get picklist value from field.
    */
    private List<SelectOption> getPicklistValues(String strSobjectName, String strFieldName)
    {
        List<SelectOption> options = new List<SelectOption>();
        Schema.SObjectType targetType = mapGlobalDescribe.get(strSobjectName);//!< From the Object Api name retrieving the SObject
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType(); //!< grab the sobject that was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //!< describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //!< get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pick_list_values = field_map.get(strFieldName).getDescribe().getPickListValues(); 
                                                        //!< grab the list of picklist values for the passed field on the sobject
        for (Schema.PicklistEntry a : pick_list_values) 
        { 
            options.add(new SelectOption(a.getLabel(), a.getValue()));
        }
        return options;
    }
    /* End */    
}