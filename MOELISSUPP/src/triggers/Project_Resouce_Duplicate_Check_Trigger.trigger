trigger Project_Resouce_Duplicate_Check_Trigger on Project_Resource__c (before insert, before update) {

	for (Project_Resource__c res : Trigger.new){
		res.Unique_check_ids__c = res.Project__c + '' + res.Banker__c;
	}

	/*Map<Id, List<Project_Resource__c>> dataByProjectsNew = new Map<Id, List<Project_Resource__c>>();
	for (Project_Resource__c resource : Trigger.new){
		Id projId = resource.Project__c;
		if (!dataByProjectsNew.containsKey(projId)){
			dataByProjectsNew.put(projId, new List<Project_Resource__c>());
		}
		dataByProjectsNew.get(projId).add(resource);
	}
	
	for (Id projId : dataByProjectsNew.keySet()){
		if (!checkInside(dataByProjectsNew.get(projId))){
			throwException('Duplicate {Deal, Employee} entry');
		}
		if (Trigger.isUpdate){
			List<Project_Resource__c> lst = new List<Project_Resource__c>();
			for (Project_Resource__c res : dataByProjectsNew.get(projId)){
				if (Trigger.oldMap.get(res.Id).Banker__c != res.Banker__c) lst.add(res);
			}
			if (!checkOutside(lst)){
				throwException('Duplicate {Deal, Employee} entry');
			}
		} else if (Trigger.isInsert){
			if (!checkOutside(dataByProjectsNew.get(projId))){
				throwException('Duplicate {Deal, Employee} entry');
			}
		}
	}
	
	

	boolean checkInside(List<Project_Resource__c> lst){
		if (lst.isEmpty()) return true;
		Set<Id> was = new Set<Id>();
		for (Project_Resource__c res : lst){
			if (was.contains(res.Banker__c)) return false;
			was.add(res.Banker__c);
		}
		return true;
	}
	
	boolean checkOutside(List<Project_Resource__c> lst){
		AggregateResult[] ress = [Select p.Project__c, p.Banker__c, count(Id) From Project_Resource__c p
								GROUP BY p.Project__c, p.Banker__c];
		return true;
	}
	
	public class DuplicateException extends Exception {}
	void throwException(String s){
		//throw new DuplicateException(s);
	}*/
}