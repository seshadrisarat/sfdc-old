@isTest(seeAlldata=false)

private class AddNewConsumerContactTest{

    static testmethod void AddNewConsumerContactTest(){
        
         List<recordtype> lstrecordtype= new List<recordtype>([select id,developername from 
                                                             recordtype where developername = 'Patient']);
        
         List<recordtype> lstAccrecordtype= new List<recordtype>([select id,developername from 
                                                 recordtype where developername = 'MIHIN_Organizations']);
        
        AddNewConsumerContact obj = new AddNewConsumerContact();                                                     
        
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
                
        List<contact> lstCTemp = new List<contact>([select id,Name,firstname,lastname,Birthdate,Gender__c,AccountID,Account.name,Patient_ID__c,SSN_Last_4__c,Phone,
                MailingCity,MailingState,MailingCountry,MailingStreet,MailingPostalCode,MobilePhone,Email,MailingAddress from contact where id =: strContact limit 1]);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
    
        req.requestURI = '/services/apexrest/AddNewConsumerContact';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        req.addParameter('firstname','TestFirstName');
        req.addParameter('lastname','TestLastName');
        req.addParameter('gender','Male');
        req.addParameter('email','test@gmail.com');
        req.addParameter('birthdate',string.valueof(system.today()));
        
        req.addParameter('orgname',objAccount.id);
        req.addParameter('patientid','4321');
        req.addParameter('ssn','123456');
        req.addParameter('phone','123456');
        req.addParameter('mobile','1323456789');
        
        req.addParameter('mailingstreet','teststreet');
        req.addParameter('mailingcity','testCity');
        req.addParameter('mailingstate','testState');
        req.addParameter('mailingcountry','testCountry');
        req.addParameter('mailingpostalcode','123456');
        
        String jsonResponse = '';
        String strFname = req.params.get('firstname');
        String strLname = req.params.get('lastname');
        String strEmail = req.params.get('email');
        string strGender = req.params.get('gender');
        String strPhone = req.params.get('phone');
        string strSSN = req.params.get('ssn');
        string strDOB = req.params.get('birthdate');
        string strMAddStreet = req.params.get('mailingstreet');
        string strMAddCity = req.params.get('mailingcity');
        string strMAddState = req.params.get('mailingstate');
        string strMAddCountry = req.params.get('mailingcountry');
        string strMAddPostalCode = req.params.get('mailingpostalcode'); 
        //string strMAddress = req.params.get('gender');
        string strPatientID = req.params.get('patientid');
        string strOrgname = req.params.get('orgname');
        //string strRelationship  = req.params.get('gender');
        string strMobile  = req.params.get('mobile');
        
        AddNewConsumerContact.GetConsumerInfo();
        jsonResponse = AddNewConsumerContact.createConsumer(strFname,strLname,strOrgname,strPatientID,strSSN,strGender,strPhone,strMobile,strEmail,strDOB,strMAddStreet,strMAddCity ,strMAddState ,strMAddCountry ,strMAddPostalCode);    
        AddNewConsumerContact.jsonstring(lstCTemp);
        
        contact objconNew = new contact();
        objconNew.Firstname='TestFName';
        objconNew.LastName='TestLName';
        objconNew.Gender__c='Male';
        objconNew.Accountid = objAccount.id;
        objconNew.recordtypeid = lstrecordtype[0].id;
        insert objconNew;
     }
        
