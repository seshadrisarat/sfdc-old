/**
*  ClassName      : SL_EngagementHandler
*  JIRATicket     : HL-11
*  CreatedOn      : 21/April/2014
*  ModifiedBy     : Edward Rivera
*  Description    : Handler class for SL_Engagement to Create/Update/Delete 'Engagement_Client_Subject__c ' Joiner objects records.
*/
public with sharing class SL_EngagementHandler 
{
    /* start - global variables*/
    public static boolean isTest = false;
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    /* stop - global variables*/
    
    /* start - constructor */     
    public SL_EngagementHandler(boolean isExecuting, integer size)
    {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    /*
        * MethodName        : onAfterInsert
        * param             : Map<id, Engagement__c> MapNewOpportunities
        * Description       : This function will be called after insert of the Engagement__c Records to 
                              Create 'Engagement_Client_Subject__c' Joiner object records if Engagement__c record is populated with either Client or Subject Fields.
    */
    public void onAfterInsert(Map<Id, Engagement__c> MapNewOpportunities)
    {
        // Map used to store filter Opportunities which have either client__c or Subject__c field populated to create Joiner Object records.
        Map<Id,Engagement__c> MapOppIdWithSubOrClntFldPopulatedToOpp = new Map<Id,Engagement__c>(); 
        
        for(Engagement__c objInsertedOpp : MapNewOpportunities.values())
        {
            if(objInsertedOpp.Client__c != null || objInsertedOpp.Subject__c != null)
                MapOppIdWithSubOrClntFldPopulatedToOpp.put(objInsertedOpp.Id,objInsertedOpp);
        }
        // Method Called to insert Joiner Object records for newly inserted Opportunities having either Client or Subject Field Populated.
        if(!MapOppIdWithSubOrClntFldPopulatedToOpp.IsEmpty())
           createEngagementClientSubjectRecords(MapOppIdWithSubOrClntFldPopulatedToOpp);
    }
    /*
        * MethodName        : onAfterUpdate
        * param             : Map<id, Engagement__c> MapNewOpportunities , Map<id, Engagement__c> MapOldOpportunities
        * Description       : This function will be called after Update of the Engagement__c Records to 
                              Create/Update/Delete 'Engagement_Client_Subject__c' Joiner object records.
    */
    public void onAfterUpdate(Map<Id, Engagement__c> MapNewOpportunities , Map<Id, Engagement__c> MapOldOpportunities )
    {
        updateEngagementClientSubjectRecords(MapNewOpportunities,MapOldOpportunities);
        manageDNDSharingRule(MapNewOpportunities,MapOldOpportunities);
    }
    
    /*
        * MethodName        : createEngagementClientSubjectRecords
        * param             : Map<id, Engagement__c> MapFilteredOpportunities 
        * Description       : This function will be called after insert of the Engagement__c Records to 
                              Create 'Engagement_Client_Subject__c' Joiner object records if Engagement__c record is populated with either Client or Subject Fields.
    */
    private void createEngagementClientSubjectRecords(Map<Id, Engagement__c> MapFilteredOpportunities)
    {
        // List to used to maintain Joiner Object Records which will be inserted for newly created Opportunities.
        List<Engagement_Client_Subject__c> lstOppClientSubToInsert = new List<Engagement_Client_Subject__c>(); 
    
        for(Engagement__c objFilteredOpp : MapFilteredOpportunities.values())
        {
            if(objFilteredOpp.Client__c != null)
            {
                Engagement_Client_Subject__c objOppClientSubject = new Engagement_Client_Subject__c(Engagement__c = objFilteredOpp.Id,
                                                                                                          Client_Subject__c = objFilteredOpp.Client__c, 
                                                                                                          Primary__c = true,
                                                                                                          Type__c = 'Client');
                // Adding in a List to insert Joiner object record                                                                    
                lstOppClientSubToInsert.add(objOppClientSubject);                                             
            }
            if(objFilteredOpp.Subject__c != null && objFilteredOpp.Subject__c != objFilteredOpp.Client__c)
            {
                Engagement_Client_Subject__c objOppClientSubject = new Engagement_Client_Subject__c(Engagement__c = objFilteredOpp.Id,
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
        * param             : Map<Id, Engagement__c> MapNewEngagement, Map<Id, Engagement__c> MapOldEngagement
        * Description       : This function will be called after update of the Engagement__c Records(Either Client__c or Subject__c field) to 
                              Create/Update/Delete 'Engagement_Client_Subject__c' Joiner object records.
    */
    private void updateEngagementClientSubjectRecords(Map<Id, Engagement__c> mapNewEngagement, Map<Id, Engagement__c> mapOldEngagement)
    {
        // List used to store Joiner records which will be deleted when Client__c Or Subject__c field is nullified.
        List<Engagement_Client_Subject__c> lstJoinerRecordsToDelete = new List<Engagement_Client_Subject__c>(); 
        // List used to store Joiner records which will be inserted when Client__c Or Subject__c field is Populated.
        List<Engagement_Client_Subject__c> lstJoinerRecordsToCreate = new List<Engagement_Client_Subject__c>(); 

        //Set of AccountIds that have tobe deleted from the joiner object
        Set<Id> setAccountIds = new Set<Id>();

        //Map to store all the updated client or Subject values
        Map<String, Id> mapEngagement = new Map<String, Id>();
        Set<String> setDeleteEngagementClientSub = new Set<String>();
        for(Engagement__c objEngagement : mapNewEngagement.values())
        {
            if(objEngagement.Client__c !=  mapOldEngagement.get(objEngagement.Id).Client__c)
            {
                //Put the Client value into the map, insert a new record of type 'Client' 
                mapEngagement.put(objEngagement.Client__c + '_' + objEngagement.Id + '_' + 'Client', objEngagement.Client__c);
                // if the client and subject are now the same
                if (objEngagement.Client__c==objEngagement.Subject__c){
                    // delete the 'Subject' record
                    Id idAccount = mapOldEngagement.get(objEngagement.Id).Subject__c;
                    setDeleteEngagementClientSub.add(idAccount + '_' + objEngagement.Id + '_' + 'Subject');
                    setAccountIds.add(idAccount);
                }
                // if the client and subject were the same, and the subject has not changed
                if (mapOldEngagement.get(objEngagement.Id).Client__c == mapOldEngagement.get(objEngagement.Id).Subject__c && objEngagement.Subject__c == mapOldEngagement.get(objEngagement.Id).Subject__c){
                    //Put the Subject value into the map, insert a new record of type 'Subject'
                    mapEngagement.put(objEngagement.Subject__c + '_' + objEngagement.Id + '_' + 'Subject', objEngagement.Subject__c);
                }
                // delete the old 'Client' record associated with this Engagement
                Id idAccount = mapOldEngagement.get(objEngagement.Id).Client__c;
                setDeleteEngagementClientSub.add(idAccount + '_' + objEngagement.Id + '_' + 'Client');
                setAccountIds.add(idAccount);
            }
            if(objEngagement.Subject__c != mapOldEngagement.get(objEngagement.Id).Subject__c)
            {
                // if the client and subject are not the same
                if(objEngagement.Client__c != objEngagement.Subject__c){
                    //Put the Subject value into the Map, insert a new record of type 'Subject'  
                    mapEngagement.put(objEngagement.Subject__c + '_' + objEngagement.Id + '_'  + 'Subject', objEngagement.Subject__c);
                }
                // delete the old 'Subject' record associated with this Engagement
                Id idAccount = mapOldEngagement.get(objEngagement.Id).Subject__c;
                setDeleteEngagementClientSub.add(idAccount + '_' + objEngagement.Id + '_' + 'Subject');
                setAccountIds.add(idAccount);
            }
        }
        //collect all the Engagement Client subject to be deleted
        for(Engagement_Client_Subject__c objOpportuntiyClientSub : [Select Id, Client_Subject__c,Type__c, Engagement__c
                                                                     From Engagement_Client_Subject__c 
                                                                     Where Client_Subject__c IN :setAccountIds])
        {
            if(setDeleteEngagementClientSub.Contains(objOpportuntiyClientSub.Client_Subject__c + '_' + objOpportuntiyClientSub.Engagement__c + '_' + objOpportuntiyClientSub.Type__c))
                lstJoinerRecordsToDelete.add(objOpportuntiyClientSub);
        }
        //iterate the MapEngagement to create new EngagementClientSubject records
        for(String strAccountEngagementType : mapEngagement.keyset())
        {
            if(strAccountEngagementType.split('_')[2] == 'Subject')
            {
                Engagement_Client_Subject__c objOppClientSubject = new Engagement_Client_Subject__c(Engagement__c = strAccountEngagementType.split('_')[1],
                                                                                                      Client_Subject__c = mapEngagement.get(strAccountEngagementType), 
                                                                                                      Primary__c = true,
                                                                                                      Type__c = 'Subject');
                 // Adding in a List to insert Joiner object record                                                                
                 lstJoinerRecordsToCreate.add(objOppClientSubject); 
            }
            else if(strAccountEngagementType.split('_')[2] == 'Client')
            {
                Engagement_Client_Subject__c objOppClientSubject = new Engagement_Client_Subject__c(Engagement__c = strAccountEngagementType.split('_')[1],
                                                                                                      Client_Subject__c = mapEngagement.get(strAccountEngagementType), 
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
    /* End */
    
    /*
        * MethodName        : manageDNDSharingRule
        * param             : Map<Id, Engagement__c> MapNewEngagement, Map<Id, Engagement__c> MapOldEngagement
        * Description       : This function will be called after update of the Engagement__c Records.
    */
    private void manageDNDSharingRule(Map<Id, Engagement__c> mapNewEngagement, Map<Id, Engagement__c> mapOldEngagement)
    {
    	Set<String> setParentId = new Set<String>();//set of engagement id 
    	
    	//Iterating over Engagement__c to get only those engagement id whose name is updated.
    	For(Engagement__c objEngagement : mapNewEngagement.values())
		{
			if(objEngagement.Name != mapOldEngagement.get(objEngagement.Id).Name 
			   && (mapOldEngagement.get(objEngagement.Id).Name.startsWithIgnoreCase('DND')) || objEngagement.Name.startsWithIgnoreCase('DND'))
			{
				setParentId.add(objEngagement.Id);
			}   
		}
		
		for(Engagement_Counterparty__c objEC : [SELECT Id FROM Engagement_Counterparty__c WHERE Engagement__c IN : setParentId])	
		{
			setParentId.add(objEC.Id);
		}
		
		for(Revenue_Accrual__c objEC : [SELECT Id FROM Revenue_Accrual__c WHERE Engagement__c IN : setParentId])	
		{
			setParentId.add(objEC.Id);
		}
		
		//Calling the method to create the sharing rule according to the Engagement__c names
		if(!setParentId.isEmpty())
			SL_ManageSharingRules.deleteSharesOnChangeParentName(setParentId, 'Engagement__c'); 
    }
}