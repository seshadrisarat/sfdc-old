/** 
* \arg ClassName  : SL_IntranetQuickCreate
* \arg JIRATicket : SOCINT-285
* \arg CreatedOn  : Rahul, 16/Sep/2013 
* \arg ModifiedBy : Lodhi, 08/Oct/2013 
* \arg Description:
*/  

public with sharing class SL_IntranetQuickCreate extends WidgetAbstract implements IObservable
{
	public QuickCreateConfig objQConfig 									{get;set;}
	public sObject sObjectSelected                                          {get;set;} /// variable used to store the sObject
	public Boolean isShowWidget												{get;set;}
	public Boolean isShowSObject											{get;set;}
	public Boolean isShowFieldSet											{get;set;}
	public Boolean isShowHardCodedFieldSet									{get;set;}
	public Boolean isShowNoFieldsPageMessage                                {get;set;} /// variable used to show page message when there are no fields
	public Boolean isShowCreatePageMessage                                  {get;set;} /// variable used to show page message when records are created
	public Boolean isShowMainSection						                {get;set;} /// variable used to show mainSection            
	public Boolean isShowInitialButton						                {get;set;} /// variable used to show initial button
	public Boolean isShowFields                                             {get;set;} /// variable used to render fields section in the component
	public Boolean isError													{get;set;}
	
	public String strSelectedFieldSet       								{get;set;} /// variable used to store  fieldset 
	public String strError       											{get;set;} /// variable used to store  Error message 
	public String strDeptId{get;set;}
    public String strSelectedSobject                                        {get;set;} /// variable used to store Sobject selected by user from QuickCreate widget. 
    public String strSelectedFieldSetOfSobject                              {get;set;} /// variable used to store FieldSet of Sobject selected by user from QuickCreate widget.
	
	public  List<SobjectFieldDetail> lstRequiredField 						{get;set;}													/// variable used to store field names
    public List<SelectOption> lstFieldSet                                   {get;set;} /// variable used to store list of fieldsets for selected object
	public List<SelectOption> lstSObjects                                   {get;set;} /// variable used to store sObjects
	
	private Map<String, Schema.SObjectType> mapGlobalDescribe;
	private String strSobject;
	private Map<String, String> mapDeptIdToDeptName = new Map<String, String>();
	private Boolean bObjAccCreate;
	private Boolean isDepartmentWidgetExist; //To identify if Department widget exist on page or not to decide the behavior based on that. 
	
	///Constructor
	public SL_IntranetQuickCreate()
	{
		initializeVariables();
	}
	
	public override protected void initialize()
	{
		strDeptId = '';
		isDepartmentWidgetExist = false;
		mapGlobalDescribe = Schema.getGlobalDescribe(); 
		mapDeptIdToDeptName = new Map<String, String>();
		objQConfig = new QuickCreateConfig(); 
		configuration();
		  // listener for department widget dependancy
		WidgetConfigurationListener.getInstance().addEventListener('SL_IntranetDepartments', this); 
	}
	
	// Depends on Department configuration, so is executed after post initializtion
	override public void postInitialize()
	{
		if(!bObjAccCreate)
			showInitialSection();
	}
	
	 /* Start - Method for getting notification records 
       @Name           - notify
       @Return Type    - void
       @Description    - Function for getting initial selection dept Id 
    */
	public void notify(IWidget widget) 
	{
		if(widget == null) return;
		SL_IntranetDepartments departmentWidget = (SL_IntranetDepartments)widget;
		strDeptId = departmentWidget.strInitialDeptSelection;
		mapDeptIdToDeptName = departmentWidget.mapDeptIdToName;
		isDepartmentWidgetExist = true;
	}
	
	 /**
       * Name: initialize 
       * Parameters: NA
       * Description: This method is used to initialize all global variables of a class
     */
	public void initializeVariables()
	{
		isShowWidget = isShowFields = isError = isShowNoFieldsPageMessage = isShowMainSection = isShowInitialButton = isShowCreatePageMessage = false;
		strDeptId = strSelectedSobject = strSelectedFieldSetOfSobject = strSobject = '';
		bObjAccCreate = false;
		lstFieldSet = new List<SelectOption>();
		lstRequiredField = new List<SobjectFieldDetail>();
		lstSObjects = new List<SelectOption>();
	}
	
	
	//Inner class is to hold configuration fields.
	public class QuickCreateConfig
	{ 
		 private String sobjectName;				 /// variable to store sobject name
		 String fieldSetName ; /// variable to store field set name
		 Set<String> setDepartment;
		 Boolean logTransaction	; /// variable to decide weather we need upsert  Intranet Requests record to fire wokflow.
		 
		 public QuickCreateConfig()
		 {
		 	sobjectName = fieldSetName = '';
		 	setDepartment	= new Set<String>{};
		 	this.logTransaction = false;
		 }
	}
	
	  //Wrapper Class for Field Name and FieldLabel
    public class SobjectFieldDetail
    {
    	public String fieldAPIName	{	get;set;	}// Field API Name.
		public String fieldLabel	{	get;set;	}// Field label
    	
    	
    	public SobjectFieldDetail(String fieldAPIName, String fieldLabel)
		{
			this.fieldAPIName = fieldAPIName;
			this.fieldLabel = fieldLabel;
		}
    }
    
	public void configuration()
	{
		if(this.properties != null)
		{
			String strDepartment;
			
			objQConfig.sobjectName = String.valueOf(((map<String, object>)properties).get('sobjectname'));
			
			objQConfig.fieldSetName = String.valueOf(((map<String, object>)properties).get('fieldsetname'));
			
			
			if(((map<String, object>)properties).get('successresponse') == null || ((map<String, object>)properties).get('successresponse') == '')
			{  
				((map<String, object>)properties).put('successresponse','Your request has been submitted for approval. You will be notified by email once complete.');
			}
			if(((map<String, object>)properties).get('savebutton') == null || ((map<String, object>)properties).get('savebutton') == '')
			{
				((map<String, object>)properties).put('savebutton','Save');
			}
			
			
			if(((map<String, object>)properties).get('initialbutton') == null || ((map<String, object>)properties).get('initialbutton') == '')
			{
				
				((map<String, object>)properties).put('initialbutton','Quick Create');
				
			}
			if(((map<String, object>)properties).get('heading') == null || ((map<String, object>)properties).get('heading') == '')
			{
				((map<String, object>)properties).put('heading','Quick Create');
			}
			
			if(((map<String, object>)properties).get('backgroundcolor') == null || ((map<String, object>)properties).get('backgroundcolor') == '')
			{
				((map<String, object>)properties).put('backgroundcolor','white');
			}
			
			objQConfig.logTransaction = Boolean.valueOf(((map<String, object>)properties).get('logtransaction'));

			if(String.isNotBlank(objQConfig.sobjectName) && !getObjectAccess('create', mapGlobalDescribe.get(objQConfig.sobjectName)))
			{
				bObjAccCreate =  true;
				return; 
			}
			
			if((String.isNotBlank(objQConfig.sobjectName) == null || objQConfig.sobjectName == '') && (objQConfig.fieldSetName == null || objQConfig.fieldSetName == ''))
				isShowWidget = false;
			else 
				isShowWidget = true;
				
			strError ='';
			strDepartment = String.valueOf(((map<String, object>)properties).get('department'));
			
			if(String.isNotBlank(strDepartment))
			{
				for(String s: strDepartment.split(','))
				{
					objQConfig.setDepartment.add(s.trim().toUpperCase());
				}
			}

			///check if sObject parameter is present in JSON
			if(String.isNotBlank(objQConfig.sobjectName))
			{
				isShowSObject = false;
				strSelectedSobject = objQConfig.sobjectName;
				
				///check if Field set parameter is present in JSON
				if(String.isNotBlank(objQConfig.fieldSetName))
				{
					strSelectedFieldSet = objQConfig.fieldSetName;
					isShowFieldSet = true;
					isShowHardCodedFieldSet = true;
				}
				else
				{
					isShowHardCodedFieldSet = false;
				}
			}
			else
			{
				isShowHardCodedFieldSet = false;
				strSelectedSobject = 'None';
				isShowSObject = true;
			}
		}
	}
	
	
	/**
       * Name: showMainSection 
       * Parameters: NA
       * Description: This method is used to intialise values to show main section
     */
	public void showInitialSection()
	{
		isShowInitialButton = false;
		isShowMainSection = false;
		if(!isDepartmentWidgetExist)
		{
			isShowInitialButton = true;
			return;
		}
		if(objQConfig.setDepartment.size()==0)
		{
			if(strDeptId =='')
				isShowInitialButton = true;
		}
		else
		{
			if(objQConfig.setDepartment.contains('ALL DEPARTMENTS') && strDeptId !='')
				isShowInitialButton = true;
			else if(strDeptId == 'All' && new Set<String>(mapDeptIdToDeptName.values()).removeAll(objQConfig.setDepartment))
				isShowInitialButton = true;
			else if(objQConfig.setDepartment.contains(mapDeptIdToDeptName.get(strDeptId)))
				isShowInitialButton = true;
		}
	}
	
	/**
       * Name: showMainSection 
       * Parameters: NA
       * Description: This method is used to intialise values to show main section
     */
	public void showMainSection()
	{
		isError = false;
		isShowMainSection = true;
		isShowInitialButton = true;
		isShowCreatePageMessage = false;
		isShowFields = false;
		isShowFieldSet = false;
		if(String.isBlank(objQConfig.sobjectName))
			SobjectNames();
		else
		{
			FieldSetNamesOfSelectedSObject();
		}
	}
	
	
	 /**
       * Name: getSobjectNames
       * Parameters: NA
       * Description: This method is used to get all SObjectNames for displaying in SObject picklist of QuickCreate widget
     */
	public void SobjectNames()
    {
       List<Schema.SObjectType> SObjectNames = mapGlobalDescribe.Values(); 
       List<Schema.SObjectType> SObjectNamesThatCanBeCreated = new List<Schema.SObjectType>();
       Map<String,Schema.SObjectType> mapSobjectLabel_Type = new Map<String,Schema.SObjectType>(); /// map to store label as key and Schema.SObjectType as value
       lstSObjects = new List<SelectOption>();
       /// Create a list of Required fields for the selected object
       for(Schema.SObjectType objSObject:SObjectNames)
       {
       		if(getObjectAccess('create', objSObject))
       		{
       			SObjectNamesThatCanBeCreated.add(objSObject);
       			mapSobjectLabel_Type.put(objSObject.getDescribe().getLabel(),objSObject);
       		}
       }
       
       List<String> lstLabel = new List<String>(); ///List to store ordered label of objects
       lstLabel.addAll(mapSobjectLabel_Type.keyset());
       lstLabel.sort();
       
       lstSObjects.add(new SelectOption('None','- None -'));
       ///Create a list of selectoptions
	   for(String str : lstLabel)
	   {
	   	  lstSObjects.add(new SelectOption(mapSobjectLabel_Type.get(str).getDescribe().getName(),mapSobjectLabel_Type.get(str).getDescribe().getLabel()));
	   }
    }
    
    /**
       * Name: FieldSetNamesOfSelectedSObject
       * Parameters: NA
       * Description:This method is used to get all FieldSets names of selected SObject for displaying in FieldSet picklist of QuickCreate widget.
     */
	public void FieldSetNamesOfSelectedSObject()
    { 
    	isError = false; 
    	if(strSelectedSobject == 'None')
    	{
    		strSelectedFieldSetOfSobject = '';
    		isShowNoFieldsPageMessage = isShowCreatePageMessage = isShowFieldSet = isShowFields = false;
    		lstFieldSet = new List<SelectOption>();
    	}
    	
		if(strSelectedSobject != 'None')
    	{
    		strSelectedFieldSetOfSobject = '';
    		isShowNoFieldsPageMessage = isShowCreatePageMessage = false ;
    		lstFieldSet = new List<SelectOption>();
    		
    		strSobject = strSelectedSobject.toLowerCase();
    		
    		if(mapGlobalDescribe.containsKey(strSobject))
    		{
		        Schema.DescribeSObjectResult DescribeSObjectResultObj = mapGlobalDescribe.get(strSobject).getDescribe();
				
		        if(DescribeSObjectResultObj.FieldSets.getMap().containsKey(strSelectedFieldSet))
		        	{
		        		strSelectedFieldSetOfSobject = strSelectedFieldSet;
		        		isShowFields = true;
		        		retrieveAllFields();
		        	}
		        else
		        {
		        	lstFieldSet.add(new SelectOption('None','- None -'));
			        ///Create a list of fieldsets for the selected object
			        for(String str : DescribeSObjectResultObj.FieldSets.getMap().keySet())
			        {
			        	String label = DescribeSObjectResultObj.FieldSets.getMap().get(str).getLabel();
			        	lstFieldSet.add(new SelectOption(str,label));
			        }
			        
			        ///check if fields sets are present for selected object
			        if(lstFieldSet.size() > 1)
			        {
				        isShowFieldSet = true;
				        isShowFields = false;
			        }
			        else
			        {
			        	isShowFieldSet = false;
				    	retrieveRequiredFields();
				    	if(lstRequiredField.size() == 0)
				    	{
				    		isShowNoFieldsPageMessage = true;
					    	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'No Required fields and field set for selected object'));
					    	isShowFields = false;
				    	}
				    	else
				    	{
				    		isShowFields = true; 
				    	}
			        }
		        }
    		}
    	}
    }
    
    /**
       * Name: retrieveRequiredFields
       * Parameters: NA
       * Description:This method is used to get all required Fields.
     */
    public void retrieveRequiredFields()
    {
	    Schema.SObjectType SObjectTypeObj = mapGlobalDescribe.get(strSobject); /// Get the sObjecttype
		sObjectSelected = SObjectTypeObj.newSObject(); ///Get the Sobject
		lstRequiredField = new List<SobjectFieldDetail>();
		
        for (Schema.SObjectField field : SObjectTypeObj.getDescribe().fields.getMap().values())  
        {
           	Schema.DescribeFieldResult fieldResult = field.getDescribe(); 
           	/// check if field is required 
           	if(fieldResult.isCreateable() && !fieldResult.isNillable()  && !fieldResult.isDefaultedOnCreate())
           	{
           	   lstRequiredField.add(new SobjectFieldDetail(fieldResult.getName(), fieldResult.getLabel()));
           	}
        }
    }
    
    
    
    /**
       * Name: retrieveAllFields
       * Parameters: NA
       * Description:This method is used to get all Fields in a fieldset.
     */
    public void retrieveAllFields()
    {
    	isError = false; 
    	if(strSelectedFieldSetOfSobject == 'None')
		{
			isShowFields = false;
			return;
		}
			
    	else
    	{
    		Boolean isFieldSetPresent = false;
    		isShowNoFieldsPageMessage = isShowCreatePageMessage = false;
		    retrieveRequiredFields();
		    lstRequiredField = new List<SobjectFieldDetail>();
			if(String.isNotBlank(strSelectedFieldSetOfSobject) || String.isNotBlank(strSelectedFieldSet)) 
		    {
		    	isFieldSetPresent = true;
			    String selectFieldSetName = '';
			    selectFieldSetName = String.isNotBlank(strSelectedFieldSetOfSobject) ? strSelectedFieldSetOfSobject :(String.isNotBlank(strSelectedFieldSet) ? strSelectedFieldSet :''); 
			    	
			    if(selectFieldSetName != 'None')
			    {
				   	isShowFieldSet = true;
		    		isShowFields = true;
			    }
			    else
			    {
					isShowCreatePageMessage = isShowInitialButton = isShowFields = false;
					
					isShowSObject = isShowFieldSet = isShowMainSection = isShowNoFieldsPageMessage = true;
		    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'No Required fields and field set for selected object'));
					return;
			    }
		    }
			
		    if(!isFieldSetPresent)
		    {
		    	isShowFieldSet = false;
		    }
    	}
    }
   
  
    
    /**
       * Name: btnCreateRecords
       * Parameters: NA
       * Description:This method is used to create Intranet Request Object records.
     */
    public void btnCreateRecords()
    {
		try
		{
			insert sObjectSelected;//dml
				
			if(objQConfig.logTransaction)
			{
				User objUser = [Select Username, Email,Department from User where Id=: UserInfo.getUserId() limit 1]; /// query user object of current logged in user
				Intranet_Request_Object__c objIntranetRequestObject = new Intranet_Request_Object__c ();
				
				//Query to get the exist records.
				for(Intranet_Request_Object__c objIR : [SELECT Id FROM Intranet_Request_Object__c WHERE Object_Name__c =: strSelectedSobject LIMIT 1])
					objIntranetRequestObject = objIR;
				
				objIntranetRequestObject.Record_Id__c = sObjectSelected.Id;
				objIntranetRequestObject.Object_Name__c = strSelectedSobject;
				objIntranetRequestObject.UserName__c = objUser.Username;
				objIntranetRequestObject.UserEmail__c = objUser.Email;
				objIntranetRequestObject.Department__c  = objUser.Department;
				upsert objIntranetRequestObject;
			}
			
			if(isShowSObject == true)
			{
				strSelectedSobject = 'None';
			}
			isShowFieldSet = isShowFields = isShowCreatePageMessage = isShowMainSection = isError = false;
			isShowCreatePageMessage = isShowInitialButton = true;
			strError = '';
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,String.valueOf(((map<String, object>)properties).get('successresponse'))));
		}
		catch(Exception ex)
		{
			if(String.valueOf(ex.getMessage()).contains('ERROR'))
				strError = ex.getMessage();
			else
				strError = 'ERROR : ' + ex.getMessage();
			isShowCreatePageMessage = false;
			isError = true;
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
		}
    }
    
    public void getFilteredByDepartment()
    {
    	btnCancel(); // To reset all details of previously selected options
    	showInitialSection();    	
    }
    
    public Boolean getHasNoRequiredFields() {
    	return lstRequiredField.isEmpty();
    } 
    
    /*
    ** Returns selected fieldset memmbers
    */
    public List<Schema.FieldSetMember> getFieldSetMembers() {    	
		Schema.DescribeSObjectResult DescribeSObjectResultObj = mapGlobalDescribe.get(strSelectedSobject).getDescribe();				
		if(DescribeSObjectResultObj.FieldSets.getMap().containsKey(strSelectedFieldSetOfSobject)) {
			return DescribeSObjectResultObj.FieldSets.getMap().get(strSelectedFieldSetOfSobject).getFields();
		}
		return new List<Schema.FieldSetMember>();
    }
    
    /**
       * Name: btnCancel
       * Parameters: NA
       * Description:This method is used to cancel
     */
    public void btnCancel()
    {
    	isShowFields = isShowMainSection = isError = isShowFieldSet = false;
		strSelectedSobject = objQConfig.sobjectName;
    }
    
	//Function for creating Component dynamically.
	public override ApexPages.Component newComponent() 
	{
		Component.c.SL_IntranetQuickCreate c = new Component.c.SL_IntranetQuickCreate();   
		c.aComponentImpl = this;
    	return c;
  	} 
}