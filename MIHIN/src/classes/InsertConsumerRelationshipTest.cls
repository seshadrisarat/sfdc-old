@isTest

private class InsertConsumerRelationshipTest{

    static testmethod void InsertConsumerRelationshipTest(){
        
         List<recordtype> lstrecordtype= new List<recordtype>([select id,developername from 
                                                             recordtype where developername = 'Patient']);
        
         List<recordtype> lstAccrecordtype= new List<recordtype>([select id,developername from 
                                                 recordtype where developername = 'MIHIN_Organizations']);
                                                             
        account objAccount = new Account();
        objAccount.Name = 'TestAccountName';
        objAccount.Recordtypeid = lstAccrecordtype[0].id;
        insert objAccount;                                                             
        
        contact objcon = new contact();
        objcon.Firstname='TestFName';
        objcon.LastName='TestLName';
        objcon.Gender__c ='Male';
        objcon.Accountid = objAccount.id;
        objcon.recordtypeid = lstrecordtype[0].id;
        insert objcon;
        
        Consumer_ID__c objConsumer = new Consumer_ID__c();
        objConsumer.Active__c = true;
        objConsumer.Consumer__c =objcon.id;
        objConsumer.Data_Source__c ='123456';
        objConsumer.Data_Source_ID__c='987654321';
        insert objConsumer;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
    
        req.requestURI = '/services/apexrest/createconsumerrelationship';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        
        req.addParameter('patient_id',string.valueof(objConsumer.Data_Source_ID__c));
        req.addParameter('consumer',string.valueof(objcon.id));
        req.addParameter('icecontact','true');
        req.addParameter('acccaretaker','true');
        req.addParameter('relationship','Child');
        
        InsertConsumerRelationship obj = new InsertConsumerRelationship();
        InsertConsumerRelationship.InsertCRRecords();
    }
    
    static testmethod void InsertConsumerRelationshipTestPatinetIDValidate(){
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
    
        req.requestURI = '/services/apexrest/createconsumerrelationship';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        
        req.addParameter('patient_id','');
        req.addParameter('consumer','12345');
        
        InsertConsumerRelationship.InsertCRRecords();
   }
   
   static testmethod void InsertConsumerRelationshipTestConsValid(){
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
    
        req.requestURI = '/services/apexrest/createconsumerrelationship';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        
        req.addParameter('patient_id','12345');
        req.addParameter('consumer','');
        
        InsertConsumerRelationship.InsertCRRecords();
   }
   
   static testmethod void InsertConsumerRelationshipTestVerifyPatient(){
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
    
        req.requestURI = '/services/apexrest/createconsumerrelationship';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        
        req.addParameter('patient_id','4321');
        req.addParameter('consumer','1566');
        
        InsertConsumerRelationship.InsertCRRecords();
   }
   
   static testmethod void InsertConsumerRelationshipValidateContact(){
        
         List<recordtype> lstrecordtype= new List<recordtype>([select id,developername from 
                                                             recordtype where developername = 'Patient']);
        
         List<recordtype> lstAccrecordtype= new List<recordtype>([select id,developername from 
                                                 recordtype where developername = 'MIHIN_Organizations']);
                                                             
        account objAccount = new Account();
        objAccount.Name = 'TestAccountName';
        objAccount.Recordtypeid = lstAccrecordtype[0].id;
        insert objAccount;                                                             
        
        contact objcon = new contact();
        objcon.Firstname='TestFName';
        objcon.LastName='TestLName';
        objcon.Gender__c ='Male';
        objcon.Accountid = objAccount.id;
        objcon.recordtypeid = lstrecordtype[0].id;
        insert objcon;
        
        Consumer_ID__c objConsumer = new Consumer_ID__c();
        objConsumer.Active__c = true;
        objConsumer.Consumer__c =objcon.id;
        objConsumer.Data_Source__c ='123456';
        objConsumer.Data_Source_ID__c='987654321';
        insert objConsumer;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
    
        req.requestURI = '/services/apexrest/createconsumerrelationship';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        
        req.addParameter('patient_id',string.valueof(objConsumer.Data_Source_ID__c));
        req.addParameter('consumer','123456');
        
        InsertConsumerRelationship.InsertCRRecords();
    }

}