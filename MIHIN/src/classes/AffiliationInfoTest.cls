@isTest(seeAlldata=false)

private class AffiliationInfoTest{
    static testmethod void AffiliationInfoTest(){
        
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
        
        Electronic_Service__c objES = new Electronic_Service__c();
        objES.Name = 'Test';
        objES.Type__c = 'Test';
        objES.Protocol__c = 'Test';
        objES.Payload__c = 'Test';
        objES.Address__c = 'Test';
        insert objES;
        
        Consumer_Affiliation__c objCA = new Consumer_Affiliation__c();
        objCA.Consumer__c = objcon.id;
        objCA.Organization__c = objAccount.id;
        insert objCA;
        
        Consumer_Affiliation_Service__c objCAS = new Consumer_Affiliation_Service__c();
        objCAS.Electronic_Service__c = objES.id;
        objCAS.Consumer_Affiliation__c = objCA.id;
        insert objCAS ;
        
        Loinc_Code_Profile__c objLonicCode = new Loinc_Code_Profile__c();
        objLonicCode.Content_Type__c = 'Any content';
        objLonicCode.Version__c = '3.0';
        objLonicCode.Value__c = 'tesrt';
        insert objLonicCode;
        
        Content_Profile__c objCP = new Content_Profile__c();
        objCP.Name = 'Test';
        objCP.Electronic_Service__c = objES.id;
        objCP.Organization__c = objAccount.id;
        objCP.Loinc_Code_Profile__c = objLonicCode.id;
        insert objCP;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
    
        req.requestURI = '/services/apexrest/Affiliations';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        
        req.addParameter('patient_id',string.valueof(objConsumer.Data_Source_ID__c));
        req.addParameter('affinity_domain',string.valueof(objCAS.id));
        req.addParameter('loinc_code',string.valueof(objCP.id));
        
        AffiliationInfo objAI = new AffiliationInfo();
        AffiliationInfo.GetPatientInfo();
    }
    
    static testmethod void AffiliationInfoTest1(){
        
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
        
        Electronic_Service__c objES = new Electronic_Service__c();
        objES.Name = 'Test';
        objES.Type__c = 'Test';
        objES.Protocol__c = 'Test';
        objES.Payload__c = 'Test';
        objES.Address__c = 'Test';
        insert objES;
        
        Consumer_Affiliation__c objCA = new Consumer_Affiliation__c();
        objCA.Consumer__c = objcon.id;
        objCA.Organization__c = objAccount.id;
        insert objCA;
        
        Consumer_Affiliation_Service__c objCAS = new Consumer_Affiliation_Service__c();
        objCAS.Electronic_Service__c = objES.id;
        objCAS.Consumer_Affiliation__c = objCA.id;
        insert objCAS ;
        
        Content_Profile__c objCP = new Content_Profile__c();
        objCP.Name = 'Test';
        objCP.Electronic_Service__c = objES.id;
        objCP.Organization__c = objAccount.id;
        insert objCP;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
    
        req.requestURI = '/services/apexrest/Affiliations';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        
        req.addParameter('patient_id','');
        req.addParameter('affinity_domain','');
        req.addParameter('loinc_code','');
        
        AffiliationInfo objAI = new AffiliationInfo();
        AffiliationInfo.GetPatientInfo();
    }
    
