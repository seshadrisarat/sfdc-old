@isTest(seeAlldata=false)

private class AddNewConsumerICEContactTest{

    static testmethod void AddNewConsumerICEContactTest(){
        
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
        objcon.Email ='Test@gmail.com';
        objcon.Phone ='123456';
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
        req.requestURI = '/services/apexrest/AddNewConsumerICEContact';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;

        String jsonResponse = '';
        
        req.addParameter('firstname',string.valueof(objcon.Firstname));
        req.addParameter('lastname',string.valueof(objcon.LastName));
        req.addParameter('email',string.valueof(objcon.Email));
        req.addParameter('phone',string.valueof(objcon.Phone));
        req.addParameter('patientid',string.valueof(objConsumer.Data_Source_ID__c));
        
        req.addParameter('ssn','789542131');
        req.addParameter('gender','Male');
        req.addParameter('birthdate','');
        req.addParameter('relationship','TestRel');
        req.addParameter('mailingstreet','testMailStreet');
        req.addParameter('mailingcity','testCity');
        req.addParameter('mailingstate','TestState');
        req.addParameter('mailingpostalcode','4587985');
        req.addParameter('mailingcountry','TestCntry');
        
        List<contact> lstcon = new List<contact>([ select Name,firstname,lastname,Birthdate,Gender__c,AccountID,Account.name,
                            Patient_ID__c,SSN_Last_4__c,Phone, MailingCity,MailingState,MailingCountry,
                            MailingStreet,MailingPostalCode, MobilePhone,
                            Email from contact where id =: objcon.id ]);
        
        List<Consumer_ID__c> lstConsumerID = new List<Consumer_ID__c>([select id,Consumer__c,Consumer__r.name from Consumer_ID__c 
                                    where Data_Source_ID__c =: objConsumer.Data_Source_ID__c]);
        
        List<Consumer_Relationship__c> lstNewConRelationship = new List<Consumer_Relationship__c>([select id,name,Consumer__c,ICE_Contact__c,
                                    Relationship__c from Consumer_Relationship__c where Consumer__c=: lstConsumerID[0].Consumer__c 
                                    and Related_Contact__c=: lstcon[0].id]);
        
        Consumer_Relationship__c objConsRelationship = new Consumer_Relationship__c();
        objConsRelationship.Consumer__c = lstConsumerID[0].Consumer__c;
        objConsRelationship.ICE_Contact__c = true;
        objConsRelationship.Relationship__c = 'testrelationship';
        objConsRelationship.Related_Contact__c= lstcon[0].id;
        insert objConsRelationship;
        
        AddNewConsumerICEContact obj = new AddNewConsumerICEContact();
        AddNewConsumerICEContact.GetICEContactnfo();
        AddNewConsumerICEContact.jsonstring(lstcon);
        AddNewConsumerICEContact.jsonstring(lstNewConRelationship);
    }
    
    static testmethod void AddNewConsumerICEContactTestAssignNull(){
        
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
        objcon.Email ='Test@gmail.com';
        objcon.Phone ='123456';
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
        req.requestURI = '/services/apexrest/AddNewConsumerICEContact';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;

        req.addParameter('firstname',string.valueof(objcon.Firstname));
        req.addParameter('lastname',string.valueof(objcon.LastName));
        req.addParameter('email',string.valueof(objcon.Email));
        req.addParameter('phone','88888522459');
        req.addParameter('patientid',string.valueof(objConsumer.Data_Source_ID__c));
        
        Consumer_Relationship__c objConsRelationship = new Consumer_Relationship__c();
        objConsRelationship.Consumer__c = objConsumer.Consumer__c;
        objConsRelationship.ICE_Contact__c = true;
        objConsRelationship.Relationship__c = 'testrelationship';
        objConsRelationship.Related_Contact__c= objcon.id;
        insert objConsRelationship;
        
        AddNewConsumerICEContact.GetICEContactnfo();
    }
    
    static testmethod void AddNewConsumerICEContactDOBEx(){
        
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
        objcon.Email ='Test@gmail.com';
        objcon.Phone ='123456';
        objcon.Accountid = objAccount.id;
        objcon.recordtypeid = lstrecordtype[0].id;
        insert objcon;
        
        Consumer_ID__c objConsumer = new Consumer_ID__c();
        objConsumer.Active__c = true;
        objConsumer.Consumer__c =objcon.id;
        objConsumer.Data_Source__c ='4321';
        objConsumer.Data_Source_ID__c='4321';
        insert objConsumer;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/AddNewConsumerICEContact';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;

        String jsonResponse = '';
        
        req.addParameter('firstname',string.valueof(objcon.Firstname));
        req.addParameter('lastname',string.valueof(objcon.LastName));
        req.addParameter('email',string.valueof(objcon.Email));
        req.addParameter('phone',string.valueof(objcon.Phone));
        req.addParameter('patientid',string.valueof(objConsumer.Data_Source_ID__c));
        
        req.addParameter('ssn','789542131');
        req.addParameter('gender','Male');
        req.addParameter('birthdate',string.valueof(system.Today()));
        
        AddNewConsumerICEContact.GetICEContactnfo();
    }
    
