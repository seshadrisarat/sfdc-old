/* Written: 02/13/2013
*  Author : KR
*  This will test the insert of Leads and recursive processing for the update of
*  Lead Owner 2 on the Lead object
*/
@isTest
private class Test_UpdateLeadOwner2AfterInsertUpdate {

    static testMethod void myUnitTest() {
        // load test lead data
        list<Lead> InsertLeads=new list<Lead>();   
        Lead lead1 = new Lead(Phone='1234567890',
            LeadSource='Advertising',
            LastName='TestJohnson',
            FirstName='Test',
            LeadBU__c='Automotive',
            Company='Test Company',
            CurrencyIsoCode='USD',
            Lead_Type__c='In-Person Meeting',
            Status='New Leads - Not yet working',
            Rating='Z - Not Contacted - Unknown Quality',
            Email='test@npd.com',
            Press_Releases__c = True,
            Country_of_Interest__c = 'United States'
            );
 
         // Test if there is anything to udpate and if method is already running, then write data
         If (InsertLeads.isEmpty() == false && UpdateLeadOwner2Running.recursive == false) {
            UpdateLeadOwner2Running.recursive = true;
            InsertLeads.Add(lead1);
        }
    }
}