    static testmethod void AffiliationInfoTest2(){
        
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
        objConsumer.Consumer_ID_Affinity_Domain__c = '4321';
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
        
        Electronic_Service__c objES = new Electronic_Service__c();
        objES.Name = 'Test';
        objES.Type__c = 'Test';
        objES.Protocol__c = 'Test';
        objES.Payload__c = 'Test';
        objES.Address__c = 'Test';
        objES.Service_Type__c = 'XCPD';
        insert objES;
        
        Consumer_Affiliation__c objCA = new Consumer_Affiliation__c();
        objCA.Consumer__c = objcon.id;
        objCA.Organization__c = objAccount.id;
        objCA.Affinity_Domain__c = 'Test';
        objCA.Unique_ID__c = 'TSet';
        objCA.Affinity_Domain__c = 'TEStet';
        insert objCA;
        
        Consumer_Affiliation_Service__c objCAS = new Consumer_Affiliation_Service__c();
        objCAS.Electronic_Service__c = objES.id;
        objCAS.Consumer_Affiliation__c = objCA.id;
        insert objCAS ;
        
        Content_Profile__c objCP = new Content_Profile__c();
        objCP.Name = 'Test';
        objCP.Electronic_Service__c = objES.id;
        objCP.Organization__c = objAccount.id;
        insert objCP;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
    
        req.requestURI = '/services/apexrest/Affiliations';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        
        req.addParameter('patient_id',string.valueof(objConsumer.Data_Source_ID__c));
        req.addParameter('affinity_domain',string.valueof(objCA.Affinity_Domain__c));
        req.addParameter('loinc_code','122');
        req.addParameter('consumer_id_affinity_domain','4321');
        
        AffiliationInfo objAI = new AffiliationInfo();
        AffiliationInfo.GetPatientInfo();
    }
    
    static testmethod void AffiliationInfoTest3(){
        
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
        objConsumer.Consumer_ID_Affinity_Domain__c = '4321';
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
        
        Electronic_Service__c objES = new Electronic_Service__c();
        objES.Name = 'Test';
        objES.Type__c = 'Test';
        objES.Protocol__c = 'Test';
        objES.Payload__c = 'Test';
        objES.Address__c = 'Test';
        objES.Service_Type__c = 'XCPD';
        insert objES;
        
        Consumer_Affiliation__c objCA = new Consumer_Affiliation__c();
        objCA.Consumer__c = objcon.id;
        objCA.Organization__c = objAccount.id;
        objCA.Affinity_Domain__c = 'Test';
        objCA.Unique_ID__c = 'TSet';
        objCA.Affinity_Domain__c = 'TEStet';
        insert objCA;
        
        Consumer_Affiliation_Service__c objCAS = new Consumer_Affiliation_Service__c();
        objCAS.Electronic_Service__c = objES.id;
        objCAS.Consumer_Affiliation__c = objCA.id;
        insert objCAS ;
        
        Loinc_Code_Profile__c objLonicCode = new Loinc_Code_Profile__c();
        objLonicCode.Content_Type__c = 'Any content';
        objLonicCode.Version__c = '3.0';
        objLonicCode.Value__c = 'tesrt';
        objLonicCode.Name = '111';
        insert objLonicCode;

        Content_Profile__c objCP = new Content_Profile__c();
        objCP.Name = 'Test';
        objCP.Electronic_Service__c = objES.id;
        objCP.Organization__c = objAccount.id;
        objCP.Loinc_Code_Profile__c = objLonicCode.id;
        insert objCP;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
    
        req.requestURI = '/services/apexrest/Affiliations';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        
        req.addParameter('patient_id',string.valueof(objConsumer.Data_Source_ID__c));
        req.addParameter('affinity_domain',string.valueof(objCA.Affinity_Domain__c));
        req.addParameter('loinc_code','122');
        req.addParameter('consumer_id_affinity_domain','4321');
        
        List<Content_Profile__c> cp = new List<Content_Profile__c>();
        cp.add(objCP);
        
        AffiliationInfo objAI = new AffiliationInfo();
        AffiliationInfo.wrpca objwrp1 = new AffiliationInfo.wrpca();
        objwrp1.lstca = objCA;
        objwrp1.strLoinc  = '122';
        List<AffiliationInfo.wrpca> lstwrp1 = new List<AffiliationInfo.wrpca>();
        lstwrp1.add(objwrp1);
        
        AffiliationInfo.WrapAffContProfile objwrp = new AffiliationInfo.WrapAffContProfile();
        objwrp.cp = cp;
        objwrp.ca = lstwrp1;
        AffiliationInfo.GetPatientInfo();
        
        req.addParameter('loinc_code','122~111');
        AffiliationInfo.GetPatientInfo();
    }
}