public class SL_sync_OppLineItemToCOLineItem {

	public static Boolean isSynced = false;

    private static Boolean getSynced() {
        if ( !isSynced ) {
            SL_sync_COLineItemToOppLineItem.isSynced = true;
        }
        return isSynced;
    }

	//**************************//
    //*      INSERT LOGIC      *//
    //**************************//
    public static void insertChangeOrderLineItems( List<OpportunityLineItem> aRecords ) {
        List<OpportunityLineItem> aNeededRecords = getChangeOrderOpportunityLineItems( aRecords );
        if ( aNeededRecords.isEmpty() ) {
            return;
        }

        if ( getSynced() ) {
            return;
        }
        
        List<CO_Line_Item__c> aChangeOrderLineItems = createChangeOrderLineItems( aNeededRecords );
        insert aChangeOrderLineItems;

        relate( aNeededRecords, aChangeOrderLineItems );
    }

    private static List<CO_Line_Item__c> createChangeOrderLineItems( List<OpportunityLineItem> aRecords ) {
        List<CO_Line_Item__c> aResult = new List<CO_Line_Item__c>();

        Map<ID, ID> aPricebookEntryId_ProductId = getProductIdByPricebookEntryId( aRecords );
        Map<ID, ID> aOppId_ChangeOrderId = getChangeOrderIdByOpportunityId( aRecords );

        for ( OpportunityLineItem oItem : aRecords ) {
            aResult.add(
                new CO_Line_Item__c(
                    Change_Order__c = aOppId_ChangeOrderId.get( oItem.OpportunityId ),
                    CurrencyIsoCode = oItem.CurrencyIsoCode,
                    Description__c = oItem.Description,
                    Discount__c = oItem.Discount,
                    Qty__c = oItem.Quantity,
                    Sales_Price__c = oItem.UnitPrice,
                    Role__c = oItem.Role__c,
                    Product__c = aPricebookEntryId_ProductId.get( oItem.PricebookEntryId )
                )
            );
        }

        return aResult;
    }

    // Relates inserted ChangeOrderLineItems with OpportunityLineItems
    private static void relate( List<OpportunityLineItem> aRecords, List<CO_Line_Item__c> aChangeOrderLineItems ) {
        for ( Integer nI = 0; nI < aRecords.size(); nI++ ) {
            aRecords.get( nI ).CO_Line_Item__c = aChangeOrderLineItems.get( nI ).Id;
        }
    }

    private static List<OpportunityLineItem> getChangeOrderOpportunityLineItems( List<OpportunityLineItem> aRecords ) {
        List<OpportunityLineItem> aResult = new List<OpportunityLineItem>();

        Set<ID> aChangeOrderOpportunityIds = new Map<ID, Opportunity>( [
            SELECT Id FROM Opportunity WHERE Id IN :getOpportunityIds( aRecords ) AND
                RecordTypeId = :psaUtils.idRTOpportunityChangeOrders
        ] ).keySet();

        for ( OpportunityLineItem oItem : aRecords ) {
            if ( aChangeOrderOpportunityIds.contains( oItem.OpportunityId ) ) {
                aResult.add( oItem );
            }
        }

        return aResult;
    }

    private static Set<ID> getPricebookEntryIds( List<OpportunityLineItem> aRecords ) {
        Set<ID> aResult = new Set<ID>();

        for ( OpportunityLineItem oItem : aRecords ) {
            aResult.add( oItem.PricebookEntryId );
        }

        return aResult;
    }

    private static Set<ID> getOpportunityIds( List<OpportunityLineItem> aRecords ) {
        Set<ID> aResult = new Set<ID>();

        for ( OpportunityLineItem oItem : aRecords ) {
            aResult.add( oItem.OpportunityId );
        }

        return aResult;
    }

