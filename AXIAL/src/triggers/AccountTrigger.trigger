trigger AccountTrigger on Account (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

	if(Trigger.isBefore && trigger.isUpdate){
		List<CompanyTypeMapping__c> mappings = CompanyTypeMapping__c.getAll().values();
		Map<String, String> axmToSFDC = new Map<String, String>();
		Map<String, String> sfdcToAXM = new Map<String, String>();
		for(CompanyTypeMapping__c c :mappings){
			axmToSFDC.put(c.Axial_Company_Type__c, c.Salesforce_Company_Type__c);
			sfdcToAXM.put(c.Salesforce_Company_Type__c, c.Axial_Company_Type__c);
		}

		for (Account a : Trigger.new) {
			if(a.AXM_Company_Type__c != Trigger.oldMap.get(a.Id).AXM_Company_Type__c){
				a.Company_Type_full_name__c = axmToSFDC.get(a.AXM_Company_Type__c);
 			}else if(a.Company_Type_full_name__c != Trigger.oldMap.get(a.Id).Company_Type_full_name__c){
				a.AXM_Company_Type__c = sfdcToAXM.get(a.Company_Type_full_name__c);
 			}
			
		}
	}

	if(Trigger.isBefore && Trigger.isInsert){
		List<CompanyTypeMapping__c> mappings = CompanyTypeMapping__c.getAll().values();
		Map<String, String> axmToSFDC = new Map<String, String>();
		Map<String, String> sfdcToAXM = new Map<String, String>();
		for (Account a :Trigger.new){
			if(a.AXM_Company_Type__c == null){
				a.AXM_Company_Type__c = sfdcToAXM.get(a.Company_Type_full_name__c);
			}else if(a.Company_Type_full_name__c == null){
				a.Company_Type_full_name__c = axmToSFDC.get(a.AXM_Company_Type__c);
			}
		}
	}
}