@RestResource(urlMapping='/ViewConsumerRelationship/*')
global Class ViewConsumerRelationship
{
    public ViewConsumerRelationship() 
    {
        
    }
     private static boolean blnSuccess {get;set;}
    @HttpGet
    global static void GetICEInfo() 
    {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        String jsonResponse = '';
        
        String strPatientid = req.params.get('patientid');
        String strICEFlag = req.params.get('iceflag');
        
        if(strPatientid != null && strPatientid != '') 
        {
            if(strICEFlag != null && strICEFlag != ''){
                jsonResponse = getICEDetail(strPatientid,strICEFlag);
            }else{
                jsonResponse = getICEDetail(strPatientid,'');   
            }
        }else{
            res.statusCode = 400;
            jsonResponse = '{"result": "Failure", "message": "Missing Required Query Parameter: patientid"}';
            res.responseBody = blob.valueOf(jsonResponse);
            AddApiLog.InsertAPILog(string.valueof(RestContext.request),jsonResponse,false,'ViewConsumerRelationship');
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
            strMsg += '\"patientid\":'+'\"'+ strPatientid +'\",';
            jsonResponse =  strMsg + jsonResponse.substring(20);
            jsonResponse  = jsonResponse.unescapeEcmaScript();
            jsonResponse  = jsonResponse.replace('"[','[');
            jsonResponse  = jsonResponse.replace(']"',']');
            res.responseBody = blob.valueOf(jsonResponse);
            if(blnSuccess == true){
                AddApiLog.InsertAPILog(string.valueof(RestContext.request),jsonResponse,false,'ViewConsumerRelationship');
            }else{
                AddApiLog.InsertAPILog(string.valueof(RestContext.request),jsonResponse,true,'ViewConsumerRelationship');
            }
            
            return;
        } 
        catch ( Exception ex ) 
        {
            res.statusCode = 500;
            jsonResponse = '{"result": "Failure", "message": "' + ex + '"}';
            res.responseBody = blob.valueOf(jsonResponse);
            AddApiLog.InsertAPILog(string.valueof(RestContext.request),jsonResponse,false,'ViewConsumerRelationship');
            return;
        }
    }
    
    public static string getICEDetail(String strPatientid,string strICEFlag)
    {
        string strjsonResponse = '';
        string strQuery = '';
       
        try {
            List<Consumer_ID__c> lstConsumerID = new List<Consumer_ID__c>(); 
            lstConsumerID = [select id,Active__c,Consumer__c,Consumer__r.name,Data_Source__c,Data_Source_ID__c FROM Consumer_ID__c
                            where Data_Source_ID__c =:  strPatientid ];
            string strContact = '';
            List<Consumer_Relationship__c> lstConsumerRelationship = new List<Consumer_Relationship__c>();
            
            if (lstConsumerID != null && lstConsumerID.size() > 0){
                strContact = lstConsumerID[0].Consumer__c;
                AddApiLog.ContactID  = strContact;    
                strQuery = 'select id,name,Consumer__c,ICE_Contact__c ,Related_Contact__c,Relationship__c,Consumer__r.name,Consumer__r.Email,';
                strQuery += ' Consumer__r.MailingCity,Consumer__r.MailingState,Consumer__r.MailingCountry,Consumer__r.MailingStreet,Consumer__r.MailingPostalCode,';
                strQuery += ' Account_Caretaker__c, Related_Contact__r.name from Consumer_Relationship__c where Consumer__c =: strContact ';
               
                if(strICEFlag !='')
                    strQuery += ' and ICE_Contact__c= '+ strICEFlag ;
                
                lstConsumerRelationship = Database.query(strQuery);
                
                if(lstConsumerRelationship != null && lstConsumerRelationship.size()>0) {
                    string tempstrjsonResponse = jsonstring(lstConsumerRelationship);
                    strjsonResponse = '{\"result\":\"Success\",';
                    strjsonResponse += '\"message\":\"Consumer Relationships found\",';
                    strjsonResponse += '\"consumer relationship'+ '\":' + tempstrjsonResponse+ '}'; 
                }else {
                    strjsonResponse = '{\"result\":\"Success\",';
                    strjsonResponse += '\"message\": \"Not Found - Consumer relationship not found\"}';
                }      
            }else{
                strjsonResponse = '{\"result\":\"Success\",';
                strjsonResponse += '\"message\": \"Patient not registered in consumer directory\",';
                strjsonResponse += '\"errorcode\":\"XDSUnknownPatientID\"}';
            }
           
        }catch(Exception ex) {
            blnSuccess = true;
            strjsonResponse = '{\"result\":\"Failure\",';
            strjsonResponse += '\"message\": \"'+ex.getMessage()+'\"}';
        }   
      
         return strjsonResponse;
    }
      
    public static string jsonstring(List<Consumer_Relationship__c> lstCRelationship){
        
        JSONGenerator generator = JSON.createGenerator(true);  
        generator.writeStartArray();

        for(Consumer_Relationship__c objCR : lstCRelationship){
            generator.writeStartObject();
            generator.writeStringField('id',objCR.Id);
            generator.writeStringField('name',objCR.Name);
            if(objCR.Consumer__c != null)        
                generator.writeStringField('consumername',objCR.Consumer__r.Name);
            else
                generator.writeStringField('consumername','');
            
            if(objCR.Consumer__r.Email != null)        
                generator.writeStringField('consumeremail',objCR.Consumer__r.Email);
            else
                generator.writeStringField('consumeremail','');
            
            string strAddress = '';
            
            if(objCR.Consumer__r.MailingStreet != null){
                strAddress += objCR.Consumer__r.MailingStreet;
            }
            if(objCR.Consumer__r.MailingCity != null){
                if(strAddress !='')
                    strAddress += ', ' + objCR.Consumer__r.MailingCity ;
            }
            if(objCR.Consumer__r.MailingState != null){
                if(strAddress !='')
                    strAddress += ', ' +  objCR.Consumer__r.MailingState;
            }
            if(objCR.Consumer__r.MailingCountry != null){
                if(strAddress !='')
                    strAddress += ', ' +  objCR.Consumer__r.MailingCountry;
            }  
            if(objCR.Consumer__r.MailingPostalCode != null){
                if(strAddress !='')
                    strAddress += ', ' +  objCR.Consumer__r.MailingPostalCode;
            } 
          
            if(strAddress != null)        
                generator.writeStringField('consumeraddress',strAddress);
            else
                generator.writeStringField('consumeraddress','');
             
            if(objCR.ICE_Contact__c != null)        
                generator.writeStringField('icecontact',string.valueof(objCR.ICE_Contact__c));
            else
                generator.writeStringField('icecontact','');
                
            if(objCR.Related_Contact__c != null)        
                generator.writeStringField('relatedcontact',objCR.Related_Contact__r.name);
            else
                generator.writeStringField('relatedcontact','');
            
            if(objCR.Account_Caretaker__c != null)        
                generator.writeStringField('accountcaretaker',string.valueof(objCR.Account_Caretaker__c));
            else
                generator.writeStringField('accountcaretaker','');
                
            if(objCR.Relationship__c != null)        
                generator.writeStringField('relationship',objCR.Relationship__c);
            else
                generator.writeStringField('relationship','');

            generator.writeEndObject();
        }
        
        generator.writeEndArray();
        return generator.getAsString();
    }
}