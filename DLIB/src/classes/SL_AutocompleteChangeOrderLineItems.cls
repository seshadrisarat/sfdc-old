public class SL_AutocompleteChangeOrderLineItems 
{
	public SL_AutocompleteChangeOrderLineItems(ApexPages.standardController std)
	{}
    @RemoteAction
    public static list<product__c> findSObjects( String strSearch)
    {
        try
        {
            strSearch = strSearch.trim();
            list<product__c> lstProducts = new list<product__c>();
            
            strSearch = string.escapeSingleQuotes(strSearch);
            
            if(strSearch != ''  )
            {                                               
                String strQuery  = 'Select Name,Active__c From Product__c where Name Like \'%'+ strSearch +'%\' and Active__c = true limit 20'; 
                lstProducts = database.query(strQuery);
                return lstProducts;
            }
        }
        catch(Exception e)
        {
            system.debug('Exception e --------------'+e.getMessage());
        }
        return null; 
    }
    /* End - Method */
    public static testmethod void Test_SL_AutocompleteChangeOrderLineItems()
    {
        test.startTest();
        Account objAccount = new Account();
        objAccount.Name = 'Test Account';
        objAccount.Industry = 'Agriculture';
        objAccount.Type = 'Customer';
        //objAccount.Current_SFDC_Edition__c = 'Enterprise';
        insert objAccount;
        
        Project__c objProject = new Project__c();
        objProject.Name = 'Test Project';
        objProject.Estimated_Start_Date__c = Date.today();
        insert objProject;

        Change_Order__c objChangeOrder = new Change_Order__c();
        objChangeOrder.Name = 'Test Change Order';
        objChangeOrder.Stage__c = 'Need Analysis';
        objChangeOrder.Project__c = objProject.Id;
        objChangeOrder.Billing_Type__c = 'T&M';
        objChangeOrder.Account__c = objAccount.Id;
        objChangeOrder.Close_Date__c =  Date.today().addDays(7);
        insert objChangeOrder;
        Apexpages.Standardcontroller std = new Apexpages.Standardcontroller(objChangeOrder);
        SL_AutocompleteChangeOrderLineItems objContoller  = new SL_AutocompleteChangeOrderLineItems(std);
        Product__c obj = new Product__c(Name='test');
        insert obj;
        SL_AutocompleteChangeOrderLineItems.findSObjects('test');
        SL_AutocompleteChangeOrderLineItems.findSObjects('');
        test.stopTest();
    }

}