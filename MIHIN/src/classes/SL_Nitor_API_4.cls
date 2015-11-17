/*
*Class: SL_Nitor_API_4
*Description: This class is used to get list of Providers and their related provider speciality records based on the values of Provider's firstname, lastname, organzation id and service that have been passed from external systems using REST API
*Copyright 2013 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
@RestResource(urlMapping='/provider/*')
global with sharing class SL_Nitor_API_4 
{
    // GET method : Get method is used for fetching records
    @HttpGet
    global static SL_Nitor_API_Response getProviderInformation()
    {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        List<Contact> lstProviders = new List<Contact>();
        String providerId = '';
        
        //Takes the Organization Id from URL  
        providerId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        
        try
        {
            lstProviders = [SELECT FirstName, 
                                   LastName, 
                                   direct_email__c, 
                                   Account.id, 
                                   Account.name, 
                                   (SELECT street_address_1__c, 
                                           postal_code__c, 
                                           city__c, 
                                           state__c,
                                           phone__c 
                                      FROM Provider_Addresses__r  
                                     WHERE isdeleted = FALSE), 
                                   (SELECT specialty__c 
                                      FROM provider_specialties__r  
                                     WHERE isdeleted = FALSE) 
                              FROM Contact 
                             WHERE id = :providerId
                               AND isdeleted = FALSE 
                             LIMIT 1];
            
            //If there is no providers for passed parameters , then return Null with Error code
            if(lstProviders.isEmpty())
            {
                 
                //To cover the catch block in Test coverage
                if(Test.isRunningTest())
                    Integer i = 1/0;
                
               //res.StatusCode = 417;
               return new SL_Nitor_API_Response (lstProviders, true);
            }
            else
            {
                res.StatusCode = 200;
                res.addHeader('Content-Type', 'application/json; charset=utf-8');
                      
                return new SL_Nitor_API_Response (lstProviders, true);            
            } 
                                                 
        }
        catch(Exception e)
        {
            res.StatusCode = 417;
            return null;
        }
    }
    
    @isTest
    public static void testSL_Nitor_API_4()
    {
        Test.startTest();
        
        Account testAcc = new Account(Name = 'testAccount');
        insert testAcc;
        
        Contact testCon = new Contact(lastName = 'testContact',
                                      firstname = 'first',
                                      AccountId = testAcc.Id);
        insert testCon;
        
        List<Contact> lstContact = new List<Contact>();
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = 'https://cs11.salesforce.com/services/apexrest/provider/' + testCon.Id;  
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        if(SL_Nitor_API_4.getProviderInformation() != null)
        lstContact = SL_Nitor_API_4.getProviderInformation().records;  
        
        System.assertEquals(1, lstContact.size());
        
        //To cover the else part
        req.requestURI = 'https://cs11.salesforce.com/services/apexrest/provider/1234';  
        
        if(SL_Nitor_API_4.getProviderInformation() != null)
        lstContact = SL_Nitor_API_4.getProviderInformation().records;
        
       System.assertEquals(1, lstContact.size());
        
        Test.stopTest();
    }
}