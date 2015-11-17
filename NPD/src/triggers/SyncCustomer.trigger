trigger SyncCustomer on Subsidiary_Customer__c (after insert, after update) {
    integrator_da__.RealTimeExportTrigger.run();
}