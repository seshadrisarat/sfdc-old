public with sharing abstract class SL_IntranetDepartments extends WidgetAbstract
{
	public List<Department> lstDepartments {get;set;}
	

	public String initialSelection {get; set;}	
	public String strInitialDeptSelection {get; set;}
	public String strInitialState {get; set;}
	
	//This is useful for those widgets where departments are being set through configuration. E.g Banner, Quick create etc...
	public Map<String, String> mapDeptIdToName {get;set;}
	
	public Boolean IsHidden { 
		get{
			return !String.isEmpty(strInitialState) && strInitialState.equalsIgnoreCase('hidden');
		}
	}
	
	private Map<String, String> mapDeptIds = new Map<String, String>();
	

	/* Wrapper class for Department records */
	public class Department 
	{
		public String deptName {get;set;}
		public String strDeptId{get;set;}
		
		public Department(String deptName, String strDeptId)
		{
			this.deptName = deptName;
			this.strDeptId = strDeptId;
		}
	}
	/* End : Wrapper class for Department records*/
	
	
	/* Constructor initialization */
	public SL_IntranetDepartments()
	{
		lstDepartments = new List<Department>();
		strInitialDeptSelection = '';
		mapDeptIds = new Map<String, String>();
		mapDeptIdToName = new Map<String, String>();
	}
	/* End : Constructor initialization */
	
	
	/* Start - 			Method for getting options in selectlist of Department.
	   @Name           - fetchDepartmentValues
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for getting options in selectlist of Apps&Links.
	*/ 
	public void fetchDepartmentValues()
	{
		//Adding extra options
		lstDepartments.add(new Department('--None--', ''));
		lstDepartments.add(new Department('All Departments', 'All'));
		
		//Getting records for Departments widget
		for(Department__c obj : [Select Id, Name From Department__c WHERE Name != null order by Name ASC])
		{
			lstDepartments.add(new Department(obj.name, obj.Id));
			mapDeptIds.put(obj.Name.toUpperCase(), obj.Id);
			mapDeptIdToName.put(obj.Id, obj.Name.toUpperCase());
		}
			
	}
	/* End : fetchDepartmentValues method */
	
	
	/* @Name           - widgetConfiguration
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for getting configuration of widget.
	*/ 

	override protected void initialize()
	{
		if(!getObjectAccess('read', new Department__c().getsObjectType()))
			return ;
		//Fetching Department values
		fetchDepartmentValues();
		
		if(this.properties != null) {
			Map<String, Object> configuration = (Map<String, Object>)this.properties;
			
			if(configuration.containsKey('initialstate')) {				
				System.debug('SL_DEBUG: department initial state: ' + configuration.get('initialstate'));
				
				strInitialState = (String)configuration.get('initialstate');
			}
			
			if(configuration.containsKey('initialselection')) {
				initialSelection = (String)configuration.get('initialselection');
				
				if(!String.isEmpty(initialSelection)) {
					System.debug('SL_DEBUG: department initialselection: ' + initialselection);					 
					strInitialDeptSelection = (mapDeptIds.containskey(initialSelection.toUpperCase()) ? mapDeptIds.get(initialSelection.toUpperCase()) : (initialSelection.toUpperCase() == 'ALL DEPARTMENTS' ? 'All' :''));
				}					 
			}
		}
		
		// broadcast configuration to all listeners
		WidgetConfigurationListener.getInstance().addDelayedBroadcaster(this);		
	}
	
	/***
	** Called before rendering. Should be used for initializations as well 
	***/ 
	public override ApexPages.Component newComponent() 
	{
		Component.c.SL_IntranetDepartments c = new Component.c.SL_IntranetDepartments();   
		c.aComponentImpl = this;
		
    	return c;
  	}
}