@RestResource(urlMapping='/AddNewConsumerICEContact/*')
global Class AddNewConsumerICEContact
{
    public AddNewConsumerICEContact() {}
    private static boolean blnSuccess {get;set;}
    @HttpGet
    global static void GetICEContactnfo() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        String jsonResponse = '';
        
        String strFname = req.params.get('firstname');
        String strLname = req.params.get('lastname');
        String strEmail = req.params.get('email');
        String strPhone = req.params.get('phone');
        string strSSN = '';
        string strGender = '';
        string strDOB = '';
        string strMAddStreet = '';
        string strMAddCity = '';
        string strMAddState = '';
        string strMAddCountry = '';
        string strMAddPostalCode = '';
        string strMAddress = '';
        string strRelationship = '';
        string strPatientID = req.params.get('patientid');
        
        if(strFname == null || strFname == ''){
            res.statusCode = 400;
            jsonResponse = '{"result": "Failure", "message": "Missing Required Query Parameter: firstname"}';
            res.responseBody = blob.valueOf(jsonResponse);
            AddApiLog.InsertAPILog(string.valueof(RestContext.request),jsonResponse,false,'AddNewConsumerICEContact');
            return;
        }   
        if(strLname == null || strLname == ''){
            res.statusCode = 400;
            jsonResponse = '{"result": "Failure", "message": "Missing Required Query Parameter: lastname"}';
            res.responseBody = blob.valueOf(jsonResponse);
            AddApiLog.InsertAPILog(string.valueof(RestContext.request),jsonResponse,false,'AddNewConsumerICEContact');
            return;
        }
        if(strEmail == null || strEmail == ''){    
            res.statusCode = 400;
            jsonResponse = '{"result": "Failure", "message": "Missing Required Query Parameter: email"}';
            res.responseBody = blob.valueOf(jsonResponse);
            AddApiLog.InsertAPILog(string.valueof(RestContext.request),jsonResponse,false,'AddNewConsumerICEContact');
            return;
        }
        if(strPhone == null || strPhone == ''){
            res.statusCode = 400;
            jsonResponse = '{"result": "Failure", "message": "Missing Required Query Parameter: phone"}';
            res.responseBody = blob.valueOf(jsonResponse);
            AddApiLog.InsertAPILog(string.valueof(RestContext.request),jsonResponse,false,'AddNewConsumerICEContact');
            return;
        }  
        if(strPatientID == null || strPatientID == ''){
            res.statusCode = 400;
            jsonResponse = '{"result": "Failure", "message": "Missing Required Query Parameter: patientid"}';
            res.responseBody = blob.valueOf(jsonResponse);
            AddApiLog.InsertAPILog(string.valueof(RestContext.request),jsonResponse,false,'AddNewConsumerICEContact');
            return;
        }    
        
        if(req.params.get('ssn') != null && req.params.get('ssn') !='')
            strSSN = req.params.get('ssn');
        if(req.params.get('gender') != null && req.params.get('gender') !='')
            strGender = req.params.get('gender');
        if(req.params.get('birthdate') != null && req.params.get('birthdate') !='')
            strDOB = req.params.get('birthdate');
        if(req.params.get('relationship') != null && req.params.get('relationship') !='')
            strRelationship = req.params.get('relationship');
            
        if(req.params.get('mailingstreet') != null && req.params.get('mailingstreet') !='')
            strMAddStreet = req.params.get('mailingstreet');
        if(req.params.get('mailingcity') != null && req.params.get('mailingcity') !='')
            strMAddCity = req.params.get('mailingcity');
        if(req.params.get('mailingstate') != null && req.params.get('mailingstate') !='')
            strMAddState = req.params.get('mailingstate');
        if(req.params.get('mailingcountry') != null && req.params.get('mailingcountry') !='')
            strMAddCountry = req.params.get('mailingcountry');
        if(req.params.get('mailingpostalcode') != null && req.params.get('mailingpostalcode') !='')
            strMAddPostalCode = req.params.get('mailingpostalcode');
       
        if(strMAddStreet != ''){
            strMAddress += strMAddStreet;
        }
        if(strMAddCity != ''){
            if(strMAddress !='')
                strMAddress += ', ' + strMAddCity;
        }
        if(strMAddState != ''){
            if(strMAddress !='')
                strMAddress += ', ' +  strMAddState ;
        }
        if(strMAddCountry != ''){
            if(strMAddress !='')
                strMAddress += ', ' +  strMAddCountry;
        }  
        if(strMAddPostalCode != ''){
            if(strMAddress !='')
                strMAddress += ', ' +  strMAddPostalCode;
        } 
      
        if(strFname != null && strFname != '' && strLname != null && strLname != '' && strEmail != null && strEmail != '' && strPhone!= null &&  strPhone != '' && strPatientID != null && strPatientID !='') 
        { 
            jsonResponse = createConsumer(strFname,strLname,strEmail,strPhone,strSSN,strGender,strDOB,strMAddStreet,strMAddCity ,strMAddState ,strMAddCountry ,strMAddPostalCode ,strRelationship,strPatientID);   
        }else{
            res.statusCode = 400;
            jsonResponse = '{"result": "Failure", "message": "Missing Required Query Parameter"}';
            res.responseBody = blob.valueOf(jsonResponse);
            AddApiLog.InsertAPILog(string.valueof(RestContext.request),jsonResponse,false,'AddNewConsumerICEContact');
            return;
        }
        
        if(jsonResponse == null){
            res.statusCode = 400;
            jsonResponse = '{"result": "Failure", "message": "json Response not found"}';
            res.responseBody = blob.valueOf(jsonResponse);
            AddApiLog.InsertAPILog(string.valueof(RestContext.request),jsonResponse,false,'AddNewConsumerICEContact');
            return;
        }
    
        // JSON serialize it and send it back.
        try 
        {
            res.statusCode = 200;
            string strMsg = '';
            JSONParser parser = JSON.createParser(jsonResponse);
            string strMessage = '';
            while (parser.nextToken() != null) 
            {
                if ((parser.getText() == 'result')) 
                {
                    parser.nextToken();
                    strMessage = parser.getText();
                }
            }
            
            strMsg = '{\"result\":\"'+ strMessage +'\",';
            strMsg += '\"name\":'+'\"'+ strFname + ' ' + strLname +'\",';
            strMsg += '\"email\":'+'\"'+ strEmail  +'\",';
            strMsg += '\"phone\":'+'\"'+ strPhone  +'\",';
            
            jsonResponse =  strMsg + jsonResponse.substring(20);
            jsonResponse  = jsonResponse.unescapeEcmaScript();
            jsonResponse  = jsonResponse.replace('"[','[');
            jsonResponse  = jsonResponse.replace(']"',']');
            res.responseBody = blob.valueOf(jsonResponse);
            if(blnSuccess == true){
                AddApiLog.InsertAPILog(string.valueof(RestContext.request),jsonResponse,false,'AddNewConsumerICEContact');
            }else{
                AddApiLog.InsertAPILog(string.valueof(RestContext.request),jsonResponse,true,'AddNewConsumerICEContact');
            }
            
            return;
        } 
        catch ( Exception ex ) 
        {
            res.statusCode = 500;
            jsonResponse = '{"result": "Failure", "message": "' + ex + '"}';
            res.responseBody = blob.valueOf(jsonResponse);
            AddApiLog.InsertAPILog(string.valueof(RestContext.request),jsonResponse,false,'AddNewConsumerICEContact');
            return;
        }
     
    }
    
    public static string createConsumer(String strFnm,string strLnm,string strEmail,string strPhone,string strSSN,string strGender,string strDOB,string strMAddStreet,string strMAddCity,string strMAddState,string strMAddCountry,string strMAddPostalCode ,string strRelationship,string strPatientID){
        string strjsonResponse = '';
        string strQuery = '';
        Date dob;
        
        try {
            contact objNewContact;
            Consumer_Relationship__c objConsRelationship;
            List<contact> lstNewcontact = new List<contact>();
            List<Consumer_ID__c> lstConsumerID = new List<Consumer_ID__c>();
            if(strDOB != ''){
                try {
                    dob = Date.parse(strDOB);
                } catch(exception ex) {
                    blnSuccess = true;
                    strjsonResponse = '{\"result\":\"Failure\",';
                    strjsonResponse += '\"message\":\"Invalid Date\"}';
                    return strjsonResponse ;
                }
            }
            strQuery  = 'select Name,firstname,lastname,Birthdate,Gender__c,AccountID,Account.name,Patient_ID__c,SSN_Last_4__c,Phone,';
            strQuery  += 'MailingCity,MailingState,MailingCountry,MailingStreet,MailingPostalCode,';
            strQuery  += 'MobilePhone,Email,MailingAddress from contact where firstname =: strFnm and lastname =: strLnm ';
            strQuery  += ' and Email =: strEmail and Phone =: strPhone and (recordtype.developername =\'ICE_Contact\' or recordtype.developername =\'patient\')  limit 1';
           
            lstNewcontact = Database.query(strQuery);
            
            lstConsumerID = [select id,Consumer__c,Consumer__r.name from Consumer_ID__c where Data_Source_ID__c =: strPatientID];
            
            if(lstNewcontact != null && lstNewcontact.size()>0){
                if(lstConsumerID != null && lstConsumerID.size() >0){
                    List<Consumer_Relationship__c> lstNewConRelationship = new List<Consumer_Relationship__c>([select id,name,Consumer__c,ICE_Contact__c,
                                    Relationship__c from Consumer_Relationship__c where Consumer__c=: lstConsumerID[0].Consumer__c 
                                    and Related_Contact__c=: lstNewcontact[0].id]);
                    if(lstNewConRelationship != null && lstNewConRelationship.size()>0){
                        string tempstrjsonResponseRel = jsonstring(lstNewConRelationship);
                        strjsonResponse = '{\"result\":\"Success\",';
                        strjsonResponse += '\"message\":\"Contact and consumer relationship already exists\"}';
                    }else{
                        objConsRelationship = new Consumer_Relationship__c();
                        objConsRelationship.Consumer__c = lstConsumerID[0].Consumer__c;
                        objConsRelationship.ICE_Contact__c = true;
                        objConsRelationship.Relationship__c = strRelationship;
                        objConsRelationship.Related_Contact__c= lstNewcontact[0].id;
                        insert objConsRelationship;
                        lstNewConRelationship.add(objConsRelationship);
                    
                        string tempstrjsonResponseRel = jsonstring(lstNewConRelationship);
                        strjsonResponse = '{\"result\":\"Success\",';
                        strjsonResponse += '\"message\":\"Contact already exists\",';
                        strjsonResponse += '\"consumer relationship'+ '\":' + tempstrjsonResponseRel + '}'; 
                   }
                }else{
                    strjsonResponse = '{\"result\":\"Success\",';
                    strjsonResponse += '\"message\":\"Invalid patientid and Contact already exists\",';
                    strjsonResponse += '\"contactid \": \"'+ lstNewcontact[0].id + '\"}';
                    AddApiLog.ContactID  = lstNewcontact[0].id;    
                }
            }else{
                List<recordtype> lstrecordtype= new List<recordtype>([select id,developername from recordtype where developername = 'ICE_Contact']);
                objNewContact = new contact();
                objNewContact.firstname = strFnm;
                objNewContact.lastname = strLnm;
                objNewContact.Birthdate = dob;
                objNewContact.Gender__c = strGender;
                objNewContact.Email = strEmail;
                objNewContact.SSN_Last_4__c = strSSN;
                objNewContact.Phone = strPhone;
                objNewContact.MailingStreet = strMAddStreet;
                objNewContact.MailingCity = strMAddCity;
                objNewContact.MailingState = strMAddState;
                objNewContact.MailingCountry = strMAddCountry;
                objNewContact.MailingPostalCode = strMAddPostalCode;
                
                if(lstrecordtype != null && lstrecordtype.size() >0)
                    objNewContact.recordtypeid = lstrecordtype[0].id;
                insert objNewContact;
               
                List<contact> lstNewcontact1 = new List<contact>();
                List<Consumer_Relationship__c> lstNewConRelationship = new List<Consumer_Relationship__c>();
                lstNewcontact1.add(objNewContact);
                
                if(lstConsumerID != null && lstConsumerID.size() >0){
                    objConsRelationship = new Consumer_Relationship__c();
                    objConsRelationship.Consumer__c = lstConsumerID[0].Consumer__c;
                    objConsRelationship.ICE_Contact__c = true;
                    objConsRelationship.Relationship__c = strRelationship;
                    objConsRelationship.Related_Contact__c= objNewContact.id;
                }else{
                    objConsRelationship = new Consumer_Relationship__c();
                    objConsRelationship.Consumer__c = objNewContact.id;
                    objConsRelationship.ICE_Contact__c = true;
                    objConsRelationship.Relationship__c = strRelationship;
                    objConsRelationship.Related_Contact__c= objNewContact.id;
                }
                insert objConsRelationship;
                lstNewConRelationship.add(objConsRelationship);
                
                string tempstrjsonResponse = jsonstring(lstNewcontact1);
                string tempstrjsonResponseRel = jsonstring(lstNewConRelationship);
                strjsonResponse = '{\"result\":\"Success\",';
                strjsonResponse += '\"message\":\"Contact saved successfully\",';
                strjsonResponse += '\"contact'+ '\":' + tempstrjsonResponse+ ','; 
                strjsonResponse += '\"consumer relationship'+ '\":' + tempstrjsonResponseRel + '}'; 
            }
        }catch(Exception ex) {
            blnSuccess = true;
            strjsonResponse = '{\"result\":\"Failure\",';
            strjsonResponse += '\"message\": \"'+ex.getMessage()+'\"}';
        } 
        
        return strjsonResponse;
    }
    public static string jsonstring(List<contact> lstContact){
        
        JSONGenerator generator = JSON.createGenerator(true);  
        generator.writeStartArray();
        List<contact> lstCTemp = new List<contact>([select Name,firstname,lastname,Birthdate,Gender__c,AccountID,Account.name,Patient_ID__c,SSN_Last_4__c,Phone,
                MailingCity,MailingState,MailingCountry,MailingStreet,MailingPostalCode,MobilePhone,Email,MailingAddress from contact where id in : lstContact limit 1]);
      
        AddApiLog.ContactID  = lstCTemp[0].id;    
        for(contact objcontact : lstCTemp){
            generator.writeStartObject();
            generator.writeStringField('id',objcontact.Id);
            generator.writeStringField('name',objcontact.name);
            if(objcontact.Email != null)        
                generator.writeStringField('email',objcontact.Email);
            else
                generator.writeStringField('email','');
                
            if(objcontact.Phone != null)        
                generator.writeStringField('phone',objcontact.Phone);
            else
                generator.writeStringField('phone','');
                
            if(objcontact.SSN_Last_4__c != null)        
                generator.writeStringField('ssn',objcontact.SSN_Last_4__c);
            else
                generator.writeStringField('ssn','');  
                  
            if(objcontact.Gender__c != null)        
                generator.writeStringField('gender',objcontact.Gender__c);
            else
                generator.writeStringField('gender','');
                
            if(objcontact.Birthdate != null)        
                generator.writeStringField('birthdate',string.valueof(objcontact.Birthdate));
            else
                generator.writeStringField('birthdate','');
            
            string strAddress = '';
            if(objcontact.MailingStreet != null){
                strAddress += objcontact.MailingStreet;
            }
            if(objcontact.MailingCity != null){
                if(strAddress !='')
                    strAddress += ', ' + objcontact.MailingCity ;
            }
            if(objcontact.MailingState != null){
                if(strAddress !='')
                    strAddress += ', ' +  objcontact.MailingState;
            }
            if(objcontact.MailingCountry != null){
                if(strAddress !='')
                    strAddress += ', ' +  objcontact.MailingCountry;
            }  
            if(objcontact.MailingPostalCode != null){
                if(strAddress !='')
                    strAddress += ', ' +  objcontact.MailingPostalCode;
            } 
            
            if(strAddress != '')        
                generator.writeStringField('mailingaddress',strAddress);
            else
                generator.writeStringField('mailingaddress','');
            /*if(objcontact.MailingAddress != '')        
                generator.writeStringField('mailingaddress',string.valueof(objcontact.MailingAddress));
            else
                generator.writeStringField('mailingaddress','');*/
            generator.writeEndObject();
        }
        
        generator.writeEndArray();
        return generator.getAsString();
    }
    public static string jsonstring(List<Consumer_Relationship__c> lstCRelationship){
        
        List<Consumer_Relationship__c> lstTemp = new List<Consumer_Relationship__c>([select Consumer__c,Consumer__r.name,name,id,ICE_Contact__c,Related_Contact__c,Related_Contact__r.name from Consumer_Relationship__c where id in: lstCRelationship]);
        JSONGenerator generator = JSON.createGenerator(true);  
        generator.writeStartArray();
        for(Consumer_Relationship__c objcrel : lstTemp ){
            generator.writeStartObject();
            generator.writeStringField('id',objcrel.Id);
            generator.writeStringField('name',objcrel.name);
            if(objcrel.ICE_Contact__c!= null)        
                generator.writeStringField('icecontact',string.valueOf(objcrel.ICE_Contact__c));
            else
                generator.writeStringField('icecontact','');
                
            if(objcrel.Consumer__c != null)        
                generator.writeStringField('consumerid',objcrel.Consumer__c);
            else
                generator.writeStringField('consumerid','');
                
            if(objcrel.Consumer__c != null)        
                generator.writeStringField('consumername',objcrel.Consumer__r.name);
            else
                generator.writeStringField('consumername','');  
                
            if(objcrel.Related_Contact__c != null)        
                generator.writeStringField('relatedcontactid',objcrel.Related_Contact__c);
            else
                generator.writeStringField('relatedcontactid','');
                
            if(objcrel.Related_Contact__c != null)        
                generator.writeStringField('relatedcontactname',objcrel.Related_Contact__r.name);
            else
                generator.writeStringField('relatedcontactname','');  
                
            generator.writeEndObject();
        }
        
        generator.writeEndArray();
        return generator.getAsString();
    }
}