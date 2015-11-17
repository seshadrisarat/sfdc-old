@RestResource(urlMapping='/validateconsumer/*')
global Class Validate_Consumer
{
    public Validate_Consumer() 
    {
        
    }
    
    private static boolean blnSuccess {get;set;}
    @HttpGet
    global static void GetConsumerValidate() 
    {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        String jsonResponse = '';
        
        String strDataSourceId= req.params.get('patient_id');        
        String strDataSource = req.params.get('data_source');
        
        if(strDataSourceId == null || strDataSourceId == '') 
        {
            res.statusCode = 400;
            jsonResponse = '{"result": "Failure", "patient_id" : "", "message": "Bad Request - Missing Parameters: patient_id"}';
            res.responseBody = blob.valueOf(jsonResponse);
            AddApiLog.InsertAPILog(string.valueof(RestContext.request),jsonResponse,false,'validateconsumer');
            return;
            
        } else {
           jsonResponse = GetConsumerInfo(strDataSourceId,strDataSource);
        }
        
        if(jsonResponse == null)
        {
            res.statusCode = 400;
            jsonResponse = '{"result": "Failure", "message": "Request Failed - Parameters were valid but request failed"}';
            res.responseBody = blob.valueOf(jsonResponse);
            AddApiLog.InsertAPILog(string.valueof(RestContext.request),jsonResponse,false,'validateconsumer');
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
            strMsg += '\"patient_id\":'+'\"'+strDataSourceId +'\",';
            
            if(strDataSource != null && strDataSource != '' && strDataSource != 'null'){
                strMsg += '\"data_source\":'+'\"'+ strDataSource +'\",';
            }    

            jsonResponse =  strMsg + jsonResponse.substring(20);
            jsonResponse  = jsonResponse.unescapeEcmaScript();
            jsonResponse  = jsonResponse.replace('"[','[');
            jsonResponse  = jsonResponse.replace(']"',']');
            res.responseBody = blob.valueOf(jsonResponse);
            if(blnSuccess == true){
                AddApiLog.InsertAPILog(string.valueof(RestContext.request),jsonResponse,false,'validateconsumer');
            }else{
                AddApiLog.InsertAPILog(string.valueof(RestContext.request),jsonResponse,true,'validateconsumer');
            }
            
            return;
        } 
        catch ( Exception ex ) 
        {
            res.statusCode = 500;
            jsonResponse = '{"result": "Failure", "message": "Unauthorized - No valid API key provided."}';
            res.responseBody = blob.valueOf(jsonResponse);
            AddApiLog.InsertAPILog(string.valueof(RestContext.request),jsonResponse,false,'validateconsumer');
            return;
        }
    }
             
    public static string GetConsumerInfo(String strDataSourceId,string strDataSource)
    {
        String jsonResponse = '';
        string strQuery = '';
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        strQuery = 'SELECT ID, Data_Source__c, Data_Source_ID__c, Consumer__c FROM Consumer_ID__c ';
        strQuery += ' where Data_Source_ID__c =: strDataSourceId ';
        
        if(strDataSource != null && strDataSource != '' && strDataSource != 'null'){
            strQuery += ' And  Data_Source__c =: strDataSource ';
        }
        
        //system.debug('strQuery...' +strQuery );
        
        list<Consumer_ID__c> lstConsumerId = Database.query(strQuery);
        
        if(lstConsumerId.size() == 1){
        
            jsonResponse = '{\"result\":\"Success\",';
            jsonResponse += '\"message\": \"Patient found\"}';
            AddApiLog.ContactID = lstConsumerId[0].Consumer__c;
            
            
        }else if(lstConsumerId.size() > 1){
        
            jsonResponse = '{\"result\":\"Success\",';
            jsonResponse += '\"message\": \"Multiple - Multiple patients found\"}';
            
                    
        }else{
            blnSuccess = true;
            jsonResponse = '{\"result\":\"Failure\",';
            jsonResponse += '\"message\": \"Not Found - Patient id not found in consumer directory\"}';
           
       } 
            return jsonResponse;       
         
    }

}