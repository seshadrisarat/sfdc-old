@RestResource(urlMapping='/AddNewConsumerContact/*')
global Class AddNewConsumerContact
{
    public AddNewConsumerContact() 
    {
        
    }
    private static boolean blnSuccess {get;set;}
    @HttpGet
    global static void GetConsumerInfo() 
    {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        String jsonResponse = '';
        
        String strFname = req.params.get('firstname');
        String strLname = req.params.get('lastname');
        String strEmail = '';
        String strPhone = '';
        string strSSN = '';
        string strGender = req.params.get('gender');
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
        
        if(strFname == null || strFname == ''){
            res.statusCode = 400;
            jsonResponse = '{"result": "Failure", "message": "Missing Required Query Parameter: firstname"}';
            res.responseBody = blob.valueOf(jsonResponse);
            AddApiLog.InsertAPILog(string.valueof(RestContext.request),jsonResponse,false,'AddNewConsumerContact');
            return;
        }   
        if(strLname == null || strLname == ''){
            res.statusCode = 400;
            jsonResponse = '{"result": "Failure", "message": "Missing Required Query Parameter: lastname"}';
            res.responseBody = blob.valueOf(jsonResponse);
            AddApiLog.InsertAPILog(string.valueof(RestContext.request),jsonResponse,false,'AddNewConsumerContact');
            return;
        }
        if(strGender == null || strGender == ''){    
            res.statusCode = 400;
            jsonResponse = '{"result": "Failure", "message": "Missing Required Query Parameter: gender"}';
            res.responseBody = blob.valueOf(jsonResponse);
            AddApiLog.InsertAPILog(string.valueof(RestContext.request),jsonResponse,false,'AddNewConsumerContact');
            return;
        }
        if(strDOB == null || strDOB == ''){
            res.statusCode = 400;
            jsonResponse = '{"result": "Failure", "message": "Missing Required Query Parameter: birthdate"}';
            AddApiLog.InsertAPILog(string.valueof(RestContext.request),jsonResponse,false,'AddNewConsumerContact');
            res.responseBody = blob.valueOf(jsonResponse);
            AddApiLog.InsertAPILog(string.valueof(RestContext.request),jsonResponse,false,'AddNewConsumerContact');
            return;
        }    
        if(req.params.get('orgname') != null && req.params.get('orgname') !='')
            strOrgname = req.params.get('orgname');
        
        if(req.params.get('patientid') != null && req.params.get('patientid') !='')
            strPatientID = req.params.get('patientid');
            
        if(req.params.get('ssn') != null && req.params.get('ssn') !='')
            strSSN = req.params.get('ssn');
            
        if(req.params.get('phone') != null && req.params.get('phone') !='')
            strPhone = req.params.get('phone');
            
        if(req.params.get('mobile') != null && req.params.get('mobile') !='')
            strMobile = req.params.get('mobile');
            
        if(req.params.get('email') != null && req.params.get('email') !='')
            strEmail = req.params.get('email');
        
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
      
            
        if(strFname != null && strFname != '' && strLname != null && strLname != '' && strGender != null && strGender !='' && strDOB != null && strDOB !='' ) 
        { 
            jsonResponse = createConsumer(strFname,strLname,strOrgname,strPatientID,strSSN,strGender,strPhone,strMobile,strEmail,strDOB,strMAddStreet,strMAddCity ,strMAddState ,strMAddCountry ,strMAddPostalCode);   
        }else{
            res.statusCode = 400;
            jsonResponse = '{"result": "Failure", "message": "Missing Required Query Parameter"}';
            AddApiLog.InsertAPILog(string.valueof(RestContext.request),jsonResponse,false,'AddNewConsumerContact');
            res.responseBody = blob.valueOf(jsonResponse);
            return;
        }
        
        if(jsonResponse == null){
            res.statusCode = 400;
            jsonResponse = '{"result": "Failure", "message": "json Response not found"}';
            AddApiLog.InsertAPILog(string.valueof(RestContext.request),jsonResponse,false,'AddNewConsumerContact');
            res.responseBody = blob.valueOf(jsonResponse);
            return;
        }
    
        // JSON serialize it and send it back.
        try 
        {
            res.statusCode = 200;
            string strMsg='';
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
            strMsg += '\"birthdate\":'+'\"'+ strDOB +'\",';
            strMsg += '\"gender\":'+'\"'+ strGender +'\",';
            strMsg += '\"phone\":'+'\"'+ strPhone  +'\",';
            strMsg += '\"mobile\":'+'\"'+ strMobile +'\",';
            strMsg += '\"email\":'+'\"'+ strEmail  +'\",';
            
            
            jsonResponse =  strMsg + jsonResponse.substring(20);
            jsonResponse  = jsonResponse.unescapeEcmaScript();
            jsonResponse  = jsonResponse.replace('"[','[');
            //jsonResponse  = jsonResponse.replace(']"',']');
            res.responseBody = blob.valueOf(jsonResponse);
            
            if(blnSuccess == true){
                AddApiLog.InsertAPILog(string.valueof(RestContext.request),jsonResponse,false,'AddNewConsumerContact');
            }else{
                AddApiLog.InsertAPILog(string.valueof(RestContext.request),jsonResponse,true,'AddNewConsumerContact');
            }
        
        
            return;
        } 
        catch ( Exception ex ) 
        {
            res.statusCode = 500;
            jsonResponse = '{"result": "Failure", "message": "' + ex + '"}';
            //jsonResponse = '{"result": "Failure", "message": "' + ex +'\"}'; 
            res.responseBody = blob.valueOf(jsonResponse);
            AddApiLog.InsertAPILog(string.valueof(RestContext.request),jsonResponse,false,'AddNewConsumerContact');
            return;
        }
    }
 
    public static string createConsumer(String strFnm,string strLnm,string strOrgname,string strPatientID,string strSSN,string strGender,string strPhone,string strMobile,string strEmail,string strDOB,string strMAddStreet,string strMAddCity ,string strMAddState ,string strMAddCountry ,string strMAddPostalCode)
    {
        string strjsonResponse = '';
        string strQuery = '';
        Date dob;
        
        try {
            contact objNewContact;
            List<contact> lstNewcontact = new List<contact>();
            if(strDOB != ''){
                try {
                    dob = Date.parse(strDOB);
                } catch(exception ex) {
                    blnSuccess = true;
                    strjsonResponse = '{\"result\":\"Failure\",';
                    strjsonResponse += '\"message\":\"Invalida Date\"}';
                    return strjsonResponse ;
                }
            }
            strQuery  = 'select id,Name,firstname,lastname,Birthdate,Gender__c,AccountID,Account.name,Patient_ID__c,SSN_Last_4__c,Phone,';
            strQuery  += 'MobilePhone,Email,MailingCity,MailingState,MailingCountry,MailingStreet,MailingPostalCode,MailingAddress from contact where firstname =: strFnm and lastname =: strLnm ';
            strQuery  += ' and Birthdate=: dob and Gender__c=: strGender and recordtype.developername =\'patient\' limit 1';
           
            lstNewcontact = Database.query(strQuery);
            
            if(lstNewcontact != null && lstNewcontact.size()>0){
                strjsonResponse = '{\"result\":\"Success\",';
                strjsonResponse += '\"message\":\"Contact already exists\",';
                strjsonResponse += '\"contactid \": \"'+ lstNewcontact[0].id +'\"}'; 
            }else{
                List<recordtype> lstrecordtype= new List<recordtype>([select id,developername from recordtype where developername = 'patient']);
                objNewContact = new contact();
                objNewContact.firstname = strFnm;
                objNewContact.lastname = strLnm;
                objNewContact.Email = strEmail;
                objNewContact.Phone = strPhone;
                objNewContact.SSN_Last_4__c = strSSN;
                objNewContact.Gender__c = strGender;
                objNewContact.Birthdate = dob;
                if(strOrgname !='')
                    objNewContact.AccountID = strOrgname;
                objNewContact.Patient_ID__c = strPatientID;
                objNewContact.MailingStreet = strMAddStreet;
                objNewContact.MailingCity = strMAddCity;
                objNewContact.MailingState = strMAddState;
                objNewContact.MailingCountry = strMAddCountry;
                objNewContact.MailingPostalCode = strMAddPostalCode;
                if(lstrecordtype != null && lstrecordtype.size() >0)
                    objNewContact.recordtypeid = lstrecordtype[0].id;
                insert objNewContact;
               
                List<contact> lstNewcontact1 = new List<contact>();
                lstNewcontact1.add(objNewContact);
               
                string tempstrjsonResponse = jsonstring(lstNewcontact1);
                strjsonResponse = '{\"result\":\"Success\",';
                strjsonResponse += '\"message\":\"Contact saved successfully\",';
                strjsonResponse += '\"contact'+ '\":' + tempstrjsonResponse+ '}'; 
            }
        }catch(Exception ex) {
            blnSuccess = true;
            strjsonResponse = '{\"result\":\"Failure\",';
            strjsonResponse += '\"message\": \"'+ ex.getMessage()+ '\"}';
        }  
       
        return strjsonResponse;
    }
      
    public static string jsonstring(List<contact> lstContact){
        
        JSONGenerator generator = JSON.createGenerator(true);  
        generator.writeStartArray();
        List<contact> lstCTemp = new List<contact>([select id,Name,firstname,lastname,Birthdate,Gender__c,AccountID,Account.name,Patient_ID__c,SSN_Last_4__c,Phone,
                MailingCity,MailingState,MailingCountry,MailingStreet,MailingPostalCode,MobilePhone,Email,MailingAddress from contact where id in : lstContact limit 1]);
        
        AddApiLog.ContactID  = lstCTemp[0].id;      
        
        for(contact objcontact : lstCTemp){
            generator.writeStartObject();
            generator.writeStringField('id',objcontact.Id);
            generator.writeStringField('name',objcontact.firstname + ' ' +objcontact.lastname);
            if(objcontact.Birthdate != null)        
                generator.writeStringField('birthdate',string.valueof(objcontact.Birthdate));
            else
                generator.writeStringField('birthdate','');
                
            if(objcontact.Gender__c != null)        
                generator.writeStringField('gender',objcontact.Gender__c);
            else
                generator.writeStringField('gender','');
          
             if(objcontact.AccountID != null)        
                generator.writeStringField('organizationid',objcontact.AccountID);
            else
                generator.writeStringField('organizationid','');
            
            if(objcontact.Patient_ID__c != null)        
                generator.writeStringField('patientid',objcontact.Patient_ID__c);
            else
                generator.writeStringField('patientid','');
            
            if(objcontact.SSN_Last_4__c != null)        
                generator.writeStringField('ssn',objcontact.SSN_Last_4__c);
            else
                generator.writeStringField('ssn','');
                
            if(objcontact.Phone != null)        
                generator.writeStringField('phone',objcontact.Phone);
            else
                generator.writeStringField('phone','');
                
            if(objcontact.MobilePhone != null)        
                generator.writeStringField('mobilephone',objcontact.MobilePhone);
            else
                generator.writeStringField('mobilephone','');
                
            if(objcontact.Email != null)        
                generator.writeStringField('email',objcontact.Email);
            else
                generator.writeStringField('email','');
                
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
                    
            generator.writeEndObject();
        }
        
        generator.writeEndArray();
        return generator.getAsString();
    }
}