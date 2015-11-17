@isTest

private class GetCareTeamDetailsTest{

    static testmethod void GetCareTeamDetailsTest(){
        
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
        objConsumer.Data_Source_ID__c='4321';
        insert objConsumer;
        
        Affiliation__c objAffl = new Affiliation__c();
        objAffl.Organization__c = objAccount.id;
        objAffl.Provider__c = objcon.id;
        objAffl.Email__c = 'Test@gmail.com';
        insert objAffl;
        
        Active_Care_Relationship__c objACR = new Active_Care_Relationship__c();
        objACR.Organization__c = objAccount.id;
        objACR.Active_Care__c = objAffl.id;
        objACR.Consumer__c = objcon.id;
        objACR.Data_Source__c = 'teset';
        insert objACR;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
    
        req.requestURI = '/services/apexrest/viewcareteam';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        
        req.addParameter('patient_id',string.valueof(objConsumer.Data_Source_ID__c));
        req.addParameter('data_source',string.valueof(objConsumer.Data_Source__c));

        GetCareTeamDetails obj = new GetCareTeamDetails();
        GetCareTeamDetails.GetCareTeam();
    }
    
    static testmethod void GetCareTeamDetailsTestPatientValid(){

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
    
        req.requestURI = '/services/apexrest/viewcareteam';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        
        req.addParameter('patient_id','');
        req.addParameter('data_source','');

        GetCareTeamDetails.GetCareTeam();
    }
}