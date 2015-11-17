@RestResource(urlMapping='/getconsumerrelation')
global class ConsumerRelationInfo  {

    public ConsumerRelationInfo(){
    
    }
    private static boolean blnSuccess {get;set;}
    @HttpGet
    global static void GetConsumerRelationDetails(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        
        String jsonResponse = '';
        boolean blICEContact = true;
        boolean blAccountCaretaker =true;
        
        String strPatientid = req.params.get('patient_id');
         if (req.params.get('icecontact') != null)
            blICEContact = Boolean.valueof(req.params.get('icecontact'));
        if (req.params.get('acccaretaker') != null)    
            blAccountCaretaker =Boolean.valueof(req.params.get('acccaretaker'));
        
        if(strPatientid == null || strPatientid == ''){
            res.statusCode = 400;
            jsonResponse = '{"status": "Failure", "message": "Missing Required Parameter : patient_id"}';
            res.responseBody = blob.valueOf(jsonResponse);
            AddApiLog.InsertAPILog(string.valueof(RestContext.request),jsonResponse,false,'getconsumerrelation');
            return;
        }else{
            jsonResponse =  GetCRDetails(strPatientid,blICEContact,blAccountCaretaker);
        }
        
        try {
            res.statusCode = 200;
            string strMsg='';
            JSONParser parser = JSON.createParser(jsonResponse);
            string strMessage = '';
            while (parser.nextToken() != null){
                if ((parser.getText() == 'result')){
                    parser.nextToken();
                    strMessage = parser.getText();
                }
            }

            jsonResponse  = jsonResponse.unescapeEcmaScript();
            jsonResponse  = jsonResponse.replace('"[','[');
            jsonResponse  = jsonResponse.replace(']"',']');
            res.responseBody = blob.valueOf(jsonResponse);
            
            if(blnSuccess == true)
                AddApiLog.InsertAPILog(string.valueof(RestContext.request),jsonResponse,false,'getconsumerrelation');
            else
                AddApiLog.InsertAPILog(string.valueof(RestContext.request),jsonResponse,true,'getconsumerrelation');
                
            return;
            
        }catch ( Exception ex ){
            res.statusCode = 500;
            jsonResponse = '{"status": "Failure", "message": "' + ex + '"}';
            res.responseBody = blob.valueOf(jsonResponse);
            AddApiLog.InsertAPILog(string.valueof(RestContext.request),jsonResponse,false,'getconsumerrelation');
            return;
        }
       
    }
    
     public static Map<string,Map<string,string>> getKeyValueColumns(Map<string,string> mapflds)
    {
        Map<string,Map<string,string>> mapfieldwithObject = new Map<string,Map<string,string>>();
        for (String fldname: mapflds.keySet()){ 
            string sobjectname = fldname;
            Map<String, Schema.SObjectType> mapGlobalDescribe = Schema.getGlobalDescribe();   
            Schema.SObjectType objSchema = mapGlobalDescribe.get(sobjectname);
            Map<String, Schema.SObjectField> fieldMap = objSchema.getDescribe().fields.getMap();
            Set<string> setStrFld = new Set<string>();
            Map<string,string> mapfield = new map<string,string>();
                         
            for(string strfds : mapflds.get(fldname).split('#')){
                    setStrFld.add(strfds.toLowerCase());
            }
            
            for (String fieldName: fieldMap.keySet()){ 
                if(setStrFld.contains(fieldName)){
                     if(fieldName.length() > 4)
                        mapfield.put(fieldName.toLowerCase(),fieldName.substring(0,fieldName.length()-3));
                     else
                        mapfield.put(fieldName.toLowerCase(),fieldName);
                }
            }
            mapfieldwithObject.put(sobjectname,mapfield);
         }
        return mapfieldwithObject;
    }

     public static string jsonstring(List<Consumer_Relationship__c> lst, Map<string,Map<string,string>> mapfield1){

        Map<string,string> mapfield = new Map<string,string>();
        for(string str: mapfield1.keySet()){
            for(string str1: mapfield1.get(str).keyset()){
                mapfield.put(str1,mapfield1.get(str).get(str1));
            }    
        }
        
        JSONGenerator generator = JSON.createGenerator(true);  
        generator.writeStartArray();
        for(Consumer_Relationship__c objConsumerRelationship : lst){
            generator.writeStartObject();
            generator.writeStringField('related_contact_name',objConsumerRelationship.Related_Contact__r.Name);
            generator.writeStringField('consumer_name',objConsumerRelationship.Consumer__r.Name);
            for(string str: mapfield.keySet()){
                try{
                    if(string.valueof(objConsumerRelationship.get(str)) != null)
                         generator.writeStringField(mapfield.get(str.toLowerCase()),string.valueof(objConsumerRelationship.get(str)));
                }catch(Exception ex){}
             }
            generator.writeEndObject();   
         }    
         generator.writeEndArray();
         return generator.getAsString();
     }
       
    public static string GetCRDetails(string strPatientid, boolean blnICEContactm, boolean blnAccountCaretaker){
        string jsonResponse = '';
        string strRelatedContact = '';
        
        List<Consumer_ID__c> lstConsumerID = New List<Consumer_ID__c>();
        lstConsumerID = [select Consumer__c from Consumer_ID__c where Data_Source_ID__c =: strPatientID];
            
        if (lstConsumerID.size() > 0){

            strRelatedContact = lstConsumerID[0].Consumer__c;
            AddApiLog.ContactID  = lstConsumerID[0].Consumer__c;    
            List <Consumer_Relationship__c> lstConsumerRelationship = new List<Consumer_Relationship__c>();
                
            lstConsumerRelationship = [SELECT Id, Name, Account_Caretaker__c, Consumer__c, Related_Contact__c, ICE_Contact__c,
                                       Relationship__c,  Consumer__r.Name, Related_Contact__r.Name
                                       FROM Consumer_Relationship__c 
                                       where Related_Contact__c =: strRelatedContact and ICE_Contact__c =: blnICEContactm
                                       and Account_Caretaker__c =: blnAccountCaretaker]; 
        
            if(lstConsumerRelationship.size() > 0)
            {
                Map<string,string> MapstringField = new Map<string,string>();
                MapstringField.put('Consumer_Relationship__c','Id#Name#Account_Caretaker__c#Consumer__c#Related_Contact__c#ICE_Contact__c');
                Map<string,Map<string,string>> mapfield = new Map<string,Map<string,string>>();
                mapfield = getKeyValueColumns(MapstringField);
                string jstr = jsonstring(lstConsumerRelationship,mapfield);
                
                jsonResponse = '{\"result\":\"Success\",';
                jsonResponse += '\"message\":\"Consumer relationship found\",';
                jsonResponse += '\"consumer_relationship\":' + jstr + '}';
                blnSuccess = false;
            }else{
                blnSuccess = true;
                jsonResponse = '{\"result\":\"Failure\",';
                jsonResponse += '\"message\":\"Consumer relationship not found\"}';
                
            }
        } else {    
            blnSuccess = true;
            jsonResponse = '{\"result\":\"Failure\",';
            jsonResponse += '\"message\":\"Related consumer not found\"}';
            
        }    
        
        return jsonResponse;               
    }
}