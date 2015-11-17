/****************************************************************************************
Name            : psaBillingAdjustmentController
Author          : CLD
Created Date    : July 2013
Description     : Billing Adjustment page will insert a new Misc Adjustment of type Billing Adjustment
                : then create a new Billing Event Item and link the Billing Event.  This page is invoked
                : from a custom button on the Billing Event sfdc page.
******************************************************************************************/
public class psaBillingAdjustmentController {
    
    String billingEventID {get; set;}
    Public pse__Billing_Event__c bEvent {get; set;}
    Public pse__Billing_Event_Item__c bEventItem {get; set;}
    Public pse__Miscellaneous_Adjustment__c ma {get; set;}

    public psaBillingAdjustmentController() {
        //Grab the billing event id from the URL 
        billingEventID = ApexPages.currentPage().getParameters().get('beID'); 
        
        //Query up relevant billing event information 
        bEvent = [SELECT name, 
                         id, 
                         pse__Project__r.pse__Project_Manager__r.Name, 
                         pse__Project__r.pse__Account__r.Name, 
                         pse__Date__c, 
                         pse__Billing_Event_Batch__c,
                         currencyIsoCode,
                         pse__Is_Released__c
                    FROM pse__Billing_Event__c 
                   WHERE ID = :billingEventID]; 
                                
        //Instantiate new billing event item 
        bEventItem = new pse__Billing_Event_Item__c(); 
        
        //Grab Billing Adjustment Record Type ID 
        RecordType billingAdjustmentRT = [SELECT name, id FROM RecordType WHERE Name = 'Billing Adjustment' LIMIT 1]; 
        System.Assert(billingAdjustmentRT<>null, 'Billing Adjustment Record Type missing on Miscellaneous Adjustment object.  Please contact Admin.');
        
        //Create new Miscellaneous Adjustment 
        ma = new pse__Miscellaneous_Adjustment__c(
            RecordTypeId = billingAdjustmentRT.Id, 
            Name = '[Billing Adjustment] ' + date.today(),
            pse__Status__c = 'Approved', 
            pse__Approved__c = true,
            pse__Include_In_Financials__c = true,
            pse__Project__c = bEvent.pse__Project__r.Id,
            currencyIsoCode = bEvent.currencyIsoCode
        );
    }

    public PageReference cancel() {
        PageReference pr = new PageReference('/' + bEvent.Id); 
        return pr;
    }


    public PageReference save() {
        
        //Insert Miscellaneous Adjustment
        Database.SaveResult saveResult = Database.insert(ma); 
        
        //Finish creating Billing Event Item and link Miscellaneous Adjustment to that item 
        bEventItem.pse__Object_Id__c = saveResult.getId(); 
        bEventItem.pse__Miscellaneous_Adjustment__c = saveResult.getId(); 
        bEventItem.pse__Billing_Event__c = bEvent.Id; 
        bEventItem.pse__Billing_Event_Batch__c = bEvent.pse__Billing_Event_Batch__c; 
        bEventItem.pse__Category__c = 'Miscellaneous Adjustment'; 
        bEventItem.pse__Description__c = ma.pse__Description__c; 
        bEventItem.pse__Amount__c = ma.pse__Amount__c; 
        bEventItem.pse__Unit_Price__c = ma.pse__Amount__c; 
        bEventItem.pse__Quantity__c = 1; 
        bEventItem.pse__Project__c = bEvent.pse__Project__c; 
        bEventItem.pse__Date__c = ma.pse__Effective_Date__c; 
        bEventItem.currencyIsoCode = bEvent.currencyIsoCode; 
        
        //Insert new Billing Event Item
        insert bEventItem; 
        
        // Update the new Misc Adjustment to link the BEI to the Misc Adjustment
        ma.pse__Billing_Event_Item__c = bEventItem.id;
        ma.name = ma.name + '-' + ma.pse__Effective_Date__c.month() + '-'+ ma.pse__Effective_Date__c.year();
        
        // Set the Misc Adjust 'Billed' if the BE has already been released
        if(bEvent.pse__Is_Released__c == TRUE) ma.pse__Billed__c = TRUE;
        
        update ma;
        
        // Call method that will refresh the BE's Summary Amount value
        recalcBillingEventSummaryAmount(bEvent.Id);
        
        //Return user to the Billing Event Detail page from whence they came 
        PageReference pr = new PageReference('/' + bEvent.Id); 
        return pr; 
    }

public static void recalcBillingEventSummaryAmount(id beId)
{
    
    // Re-calculate the Summary Amount on a Billing Event from it's BE Items
    decimal summaryAmount = 0.0;
    
    for(pse__Billing_Event_Item__c bei : [SELECT id, pse__Amount__c FROM pse__Billing_Event_Item__c WHERE pse__Billing_Event__c = :beId])
    {
        summaryAmount += bei.pse__Amount__c.setScale(2);  
    }
    
    if(summaryAmount <> 0)
    {
        pse__Billing_Event__c beUpdate = [SELECT id, pse__Summary_Amount__c FROM pse__Billing_Event__c WHERE id = :beId];
        beUpdate.pse__Summary_Amount__c = summaryAmount;
        
        update beUpdate;
    }
}

}