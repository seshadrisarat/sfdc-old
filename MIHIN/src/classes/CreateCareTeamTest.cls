@isTest

private class CreateCareTeamTest{

    static testmethod void CreateCareTeamTest(){
        
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
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
    
        req.requestURI = '/services/apexrest/createcareteam';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        
        req.addParameter('patientid',string.valueof(objConsumer.Data_Source_ID__c));
        req.addParameter('activecareadmin',string.valueof(objAccount.id));
        req.addParameter('consumer',string.valueof(objcon.id));
        req.addParameter('activecareaff',string.valueof(objAffl.id));
        
        CreateCareTeam obj = new CreateCareTeam();
        CreateCareTeam.InsertCareTeam();
    }
    
    static testmethod void CreateCareTeamTestPatientID(){
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
    
        req.requestURI = '/services/apexrest/createcareteam';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        
        req.addParameter('patientid','');
        
        CreateCareTeam.InsertCareTeam();
    }
    
    static testmethod void CreateCareTeamTestAcvtAdmin(){
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
    
        req.requestURI = '/services/apexrest/createcareteam';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        
        req.addParameter('patientid','4321');
        req.addParameter('activecareadmin','');
        
        CreateCareTeam.InsertCareTeam();
    }
    
    static testmethod void CreateCareTeamTestAcvtAdminCons(){
    
         List<recordtype> lstAccrecordtype= new List<recordtype>([select id,developername from 
                                                 recordtype where developername = 'MIHIN_Organizations']);
                                                             
        account objAccount = new Account();
        objAccount.Name = 'TestAccountName';
        objAccount.Recordtypeid = lstAccrecordtype[0].id;
        insert objAccount; 
                                                                    
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
    
        req.requestURI = '/services/apexrest/createcareteam';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        
        req.addParameter('patientid','4321');
        req.addParameter('activecareadmin',string.valueof(objAccount.id));
        req.addParameter('consumer','');
        
        CreateCareTeam.InsertCareTeam();
    }
    
    static testmethod void CreateCareTeamTestActCareAff(){
    
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
    
        req.requestURI = '/services/apexrest/createcareteam';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        
        req.addParameter('patientid',string.valueof(objConsumer.Data_Source_ID__c));
        req.addParameter('activecareadmin',string.valueof(objAccount.id));
        req.addParameter('consumer',string.valueof(objcon.id));
        req.addParameter('activecareaff','');
        
        CreateCareTeam.InsertCareTeam();
    }
    
    static testmethod void CreateCareTeamTestAccNull(){
    
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
    
        req.requestURI = '/services/apexrest/createcareteam';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        
        req.addParameter('patientid','4321');
        req.addParameter('activecareadmin','123');
        
        CreateCareTeam.InsertCareTeam();
    }
    
    static testmethod void CreateCareTeamTestContactNull(){

        List<recordtype> lstAccrecordtype= new List<recordtype>([select id,developername from 
                                                 recordtype where developername = 'MIHIN_Organizations']);
                                                             
        account objAccount = new Account();
        objAccount.Name = 'TestAccountName';
        objAccount.Recordtypeid = lstAccrecordtype[0].id;
        insert objAccount;                                                             
    
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
    
        req.requestURI = '/services/apexrest/createcareteam';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        
        req.addParameter('patientid','43211');
        req.addParameter('activecareadmin',string.valueof(objAccount.id));
        req.addParameter('consumer','859562');
       
        CreateCareTeam.InsertCareTeam();
    }
    
    static testmethod void CreateCareTeamTestAffNull(){
    
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
       
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
    
        req.requestURI = '/services/apexrest/createcareteam';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        
        req.addParameter('patientid','4321');
        req.addParameter('activecareadmin',string.valueof(objAccount.id));
        req.addParameter('consumer',string.valueof(objcon.id));
        req.addParameter('activecareaff','11111');
        
        CreateCareTeam.InsertCareTeam();
    }
}