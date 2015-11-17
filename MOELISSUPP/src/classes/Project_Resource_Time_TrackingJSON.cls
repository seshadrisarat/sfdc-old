/*

Modified: Privlad 02/23/2010 - task: 956
modified: yuguziy 04/16/2010 - task: 10280 - can be deleted now 
*/
public class Project_Resource_Time_TrackingJSON {
/*	public list<Project_Resource_Time_Tracking__c > objList {get; set;}
	public List<picklistItem> TT_Status_values {get; set;}
	
	public class picklistItem {
		public string value {get; set;}
		public string label {get; set;}
		
		public picklistItem (string val, string lbl)
		{
			value = val;
			label = lbl;			
		}
	}
	
	public Project_Resource_Time_TrackingJSON()
	{
		objList = new list<Project_Resource_Time_Tracking__c>();
    	
    	if(System.currentPageReference().getParameters().get('pid')!=null && System.currentPageReference().getParameters().get('pid')!='')
    	{
    		String curPidID = System.currentPageReference().getParameters().get('pid');
			if(curPidID!=null && curPidID!='')
			{
				id id1 = UserInfo.getUserId();
				objList = [Select p.Project__c, p.Name, p.Moelis_Employee__c, p.Moelis_Employee__r.Last_Name__c, p.Moelis_Employee__r.First_Name__c, p.Id, p.Hours__c, p.Date__c, p.CreatedById, p.Activity__c From Project_Resource_Time_Tracking__c p where p.Project__c = :curPidID order by p.name limit 200];
			}
    	}

		Schema.DescribeFieldResult fieldResult = Project_Resource_Time_Tracking__c.Activity__c.getDescribe();
		List<Schema.PicklistEntry> PickilstValues = fieldResult.getPicklistValues();
		TT_Status_values = new List<picklistItem>();
		
		TT_Status_values.add(new picklistItem('',''));
		for (Schema.PicklistEntry pVal : PickilstValues){TT_Status_values.add(new picklistItem(pVal.value,pVal.label));}
	}
	
	public static testMethod void testMyController()
	{
		
		ID iCompanyRT = null;
		ID iDealRT = null;
		RecordType[] recTypeIDs  = [Select id,Name,SobjectType from RecordType where SobjectType = 'Account' limit 1];
		for(RecordType rtItem: recTypeIDs)
		{
			iCompanyRT = rtItem.ID;
		}

		RecordType[] recTypeIDs2  = [Select id,Name,SobjectType from RecordType where SobjectType = 'Ibanking_Project__c'];
		for(RecordType rtItem: recTypeIDs2)
		{
			iDealRT = rtItem.ID;
			if(rtItem.Name == 'General Advisory') break;
		}
		
		Account accObj1 = new Account(Name='Company1',RecordTypeId=iCompanyRT,Type='Other',Industry='Other',Public_Private__c='Public',Client_Code__c='00001',EBITDA__c=2.0,Enterprise_Value__c=3.0,TickerSymbol='CSCO',Total_Revenue__c=10.0,Website='www.mail.ru');
    	insert accObj1;
    	
    	ID UserID = UserInfo.getUserId();
    	
    	Employee_Profile__c emplObj = new Employee_Profile__c(Title__c='Analyst', Office_Location__c='New York', Name='AnalystNY', Last_Name__c='Test LN', Group__c='Capital Markets', First_Name__c='test FN', Business_Function__c='Analyst');
    	emplObj.User_ID__c = UserID;
    	insert emplObj;

		Test.startTest();
		
    	Ibanking_Project__c IbankProjObj = new Ibanking_Project__c(RecordTypeId=iDealRT , Status__c='Active', Stage__c='Staffing Request', Region__c='Americas', Product_Type__c='General Advisory', Name='Test Deal', Industry__c='Other', Business_Type__c='Advisory',Description__c='test1',Full_Description_of_Transaction__c='test2');
    	IbankProjObj.Name = 'Deal Test';
    	IbankProjObj.Client__c = accObj1.ID;
    	//IbankProjObj.Staffer__c = emplObj.ID;
    	IbankProjObj.Transaction_Type__c = 'N/A';
    	IbankProjObj.Transaction_Sub_Type__c = 'N/A';
    	IbankProjObj.Transaction_Feature__c = 'N/A'; 
    	
    	system.debug('IbankProjObj=====' + IbankProjObj);
    	insert IbankProjObj;
    	
    	Project_Resource__c ProgResObj = new Project_Resource__c(Role__c='Other', Project__c=IbankProjObj.ID, Banker__c=emplObj.ID);
    	insert ProgResObj;

		IbankProjObj.Name = 'Test Name-2';
		update IbankProjObj;
		Date myDate = date.today();
		String curPidIDTest = myDate.month()+'/'+myDate.day()+'/'+myDate.year();
		
		Project_Resource_Time_Tracking__c ttTrack1 = new Project_Resource_Time_Tracking__c(Moelis_Employee__c=emplObj.ID,Project__c=IbankProjObj.ID);
		insert ttTrack1;
		System.currentPageReference().getParameters().put('pid',curPidIDTest);
		Project_Resource_Time_TrackingJSON TrackerJSONClass = new Project_Resource_Time_TrackingJSON();
		
		Test.stopTest();
		
	}
*/	
}