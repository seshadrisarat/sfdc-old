/**
* Test methods are in Test_Timetracker.cls
**/
public class TimeTrackerJSON_test {
	/*
	public list<Time_Tracker__c> objList {get; set;}
	public List<picklistItem> TT_Status_values {get; set;}
	public String formId {get; set;}
	
	public class picklistItem {
		public string value {get; set;}
		public string label {get; set;}
		
		public picklistItem (string val, string lbl)
		{
			value = val;
			label = lbl;			
		}
	}
	
	public TimeTrackerJSON_test()
	{
		objList = new list<Time_Tracker__c>();
    	formId = System.currentPageReference().getParameters().get('formid');
    	if(System.currentPageReference().getParameters().get('pid')!=null && System.currentPageReference().getParameters().get('pid')!=''
    		&& System.currentPageReference().getParameters().get('empid')!=null && System.currentPageReference().getParameters().get('empid')!=''
    	  )
    	{
    		String curPidID = System.currentPageReference().getParameters().get('pid');
    		Employee_Profile__c curEmplObj = TimeTracker.getCurEmployee(System.currentPageReference().getParameters().get('empid'));
    		system.debug('Employee_Profile NAME===' + curEmplObj.name);
    		//Employee_Profile__c curEmplObj = null;
			if(curPidID!=null && curPidID!='')
			{
				String[] aStrData = curPidID.split('/',3);
				if(integer.valueOf(aStrData[0])>0 && integer.valueOf(aStrData[1])>0 && integer.valueOf(aStrData[2])>0)
				{
					id id1 = UserInfo.getUserId();
					Date curTTDate = date.newinstance(integer.valueOf(aStrData[2]), integer.valueOf(aStrData[0]), integer.valueOf(aStrData[1]));
					objList = [
					SELECT 
						t.Non_Deal_Project__c, 		t.Week_Start_Date__c, 	t.Status__c, 
						t.Note__c, 					t.Hours__c, 			t.Employee__c, 
						t.Deal__r.Name, 			t.Deal__c, 				t.Deal__r.Client__c,
						t.Deal__r.Client__r.Name,	t.Deal__r.Client__r.Id
					FROM Time_Tracker__c t 
					WHERE t.Week_Start_Date__c = :curTTDate and 
						Employee__c=:curEmplObj.ID and 
						(Non_Deal_Project__c = null or Non_Deal_Project__c = '')
					ORDER BY t.Deal__r.Name 
					LIMIT 200];
					
				}
			}
    	}

		Schema.DescribeFieldResult fieldResult = Time_Tracker__c.Status__c.getDescribe();
		List<Schema.PicklistEntry> PickilstValues = fieldResult.getPicklistValues();
		TT_Status_values = new List<picklistItem>();
		
		TT_Status_values.add(new picklistItem('',''));
		for (Schema.PicklistEntry pVal : PickilstValues){TT_Status_values.add(new picklistItem(pVal.value,pVal.label));}
	}
	
	*/

}