    static testmethod void AddNewConsumerICEContactTestFirstName(){
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/AddNewConsumerICEContact';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        String jsonResponse = '';
        
        req.addParameter('firstname','');
        req.addParameter('lastname','TestLastName');
        req.addParameter('email','test@gmail.com');
        req.addParameter('phone','1234567');
        req.addParameter('patientid','4321');
        
        String strFname = req.params.get('firstname');
        String strLname = req.params.get('lastname');
        String strEmail = req.params.get('email');
        String strPhone = req.params.get('phone');
        string strPatientID = req.params.get('patientid');

        AddNewConsumerICEContact.GetICEContactnfo();
    }
    
    static testmethod void AddNewConsumerICEContactTestLastName(){

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/AddNewConsumerICEContact';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        String jsonResponse = '';
        
        req.addParameter('firstname','TestFirstName');
        req.addParameter('lastname','');
        req.addParameter('email','test@gmail.com');
        req.addParameter('phone','1234567');
        req.addParameter('patientid','4321');
        
        String strFname = req.params.get('firstname');
        String strLname = req.params.get('lastname');
        String strEmail = req.params.get('email');
        String strPhone = req.params.get('phone');
        string strPatientID = req.params.get('patientid');
                
        AddNewConsumerICEContact.GetICEContactnfo();
    }
    
    static testmethod void AddNewConsumerICEContactTestEmail(){

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/AddNewConsumerICEContact';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        String jsonResponse = '';
        
        req.addParameter('firstname','TestFirstName');
        req.addParameter('lastname','TestLastName');
        req.addParameter('email','');
        req.addParameter('phone','1234567');
        req.addParameter('patientid','4321');
        
        String strFname = req.params.get('firstname');
        String strLname = req.params.get('lastname');
        String strEmail = req.params.get('email');
        String strPhone = req.params.get('phone');
        string strPatientID = req.params.get('patientid');
        
        AddNewConsumerICEContact.GetICEContactnfo();
    }
    
    static testmethod void AddNewConsumerICEContactTestPhone(){

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/AddNewConsumerICEContact';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        String jsonResponse = '';
        
        req.addParameter('firstname','TestFirstName');
        req.addParameter('lastname','TestLastName');
        req.addParameter('email','TestEmail');
        req.addParameter('phone','');
        req.addParameter('patientid','4321');
        
        String strFname = req.params.get('firstname');
        String strLname = req.params.get('lastname');
        String strEmail = req.params.get('email');
        String strPhone = req.params.get('phone');
        string strPatientID = req.params.get('patientid');
        
        AddNewConsumerICEContact.GetICEContactnfo();
    }
    
    static testmethod void AddNewConsumerICEContactTestpatientid(){
               
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/AddNewConsumerICEContact';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        String jsonResponse = '';

        req.addParameter('firstname','TestFirstName');
        req.addParameter('lastname','TestLastName');
        req.addParameter('email','TestEmail');
        req.addParameter('phone','123456');
        req.addParameter('patientid','');
        
        String strFname = req.params.get('firstname');
        String strLname = req.params.get('lastname');
        String strEmail = req.params.get('email');
        String strPhone = req.params.get('phone');
        string strPatientID = req.params.get('patientid');
        
        AddNewConsumerICEContact.GetICEContactnfo();
    }
    
    static testmethod void AddNewConsumerICEContactTestpatientForEx(){
               
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/AddNewConsumerICEContact111111';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        
        String jsonResponse = '';

        req.addParameter('firstname','TestFirstName');
        req.addParameter('lastname','TestLastName');
        req.addParameter('email','TestEmail');
        req.addParameter('phone','123456');
        req.addParameter('patientid','');
        
        String strFname = req.params.get('firstname');
        String strLname = req.params.get('lastname');
        String strEmail = req.params.get('email');
        String strPhone = req.params.get('phone');
        string strPatientID = req.params.get('patientid');
        
        AddNewConsumerICEContact.GetICEContactnfo();
    }
    
    
}