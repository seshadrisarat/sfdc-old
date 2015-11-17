public class SL_sync_COLineItemToOppLineItem {
	
	public static Boolean isSynced = false;
	
    private static Boolean getSynced() {
        if ( !isSynced ) {
            SL_sync_OppLineItemToCOLineItem.isSynced = true;
        }
        return isSynced;
    }
    
	//**************************//
    //*      INSERT LOGIC      *//
    //**************************//
    public static void insertOpportunityLineItems( Map<ID, CO_Line_Item__c> aRecords ) {
        if ( getSynced() ) {
            return;
        }
        
        insert createOpportunityLineItems( aRecords.values() );
    }

    private static List<OpportunityLineItem> createOpportunityLineItems( List<CO_Line_Item__c> aRecords ) {
        List<OpportunityLineItem> aResult = new List<OpportunityLineItem>();

        Map<ID, ID> aProductId_PricebookEntryId = getPricebookEntryIdByProductId( aRecords );
        Map<ID, ID> aChangeOrderId_OppId = getOpportunityIdByChangeOrderId( aRecords );

        for ( CO_Line_Item__c oItem : aRecords ) {
            aResult.add(
                new OpportunityLineItem(
                	OpportunityId = aChangeOrderId_OppId.get( oItem.Change_Order__c ),
                    Description = oItem.Description__c,
                    Discount = oItem.Discount__c,
                    Quantity = oItem.Qty__c,
                    UnitPrice = oItem.Sales_Price__c,
                    Role__c = oItem.Role__c,
                    PricebookEntryId = aProductId_PricebookEntryId.get( oItem.Product__c ),
                    CO_Line_Item__c = oItem.Id
                )
            );
        }

        return aResult;
    }

    private static Set<ID> getProductIds( List<CO_Line_Item__c> aRecords ) {
        Set<ID> aResult = new Set<ID>();

        for ( CO_Line_Item__c oItem : aRecords ) {
            aResult.add( oItem.Product__c );
        }

        return aResult;
    }

    private static Set<ID> getChangeOrderIds( List<CO_Line_Item__c> aRecords ) {
        Set<ID> aResult = new Set<ID>();

        for ( CO_Line_Item__c oItem : aRecords ) {
            aResult.add( oItem.Change_Order__c );
        }

        return aResult;
    }

    private static Map<ID, ID> getPricebookEntryIdByProductId( List<CO_Line_Item__c> aRecords ) {
        Map<ID, ID> aResult = new Map<ID, ID>();


        Map<ID, ID> aProductId_Product2Id = new Map<ID, ID>();
        for ( Product__c oItem : [ SELECT Id, Product__c FROM Product__c WHERE Id IN :getProductIds( aRecords ) ] ) {
            aProductId_Product2Id.put( oItem.Id, oItem.Product__c );
        }

        Map<ID, ID> aProduct2Id_PricebookEntryId = new Map<ID, ID>();
        for ( PricebookEntry oItem : [ SELECT Id, Product2Id FROM PricebookEntry WHERE Product2Id IN :aProductId_Product2Id.values() ] ) {
            aProduct2Id_PricebookEntryId.put( oItem.Product2Id, oItem.Id );
        }

        for ( CO_Line_Item__c oItem : aRecords ) {
        	aResult.put( oItem.Product__c, aProduct2Id_PricebookEntryId.get( aProductId_Product2Id.get( oItem.Product__c ) ) );
        }

        return aResult;
    }

    private static Map<ID, ID> getOpportunityIdByChangeOrderId( List<CO_Line_Item__c> aRecords ) {
        Map<ID, ID> aResult = new Map<ID, ID>();

        for ( Change_Order__c oItem : [ SELECT Id, Change_Order_Opportunity__c FROM Change_Order__c WHERE Id IN :getChangeOrderIds( aRecords ) ] ) { 
            aResult.put( oItem.Id, oItem.Change_Order_Opportunity__c );
        }

        return aResult;
    }


    //**************************//
    //*      UPDATE LOGIC      *//
    //**************************//
    public static void refreshLineItems( Map<ID, CO_Line_Item__c> aRecords ) {
        if ( getSynced() ) {
            return;
        }

        List<OpportunityLineItem> aLineItemsToUpdate = new List<OpportunityLineItem>();

        for ( OpportunityLineItem oItem : [ SELECT Id, CO_Line_Item__c, CurrencyIsoCode, Description, Discount, Quantity, UnitPrice, Role__c FROM OpportunityLineItem WHERE CO_Line_Item__c IN :aRecords.keySet() ] ) {
            if ( psaUtils.refreshRecord( oItem, generateFieldMapping( aRecords.get( oItem.CO_Line_Item__c ) ) ) ) {
                aLineItemsToUpdate.add( oItem );
            }
        }

        if ( !aLineItemsToUpdate.isEmpty() ) {
            update aLineItemsToUpdate;
        }
    }

    private static Map<String, object> generateFieldMapping( CO_Line_Item__c oRecord ) {
        return new Map<String, object>{
            'CurrencyIsoCode' => oRecord.CurrencyIsoCode,
            'Description' => oRecord.Description__c,
            'Discount' => oRecord.Discount__c,
            'Quantity' => oRecord.Qty__c,
            'UnitPrice' => oRecord.Sales_Price__c,
            'Role__c' => oRecord.Role__c
        };
    }


    //**************************//
    //*      DELETE LOGIC      *//
    //**************************//
    public static void deleteLineItems( Set<ID> aRecordIds ) {
        if ( getSynced() ) {
            return;
        }

        List<OpportunityLineItem> aOppLineItems = [ SELECT Id FROM OpportunityLineItem WHERE CO_Line_Item__c IN :aRecordIds ];
        if ( !aOppLineItems.isEmpty() ) {
            delete aOppLineItems;
        }
    }
}