@isTest
private class LeadHandlerTest {
    
    //test dpb
    
    static testMethod void testLeadHandler() {
    
    List<Lead> testLeads = new List<Lead>();
    List<Contact> testContacts = new List<Contact>();
        
        Contact contact1 = 
                new Contact(NPD_Client_Satisfaction_Survey__c = 'Yes', 
                            LastName = 'Test', 
                            JobFunction__c = 'Administration', 
                            Email = 'test@npd.com', 
                            ContactType__c = 'NPD Customer');
                            
        testcontacts.add(contact1);
        
        Contact contact2 = 
                new Contact(NPD_Client_Satisfaction_Survey__c = 'Yes', 
                            LastName = 'TestJohnson', 
                            JobFunction__c = 'Administration', 
                            Email = 'test@npd.com', 
                            ContactType__c = 'NPD Customer');
        testContacts.add(contact2);
        
            insert testContacts;
        
        
        
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
                            
            testLeads.add(lead1);
                                    
        Lead lead2 = new Lead(Phone='1234567890',
                            LeadSource='Advertising',
                            LastName='TestJohnson2',
                            FirstName='Test2',
                            LeadBU__c='Beauty',
                            Company='Test Company',
                            CurrencyIsoCode='CAD',
                            Lead_Type__c='In-Person Meeting',
                            Status='New Leads - Not yet working',
                            Rating='Z - Not Contacted - Unknown Quality',
                            Email='test2@npd.com',
                            PrimaryAreaofInterest__c = 'Retail',
                            NPD_Group_Blog__c = true,
                            Subscriptions__c = 'Fashion'
                            );
        testLeads.add(lead2);
        
            insert testLeads;
        
        Lead lead3 = new Lead(Phone='1234567890',
                            LeadSource='Advertising',
                            LastName='TestJohnson3',
                            FirstName='Test2',
                            LeadBU__c='Beauty',
                            Company='Test Company',
                            CurrencyIsoCode='CAD',
                            Lead_Type__c='In-Person Meeting',
                            Status='New Leads - Not yet working',
                            Rating='Z - Not Contacted - Unknown Quality',
                            Email='test@npd.com',
                            PrimaryAreaofInterest__c = 'Retail'
//                            MarketingCampaign__c = 'Web-Marketing-Opt In Web Page-200807',
//                            Country_of_Interest__c = 'El Dorado; United States; United Kingdom'
                            );
        insert lead3;
    }
}