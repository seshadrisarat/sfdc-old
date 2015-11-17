/**
*  ClassName      : SL_DocusignRecipientHandler
*  JIRATicket     : THOR-69
*  CreatedOn      : 7/20/2015
*  ModifiedBy     : Sanath
*  Description    : Handler Class for Updating Opportunity Status when all Leases are signed by Tenants
*/
public class SL_DocusignRecipientHandler 
{	
	private static final String DOCUSIGN_DOCUMENT_DONE = 'Completed';
	private static final String DOCUSIGN_TENANT_LEASE_SIGNED = 'Lease Signed by Tenants';

    /*Start Constructor*/
    public SL_DocusignRecipientHandler()
    {
        //Do Nothing
    }
    /*End Constructor*/

    /*
        * MethodName   : onAfterUpdate
        * param        : trigger.newMap
        * Description  : Will invoke on After Update of Docusign Recipient Status record
    */

    public void onAfterUpdate(map<Id , dsfs__DocuSign_Recipient_Status__c> mapIdToDocusignRecipient)
    {
        updateOpportunityStageName(mapIdToDocusignRecipient);
    }

    /*
        * MethodName   : updateOpportunityStageName
        * param        : trigger.newMap
        * Description  : Will Update the stageName of Opportunity when all Leases have been signed by Client
    */

    private void updateOpportunityStageName(map<Id , dsfs__DocuSign_Recipient_Status__c> mapIdToDocusignRecipient)
    {
        List<Opportunity> lstOpportunityToUpdate = new List<Opportunity>();
        Set<Integer> setTenantOrderNos = new Set<Integer>{1,2,3,4};
        Set<Id> setDocusignStatusIds = new Set<Id>();
        map<Id , Id> mapDocusignStatusToOpportunity = new map<Id , Id>();

        for(dsfs__DocuSign_Recipient_Status__c objDocusignRecipientStatus : mapIdToDocusignRecipient.values())
        {
        	setDocusignStatusIds.add(objDocusignRecipientStatus.dsfs__Parent_Status_Record__c);
        }	

        for(dsfs__DocuSign_Status__c objDocusignStatus : [Select Id,dsfs__Opportunity__c from dsfs__DocuSign_Status__c 
        												  where Id IN :setDocusignStatusIds 
        												  AND Docusign_Status_Type__c = 'Lease'])
        {
        	mapDocusignStatusToOpportunity.put(objDocusignStatus.Id , objDocusignStatus.dsfs__Opportunity__c);
        }

        for(dsfs__DocuSign_Recipient_Status__c objDocusignRecipientStatus : mapIdToDocusignRecipient.values())
        {
        	if(setTenantOrderNos.contains((Integer)objDocusignRecipientStatus.dsfs__DocuSign_Routing_Order__c) 
        		&& objDocusignRecipientStatus.dsfs__Recipient_Status__c == DOCUSIGN_DOCUMENT_DONE
        		&& mapDocusignStatusToOpportunity.containsKey(objDocusignRecipientStatus.dsfs__Parent_Status_Record__c))
        	{
				lstOpportunityToUpdate.add(new Opportunity(Id=mapDocusignStatusToOpportunity.get(objDocusignRecipientStatus.dsfs__Parent_Status_Record__c) ,
														   StageName = DOCUSIGN_TENANT_LEASE_SIGNED));        		
        	}
        }

        if(!lstOpportunityToUpdate.isEmpty())
        	update lstOpportunityToUpdate;
    }
}