@RestResource(urlMapping='/createconsumerrelationship')
global class InsertConsumerRelationship {
    private static boolean blnSuccess {get;set;}
    @HttpGet
    global static void InsertCRRecords() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        
        string jsonResponse = '';
        
        string strPatientID ='';
        string strConsumer ='';
        string strRelatedContact ='';
        boolean blICEContact = false;
        boolean blAccountCaretaker =false;
        string strRelationship ='';       
       
        strPatientID = req.params.get('patient_id'); 
        strConsumer = req.params.get('consumer');
        if (req.params.get('icecontact') != null)
            blICEContact = Boolean.valueof(req.params.get('icecontact'));
        if (req.params.get('acccaretaker') != null)    
            blAccountCaretaker =Boolean.valueof(req.params.get('acccaretaker'));
        strRelationship = req.params.get('relationship');
        
            
        if(strPatientID == null || strPatientID == '') {
            res.statusCode = 400;
            jsonResponse = '{"status": "Failure", "message": "Missing Required Parameter : patient_id"}';
            res.responseBody = blob.valueOf(jsonResponse);
            AddApiLog.InsertAPILog(string.valueof(RestContext.request),jsonResponse,false,'createconsumerrelationship');
            return;
        }else if(strConsumer == null || strConsumer == '') {
            res.statusCode = 400;
            jsonResponse = '{"status": "Failure", "message": "Missing Required Parameter : consumer"}';
            res.responseBody = blob.valueOf(jsonResponse);
            AddApiLog.InsertAPILog(string.valueof(RestContext.request),jsonResponse,false,'createconsumerrelationship');
            return;
        }else{
            
            List<Consumer_ID__c> lstConsumerID = New List<Consumer_ID__c>();
            lstConsumerID = [select Consumer__c from Consumer_ID__c where Data_Source_ID__c =: strPatientID];
            
            if (lstConsumerID.size() == 0){
                res.statusCode = 400;
                jsonResponse = '{"status": "Failure", "message": "Related consumer not exist"}';
                res.responseBody = blob.valueOf(jsonResponse);
                AddApiLog.InsertAPILog(string.valueof(RestContext.request),jsonResponse,false,'createconsumerrelationship');
                return;
            }
            
            List<Contact> lstContact = New List<Contact>();
            lstContact = [select id from contact where id =: strConsumer];
            
            if (lstContact.size() == 0){
                res.statusCode = 400;
                jsonResponse = '{"status": "Failure", "message": "Consumer not exist"}';
                res.responseBody = blob.valueOf(jsonResponse);
                AddApiLog.InsertAPILog(string.valueof(RestContext.request),jsonResponse,false,'createconsumerrelationship');
                return;
            }
            
            Consumer_Relationship__c objConsumerRelationship = new Consumer_Relationship__c();
            
            List<Consumer_Relationship__c> lstConsumerRelationship = New List<Consumer_Relationship__c>();
            
            lstConsumerRelationship = [select id, Related_Contact__c, Consumer__c from Consumer_Relationship__c 
                                       where Related_Contact__c =: lstConsumerID[0].Consumer__c 
                                       And Consumer__c =: strConsumer];
            
            if (lstConsumerRelationship.size() > 0){
                objConsumerRelationship.id = lstConsumerRelationship[0].id;
            }else{
                objConsumerRelationship.Consumer__c = strConsumer;
            }  
            
            Savepoint sp = Database.setSavepoint();
            try {
                AddApiLog.ContactID  = lstConsumerID[0].Consumer__c;  
                objConsumerRelationship.Related_Contact__c= lstConsumerID[0].Consumer__c ;
                objConsumerRelationship.Account_Caretaker__c = blAccountCaretaker;
                objConsumerRelationship.ICE_Contact__c= blICEContact ;
                objConsumerRelationship.Relationship__c= strRelationship ;
                upsert objConsumerRelationship;
                
                res.statusCode = 200;
                jsonResponse = '{\"result\":\"Success\",';
                jsonResponse += '\"message\": \"Save Successfully\",';
                jsonResponse += '\"id\":"' + objConsumerRelationship.id  + '"}';
                res.responseBody = blob.valueOf(jsonResponse);
                if( blnSuccess == true){
                    AddApiLog.InsertAPILog(string.valueof(RestContext.request),jsonResponse,false,'createconsumerrelationship');
                }else{
                    AddApiLog.InsertAPILog(string.valueof(RestContext.request),jsonResponse,true,'createconsumerrelationship');
                }
                return;
            }catch (Exception ex) {
                Database.rollback(sp);
                res.statusCode = 500;
                jsonResponse = '{"response": {"status": "Failure", "message": "' + ex + '"}}';
                res.responseBody = blob.valueOf(jsonResponse);
                AddApiLog.InsertAPILog(string.valueof(RestContext.request),jsonResponse,false,'createconsumerrelationship');
                return;
            }
        }
        
    }
}