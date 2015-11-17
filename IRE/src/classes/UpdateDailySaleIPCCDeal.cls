public class UpdateDailySaleIPCCDeal {
    public void UpdateIPCC(){
        list<Daily_Sale__c> lSalestoUpdate = [Select id, IPCC_Deal__c from Daily_sale__c where Fund__r.Fund_Acronym__c = 'IPCC' and IPCC_Deal__c = FALSE];
        list<Daily_Sale__c> lUpdatedSales = new list<Daily_Sale__c>();
        for(Daily_Sale__c ds: lSalestoUpdate){
            //ds.put('IPCC_Deal__c', true);
            if (ds.id != null){
            	ds.IPCC_Deal__c = true;
            	lUpdatedSales.add(ds);
            }
        }
        update lUpdatedSales;
    }
    public void UpdateDailySales(list<Daily_Sale__c> dsales){
		list<Fund__c> FundReference = [select id from Fund__c];        
    }
}