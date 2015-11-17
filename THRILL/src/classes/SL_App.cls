global class SL_App{
    public static Opportunity opp { get; set; }
    
    global class MediaPlan
    {
    	global String Name 							     {get; set;}
     	global Id oppId 								{get; set;}
     	global List<OpportunityLineItemWrapper> lstOLIW {get; set;}
     	
     	global MediaPlan(String oppName, Id oppId, List<OpportunityLineItemWrapper> lstOLIW)
     	{
            //this.lstOLIW = new List<OpportunityLineItemWrapper>();
     		this.Name = oppName;
     		this.oppId = oppId;
     		this.lstOLIW = lstOLIW;
     	}
    }
    
    global class OpportunityLineItemWrapper
    {
    	global String product	 								 {get;set;}
    	global String property  								 {get;set;}
    	global Decimal impressions								 {get;set;}
    	global Decimal cpm										 {get;set;}
    	global Boolean autoCalc									 {get;set;}
    	global String notes										 {get;set;}
        global String unitSize                                   {get;set;}
        global String medium                                     {get;set;}
        global Date firstPlacement                               {get;set;}
        global Date lastPlacement                                {get;set;}
    	global List<Inventory_Order_Line__c> inventoryOrderLines {get;set;}
    	
    	global OpportunityLineItemWrapper(String  product, 
                                          String  property, 
                                          Decimal impressions, 
                                          Decimal cpm, 
                                          Boolean autoCalc, 
                                          String  notes, 
                                          String  medium,
                                          Date firstPlacement,
                                          Date lastPlacement,
                                          List<Inventory_Order_Line__c> inventoryOrderLines)
    	{

    		this.product = product;
    		this.property = property;
    		this.impressions = impressions;
    		this.cpm = cpm;
    		this.autoCalc = autoCalc;
    		this.notes = notes;
    		this.inventoryOrderLines = inventoryOrderLines;
            this.medium = medium;
            this.firstPlacement = firstPlacement;
            this.lastPlacement = lastPlacement;
    	}
    }
    
    @RemoteAction
    global static MediaPlan getOpportunityData(String oppId)
    {
        List<OpportunityLineItemWrapper> lstOLIWrapper = new List<OpportunityLineItemWrapper>();
        
        opp = [SELECT 	Id, Name, (SELECT 	Id, 
        									Product2.Name, 
        									Property__c,
        									Impressions_Promised__c,
        									CPM__c, 
        									Notes__c,
                                            Medium__c,
                                            First_Placement__c,
                                            Last_Placement__c,
        									Autocalculate_CPM__c
        		 					FROM 	OpportunityLineItems) 
				FROM 	Opportunity 
				WHERE 	Id=:oppId 
				LIMIT 1];
				
		if(!opp.OpportunityLineItems.isEmpty())
		{
			Map<Id, List<Inventory_Order_Line__c>> mapOLIToInventoryOrderLine = new Map<Id, List<Inventory_Order_Line__c>>();
			Set<String> setOLIIds = new Set<String>();
			
			//Iterating over OLI keysets to hold both 15 digit and 18 digit ids in sets since we have to fetch the Inventory_Order_Line__c based on the oliId which is of text field type.
			for(Id oliId : (new Map<Id, OpportunityLineItem>(opp.OpportunityLineItems)).keyset())
			{
				setOLIIds.addAll(new List<String>{String.valueOf(oliId), String.valueOf(oliId).subString(0,15)});
			}
			
			for(Inventory_Order_Line__c objIOL : [SELECT OpportunityProduct_Id__c, Medium__c, Inventory_Item_Name__c FROM Inventory_Order_Line__c WHERE OpportunityProduct_Id__c IN : setOLIIds])
			{
				if(!mapOLIToInventoryOrderLine.containskey(objIOL.OpportunityProduct_Id__c))
					mapOLIToInventoryOrderLine.put(objIOL.OpportunityProduct_Id__c, new List<Inventory_Order_Line__c>{objIOL});
				else
					mapOLIToInventoryOrderLine.get(objIOL.OpportunityProduct_Id__c).add(objIOL);
			}
			
			for(OpportunityLineItem objOLI : opp.OpportunityLineItems)
			{
				lstOLIWrapper.add(new OpportunityLineItemWrapper(objOLI.Product2.Name, 
																 objOLI.Property__c,
																 objOLI.Impressions_Promised__c,
																 objOLI.CPM__c,
																 objOLI.Autocalculate_CPM__c,
																 objOLI.Notes__c,
                                                                 objOLI.Medium__c, 
                                                                 objOLI.First_Placement__c,
                                                                 objOLI.Last_Placement__c,
																 mapOLIToInventoryOrderLine.containskey(objOLI.Id) ? mapOLIToInventoryOrderLine.get(objOLI.Id) : new List<Inventory_Order_Line__c>()));
			}
		}
		
        return new MediaPlan(opp.Name, opp.Id, lstOLIWrapper);
    }
}