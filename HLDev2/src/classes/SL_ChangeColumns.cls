/**  
* \arg ClassName      : SL_ChangeColumns
* \arg JIRATicket     : HL-17
* \arg CreatedOn      : 4/JUNE/2014
* \arg LastModifiedOn : 4/JUNE/2014
* \arg CreatededBy    : Lodhi
* \arg ModifiedBy     : -
* \arg Description    : This is controller class for SL_ChangeColumns page.
*/
public with sharing class SL_ChangeColumns 
{
	/* Start Variables */
	public PicklistWrapper opportunityPicklist  			{   get;set;    }//!< Opportunity multiselected picklist.   
    public PicklistWrapper engagementPicklist   			{   get;set;    }//!< Engagement multiselected picklist.
    
    private Pipeline_Column_Selection__c objPCS;
    private Map<String, Schema.SObjectType> mapGlobalDescribe = Schema.getGlobalDescribe();
	/* End Variables */ 
	
	/* Start - Constructor */
    public SL_ChangeColumns() 
    {
    	objPCS = getPCS();
    	opportunityPicklist = getPicklistValues(objPCS.Opportunity_Columns__c.split(','), 'Opportunity__c');
	    engagementPicklist = getPicklistValues(objPCS.Engagement_Columns__c.split(','), 'Engagement__c');
    }
    /* End - Constructor */
    
    /* Start - Wrapper Class for Picklist */
    public class PicklistWrapper
    {
        public List<SelectOption> allValues     {   get;set;    }
        public List<SelectOption> selectedValues{   get;set;    }
        
        public PicklistWrapper(List<SelectOption> allValues, List<SelectOption> selectedValues)
        {
            this.allValues = allValues;
            this.selectedValues = selectedValues;
        }
    }
    /* End - Wrapper Class for Picklist */
    
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
        @MethodName : getPicklistValues.
        @param      : Set of selected fields and sobject name.
        @Description: to get the options to display the engagements records.
    */
   private PicklistWrapper getPicklistValues(List<String> lstSelectedFields, String SobjectName)
   { 
        List<SelectOption> optionsSelected = new List<SelectOption>();
        List<SelectOption> optionsAvailable = new List<SelectOption>();
        Set<String> setSelectedFields = new Set<String>();
        for(String strSelectedField : lstSelectedFields)
        {
        	if(mapGlobalDescribe.get(SobjectName).getDescribe().fields.getMap().containsKey(strSelectedField.trim()))
        	{
        		setSelectedFields.add(strSelectedField.trim());
        		Schema.SObjectField field = mapGlobalDescribe.get(SobjectName).getDescribe().fields.getMap().get(strSelectedField.trim());
        		optionsSelected.add(new SelectOption(field.getDescribe().getName(), field.getDescribe().getLabel()));
        	}
        }
        
		for(Schema.SObjectField field  :  mapGlobalDescribe.get(SobjectName).getDescribe().fields.getMap().values())
		{
			if(field.getDescribe().isAccessible())
			{
				if(!setSelectedFields.contains(field.getDescribe().getName()))
					optionsAvailable.add(new SelectOption(field.getDescribe().getName(), field.getDescribe().getLabel()));
			}
		}
		optionsAvailable.sort();
        return new PicklistWrapper(optionsAvailable, optionsSelected);
   	}
    /* End */
   
   	 /*
        @MethodName : getCSVFields.
        @param      : NA
        @Description: to get the fields value of the Objects
    */
    private String getCSVFields(List<SelectOption> options)
    {
    	String strCSVFields =  ''; 
    	for(SelectOption option : options)
		{
       		strCSVFields += (strCSVFields == '') ? option.getValue() : ',' +	option.getValue();
		}
		return strCSVFields;
    }
    /* End */
     
    /*
        @MethodName : saveChangeColumn.
        @param      : NA
        @Description: on save change column page.
    */
    public Pagereference saveChangeColumn()
    {
		if(!opportunityPicklist.selectedValues.isEmpty() && !engagementPicklist.selectedValues.isEmpty())
		{
	       	objPCS.Opportunity_Columns__c =  getCSVFields(opportunityPicklist.selectedValues);
	       	objPCS.Engagement_Columns__c = getCSVFields(engagementPicklist.selectedValues);
	       	upsert objPCS;
	       	 
	    	Pagereference pageref = new Pagereference('/apex/SL_PipelineManager');  
		   	return pageref;
		}
		else
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select atleast one field from picklist.'));
			return null;
		}
    }
    /* End */
    
   
    /*
        @MethodName : cancelChangeColumn.
        @param      : NA
        @Description: on cancel change column page.
    */
    public Pagereference cancelChangeColumn()
    {
    	Pagereference pageref = new Pagereference('/apex/SL_PipelineManager');
	   	return pageref;
    }
    /* End */
}