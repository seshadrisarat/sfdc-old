/**
*  ClassName      : SL_Batch_OrderSalesUpdateByFiscalYear
*  JIRATicket     : LAT-4
*  CreatedOn      : 30/04/2015
*  ModifiedBy     : Sanath Kumar
*  Description    : Batch for creating Sales_Order_Lines__c records for all Sales_Orders__c records with Fiscal year as 13,14 or 15
*/
global class SL_Batch_OrderSalesUpdateByFiscalYear implements Database.Batchable<sObject>
{
    /* Start : Constructor */
    public SL_Batch_OrderSalesUpdateByFiscalYear()
    {
        //Do Nothing
    }
    /* End : Constructor */
    
    /*
        * MethodName   : start
        * Param        : Database.BatchableContext BC
        * Description  : This method returns Sales_Orders__c with Fiscal Year as 13,14 or 15
    */
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        Set<Integer> setFiscalYear = new Set<Integer>{13,14,15};
        String query = 'Select Id from Sales_Orders__c where Fiscal_Year__c In :setFiscalYear';     
        return Database.getQueryLocator(query);
    }
    
    /*
        * MethodName   : execute
        * Param        : Database.BatchableContext BC, List<Sales_Orders__c> lstSalesOrder
        * Description  : Processes Sales Order records returned by start method
    */
 
    global void execute(Database.BatchableContext BC, List<Sales_Orders__c> lstSalesOrder)
    {
        List<Sales_Order_Lines__c> lstSalesOrderLItoInsert = new List<Sales_Order_Lines__c>();
        Set<Id> setSalesOrderId = new Set<Id>();
        List<String> lstMonth = new List<String>{'JAN','FEB','MAR',
                                                 'APR','MAY','JUN',
                                                 'JUL','AUG','SEPT',
                                                 'OCT','NOV','DEC'};
        for(Sales_Orders__c objSalesOrder : lstSalesOrder)
        {
            setSalesOrderId.add(objSalesOrder.Id);
        }
        map<Id , set<String>> mapIdToSalesLineMonth = new map<Id , Set<String>>();
        for(Sales_Order_Lines__c objSalesLine : [Select Id , Sales_Order__c , Month__c from Sales_Order_Lines__c where Sales_Order__c In :setSalesOrderId])
        {
            if(!mapIdToSalesLineMonth.containsKey(objSalesLine.Sales_Order__c))
            {
                mapIdToSalesLineMonth.put(objSalesLine.Sales_Order__c , new set<String>{objSalesLine.Month__c});
            }
            else
            {
                mapIdToSalesLineMonth.get(objSalesLine.Sales_Order__c).add(objSalesLine.Month__c);
            }
        }
        for(Sales_Orders__c objSalesOrder : lstSalesOrder)
        {
            for(String strMonth : lstMonth)
            {
                if(!mapIdToSalesLineMonth.containsKey(objSalesOrder.Id) || !mapIdToSalesLineMonth.get(objSalesOrder.Id).contains(strMonth))
                    lstSalesOrderLItoInsert.add(new Sales_Order_Lines__c(Sales_Order__c = objSalesOrder.Id , Month__c = strMonth));
            }
        }
        if(!lstSalesOrderLItoInsert.isEmpty())
            insert lstSalesOrderLItoInsert;
    } 
 
    global void finish(Database.BatchableContext BC)
    {
     
    }
}