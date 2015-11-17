/**  
* \arg ClassName        : SL_LeadTriggerHandlerTest
* \arg JIRATicket       : NPD-213
* \arg CreatedOn        : 13/October/2015
* \arg LastModifiedOn   : 13/October/2015
* \arg CreatededBy      : Smriti
* \arg ModifiedBy       : Smriti 
* \arg Description      : Test class for SL_LeadTriggerHandler
*/
@isTest
private class SL_LeadTriggerHandlerTest {

	      /*Added by Smriti for NPD-213*/
    private static testMethod void myUnitTest() {
            
            Practice__c objPractice1 = new Practice__c(Name='Test',CurrencyIsoCode='USD');
            insert objPractice1;
            
            Practice__c objPractice2 = new Practice__c(Name='Test',CurrencyIsoCode='USD');
            insert objPractice2;
            
            Account objAccount1 = new Account(Name='Test',BillingCountry='Austria',Practice__c=objPractice2.Id);
            insert objAccount1;
            
            Account objAccount2 = new Account(Name='Test',BillingCountry='Austria',Practice__c=objPractice1.Id,Company_Account__c=objAccount1.Id);
            insert objAccount2;
            
    
            // create a Lead
            Lead lead = new Lead( LastName='Doe',
                                FirstName='John',
                                Company='Test',
                                Status='Inquiry',
                                Email='test@test.com',
                                Practice__c=objPractice1.Id
                                );  
            
            insert lead;                
            
            Database.LeadConvert lc = new database.LeadConvert();
            lc.setLeadId(lead.id);
            lc.setDoNotCreateOpportunity(false);
            lc.setConvertedStatus('Converted');
            
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            System.assert(lcr.isSuccess());
            }

}