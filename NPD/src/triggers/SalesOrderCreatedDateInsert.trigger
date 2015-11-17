trigger SalesOrderCreatedDateInsert on Order (after insert) {

    
        Order[] NPDorder_chg = [select Id,netsuite_conn__NetSuite_Order_Date__c,OpportunityId from Order where Id in :Trigger.new];
        Set<Id> OppIds = new Set<Id>();
        for (Order NPDorder : NPDorder_chg) {
             OppIds.add(NPDorder.OpportunityId);
        }
        Opportunity[] OppChange = [select Id,Sales_Order_Created_Date__c from Opportunity where Id in :OppIds];
    
        Map<Id, Opportunity> update_o_list = new Map<Id, Opportunity>();
        for (Opportunity NPDo : OppChange) {
             NPDo.Sales_Order_Created_Date__c = date.today();
             update_o_list.put(NPDo.Id, NPDo);
        }
            
        update update_o_list.values();  
}