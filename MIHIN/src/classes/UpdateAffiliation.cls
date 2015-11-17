@RestResource(urlMapping='/updateaffiliation/*')
global Class UpdateAffiliation
{
    private static boolean blnSuccess {get;set;}
    @HttpGet
    global static void UpdateAffiliation() 
    {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        
        string strjsonResponse = '';
        string strrecordid = '';
        string straffinitydomain = '';
        string struniqueid = '';
        
        strrecordid = req.params.get('recordid');        
        straffinitydomain = req.params.get('affinitydomain');
        struniqueid = req.params.get('uniqueid');
        if(req.params.get('affinitydomain') == null){
            res.statusCode = 400;
            strjsonResponse = '{"result": "Failure", "message": "Bad Request - Missing Parameters: affinitydomain"}';
            res.responseBody = blob.valueOf(strjsonResponse);
            AddApiLog.InsertAPILog(string.valueof(RestContext.request),strjsonResponse,false,'updateaffiliation');
            return;
        }  
        if(req.params.get('uniqueid') == null){
            res.statusCode = 400;
            strjsonResponse = '{"result": "Failure", "message": "Bad Request - Missing Parameters: uniqueid"}';
            res.responseBody = blob.valueOf(strjsonResponse);
            AddApiLog.InsertAPILog(string.valueof(RestContext.request),strjsonResponse,false,'updateaffiliation');
            return;
        } 
        if(string.isBlank(strrecordid)) {
            res.statusCode = 400;
            strjsonResponse = '{"result": "Failure", "message": "Bad Request - Missing Parameters: recordid"}';
            res.responseBody = blob.valueOf(strjsonResponse);
            AddApiLog.InsertAPILog(string.valueof(RestContext.request),strjsonResponse,false,'updateaffiliation');
            return;
        } else {
            List<Consumer_Affiliation__c> lstCA = new List<Consumer_Affiliation__c>([select Id from Consumer_Affiliation__c  
                        where Id=:strrecordid]);
            if(lstCA.size() == 0) {
                res.statusCode = 400;
                strjsonResponse =  '{"result": "Failure", "message": "Not Found - No consumer affiliation found"}';
                res.responseBody = blob.valueOf(strjsonResponse);
                AddApiLog.InsertAPILog(string.valueof(RestContext.request),strjsonResponse,false,'updateaffiliation');
                return;
            }
        }
        if(!string.IsBlank(strrecordid)){
            strjsonResponse = UpdateAffiliationRecord(strrecordid, straffinitydomain, struniqueid);
        }
        if(strjsonResponse == null)
        {
            res.statusCode = 400;
            strjsonResponse= '{"result": "Failure", "message": "Request Failed - Parameters were valid but request failed."}';
            res.responseBody = blob.valueOf(strjsonResponse);
            AddApiLog.InsertAPILog(string.valueof(RestContext.request),strjsonResponse,false,'updateaffiliation');
            return;
        } else {
            res.statusCode = 200;
            strjsonResponse= strjsonResponse.unescapeEcmaScript();
            strjsonResponse= strjsonResponse.replace('"[','[');
            strjsonResponse= strjsonResponse.replace(']"',']');
            res.responseBody = blob.valueOf(strjsonResponse);
           
            if(blnSuccess == true){
                AddApiLog.InsertAPILog(string.valueof(RestContext.request),strjsonResponse,false,'updateaffiliation');
            }else{
                AddApiLog.InsertAPILog(string.valueof(RestContext.request),strjsonResponse,true,'updateaffiliation');
            }
            return;
        }
    }
    
    public static string jsonstring(Consumer_Affiliation__c objCAUpdated){
        JSONGenerator generator = JSON.createGenerator(true);  
        generator.writeStartArray();
        if(objCAUpdated != null) {
            generator.writeStartObject();
            generator.writeStringField('recordid',objCAUpdated.Id);
            
            if(objCAUpdated.Name != null)        
                generator.writeStringField('name',objCAUpdated.Name);
            else
                generator.writeStringField('name','');
            
            if(objCAUpdated.Unique_Id__c != null)        
                generator.writeStringField('unique_id',objCAUpdated.Unique_Id__c);
            else
                generator.writeStringField('unique_id','');

            if(objCAUpdated.Affinity_Domain__c != null)        
                generator.writeStringField('affinity_domain',objCAUpdated.Affinity_Domain__c);
            else
                generator.writeStringField('affinity_domain','');
            
            JSONGenerator generatorchild = JSON.createGenerator(true);
            generatorchild.writeStartArray();
        
            generator.writeEndObject();
        }
        
        generator.writeEndArray();
        return generator.getAsString();
    }
    
    public static string UpdateAffiliationRecord(string strrecordid, string straffinitydomain, string struniqueid) 
    {
        string strjsonResponse = '';
        try {
            if(!string.Isblank(strrecordid)) {
                List<Consumer_Affiliation__c> lstCA = new List<Consumer_Affiliation__c>([select Id from Consumer_Affiliation__c  where Id=:strrecordid]);
                if(lstCA.size() > 0){
                    Consumer_Affiliation__c objCAffiliation = new Consumer_Affiliation__c();
                    objCAffiliation.Id = lstCA[0].Id;
                    objCAffiliation.Affinity_Domain__c = straffinitydomain;
                    objCAffiliation.Unique_ID__c = struniqueid;
                    update objCAffiliation;            
                    List<Consumer_Affiliation__c> lstCAUpdated = new List<Consumer_Affiliation__c>([select Id,Name,Affinity_Domain__c ,Consumer__c,
                                                        Data_Source__c , End_Date__c , Organization__c , Organization_ID__c ,Start_Date__c ,
                                                        Unique_ID__c from Consumer_Affiliation__c Where Id =: objCAffiliation.Id Limit 1]);
                    if(lstCAUpdated.size() > 0) {
                        string tempstrjsonResponse = jsonstring(lstCAUpdated[0]);
                        strjsonResponse = '{\"result\":\"Success\",';
                        strjsonResponse += '\"message\":\"Record update successfully\",';
                        strjsonResponse += '\"consumer_affiliation'+ '\":' + tempstrjsonResponse+ '}'; 
                        blnSuccess = false;
                    }
                }   
            }
        } catch(Exception ex) {
            blnSuccess = true;
            strjsonResponse = '{\"result\":\"Failure\",';
            strjsonResponse += '\"message\": \"'+ex.getMessage()+'\"}';
        }
        return strjsonResponse ;
    }
}