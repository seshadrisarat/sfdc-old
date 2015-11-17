/**
*  ClassName      : SL_OpportunityHandler
*  JIRATicket     : HL-11
*  CreatedOn      : 21/April/2014
*  ModifiedBy     : Edward Rivera
*  Description    : Handler class for SL_Opportunity to Create/Update/Delete 'Opportunity_Client_Subject__c' Joiner objects records.
*/
public with sharing class SL_OpportunityHandler 
{
    /* start - global variables*/
    public static boolean isTest = false;
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    /* stop - global variables*/
	
    /* start - constructor */     
    public SL_OpportunityHandler(boolean isExecuting, integer size)
    {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
	/*
        * MethodName        : onAfterInsert
        * param             : Map<id, Opportunity__c> MapNewOpportunities
        * Description       : This function will be called after insert of the Opportunity__c Records to 
        					  Create 'Opportunity_Client_Subject__c' Joiner object records if Opportunity__c record is populated with either Client or Subject Fields.
    */
	public void onAfterInsert(Map<Id, Opportunity__c> MapNewOpportunities)
    {
        // Map used to store filter Opportunities which have either client__c or Subject__c field populated to create Joiner Object records.
    	Map<Id,Opportunity__c> MapOppIdWithSubOrClntFldPopulatedToOpp = new Map<Id,Opportunity__c>(); 
    	
    	for(Opportunity__c objInsertedOpp : MapNewOpportunities.values())
    	{
    		if(objInsertedOpp.Client__c != null || objInsertedOpp.Subject__c != null)
    			MapOppIdWithSubOrClntFldPopulatedToOpp.put(objInsertedOpp.Id,objInsertedOpp);
    	}
        // Method Called to insert Joiner Object records for newly inserted Opportunities having either Client or Subject Field Populated.
        if(!MapOppIdWithSubOrClntFldPopulatedToOpp.IsEmpty())
    	   createOpportunityClientSubjectRecords(MapOppIdWithSubOrClntFldPopulatedToOpp);
    }
	/*
        * MethodName        : onAfterUpdate
        * param             : Map<id, Opportunity__c> MapNewOpportunities , Map<id, Opportunity__c> MapOldOpportunities
        * Description       : This function will be called after Update of the Opportunity__c Records to 
        					  Create/Update/Delete 'Opportunity_Client_Subject__c' Joiner object records.
    */
	public void onAfterUpdate(Map<Id, Opportunity__c> MapNewOpportunities , Map<Id, Opportunity__c> MapOldOpportunities )
    {
    	updateOpportunityClientSubjectRecords(MapNewOpportunities,MapOldOpportunities);
    	manageDNDSharingRule(MapNewOpportunities,MapOldOpportunities);
    }
    
    /*
        * MethodName        : createOpportunityClientSubjectRecords
        * param             : Map<id, Opportunity__c> MapFilteredOpportunities 
        * Description       : This function will be called after insert of the Opportunity__c Records to 
        					  Create 'Opportunity_Client_Subject__c' Joiner object records if Opportunity__c record is populated with either Client or Subject Fields.
    */
    private void createOpportunityClientSubjectRecords(Map<Id, Opportunity__c> MapFilteredOpportunities)
    {
        // List to used to maintain Joiner Object Records which will be inserted for newly created Opportunities.
		List<Opportunity_Client_Subject__c> lstOppClientSubToInsert = new List<Opportunity_Client_Subject__c>(); 
	
    	for(Opportunity__c objFilteredOpp : MapFilteredOpportunities.values())
    	{
            if(objFilteredOpp.Client__c != null)
    		{
    			Opportunity_Client_Subject__c objOppClientSubject = new Opportunity_Client_Subject__c(Opportunity__c = objFilteredOpp.Id,
                                                                                                          Client_Subject__c = objFilteredOpp.Client__c, 
                                                                                                          Primary__c = true,
                                                                                                          Type__c = 'Client');
    			// Adding in a List to insert Joiner object record   																  
    			lstOppClientSubToInsert.add(objOppClientSubject); 											  
    		}
    		if(objFilteredOpp.Subject__c != null && objFilteredOpp.Subject__c != objFilteredOpp.Client__c)
    		{
    			Opportunity_Client_Subject__c objOppClientSubject = new Opportunity_Client_Subject__c(Opportunity__c = objFilteredOpp.Id,
                                                                                                          Client_Subject__c = objFilteredOpp.Subject__c, 
                                                                                                          Primary__c = true,
                                                                                                          Type__c = 'Subject');
    			// Adding in a List to insert Joiner object record																  
    			lstOppClientSubToInsert.add(objOppClientSubject); 
    		}
    	}
        if(!lstOppClientSubToInsert.IsEmpty())
            Database.insert(lstOppClientSubToInsert,false);
    }
    /*
        * MethodName        : updateOppClientSubRecords
        * param             : Map<Id, Opportunity__c> MapNewOpportunity, Map<Id, Opportunity__c> MapOldOpportunity
        * Description       : This function will be called after update of the Opportunity__c Records(Either Client__c or Subject__c field) to 
        					  Create/Update/Delete 'Opportunity_Client_Subject__c' Joiner object records.
    */
    private void updateOpportunityClientSubjectRecords(Map<Id, Opportunity__c> mapNewOpportunity, Map<Id, Opportunity__c> mapOldOpportunity)
    {
    	// List used to store Joiner records which will be deleted when Client__c Or Subject__c field is nullified.
    	List<Opportunity_Client_Subject__c> lstJoinerRecordsToDelete = new List<Opportunity_Client_Subject__c>(); 
        // List used to store Joiner records which will be inserted when Client__c Or Subject__c field is Populated.
    	List<Opportunity_Client_Subject__c> lstJoinerRecordsToCreate = new List<Opportunity_Client_Subject__c>(); 

        //Set of AccountIds that have tobe deleted from the joiner object
        Set<Id> setAccountIds = new Set<Id>();

        //Map to store all the updated client or Subject values
        Map<String, Id> mapOpportunity = new Map<String, Id>();
        Set<String> setDeleteOpportunityClientSub = new Set<String>();
        for(Opportunity__c objOpportunity : mapNewOpportunity.values())
        {
            if(objOpportunity.Client__c !=  mapOldOpportunity.get(objOpportunity.Id).Client__c)
            {
                //Put the Client value into the map, insert a new record of type 'Client' 
                mapOpportunity.put(objOpportunity.Client__c + '_' + objOpportunity.Id + '_' + 'Client', objOpportunity.Client__c);
                // if the client and subject are now the same
                if (objOpportunity.Client__c==objOpportunity.Subject__c){
                    // delete the 'Subject' record
                    Id idAccount = mapOldOpportunity.get(objOpportunity.Id).Subject__c;
                    setDeleteOpportunityClientSub.add(idAccount + '_' + objOpportunity.Id + '_' + 'Subject');
                    setAccountIds.add(idAccount);
                }
                // if the client and subject were the same, and the subject has not changed
                if (mapOldOpportunity.get(objOpportunity.Id).Client__c == mapOldOpportunity.get(objOpportunity.Id).Subject__c && objOpportunity.Subject__c == mapOldOpportunity.get(objOpportunity.Id).Subject__c){
                    //Put the Subject value into the map, insert a new record of type 'Subject'
                    mapOpportunity.put(objOpportunity.Subject__c + '_' + objOpportunity.Id + '_' + 'Subject', objOpportunity.Subject__c);
                }
                // delete the old 'Client' record associated with this opportunity
                Id idAccount = mapOldOpportunity.get(objOpportunity.Id).Client__c;
                setDeleteOpportunityClientSub.add(idAccount + '_' + objOpportunity.Id + '_' + 'Client');
                setAccountIds.add(idAccount);
            }
            if(objOpportunity.Subject__c != mapOldOpportunity.get(objOpportunity.Id).Subject__c)
            {
                // if the client and subject are not the same
                if(objOpportunity.Client__c != objOpportunity.Subject__c){
                    //Put the Subject value into the Map, insert a new record of type 'Subject'  
                    mapOpportunity.put(objOpportunity.Subject__c + '_' + objOpportunity.Id + '_'  + 'Subject', objOpportunity.Subject__c);
                }
                // delete the old 'Subject' record associated with this opportunity
                Id idAccount = mapOldOpportunity.get(objOpportunity.Id).Subject__c;
                setDeleteOpportunityClientSub.add(idAccount + '_' + objOpportunity.Id + '_' + 'Subject');
                setAccountIds.add(idAccount);
            }
        }
        //collect all the Opportunity Client subject to be deleted
        for(Opportunity_Client_Subject__c objOpportuntiyClientSub : [Select Id, Client_Subject__c,Type__c, Opportunity__c
                                                                     From Opportunity_Client_Subject__c 
                                                                     Where Client_Subject__c IN :setAccountIds])
        {
            if(setDeleteOpportunityClientSub.Contains(objOpportuntiyClientSub.Client_Subject__c + '_' + objOpportuntiyClientSub.Opportunity__c + '_' + objOpportuntiyClientSub.Type__c))
                lstJoinerRecordsToDelete.add(objOpportuntiyClientSub);
        }
        //iterate the MapOpportunity to create new OpportunityClientSubject records
        for(String strAccountOpportunityType : mapOpportunity.keyset())
        {
            if(strAccountOpportunityType.split('_')[2] == 'Subject')
            {
                Opportunity_Client_Subject__c objOppClientSubject = new Opportunity_Client_Subject__c(Opportunity__c = strAccountOpportunityType.split('_')[1],
                                                                                                      Client_Subject__c = mapOpportunity.get(strAccountOpportunityType), 
                                                                                                      Primary__c = true,
                                                                                                      Type__c = 'Subject');
                 // Adding in a List to insert Joiner object record                                                                
                 lstJoinerRecordsToCreate.add(objOppClientSubject); 
            }
            else if(strAccountOpportunityType.split('_')[2] == 'Client')
            {
                Opportunity_Client_Subject__c objOppClientSubject = new Opportunity_Client_Subject__c(Opportunity__c = strAccountOpportunityType.split('_')[1],
                                                                                                      Client_Subject__c = mapOpportunity.get(strAccountOpportunityType), 
                                                                                                      Primary__c = true,
                                                                                                      Type__c = 'Client');
                 // Adding in a List to insert Joiner object record                                                                
                 lstJoinerRecordsToCreate.add(objOppClientSubject); 
            }
        }
        //Delete the Records
        if(!lstJoinerRecordsToDelete.IsEmpty())
            Database.delete(lstJoinerRecordsToDelete,false);
        //Create new records
        if(!lstJoinerRecordsToCreate.IsEmpty())
            Database.insert(lstJoinerRecordsToCreate,false);
    }
    
    /*
        * MethodName        : manageDNDSharingRule
        * param             : Map<Id, Engagement__c> MapNewEngagement, Map<Id, Engagement__c> MapOldEngagement
        * Description       : This function will be called after update of the Engagement__c Records.
    */
    private void manageDNDSharingRule(Map<Id, Opportunity__c> mapNewOpportunity, Map<Id, Opportunity__c> mapOldOpportunity)
    {
    	Set<String> setOpportunityId = new Set<String>();//set of opportunity id  
    	
    	//Iterating over Opportunity__c to get only those Opportunity id whose name is updated.
    	For(Opportunity__c objOpportunity : mapNewOpportunity.values())
		{
			if(objOpportunity.Name != mapOldOpportunity.get(objOpportunity.Id).Name 
			   && (mapOldOpportunity.get(objOpportunity.Id).Name.startsWithIgnoreCase('DND')) || objOpportunity.Name.startsWithIgnoreCase('DND'))
			{
				setOpportunityId.add(objOpportunity.Id);
			}   
		}
		//Calling the method to create the sharing rule according to the Opportunity__c names
		if(!setOpportunityId.isEmpty()) 
			SL_ManageSharingRules.deleteSharesOnChangeParentName(setOpportunityId, 'Opportunity__c');
    }
    
    
}