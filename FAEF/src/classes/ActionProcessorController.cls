public with sharing class ActionProcessorController {

	public String sObjectType									{ get; set; }
	public String recordId										{ get; set; }	
	private sObject record										{ get; set; }
	public String retURL										{ get; set; }
	private Schema.sObjectType sot								{ get; set; }
	private Map<String, Schema.sObjectField> sotFields			{ get; set; }

	public Map<String, String> params {
		get {
			if(ApexPages.currentPage() != null && ApexPages.currentPage().getParameters() != null) {
				params = ApexPages.currentPage().getParameters();
			}
			else {
				params = new Map<String, String>();
			}
			return params;
		}
		set;
	}
	
	public String getParam(String key) {
		if(!params.containsKey(key)) return null;
		return params.get(key);
	}

	public ActionProcessorController() {}
	
	public PageReference process() {
		
		recordId = getParam('id');
		sObjectType = getParam('sObjectType');
		
		retURL = getParam('retURL');
		
		if(retURL == null) retURL = ApexPages.currentPage().getHeaders().get('referer');
		
		Map<String, Schema.sObjectType> globalDescribe = Schema.getGlobalDescribe();
		Schema.sObjectType sot = globalDescribe.get(sObjectType); 
		sotFields = sot.getDescribe().fields.getMap();
		
		if(recordId != null) record = sot.newSObject(recordId);
		else record = sot.newSObject();
		
		String booleans =		'boolean';
		String strings =		'combobox,email,phone,reference,multipicklist,string,picklist,textarea,url';
		String integers =		'integer';
		String doubles =		'currency,double,percent';
		
		for(String k : params.keySet()) {
			if(!sotFields.containsKey(k)) continue;
			Schema.sObjectField f = sotFields.get(k);
			Schema.DescribeFieldResult d = f.getDescribe();
			String fieldType = d.getType().name().toLowerCase(); 
			if(booleans.contains(fieldType)) record.put(k, Boolean.valueOf(params.get(k)));
			else if(strings.contains(fieldType)) record.put(k, params.get(k));
			else if(integers.contains(fieldType)) record.put(k, Integer.valueOf(params.get(k)));
			else if(doubles.contains(fieldType)) record.put(k, Double.valueOf(params.get(k)));
			else if(fieldType == 'date') {
				try {
					record.put(k, Date.parse(params.get(k)));
				}
				catch(Exception ex) {
					try {
						record.put(k, Date.valueOf(params.get(k)));
					}
					catch(Exception ex2) {
						// splat
					}
				}
			}
			else if(fieldType == 'datetime') {
				try {
					record.put(k, DateTime.parse(params.get(k)));	
				}
				catch(Exception ex) {
					try {
						record.put(k, DateTime.valueOfGmt(params.get(k)));
					}
					catch(Exception ex2) {
						// splat
					}
					//Date theDate = Date.parse(params.get(k));
					//record.put(k, DateTime.newInstance(theDate, Time.newInstance(0,0,0,0)));
				}
			}
		}
		
		upsert record;
		
		if(retURL == null) return null;
		
		if(retURL.contains('[NEWID]')) retURL = retURL.replace('[NEWID]', record.Id);
		PageReference pr = new PageReference(retURL);
		pr.setRedirect(true);
		return pr;  
		
	}
	
	public static testmethod void test() {
		
		Account a = new Account(Name = 'Test');
		insert a;
		
		Contact c = new Contact(
			FirstName = 'Test',
			LastName = 'Test',
			AccountId = a.Id
		);
		insert c;
		
		ActionProcessorController apc = new ActionProcessorController();
		apc.params.put('sObjectType', 'Task');
		apc.params.put('WhoId', c.Id);
		apc.params.put('Type', 'Outbound Call');
		apc.params.put('Last_Call_Attempt__c', '2011-12-12 16:13:08Z');
		apc.params.put('ActivityDate', '12/12/2011');
		apc.params.put('Status', 'Completed');
		apc.params.put('Result__c', 'Left VoiceMail');
		apc.process();
	}

}