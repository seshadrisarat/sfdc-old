/**
*  ClassName      : SL_DocusignStatusHandler
*  JIRATicket     : THOR-69
*  CreatedOn      : 7/20/2015
*  ModifiedBy     : Sanath
*  Description    : Handler Class for Updating Opportunity Status when all Leases are signed by Tenants
*/
public class SL_DocusignStatusHandler 
{
    /*Start Constructor*/
    public SL_DocusignStatusHandler()
    {
        //Do Nothing
    }
    /*End Constructor*/
    
    /*
        * MethodName   : onBeforeInsert
        * param        : trigger.newMap
        * Description  : Will invoke on After insert of Docusign Status record
    */

    public void onBeforeInsert(List<dsfs__DocuSign_Status__c> lstDocusignStatus)
    {
        updateDocumentType(lstDocusignStatus);
    }

    /*
        * MethodName   : updateDocumentType
        * param        : List<dsfs__DocuSign_Status__c>
        * Description  : Update Document Type field on Document Status
    */

    private void updateDocumentType(List<dsfs__DocuSign_Status__c> lstDocusignStatus)
    {
        String LEASE_SUBJECT = DocusignStatus_Document_Mapping__c.getValues('Lease').Subject__c;
        
        List<String> lstLeaseDocs = (LEASE_SUBJECT.contains(';')) ? LEASE_SUBJECT.split(';') : new List<String>{LEASE_SUBJECT};
        
        for(dsfs__DocuSign_Status__c objDocusignStatus : lstDocusignStatus)
        {
            for(String docs : lstLeaseDocs)
            {
                if(objDocusignStatus.dsfs__Subject__c != null && objDocusignStatus.dsfs__Subject__c.contains(docs)) 
                {
                    objDocusignStatus.Docusign_Status_Type__c = 'Lease';
                }
            }
        }
    }
}