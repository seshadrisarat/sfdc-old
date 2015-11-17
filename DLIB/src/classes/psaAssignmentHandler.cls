/****************************************************************************************
Name            : psaAssignmentHandler
Author          : Julia Kolesnik
Created Date    : March 07, 2014
Description     : psaAssignmentHandler.cls, SLFF-35
******************************************************************************************/
public class psaAssignmentHandler {
	private boolean m_isExecuting = false;
	private integer BatchSize = 0;
	
	private static map<string,string> mapFieldNameByLabel = null;

	/**
		* Constructor		: Initialise the global variables
		* @param			: None
	*/
	public psaAssignmentHandler(boolean isExecuting, integer size)
	{
		m_isExecuting = isExecuting;
		BatchSize = size;
	}

	/*
		@MethodName		: onBeforeInsert
		@param			: lstNew (Trigger New Values)
		@Description	: To sync Rates on Assignments
	*/
	public void onBeforeInsert(list<pse__Assignment__c> lstNew)
	{
		try
		{
			syncRatesWithProject(lstNew, new map<Id,pse__Assignment__c> ());
			
		}
		catch(Exception e) {
			system.debug(LoggingLevel.ERROR, e.getMessage() + ' ' + e.getStackTraceString());
		}
	}
	
	/*
		@MethodName		: onBeforeUpdate
		@param			: mapNew (Trigger New Values)
		@param			: mapOld (Trigger New Values)
		@Description	: To sync Rates on Assignments
	*/
	public void onBeforeUpdate(map<Id,pse__Assignment__c> mapNew, map<Id,pse__Assignment__c> mapOld)
	{
		try
		{
			syncRatesWithProject(mapNew.values(), mapOld);
		}
		catch(Exception e) {
			system.debug(LoggingLevel.ERROR, e.getMessage() + ' ' + e.getStackTraceString());
		}
	}
	
	private void syncRatesWithProject(list<pse__Assignment__c> lstNew, map<Id,pse__Assignment__c> mapOld) {
		mapFieldNameByLabel = getFieldNameByLabel(new String[]{'pse__Proj__c'});
		
		set<Id> setProjectIds = new set<Id>();
		for (pse__Assignment__c item:lstNew) {
			setProjectIds.add(item.pse__Project__c);
		}
		
		string strFields = String.join(mapFieldNameByLabel.values(), ',');
		string soql = 'Select '+strFields+' FROM  pse__Proj__c WHERE Id IN :setProjectIds limit 10000';
		list<pse__Proj__c> lstProjects = database.query(soql);
		system.debug(LoggingLevel.ERROR, lstProjects[0]);
		system.debug(LoggingLevel.ERROR, JSON.serialize(lstProjects[0]));
		Map<Id, pse__Proj__c> mapProjects = new Map<Id, pse__Proj__c>(lstProjects);
		for (pse__Assignment__c item:lstNew) {
			if (!mapOld.containsKey(item.Id) || item.pse__Role__c!=mapOld.get(item.Id).pse__Role__c || item.Override_Bill_Rate__c) {
				if (mapFieldNameByLabel.containsKey(item.pse__Role__c)) {
					if (mapProjects.get(item.pse__Project__c).get(mapFieldNameByLabel.get(item.pse__Role__c))!=null) {
						item.pse__Bill_Rate__c = decimal.valueOf(String.valueOf(mapProjects.get(item.pse__Project__c).get(mapFieldNameByLabel.get(item.pse__Role__c))));
					} else {
						item.pse__Bill_Rate__c = 0;
					}
				}
				if (item.pse__Role__c==null) item.pse__Bill_Rate__c = 0;
			}
		}
	}
	
	public static map<string,string> getFieldNameByLabel(list<string> lstObj) {
		if (mapFieldNameByLabel==null) {
			set<string> setRolesFromPicklist = new set<string>();
   			List<Schema.PicklistEntry> ple = pse__Assignment__c.pse__Role__c.getDescribe().getPicklistValues();
		    for( Schema.PicklistEntry f : ple)
		    {
		    	setRolesFromPicklist.add(f.getValue());
		    }
		    
			mapFieldNameByLabel = new map<string,string>();
			list<string> types = lstObj;
			Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
			for(Schema.DescribeSobjectResult res : results) {
				Map<String, Schema.SobjectField> fields = res.fields.getMap();
		        for (String s : fields.keySet()) {
		        	if (setRolesFromPicklist.contains(fields.get(s).getDescribe().getLabel())) {
			        	if (String.valueOf(fields.get(s).getDescribe().getType())=='Currency' && !fields.get(s).getDescribe().isCalculated() && fields.get(s).getDescribe().isUpdateable()) {
			        		mapFieldNameByLabel.put(fields.get(s).getDescribe().getLabel(), s);
			        	}
		        	}
		        }
			}
		}
		
		return mapFieldNameByLabel;
	}
}