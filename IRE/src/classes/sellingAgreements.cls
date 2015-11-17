public with sharing class sellingAgreements {
	public List<wrapperClass> wrpList {get;set;}
	public List<sObject> dueList {get;set;}
	
	public sellingAgreements()
	{
		dueList=[Select Received_Approval__c, Fund__r.name 
				From Due_Diligence__c 
				where Received_Approval__c = true and Fund__r.name != null and Fund__r.Fund_Acronym__c = 'IPCC'
				group by Received_Approval__c, Fund__r.name];
	}
 
	public List<wrapperClass> getDueDiligence(){
		if(wrpList == null){
			wrpList = new List<wrapperClass>();
			for(sObject d:dueList){
				wrpList.add(new wrapperClass(d));
			}
		}
		return wrpList;
	}
	//wrapper Class starts
	public class wrapperClass
	{
		public Due_Diligence__c due {get;set;}
		//public boolean checked {get;set;}

		public wrapperClass(sObject d){
			//due = d;

		}
	}
}