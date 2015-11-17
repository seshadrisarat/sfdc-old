/*
*  ClassName      : SL_SalesOrdersHandler 
*  JIRATicket     : LAT-4, LAT-5
*  CreatedOn      : 30/April/2015
*  LastModifiedon : 5/JUNE/2015
*  CreatedBy      : Sanath Kumar
*  LastModifiedBy : Pankaj Ganwani
*  Description    : Handler for trigger on Sales_Orders__c
*/
public class SL_SalesOrdersHandler 
{
    //private static Id idUserInactive = '005A00000056TAT';
    private Id idUserInactive ;
    
    /* start - constructor */ 
    public SL_SalesOrdersHandler()
    {
        idUserInactive = SL_SalesOrdersHandler__c.getValues('Sl_SalesOrderInactiveOwner').InActive_User__c;        
    }
    /* end - constructor */ 
    
    /*
        * MethodName : onBeforeInsert
        * Param      : List<Sales_Orders__c>(Trigger.new) 
        * Description: Triggers on before insert of Sales_Orders__c record to Update OwnerId
    */
    public void onBeforeInsert(List<Sales_Orders__c> lstSalesOrders)
    {
        updateOwnerId(lstSalesOrders);
    }
    
    /*
        * MethodName : onbeforeUpdate
        * Param      : List<Sales_Orders__c>(Trigger.new) 
        * Description: Triggers on before update of Sales_Orders__c record to Update OwnerId
    */
    public void onbeforeUpdate(List<Sales_Orders__c> lstSalesOrdersNew)
    {
        updateOwnerId(lstSalesOrdersNew);
    }
    
    /*
        * MethodName : updateOwnerId
        * Param      : List<Sales_Orders__c>(Trigger.new) 
        * Description: Update OwnerId of Sales_Orders__c record to be User matched by the Id on IntegrationID field.
    */    
    private void updateOwnerId(List<Sales_Orders__c> lstSalesOrdersNew)
    {
        Set<String> setIntegrationId = new set<String>();
       /* for(Sales_Orders__c objSales : lstSalesOrdersNew)
        {
            if(objSales.IntegrationID__c!=null)
            {
                setIntegrationId.add(objSales.IntegrationID__c);
            }
        }*/
        Set<String> setInactiveUsers = new set<String>();
        map<String , User> mapIntegrationIdToUser = new map<String , User>();
        for(User objUser : [Select Id , Integration_ID__c , IsActive from User where Integration_ID__c!=null])
        {
            mapIntegrationIdToUser.put(objUser.Integration_ID__c.toLowerCase() , objUser);
            if(!objUser.isActive)
            {
                setInactiveUsers.add(objUser.Integration_ID__c.toLowerCase());
            }
        }
        for(Sales_Orders__c objSales : lstSalesOrdersNew)
        {
            if(objSales.IntegrationID__c!=NULL && mapIntegrationIdToUser.containsKey(objSales.IntegrationID__c.toLowerCase()))
            {
                if(setInactiveUsers.contains(objSales.IntegrationID__c.toLowerCase()))
                {
                    objSales.OwnerId = idUserInactive;
                }
                else
                {
                   objSales.OwnerId = mapIntegrationIdToUser.get(objSales.IntegrationID__c.toLowerCase()).Id;
                }
            }
        }
    }
}