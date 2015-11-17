/**
* \arg \b ClassName           : SL_ContractExtensionTriggerHandler
* \arg \b JIRATicket          : FAEF-34,FAEF-62
* \arg \b CreatedOn      	  : 1/9/2015
* \arg \b LastModifiedOn      : 3/17/2015
* \arg \b LastModifiedBy      : Pankaj Ganwani
*/
public with sharing class SL_ContractExtensionTriggerHandler 
{
	static final String CONTRACT_EXTENSION = 'Contracted Extension';//static variable to hold constant value of type
	
	//Constructor
	public SL_ContractExtensionTriggerHandler()
	{
		// do nothing      
	}

	// Method called on before insert of Contract_Extension__c record
	public void onBeforeInsert(list<Contract_Extension__c> lstContractExtensions)    
	{
		list<Contract_Extension__c> filteredContractExtensions = new list<Contract_Extension__c>();
		for(Contract_Extension__c c : lstContractExtensions){
			if(!c.Import_Flag__c){
				filteredContractExtensions.add(c);
			}
		}
		updateContractExtensionEndDate(filteredContractExtensions);// Method called to update Contract_Extension_End__c field.
	}
	       
	public void onAfterInsert(map<Id,Contract_Extension__c> mapContractExtensions)
	{
		map<Id,Contract_Extension__c> filteredContractExtensions = new map<Id,Contract_Extension__c>();
		for(Contract_Extension__c c : mapContractExtensions.values()){
			if(!c.Import_Flag__c){
				filteredContractExtensions.put(c.Id, c);
			}
		}
		// Method used to create proceed records and update associated schedule fields based on Contract_Extension__c info.
		createProceedRecordsAndUpdateSchedules(filteredContractExtensions.values(),null,'isInsert');
	}
	
	// Method called on before update of Contract_Extension__c record
	public void onBeforeUpdate(list<Contract_Extension__c> lstContractExtensions)
	{
		list<Contract_Extension__c> filteredContractExtensions = new list<Contract_Extension__c>();
		for(Contract_Extension__c c : lstContractExtensions){
			if(c.Contract_Extension_End__c == null && !c.Import_Flag__c){
				filteredContractExtensions.add(c);
			}
		}
		updateContractExtensionEndDate(filteredContractExtensions); // Method called to update Contract_Extension_End__c field.
	}
	
	public void onAfterUpdate(map<Id,Contract_Extension__c> mapOldContractExtensions,map<Id,Contract_Extension__c> mapNewContractExtensions)
	{
		map<Id,Contract_Extension__c> filteredOldContractExtensions = new map<Id,Contract_Extension__c>();
		map<Id,Contract_Extension__c> filteredNewContractExtensions = new map<Id,Contract_Extension__c>();
		for(Contract_Extension__c c : mapNewContractExtensions.values()){
			if(!c.Import_Flag__c){
				filteredNewContractExtensions.put(c.Id, c);
				filteredOldContractExtensions.put(c.Id, mapOldContractExtensions.get(c.Id));
			}
		}
		// Method used to update associated schedule fields based on Contract_Extension__c info.
		createProceedRecordsAndUpdateSchedules(filteredNewContractExtensions.values(),filteredOldContractExtensions,'isUpdate');
	}
	
	// Method used to update Contract_Extension_End__c field on Contract extension object based on Contract_Extension_Start__c and Contract_Extension_Term_Months__c fields.
	private void updateContractExtensionEndDate(list<Contract_Extension__c> lstContractExtensions)
	{
		// Iterating through insertable records
		for(Contract_Extension__c objContractExtension : lstContractExtensions)
		{
			if( objContractExtension.Contract_Extension_Start__c != null && objContractExtension.Contract_Extension_Term_Months__c != null)
				objContractExtension.Contract_Extension_End__c = objContractExtension.Contract_Extension_Start__c.addMonths(Integer.valueOf(objContractExtension.Contract_Extension_Term_Months__c)).toStartOfMonth().addDays(-1);
			
			else if(objContractExtension.Contract_Extension_Start__c == null)	
				objContractExtension.Contract_Extension_End__c = null;
			
			else if(objContractExtension.Contract_Extension_Start__c != null && objContractExtension.Contract_Extension_Term_Months__c == null)	
				objContractExtension.Contract_Extension_End__c = objContractExtension.Contract_Extension_Start__c.addMonths(1).toStartOfMonth().addDays(-1);
				
		}		
	}
	
	// Method used to create Proceed records for Contract_Extensions and update its schedule record with provided field mappings.
	private void createProceedRecordsAndUpdateSchedules(list<Contract_Extension__c> lstContractExtensions,map<Id,Contract_Extension__c> mapOldContractExtensions,String strEvent)   
	{
		map<String,Schedule__c> mapLatestContractExtensionToSchedule = new map<String,Schedule__c>(); // Map used to update Schedule records.	
		map<Id,Schedule__c> mapScheduleIdToSchedule = new map<Id,Schedule__c>();
		set<Id> setScheduleIds = new set<Id>();
		Map<Id,Proceeds__c> mapIdToProceed = new Map<Id,Proceeds__c>();
		List<Contract_Extension__c> lstContractExtensionToUpdate = new List<Contract_Extension__c>();
		
		// Iterating through insertable records
		for(Contract_Extension__c objContractExtension : lstContractExtensions)
		{
			setScheduleIds.add(objContractExtension.Schedule__c);
			
			if(strEvent == 'isInsert')
			{
				Proceeds__c objProceed = new Proceeds__c(Schedule__c = objContractExtension.Schedule__c,
														 Date_Posted__c = objContractExtension.Contract_Extension_Booked_Date__c,
														 Amount__c = objContractExtension.Contract_Extension_Amount__c,
														 Type__c = CONTRACT_EXTENSION);
				mapIdToProceed.put(objContractExtension.Id, objProceed);
			}
		}
			
		// Querying Schedule records related to Contract extensions.																	   		  
		for( Schedule__c objSchedule : [Select Id,Notice_Days_Required__c,(Select Name from Contract_Extensions__r order by Name desc limit 1)
										from Schedule__c
										where Id IN:setScheduleIds])				
		{
			if(!objSchedule.Contract_Extensions__r.isEmpty()) 
			{  
				mapLatestContractExtensionToSchedule.put(objSchedule.Contract_Extensions__r[0].Name,objSchedule);         
			}
		}					
		
		// Iterating through inserted or updated Contract Extensions    
		for(Contract_Extension__c objContractExtension : lstContractExtensions)
		{
			if((strEvent == 'isInsert' && mapLatestContractExtensionToSchedule.containsKey(objContractExtension.Name)) || (strEvent == 'isUpdate' && mapLatestContractExtensionToSchedule.containsKey(objContractExtension.Name) && (objContractExtension.Contract_Extension_End__c != mapOldContractExtensions.get(objContractExtension.Id).Contract_Extension_End__c || objContractExtension.Contract_Extension_Renewal_Amount__c != mapOldContractExtensions.get(objContractExtension.Id).Contract_Extension_Renewal_Amount__c 
			 	|| objContractExtension.Contract_Extension_Renew__c != mapOldContractExtensions.get(objContractExtension.Id).Contract_Extension_Renew__c)))
			{
				// Updating the Schedule with given field mappings
				Schedule__c objSchedule = new Schedule__c(Id = objContractExtension.Schedule__c,Current_Lease_Expiration_Date__c =  objContractExtension.Contract_Extension_End__c,
														  EOT_Status__c = 'Extension');
														  
				if(objSchedule.Current_Lease_Expiration_Date__c != null && (mapLatestContractExtensionToSchedule.containsKey(objContractExtension.Name) && mapLatestContractExtensionToSchedule.get(objContractExtension.Name).Notice_Days_Required__c != null))		
					objSchedule.Current_Residual_Notice_Date__c = objSchedule.Current_Lease_Expiration_Date__c - Integer.valueOf(mapLatestContractExtensionToSchedule.get(objContractExtension.Name).Notice_Days_Required__c);
					
				else if(objSchedule.Current_Lease_Expiration_Date__c != null)	   
					objSchedule.Current_Residual_Notice_Date__c = objSchedule.Current_Lease_Expiration_Date__c;        
					
				else 
					objSchedule.Current_Residual_Notice_Date__c = null;  
														   
			    mapScheduleIdToSchedule.put(objSchedule.Id,objSchedule);		     									        
			}         
		}
		
		// Inserting proceed records for contract extension
		if(!mapIdToProceed.isEmpty())
			database.upsert(mapIdToProceed.values(),false);      
		
		for(Id objContExtensionId : mapIdToProceed.Keyset())
		{
				Contract_Extension__c objCE = new Contract_Extension__c(Id = objContExtensionId, Proceed__c = mapIdToProceed.get(objContExtensionId).Id); 
				lstContractExtensionToUpdate.add(objCE);
		}
		
		// Updating Contrat extensions	  	
		if(!lstContractExtensionToUpdate.isEmpty())
		{
			database.update(lstContractExtensionToUpdate,false);
		}	
		
		// Updating schedules	  
		if(!mapScheduleIdToSchedule.isEmpty())
			database.upsert(mapScheduleIdToSchedule.values(),false);
	}
}