@isTest(seeAlldata=false)

private class DeleteConsumerRelationshipTest{

    static testmethod void DeleteConsumerRelationshipTest(){
        
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
        
        string strContact = objcon.id;
        Consumer_Relationship__c objConsumerRel = new Consumer_Relationship__c();
        objConsumerRel.Account_Caretaker__c = true;
        objConsumerRel.Consumer__c = strContact;
        objConsumerRel.ICE_Contact__c = false;
        objConsumerRel.Related_Contact__c = strContact;
        objConsumerRel.Relationship__c = 'Child';
        insert objConsumerRel;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
    
        req.requestURI = '/services/apexrest/deleteconsumerrelationship';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        req.addParameter('id',string.valueof(objConsumerRel.id));

        DeleteConsumerRelationship.DeleteCRRecords();
     }
     
     static testmethod void DeleteConsumerRelationshipIdNull(){
     
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/deleteconsumerrelationship';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        req.addParameter('id','');
        
        DeleteConsumerRelationship.DeleteCRRecords();
    }
    
    static testmethod void DeleteConsumerRelationshipCntZero(){
    
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/deleteconsumerrelationship';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        req.addParameter('id','123465');
        
        DeleteConsumerRelationship.DeleteCRRecords();
    }
}