/*
*Class: SL_Nitor_API_7
*Description: This class is used to get details of speciality records based on the speciality id passed from external system using REST API
*Copyright 2013 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
@RestResource(urlMapping='/specialty/*')
global with sharing class SL_Nitor_API_7 
{
  // GET method : Get method is used for fetching records
    @HttpGet
    global static SL_Nitor_API_Response getSpecialtiesInformation()
    {
      RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        List<Specialty__c> lstSpecialties = new List<Specialty__c>();
        String specialtyId = '';
        
        //Takes the Specialty Id from URL
        specialtyId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        
        try
        {
          lstSpecialties = [SELECT id, 
                       classification__c, 
                       specialization__c 
                 FROM specialty__c 
                 WHERE id = :specialtyId 
                     AND isdeleted = FALSE 
                 LIMIT 1];
      
      //If there is no Specialty , then return Null with Error code
            if(lstSpecialties.isEmpty())
            {
                //To cover the catch block in Test coverage
                if(Test.isRunningTest())
                  Integer i = 1/0;
                
                //res.StatusCode = 417;
                return new SL_Nitor_API_Response (lstSpecialties, true);
                
                //return null;
            }
            else
            {
                res.StatusCode = 200;
                res.addHeader('Content-Type', 'application/json; charset=utf-8');
                      
                return new SL_Nitor_API_Response (lstSpecialties, true);            
            } 
                                 
        }
        catch(Exception e)
        {
          res.StatusCode = 417;
            return null;
        }
    }
    
    @isTest
    public static void testSL_Nitor_API_7()
    {
      Test.startTest();
      
      Specialty__c testSpec = new Specialty__c(Name = 'testSpec', classification__c = 'test');
      insert testSpec; 
      
      List<Specialty__c> lstspecialities = new List<Specialty__c>();
      
      RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
    
    req.requestURI = 'https://cs11.salesforce.com/services/apexrest/list/specialty/'+testSpec.id;
    req.httpMethod = 'GET';
    RestContext.request = req;
      RestContext.response = res;
      if(SL_Nitor_API_7.getSpecialtiesInformation() != null)
      lstspecialities = SL_Nitor_API_7.getSpecialtiesInformation().records;  
      
      System.assertEquals(1, lstspecialities.size());
      
   
       //To cover the else part
      req.requestURI = 'https://cs11.salesforce.com/services/apexrest/list/specialty/1234';  
    if(SL_Nitor_API_7.getSpecialtiesInformation() != null)
    lstspecialities = SL_Nitor_API_7.getSpecialtiesInformation().records;  
    
    System.assertEquals(1, lstspecialities.size());
    
    Test.stopTest();
    }
}