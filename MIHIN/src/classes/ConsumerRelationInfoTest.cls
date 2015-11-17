@isTest(seeAlldata=false)

private class ConsumerRelationInfoTest{

    static testmethod void ConsumerRelationInfoTest(){
        
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
        
        Consumer_ID__c  objConsumerID  = new Consumer_ID__c();
        objConsumerID.Consumer__c = objcon.id;
        objConsumerID.Data_Source_ID__c  = '123456';
        insert objConsumerID;
        
        Consumer_Relationship__c objConsumerRel = new Consumer_Relationship__c();
        objConsumerRel.Account_Caretaker__c =true;
        objConsumerRel.Consumer__c = objcon.id;
        objConsumerRel.ICE_Contact__c = true;
        objConsumerRel.Related_Contact__c = objcon.id;
        objConsumerRel.Relationship__c='Child';
        insert objConsumerRel;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
    
        req.requestURI = '/services/apexrest/getconsumerrelation';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        
        req.addParameter('patient_id',string.valueof(objConsumerID.Data_Source_ID__c));
        req.addParameter('icecontact',string.valueof(objConsumerRel.ICE_Contact__c));
        req.addParameter('acccaretaker',string.valueof(objConsumerRel.Account_Caretaker__c));
       
        ConsumerRelationInfo objAfAffiliationDetails = new ConsumerRelationInfo();
        ConsumerRelationInfo.GetConsumerRelationDetails();
    }
    
    static testmethod void AffiliationInfoBAK1TestRecordFnd(){
        
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
        
        Consumer_ID__c  objConsumerID  = new Consumer_ID__c();
        objConsumerID.Consumer__c = objcon.id;
        objConsumerID.Data_Source_ID__c  = '123456';
        insert objConsumerID;
          
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
    
        req.requestURI = '/services/apexrest/getconsumerrelation';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        
        req.addParameter('patient_id',string.valueof(objConsumerID.Data_Source_ID__c));
        req.addParameter('icecontact','true');
        req.addParameter('acccaretaker','');
       
        ConsumerRelationInfo objAfAffiliationDetails = new ConsumerRelationInfo();
        ConsumerRelationInfo.GetConsumerRelationDetails();
    }
    
    static testmethod void AffiliationInfoBAK1TestRecordNotFnd(){
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
    
        req.requestURI = '/services/apexrest/getconsumerrelation';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        
        req.addParameter('patient_id','456789');
        req.addParameter('icecontact','true');
        req.addParameter('acccaretaker','');
       
        ConsumerRelationInfo objAfAffiliationDetails = new ConsumerRelationInfo();
        ConsumerRelationInfo.GetConsumerRelationDetails();
    }
    
    static testmethod void AffiliationDetailsTestPidValidate(){

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
    
        req.requestURI = '/services/apexrest/getconsumerrelation';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        
        req.addParameter('patient_id','');
       
        ConsumerRelationInfo objAfAffiliationDetails = new ConsumerRelationInfo();
        ConsumerRelationInfo.GetConsumerRelationDetails();
    }
    
}