/**  
* \arg ClassName        : SL_Product2TriggerHandler
* \arg JIRATicket       : NPD-220
* \arg CreatedOn        : 13/OCT/2015
* \arg LastModifiedOn   : 
* \arg CreatededBy      : Sandeep
* \arg ModifiedBy       : 
* \arg Description      : Handler class for Product2 object.
*/
global class SL_Product2TriggerHandler extends SL_TriggerHandlerBase {

    @TestVisible private static Boolean isRecursive  = false; //Using this boolean for handle recursive call
	public override void beforeInsert(List<SObject> newListGeneric){
		List<Product2> newList = (List<Product2>) newListGeneric;
		/*BEFORE INSERT METHODS START*/
		
		/*BEFORE INSERT METHODS END*/
	}
	
	public override void beforeUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric){
		Map<Id, Product2> oldMap = (Map<Id, Product2>) oldMapGeneric;
		Map<Id, Product2> newMap = (Map<Id, Product2>) newMapGeneric;
		/*BEFORE UPDATE METHODS START*/
		
		/*BEFORE UPDATE METHODS END*/
	}
	
	public override void beforeDelete(Map<Id, SObject> oldMapGeneric){
		Map<Id, Product2> oldMap = (Map<Id, Product2>) oldMapGeneric;
		/*BEFORE DELETE METHODS START*/
		
		/*BEFORE DELETE METHODS END*/
	}
	
	public override void afterInsert(Map<Id, SObject> newMapGeneric){
		Map<Id, Product2> newMap = (Map<Id, Product2>) newMapGeneric;
		/*AFTER INSERT METHODS START*/
		if(!isRecursive)
		{
		    isRecursive = true;
		    manageProductBundle(newMap, new Map<Id, Product2>());
		}
		/*AFTER INSERT METHODS END*/
	}
	
	public override void afterUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric){
		Map<Id, Product2> oldMap = (Map<Id, Product2>) oldMapGeneric;
		Map<Id, Product2> newMap = (Map<Id, Product2>) newMapGeneric;
		/*AFTER UPDATE METHODS START*/
		if(!isRecursive)
		{
    		isRecursive = true;
    		manageProductBundle(newMap, oldMap); 
		}
		/*AFTER UPDATE METHODS END*/
	}
	
	public override void afterDelete(Map<Id, SObject> oldMapGeneric){
		Map<Id, Product2> oldMap = (Map<Id, Product2>) oldMapGeneric;
		/*AFTER DELETE METHODS START*/
		if(!isRecursive)
		{
    		isRecursive = true;
		    manageProductBundle(oldMap, new Map<Id, Product2>()); 
		}
		/*AFTER DELETE METHODS END*/
	}
	
	public override void afterUndelete(Map<Id, SObject> newMapGeneric){
		Map<Id, Product2> newMap = (Map<Id, Product2>) newMapGeneric;
		/*AFTER UNDELETE METHODS START*/
		
		/*AFTER UNDELETE METHODS END*/
	}
	
	
	private void manageProductBundle(Map<Id, Product2> newMap, Map<Id, Product2> oldMap)
	{
		map<String, List<Product2>> mapProductIdentifier = new map<String, List<Product2>>(); //map to hold the productIdentifier to list of product2
		List<Product2> lstProduct2ToUpdate = new List<Product2>(); //list of product to update
		List<Product_Bundle__c> lstProductBundleToInsert = new List<Product_Bundle__c>(); //list of product bundle to insert
		List<Product_Bundle__c> lstProductBundleToUpdate = new List<Product_Bundle__c>(); // list of product bundle to update
		List<Product_Bundle__c> lstProductBundleToDelete = new List<Product_Bundle__c>(); // list of product bundle to delete
		set<String> setUniqueIdentifier = new set<String>(); // set of unique identifier
		
		/*
		    Iterate over new map and store into the map with uniqu identifier to list of products 
		    In delete case new map is old map (check after delete method). Stored all the unique Identifier in set 
		*/
		for(Product2 objProduct2: newMap.values())
		{
			Product2 objOldProduct2 = new Product2();
			if(Trigger.isUpdate)
				objOldProduct2 = oldMap.get(objProduct2.Id);
			if(objProduct2.Product_Identifier__c != null && ((Trigger.isUpdate || objProduct2.isActive) ||
				(Trigger.IsUpdate && (objProduct2.Family != objOldProduct2.Family || 
				objProduct2.Product_Group__c != objOldProduct2.Product_Group__c  || 
				objProduct2.Product_Offering__c != objOldProduct2.Product_Offering__c ||
				objProduct2.Product_Identifier__c != objOldProduct2.Product_Identifier__c || 
				objProduct2.ALR_Retailer__c != objOldProduct2.ALR_Retailer__c ||
				objProduct2.Product_LOB__c != objOldProduct2.Product_LOB__c ||
				objProduct2.isActive != objOldProduct2.isActive))))
			{
				setUniqueIdentifier.add(objProduct2.Product_Identifier__c);
				if(Trigger.isUpdate)
					setUniqueIdentifier.add(objOldProduct2.Product_Identifier__c);
				if(!Trigger.isDelete)
				{
    				if(mapProductIdentifier.containsKey(objProduct2.Product_Identifier__c))
    					mapProductIdentifier.get(objProduct2.Product_Identifier__c).add(objProduct2);
    				else
    					mapProductIdentifier.put(objProduct2.Product_Identifier__c , new List<Product2>{objProduct2});
				}
			}
		}
		//query on product bundle and update the all the product Product_Bundle__c llokup with Product_Bundle__c id
		for(Product_Bundle__c objProductBundle: [SELECT Id,
														Product_Identifier__c
												   FROM Product_Bundle__c WHERE Product_Identifier__c IN: mapProductIdentifier.keySet()])
		{
			for(Product2 objProduct2 :mapProductIdentifier.get(objProductBundle.Product_Identifier__c))
				lstProduct2ToUpdate.add(new Product2(Id = objProduct2.Id, Product_Bundle__c = objProductBundle.Id));
		}
		update lstProduct2ToUpdate;
		/*
		    fetch all the Product_Bundle__c using unique identifier and their childs . If there is no product childs then add into a list for deleting
		    Or if exist then get all the childs and perform field mapping and update the Product bundle
		*/
		for(Product_Bundle__c objProductBundle :[SELECT Id, Product_Family__c, Product_Group__c, Product_Offering__c,
														Product_Identifier__c, Accounting_Units__c, Retailers__c,
														(SELECT Id, Family, Product_Group__c, Product_Identifier__c,
																Product_Offering__c, ALR_Retailer__c, Product_LOB__c
														   FROM Products__r WHERE isActive = true)
												   FROM Product_Bundle__c WHERE Product_Identifier__c IN: setUniqueIdentifier])
		{
			setUniqueIdentifier.remove(objProductBundle.Product_Identifier__c);
			String strAccountingUnits = '';
			String strRetailers = '';
			Integer intlstCounter = 0;
				
			for(Product2 objProduct2 : objProductBundle.Products__r)
			{
			    intlstCounter ++;
				objProductBundle.Product_Family__c = objProduct2.Family;
				objProductBundle.Product_Group__c = objProduct2.Product_Group__c;
				objProductBundle.Product_Offering__c = objProduct2.Product_Offering__c;
				objProductBundle.Product_Identifier__c = objProduct2.Product_Identifier__c;
				if(objProduct2.Product_LOB__c != null && !strAccountingUnits.contains(objProduct2.Product_LOB__c))
				    strAccountingUnits += ';' + objProduct2.Product_LOB__c;
				if(objProduct2.ALR_Retailer__c != null && !strRetailers.contains(objProduct2.ALR_Retailer__c))
				    strRetailers += ';' + objProduct2.ALR_Retailer__c;
			}
			 objProductBundle.Accounting_Units__c = strAccountingUnits.removeStart(';');
			 objProductBundle.Retailers__c = strRetailers.removeStart(';');
			 lstProductBundleToUpdate.add(objProductBundle);
			 
			 if(intlstCounter == 0)
			    lstProductBundleToDelete.add(objProductBundle);
		}
		update lstProductBundleToUpdate;
		delete lstProductBundleToDelete;
		/*
		    If product bundle is not exist with unique identifier then Iterate over setUniqueIdentifier and get all the related products  
		    create product bundle based on field mapping
		*/
		for(String strUniqueIdentifier : setUniqueIdentifier)
		{
			Product_Bundle__c objProductBundle = new Product_Bundle__c();
			objProductBundle.Accounting_Units__c = objProductBundle.Retailers__c = '';
			if(mapProductIdentifier.containsKey(strUniqueIdentifier))
			{
				for(Product2 objProduct2 :mapProductIdentifier.get(strUniqueIdentifier))
				{
					objProductBundle.Product_Family__c = objProduct2.Family;
					objProductBundle.Product_Group__c = objProduct2.Product_Group__c;
					objProductBundle.Product_Identifier__c = objProduct2.Product_Identifier__c;
					objProductBundle.Product_Offering__c = objProduct2.Product_Offering__c;
					objProductBundle.Name = objProduct2.Product_Identifier__c.length() > 80 ? 
											objProduct2.Product_Identifier__c.substring(0,80) : objProduct2.Product_Identifier__c;
					
					objProductBundle.Accounting_Units__c += String.isEmpty(objProduct2.Product_LOB__c) ? '': ';'+ objProduct2.Product_LOB__c;
					objProductBundle.Retailers__c += String.isEmpty(objProduct2.ALR_Retailer__c) ? '': ';'+ objProduct2.ALR_Retailer__c;
				}
				objProductBundle.Accounting_Units__c = objProductBundle.Accounting_Units__c.removeStart(';');
				objProductBundle.Retailers__c = objProductBundle.Retailers__c.removeStart(';');
				lstProductBundleToInsert.add(objProductBundle);
			}
		}
		insert lstProductBundleToInsert;
		lstProduct2ToUpdate = new List<Product2>();
		// Once Product bundle is created now update the all product's Product_Bundle__c with related product bundle id.
		for(Product_Bundle__c objProductBundle: lstProductBundleToInsert)
		{
			for(Product2 objProduct2 :mapProductIdentifier.get(objProductBundle.Product_Identifier__c))
				lstProduct2ToUpdate.add(new Product2(Id = objProduct2.Id, Product_Bundle__c = objProductBundle.Id));
		}
		update lstProduct2ToUpdate;
	}
}