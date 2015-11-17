/**
    * \arg ClassName      : SL_ProductManagementToolCtrl
    * \arg JIRATicket     : NPD-87
    * \arg CreatedOn      : 08/Sep/2015
    * \arg LastModifiedOn : 
    * \arg CreatededBy    : Sandeep
    * \arg ModifiedBy     : 
    * \arg Description    : This class for the SL_ProductManagementTool page.
*/
global with sharing class SL_ProductManagementToolCtrl
{
    /* Start- variables */
    public Opportunity objOpp                                                           {get;set;}
    public String strSelectedProductIdentifier                                          {get;set;}
    public List<product2Wrapper> lstProduct2Wrapper                                     {get;set;}
    public Integer intSelectedProductTableRowNo                                         {get;set;}
    public set<String> setProductFamily                                                 {get;set;}
    public set<String> setProductGroup                                                  {get;set;}
    public set<String> setProductOffering                                               {get;set;}
    Transient public map<String, Product_Bundle__c> mapProductIdentifierToProduct2      {get;set;}
    public map<String, set<String>> mapProductFamilyToSetProductGroup                   {get;set;}
    public String strProductFamilySelected                                              {get;set;}
    public String strProductGroupSelected                                               {get;set;} 
    private map<String, set<String>> mapProductGroupToSetProductOffering ;
    /* End- Variables*/
    
    /* Start - Constructor */
    public SL_ProductManagementToolCtrl(ApexPages.StandardController stdController)
    {
        strProductFamilySelected = '';
        strProductGroupSelected = '';
        setProductFamily = new set<String>{'--None--'};
        setProductGroup = new set<String>{'--None--'};
        setProductOffering = new set<String>{'--None--'};
        lstProduct2Wrapper = new List<product2Wrapper>();
        mapProductIdentifierToProduct2 = new map<String, Product_Bundle__c>();
        
        mapProductFamilyToSetProductGroup = new map<String, set<String>>();
        mapProductGroupToSetProductOffering = new map<String, set<String>>();
        mapProductFamilyToSetProductGroup.put('--None--', new set<String>());
        
        strSelectedProductIdentifier = '';
        
        if(!Test.isRunningTest())
            stdController.addFields(new List<String>{'Name','ContractTerm__c', 'PriceBook2Id'});
        objOpp = (Opportunity)stdController.getRecord();
       
        List<Product_Bundle__c> lstProduct_Bundle = [SELECT Id, Name, Product_Family__c, Product_Group__c, Product_Offering__c, Product_Identifier__c, Retailers__c, Accounting_Units__c  FROM Product_Bundle__c WHERE Product_Identifier__c  != null];
        Integer lstsize = lstProduct_Bundle.size();
        set<String> setProductIdentifier = new set<String>();
        
        for(Integer i = 0; i < lstsize ; i++)
        {       
            if(lstProduct_Bundle[i].Product_Family__c != null && lstProduct_Bundle[i].Product_Group__c != null && !mapProductFamilyToSetProductGroup.containsKey(lstProduct_Bundle[i].Product_Family__c) ) 
                mapProductFamilyToSetProductGroup.put(lstProduct_Bundle[i].Product_Family__c, new set<String>{lstProduct_Bundle[i].Product_Group__c});
            else if(lstProduct_Bundle[i].Product_Family__c != null && lstProduct_Bundle[i].Product_Group__c != null && mapProductFamilyToSetProductGroup.containsKey(lstProduct_Bundle[i].Product_Family__c))
                mapProductFamilyToSetProductGroup.get(lstProduct_Bundle[i].Product_Family__c).add(lstProduct_Bundle[i].Product_Group__c);
            
            if(lstProduct_Bundle[i].Product_Offering__c != null && lstProduct_Bundle[i].Product_Group__c != null && !mapProductGroupToSetProductOffering.containsKey(lstProduct_Bundle[i].Product_Group__c) ) 
                mapProductGroupToSetProductOffering.put(lstProduct_Bundle[i].Product_Group__c, new set<String>{lstProduct_Bundle[i].Product_Offering__c});
            else if(lstProduct_Bundle[i].Product_Offering__c != null && lstProduct_Bundle[i].Product_Group__c != null &&  mapProductGroupToSetProductOffering.containsKey(lstProduct_Bundle[i].Product_Group__c) )
                mapProductGroupToSetProductOffering.get(lstProduct_Bundle[i].Product_Group__c).add(lstProduct_Bundle[i].Product_Offering__c);
            
            //adding values into set for prepare filter picklist. 
        	if(!setProductIdentifier.contains(lstProduct_Bundle[i].Product_Identifier__c))
        	{    
            	mapProductIdentifierToProduct2.put(lstProduct_Bundle[i].Product_Identifier__c, lstProduct_Bundle[i]);
            	setProductIdentifier.add(lstProduct_Bundle[i].Product_Identifier__c);
        	}
        }
    }
    /* End - Constructor */
    
    //Wrapper class for product2
    public class product2Wrapper
    {
        public List<Product2> lstProduct2                       {get;set;} // List of product with same identifiers
        public OpportunityLineItem objOppLineItem               {get;set;} // newly OLI 
        public String strCurrentMonth                           {get;set;} //Current month
        public Integer intCurrentYear                           {get;set;} //Curret year
        public String strEndMonth                               {get;set;} // End month based on current month + opportuntiy ContractTerm__c
        public Integer intEndYear                               {get;set;} // End Year based on current date + opportuntiy ContractTerm__c
        public String strCombinationOfAllFields                 {get;set;} //This field contain all the values when  user change the values again and again 
        public String strFinalCombination                       {get;set;} //After changing the values again and agian. The final selected field and their combination will be stored in this string
        public map<String, set<String>> mapFieldToTheirOptions  {get;set;} //map will their field name and their all unique values
        public Id idProduct2Id                                  {get;set;} //This will contain the product id for OLI
        private Opportunity objOpportunity ;
        
        public product2Wrapper(List<Product2> lstProducts2, Opportunity objOpportunity)
        {
            lstProduct2 = new List<Product2>();
            this.lstProduct2 = lstProducts2;
            this.objOpportunity = objOpportunity;
            //set the default values of OLI
            objOppLineItem = new OpportunityLineItem(Quantity = 1, UnitPrice = 0, OpportunityId = objOpportunity.Id, Start_Date__c = Date.Today().toStartOfMonth(), End_Date__c = objOpportunity.ContractTerm__c == null ? null : Date.Today().toStartOfMonth().addMonths(Integer.valueOf(objOpportunity.ContractTerm__c)));
            mapFieldToTheirOptions = new map<String, set<String>>();
            strCombinationOfAllFields = '';
            strFinalCombination = '';
            
            //set the current month/year and end month/year
            strCurrentMonth = String.valueOf(Datetime.now().month());
            intCurrentYear = Datetime.now().year();
            if(objOpportunity.ContractTerm__c != null)
            {
                strEndMonth = String.valueOf(Datetime.now().addMonths(Integer.valueOf(objOpportunity.ContractTerm__c)).month());
                intEndYear = Datetime.now().addMonths(Integer.valueOf(objOpportunity.ContractTerm__c)).Year();
            }
            
            //iterate over fieldset and perape map for respective field and their values
            for(Schema.FieldSetMember f : SObjectType.Product2.FieldSets.SL_ProductMgtTool.getFields()) 
            {
                for(Product2 objProduct2: lstProducts2)
                {
                    if(!mapFieldToTheirOptions.containsKey(f.getFieldPath()))
                        mapFieldToTheirOptions.put(f.getFieldPath(), new set<String>{String.valueOf(objProduct2.get(f.getFieldPath()))});
                    else
                        mapFieldToTheirOptions.get(f.getFieldPath()).add(String.valueOf(objProduct2.get(f.getFieldPath())));
                }
            }
        }
    }
    /**
    @MethodName : addIntoSelectedProduct
    @Param      : 
    @Description: Add product2 in selected Product table
    **/
    public void addIntoSelectedProduct()
    {
        String query = 'SELECT ';
        set<String> setFields = new set<String>(); // set to check Product_Identifier__c field exist in fieldset or not
        for(Schema.FieldSetMember f : SObjectType.Product2.FieldSets.SL_ProductMgtTool.getFields()) {
            query += f.getFieldPath() + ', ';
            setFields.add(f.getFieldPath());
        }
        if(setFields.isEmpty())
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select a field in fieldset.'));
        else
        {    
            if(setFields.contains('Product_Identifier__c'))
                query += 'Id FROM Product2 WHERE isActive = true AND Product_Identifier__c =\''+strSelectedProductIdentifier+'\' ';
            else
                query += 'Id, Product_Identifier__c FROM Product2 WHERE isActive = true AND Product_Identifier__c =\''+strSelectedProductIdentifier+'\' ';
            
            //based on the select product, create a new wrapper
            lstProduct2Wrapper.add(new product2Wrapper(Database.Query(query), objOpp));
        }
    }
    /**
    @MethodName : removeProductFromSelectedProduct
    @Param      : 
    @Description: Remove product2 from selected Product table and add into search table
    **/
    public void removeProductFromSelectedProduct()
    {
        map<String, product2Wrapper> mapProductIdentifierWrapper = new map<String, product2Wrapper>();
        set<String> setProductIdentifier = new set<String>();
        //remove only one selected product from wrapper list
        lstProduct2Wrapper.remove(intSelectedProductTableRowNo-1);
    }
    /**
    @MethodName : createOppLineItems
    @Param      : 
    @Description: This method will create OLI based on selected product2
    **/
    public PageReference createOppLineItems()
    {
        set<Id> setProduct2Id = new set<Id>();
        set<String> setUniqueString = new set<String>();
        List<OpportunityLineItem> lstOpportunityLineItemsToInsert = new List<OpportunityLineItem>();
        map<Id, Id> mapProduct2IdToPricebookEntryId = new map<Id, Id>();
        map<string, set<string>> mapFieldNameToListOfValue = new map<string, set<string>>();
        
        //based on the prepare unique combination get all the fields name and their values into a map 
        for(product2Wrapper objWarpper: lstProduct2Wrapper)
        {
            //update the start date and end date based on user selection
            objWarpper.objOppLineItem.Start_Date__c = objWarpper.intCurrentYear == null || objWarpper.intCurrentYear == 0 ? null :
                                                      Date.newInstance(objWarpper.intCurrentYear, Integer.valueOf(objWarpper.strCurrentMonth), 1);
            objWarpper.objOppLineItem.End_Date__c = objWarpper.intEndYear == null || objWarpper.intEndYear == 0 ?  null :
                                                    Date.newInstance(objWarpper.intEndYear, Integer.valueOf(objWarpper.strEndMonth), 1);
            
            map<String, String> mapFieldNameToValue = new map<String, String>();
            //combination of field and their values from string. Split the string and adding into map for final values
            for(String str :objWarpper.strCombinationOfAllFields.split('~~~'))
            {
                if(str != '' && str.split('--->').size() == 2)
                {
                    mapFieldNameToValue.put(str.split('--->')[0], str.split('--->')[1]);
                }
            }
            objWarpper.strFinalCombination = '';
            //store into field and their all the values
            for(String strKey :mapFieldNameToValue.keySet())
            {
                objWarpper.strFinalCombination +=  strKey +'~~~'+ mapFieldNameToValue.get(strKey) +'--->'; // to store the final combination of field and their value
                if(!mapFieldNameToListOfValue.containsKey(strKey))
                    mapFieldNameToListOfValue.put(strKey, new set<String>{mapFieldNameToValue.get(strKey)});
                else
                    mapFieldNameToListOfValue.get(strKey).add(mapFieldNameToValue.get(strKey));
            }
        }
        //preparing dynamic query for product
        String strQuery = 'SELECT Id ';
        for(String strField : mapFieldNameToListOfValue.keySet()) 
        {
            strQuery += ','+strField ;
        }
        strQuery += ' FROM Product2 WHERE isActive = true AND ';
        Integer i = 1;
        for(String strField : mapFieldNameToListOfValue.keySet()) 
        {
            if(mapFieldNameToListOfValue.get(strField).size() == 1)
                strQuery += strField +'=' ;
            else
                strQuery += strField +' IN (' ;
            for(String strValues: mapFieldNameToListOfValue.get(strField))
            {
                strQuery += '\''+strValues+'\''+ +',';
            }
            strQuery = strQuery.removeEnd(',');
            if(mapFieldNameToListOfValue.get(strField).size() > 1)
                strQuery += ')';
            if(i != mapFieldNameToListOfValue.values().size())
                strQuery += ' AND ';
            i++;
        }
        try
        {
            List<Product2> lstProduct2 = Database.query(strQuery);
            
            //based on select values in dropdown of each field get the maching product id
            for(product2Wrapper objWarpper: lstProduct2Wrapper)
            {
                for(Product2 objProduct2 :lstProduct2)
                {
                    String strCombine = '';
                    for(String str:mapFieldNameToListOfValue.KeySet())
                    {
                        strCombine += str+'~~~'+ objProduct2.get(str) +'--->';
                    }
                    //checking for final combination equal with all product field values then select that productId for that Newly OLI
                    if(objWarpper.strFinalCombination == strCombine)
                    {
                        setProduct2Id.add(objProduct2.Id);
                        objWarpper.idProduct2Id = objProduct2.Id;
                    }
                }
            }
            // get the current PricebookId using query. Reason we are getting null value from standard controller
            Opportunity objOpportunity = [SELECT Id, PriceBook2Id FROM Opportunity WHERE Id =: objOpp.Id];
            
            // get the pricebok Entry Product2Id and add into the map.
            for(PricebookEntry objPricebookEntry: [SELECT Id, Product2Id FROM PricebookEntry WHERE Product2Id IN :setProduct2Id  AND PriceBook2Id =: objOpportunity.PriceBook2Id])
            {
                mapProduct2IdToPricebookEntryId.put(objPricebookEntry.Product2Id, objPricebookEntry.Id);
            }
            // based on the above map get the pricebookEntry id and add into OLI pricebook Entry id
            for(product2Wrapper objWarpper: lstProduct2Wrapper)
            {
                if(objWarpper.objOppLineItem.Start_Date__c == null || objWarpper.objOppLineItem.End_Date__c == null)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Start Date and End Date must be populated.'));
                    return null;
                }
                if(mapProduct2IdToPricebookEntryId.containsKey(objWarpper.idProduct2Id))
                {
                    objWarpper.objOppLineItem.PricebookEntryId = mapProduct2IdToPricebookEntryId.get(objWarpper.idProduct2Id);
                    lstOpportunityLineItemsToInsert.add(objWarpper.objOppLineItem);
                }
            }
            // if lstOpportunityLineItemsToInsert is empty for selectd product(Only reason when pricebookEntry is not availbale for product2)
            if(lstOpportunityLineItemsToInsert.isEmpty())
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'PriceBookEntry for selected product is not exist.'));
                return null;
            }
            else
                insert lstOpportunityLineItemsToInsert;
        }
        catch(Exception ex)
        {
            system.debug('==========ex.getMessage()=========='+ex.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            return null;
        }
        PageReference ReturnPage = new PageReference('/' + objOpp.Id);
        ReturnPage.setRedirect(true); 
        return ReturnPage;
    }
     /**
    @MethodName : cancel
    @Param      : 
    @Description: This method will redirect to opportunty detail page
    **/
    public PageReference cancel()
    {
        PageReference ReturnPage = new PageReference('/' + objOpp.Id);
        ReturnPage.setRedirect(true);
        return ReturnPage;
    }
     /**
    @MethodName : getMonths
    @Param      : 
    @Description: This method will return all the months and respective order number
    **/
    public List<SelectOption> getMonths()
    {
        List<SelectOption> options = new List<SelectOption>{
            new SelectOption('1','JAN'), new SelectOption('2','FEB'), new SelectOption('3','March'),
            new SelectOption('4','April'), new SelectOption('5','MAY'), new SelectOption('6','JUNE'),
            new SelectOption('7','JULY'), new SelectOption('8','AUG'), new SelectOption('9','SEP'),
            new SelectOption('10','OCT'), new SelectOption('11','NOV'), new SelectOption('12','DEC')
        };
        return options;
    }
     /**
    @MethodName : onChangeOfProductFamily
    @Param      : 
    @Description: this method will execute when user change the product family picklist
    **/
    public void onChangeOfProductFamily()
    {
        system.debug('========inside family========='+strProductGroupSelected);
        setProductGroup = new set<String>{'--None--'};
        setProductOffering = new set<String>{'--None--'};
        if(mapProductFamilyToSetProductGroup.containsKey(strProductFamilySelected))
            setProductGroup.addAll(mapProductFamilyToSetProductGroup.get(strProductFamilySelected));
    }
     /**
    @MethodName : onChangeOfProductGroup
    @Param      : 
    @Description: this method will execute when user change the product group picklist
    **/
    public void onChangeOfProductGroup()
    {
        system.debug('========inside group========='+strProductGroupSelected);
        setProductOffering = new set<String>{'--None--'};
        if(mapProductGroupToSetProductOffering.containsKey(strProductGroupSelected))
            setProductOffering.addAll(mapProductGroupToSetProductOffering.get(strProductGroupSelected));
    }
     /**
    @MethodName : getRetailers
    @Param      : 
    @Description: This method will return ALR_Retailer__c picklist values
    **/
    public list<Schema.Picklistentry> getRetailers(){
        return Product2.fields.ALR_Retailer__c.getDescribe().getpicklistvalues();
    }
     /**
    @MethodName : getAccountingUnits
    @Param      : 
    @Description: This method will return Product_LOB__c picklist values
    **/
    public list<Schema.Picklistentry> getAccountingUnits(){
        return Product2.fields.Product_LOB__c.getDescribe().getpicklistvalues();
    }
    /**
    @MethodName : getFamily
    @Param      : 
    @Description: This method will return family picklist values
    **/
     public list<Schema.Picklistentry> getFamily(){
        return Product2.fields.Family.getDescribe().getpicklistvalues();
    }
}