/**  
* \arg ClassName      : SL_CreateWelcomeKit
* \arg JIRATicket     : STARGAS-12
* \arg CreatedOn      : 1/Sep/2014
* \arg LastModifiedOn : 12/Sep/2014
* \arg CreatededBy    : SRUTI
* \arg ModifiedBy     : Pankaj Ganwani
* \arg Description    : This is controller is used for sending site link to User via email
*/
global without sharing class SL_CreateWelcomeKit 
{
    /*
        * MethodName        : createWelcomeKit
        * param             : Opportunity ID and Account Id
        * Description       : Will create Welcome_Kit__c record
    */
    WebService static String createWelcomeKit(Id idOpportunity, String accId)
    {        
        Opportunity objOpportunity;// This variable is used to hold the value of current Opportunity
        //Fetching the customer email address from current Opportunity
        List<Opportunity> lstOpportunity = [SELECT ID, Customer_s_Email_Address__c 
        								    FROM Opportunity 
        								    WHERE ID = :idOpportunity LIMIT 1];
        //checking if the list is not empty
        if(!lstOpportunity.isEmpty())
        	objOpportunity = lstOpportunity[0];
        
        //Variable to hold number of sent welcome kits
        Integer intWelcomeKitSent = [SELECT count() FROM Welcome_Kit__c WHERE Opportunity__c =:idOpportunity];
        
        //Creating the instace of welcome kit record with the status Sent if this is sent first time and the status of subsequent welcome kits will be set as Resent      	
        Welcome_Kit__c objWelcomeKit = new Welcome_Kit__c(Opportunity__c = idOpportunity, 
        												  Client_Name__c= accId, 
        												  Email__c = objOpportunity.Customer_s_Email_Address__c,
        												  Letter_Status__c = intWelcomeKitSent > 0 ? 'Resent' : 'Sent',
        												  Sent_Date__c = DateTime.now());
            
        try
        {
            insert objWelcomeKit;
        }
        catch(Exception ex)
        {
            System.debug('============='+ex.getMessage()+'================'+ex.getLineNumber());
            return 'ERROR# An error has occurred sending the Welcome Kit'; 
        }
        return objWelcomeKit.Id;
    }
}