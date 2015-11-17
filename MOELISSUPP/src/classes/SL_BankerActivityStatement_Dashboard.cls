/**
 * \author Vika Osmak 
 * \date 03/29/12
 * \see https://silverline.jira.com/browse/MBS-3
 * \brief Test Class for class SL_SeniorBankerScorecard_Dashboard 
 */
public with sharing class SL_BankerActivityStatement_Dashboard 
{
	public Date sDate {get; set;}
	public SL_TmpObjects__c tmpObj {get; set;}
	private Boolean isError;
	
	String filter;
	public String getFilter() 
	{
	    return this.filter;
	}
	public void setFilter(String p_filter) 
	{
	    this.filter = p_filter;
	}
	
	String[] subFilters;
	public String[] getSubFilters() 
	{
	    return this.subFilters;
	}
	public void setSubFilters(String[] p_subfilters) 
	{
	    this.subFilters = p_subfilters;
	}
	
	private set<String> listMDSCTitles;
	private set<String> listExcludeGroups;
	private list<picklistItem> subFilter_values {get; set;}
	private list<reporItem> report_values {get; set;}
	public list<reporItem> getReport_values() 
	{
	    return this.report_values;
	}
	
	public SL_BankerActivityStatement_Dashboard()
	{
		tmpObj = new SL_TmpObjects__c(Start_Date__c = Date.today(),End_Date__c = Date.today());
		
		isError = false;
		
		listMDSCTitles = getSeniorBankerTitles();
		listExcludeGroups = getExcludeGroups();
		system.debug('listMDSCTitles='+listMDSCTitles);
		
		this.filter = 'banker';
		changeFilter();
	}
	
	public static set<String> getSeniorBankerTitles()
	{
		set<String> listMDSCTitles = new set<String>();
		Schema.DescribeFieldResult fieldResult = Employee_Profile__c.Title__c.getDescribe();
        List<Schema.PicklistEntry> PickilstValues = fieldResult.getPicklistValues();
		set<String> employeeTitles = new set<String>();
		list<MDSC_Titles__c> MDSCTitles = MDSC_Titles__c.getall().values();
		
		if(MDSCTitles != null)
		{
			for(MDSC_Titles__c item : MDSCTitles) 
				employeeTitles.add(item.Name);
			for (Schema.PicklistEntry pVal : PickilstValues)
			{
				if(employeeTitles.contains(pVal.value))	listMDSCTitles.add(pVal.value);
			}
		}
		return listMDSCTitles;
	}
	
	public static set<String> getExcludeGroups()
	{
		set<String> listExcludeGroups = new set<String>();
		Schema.DescribeFieldResult fieldResult = Employee_Profile__c.Group__c.getDescribe();
        List<Schema.PicklistEntry> PickilstValues = fieldResult.getPicklistValues();
		set<String> employeeGroups = new set<String>();
		list<MDSC_Exclude_Groups__c> MDSCExcludeGroups = MDSC_Exclude_Groups__c.getall().values();
		
		if(MDSCExcludeGroups != null)
		{
			for(MDSC_Exclude_Groups__c item : MDSCExcludeGroups) 
				employeeGroups.add(item.Name);
			for (Schema.PicklistEntry pVal : PickilstValues)
			{
				if(employeeGroups.contains(pVal.value))	listExcludeGroups.add(pVal.value);
			}
		} 
		return listExcludeGroups;
	}
	
	/*Start : Added by lodhi for new button MBS-87 on july 19*/
	public void checkErrors()
	{
		report_values = new List<reporItem>();
		isError = false;
		if(	this.filter == '' || this.subFilters.size() == 0)
		{
           ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR,'All Filters should be selected.'));
           isError = true;
        }
		Date todayDate = Date.today();
        if(	!(	tmpObj.Start_Date__c != null && 
        		tmpObj.End_Date__c != null &&
        		tmpObj.Start_Date__c <= todayDate &&
        		tmpObj.End_Date__c <= todayDate &&
        		tmpObj.Start_Date__c < tmpObj.End_Date__c) 	)
		{
           ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR,'End Date must be later than Start Date. Both End Date and Start Date must be <= TODAY.'));
           isError = true;
        }
	}
	/*End : Added by lodhi for new button MBS-87 on july 19*/
	
	public PageReference runReportV1()
	{
		//Start : Added by lodhi for new button MBS-87 on july 19
        checkErrors();
        //End : Added by lodhi for new button MBS-87 on july 19
        
        if(!isError)
        {
			String subFIds = '';
			if(this.subFilters.size() > 0)
			{
				for(String sId : this.subFilters)
				{
					if(subFIds.length() == 0)	subFIds = sId;
					else subFIds += ';'+sId; 
				}
			}
			PageReference pageRef = new PageReference('/apex/SL_BankerActivityStatement_Report?filter='+this.filter+'&subfilters='+EncodingUtil.urlEncode(subFIds, 'UTF-8')+'&sdate='+String.valueOf(tmpObj.Start_Date__c)+'&edate='+String.valueOf(tmpObj.End_Date__c));
			pageRef.setRedirect(true);
	        return pageRef;
        }
		return null;
	}
	
	/*Start : Added by lodhi for new button MBS-87 on july 19*/
	public PageReference runReportV2()
	{
		checkErrors();
        if(!isError)
        {        	
			String subFIds = '';
			if(this.subFilters.size() > 0)
			{
				for(String sId : this.subFilters)
				{
					if(subFIds.length() == 0)	subFIds = sId;
					else subFIds += ';'+sId; 
				}
			}
			//PageReference pageRef = new PageReference('/apex/SL_BankerDashboard_Report?filter='+this.filter+'&subfilters='+EncodingUtil.urlEncode(subFIds, 'UTF-8')+'&userId='+loggedInUserId+'&sdate='+String.valueOf(tmpObj.Start_Date__c)+'&edate='+String.valueOf(tmpObj.End_Date__c));
            PageReference pageRef = new PageReference('/apex/SL_BankerDashboard_Report?filter='+this.filter+'&subfilters='+EncodingUtil.urlEncode(subFIds, 'UTF-8')+'&sdate='+String.valueOf(tmpObj.Start_Date__c)+'&edate='+String.valueOf(tmpObj.End_Date__c));
			pageRef.setRedirect(true);
	        return pageRef;
        }
		return null;
	}
	/*End : Added by lodhi for new button MBS-87 on july 19*/
	
	public List<SelectOption> getFilterItems()
	{
	    List<SelectOption> options = new List<SelectOption>();
	    options.add(new SelectOption('banker','Banker'));
	    options.add(new SelectOption('title','Title'));
	    options.add(new SelectOption('group','Group'));
	    options.add(new SelectOption('location','Office Location'));
	    return options;
	}
	public List<SelectOption> getSubFilterItems()
	{
	    List<SelectOption> options = new List<SelectOption>();
	    if(subFilter_values.size() > 0)
	    {
	    	list<String> listForSelectFirst = new list<String>();
	    	for(picklistItem item : subFilter_values)
	    	{
	    		if(listForSelectFirst.size() == 0) listForSelectFirst.add(item.value); 
	    		options.add(new SelectOption(item.value,item.label));
	    	}
	    	setSubFilters(listForSelectFirst);
	    }
	    return options;
	}
	
	
	public void changeFilter()
	{
		subFilter_values = new List<picklistItem>();
		Schema.DescribeFieldResult fieldResult;
		List<Schema.PicklistEntry> PickilstValues;
		
		if(this.filter == 'banker')
		{
			for(Employee_Profile__c item : [ 
					SELECT Id,Last_Name__c,First_Name__c
					FROM Employee_Profile__c
					WHERE 	Status__c = 'Active' AND 
							Business_Type__c = 'Advisory' AND
							Group__c NOT IN :listExcludeGroups AND 
							Title__c IN : listMDSCTitles
					ORDER BY Last_Name__c, First_Name__c])
			{
				subFilter_values.add(new picklistItem(item.Id,item.Last_Name__c+', '+item.First_Name__c));
			}
		}
		else if(this.filter == 'title')
		{
			for(String item : listMDSCTitles)
			{
				subFilter_values.add(new picklistItem(item,item));
			}
		}
		else if(this.filter == 'group')
		{
			fieldResult = Employee_Profile__c.Group__c.getDescribe();
	        PickilstValues = fieldResult.getPicklistValues();
			for (Schema.PicklistEntry pVal : PickilstValues)	
			{
				if(!listExcludeGroups.contains(pVal.value))subFilter_values.add(new picklistItem(pVal.value,pVal.label));
			}	
		}
		else if(this.filter == 'location')
		{
			fieldResult = Employee_Profile__c.Office_Location__c.getDescribe();
	        PickilstValues = fieldResult.getPicklistValues();
			for (Schema.PicklistEntry pVal : PickilstValues)	
			{
				subFilter_values.add(new picklistItem(pVal.value,pVal.label));
			}
		}
		
	}
	
	public class reporItem 
	{
        public string title {get; set;}
        public list<picklistItem> links {get; set;}
        
        public reporItem(string ttl, list<picklistItem> lnks)
        {
            title = ttl; 
            links = lnks;            
        }
    }
	public class picklistItem 
	{
        public string value {get; set;}
        public string label {get; set;}
        
        public picklistItem (string val, string lbl)
        {
            value = val;
            label = lbl;            
        }
    }

}