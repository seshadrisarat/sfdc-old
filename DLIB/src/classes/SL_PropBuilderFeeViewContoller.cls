public with sharing class SL_PropBuilderFeeViewContoller {


	public List<condensedOli> feeViewItems {get;set;}
	public decimal opptyTotalValue {get; set;}
	public integer opptyTotalHours {get;set;}
    public string opptyId {get;set;}
    public string opptyStageName {get;set;}
    public string opptyName {get;set;}
    public OpportunityLineItem discountItem {get;set;}

    public class condensedOli {
        public String description {get;set;}
        public string productid  {get;set;}
        public String productName  {get;set;}
        public List<OpportunityLineItem> lineItems  {get;set;}
        public Decimal totalOliHours  {get;set;}
        public Decimal totalOliPrice  {get;set;}
    }

    public SL_PropBuilderFeeViewContoller() {
    	if(Apexpages.currentPage().getParameters().containsKey('oppty')) {
    		opptyId = Apexpages.currentPage().getParameters().get('oppty');

    		List<OpportunityLineItem> opptyLineItems = new List<OpportunityLineItem>();
    		opptyLineItems = [Select PriceBookEntry.name
                                        , PriceBookEntry.product2id
                                        , id
                                        , role__c
                                        , quantity
                                        , unitprice
                                        , totalprice
                                        , description
                                        , Opportunity.StageName
                                        , Opportunity.name
                                        , isDiscount__c 
                                        From 
                                        OpportunityLineItem 
                                        where
                                         opportunityId = :opptyId ];
    		
            map<string,condensedOli> condensedOlis = new map<string,condensedOli>();
            for(OpportunityLineItem oli : opptyLineItems) {
                if(oli.isDiscount__c == false){
                    string prodid = oli.PriceBookEntry.product2id;
                    if(condensedOlis.containsKey(prodId)){
                        condensedOlis.get(prodId).lineItems.add(oli);
                        condensedOlis.get(prodId).totalOliHours += oli.quantity;
                        condensedOlis.get(prodId).totalOliPrice += oli.totalprice;
                    } else {
                        condensedOli coli = new condensedOli();
                        coli.lineItems = new list<OpportunityLineItem>();
                        coli.lineItems.add(oli);
                        coli.totalOliHours = oli.quantity;
                        coli.productName = oli.PriceBookEntry.name;
                        coli.totalOliPrice = oli.totalprice;
                        coli.productid = oli.PriceBookEntry.product2id;
                        coli.description = oli.description;
                        condensedOlis.put(prodid, coli);

                        //HACKY GARBAGE TO SAVE A QUERY
                        opptyStageName = oli.Opportunity.StageName;
                        opptyName = oli.Opportunity.name;
                    }
                    } else {
                        discountItem = oli;
                    }
            }

            feeViewItems = condensedOlis.values();

    		List<AggregateResult> totalHoursResult = [Select sum(quantity) hrs from OpportunityLineItem where OpportunityId = :opptyId];
    		opptyTotalHours = integer.valueOf(totalHoursResult[0].get('hrs'));
    		Opportunity oppty = [Select id, amount from Opportunity where id = :opptyId];
    		opptyTotalValue = oppty.amount;
    	}
    }

    public void init () {
         if(discountItem == null){

                List<PricebookEntry> aPricebookEntries = new List< PricebookEntry>();
                aPricebookEntries = [
                            SELECT Id, Product2.id
                            FROM PricebookEntry 
                            WHERE Pricebook2Id = :[ SELECT Id FROM Pricebook2 WHERE Name = 'Standard Price Book' LIMIT 1 ].Id AND 
                                Product2.name = 'Discount'  LIMIT 1];
                System.debug('pricebbok entires' + aPricebookEntries);
                if(aPricebookEntries.size() > 0){

                    discountItem = new OpportunityLineItem();
                    discountItem.pricebookentryid = aPricebookEntries[0].id;
                    discountItem.isDiscount__c = true;
                    discountItem.quantity = 1;
                    discountItem.unitprice = 0;
                    discountItem.OpportunityId = opptyId;

                    insert discountItem;
                }
            }
    }

    @remoteAction
    public static void updateDiscountAmnt(String oliID, string oppty, decimal discountAmt){
        List<OpportunityLineItem> olis = new List<OpportunityLineItem>();
        olis = [select unitprice, id from OpportunityLineItem where id = :oliId];
        if(olis.size() > 0) {
            olis[0].unitprice = discountAmt;
            update olis;
        }
    }

    @remoteAction
    public static void updateOliDesc(String prodId, String newValue, String oppty) {
    	List<OpportunityLineItem> olis = new list<OpportunityLineItem>();
        olis =  [select id, description from OpportunityLineItem o where o.PriceBookEntry.product2id= :prodId AND o.OpportunityId = :oppty];

    	if(olis.size() > 0) {
            for(OpportunityLineItem oli : olis) {
                oli.description = newValue;
            }
    		update olis;
    	}
    }

}