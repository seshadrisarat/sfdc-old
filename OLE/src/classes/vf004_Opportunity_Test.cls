@isTest 
private class vf004_Opportunity_Test {
    static testMethod void testCreateUpdate() {
        //general testing - access class "special" values
        vf004_Opportunity controller=new vf004_Opportunity();
        system.debug(vf004_Opportunity.CURRENT_PML_COUNT);
        system.debug(vf004_Opportunity.CURRENT_SL_COUNT);
        system.assert(!vf004_Opportunity.st_LP_Sync_Opportunity_RecordTypeID.isEmpty(),'vf004_Opportunity ERROR: must have at least one opportunity record type for LP');
        system.assert(!vf004_Opportunity.st_Clear_PML_Opportunity_RecordTypeID.isEmpty(),'vf004_Opportunity ERROR: must have at least one opportunity record type for Clear');
        
        List<Id> lOPRT_LP=new List<ID>(vf004_Opportunity.st_LP_Sync_Opportunity_RecordTypeID);
        Opportunity Op1_LP=new Opportunity(
            RecordTypeId=lOPRT_LP[0]
            ,Name='Test LP Opportunity'
            ,Description='Test LP Opportunity'
            ,StageName='1-Pending'
            ,CloseDate=date.today()
        );
        List<Id> lOPRT_Clear=new List<ID>(vf004_Opportunity.st_Clear_PML_Opportunity_RecordTypeID);
        Opportunity Op2_Clear=new Opportunity(
            RecordTypeId=lOPRT_Clear[0]
            ,Name='Test Clear Opportunity'
            ,Description='Test Clear Opportunity'
            ,StageName='1-Pending'
            ,CloseDate=date.today()
        );

        List<Opportunity> lOpportunity_Test=new List<Opportunity>{ Op1_LP, Op2_Clear};      

//start testing     
        Test.startTest();
        insert lOpportunity_Test;
        Op1_LP.StageName='4-Closed/Won';
        Op2_Clear.StageName='6-Closed/Won Invoiced';
        update lOpportunity_Test;
//confirm that Opportunity_Number__c was allocated      
        map<Id,Opportunity> m_Id_Opportunity=new map<Id,Opportunity>([select id, Opportunity_Number__c from Opportunity where Id IN (:Op1_LP.Id, :Op2_Clear.Id)]);
        system.assert(m_Id_Opportunity.get(Op1_LP.Id).Opportunity_Number__c!=null, 'vf004_Opportunity ERROR: could not assign "Opportunity Number" for LP Opportunity');
        system.assert(m_Id_Opportunity.get(Op2_Clear.Id).Opportunity_Number__c!=null, 'vf004_Opportunity ERROR: could not assign "Opportunity Number" for Clear Opportunity');
        Test.stopTest();    
    }
}