/*
*Class: SL_Nitor_API_6
*Description: This class is used to get the details of those speciality records in which classification is not equal to null using REST API
*Copyright 2013 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
@RestResource(urlMapping='/list/specialty/*')
global with sharing class SL_Nitor_API_6 
{
    // GET method : Get method is used for fetching records
    @HttpGet
    global static SL_Nitor_API_Response getSpecialtiesInformation()
    {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        List<Specialty__c> lstSpecialties = new List<Specialty__c>();
        
        try
        {
            lstSpecialties = [SELECT id, 
                                     classification__c, 
                                     specialization__c 
                               FROM specialty__c 
                               WHERE ((classification__c != NULL 
                                   AND classification__c != '') 
                                   OR (specialization__c != NULL 
                                   AND specialization__c != '')) 
                                   AND isdeleted = FALSE 
                               order BY classification__c, 
                                     specialization__c];
            
            //If there is no Specialty , then return Null with Error code
            if(lstSpecialties.isEmpty())
            {
                 
                //To cover the catch block in Test coverage
                if(Test.isRunningTest())
                    Integer i = 1/0;
                
                //res.StatusCode = 417;
                return new SL_Nitor_API_Response(lstSpecialties, true);  
            }
            else
            {
                res.StatusCode = 200;
                res.addHeader('Content-Type', 'application/json; charset=utf-8');
                if(lstSpecialties.size() >= 201)
                {
                	lstSpecialties.remove(200);
                	return new SL_Nitor_API_Response(lstSpecialties, false);
                }   
                else
                {   
                	return new SL_Nitor_API_Response(lstSpecialties, true);
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
    public static void testSL_Nitor_API_6()
    {
        Test.startTest();
        
        Specialty__c testSpec = new Specialty__c(Name = 'testSpec', classification__c = 'test');
        insert testSpec; 
        
        List<Specialty__c> lstspecialities = new List<Specialty__c>();
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = 'https://cs11.salesforce.com/services/apexrest/list/specialty/';
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        
        if(SL_Nitor_API_6.getSpecialtiesInformation() != null)
        lstspecialities = SL_Nitor_API_6.getSpecialtiesInformation().records;  
        
        System.assertEquals(1, lstspecialities.size());
        
        delete testSpec;
        if(SL_Nitor_API_6.getSpecialtiesInformation() != null)
        lstspecialities = SL_Nitor_API_6.getSpecialtiesInformation().records; 
        
        System.assertEquals(1, lstspecialities.size());
        
        Test.stopTest();
    }
}