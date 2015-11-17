/*
Modified: Privlad 02/23/2010 - task: 956
modified: yuguziy 04/16/2010 - task: 10280 - can be deleted now 
*/
public class Project_Resource_Time_Tracking {
/*
        public List<selectOption> lProjects = null;
        public String SelProjItem {get; set;}
        public String testData {get; set;}
        public Project_Resource_Time_Tracking__c newPRTimeTrackingObj = new Project_Resource_Time_Tracking__c();
        public boolean isTest = false;
        
        public Ibanking_Project__c getCurrDealObj()
        {
        	if(SelProjItem!=null && SelProjItem!='')
        	{
        		Ibanking_Project__c retObj = [select ID,Name from Ibanking_Project__c where id=:SelProjItem limit 1]; 
        		return retObj; 
        	}
        	
        	return null;
        }
        
        public Project_Resource_Time_Tracking__c getPRTTObj(){ return newPRTimeTrackingObj;}
        public void setPRTTObj(Project_Resource_Time_Tracking__c inVal){ newPRTimeTrackingObj = inVal;}
        
		public Project_Resource_Time_Tracking()
		{
			//buyersList = new list<Target_Buyers__c>();
    	
    		if(System.currentPageReference().getParameters().get('pid')!=null && System.currentPageReference().getParameters().get('pid')!='')
    		{
    			SelProjItem = System.currentPageReference().getParameters().get('pid'); 
    		}
		}
       
       public PageReference save_and_new()
       {
       		newPRTimeTrackingObj.Project__c = SelProjItem;
       		insert newPRTimeTrackingObj;
       		newPRTimeTrackingObj = new Project_Resource_Time_Tracking__c();
       		saveJson();

       		return null;
       }
       
       
       public List<String> getTBFormPanel()
	   {
	    	
	    	List<String> aRetArr = new List<String>();
	    	if(SelProjItem==null || SelProjItem==''){ aRetArr.add('Show Project Panel.');}
	    	return aRetArr;
	   } 
       
        public List<String> getTBListPanel()
	    {
	    	
	    	List<String> aRetArr = new List<String>();
	    	if(SelProjItem!=null && SelProjItem!=''){ aRetArr.add('Selected Project Item.');}
	    	return aRetArr;
	    } 
        
        public List<selectOption> getProjects()
        {
        	if(lProjects==null)
        	{
                lProjects = new list<selectOption>();
                for (Ibanking_Project__c tl : [
                       Select i.TB_Counter__c, i.Id, i.Name From Ibanking_Project__c i where  i.TB_Counter__c>0 order by i.Name limit 100        
                ]) 
                {
                        lProjects.add(new SelectOption(tl.ID,tl.Name));
                        //system.debug('The p: '+tl.Project__r.Name);                   
                }        		
        	}
        	
        	return lProjects;
        }
        
        //public void setProjects(List<selectOption> inVal){ lProjects = inVal;}
        
        
        public string jsonContent { get; set; }
        
        public PageReference selProject()
    	{
    		
    		//System.currentPageReference().getParameters().put('pid',SelProjItem);
    		if(SelProjItem!=null && SelProjItem!='')
    		{
	    		String param1 = System.currentPageReference().getParameters().get('sfdc.tabName');
	    		String newURL = '/apex/Project_Resource_Time_Tracking?pid='+SelProjItem;
	    		if(param1!=null) newURL = newURL + '&sfdc.tabName='+param1;
	    		
	    		PageReference pageRef = new PageReference(newURL);
	    		pageRef.setRedirect(true);
	    		return pageRef;
    		}   
    		
    		return null;
    	}
    	
    	public PageReference close()
    	{
    		PageReference pageRef = new PageReference('/'+SelProjItem);
	        pageRef.setRedirect(true);   
	        return pageRef;
    	} 

        public PageReference cancel()
    	{
    		return null;
    	}        

        public static Date parceDate(String dateVal)
        {
        	Date contactDate = null;
        	
                try 
                {
                	integer dayVal = integer.valueOf(dateVal.substring(3,5));
                	integer monthVal = integer.valueOf(dateVal.substring(0,2));
                	integer yearVal = integer.valueOf(dateVal.substring(6,10));
                	contactDate = date.newInstance(yearVal, monthVal, dayVal);
                	
                } catch (Exception e) {
                	
                }
        	return contactDate;
        }
        
        public void saveJson()
        {
        	//system.debug('jsonContent===' + jsonContent);
			
			//testData = '::::'+jsonContent;
			
			if(jsonContent!=null && jsonContent!='')
			{
				JSONObject jsonObj = new JSONObject(jsonContent);
				
				if (jsonObj.getValue('delList') != null) {
					integer lenDelete = jsonObj.getValue('delList').values.size();
					List<String> PRTTForDeleteIDs = new List<String>();
					for(integer i = 0; i < lenDelete; i++)
		            {
		            	if(jsonObj.getValue('delList').values.get(i).str!= null && jsonObj.getValue('delList').values.get(i).str!= '')
		            	{
		            		PRTTForDeleteIDs.add(jsonObj.getValue('delList').values.get(i).str);
		            	}
		            }
		            if(PRTTForDeleteIDs.size()>0)
		            {
		            	List<Project_Resource_Time_Tracking__c> ListPRTTForDelete = [select ID from Project_Resource_Time_Tracking__c where id in :PRTTForDeleteIDs];
		            	if(ListPRTTForDelete!= null && ListPRTTForDelete.size()>0) delete ListPRTTForDelete;
		            }
				} // if
				
				//lenDelete;
				
				integer len = jsonObj.getValue('table').values.size();
				string valueId;
				List<Project_Resource_Time_Tracking__c> tbList = new List<Project_Resource_Time_Tracking__c>();
				Project_Resource_Time_Tracking__c tb; 
				string dateVal;
				Date dDateVal;
				boolean changed;
	
				
				//testData = ''+len;
	
	            List<Project_Resource_Time_Tracking__c> tmpListObjs = null;
	            if(isTest) len = 1; 
	            for (integer i = 0; i < len; i++)
	            {
	                valueId = jsonObj.getValue('rows').values.get(i).str;
	                tb = null;
	                
	                tmpListObjs = [SELECT Date__c, Hours__c, Activity__c FROM Project_Resource_Time_Tracking__c WHERE id=:valueId];
	                if(isTest) tmpListObjs = [SELECT Date__c, Hours__c, Activity__c FROM Project_Resource_Time_Tracking__c limit 1];
	                for(Project_Resource_Time_Tracking__c TmpTbObj : tmpListObjs)
	                {
	                	tb = TmpTbObj;
	                }
	                if(tb == null) break;
					changed = false;
	
	                //Date__c
	                dateVal = jsonObj.getValue('table').values.get(i).values.get(2).obj.getString('value');
					dDateVal = MilestoneTracker.parceDate(dateVal);
					if(tb.Date__c != dDateVal) {
						tb.Date__c = dDateVal;
						changed = true; 
	                }
	
	                //Hours__c
	                dateVal = jsonObj.getValue('table').values.get(i).values.get(3).obj.getString('value');
	                try {
		                double tmpDouble = double.valueOf(dateVal);
						if(tb.Hours__c != tmpDouble) {
							tb.Hours__c = tmpDouble;
							changed = true; 
		                }
	                } catch (Exception e){ }
	                
	                //Activity__c
	                String strVal = jsonObj.getValue('table').values.get(i).values.get(4).obj.getString('value');
					if(tb.Activity__c != strVal) {
						tb.Activity__c = strVal; 
						changed = true; 
	                }
	
	            	if (changed) {
	            		//update tb;
	            		tbList.add(tb);
	            	}
	            	
	            }
	            
	            if(tbList.size()>0){ update tbList;}
			}
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

		RecordType[] recTypeIDs2  = [Select id,Name,SobjectType from RecordType where SobjectType = 'Ibanking_Project__c' limit 1];
		for(RecordType rtItem: recTypeIDs2)
		{
			iDealRT = rtItem.ID;
		}
		
		Account accObj1 = new Account(Name='Company1',RecordTypeId=iCompanyRT,Type='Other',Industry='Other',Public_Private__c='Public',Client_Code__c='00000',EBITDA__c=2.0,Enterprise_Value__c=3.0,TickerSymbol='CSCO',Total_Revenue__c=10.0,Website='www.mail.ru');
		Account newAccount2 = new Account(Name='Test1', Industry='Media', Type='Other', Public_Private__c='Public', CurrencyIsoCode='USD', Status__c='Active', Client_Code__c='00001', TickerSymbol='qwe', Website='test.com');
    	insert accObj1;
    	insert newAccount2;
    	
    	ID UserID = UserInfo.getUserId();
    	
    	Employee_Profile__c emplObj = new Employee_Profile__c(Title__c='Analyst', Office_Location__c='New York', Name='AnalystNY', Last_Name__c='Test LN', Group__c='Capital Markets', First_Name__c='test FN', Business_Function__c='Analyst');
    	emplObj.User_ID__c = UserID;
    	insert emplObj;

    	Ibanking_Project__c IbankProjObj = new Ibanking_Project__c(RecordTypeId=iDealRT ,Transaction_Type__c='Sellside', Status__c='Active', Stage__c='Staffing Request', Region__c='Americas', Product_Type__c='M&A', Name='Test Deal', Industry__c='FIG', Business_Type__c='Advisory',Description__c='test1',Est_Transaction_Size__c=100.0,Full_Description_of_Transaction__c='test2');
    	//IbankProjObj.Client__c = accObj1.ID;
    	IbankProjObj.Client__c = newAccount2.ID;
    	//IbankProjObj.Staffer__c = emplObj.ID;
    	insert IbankProjObj;
    	
    	Project_Resource__c ProgResObj = new Project_Resource__c(Role__c='Other', Project__c=IbankProjObj.ID, Banker__c=emplObj.ID);
    	insert ProgResObj;

		IbankProjObj.Name = 'Test Name-2';
		update IbankProjObj;
		
		Target_Buyers__c targetBuyerObj = new Target_Buyers__c(Type__c='Financial', TargetBuyer__c=accObj1.ID, StageName__c='3-CA Sent', Project__c=IbankProjObj.ID, Name='test1');
		insert targetBuyerObj;
		

		Target_Buyers__c targetBuyerObj2 = new Target_Buyers__c(Type__c='Financial', TargetBuyer__c=accObj1.ID, StageName__c='3-CA Sent', Project__c=IbankProjObj.ID, Name='test2');
		insert targetBuyerObj2;
		delete targetBuyerObj;

		Test.startTest();


		System.currentPageReference().getParameters().put('pid',IbankProjObj.ID);
		Project_Resource_Time_Tracking PRTimeTrackerClass = new Project_Resource_Time_Tracking();
		PRTimeTrackerClass.SelProjItem = null;
		Ibanking_Project__c tmpObj3 = PRTimeTrackerClass.getCurrDealObj();
		List<String> tmpListObj4 = PRTimeTrackerClass.getTBFormPanel();
		PageReference refTest1 =  PRTimeTrackerClass.selProject();
		
		System.currentPageReference().getParameters().put('pid',IbankProjObj.ID);
		PRTimeTrackerClass = new Project_Resource_Time_Tracking();
		
		
		
		Project_Resource_Time_Tracking__c qqq = PRTimeTrackerClass.getPRTTObj();
		qqq.Moelis_Employee__c = emplObj.ID;
		//qqq.Project__c=IbankProjObj.Id;
		//insert qqq;
        PRTimeTrackerClass.setPRTTObj(qqq);
        PRTimeTrackerClass.save_and_new();
		PRTimeTrackerClass.getTBFormPanel();
		PRTimeTrackerClass.close();
		PRTimeTrackerClass.cancel();
		
		
		PRTimeTrackerClass.getCurrDealObj();
		//TrackerJSONClass.
		PageReference pageRef = null;
		pageRef = PRTimeTrackerClass.selProject();
		pageRef = PRTimeTrackerClass.cancel();
		List<String> lStr = PRTimeTrackerClass.getTBListPanel();
		//String selPID = ''+IbankProjObj.ID;
		//PRTimeTrackerClass.SelProjItem = selPID;
		//selPID = PRTimeTrackerClass.SelProjItem;
		lStr = PRTimeTrackerClass.getTBListPanel();
		PRTimeTrackerClass.lProjects = PRTimeTrackerClass.getProjects();
		Date dTest = Project_Resource_Time_Tracking.parceDate('10/10/2009');
		dTest = Project_Resource_Time_Tracking.parceDate('10/1');

		PRTimeTrackerClass.jsonContent =  '{"head" : ["ID","Moelis Employee","Date","Hours","Activity Description",""],';
        PRTimeTrackerClass.jsonContent += '"footer" : [{"footer-type" : "tableCells","cells" : [{"type" : "caption","data" : {"caption" : ""}},{ "type" : "caption","data" : {"caption" : ""}},{ "type" : "caption","data" : {"caption" : ""}},{"type" : "sum","data" : {}';
        PRTimeTrackerClass.jsonContent += '},{"type" : "caption","data" : {"caption" : ""}},{"type" : "del","data" : {"caption" : "Delete"}}]}],"fields" : [{},{"readonly": "true"},{},{},{"values" :[{ "value" : "", "label" : ""}';
        PRTimeTrackerClass.jsonContent += ',{ "value" : "Meeting with Committee counsel", "label" : "Meeting with Committee counsel"}';
        PRTimeTrackerClass.jsonContent += ',{ "value" : "Committee conference calls", "label" : "Committee conference calls"}';
        PRTimeTrackerClass.jsonContent += ',{ "value" : "Call with Debtors\' CRO", "label" : "Call with Debtors\' CRO"}';
        PRTimeTrackerClass.jsonContent += ',{ "value" : "Call to discuss Debtors\' CEO Transition", "label" : "Call to discuss Debtors\' CEO Transition"}';
        PRTimeTrackerClass.jsonContent += ',{ "value" : "Meeting to discuss business plan diligence and meeting with Debtors regarding operational performance", "label" : "Meeting to discuss business plan diligence and meeting with Debtors regarding operational performance"}';
        PRTimeTrackerClass.jsonContent += ',{ "value" : "Preparation of materials for Committee conference call", "label" : "Preparation of materials for Committee conference call"}';
        PRTimeTrackerClass.jsonContent += ',{ "value" : "Review of third-party restructuring proposals", "label" : "Review of third-party restructuring proposals"}';
        PRTimeTrackerClass.jsonContent += ',{ "value" : "Diligence of Debtors\' business plan", "label" : "Diligence of Debtors\' business plan"}';
        PRTimeTrackerClass.jsonContent += ',{ "value" : "Call to discuss pending bulk sale with Debtors", "label" : "Call to discuss pending bulk sale with Debtors"}';
        PRTimeTrackerClass.jsonContent += ',{ "value" : "Review of Committee advisor\'s presentation", "label" : "Review of Committee advisor\'s presentation"}';
        PRTimeTrackerClass.jsonContent += ',{ "value" : "Meetings with special litigation counsel", "label" : "Meetings with special litigation counsel"}';
        PRTimeTrackerClass.jsonContent += ',{ "value" : "Meetings with Debtors\' counsel to discuss intercompany transactions", "label" : "Meetings with Debtors\' counsel to discuss intercompany transactions"}';
        PRTimeTrackerClass.jsonContent += ',{ "value" : "Calls with Committee counsel to discuss outstanding motions", "label" : "Calls with Committee counsel to discuss outstanding motions"}';
        PRTimeTrackerClass.jsonContent += ']},{}],"rows" : ["'+ PRTimeTrackerClass.newPRTimeTrackingObj.ID+'","'+ PRTimeTrackerClass.newPRTimeTrackingObj.ID+'","'+ PRTimeTrackerClass.newPRTimeTrackingObj.ID+'"],"table" : [[{"value" : "RT-0041","type" : "sflink"';
        PRTimeTrackerClass.jsonContent += '},{"value" : "Andrew Horrocks","type" : "text"},{"value" : "11/20/2009","type" : "date"},{"value" : "13.00","type" : "rtext"';
        PRTimeTrackerClass.jsonContent += '},{"value" : "Meeting with Committee counsel","type" : "smplselect"},{"value" : "","type" : "boolean"}],[{"value" : "RT-0044","type" : "sflink"';
        PRTimeTrackerClass.jsonContent += '},{"value" : "Adam Keil","type" : "text"},{"value" : "11/09/2009","type" : "date"},{"value" : "12.30","type" : "rtext"},{"value" : "Call to discuss Debtors\' CEO Transition","type" : "smplselect"';
        PRTimeTrackerClass.jsonContent += '},{"value" : "","type" : "boolean"}],[{"value" : "RT-0045","type" : "sflink"},{"value" : "Alice Jan","type" : "text"},{"value" : "11/20/2009","type" : "date"';
        PRTimeTrackerClass.jsonContent += '},{"value" : "3.30","type" : "rtext"},{"value" : "Committee conference calls","type" : "smplselect"},{"value" : "","type" : "boolean"}]]}';
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		PRTimeTrackerClass.isTest = true;
		PRTimeTrackerClass.saveJson();
		
		Test.stopTest();
	}        

*/
}