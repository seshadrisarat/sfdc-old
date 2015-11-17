trigger SalesOrderApprovedDateUpdate on Order (after update) {

        Set<Id> NPDorder_New = new Set<Id>();
        
        for (Order NPDorder : Trigger.new) {
            Order OldNPDorder = Trigger.oldMap.get(NPDorder.ID);
            if (NPDorder.netsuite_conn__NetSuite_Order_Status__c != OldNPDorder.netsuite_conn__NetSuite_Order_Status__c) {
                NPDorder_New.add(NPDorder.Id);
            }
        }
    
        Order[] NPDorder_chg = [select Id,netsuite_conn__NetSuite_Order_Status__c,OpportunityId from Order where Id in :NPDorder_New and (netsuite_conn__NetSuite_Order_Status__c like '%fulfill%' or netsuite_conn__NetSuite_Order_Status__c like '%bill%' or netsuite_conn__NetSuite_Order_Status__c = 'Closed')];
        Set<Id> NPDo_NoRev_Id = new Set<Id>();
        for (Order NPDorder : NPDorder_chg) {
             NPDo_NoRev_Id.add(NPDorder.OpportunityId);
        }
        Opportunity[] NPDo_NoRev = [select Id,Sales_Order_Approved_Date__c from Opportunity where Id in :NPDo_NoRev_Id];
    
        Map<Id, Opportunity> updated_o_NoRev = new Map<Id, Opportunity>();
        for (Opportunity NPDo : NPDo_NoRev) {
             NPDo.Sales_Order_Approved_Date__c = date.today();
             updated_o_NoRev.put(NPDo.Id, NPDo);
        }
            
        update updated_o_NoRev.values();
}