@isTest
    private class testleadNPDleadAfterInsertUpdate {

        static testMethod void testDeDupeInsert () { 
    
        List<Lead> leads = new List<lead>{};
        
        User runAsUser = [
            SELECT Id, alias, Name
                FROM User
                WHERE alias = 'ncloix'
        ];

        // Test Jigsaw Lead Import
        
        System.runAs(runAsUser) {
    
            // Load new test lead as if from website    
            for(Integer i = 0; i < 1; i++){
                Lead ld = new Lead(
                    Email = 'TESTDEDUPE@npd.com',
                    FirstName = 'Johnny',
                    LastName = 'TestLead' + i, 
                    LeadSource = 'Imported Target List',
                    Lead_Type__c = 'Imported List',
                    Company = 'TestCompany' + i,
                    MarketingCampaign__c = 'Web-Marketing-Opt In Web Page-200807'
                    );
                leads.add(ld);
            }
            
            test.startTest();
            
            insert leads;
            
            test.stopTest();
            
            List<Lead> insertedLeads = [
                SELECT Name, LeadBU__c, OwnerId, Lead_Type__c, LeadSource, Id, Email
                    FROM Lead
                    WHERE Id in :leads
            ];
            
            // Assert that the fields were set properly.
            for(Lead ld : insertedLeads){
                System.assertEquals('testdedupe@npd.com', ld.Email);
            }
        }
    }
}