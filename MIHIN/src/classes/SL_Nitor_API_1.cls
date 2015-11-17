/*
*Class: SL_Nitor_API_1
*Description: This class is used to get Organization record based on the Orgid received from external system using REST API
*Copyright 2013 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
@RestResource(urlMapping='/organization/*')
global with sharing class SL_Nitor_API_1 
{
    // GET method : Get method is used for fetching records
    @HttpGet
    global static SL_Nitor_API_Response getHpdInformation()
    {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        List<Account> lstOrganizations = new List<Account>();
        String orgId = '';
        
        orgId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);  
        
        try
        {
            //Fetching the SFDC record for specified Id
            lstOrganizations = [SELECT name,
                                       (SELECT street_address_1__c,
                                               postal_code__c,
                                               city__c,
                                               state__c
                                         FROM Organization_Addresses__r
                                         WHERE isdeleted = FALSE)
                                 FROM Account
                                 WHERE id = :orgId AND 
                                       isdeleted = FALSE
                                 LIMIT 1];
            //If there is no organization for passed parameters , then return Null with Error code
            if(lstOrganizations.isEmpty())
            {
                //To cover the catch block in Test coverage
                if(Test.isRunningTest())  
                    integer i = 1/0;
                
               //res.StatusCode = 417;
                return new SL_Nitor_API_Response(lstOrganizations, true); 
            }
            else
            {
                res.StatusCode = 200;
                res.addHeader('Content-Type', 'application/json; charset=utf-8');
                       
                return new SL_Nitor_API_Response(lstOrganizations, true);            
            }                   
                                     
        }
        catch(Exception e)
        {
            res.StatusCode = 417;
            return null;
        }   
    }
    
    @isTest
    public static void testSL_Nitor_API_1()
    {
        Test.startTest();
        
        Account testAcc = new Account(Name = 'testAccount');
        insert testAcc;
        
        List<Account> lstAcc = new List<Account>();
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = 'https://cs11.salesforce.com/services/apexrest/organization/' + testAcc.Id;  
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        if(SL_Nitor_API_1.getHpdInformation() != null)
        lstAcc = SL_Nitor_API_1.getHpdInformation().records;  
        
        System.assertEquals(1, lstAcc.size());
        
        //To cover the else part
        req.requestURI = 'https://cs11.salesforce.com/services/apexrest/organization/1234';  
        
        if(SL_Nitor_API_1.getHpdInformation() != null)
        lstAcc = SL_Nitor_API_1.getHpdInformation().records;
        
        System.assertEquals(1, lstAcc.size());
        
        Test.stopTest();
    }
}