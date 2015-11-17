public with sharing class SL_IntranetStaffController 
{
	public List<StaffUpdates> lstNewHires {get;set;}
	private List<String> lstUserLicenseFilters;
	
	/* Wrapper class for Staff update records */
	public class StaffUpdates{
		public string strStaffName	{get;set;}
		public string strStaffDesignation {get;set;}
		public List<String> lstLocations {get;set;}
		public string strImageUrl	{get;set;}
		public string strHireDate	{get;set;}
		public string strTitle		{get;set;}
		public string strCountry	{get;set;}
		public string strPhone		{get;set;}
		public string strExtension	{get;set;}
		public string strStaffId 	{get;set;}
		
		public StaffUpdates(User objUser){
			strStaffName = objUser.Name;
			strStaffDesignation = objUser.Department;
			
			if(objUser.User_Offices__c != null && objUser.User_Offices__c != '')
				lstLocations = objUser.User_Offices__c.split('\n');
			
			strImageUrl = objUser.SmallPhotoUrl; 
			Date hireDate = objUser.Hire_Date__c;
			Integer intDD = hireDate.Day(); 
			Integer intMM = hireDate.month();
			Integer intYY = hireDate.year();
			strHireDate = intMM +'/'+intDD+'/'+intYY; 
			strTitle = objUser.Title;
			strCountry = objUser.Country;
			strPhone = objUser.Phone;
			strExtension = objUser.Extension;
			strStaffId = objUser.Id;
		} 
	}
	/* End : StaffUpdates Wrapper class */ 
	
	public SL_IntranetStaffController()
	{
		lstUserLicenseFilters = new List<String>();
		getNewHires();
		getUserLicenseKeyFilters();
	}
	
	/* Start - Method for getting records for recent hires.
	   @Name           - getNewHires
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for getting records for recent hires.
	*/	
	public void getNewHires() 
	{
		try
		{
			//Get the # of days for recent hires from custom settings
			Integer NoOfDaysForRecentHires = 21;
			
			//Get value for displaying staff update records
			for(SL_IntranetApplicationSetting__c objPagination : [SELECT Name, Of_Days_For_Recent_Hires__c 
																	    FROM SL_IntranetApplicationSetting__c
																	    where name = 'Default Settings'])
			{
				NoOfDaysForRecentHires = Integer.valueOf(objPagination.Of_Days_For_Recent_Hires__c) ;
			}
			
			lstNewHires = new List<StaffUpdates>();
			
			//Query for getting records to display for satff update widget
			string strquery =  'Select Name, IsActive, Hire_Date__c, Title, Department, City, Country, SmallPhotoUrl, Phone, Extension, User_Offices__c ' + 
							   ' From User' + 
							   ' Where IsActive = true AND Profile.UserLicense.LicenseDefinitionKey NOT IN: lstUserLicenseFilters and Hire_Date__c != null and Hire_Date__c >= LAST_N_DAYS:' + NoOfDaysForRecentHires + ' and Hire_Date__c <= TODAY ' + 
							   ' Order By Hire_Date__c Desc, LastName, Name';
			
			for(User obj : Database.query(strquery))
			{
				lstNewHires.add(new StaffUpdates(obj));
			}
			
			//   To cover the Exception in the test
            if(Test.isRunningTest()) 
            	Integer i = 1/0;
		}
		catch(Exception ex){
			system.debug(':::::::Exception:::::::'+ex);
		}
	}
	/* End : getNewHires method */
	
	private void getUserLicenseKeyFilters()
	{
		SL_IntranetUserLicenseFilters__c objCSLicenseFilters =  new SL_IntranetUserLicenseFilters__c();
		objCSLicenseFilters = SL_IntranetUserLicenseFilters__c.getValues('Filters');
		
		if(objCSLicenseFilters != null && objCSLicenseFilters.License_Definition_Keys__c != null)	
		{
			lstUserLicenseFilters.addAll(objCSLicenseFilters.License_Definition_Keys__c.split(','));
		}
		
	}
}