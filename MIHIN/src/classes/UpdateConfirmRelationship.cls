@RestResource(urlMapping='/UpdateConfirmRelationship/*')
global Class UpdateConfirmRelationship
{
    public UpdateConfirmRelationship() 
    {
        
    }
    private static boolean blnSuccess {get;set;}
    @HttpGet
    global static void GetCareTeamInfo() 
    {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        String jsonResponse = '';
        
        String strActiveCareRelid = req.params.get('activecarerelationid');
        String strNotifyFlag = req.params.get('confirmrelationship');
       
        if(strActiveCareRelid != null && strActiveCareRelid != '') 
        {    
            if(strNotifyFlag != null && strNotifyFlag != ''){
                jsonResponse = getCareTeamDetail(strActiveCareRelid,strNotifyFlag);   
            }else{
                jsonResponse = getCareTeamDetail(strActiveCareRelid,'');   
            }
            
        }else{
            res.statusCode = 400;
            jsonResponse = '{"result": "Failure", "message": "Missing Required Query Parameter: activecarerelationid"}';
            res.responseBody = blob.valueOf(jsonResponse);
            AddApiLog.InsertAPILog(string.valueof(RestContext.request),jsonResponse,false,'UpdateConfirmRelationship');
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
            strMsg += '\"activecarerelationid\":'+'\"'+ strActiveCareRelid +'\",';
                
            if(strNotifyFlag != null && strNotifyFlag != ''){
                strMsg += '\"confirmrelationship\":'+'\"'+ strNotifyFlag +'\",';
            }
            jsonResponse =  strMsg + jsonResponse.substring(20);
            jsonResponse  = jsonResponse.unescapeEcmaScript();
            jsonResponse  = jsonResponse.replace('"[','[');
            jsonResponse  = jsonResponse.replace(']"',']');
           
            res.responseBody = blob.valueOf(jsonResponse);
            
            if(blnSuccess == true){
                AddApiLog.InsertAPILog(string.valueof(RestContext.request),jsonResponse,false,'UpdateConfirmRelationship');
            }else{
                AddApiLog.InsertAPILog(string.valueof(RestContext.request),jsonResponse,true,'UpdateConfirmRelationship');
            }
            
            return;
        } 
        catch ( Exception ex ) 
        {
            res.statusCode = 500;
            jsonResponse = '{"result": "Failure", "message": "' + ex + '"}';
            AddApiLog.InsertAPILog(string.valueof(RestContext.request),jsonResponse,false,'UpdateConfirmRelationship');
            res.responseBody = blob.valueOf(jsonResponse);
            return;
        }
    }
    
    public static string getCareTeamDetail(String strActiveCareRelid,string strDonNotNotifyFlag)
    {
        string strjsonResponse = '';
        string strQuery = '';
       
        try {
                
            List<Active_Care_Relationship__c> lstCareRelationship = new List<Active_Care_Relationship__c>();
            strQuery = 'select id,name,Care_Provider__c,Consumer_Name__c,Data_Source__c,Data_Source_Id__c,Notes__c, ';
            strQuery += 'Organization__c,Confirm_Relationship__c,Consumer__c,Consumer__r.name,Care_Organization__c ';
            strQuery += ' from Active_Care_Relationship__c where id =: strActiveCareRelid ';
            
            lstCareRelationship = Database.query(strQuery);
         
            if(lstCareRelationship != null && lstCareRelationship.size()>0) {
                AddApiLog.ContactID = lstCareRelationship[0].Consumer__c;   
                //system.debug('lstCareRelationship1::'+lstCareRelationship );
                if(strDonNotNotifyFlag !=''){
                    for(Active_Care_Relationship__c objCareRel : lstCareRelationship ){
                        objCareRel.Confirm_Relationship__c = boolean.valueof(strDonNotNotifyFlag);
                    }
                    update lstCareRelationship ;
                    //system.debug('lstCareRelationship ::'+lstCareRelationship );
                }
                
                string tempstrjsonResponse = jsonstring(lstCareRelationship);
                //string tempstrjsonResponse = '';
                strjsonResponse = '{\"result\":\"Success\",';
                strjsonResponse += '\"message\":\"Care Relationships updated successfully\",';
                //strjsonResponse +=  '}'; 
                strjsonResponse += '\"care relationship'+ '\":' + tempstrjsonResponse+ '}'; 
            }else {
                strjsonResponse = '{\"result\":\"Success\",';
                strjsonResponse += '\"message\": \"Not Found - Care relationship not found\"}';
            }      
     
           
        }catch(Exception ex) {
            blnSuccess = true;
            strjsonResponse = '{\"result\":\"Failure\",';
            strjsonResponse += '\"message\": \"'+ex.getMessage()+'\"}';
        }   
         
         return strjsonResponse;
    }
      
    public static string jsonstring(List<Active_Care_Relationship__c> lstCareRelation){
        
        JSONGenerator generator = JSON.createGenerator(true);  
        generator.writeStartArray();

        for(Active_Care_Relationship__c objCareRel : lstCareRelation){
            generator.writeStartObject();
            generator.writeStringField('id',objCareRel.Id);
            generator.writeStringField('name',objCareRel.Name);
            if(objCareRel.Consumer__c != null)        
                generator.writeStringField('consumername',objCareRel.Consumer__r.Name);
            else
                generator.writeStringField('consumername','');
                
            if(objCareRel.Confirm_Relationship__c != null)        
                generator.writeStringField('confirmrelationship',string.valueof(objCareRel.Confirm_Relationship__c));
            else
                generator.writeStringField('confirmrelationship','');
              
            if(objCareRel.Data_Source__c != null)        
                generator.writeStringField('datasource',objCareRel.Data_Source__c);
            else
                generator.writeStringField('datasource','');
                
            if(objCareRel.Data_Source_Id__c != null)        
                generator.writeStringField('datasourceid',objCareRel.Data_Source_Id__c);
            else
                generator.writeStringField('datasourceid','');

            generator.writeEndObject();
        }
        
        generator.writeEndArray();
        return generator.getAsString();
    }
}