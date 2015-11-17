@RestResource(urlMapping='/viewcareteam/*')
global Class GetCareTeamDetails
{
    @HttpGet
    global static void GetCareTeam() 
    {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        set<string> setLoiccode = new set<string>();
        String jsonResponse = '';
        
        String strDataSourceId= req.params.get('patient_id');        
        String strDataSource = req.params.get('data_source');
        
        if(strDataSourceId == null || strDataSourceId == '') 
        {
            res.statusCode = 400;
            jsonResponse = '{"result": "Failure", "message": "Bad Request - Missing Parameters: patient_id"}';
            res.responseBody = blob.valueOf(jsonResponse);
            AddApiLog.InsertAPILog(string.valueof(RestContext.request),jsonResponse,false,'viewcareteam');
            return;
        }    
        else
        {
           jsonResponse = GetCareTeamInfo(strDataSourceId ,strDataSource);
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
            strMsg += '\"patient_id\":'+'\"'+ strDataSourceId +'\",';
            
            if(strDataSource != null && strDataSource != '' && strDataSource != 'null'){
                strMsg += '\"data_source\":'+'\"'+ strDataSource +'\",';
            }    
                  
            jsonResponse =  strMsg + jsonResponse.substring(20);
            jsonResponse  = jsonResponse.unescapeEcmaScript();
            jsonResponse  = jsonResponse.replace('"[','[');
            jsonResponse  = jsonResponse.replace(']"',']');
            res.responseBody = blob.valueOf(jsonResponse);
            AddApiLog.InsertAPILog(string.valueof(RestContext.request),jsonResponse,true,'viewcareteam'); 
            return;
        } 
        catch ( Exception ex ) 
        {
            res.statusCode = 500;
            jsonResponse = '{"result": "Failure", "message": "Server errors - ' + ex + '"}';
            res.responseBody = blob.valueOf(jsonResponse);
            AddApiLog.InsertAPILog(string.valueof(RestContext.request),jsonResponse,false,'viewcareteam');
            return;
        }
    }
    
     public static Map<string,string> getKeyValueColumns(Map<string,string> mapflds)
    {
        Map<string,string> mapfield = new map<string,string>();
        for (String fldname: mapflds.keySet()){ 
            string sobjectname = fldname;            
            Map<String, Schema.SObjectType> mapGlobalDescribe = Schema.getGlobalDescribe();   
            Schema.SObjectType objSchema = mapGlobalDescribe.get(sobjectname);
            Map<String, Schema.SObjectField> fieldMap = objSchema.getDescribe().fields.getMap();
            Set<string> setStrFld = new Set<string>();
            
            for(string strfds : mapflds.get(fldname).split('#')){
                setStrFld.add(strfds.toLowerCase());
            }
            
            for (String fieldName: fieldMap.keySet()){ 
                if(setStrFld.contains(fieldName)){
                    mapfield.put(fieldName.toLowerCase(),fieldName.substring(0,fieldName.length()-3));
                }
            }
         }
        return mapfield;
    }
    
    public static string jsonstring(WrapCareTeam wc,Map<string,string> mapfield){
        
        //system.debug('mapfield....' + mapfield);
        JSONGenerator generator = JSON.createGenerator(true);  
        generator.writeStartArray();
                                         
        if(wc.wplstActiveCareRelationship.size()>0){
            for(Active_Care_Relationship__c objes : wc.wplstActiveCareRelationship){
                generator.writeStartObject();                
                generator.writeStringField('patient_id',objes.name);

                JSONGenerator generatorchild1 = JSON.createGenerator(true);
                generatorchild1.writeStartArray();               
                generatorchild1.writeStartObject();
                generatorchild1.writeStringField('recordid',objes.id);
                generatorchild1.writeStringField('organizationname',objes.Organization__r.name);
                //generatorchild1.writeStringField('organizationid',objes.Organization__c);
                if (objes.Organization__r.Organizational_OID__c != null ) 
                    generatorchild1.writeStringField('organizationaloid',objes.Organization__r.Organizational_OID__c);
                else
                    generatorchild1.writeStringField('organizationaloid','');
                generatorchild1.writeEndObject();
                generatorchild1.writeEndArray();
                generator.writeStringField('active_care_administrator',generatorchild1.getAsString().unescapeEcmaScript());
                
                contact objContact;
                JSONGenerator generatorchild = JSON.createGenerator(true);
                JSONGenerator generatorchild2 = JSON.createGenerator(true);                                     
                 generatorchild.writeStartArray();
                 if(wc.wplstAffiliation.size() > 0) {
                     for(Affiliation__c objaff : wc.wplstAffiliation){
                         if(objaff.id == objes.Active_Care__c) {
                            generatorchild.writeStartObject();
                            objContact = objaff.Provider__r;
                            generatorchild.writeStringField('firstname',objContact.FirstName);
                            generatorchild.writeStringField('lastname',objContact.LastName);
                            if(objContact.Type__c != null)
                                generatorchild.writeStringField('type',objContact.Type__c);
                            else
                                generatorchild.writeStringField('type','');
                            if(objContact.NPI__c != null)        
                                generatorchild.writeStringField('npi',objContact.NPI__c);
                            else
                                generatorchild.writeStringField('npi','');
                                
                            if(objContact.Phone!= null)        
                                generatorchild.writeStringField('phone',objContact.Phone);
                            else
                                generatorchild.writeStringField('phone','');
        
                             if(objContact.Org_Practice_State__c != null)        
                                generatorchild.writeStringField('state',objContact.Org_Practice_State__c);
                             else
                                generatorchild.writeStringField('state','');
                                
                             if(objContact.Org_Practice_Zip__c!= null)        
                                generatorchild.writeStringField('postalcode',objContact.Org_Practice_Zip__c);
                             else
                                generatorchild.writeStringField('postalcode','');
                                
                             if(objContact.Org_Practice_Address_line_1__c!= null)        
                                generatorchild.writeStringField('address',objContact.Org_Practice_Address_line_1__c);
                             else
                                generatorchild.writeStringField('address','');
                                
                             if(objContact.Org_Practice_City__c!= null)        
                                generatorchild.writeStringField('city',objContact.Org_Practice_City__c);
                             else
                                generatorchild.writeStringField('city','');
                                
                                generatorchild.writeStringField('county','');     
                              
                             generatorchild.writeEndObject();
                            
                             generatorchild2.writeStartArray();
                             generatorchild2.writeStartObject();
                             generatorchild2.writeStringField('organizationname',objaff.Organization__r.Name);
                             //generatorchild2.writeStringField('organizationid',objaff.Organization__c);
                             if (objaff.Organization__r.Organizational_OID__c != null)
                                 generatorchild2.writeStringField('organizationaloid',objaff.Organization__r.Organizational_OID__c);
                             else
                                 generatorchild2.writeStringField('organizationaloid','');
                                 
                             generatorchild2.writeEndObject();
                           }       
                    }
                     generatorchild2.writeEndArray();
                     generator.writeStringField('care_organization',generatorchild2.getAsString().unescapeEcmaScript());  
                 
                     generatorchild.writeEndArray();
                     generator.writeStringField('care_provider',generatorchild.getAsString().replaceAll('/\n/g', '\\n').unescapeEcmaScript());
                 }else{
                     generator.writeStringField('care_organization','');              
                     generator.writeStringField('care_provider','');
                }
                generator.writeEndObject();  
            }
        }else{
            generator.writeStringField('care_organization','');              
        }
         
         generator.writeEndArray();
         return generator.getAsString();
     }
    
    public static string GetCareTeamInfo(String strDataSourceId ,string strDataSource)
    {
        String jsonResponse = '';
        String strQuery ='';
        set<id> setAffiliations = new set<id>();
        set<id> setAccountid = new set<id>();
        
        strQuery = ' select id, name, Organization__c,Organization__r.id, Organization__r.Name, Organization__r.Organizational_OID__c, ';
        strQuery += ' Active_Care__c, Consumer__c, Consumer_Name__c, Care_Provider__c from Active_Care_Relationship__c ';
        strQuery += ' where Consumer__c in  (select Consumer__c from Consumer_ID__c where Data_Source_ID__c =: strDataSourceId ';  
        
        if(strDataSource != null && strDataSource != '' && strDataSource != 'null'){
            strQuery += ' And  Data_Source__c =: strDataSource ';
        }
        strQuery += ' ) and consumer__r.recordtype.name= \'Patient\'';
        
        List<Active_Care_Relationship__c> lstActiveCareRelationship = Database.query(strQuery);
        
        WrapCareTeam wpCareTeam = new WrapCareTeam();
        
        if(lstActiveCareRelationship.size() > 0) {
            AddApiLog.ContactID  = lstActiveCareRelationship[0].Consumer__c;    
            for(Active_Care_Relationship__c objActiveCareRelationship : lstActiveCareRelationship){
                 setAffiliations.add(objActiveCareRelationship.Active_Care__c);
            }
            
            wpCareTeam.wplstActiveCareRelationship.addAll(lstActiveCareRelationship);
            
            List<Affiliation__c> lstAffiliation = new List<Affiliation__c>();
        
            lstAffiliation = [select id, name, Provider__r.id,Provider__r.Name, Organization__c, Organization__r.Name, 
                            Organization__r.Organizational_OID__c,
                            Provider__r.FirstName, Provider__r.LastName, Provider__r.Type__c, Provider__r.NPI__c, 
                            Provider__r.Phone, Provider__r.Org_Practice_State__c, Provider__r.Org_Practice_Zip__c,
                            Provider__r.Org_Practice_Address_line_1__c, Provider__r.Org_Practice_City__c,
                            (select id, name, Organization__c,Organization__r.id, Organization__r.Name, Active_Care__c, Consumer__c, Consumer_Name__c,
                            Care_Provider__c from ACRs__r where Organization__c in : setAccountid )
                            from Affiliation__c where id in :setAffiliations];
            
            if(lstAffiliation.size() > 0){
                
                 for(Affiliation__c objAffiliation :lstAffiliation){
                    for(Active_Care_Relationship__c  objActiveCareRelationship : objAffiliation.ACRs__r){
                        wpCareTeam.wplstActiveCareRelationship.add(objActiveCareRelationship);
                    }
                 }
                
                wpCareTeam.wplstAffiliation.addall(lstAffiliation);
            }
             
            Map<string,string> MapstringField = new Map<string,string>();
            Map<string,string> mapfield = new map<string,string>();
            mapfield = getKeyValueColumns(MapstringField);
            string jstr = jsonstring(wpCareTeam,mapfield);

            if(lstActiveCareRelationship.size() > 0 && wpCareTeam.wplstAffiliation.size() == 0 )
            {
                jsonResponse = '{\"result\":\"Success\",';
                jsonResponse += '\"message\": \"Not Found - No care team providers found for this consumer\",';
                jsonResponse += '\"care_team'+ '\":' + jstr + '}';  
            }
            else if(lstActiveCareRelationship.size() > 0)
            {
                jsonResponse = '{\"result\":\"Success\",';
                jsonResponse += '\"message\": \"Care team providers found\",';
                jsonResponse += '\"care_team'+ '\":' + jstr + '}';        
            }
        } else {
            jsonResponse = '{\"result\":\"Success\",';
            jsonResponse += '\"message\": \"Not Found - Patient id not found in consumer directory\"}';
           
        } 
              
         return jsonResponse;
    }
    
    
    public class WrapCareTeam 
    {
        public List<Active_Care_Relationship__c> wplstActiveCareRelationship {get;set;}
        public List<Affiliation__c> wplstAffiliation  {get;set;}

        public WrapCareTeam(){
            wplstActiveCareRelationship = new List<Active_Care_Relationship__c>();
            wplstAffiliation = new List<Affiliation__c>();
        }
    }
}