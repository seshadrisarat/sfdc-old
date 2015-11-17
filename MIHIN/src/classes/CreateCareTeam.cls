@RestResource(urlMapping='/createcareteam/*')
global Class CreateCareTeam
{
    private static boolean blnSuccess {get;set;}
    @HttpGet
    global static void InsertCareTeam() 
    {
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        
        string strjsonResponse = '';
        string strpatientid = ''; // entered by user any text
        string stractivecareadmin = ''; // account lookup
        string strconsumer = ''; // contact lookup.
        string stractivecareaff = ''; // provider affiliation lookup.
        
        strpatientid = req.params.get('patientid');        
        stractivecareadmin = req.params.get('activecareadmin');
        strconsumer = req.params.get('consumer');
        stractivecareaff = req.params.get('activecareaff');
        
        if(strpatientid == null || strpatientid == '') {
            res.statusCode = 400;
            strjsonResponse = '{"result": "Failure", "message": "Bad Request - Missing Parameters: patientid"}';
            res.responseBody = blob.valueOf(strjsonResponse);
            AddApiLog.InsertAPILog(string.valueof(RestContext.request),strjsonResponse,false,'createcareteam');
            return;
        } 
        if(stractivecareadmin == null || stractivecareadmin == '') {
            res.statusCode = 400;
            strjsonResponse = '{"result": "Failure", "message": "Bad Request - Missing Parameters: activecareadmin"}';
            res.responseBody = blob.valueOf(strjsonResponse);
            AddApiLog.InsertAPILog(string.valueof(RestContext.request),strjsonResponse,false,'createcareteam');
            return;
        } else if(stractivecareadmin != null) {
            List<Account> objOrg = new List<Account>([select Id from Account Where Id =: stractivecareadmin Limit 1]);
            if(objOrg.size() == 0) {
                res.statusCode = 400;
                strjsonResponse = '{"result": "Failure", "message": "Not Found - No care administrator found"}';
                res.responseBody = blob.valueOf(strjsonResponse);
                AddApiLog.InsertAPILog(string.valueof(RestContext.request),strjsonResponse,false,'createcareteam');
                return;
            }
        }
        if(strconsumer == null || strconsumer == '') {
            res.statusCode = 400;
            strjsonResponse = '{"result": "Failure", "message": "Bad Request - Missing Parameters: consumer"}';
            res.responseBody = blob.valueOf(strjsonResponse);
            AddApiLog.InsertAPILog(string.valueof(RestContext.request),strjsonResponse,false,'createcareteam');
            return;
        } else if(strconsumer != null) {
            List<Contact> objCon = new List<Contact>([select Id from Contact Where Id =: strconsumer Limit 1]);
            if(objCon.size() == 0) {
                res.statusCode = 400;
                strjsonResponse = '{"result": "Failure", "message": "Not Found - No consumer found"}';
                res.responseBody = blob.valueOf(strjsonResponse);
                AddApiLog.InsertAPILog(string.valueof(RestContext.request),strjsonResponse,false,'createcareteam');
                return;
            }
        }
        if(stractivecareaff == null || stractivecareaff == '') {
            res.statusCode = 400;
            strjsonResponse = '{"result": "Failure", "message": "Bad Request - Missing Parameters: activecareaff"}';
            res.responseBody = blob.valueOf(strjsonResponse);
            AddApiLog.InsertAPILog(string.valueof(RestContext.request),strjsonResponse,false,'createcareteam');
            return;
        } else if(stractivecareaff  != null) {
            List<Affiliation__c> objAff = new List<Affiliation__c>([select Id from Affiliation__c Where Id =: stractivecareaff Limit 1]);
            if(objAff.size() == 0) {
                res.statusCode = 400;
                strjsonResponse = '{"result": "Failure", "message": "Not Found - No active care affiliation found"}';
                res.responseBody = blob.valueOf(strjsonResponse);
                AddApiLog.InsertAPILog(string.valueof(RestContext.request),strjsonResponse,false,'createcareteam');
                return;
            }
        }
        if(strpatientid != '' && stractivecareadmin != '' && strconsumer != '' && stractivecareaff != ''){
            strjsonResponse = InsertCareTeamRecord(strpatientid,stractivecareadmin,strconsumer,stractivecareaff);
        }
        if(strjsonResponse == null)
        {
            res.statusCode = 400;
            strjsonResponse= '{"result": "Failure", "message": "Request Failed - Parameters were valid but request failed."}';
            res.responseBody = blob.valueOf(strjsonResponse);
            AddApiLog.InsertAPILog(string.valueof(RestContext.request),strjsonResponse,false,'createcareteam');
            return;
        } else {
            //strjsonResponse= strjsonResponse.unescapeEcmaScript();
            
            res.statusCode = 200;
            string strMsg='';
            JSONParser parser = JSON.createParser(strjsonResponse);
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
            strMsg += '\"patientid\":'+'\"'+ strpatientid +'\",';
            strMsg += '\"activecareadministrator\":'+'\"'+ stractivecareadmin +'\",';
            strMsg += '\"consumer\":'+'\"'+ strconsumer +'\",';
            strMsg += '\"activecareaffiliation\":'+'\"'+ stractivecareaff +'\",';
            strjsonResponse=  strMsg + strjsonResponse.substring(20);
            strjsonResponse= strjsonResponse.unescapeEcmaScript();
            //strjsonResponse= strjsonResponse.replace('"[','[');
            //strjsonResponse= strjsonResponse.replace(']"',']');
            res.responseBody = blob.valueOf(strjsonResponse);
           
            if(blnSuccess == true){
                AddApiLog.InsertAPILog(string.valueof(RestContext.request),strjsonResponse,false,'createcareteam');
            }else{
                AddApiLog.InsertAPILog(string.valueof(RestContext.request),strjsonResponse,true,'createcareteam');
            }
        
        
            return;
        }
    }
    
    public static string jsonstring(List<Active_Care_Relationship__c> lstACR){
        
        JSONGenerator generator = JSON.createGenerator(true);  
        generator.writeStartArray();

        for(Active_Care_Relationship__c objacr : lstACR){
            generator.writeStartObject();
            generator.writeStringField('id',objacr.Id);
            generator.writeStringField('patientid',objacr.Name);
            if(objacr.Consumer_Name__c != null)        
                generator.writeStringField('consumername',objacr.Consumer__r.Name);
            else
                generator.writeStringField('consumername','');
            if(objacr.Active_Care__c != null)        
                generator.writeStringField('activecareaffiliation',objacr.Active_Care__c);
            else
                generator.writeStringField('activecareaffiliation','');
            if(objacr.Organization__c != null)        
                generator.writeStringField('activecareadministrator',objacr.Organization__c);
            else
                generator.writeStringField('activecareadministrator','');
            if(objacr.Care_Organization__c != null)        
                generator.writeStringField('careorganization',objacr.Care_Organization__c);
            else
                generator.writeStringField('careorganization','');
            if(objacr.Care_Provider__c != null)        
                generator.writeStringField('careprovider',objacr.Active_Care__r.Provider__r.Name);
            else
                generator.writeStringField('careprovider','');

            generator.writeEndObject();
        }
        
        generator.writeEndArray();
        return generator.getAsString();
    }
    
    public static string InsertCareTeamRecord(string patientid, string stractivecareadmin, string strconsumer, string stractivecareaff) 
    {
        string strjsonResponse = '';
        
        try {
            Active_Care_Relationship__c objACR = new Active_Care_Relationship__c();
            objACR.Name = patientid;
            objACR.Organization__c = stractivecareadmin;
            objACR.Active_Care__c = stractivecareaff;
            objACR.Consumer__c = strconsumer;
            AddApiLog.ContactID  = strconsumer ;
            insert objACR;
            List<Active_Care_Relationship__c> lstACR = new List<Active_Care_Relationship__c>([select Id,Name,Organization__c,Active_Care__c,
                                                Care_Organization__c, Care_Provider__c, Consumer__c, Consumer_Name__c,Consumer__r.Name,
                                                Active_Care__r.Provider__r.Name from Active_Care_Relationship__c Where Id =: objACR.Id Limit 1]);
            
            if(lstACR != null) {
                string tempstrjsonResponse = jsonstring(lstACR);
                strjsonResponse = '{\"result\":\"Success\",';
                strjsonResponse += '\"message\":\"Record save successfully\",';
                strjsonResponse += '\"careteam'+ '\":' + tempstrjsonResponse+ '}'; 
                blnSuccess = false;
            }
            //strjsonResponse = '{\"result\":\"Success\",';
            //strjsonResponse += '\"message\": \"[patientid: '+patientid+',\n activecareadministrator: '+stractivecareadmin+',\n consumer: '+strconsumer+', \n activecareaffiliation: '+stractivecareaff+' ]\"}';
            
        } catch(Exception ex) {
            blnSuccess = true;
            strjsonResponse = '{\"result\":\"Failure\",';
            strjsonResponse += '\"message\": \"'+ex.getMessage()+'\"}';
        }
       
        return strjsonResponse ;
    }
}