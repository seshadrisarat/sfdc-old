/**
* \arg ClassName  : SL_LotEntryHandler
* \arg JIRATicket : FAEF -39
* \arg CreatedOn  : 10/09/2014
* \arg CreatedBy  : Dhanlakshmi
* \arg ModifiedBy : Dhanlakshmi
* \arg Description: This is controller for SL_LotEntry page.
*/

public with sharing class SL_LotEntryHandler 
{
    /* Start - Variables */
    public Lot__c objLot                                {   get;set;    }
    public String strAuctionName                        {   get;set;    }
    public String equipmentRecordId                     {   get;set;    }
    public String selectedRecordIds                     {   get;set;    }
    public String unselectedRecordIds                   {   get;set;    }
    public String quantities                            {   get;set;    }
    public List<SelectOption> statusOptions             {   get;set;    }
    public Boolean isEditable                           {   get;set;    }
    public String strBidsJSON                           {   get;set;    }
    public List<Bid__c> lst_Bids                        {   get;set;    } 
    /* End - Variables */
    
    /* Start-Constructor */
    public SL_LotEntryHandler(ApexPages.StandardController std)
    {
        intilization();
        List<Lot__c> lstLot = [Select Won_Bid_Total__c, Status__c, Name, Lot_Description__c, Id, Auction__c, Auction__r.Name ,Auction__r.Status__c From Lot__c  where Id =:std.getId()];
        String strAuctionId = Apexpages.currentPage().getParameters().get('retURL');
        String strLotId = Apexpages.currentPage().getParameters().get('id');
        String str_JSON ='[';

        strBidsJSON = '{}';

        if(strLotId!= NULL)
        {
           lst_Bids = [Select Name,Bidder_Account__c,Status__c,Submitted_Date__c , Total_Bid_Amount__c from Bid__c where Lot__c =:strLotId ];        
           system.debug('=====lst_Bids===='+lst_Bids);
           strBidsJSON = JSON.serializePretty(lst_Bids);
           /*
           for(Bid__c obj_Bid : lst_Bids)
           {
             str_JSON +='{'+'"BidName"' + ':' + '"' + obj_Bid.Name + '"' + ',' + '"BidderAccount"' + ':' + '"' + obj_Bid.Bidder_Account__c + '"' +','
                        +'"Status"' + ':' + '"' + obj_Bid.Status__c  + '"' + ',' + '"Submitted Date/Time"' + ':' +string.valueof(obj_Bid.Submitted_Date__c) +','
                        +'"Total Bid Amount"' + ':' + string.valueof(obj_Bid.Total_Bid_Amount__c) +'}';
           }
            str_JSON += ']';
            strBidsJSON = str_JSON;*/
            system.debug('=====>' + strBidsJSON);

            /*delete strBidsJSON.attributes;
            system.debug('=====----->' + strBidsJSON);*/
        }

        Schema.DescribeSObjectResult r = Auction__c.sObjectType.getDescribe();
        String keyPrefix = r.getKeyPrefix();
        if(!lstLot.isEmpty())
        {
            objLot = lstLot[0];
            strAuctionName = lstLot[0].Auction__r.Name; 
            isEditable = (lstLot[0].Auction__r.Status__c == 'Closed') ? false : true;
        }
        else if(strAuctionId != null && strAuctionId.contains(keyPrefix))
        {
            strAuctionId = strAuctionId.subString(strAuctionId.indexOf(keyPrefix), strAuctionId.length());//
            List<Auction__c> lstAuction = [SELECT Id, Name, Status__c FROM Auction__c WHERE Id =: strAuctionId];
            if(!lstAuction.isEmpty())
            {
                objLot.Auction__c = lstAuction[0].Id;
                strAuctionName = lstAuction[0].Name;
                isEditable = (lstAuction[0].Status__c == 'Closed') ? false : true;
            }
            else
            {
                isEditable = false;
            }
        }  
        
    }
    /* Start-Constructor */
    
    /* 
        @MethodName : intilization.
        @param      : NA.
        @Description: intilize all global variables of the class.
    */
    private void intilization()
    {
        objLot = new Lot__c();
        statusOptions = new List<SelectOption>();
        getPicklistValue();  
    }
    /* End */
    
    
    /* 
        @MethodName : createLotAndLotItemRecords.
        @param      : NA.
        @Description: create, delete and update Lot Item with Lot.
    */
    public Pagereference createLotAndLotItemRecords()
    {
        Map<String, Integer> mapQuantities = new Map<String, Integer>();
        List<Lot_Item__c> lstLotItemToDelete = new List<Lot_Item__c>();
        List<Lot_Item__c> lstLotItemToUpsert = new List<Lot_Item__c>();
        /*if(objLot.Id==null)
        {
            objLot.Status__c='Pending';
        }*/
       
        upsert objLot;
        
        for(String strQuantity : quantities.split(','))
        {
            System.debug('================strQuantity=========='+strQuantity);
            if(strQuantity.split('____').size() > 1 && Integer.valueOf(strQuantity.split('____')[1]) > 0)
            {
                System.debug('================strQuantity.split.size()=========='+strQuantity.split('____').size());
                System.debug('================Integer.valueOf(strQuantity.split[1])=========='+Integer.valueOf(strQuantity.split('____')[1]));
                mapQuantities.put(strQuantity.split('____')[0], Integer.valueOf(strQuantity.split('____')[1]));
                System.debug('================mapQuantities=========='+mapQuantities);
            }
                
            else if(strQuantity.split('~').size() > 1 && strQuantity.split('~')[1].contains('=>') && strQuantity.split('~')[1].split('=>').size() > 0)
                lstLotItemToDelete.add(new Lot_Item__c( Id=strQuantity.split('~')[1].split('=>')[0]));
        }
        
        for(String strEquipment_LotItemId : unselectedRecordIds.split(','))
        {
            if(strEquipment_LotItemId.split('~').size() > 1 && strEquipment_LotItemId.split('~')[1].contains('=>') && strEquipment_LotItemId.split('~')[1].split('=>').size() > 0)
                lstLotItemToDelete.add(new Lot_Item__c(Id=strEquipment_LotItemId.split('~')[1].split('=>')[0]));
        }
        
        if(!String.isBlank(selectedRecordIds))
        {
            for(String strEquipment_LotItemId : selectedRecordIds.split(','))
            {
                if(mapQuantities.containsKey(strEquipment_LotItemId))
                {
                    if(strEquipment_LotItemId.split('~').size() > 1 && strEquipment_LotItemId.split('~')[1].contains('=>'))
                        lstLotItemToUpsert.add(new Lot_Item__c(Id = strEquipment_LotItemId.split('~')[1].split('=>')[0], 
                                                               Lot__c = objLot.Id, 
                                                               Status__c = 'Pending in Lot',
                                                               Quantity__c = mapQuantities.get(strEquipment_LotItemId),
                                                               Equipment__c = strEquipment_LotItemId.split('~')[0]));
                    else
                        lstLotItemToUpsert.add(new Lot_Item__c(Lot__c = objLot.Id, 
                                                               Status__c = 'Pending in Lot',
                                                               Quantity__c = mapQuantities.get(strEquipment_LotItemId),
                                                               Equipment__c = strEquipment_LotItemId.split('~')[0]));
                }
            }
        }
        
        if(!lstLotItemToDelete.isEmpty())
            delete lstLotItemToDelete;
        if(!lstLotItemToUpsert.isEmpty())
            upsert lstLotItemToUpsert;
        
        if(objLot.Id != null)
            return new Pagereference('/' + objLot.Id);
        else
            return new Pagereference('/' + objLot.Auction__c);  
    }
    /* End */
    /* 
        @MethodName : cancel.
        @param      : NA.
        @Description: redirect the page to Auction detail page.
    */
    public Pagereference cancel()
    {
        if(objLot.Id != null)
            return new Pagereference('/' + objLot.Id);
        else
            return new Pagereference('/' + objLot.Auction__c);
    } 
    /* End */
    
     /* 
        @MethodName : getPicklistValue.
        @param      : NA.
        @Description: 
    */
    public void getPicklistValue()
    {
        Schema.DescribeFieldResult fieldResult = Lot__c.Status__c.getDescribe();
        List<Schema.PicklistEntry> lstPicklist = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : lstPicklist)
        {
            statusOptions.add(new SelectOption(f.getLabel(), f.getValue()));
        }
    }
    /* End */
}