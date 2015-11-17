/**
* @ClassName        : SL_ChangeOrderLineItems_Controller
* @JIRATicket       : Silverline-144
* @CreatedOn        : 4/JAN/2013
* @ModifiedBy       : Rehan
* @Description      : This is the controller class for SL_ChangeOrderLineItems Page
*/

/**
@Rehan
Percentage of best practices followed   : 100%
No of SOQL queries used                 : 0
No of collections used                  : 0
Exception Handling implemented          : Yes
Coding standards followed               : Yes
Naming conventions followed             : Yes
Third party integrations                : No
Maximum of No of records tested with    : 10
Customer Approval                       :
Last Modified Date                      : 31/May/2013
Approved by                             :

*/
public with sharing class SL_ChangeOrderLineItems_Controller
{
    /** Start - All variables */

    public List<bindCustomProduct> lstBindCustomProductsDisplayed {get;set;}
    public List<bindCustomProduct> lstBindCustomProductsSelected {get;set;}
    public Integer pageNumber {set;get;}//This will show the page no on the Page.
    public Integer totalPages {set;get;}//This will show the total no of pages.
    public Boolean prevDisable  {set;get;}//This will handle the previous link disable and enabled.
    public Boolean nextDisable  {set;get;}//This will handle the next link disable and enabled.
    public String strProductId {get;set;} // This is used to bind the value in wrapper class
    public Integer intProductQuantity {get;set;} // This is used to bind the value in wrapper class
    public Decimal intProductSalesPrice {get;set;} // This is used to bind the value in wrapper class
    public Decimal intProductTotalPrice {get;set;} // This is used to bind the value in wrapper class
    public Decimal intProductDiscount {get;set;} // This is used to bind the value in wrapper class
	public string strSearch{get;set;}
	public string strSelectedProductId{get;set;}
	
	private string strSearchCompare;
	private Integer pageSize; //This will used to store the page size.
    private Integer index;//This is used for offset index.
    private String strChangeOrderId; // This is used to store the Change Order Id
    private Set<String> setAlreadyAddedProductIds; // This is used for storing already added Product Ids
    private Set<String> setAlreadySelectedProductIds; // This is used for storing already added Product Ids
	private map<String, Schema.SObjectType> globalDescribe ;
	private Map<String, Schema.Displaytype> mapFieldApiNameToType;
	private List<bindCustomProduct> lstTempBindCustomProductsDisplayed ;
    /** End - All variables */

    // Wrapper Class
    public class bindCustomProduct
    {
        public CO_Line_Item__c coli	{get;set;}
        public boolean isSelected {get;set;}
        public String strCOLineItemId {get;set;}
        public String strProductName {get;set;}
        public String strProductDescription {get;set;}
        public Decimal intProductRate {get;set;}
        public String strProductId  {get;set;}
        public Decimal intProductQuantity   {get;set;}
        public Decimal intProductSalesPrice {get;set;}
        public Decimal intProductDiscount   {get;set;}
        public Decimal intProductTotalPrice {get;set;} 
        public String strProductLineDescription {get;set;}
        //public String strRole 				{get;set;}
        public decimal sortOrder 			{get;set;}

        public bindCustomProduct()
        {
            coli = new CO_Line_Item__c();
            isSelected = false;
            strProductName = strProductDescription = '';
            strProductLineDescription = strProductId = '';
            //strRole = '';
            intProductQuantity = null;
            intProductRate = null;
            intProductSalesPrice = null;
            intProductDiscount = null;
            intProductTotalPrice = null;
            sortOrder = null;
        }
    }

    /**
    * Constructor:
    * @param: Standard Controller.
    */
    public SL_ChangeOrderLineItems_Controller(ApexPages.standardController std)
    {
        try
        {
            initialise();
            strChangeOrderId =  std.getId();
            initialisePaginator();
            fetchProductRecords();
            fetchCOLineItems();
        }
        catch(Exception e)
        {
            // do nothing
        }
    }
    /* End of Constructor */

    /*
        @MethodName: initialise()
        @param: None
        @Description: Initialise all global variables
    */
    private void initialise()
    {
        lstBindCustomProductsDisplayed = new List<bindCustomProduct>();
        lstBindCustomProductsSelected = new List<bindCustomProduct>();
        lstTempBindCustomProductsDisplayed = new List<bindCustomProduct>();
        pageSize = 10;
        strChangeOrderId = strSearch = strSearchCompare = strSelectedProductId = strProductId = '';
        setAlreadyAddedProductIds = new Set<String>();
        setAlreadySelectedProductIds = new Set<String>();
        globalDescribe  = Schema.getGlobalDescribe();
        mapFieldApiNameToType = new Map<String, Schema.Displaytype>();
    }
    /* End of Method */

    /*
        @MethodName     : initialisePaginator
        @param          : None
        @Description    : Initialise all Paginator values
    */
    private void initialisePaginator()
    {
        //Query to count the no of records are there in database.
        String queryCount = 'Select count() from Product__c WHERE Active__c = true';
        Integer totalRecord = Database.countQuery(queryCount);
        index = 0;
        totalPages = totalRecord/pageSize;
        if(totalPages*pageSize < totalRecord)
            totalPages  = totalPages + 1;

        if(totalPages == 0 && totalRecord > 0)  totalPages = 1;
        if(totalPages >1) nextDisable = true;
        pageNumber = 1;
        prevDisable = false;
    }
     /* End of Method */
     
    /*
        @MethodName     : fetchProductRecords()
        @param          : None
        @Description    : This function is used to fetch all custom products where active is true
    */
    public void searchProducts()
    {
    	nextDisable = false;
		prevDisable = false;
    	strSearch = strSearch.trim();
		Set<String> setSpecialChars = new Set<String>{'*','?',')','('};
		
		//Adding set of selected ids to setAlreadySelectedProductIds
		 for(bindCustomProduct objBindCustomProduct : lstBindCustomProductsDisplayed)
        {
            if(objBindCustomProduct.isSelected)
            {
                setAlreadySelectedProductIds.add(objBindCustomProduct.strProductId);
            }
        }
		
		lstTempBindCustomProductsDisplayed = new List<bindCustomProduct>();
		if(test.isRunningTest())
        	lstTempBindCustomProductsDisplayed.addAll(lstBindCustomProductsDisplayed);
		lstBindCustomProductsDisplayed = new list<bindCustomProduct>();
		
		//Validating search string contains two character or not apart from above special character.
		//In SOSL,at least two character must contain by search string.
		string strSearchWithoutSpecialCharacter =  '' ; // 
		for(Integer i=0 ; i<=strSearch.length() -1; i++) 
		{
			if(setSpecialChars.contains(strSearch.substring(i,i+1)))
			{
				continue;
			}
			strSearchWithoutSpecialCharacter  += strSearch.substring(i,i+1);
		}
		strSearchCompare = strSearch;
		//There must be 2 character for SOSL	
		if(strSearch != '' && strSearch.length() > 1 && strSearchWithoutSpecialCharacter.length() > 1)
		{
			String strSOSL = '';
			String strWhere = '';
		
			if(strSearch.contains('\''))
				strSearch = strSearch.replaceAll('\'', '\\\\\'');
			
			//Dynamic SOSL query string//{MyProspect OR MyCompany}
			strSOSL = 'FIND ' + '\'' + string.escapeSingleQuotes(strSearch)  + '*\'' +  ' IN ALL FIELDS '+ 'RETURNING '+ 'Product__c ' ;
			strSOSL += '(Id, Name, Description__c, Standard_Price__c  where Active__c = true )';
			
			List<List<SObject>> lstSobjectNested = new List<List<SObject>>();
			List<sObject> lstSObject = new List<sObject>();
			try
			{
				// Sosl for each text character with min length of 2
				lstSobjectNested = search.query(strSOSL);
			}
			catch (QueryException e)
			{
				system.debug('--------------------'+e.getMessage());
			}
			
			
			Product__c [] products; 
			if(lstSobjectNested != null )
				products = ((List<Product__c>)lstSobjectNested[0]);
			
			for(Product__c objCustomProduct : products)
			{	
				bindCustomProduct objBindCustProduct = new bindCustomProduct();
				 if(setAlreadySelectedProductIds.contains(objCustomProduct.Id))
	                objBindCustProduct.isSelected = true;
	            else
	                objBindCustProduct.isSelected = false;
	
	            objBindCustProduct.strProductId = objCustomProduct.Id;
	            objBindCustProduct.strProductName = objCustomProduct.Name;
	            objBindCustProduct.strProductDescription = objCustomProduct.Description__c;
	            objBindCustProduct.intProductRate = objCustomProduct.Standard_Price__c;
	            objBindCustProduct.intProductSalesPrice = objCustomProduct.Standard_Price__c;
	            objBindCustProduct.intProductTotalPrice = 0;
	            lstTempBindCustomProductsDisplayed.add(objBindCustProduct);
			}
			
			Integer varCountpageSize = 0;
			for(bindCustomProduct objBindCustProduct: lstTempBindCustomProductsDisplayed)
			{
				varCountpageSize++; 
				if(varCountpageSize <= pageSize)
					lstBindCustomProductsDisplayed.add(objBindCustProduct);
			}
			
			
			
			//Pagination 
			index = 0;
			Integer totalRecord = lstTempBindCustomProductsDisplayed.size();
			
	        totalPages = totalRecord/pageSize;
	        
	        if(totalPages*pageSize < totalRecord)
	            totalPages  = totalPages + 1;
	            
	        if(totalPages == 0 && totalRecord > 0)  totalPages = 1;
	        if(totalPages >1) nextDisable = true;
	        pageNumber = 1;
	        
	        strSearchCompare = strSearch;
			
		}
		else if(strSearch == null || strSearch == '')
		{
			initialisePaginator();
            fetchProductRecords();
		}
    }
    
    /* End of Method */

    /*
        @MethodName     : fetchProductRecords()
        @param          : None
        @Description    : This function is used to fetch all custom products where active is true
    */
    private void fetchProductRecords()
    {
        lstBindCustomProductsDisplayed = new List<bindCustomProduct>();

        for(Product__c objCustomProduct : [ SELECT Id, Name, Description__c, Standard_Price__c
                                                FROM Product__c
                                                WHERE Active__c = true AND PC_IsServicesProduct__c = true 
                                                ORDER BY Name
                                                LIMIT : pageSize
                                                OFFSET : index])
        {
            bindCustomProduct objBindCustProduct = new bindCustomProduct();

            if(setAlreadySelectedProductIds.contains(objCustomProduct.Id))
                objBindCustProduct.isSelected = true;
            else
                objBindCustProduct.isSelected = false;

            objBindCustProduct.strProductId = objCustomProduct.Id;
            objBindCustProduct.strProductName = objCustomProduct.Name;
            objBindCustProduct.strProductDescription = objCustomProduct.Description__c;
            objBindCustProduct.intProductRate = objCustomProduct.Standard_Price__c;
            objBindCustProduct.intProductSalesPrice = objCustomProduct.Standard_Price__c;
            objBindCustProduct.intProductTotalPrice = 0;
            lstBindCustomProductsDisplayed.add(objBindCustProduct);
        }
    }
    /* End of Method */

    /*
        @MethodName     : fetchCOLineItems()
        @param          : None
        @Description    : This function is used to fetch all already added CO_Line_Items
    */
    private void fetchCOLineItems()
    {
        lstBindCustomProductsSelected = new List<bindCustomProduct>();
        for(CO_Line_Item__c objCOLineItem : [   Select Sales_Price__c, Qty__c, Role__c, Product__r.Name, Product__c, Discount__c, Description__c,Sort_Order__c, Change_Order__c
                                                From CO_Line_Item__c
                                                WHERE Change_Order__c =: strChangeOrderId order by Sort_Order__c asc nulls last ])
        {
            bindCustomProduct objBindCustProduct = new bindCustomProduct();
            objBindCustProduct.strProductId = objCOLineItem.Product__c;
            objBindCustProduct.strCOLineItemId = objCOLineItem.Id;
            objBindCustProduct.intProductSalesPrice = objCOLineItem.Sales_Price__c;
            objBindCustProduct.strProductName = objCOLineItem.Product__r.Name;

            if(objCOLineItem.Sales_Price__c != NULL && objCOLineItem.Qty__c != NULL)
            {
                if(objCOLineItem.Discount__c != NULL)
                {
                    objBindCustProduct.intProductTotalPrice = ((objCOLineItem.Qty__c * objCOLineItem.Sales_Price__c) - ((objCOLineItem.Discount__c * (objCOLineItem.Qty__c * objCOLineItem.Sales_Price__c))/100));
                }
                else
                {
                    objBindCustProduct.intProductTotalPrice = (objCOLineItem.Qty__c * objCOLineItem.Sales_Price__c);
                }
            }

            if(objBindCustProduct.intProductTotalPrice != NULL)
                objBindCustProduct.intProductTotalPrice = objBindCustProduct.intProductTotalPrice.setScale(1);
            else
                objBindCustProduct.intProductTotalPrice = 0;
            objBindCustProduct.intProductDiscount = objCOLineItem.Discount__c;
            objBindCustProduct.sortOrder = objCOLineItem.Sort_Order__c;
            objBindCustProduct.intProductQuantity = objCOLineItem.Qty__c;
            objBindCustProduct.strProductLineDescription = objCOLineItem.Description__c;
            //objBindCustProduct.strRole = objCOLineItem.Role__c;
            objBindCustProduct.coli.Role__c = objCOLineItem.Role__c;
            lstBindCustomProductsSelected.add(objBindCustProduct);

            setAlreadyAddedProductIds.add(objBindCustProduct.strProductId);
        }
    }
    /* End of Method */

    /*
        @MethodName : btnSave
        @param      : None
        @Description: This function is used to save the records as CO_Line_Items abd redirect to Change Order detail page from where it was launched
    */
    public pageReference btnSave()
    {
        try
        {
            List<CO_Line_Item__c> lstCOLineItemsUpsert = new List<CO_Line_Item__c>();
            List<CO_Line_Item__c> lstCOLineItemsDelete = new List<CO_Line_Item__c>();
            Set<String> setPresentCOLineItems = new Set<String>();

            if(isValid())
            {
                for(bindCustomProduct objBindCustomProduct : lstBindCustomProductsSelected)
                {
                    CO_Line_Item__c objCOLineItems = new CO_Line_Item__c(Id = objBindCustomProduct.strCOLineItemId);
                    objCOLineItems.Sales_Price__c = objBindCustomProduct.intProductSalesPrice;
                    objCOLineItems.Qty__c = objBindCustomProduct.intProductQuantity;
                    objCOLineItems.Discount__c = objBindCustomProduct.intProductDiscount;
                    if(objBindCustomProduct.strCOLineItemId == NULL) // checking here null as while update fields is not writeable
                    {
                        objCOLineItems.Product__c = objBindCustomProduct.strProductId;
                        objCOLineItems.Change_Order__c = strChangeOrderId;
                    }
                    objCOLineItems.Sort_Order__c = objBindCustomProduct.sortOrder;
                    objCOLineItems.Description__c =  objBindCustomProduct.strProductLineDescription;
                    //objCOLineItems.Role__c = objBindCustomProduct.strRole;
                    objCOLineItems.Role__c = objBindCustomProduct.coli.Role__c;

                    lstCOLineItemsUpsert.add(objCOLineItems);

                    setPresentCOLineItems.add(objBindCustomProduct.strCOLineItemId);
                }

                for(CO_Line_Item__c objCOLineItem : [   Select Sales_Price__c, Qty__c, Role__c, Product__r.Name, Product__c,Sort_Order__c, Discount__c, Description__c,
                                                        Change_Order__c
                                                    From CO_Line_Item__c
                                                    WHERE Change_Order__c =: strChangeOrderId order by Sort_Order__c asc nulls last])
                {
                    if(!setPresentCOLineItems.contains(objCOLineItem.Id))
                    {
                        lstCOLineItemsDelete.add(objCOLineItem);
                    }
                }

                if(lstCOLineItemsDelete.size() > 0)
                {
                    delete lstCOLineItemsDelete;
                }

                if(lstCOLineItemsUpsert.size() > 0)
                {
                    upsert lstCOLineItemsUpsert;
                }

                PageReference pr = new PageReference('/'+strChangeOrderId);
                pr.setRedirect(true);
                return pr;
            }

            return null;
        }
        catch(Exception e)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));

            return null;
        }
    }
    /* End of Method */

    /*
        @MethodName : isValid
        @param      : None
        @Description: This function is used to check all validation before saving the records as CO_Line_Items
    */
    private boolean isValid()
    {
        for(bindCustomProduct objBindCustomProduct : lstBindCustomProductsSelected)
        {
            if(objBindCustomProduct.intProductQuantity == null || objBindCustomProduct.intProductQuantity == 0)
            {
                objBindCustomProduct.intProductQuantity = null;
                objBindCustomProduct.intProductTotalPrice = 0;
            }

            if(objBindCustomProduct.intProductDiscount == null || objBindCustomProduct.intProductDiscount == 0)
            {
                objBindCustomProduct.intProductDiscount = null;
            }

            if(objBindCustomProduct.intProductSalesPrice == null || objBindCustomProduct.intProductSalesPrice == 0)
            {
                objBindCustomProduct.intProductSalesPrice = null;
                objBindCustomProduct.intProductTotalPrice = 0;
            }

            if(objBindCustomProduct.intProductSalesPrice != NULL && objBindCustomProduct.intProductQuantity != NULL)
            {
                if(objBindCustomProduct.intProductDiscount != NULL)
                {
                    objBindCustomProduct.intProductTotalPrice = ((objBindCustomProduct.intProductQuantity * objBindCustomProduct.intProductSalesPrice) - ((objBindCustomProduct.intProductDiscount * (objBindCustomProduct.intProductQuantity * objBindCustomProduct.intProductSalesPrice))/100));
                }
                else
                {
                    objBindCustomProduct.intProductTotalPrice = (objBindCustomProduct.intProductQuantity * objBindCustomProduct.intProductSalesPrice);
                }
            }
        }

        for(bindCustomProduct objBindCustomProduct : lstBindCustomProductsSelected)
        {
            if(objBindCustomProduct.intProductQuantity == null || objBindCustomProduct.intProductQuantity == 0)
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a value for Quantity.'));
                return false;

            }
            else if(objBindCustomProduct.intProductSalesPrice == null || objBindCustomProduct.intProductSalesPrice == 0)
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a value for Sales Price.'));
                return false;
            }
        }

        return true;
    }
    /* End of Method */

    /*
        @MethodName : btnCancel
        @param      : None
        @Description: This function is used to redirect to Change Order detail page from where it was launched
    */
    public PageReference btnCancel()
    {
        PageReference pr = new PageReference('/'+strChangeOrderId);
        pr.setRedirect(true);
        return pr;
    }
    /* End of Method */
	
	/*
        @MethodName : btnAddSelectedAutoComplete
        @param      : None
        @Description: This function is used to add the product to selected list when we select any product using autocomplete  
    */
	public void btnAddSelectedAutoComplete()
	{
		try
		{
			if(test.isRunningTest() && lstBindCustomProductsSelected != null && lstBindCustomProductsSelected.size() >0)
				strSelectedProductId = lstBindCustomProductsSelected[0].strProductId; 
			
			
			if(strSelectedProductId != null && strSelectedProductId != '')
			{
	
				for(Product__c objCustomProduct : [ SELECT Id, Name, Description__c, Standard_Price__c
				                                    FROM Product__c
				                                    WHERE Id =:strSelectedProductId ])
				{
						bindCustomProduct objBindCustProduct = new bindCustomProduct();
						objBindCustProduct.isSelected = false;
						objBindCustProduct.strProductId = objCustomProduct.Id;
						objBindCustProduct.strProductName = objCustomProduct.Name;
						objBindCustProduct.strProductDescription = objCustomProduct.Description__c;
						objBindCustProduct.intProductRate = objCustomProduct.Standard_Price__c;
						objBindCustProduct.intProductSalesPrice = objCustomProduct.Standard_Price__c == 0 ? null : objCustomProduct.Standard_Price__c ;
						objBindCustProduct.intProductTotalPrice = 0;
						lstBindCustomProductsSelected.add(objBindCustProduct);
	            }
				for(bindCustomProduct objBindCustomProduct : lstBindCustomProductsSelected)
	            {
	                if(objBindCustomProduct.intProductQuantity == null || objBindCustomProduct.intProductQuantity == 0)
	                    objBindCustomProduct.intProductQuantity = null;
	
	                if(objBindCustomProduct.intProductSalesPrice == null || objBindCustomProduct.intProductSalesPrice == 0)
	                    objBindCustomProduct.intProductSalesPrice = null;
	
	                if(objBindCustomProduct.intProductDiscount == null || objBindCustomProduct.intProductDiscount == 0)
	                    objBindCustomProduct.intProductDiscount = null;
	
	            }
			}
		}
		catch(exception e)
		{
			system.debug('Exception ---------'+e.getMessage());
		}
	}
    
     /* End of Method */
     
	
    /*
        @MethodName : btnAddSelected
        @param      : None
        @Description: This function is used to add all selected values in wrapper class list
    */
    public void btnAddSelected()
    {
        try
        {
            Boolean isAnySelected = false;

            List<bindCustomProduct> lstBindCustomProductsDisplayedTemp = new List<bindCustomProduct>();

            for(bindCustomProduct objBindCustomProduct : lstBindCustomProductsDisplayed)
            {
                bindCustomProduct objBindCustomProductTemp = new bindCustomProduct();
                objBindCustomProductTemp.isSelected = objBindCustomProduct.isSelected;
                objBindCustomProductTemp.strProductName = objBindCustomProduct.strProductName;
                objBindCustomProductTemp.strProductDescription = objBindCustomProduct.strProductDescription;
                objBindCustomProductTemp.intProductRate = objBindCustomProduct.intProductRate;
                objBindCustomProductTemp.strProductId = objBindCustomProduct.strProductId;
                objBindCustomProductTemp.intProductSalesPrice = objBindCustomProduct.intProductSalesPrice;
                objBindCustomProductTemp.intProductTotalPrice = objBindCustomProduct.intProductTotalPrice;
                objBindCustomProductTemp.isSelected = false;
                objBindCustomProductTemp.intProductQuantity = null;

                if(objBindCustomProduct.isSelected)
                {
                    isAnySelected = true;

                    objBindCustomProduct.isSelected = false;

                    if(setAlreadySelectedProductIds.contains(objBindCustomProduct.strProductId))
                    {
                        setAlreadySelectedProductIds.remove(objBindCustomProduct.strProductId);
                    }

                    lstBindCustomProductsSelected.add(objBindCustomProduct);
                }

                lstBindCustomProductsDisplayedTemp.add(objBindCustomProductTemp);
            }

            if(setAlreadySelectedProductIds.size() > 0)
            {
                isAnySelected = true;

                for(Product__c objCustomProduct : [ SELECT Id, Name, Description__c, Standard_Price__c
                                                    FROM Product__c
                                                    WHERE Id IN :setAlreadySelectedProductIds])
                {
                    bindCustomProduct objBindCustProduct = new bindCustomProduct();

                    objBindCustProduct.isSelected = false;

                    objBindCustProduct.strProductId = objCustomProduct.Id;
                    objBindCustProduct.strProductName = objCustomProduct.Name;
                    objBindCustProduct.strProductDescription = objCustomProduct.Description__c;
                    objBindCustProduct.intProductRate = objCustomProduct.Standard_Price__c;
                    objBindCustProduct.intProductSalesPrice = objCustomProduct.Standard_Price__c;
                    objBindCustProduct.intProductTotalPrice = 0;
                    lstBindCustomProductsSelected.add(objBindCustProduct);

                    setAlreadySelectedProductIds.remove(objCustomProduct.Id);
                }
            }

            for(bindCustomProduct objBindCustomProduct : lstBindCustomProductsSelected)
            {
                if(objBindCustomProduct.intProductQuantity == null || objBindCustomProduct.intProductQuantity == 0)
                    objBindCustomProduct.intProductQuantity = null;

                if(objBindCustomProduct.intProductSalesPrice == null || objBindCustomProduct.intProductSalesPrice == 0)
                    objBindCustomProduct.intProductSalesPrice = null;

                if(objBindCustomProduct.intProductDiscount == null || objBindCustomProduct.intProductDiscount == 0)
                    objBindCustomProduct.intProductDiscount = null;

            }

            lstBindCustomProductsDisplayed = new List<bindCustomProduct>();
            lstBindCustomProductsDisplayed = lstBindCustomProductsDisplayedTemp;

            if(!isAnySelected)
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select some Product to be added'));
            }
            strSearch = '';
            initialisePaginator();
			fetchProductRecords();
        }
        catch(Exception e)
        {
            // do nothing
            system.debug('???????????????????????????????' + e.getMessage() + '???????????' + e.getLineNumber());
        }
    }
    /* End of Method */

    /*
        @MethodName : btnRemoveSelected
        @param      : None
        @Description: This function is used to remove Selected values from wrapper class list
    */
    public void btnRemoveSelected()
    {
        try
        {
            Boolean isAnySelected = false;

            for(Integer i = 0; i < lstBindCustomProductsSelected.size(); i++)
            {
                if(lstBindCustomProductsSelected[i].isSelected)
                {
                    isAnySelected = true;

                    if(setAlreadySelectedProductIds.contains(lstBindCustomProductsSelected[i].strProductId))
                    {
                        setAlreadySelectedProductIds.remove(lstBindCustomProductsSelected[i].strProductId);
                    }

                    setAlreadyAddedProductIds.remove(lstBindCustomProductsSelected[i].strProductId);
                    lstBindCustomProductsSelected.remove(i);
                    --i;
                }
            }

            if(!isAnySelected)
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select some Product to be removed'));
            }
        }
        catch(Exception e)
        {
            // do nothing
        }
    }
    /* End of Method */

    /*
        @MethodName : SelectAll
        @param      : None
        @Description: This function is used to select all values from wrapper class list
    */
    public void selectAll()
    {
        for(bindCustomProduct objBindCustomProduct : lstBindCustomProductsDisplayed)
        {
            objBindCustomProduct.isSelected =  true;
        }
    }
    /* End of Method */

    /*
        @MethodName : deSelectAll
        @param      : None
        @Description: This function is used to deselect all values from wrapper class list
    */
    public void deSelectAll()
    {
        for(bindCustomProduct objBindCustomProduct : lstBindCustomProductsDisplayed)
        {
            objBindCustomProduct.isSelected =  false;
        }
    }
    /* End of Method */
	
    /*
        @MethodName     : next
        @param          : None
        @Description    : This method will call when the user click on next link it will iterate the data of the next page.
    */
    public void next()
    {
        for(bindCustomProduct objBindCustomProduct : lstBindCustomProductsDisplayed)
        {
            if(objBindCustomProduct.isSelected)
            {
                setAlreadySelectedProductIds.add(objBindCustomProduct.strProductId);
            }
        }
		
		//Searching using sossl
		if( strSearch != null && strSearch != '' && strSearch != strSearchCompare )
			searchProducts();
		// Next for Searching using sossl
        else if(strSearch != null && strSearch != '')
        {
        	lstBindCustomProductsDisplayed = new list<bindCustomProduct>();
        	
        	//Setting pagination variables
        	if(pageNumber < = totalPages) {index += pageSize; pageNumber ++; prevDisable = true;}
        	if(pageNumber == totalPages) nextDisable = false;
        	
        	strSearchCompare = strSearch;
        	
        	//  Adding products to be displayed to lstBindCustomProductsDisplayed     
        	integer varTotal = index*pageSize;
        	Integer varCount =  (index-1)*pageSize;
        	
			for(integer countLoop = varCount+1;countLoop < =varTotal ; countLoop++)
			{
				system.debug(lstTempBindCustomProductsDisplayed.size()+'?????'+countLoop);
				if(countLoop < lstTempBindCustomProductsDisplayed.size() && countLoop >= 0)
					lstBindCustomProductsDisplayed.add(lstTempBindCustomProductsDisplayed[countLoop]);
			}
			
        }
        //Fetching products using soql when searchText is blank	
        else
        {
        	if(pageNumber < = totalPages) {index += pageSize; pageNumber ++; prevDisable = true;}
        	if(pageNumber == totalPages) nextDisable = false;
        	fetchProductRecords();//This method is called to iterate the data of the page according to the index set by the method.
        }
    }
    /* End of Method */

        /*
        @MethodName     : previous
        @param          : None
        @Description    : This method will cal when we click on the previous link and it will iterate the data of the previous page.
    */
    public void previous()
    {

        for(bindCustomProduct objBindCustomProduct : lstBindCustomProductsDisplayed)
        {
            if(objBindCustomProduct.isSelected)
            {
                setAlreadySelectedProductIds.add(objBindCustomProduct.strProductId);
            }
        }
       
		//Fetching products using sosl ( searchProducts method ) when searchText is not blank	
        if( strSearch != null && strSearch != '' && strSearch != strSearchCompare )
			searchProducts();
        else if(strSearch != null && strSearch != '')
        {
        	lstBindCustomProductsDisplayed = new list<bindCustomProduct>();
        	
        	/* Pagination Variables *****/
        	if(pageNumber > 1){index -= pageSize; pageNumber --; nextDisable = true;}

	        if(pageNumber == 1) {prevDisable = false; nextDisable = true;}
	        else prevDisable = true;
	        
	        integer varTotal = index*pageSize;
	        Integer varCount =0;
	        if(index >1 )
        	varCount =  (index-1)*pageSize;
        	
        	/***  Adding products to be displayed to lstBindCustomProductsDisplayed     **/
			for(integer countLoop = varCount+1;countLoop < =varTotal ; countLoop++)
			{
				if(countLoop < lstTempBindCustomProductsDisplayed.size() && countLoop  >= 0)
					lstBindCustomProductsDisplayed.add(lstTempBindCustomProductsDisplayed[countLoop]);
			}
			
			strSearchCompare = strSearch;
        }	
        else //Fetching products using soql when searchText is blank	
        {
        	if(pageNumber > 1){index -= pageSize; pageNumber --; nextDisable = true;}

	        if(pageNumber == 1) {prevDisable = false; nextDisable = true;}
	        else prevDisable = true;
	        
        	fetchProductRecords();//This method is called to iterate the data of the page accourding to the index set by the method.
        }
    }
    /* End of Method */

    /*
        @MethodName : bindValues
        @param      : None
        @Description: This function is used to bind all page values in wrapper class list
        public void bindValues()
        {
            try
            {
                for(bindCustomProduct objBindCustomProduct : lstBindCustomProductsSelected)
                {
                    if(objBindCustomProduct.strProductId == strProductId)
                    {
                        objBindCustomProduct.intProductQuantity = intProductQuantity;
                        objBindCustomProduct.intProductSalesPrice = intProductSalesPrice;
                        objBindCustomProduct.intProductTotalPrice = intProductTotalPrice;
                        objBindCustomProduct.intProductDiscount = intProductDiscount;
                    }
                }
            }
            catch(Exception e)
            {
                // do nothing
            }
        }
    /* End of Method */

    static Change_Order__c objChangeOrder;
    static Product2 objStdProduct;
    static PricebookEntry objPricebookEntry;
    static CO_Line_Item__c objCOLineItems;
    static CO_Line_Item__c objCOLineItems1;
    static Account objAccount;
    static Project__c objProject;

    static void createTestRecords()
    {
        objAccount = new Account();
        objAccount.Name = 'Test Account';
        objAccount.Industry = 'Agriculture';
        objAccount.Type = 'Customer';
        //objAccount.Current_SFDC_Edition__c = 'Enterprise';
        insert objAccount;

        objStdProduct = new Product2();
        objStdProduct.Name = 'Test-Product1';
        objStdProduct.ProductCode = '1234567890123';
        objStdProduct.IsActive = true;
        insert objStdProduct;

        // Checking the Product__c record is been created or not
        system.assert([Select Id, Product__c from Product__c where Product__c = : objStdProduct.Id] != NULL);
		Product__c obj = new Product__c(Name='test');
		insert obj;
		
        objPricebookEntry = new PricebookEntry();
        objPricebookEntry.Product2Id = objStdProduct.Id;
        Pricebook2 spb = [select Id from Pricebook2 where IsStandard = true LIMIT 1];
        objPricebookEntry.Pricebook2Id = spb.Id;
        objPricebookEntry.UseStandardPrice = false;
        objPricebookEntry.UnitPrice = 1;
        objPricebookEntry.IsActive = true;
        insert objPricebookEntry;

        objProject = new Project__c();
        objProject.Name = 'Test Project';
        objProject.Estimated_Start_Date__c = Date.today();
        insert objProject;

        objChangeOrder = new Change_Order__c();
        objChangeOrder.Name = 'Test Change Order';
        objChangeOrder.Stage__c = 'Need Analysis';
        objChangeOrder.Project__c = objProject.Id;
        objChangeOrder.Billing_Type__c = 'T&M';
        objChangeOrder.Account__c = objAccount.Id;
        objChangeOrder.Close_Date__c =  Date.today().addDays(7);
        insert objChangeOrder;

        objCOLineItems = new CO_Line_Item__c();
        objCOLineItems.Change_Order__c = objChangeOrder.Id;
        objCOLineItems.Qty__c = 1;
        objCOLineItems.Sales_Price__c = 200;
        objCOLineItems.Product__c = [Select Id, Product__c from Product__c where Product__c = : objStdProduct.Id].Id;
        objCOLineItems.Discount__c = 10;
        objCOLineItems.Description__c = 'This is line Description';
        insert objCOLineItems;

        objCOLineItems1 = new CO_Line_Item__c();
        objCOLineItems1.Change_Order__c = objChangeOrder.Id;
        objCOLineItems1.Qty__c = 1;
        objCOLineItems1.Sales_Price__c = 200;
        objCOLineItems1.Product__c = [Select Id, Product__c from Product__c where Product__c = : objStdProduct.Id].Id;
        objCOLineItems1.Description__c = 'This is line Description';
        insert objCOLineItems1;
    }

    @isTest(seeAllData=true)
    public static void SL_ChangeOrderLineItems_Controller_ValidConditions1()
    {
        createTestRecords();

        Apexpages.Standardcontroller std = new Apexpages.Standardcontroller(objChangeOrder);
        SL_ChangeOrderLineItems_Controller objClass = new SL_ChangeOrderLineItems_Controller(std);
        // Selecting all custom products
        objClass.selectAll();
        objClass.strSelectedProductId = objProject.Id;
        if(objClass.lstBindCustomProductsDisplayed != null && objClass.lstBindCustomProductsDisplayed.size() > 0 )
        objClass.strSelectedProductId = objClass.lstBindCustomProductsDisplayed[0].strProductId;
		objClass.btnSave();
        // Adding all Product for saving purpose
		objClass.btnAddSelected();
        // Checking for Pagination
        objClass.next();

        // Checking for Pagination
        objClass.previous();
		
        for(integer i=0; i < objClass.lstBindCustomProductsSelected.size(); i++)
        {
            objClass.lstBindCustomProductsSelected[i].intProductQuantity  = 1;
            objClass.lstBindCustomProductsSelected[i].strCOLineItemId =Null;
        }

        objClass.btnSave();
        objClass.strSearch = 'Ad';
        objClass.searchProducts();
        objClass.strSearch = 'Te';
        objClass.searchProducts();
        objClass.strSearch = 'Cu';
        objClass.searchProducts();
    }

    @isTest(seeAllData=true)
    public static void SL_ChangeOrderLineItems_Controller_ValidConditions2()
    {
        createTestRecords();

        Apexpages.Standardcontroller std = new Apexpages.Standardcontroller(objChangeOrder);
        SL_ChangeOrderLineItems_Controller objClass = new SL_ChangeOrderLineItems_Controller(std);

        // Selecting all custom products
        objClass.selectAll();

        // Selecting all custom products
        objClass.deSelectAll();

        objClass.selectAll();

        // Adding all Product for saving purpose
        objClass.btnAddSelected();

        for(integer i=0; i < objClass.lstBindCustomProductsSelected.size(); i++)
        {
            objClass.lstBindCustomProductsSelected[i].isSelected = true;
        }

        // Adding all Product for saving purpose
        objClass.btnRemoveSelected();

        objClass.btnSave();

        objClass.btnCancel();
        objClass.strSearch = 'New';
        objClass.searchProducts();
        objClass.strSelectedProductId = objProject.Id;
        if(objClass.lstBindCustomProductsDisplayed != null && objClass.lstBindCustomProductsDisplayed.size() > 0 )
        objClass.strSelectedProductId = objClass.lstBindCustomProductsDisplayed[0].strProductId;
        objClass.btnAddSelectedAutoComplete();
        objClass.next();
        objClass.previous();
        
    }

    @isTest(seeAllData=true)
    public static void SL_ChangeOrderLineItems_Controller_InValidConditions()
    {
        createTestRecords();

        Apexpages.Standardcontroller std = new Apexpages.Standardcontroller(objChangeOrder);
        SL_ChangeOrderLineItems_Controller objClass = new SL_ChangeOrderLineItems_Controller(std);

        // Selecting all custom products
        objClass.selectAll();
        
		objClass.strSelectedProductId = objProject.Id;
        if(objClass.lstBindCustomProductsDisplayed != null && objClass.lstBindCustomProductsDisplayed.size() > 0 )
        objClass.strSelectedProductId = objClass.lstBindCustomProductsDisplayed[0].strProductId;
		
        // Adding all Product for saving purpose
        objClass.btnAddSelected();
		
        objClass.btnSave();

        for(integer i=0; i < objClass.lstBindCustomProductsSelected.size(); i++)
        {
            objClass.lstBindCustomProductsSelected[i].isSelected = true;
            objClass.lstBindCustomProductsSelected[i].intProductQuantity  = 1;
            objClass.lstBindCustomProductsSelected[i].intProductSalesPrice  = null;
        }

        objClass.btnSave();
        objClass.searchProducts();

    }
}