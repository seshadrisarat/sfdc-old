@isTest
private class Test_CIFRevision_AfterUpdate {

    static testMethod void myUnitTest() {
    
        CIF_Revision__c myCIFRev = new CIF_Revision__c (
            name = 'a',
            description__c = 'test',
            CIF_Revision_Type__c = 'Simple',
            CIF_Revision_Type_Simple__c = 'PO #',
            Instructions_PO__c = 'Test',
            CIF_Revision__c = 1
        );
         
        insert myCIFRev;
        delete myCIFRev;
        
    }
    
}