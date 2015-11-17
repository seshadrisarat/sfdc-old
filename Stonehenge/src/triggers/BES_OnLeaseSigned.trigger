trigger BES_OnLeaseSigned on Opportunity (after insert,after update) 
{  
  List<Property_to_Opportunity_Connector__c> lstPTOConnector = new List<Property_to_Opportunity_Connector__c>(); 
  Set<Id> setPropertyIds = new Set<Id>();
  List<Property__c> lstProperty = new List<Property__c>();
  set<Id> setPropertyIdsForApprovalStatus = new Set<Id>();
  
  // Added by Shailendra
  Set<Id> setPropertyIdsForOpportunity = new Set<Id>();
  
  //srinivas code begins
  set<Id> setOppIds = new set<Id>();
  //ends
  
  for(Integer i=0;i < Trigger.new.size() ;i++)
  {
    if(Trigger.new[i].StageName == 'Signed Lease' && Trigger.new[i].Property__c != null)
    {      
      setPropertyIds.add(Trigger.new[i].Property__c);
      
      if(!setPropertyIdsForOpportunity.contains(trigger.new[i].Property__c))
      {
	      Property__c objProperty = new Property__c(Id=trigger.new[i].Property__c);
	      objProperty.Unit_Status__c = '1. Rented';
	      objProperty.UnitStatusUpdateDate__c = System.Date.today();
	      lstProperty.add(objProperty);
	      setPropertyIdsForOpportunity.add(trigger.new[i].Property__c);
      }
	  setOppIds.add(Trigger.new[i].Id);
    }
    if(Trigger.new[i].StageName == 'Application Approved' && Trigger.new[i].Property__c != null)
    {
      setPropertyIdsForApprovalStatus.add(Trigger.new[i].Property__c);
    }
    
  }  
  
  if(lstProperty.size() > 0)
  {
    update lstProperty;
  }
    
  if(setPropertyIds.size() > 0)
    lstPTOConnector = [Select Id, Opportunity__c, Opportunity__r.IsClosed from Property_to_Opportunity_Connector__c where Property__c in : setPropertyIds];
  else if(setPropertyIdsForApprovalStatus.size() > 0)
    lstPTOConnector = [Select Id from Property_to_Opportunity_Connector__c where Property__c in : setPropertyIdsForApprovalStatus];  
  
  for(Integer i=0; i < lstPTOConnector.size();i++)
  {
    if(setPropertyIds.size() > 0)
    {
      //Srinivas code begins
      if(setOppIds.contains(lstPTOConnector[i].Opportunity__c))
      {
        lstPTOConnector[i].Status__c = 'Rented'; 
      }
      else
      {
      //ends
      	if(!(lstPTOConnector[i].Opportunity__r.IsClosed))
        	lstPTOConnector[i].Status__c = 'Unavailable - Lease Signed';
      }
    }
    if(setPropertyIdsForApprovalStatus.size() > 0)  
      lstPTOConnector[i].Status__c = 'In Progress';  
  }
  
  // Changed By T_SPD12 - 10th May 2010.
  if(lstPTOConnector.size() > 0)
  {
  	/* Commentted out this code as per JIRA : StonePII-99
    String query = 'Select Id from Property_to_Opportunity_Connector__c limit 1';
    BES_BatchForLeaseSigned objBES_BatchForLeaseSigned = new BES_BatchForLeaseSigned(query,lstPTOConnector);
    Database.executebatch(objBES_BatchForLeaseSigned,1);
  	*/
  	
  	update lstPTOConnector;
  }
  
  
  
   
}