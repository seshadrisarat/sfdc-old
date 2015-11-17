@RestResource(urlMapping='/deleteconsumerrelationship')
global class DeleteConsumerRelationship {
    private static boolean blnSuccess {get;set;}
    @HttpGet
    global static void DeleteCRRecords() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        
        string jsonResponse = '';
        
        string strID ='';
        
        strID  = req.params.get('id'); 
            
        if(strID == null || strID == '') {
            res.statusCode = 400;
            blnSuccess = true;
            jsonResponse = '{"status": "Failure", "message": "Missing Required Parameter : id"}';
            res.responseBody = blob.valueOf(jsonResponse);
            AddApiLog.InsertAPILog(string.valueof(RestContext.request),jsonResponse,false,'deleteconsumerrelationship');
            return;
        }else{

            Consumer_Relationship__c objConsumerRelationship = new Consumer_Relationship__c();
            
            List<Consumer_Relationship__c> lstConsumerRelationship = New List<Consumer_Relationship__c>();
            
            lstConsumerRelationship = [select id,Consumer__c from Consumer_Relationship__c where id =: strID ];
            
            if (lstConsumerRelationship.size() > 0){
                AddApiLog.ContactID  = lstConsumerRelationship[0].Consumer__c;    
                objConsumerRelationship.id = lstConsumerRelationship[0].id;
            
                Savepoint sp = Database.setSavepoint();
                try {
                     
                    delete objConsumerRelationship;
                    res.statusCode = 200;
                    jsonResponse = '{\"result\":\"Success\",';
                    jsonResponse += '\"message\": \"Delete Successfully\"}';
                    res.responseBody = blob.valueOf(jsonResponse);
                    AddApiLog.InsertAPILog(string.valueof(RestContext.request),jsonResponse,true,'deleteconsumerrelationship');
                    return;
                }catch (Exception ex) {
                    Database.rollback(sp);
                    res.statusCode = 500;
                    blnSuccess = true;
                    jsonResponse = '{"response": {"status": "Failure", "message": "' + ex + '"}}';
                    res.responseBody = blob.valueOf(jsonResponse);
                    AddApiLog.InsertAPILog(string.valueof(RestContext.request),jsonResponse,false,'deleteconsumerrelationship');
                    return;
                }
           } else {
               
                res.statusCode = 200;
                jsonResponse = '{\"result\":\"Success\",';
                jsonResponse += '\"message\": \"Consumer relationship id not found\"}';
                res.responseBody = blob.valueOf(jsonResponse);
                AddApiLog.InsertAPILog(string.valueof(RestContext.request),jsonResponse,true,'deleteconsumerrelationship');
                return;
               
           }
           
        }
       
    }
}