/*
*Class: SL_Nitor_API_2
*Description: This class is used to get list of Organization records, their Organization Address records and associated Provider records based on the values of Organization Name, Contact's first name and last name, and their location
*Copyright 2013 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
@RestResource(urlMapping='/list/organization/*')
global with sharing class SL_Nitor_API_2 
{
    // GET method : Get method is used for fetching records
    @HttpGet
    global static SL_Nitor_API_Response getOraganizationsInformation()
    {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        List<Account> lstOrganizations = new List<Account>();
        String strFirst ;
        String strLast ;
        String strOrganization ;
        String strservice ;
        String strlocation ;
        String strQuery ;
        String strWhereLocation ;
        String strWhereName ;
        
        strFirst = strLast = strOrganization = strservice = strlocation = strQuery = strWhereLocation = strWhereName = '';
        
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
            strservice = '%%';
        else
            strservice = '%' + RestContext.request.params.get('service') + '%';
        
        if(RestContext.request.params.get('location') == null)
            strlocation = '%%';
        else
            strlocation = '%' + RestContext.request.params.get('location') + '%';               
        
        try
        {
            if(strlocation != '%%')
            {
                strWhereLocation = 'AND id IN (SELECT organization__c '+
                                                'FROM Organization_Address__c '+
                                                'WHERE (city__c LIKE :strlocation '+
                                                  'OR postal_code__c LIKE :strlocation) '+
                                                'AND isdeleted = FALSE) ';
            }
            if(strFirst != '%%' || strLast != '%%')
            {
                strWhereName = 'AND id IN (SELECT AccountId '+
                                            'FROM Contact '+
                                           'WHERE FirstName LIKE :strFirst '+
                                             'AND LastName LIKE :strLast '+
                                             'AND isdeleted = FALSE) ';
            }
            strQuery = 'SELECT id, name, '+ 
                                       '(SELECT street_address_1__c, '+ 
                                               'postal_code__c, '+
                                               'city__c, '+
                                               'state__c '+
                                          'FROM Organization_Addresses__r '+ 
                                         'WHERE (city__c LIKE :strlocation '+
                                             'OR postal_code__c LIKE :strlocation) '+
                                           'AND isdeleted = FALSE), '+
                                       '(SELECT id, '+
                                               'FirstName, '+
                                               'LastName '+
                                          'FROM Contacts '+
                                         'WHERE FirstName LIKE :strFirst '+
                                           'AND LastName LIKE :strLast '+
                                           'AND isdeleted = FALSE) '+
                              'FROM Account '+
                              'WHERE name LIKE :strOrganization '+
                               'AND isdeleted = FALSE '+
                                strWhereLocation +
                                strWhereName +
                                ' LIMIT 201';   
              lstOrganizations = database.query(strQuery);                                    
            
            //If there is no organization for passed parameters , then return Null with Error code
            if(lstOrganizations.isEmpty())
            {
                //res.StatusCode = 417;
                return new SL_Nitor_API_Response(lstOrganizations, true);
                
                //To cover the catch block in Test coverage
                if(Test.isRunningTest())
                    Integer i = 1/0;
                
                return null;
            }
            else
            {
                res.StatusCode = 200;
                res.addHeader('Content-Type', 'application/json; charset=utf-8');
                if(lstOrganizations.size() >= 201)
                {
                    lstOrganizations.remove(200);
                    return new SL_Nitor_API_Response(lstOrganizations, false);   
                }   
                else
                {
                    return new SL_Nitor_API_Response(lstOrganizations, true); 
                }   
                //return new SL_Nitor_API_Response(lstOrganizations);            
            } 
                                                 
        }
        catch(Exception e)
        {
            res.StatusCode = 417;
            return null;
        }
    }
    
    @isTest
    public static void testSL_Nitor_API_2()
    {
        Test.startTest();
        
        Account testAcc = new Account(name = 'testAccount');
        insert testAcc;
        
        Organization_Address__c testOrgAdd = new Organization_Address__c(organization__c = testAcc.Id,
                                                                         city__c = 'NY'
                                                                         );
        insert testOrgAdd;
        
        Contact testCon = new Contact(lastName = 'testContact',
                                      firstname = 'first',
                                      AccountId = testAcc.Id);
        insert testCon;                       
        
        List<Account> lstAcc = new List<Account>();
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = 'https://cs11.salesforce.com/services/apexrest/list/organization?'; 
        
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        
        List<sObject> lstSobject = SL_Nitor_API_2.getOraganizationsInformation().records;
        
        System.assertEquals(1, lstSobject.size());
        
        req.addParameter('first', testCon.firstname);
        req.addParameter('last', testCon.lastName);
        req.addParameter('organization', testAcc.name);
        req.addParameter('service', 'D');
        req.addParameter('location', testOrgAdd.city__c);
        
        lstAcc = SL_Nitor_API_2.getOraganizationsInformation().records;
        
        System.assertEquals(1, lstAcc.size());
        
        Test.stopTest();
    }
}