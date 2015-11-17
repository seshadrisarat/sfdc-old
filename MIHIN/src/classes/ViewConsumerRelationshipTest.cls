@isTest(seeAlldata=false)

private class ViewConsumerRelationshipTest{

    static testmethod void ViewConsumerRelationshipTest(){
        
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
        objcon.Email = 'Test@gmail.com';
        objcon.MailingStreet = 'TestMailingStreet';
        objcon.MailingCity = 'TestMailingCity';
        objcon.MailingState = 'TestMailingState';
        objcon.MailingCountry = 'TestMailingCntry';
        objcon.MailingPostalCode = '123456';
        insert objcon;
       
        Consumer_Relationship__c objConsumerRel = new Consumer_Relationship__c();
        objConsumerRel.Account_Caretaker__c = true;
        objConsumerRel.Consumer__c = objcon.id;
        objConsumerRel.ICE_Contact__c = true;
        objConsumerRel.Related_Contact__c = objcon.id;
        objConsumerRel.Relationship__c = 'Child';
        insert objConsumerRel;
        
        Consumer_ID__c objConsumer = new Consumer_ID__c();
        objConsumer.Active__c = true;
        objConsumer.Consumer__c =objcon.id;
        objConsumer.Data_Source__c ='123456';
        objConsumer.Data_Source_ID__c='987654321';
        insert objConsumer;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
    
        req.requestURI = '/services/apexrest/ViewConsumerRelationship';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        
        req.addParameter('patientid',string.valueof(objConsumer.Data_Source_ID__c));
        req.addParameter('iceflag',string.valueof(objConsumerRel.ICE_Contact__c));
        
        ViewConsumerRelationship obj = new ViewConsumerRelationship();
        ViewConsumerRelationship.GetICEInfo();
     }
     
     static testmethod void ViewConsumerRelationshipTestPatinetValidate(){
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
    
        req.requestURI = '/services/apexrest/ViewConsumerRelationship';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        
        req.addParameter('patientid','');
        req.addParameter('iceflag','');
        
        ViewConsumerRelationship.GetICEInfo();
     }
     
      static testmethod void ViewConsumerRelationshipTestIceflgValidate(){
        
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
        insert objcon;
       
        Consumer_Relationship__c objConsumerRel = new Consumer_Relationship__c();
        objConsumerRel.Account_Caretaker__c = false;
        objConsumerRel.Consumer__c = objcon.id;
        objConsumerRel.ICE_Contact__c = false;
        objConsumerRel.Related_Contact__c = objcon.id;
        objConsumerRel.Relationship__c = null;
        insert objConsumerRel;
        
        Consumer_ID__c objConsumer = new Consumer_ID__c();
        objConsumer.Active__c = true;
        objConsumer.Consumer__c =objcon.id;
        objConsumer.Data_Source__c ='123456';
        objConsumer.Data_Source_ID__c='987654321';
        insert objConsumer;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
    
        req.requestURI = '/services/apexrest/ViewConsumerRelationship';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        
        req.addParameter('patientid','999998');
        req.addParameter('iceflag','');
        
        ViewConsumerRelationship.GetICEInfo();
     }

     
}