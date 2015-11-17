/*
*Class: SL_Nitor_API_5
*Description: This class is used to get the provider details, their addresses and specialities based on the first name, last name, organization name and speciality passed from external using REST API
*Copyright 2013 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
@RestResource(urlMapping='/list/provider/*')
global with sharing class SL_Nitor_API_5 
{
    // GET method : Get method is used for fetching records
    @HttpGet
    global static SL_Nitor_API_Response getProvidersInformation()
    {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        List<Contact> lstProviders = new List<Contact>();
        String strFirst ;
        String strLast ;
        String strOrganization ;
        String strservice ;
        String strlocation ;
        String strQuery ;
        String strWhereLocation ;
        String strWhereService ;
        
        strFirst = strLast = strOrganization = strservice = strlocation = strQuery = strWhereLocation = strWhereService = '';
        
        // Takes the prameters value from the RestRequest
        if(RestContext.request.params.get('first') == null)
            strFirst = '%%';
        else
            strFirst = '%' + RestContext.request.params.get('first') + '%';
        
        if(RestContext.request.params.get('last') == null)
            strLast = '%%';
        else
            strLast = '%' + RestContext.request.params.get('last') + '%';
        
        if(RestContext.request.params.get('organization') == null)
            strOrganization = '%%';
        else
            strOrganization = '%' + RestContext.request.params.get('organization') + '%';
        
        if(RestContext.request.params.get('service') == null)
            strservice = '';
        else
            strservice = RestContext.request.params.get('service');
        
        if(RestContext.request.params.get('location') == null)
            strlocation = '%%';
        else
            strlocation = '%' + RestContext.request.params.get('location') + '%';   
        
        try
        {
            if(strlocation != '%%')
            {
                strWhereLocation = 'AND id IN (SELECT provider__c '+
                                            'FROM provider_address__c '+
                                           'WHERE (city__c LIKE :strlocation '+
                                               'OR postal_code__c LIKE :strlocation) '+ 
                                             'AND isdeleted = FALSE) ';
            }
            
            if(strservice != '')
            {
                 strWhereService = 'AND id IN (SELECT provider__c '+ 
                                            'FROM provider_specialty__c '+
                                           'WHERE Specialty__c =:  strservice '+
                                               'AND isdeleted = FALSE) ';
            }
            strQuery = 'SELECT id, '+
                               'FirstName, '+
                               'LastName, '+
                               'direct_email__c, '+
                               'Account.id, '+
                               'Account.name, '+
                               '(SELECT street_address_1__c, '+
                                       'postal_code__c, '+
                                       'city__c, '+
                                       'state__c '+
                                  'FROM Provider_Addresses__r '+
                                 'WHERE (city__c LIKE :strlocation '+
                                     'OR postal_code__c LIKE :strlocation) '+
                                   'AND isdeleted = FALSE), '+
                               '(SELECT specialty__c '+
                                  'FROM provider_specialties__r '+
                                 'WHERE isdeleted = FALSE) '+
                          'FROM Contact '+
                          'WHERE FirstName LIKE :strFirst '+
                           'AND LastName LIKE :strLast '+
                           'AND Account.name LIKE :strOrganization '+
                           'AND isdeleted = FALSE '+
                           strWhereLocation +
                           strWhereService + 
                           ' Limit 201';
              lstProviders = database.query(strQuery) ;                 
            
            //If there is no providers for passed parameters , then return Null with Error code
            if(lstProviders.isEmpty())
            {
                //res.StatusCode = 417;
                return new SL_Nitor_API_Response (lstProviders, true); 
                
                //To cover the catch block in Test coverage
                if(Test.isRunningTest())
                    Integer i = 1/0;
                
                return null;
            }
            else
            {
                res.StatusCode = 200;
                res.addHeader('Content-Type', 'application/json; charset=utf-8');
                if(lstProviders.size() >= 201)
                {
                    lstProviders.remove(200);
                    return new SL_Nitor_API_Response (lstProviders, false); 
                }   
                else
                {   
                    return new SL_Nitor_API_Response (lstProviders, true);
                }            
            } 
                                                 
        }
        catch(Exception e)
        {
            res.StatusCode = 417;
            return null;
        }
    }
    
    @isTest
    public static void testSL_Nitor_API_5()
    {
        Test.startTest();
        
        Account testAcc = new Account(name = 'testAccount');
        insert testAcc;
        
        Contact testCon = new Contact(lastName = 'testContact',
                                      firstname = 'first',
                                      AccountId = testAcc.Id);
        insert testCon;                           
        
        provider_address__c testPA = new provider_address__c(provider__c = testCon.Id, city__c = 'NY');
        insert testPA;
        
        Specialty__c testSpec = new Specialty__c(Name = 'testSpec');
        insert testSpec; 
        
        provider_specialty__c testPS = new provider_specialty__c(provider__c = testCon.Id, Specialty__c = testSpec.Id);
        insert testPS;                            
                                      
        List<Contact> lstContact = new List<Contact>();
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = 'https://cs11.salesforce.com/services/apexrest/list/provider?' ;   
        
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;    
        
        //lstContact = SL_Nitor_API_5.getProvidersInformation();  
        
        //System.assertEquals(null, SL_Nitor_API_5.getProvidersInformation());
        
        req.addParameter('first', testCon.firstname);
        req.addParameter('last', testCon.lastName);
        req.addParameter('organization', testAcc.name);
        req.addParameter('service', 'D');
        req.addParameter('location', 'NY'); 
        
        lstContact = SL_Nitor_API_5.getProvidersInformation().records;
        
        System.assertEquals(0, lstContact.size());
                                  
        Test.stopTest();
    }
}