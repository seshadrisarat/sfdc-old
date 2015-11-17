@isTest
private class SL_Test_Docusign {
    private static testMethod void updateStageName() 
    {
        insert new DocusignStatus_Document_Mapping__c(Name='Lease' , Subject__c='Lease Documents;Renewal Lease Documents;Lease Extension Documents');
        
        final Id CUSTOMER_ID = [SELECT Id FROM RecordType WHERE DeveloperName =: 'PersonAccount' LIMIT 1].Id;
        Account objAccount = new Account(RecordTypeId = CUSTOMER_ID , LastName='Test Account For Docusign 1');
        insert objAccount;
        
        Opportunity objOpportunity = new Opportunity(AccountId=objAccount.Id , Name='Test Opportunity for Docusign 1' , CloseDate = date.today().addDays(40) , StageName='Qualified Prospect');
        insert objOpportunity;
        
        Contact_Role__c objContactRole = new Contact_Role__c(Opportunity__c = objOpportunity.Id , Person_Account__c = objAccount.Id , Role__c = 'Tenant' , Status__c = 'Application Sent');
        insert objContactRole;
        
        objContactRole.Status__c = 'Application Approved';
        update objContactRole;
        
        dsfs__DocuSign_Status__c objDocusignStatus = new dsfs__DocuSign_Status__c(dsfs__Envelope_Status__c='Sent' , dsfs__Subject__c='Lease Documents for Residence 3B3 at 838 West End Avenue' , dsfs__Opportunity__c=objOpportunity.Id);
        insert objDocusignStatus;
        
        dsfs__DocuSign_Recipient_Status__c objRecipientStatusTenant = new dsfs__DocuSign_Recipient_Status__c(dsfs__DocuSign_Recipient_Id__c = '1234123243243243242343243243243242' , Name ='THOR customer Test 1' , dsfs__Parent_Status_Record__c=objDocusignStatus.Id , dsfs__DocuSign_Routing_Order__c = 1 , dsfs__Recipient_Status__c = 'Delievred');
        insert objRecipientStatusTenant;
        
        dsfs__DocuSign_Recipient_Status__c objRecipientStatusTHOR = new dsfs__DocuSign_Recipient_Status__c(dsfs__DocuSign_Recipient_Id__c = '1234123243243243242343243243243242',Name ='THOR Signee' , dsfs__Parent_Status_Record__c=objDocusignStatus.Id , dsfs__DocuSign_Routing_Order__c = 6 , dsfs__Recipient_Status__c = 'Created');
        insert objRecipientStatusTHOR;
        
        objRecipientStatusTenant.dsfs__Recipient_Status__c = 'Completed';
        update objRecipientStatusTenant;
        
        objRecipientStatusTHOR.dsfs__Recipient_Status__c = 'Completed';
        update objRecipientStatusTHOR;
        
        objDocusignStatus.dsfs__Envelope_Status__c = 'Completed';
        update objDocusignStatus;
	}

}