    private static Map<ID, ID> getProductIdByPricebookEntryId( List<OpportunityLineItem> aRecords ) {
        Map<ID, ID> aResult = new Map<ID, ID>();

        Map<ID, ID> aPricebookEntryId_Product2Id = new Map<ID, ID>();
        for ( PricebookEntry oItem : [ SELECT Id, Product2Id FROM PricebookEntry WHERE Id IN :getPricebookEntryIds( aRecords ) ] ) {
            aPricebookEntryId_Product2Id.put( oItem.Id, oItem.Product2Id );
        }

        Map<ID, ID> aProduct2Id_ProductId = new Map<ID, ID>();
        for ( Product__c oItem : [ SELECT Id, Product__c FROM Product__c WHERE Product__c IN :aPricebookEntryId_Product2Id.values() ] ) {
            aProduct2Id_ProductId.put( oItem.Product__c, oItem.Id );
        }

        for ( ID idPricebookEntryId : aPricebookEntryId_Product2Id.keySet() ) {
            aResult.put( idPricebookEntryId, aProduct2Id_ProductId.get( aPricebookEntryId_Product2Id.get( idPricebookEntryId ) ) );
        }

        return aResult;
    }

    private static Map<ID, ID> getChangeOrderIdByOpportunityId( List<OpportunityLineItem> aRecords ) {
        Map<ID, ID> aResult = new Map<ID, ID>();

        for ( Opportunity oItem : [ SELECT Id, Project_Change_Order__c FROM Opportunity WHERE Id IN :getOpportunityIds( aRecords ) ] ) { 
            aResult.put( oItem.Id, oItem.Project_Change_Order__c );
        }

        return aResult;
    }


    //**************************//
    //*      UPDATE LOGIC      *//
    //**************************//
    public static void refreshLineItems( Map<ID, OpportunityLineItem> aRecords ) {
        List<CO_Line_Item__c> aLineItemsToUpdate = new List<CO_Line_Item__c>();
        Map<ID, OpportunityLineItem> aCOLineItemId_OppLineItems = getOppLineItemsByCOLineItemId( aRecords );

        if ( aCOLineItemId_OppLineItems.isEmpty() ) {
            return;
        }

        if ( getSynced() ) {
            return;
        }

        for ( CO_Line_Item__c oItem : [ SELECT Id, Name, CurrencyIsoCode, Description__c, Discount__c, Qty__c, Sales_Price__c, Role__c FROM CO_Line_Item__c WHERE Id IN :aCOLineItemId_OppLineItems.keySet() ] ) {
            if ( psaUtils.refreshRecord( oItem, generateFieldMapping( aCOLineItemId_OppLineItems.get( oItem.Id ) ) ) ) {
                aLineItemsToUpdate.add( oItem );
            }
        }

        if ( !aLineItemsToUpdate.isEmpty() ) {
            update aLineItemsToUpdate;
        }
    }

    private static Map<ID, OpportunityLineItem> getOppLineItemsByCOLineItemId( Map<ID, OpportunityLineItem> aRecords ) {
        Map<ID, OpportunityLineItem> aResult = new Map<ID, OpportunityLineItem>();

        for ( OpportunityLineItem oItem : aRecords.values() ) {
            aResult.put( oItem.CO_Line_Item__c, oItem );
        }

        return aResult;
    }

    private static Map<String, object> generateFieldMapping( OpportunityLineItem oRecord ) {
        return new Map<String, object>{
            'CurrencyIsoCode' => oRecord.CurrencyIsoCode,
            'Description__c' => oRecord.Description,
            'Discount__c' => oRecord.Discount,
            'Qty__c' => oRecord.Quantity,
            'Sales_Price__c' => oRecord.UnitPrice,
            'Role__c' => oRecord.Role__c
        };
    }


    //**************************//
    //*      DELETE LOGIC      *//
    //**************************//
    public static void deleteLineItems( Map<ID, OpportunityLineItem> aRecords ) {
        if ( getSynced() ) {
            return;
        }

        List<CO_Line_Item__c> aCOLineItems = [ SELECT Id FROM CO_Line_Item__c WHERE Id IN :getCOLineItemIds( aRecords.values() ) ];
        if ( !aCOLineItems.isEmpty() ) {
            delete aCOLineItems;
        }
    }

    private static Set<ID> getCOLineItemIds( List<OpportunityLineItem> aRecords ) {
        Set<ID> aResult = new Set<ID>();

        for ( OpportunityLineItem oItem : aRecords ) {
            aResult.add( oItem.CO_Line_Item__c );
        }

        return aResult;
    }
}