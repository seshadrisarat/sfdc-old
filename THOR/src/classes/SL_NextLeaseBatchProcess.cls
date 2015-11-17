/**
*  Class Name     : SL_NextLeaseBatchProcess
*  JIRATicket     : THOR-49
*  CreatedOn      : 26/NOV/2014
*  ModifiedBy     : SANATH
*  Description    : Batch to populate Next Lease field on Lease record
*/
global class  SL_NextLeaseBatchProcess implements Database.Batchable<sObject>
{
    public string strQuery = ''; 
    
    /* Start : Constructor */
    public SL_NextLeaseBatchProcess(String strQuery)
    {
    	this.strQuery = strQuery;
    }
    /* End : Constructor */
    
    /*
    	* MethodName   : start
        * Param        : Database.BatchableContext BC
        * Description  : This method returns list of Apartment records to execute method
    */
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
    	return Database.getQueryLocator(strQuery);
    }
    
    /*
    	* MethodName   : execute
        * Param        : Database.BatchableContext BC, List<Apartment__c> lstApartment
        * Description  : Processes Apartment records returned by start method
    */
    global void execute(Database.BatchableContext BC, List<Apartment__c> lstApartment)
    {
    	Map<Id,Map<Date,Id>> mapApartmentId_MapStartDateToNextLeaseId = new Map<Id,Map<Date,Id>>();
    	Map<Id,List<Date>> mapApartmentId_LstStartDate = new Map<Id,List<Date>>();
    	List<Lease__c> lstLeaseToUpdate = new List<Lease__c>();
    	List<Lease__c> lstLease = new List<Lease__c>();
    	 
    	///Create maps of apartment id to list/map of start date
    	for(Lease__c objLease:[SELECT Id,Start_Date__c,Apartment__c,Next_Lease__c
    	                       FROM Lease__c
    	                       WHERE Apartment__c IN:lstApartment
    	                       ORDER BY Start_Date__c ASC])
    	{
    		if(!mapApartmentId_MapStartDateToNextLeaseId.containskey(objLease.Apartment__c) && objLease.Start_Date__c != null)
    		{
    			mapApartmentId_MapStartDateToNextLeaseId.put(objLease.Apartment__c,new Map<Date,Id>{objLease.Start_Date__c => objLease.Id});
    		}
    		else if(mapApartmentId_MapStartDateToNextLeaseId.containskey(objLease.Apartment__c) &&
    		        mapApartmentId_MapStartDateToNextLeaseId.get(objLease.Apartment__c) != null && objLease.Start_Date__c != null)
    		{
    			mapApartmentId_MapStartDateToNextLeaseId.get(objLease.Apartment__c).put(objLease.Start_Date__c,objLease.Id);
    		}
    		if(!mapApartmentId_LstStartDate.containskey(objLease.Apartment__c) && objLease.Start_Date__c != null)
    		{
    			mapApartmentId_LstStartDate.put(objLease.Apartment__c,new List<Date>{objLease.Start_Date__c});
    		}
    		else if(mapApartmentId_LstStartDate.containskey(objLease.Apartment__c) &&
    		        mapApartmentId_LstStartDate.get(objLease.Apartment__c) != null && objLease.Start_Date__c != null)
    		{
    			mapApartmentId_LstStartDate.get(objLease.Apartment__c).add(objLease.Start_Date__c);
    		}
    		lstLease.add(objLease);
    	}
    	
    	///Populate Next_Lease__c field on Lease
    	for(Lease__c objLease:lstLease)
    	{
    		if(objLease.Apartment__c != null && mapApartmentId_LstStartDate.containskey(objLease.Apartment__c) && mapApartmentId_LstStartDate.get(objLease.Apartment__c) != null)
    		{
	    		for(Date objStartDate:mapApartmentId_LstStartDate.get(objLease.Apartment__c))
	    		{
	    			if(objStartDate != null && objLease.Start_Date__c != null &&
	    			   mapApartmentId_MapStartDateToNextLeaseId.containskey(objLease.Apartment__c) && mapApartmentId_MapStartDateToNextLeaseId.get(objLease.Apartment__c) != null &&
	    		       mapApartmentId_MapStartDateToNextLeaseId.get(objLease.Apartment__c).containskey(objStartDate)
	    			   && mapApartmentId_MapStartDateToNextLeaseId.get(objLease.Apartment__c).get(objStartDate) != null)
	    			{
		    			if(objStartDate > objLease.Start_Date__c)
		    			{
		    				objLease.Next_Lease__c = mapApartmentId_MapStartDateToNextLeaseId.get(objLease.Apartment__c).get(objStartDate);
		    				lstLeaseToUpdate.add(objLease);
		    				break;
		    			}
	    			}
	    		}
    		}
    	}
    	
    	if(!lstLeaseToUpdate.isEmpty())
    		update lstLeaseToUpdate;
    	
    	///Call method to populate ActiveLease checkbox on lease
    	populateActiveLeaseCheckbox(lstApartment);
    }
    
    /*
    	* MethodName   : populateActiveLeaseCheckbox
        * Param        : List<Apartment__c> lstApartment
        * Description  : Populates Active_Lease__c checkbox on lease
    */
    private void populateActiveLeaseCheckbox(List<Apartment__c> lstApartment)
    {
    	List<Lease__c> lstLeaseToUpdate = new List<Lease__c>();
    	
    	///Update Active_Lease__c checkbox by requerying the updated values on the lease records
    	for(Lease__c objLease:[SELECT Active_Lease__c,Start_Date__c,Next_Lease_Start_Date__c,Future_Lease__c,End_Date__c,Deactivated__c
    	                       FROM Lease__c
    	                       WHERE Apartment__c IN:lstApartment])
    	{
    		if((objLease.Start_Date__c != null && objLease.Start_Date__c <= date.today()) &&
    		   (objLease.Next_Lease_Start_Date__c == null || (objLease.Next_Lease_Start_Date__c != null && objLease.Next_Lease_Start_Date__c > date.today())))
    		{
    			objLease.Active_Lease__c = true;
    		}
    		else
    		{
    			objLease.Active_Lease__c = false;
    		}
    		if(objLease.Start_Date__c != null && objLease.Start_Date__c > date.today())
    		{
    			objLease.Future_Lease__c = true;
    		}
    		if((objLease.Start_Date__c != null && objLease.Start_Date__c < date.today()) && 
    		   ((objLease.Active_Lease__c && objLease.End_Date__c != null && objLease.End_Date__c < date.today())|| (!objLease.Active_Lease__c)))
    		{
    			objLease.Deactivated__c = true;
    		}
    		lstLeaseToUpdate.add(objLease);
    	}
    	
    	if(!lstLeaseToUpdate.isEmpty())
    		update lstLeaseToUpdate;
    }
    
    /*
    	* MethodName   : finish
        * Param        : Database.BatchableContext BC
        * Description  : Performs necessary post-execution steps
    */
    global void finish(Database.BatchableContext BC)
    {
        ///Does nothing
    }
}