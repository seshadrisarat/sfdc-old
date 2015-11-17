/**
*  ClassName      : SL_ConnectionHandler
*  JIRATicket     : GA-6
*  CreatedOn      : 23/JAN/2015
*  ModifiedBy     : Pradeep
*  Description    : This is the handler class for Connection trigger   
*/

public with sharing class SL_ConnectionHandler {

	SL_Reciprocal objReciprocalClass = new SL_Reciprocal('From_Account__c', 'To_Account__c', 'From_Contact__c', 'To_Contact__c', 'Related_Connector__c', 'Connection__c', 'CnxnSameFlds', '', '', 'ConnectionRefFieldText__c');
	
	/* Constructor */
	public SL_ConnectionHandler() {}
	
	
	/*
    * MethodName   : onBeforeInsert 
    * param        : trigger.new
    * Description  : updateConnectionCompany method called
    */
    
	public void onBeforeInsert(List<Connection__c> lstConnections) 
	{
		updateConnectionCompany(lstConnections,null);	// Method called to create inverse connection records for inserted Connections
	}	
	
	
	/*
    * MethodName   : onBeforeupdate 
    * param        : trigger.new
    * Description  : updateConnectionCompany method called
    */
    
	public void onBeforeUpdate(map<Id,Connection__c> mapNewConnections,map<Id,Connection__c> mapOldConnections) 
	{
		updateConnectionCompany(mapNewConnections.values(),mapOldConnections);	// Method called to create inverse connection records for inserted Connections
	}	
	
	/*
    * MethodName   : onAfterInsert 
    * param        : trigger.new
    * Description  : Method called after insertion of Connection records.
    */
    
	public void onAfterInsert(map<Id,Connection__c> mapNewConnections) 
	{
		createInverseConnections(mapNewConnections);	// Method called to create inverse connection records for inserted Connections
	}	
	
	/*
    * MethodName   : onAfterUpdate 
    * param        : trigger.oldMap,trigger.newMap
    * Description  : Method called after updation of Connection records.
    */
    
	public void onAfterUpdate(map<Id,Connection__c> mapOldConnections,map<Id,Connection__c> mapNewConnections) 
	{
		objReciprocalClass.onAfterUpdate(mapOldConnections,mapNewConnections); // Method called to delete inverse connection records for deleted Connections.
	}
	
	/*
    * MethodName   : onAfterDelete 
    * param        : trigger.oldMap
    * Description  : Method called after deletion of Connection records.
    */
    
	public void onAfterDelete(map<Id,Connection__c> mapOldConnections) 
	{
		objReciprocalClass.OnAfterDelete(mapOldConnections); // Method called to delete inverse connection records for deleted Connections.
	}
	
	/*
    * MethodName   : OnAfterUnDelete 
    * param        : trigger.oldMap
    * Description  : Method called after Undelete of Connection records.
    */
    
	public void OnAfterUnDelete(map<Id,Connection__c> mapNewConnections) 
	{
		objReciprocalClass.OnAfterUnDelete(mapNewConnections); // Method called to delete inverse connection records for deleted Connections.
	}
	
	/*
    * MethodName   : createInverseConnections 
    * param        : map<Id,Connection__c>
    * Description  : Method used to create inverse connection records on after insert.
    */
    
	private void createInverseConnections(map<Id,Connection__c> mapNewConnections)
	{
		Map<Id,Connection__c> MapFilteredConnectIdToConnection = new map<Id,Connection__c>(); // Map used to store Connection records for which inverse Connections need to be created.
		
		// Iterating through inserted Connection records
		for(Connection__c objConnection : mapNewConnections.values())
		{
			if((objConnection.From_Account__c != null && objConnection.To_Account__c != null) || (objConnection.From_Contact__c != null && objConnection.To_Contact__c != null))
				MapFilteredConnectIdToConnection.put(objConnection.Id,objConnection);
			
		}
		// Creating inverse connection records
		if(!MapFilteredConnectIdToConnection.isEmpty())
		{
			objReciprocalClass.OnAfterInsert(MapFilteredConnectIdToConnection);
		}
	}
	
	/*
    * MethodName   : updateConnectionCompany 
    * param        :List of Connections
    * Description  : Method used to update the Connection.From Account and Connection.To Account 
    */
	private void updateConnectionCompany (List<Connection__c> lstConnections, map<Id,Connection__c> mapOldConnections)
	{
		Set<Id>SetContactId = new Set<Id>();
		Map <Id, Id>mapContactIdToAccountId = new Map <Id, Id>();
		
		// Iterating through the List of Connections which are inserted and storing the To contact and From Contact to the Set
		for(Connection__c objConnection : lstConnections)
		{
			if((objConnection.To_Contact__c != null && mapOldConnections == null) || (mapOldConnections != null 
				&& objConnection.To_Contact__c != null && objConnection.To_Contact__c != mapOldConnections.get(objConnection.Id).To_Contact__c))
				SetContactId.add(objConnection.To_Contact__c );
			
			if((objConnection.From_Contact__c != null && mapOldConnections == null) || (mapOldConnections != null 
				&& objConnection.From_Contact__c != null && objConnection.From_Contact__c != mapOldConnections.get(objConnection.Id).From_Contact__c))
				SetContactId.add(objConnection.From_Contact__c );
		}
		
		// Iterating through the Set To Contact and Set From Contact to update the connections From Account and To account
		if(!SetContactId.isEmpty() && SetContactId != null)
		{
			for(Contact objContact : [SELECT Id,AccountId FROM Contact WHERE Id IN:SetContactId ])
				mapContactIdToAccountId.put(objContact.Id,objContact.AccountId );
			
			for(Connection__c objConnectionUpdated : lstConnections)
			{
				// Updating Connection.To Account
				if(!mapContactIdToAccountId.isEmpty() && mapContactIdToAccountId != null)
				{
					if(mapContactIdToAccountId.containsKey(objConnectionUpdated.To_Contact__c))
						objConnectionUpdated.To_Account__c = mapContactIdToAccountId.get(objConnectionUpdated.To_Contact__c); 
					if(mapContactIdToAccountId.containsKey(objConnectionUpdated.From_Contact__c))
						objConnectionUpdated.From_Account__c = mapContactIdToAccountId.get(objConnectionUpdated.From_Contact__c); 
				}
			}
		}
	}
}