    static testmethod void AddNewConsumerContactTestFirstName(){
            
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
        
        string strContact1 = objcon.id;
        
        List<contact> lstCTemp1 = new List<contact>([select id,Name,firstname,lastname,Birthdate,Gender__c,AccountID,Account.name,Patient_ID__c,SSN_Last_4__c,Phone,
                MailingCity,MailingState,MailingCountry,MailingStreet,MailingPostalCode,MobilePhone,Email,MailingAddress from contact where id =: strContact1 limit 1]);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String jsonResponse = '';
        
        req.requestURI = '/services/apexrest/AddNewConsumerContact';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
       
        req.addParameter('firstname','');
        req.addParameter('lastname','testLastName');
        req.addParameter('gender','testGender');
        req.addParameter('birthdate',string.valueof(system.today()));
        
        req.addParameter('orgname',objAccount.id);
        req.addParameter('patientid','4321');
        req.addParameter('ssn','123456');
        req.addParameter('phone','123456');
        req.addParameter('mobile','1323456789');
        req.addParameter('email','test@gmail.com');
        /*req.addParameter('mailingstreet','testAddress');
        req.addParameter('mailingcity','TestCity');
        req.addParameter('mailingstate','TestState');
        req.addParameter('mailingcountry','MA');
        req.addParameter('mailingpostalcode','123456'); */
        
        String strFname = req.params.get('firstname');
        String strLname = req.params.get('lastname');
        String strEmail = req.params.get('email');
        string strGender = req.params.get('gender');
        String strPhone = '';
        string strSSN = '';
        string strDOB = req.params.get('birthdate');
        string strMAddStreet = '';
        string strMAddCity = '';
        string strMAddState = '';
        string strMAddCountry = '';
        string strMAddPostalCode = '';
        string strMAddress = ''; 
        string strPatientID = '';
        string strOrgname = '';
        string strRelationship  = '';
        string strMobile  = '';
        
        AddNewConsumerContact obj = new AddNewConsumerContact();
        AddNewConsumerContact.GetConsumerInfo();
        jsonResponse = AddNewConsumerContact.createConsumer(strFname,strLname,strOrgname,strPatientID,strSSN,strGender,strPhone,strMobile,strEmail,strDOB,
                        strMAddStreet,strMAddCity ,strMAddState ,strMAddCountry ,strMAddPostalCode); 
        AddNewConsumerContact.jsonstring(lstCTemp1);                           
        
        contact objconNew = new contact();
        objconNew.Firstname='TestFName';
        objconNew.LastName='TestLName';
        objconNew.Gender__c='Male';
        objconNew.Accountid = objAccount.id;
        objconNew.recordtypeid = lstrecordtype[0].id;
        insert objconNew;
        
        }
        
    static testmethod void AddNewConsumerContactTestLastName(){
            
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
        
        string strContact1 = objcon.id;
        
        List<contact> lstCTemp1 = new List<contact>([select id,Name,firstname,lastname,Birthdate,Gender__c,AccountID,Account.name,Patient_ID__c,SSN_Last_4__c,Phone,
                MailingCity,MailingState,MailingCountry,MailingStreet,MailingPostalCode,MobilePhone,Email,MailingAddress from contact where id =: strContact1 limit 1]);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String jsonResponse = '';
        
        req.requestURI = '/services/apexrest/AddNewConsumerContact';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
       
        req.addParameter('firstname','TestFirstName');
        req.addParameter('lastname','');
        req.addParameter('gender','TestGender');
        req.addParameter('birthdate',string.valueof(system.today()));
        
        req.addParameter('orgname',objAccount.id);
        req.addParameter('patientid','4321');
        req.addParameter('ssn','123456');
        req.addParameter('phone','123456');
        req.addParameter('mobile','1323456789');
        req.addParameter('email','test@gmail.com');
        /*req.addParameter('mailingstreet','testAddress');
        req.addParameter('mailingcity','TestCity');
        req.addParameter('mailingstate','TestState');
        req.addParameter('mailingcountry','MA');
        req.addParameter('mailingpostalcode','123456'); */
        
        String strFname = req.params.get('firstname');
        String strLname = req.params.get('lastname');
        String strEmail = req.params.get('email');
        string strGender = req.params.get('gender');
        String strPhone = '';
        string strSSN = '';
        string strDOB = req.params.get('birthdate');
        string strMAddStreet = '';
        string strMAddCity = '';
        string strMAddState = '';
        string strMAddCountry = '';
        string strMAddPostalCode = '';
        string strMAddress = ''; 
        string strPatientID = '';
        string strOrgname = '';
        string strRelationship  = '';
        string strMobile  = '';
        
        AddNewConsumerContact obj = new AddNewConsumerContact();
        AddNewConsumerContact.GetConsumerInfo();
        jsonResponse = AddNewConsumerContact.createConsumer(strFname,strLname,strOrgname,strPatientID,strSSN,strGender,strPhone,strMobile,strEmail,strDOB,
                        strMAddStreet,strMAddCity ,strMAddState ,strMAddCountry ,strMAddPostalCode); 
        AddNewConsumerContact.jsonstring(lstCTemp1);                           
        
        contact objconNew = new contact();
        objconNew.Firstname='TestFName';
        objconNew.LastName='TestLName';
        objconNew.Gender__c='Male';
        objconNew.Accountid = objAccount.id;
        objconNew.recordtypeid = lstrecordtype[0].id;
        insert objconNew;
        
    }

    static testmethod void AddNewConsumerContactTestGender(){
            
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
        
        string strContact1 = objcon.id;
        
        List<contact> lstCTemp1 = new List<contact>([select id,Name,firstname,lastname,Birthdate,Gender__c,AccountID,Account.name,Patient_ID__c,SSN_Last_4__c,Phone,
                MailingCity,MailingState,MailingCountry,MailingStreet,MailingPostalCode,MobilePhone,Email,MailingAddress from contact where id =: strContact1 limit 1]);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String jsonResponse = '';
        
        req.requestURI = '/services/apexrest/AddNewConsumerContact';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
       
        req.addParameter('firstname','testFirstName');
        req.addParameter('lastname','testLastName');
        req.addParameter('gender','');
        req.addParameter('birthdate',string.valueof(system.today()));
        
        req.addParameter('orgname',objAccount.id);
        req.addParameter('patientid','4321');
        req.addParameter('ssn','123456');
        req.addParameter('phone','123456');
        req.addParameter('mobile','1323456789');
        req.addParameter('email','test@gmail.com');
        /*req.addParameter('mailingstreet','testAddress');
        req.addParameter('mailingcity','TestCity');
        req.addParameter('mailingstate','TestState');
        req.addParameter('mailingcountry','MA');
        req.addParameter('mailingpostalcode','123456'); */
        
        String strFname = req.params.get('firstname');
        String strLname = req.params.get('lastname');
        String strEmail = req.params.get('email');
        string strGender = req.params.get('gender');
        String strPhone = '';
        string strSSN = '';
        string strDOB = req.params.get('birthdate');
        string strMAddStreet = '';
        string strMAddCity = '';
        string strMAddState = '';
        string strMAddCountry = '';
        string strMAddPostalCode = '';
        string strMAddress = ''; 
        string strPatientID = '';
        string strOrgname = '';
        string strRelationship  = '';
        string strMobile  = '';
        
        AddNewConsumerContact obj = new AddNewConsumerContact();
        AddNewConsumerContact.GetConsumerInfo();
        jsonResponse = AddNewConsumerContact.createConsumer(strFname,strLname,strOrgname,strPatientID,strSSN,strGender,strPhone,strMobile,strEmail,strDOB,
                        strMAddStreet,strMAddCity ,strMAddState ,strMAddCountry ,strMAddPostalCode); 
        AddNewConsumerContact.jsonstring(lstCTemp1);                           
        
        contact objconNew = new contact();
        objconNew.Firstname='TestFName';
        objconNew.LastName='TestLName';
        objconNew.Gender__c='Male';
        objconNew.Accountid = objAccount.id;
        objconNew.recordtypeid = lstrecordtype[0].id;
        insert objconNew;
    }
    
    static testmethod void AddNewConsumerContactTestDOB(){
            
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
        
        string strContact1 = objcon.id;
        
        List<contact> lstCTemp1 = new List<contact>([select id,Name,firstname,lastname,Birthdate,Gender__c,AccountID,Account.name,Patient_ID__c,SSN_Last_4__c,Phone,
                MailingCity,MailingState,MailingCountry,MailingStreet,MailingPostalCode,MobilePhone,Email,MailingAddress from contact where id =: strContact1 limit 1]);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String jsonResponse = '';
        
        req.requestURI = '/services/apexrest/AddNewConsumerContact';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
       
        req.addParameter('firstname','testFirstName');
        req.addParameter('lastname','testLastName');
        req.addParameter('gender','Male');
        
        req.addParameter('orgname',objAccount.id);
        req.addParameter('patientid','4321');
        req.addParameter('ssn','123456');
        req.addParameter('phone','123456');
        req.addParameter('mobile','1323456789');
        req.addParameter('email','test@gmail.com');
        /*req.addParameter('mailingstreet','testAddress');
        req.addParameter('mailingcity','TestCity');
        req.addParameter('mailingstate','TestState');
        req.addParameter('mailingcountry','MA');
        req.addParameter('mailingpostalcode','123456'); */
        
        String strFname = req.params.get('firstname');
        String strLname = req.params.get('lastname');
        String strEmail = req.params.get('email');
        string strGender = req.params.get('gender');
        String strPhone = '';
        string strSSN = '';
        string strDOB = '';
        string strMAddStreet = '';
        string strMAddCity = '';
        string strMAddState = '';
        string strMAddCountry = '';
        string strMAddPostalCode = '';
        string strMAddress = ''; 
        string strPatientID = '';
        string strOrgname = '';
        string strRelationship  = '';
        string strMobile  = '';
        
        AddNewConsumerContact obj = new AddNewConsumerContact();
        AddNewConsumerContact.GetConsumerInfo();
        jsonResponse = AddNewConsumerContact.createConsumer(strFname,strLname,strOrgname,strPatientID,strSSN,strGender,strPhone,strMobile,strEmail,strDOB,
                        strMAddStreet,strMAddCity ,strMAddState ,strMAddCountry ,strMAddPostalCode); 
        AddNewConsumerContact.jsonstring(lstCTemp1);                           
        
        contact objconNew = new contact();
        objconNew.Firstname='TestFName';
        objconNew.LastName='TestLName';
        objconNew.Gender__c='Male';
        objconNew.Accountid = objAccount.id;
        objconNew.recordtypeid = lstrecordtype[0].id;
        insert objconNew;
    }
}