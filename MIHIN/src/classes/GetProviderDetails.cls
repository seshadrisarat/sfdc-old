@RestResource(urlMapping='/viewprovider/*')
global Class GetProviderDetails
{
    @HttpGet
    global static void GetProviderDetail() 
    {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        set<string> setLoiccode = new set<string>();
        String jsonResponse = '';
        
        String strprovidername = '';
        String strprovidercity = '';
        String strproviderstate = '';
        
        String strorganizationname = '';
        String strstatus = '';
        String strtype = '';
        String strgender = '';
        String strpracticeaddress = '';
        String strspecialities = '';
        
        strprovidername = req.params.get('provider_name');        
        strprovidercity = req.params.get('provider_city');
        strproviderstate = req.params.get('provider_state');
        
        strorganizationname = req.params.get('organization_name');        
        strstatus = req.params.get('status');
        strtype = req.params.get('type');
        strgender = req.params.get('gender');        
        strpracticeaddress = req.params.get('practice_address');
        strspecialities = req.params.get('specialities');
        
        //List<string> lstparam = new List<string>();
        
        if(strprovidername == null || strprovidername == '') {
            res.statusCode = 400;
            jsonResponse = '{"result": "Failure", "message": "Bad Request - Missing Parameters: provider_name"}';
            res.responseBody = blob.valueOf(jsonResponse);
            AddApiLog.InsertAPILog(string.valueof(RestContext.request),jsonResponse,false,'viewprovider');
            return;
        } else if(strprovidercity == null || strprovidercity == '') {
            res.statusCode = 400;
            jsonResponse = '{"result": "Failure", "message": "Bad Request - Missing Parameters: provider_city"}';
            res.responseBody = blob.valueOf(jsonResponse);
            AddApiLog.InsertAPILog(string.valueof(RestContext.request),jsonResponse,false,'viewprovider');
            return;
        } else if(strproviderstate == null || strproviderstate == '') {
            res.statusCode = 400;
            jsonResponse = '{"result": "Failure", "message": "Bad Request - Missing Parameters: provider_state"}';
            res.responseBody = blob.valueOf(jsonResponse);
            AddApiLog.InsertAPILog(string.valueof(RestContext.request),jsonResponse,false,'viewprovider');
            return;
        } else {
            jsonResponse = GetGetProviderInfo(strprovidername,strprovidercity,strproviderstate,strorganizationname,
                                              strstatus,strtype,strgender,strpracticeaddress,strspecialities);
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
            strMsg += '\"provider_name\":'+'\"'+ strprovidername +'\",';
            
           /*if(strprovidercity != null && strprovidercity == '')
                strMsg += '\"provider_city\":'+'\"'+ strprovidercity +'\",';
            
           if(strproviderstate != null && strproviderstate == '')        
                strMsg += '\"provider_state\":'+'\"'+ strproviderstate +'\",';
        
           if(strstatus != null && strstatus != '')
                 strMsg += '\"status\":'+'\"'+ strstatus +'\",';
        
           if(strtype != null && strtype != '')
                 strMsg += '\"type\":'+'\"'+ strtype +'\",';
             
           if(strgender != null && strgender != '')
                 strMsg += '\"gender\":'+'\"'+ strgender +'\",';
           
           if(strpracticeaddress != null && strpracticeaddress != '')
                 strMsg += '\"practice_address\":'+'\"'+ strpracticeaddress +'\",';      */
                  
            jsonResponse =  strMsg + jsonResponse.substring(20);
            jsonResponse  = jsonResponse.unescapeEcmaScript();
            jsonResponse  = jsonResponse.replace('"[','[');
            jsonResponse  = jsonResponse.replace(']"',']');
            res.responseBody = blob.valueOf(jsonResponse);
            AddApiLog.InsertAPILog(string.valueof(RestContext.request),jsonResponse,true,'viewprovider');
            return;
        } 
        catch ( Exception ex ) 
        {
            res.statusCode = 500;
            jsonResponse = '{"result": "Failure", "message": "Server errors - ' + ex + '"}';
            res.responseBody = blob.valueOf(jsonResponse);
            AddApiLog.InsertAPILog(string.valueof(RestContext.request),jsonResponse,false,'viewprovider');
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
        
        JSONGenerator generator = JSON.createGenerator(true);  
        generator.writeStartArray();

        for(contact objcon : wc.wplsContact){
            
            generator.writeStartObject();
            generator.writeStringField('name',objcon.Name);
            
            if(objcon.Org_Practice_State__c != null)        
                generator.writeStringField('state',objcon.Org_Practice_State__c);
            else
                generator.writeStringField('state','');
            
            if(objcon.Org_Practice_Zip__c!= null)        
                generator.writeStringField('postalcode',objcon.Org_Practice_Zip__c);
            else
                generator.writeStringField('postalcode','');
            
            if(objcon.Org_Practice_Address_line_1__c!= null)        
                generator.writeStringField('address',objcon.Org_Practice_Address_line_1__c);
            else
                generator.writeStringField('address','');
            
            if(objcon.Org_Practice_City__c!= null)        
                generator.writeStringField('city',objcon.Org_Practice_City__c);
            else
                generator.writeStringField('city','');
                        
            JSONGenerator generatorchild = JSON.createGenerator(true);
            generatorchild.writeStartArray();
        
            if(wc.wplstAffiliation.size() > 0) {
                for(Affiliation__c objaff : wc.wplstAffiliation){
                    
                    if(objcon.id == objaff.provider__c){
                        generatorchild.writeStartObject();
                        generatorchild.writeStringField('recordid',objaff.id);
                        generatorchild.writeStringField('providerid',objaff.provider__c);
                        generatorchild.writeStringField('name',objaff.Name);
                        generatorchild.writeStringField('organization',objaff.Organization__c);
                        generatorchild.writeStringField('organizationname',objaff.Organization__r.Name);
                        
                        if(objaff.Type__c != null)
                            generatorchild.writeStringField('type',objaff.Type__c);
                        else
                            generatorchild.writeStringField('type','');
                        
                        if(objaff.Phone__c != null)
                            generatorchild.writeStringField('phone',objaff.Phone__c);
                        else    
                            generatorchild.writeStringField('phone','');
                            
                        /*if(wc.wplstActiveCareRelationship.size() > 0) {
                            for(Active_Care_Relationship__c objAcr : wc.wplstActiveCareRelationship){
                                    generatorchild.writeStringField('patientid ',objAcr.Name);
                                    generatorchild.writeStringField('activecareadministrator',objAcr.Organization__c);
                                    generatorchild.writeStringField('activecareadministratorname',objAcr.Organization__r.Name);
                            }
                        }else{
                              generatorchild.writeStringField('patientid','');
                              generatorchild.writeStringField('activecareadministrator','');
                              generatorchild.writeStringField('activecareadministratorname','');  
                        }  */ 
                             
                        generatorchild.writeEndObject();
                  }          
                }       
                generatorchild.writeEndArray();
                generator.writeStringField('care_provider',generatorchild.getAsString().replaceAll('/\n/g', '\\n').unescapeEcmaScript());
            }else{
                generator.writeStringField('care_provider','');              
            }
            
            JSONGenerator generatorspe = JSON.createGenerator(true);
            generatorspe.writeStartArray();
        
            if(wc.wpProviderSpecialty.size() > 0) {
                for(Provider_Specialty__c objProviderSpecialty : wc.wpProviderSpecialty){
                    if(objcon.id == objProviderSpecialty.provider__c){
                        generatorspe.writeStartObject();
                        generatorspe.writeStringField('specialities',objProviderSpecialty.Specialty__r.Name);
                        generatorspe.writeEndObject();
                    }    
                }       
                generatorspe.writeEndArray();
                generator.writeStringField('specialities',generatorspe.getAsString().replaceAll('/\n/g', '\\n').unescapeEcmaScript());
            }else{
                generator.writeStringField('specialities','');              
            }
            
            generator.writeEndObject();
        }
        
        generator.writeEndArray();
        return generator.getAsString();
     }
    
    public static string GetGetProviderInfo(String strprovidername,String strprovidercity, 
                                            String strproviderstate, String strorganizationname, 
                                            String strstatus, string strtype, String strgender, 
                                            String strpracticeaddress, String strspecialities)
    {
        String jsonResponse = '';
        String strQuery ='';
        set<string> setAffiliationID = new set<string>();
        
        strQuery = 'select id, Name, accountid, account.name,  FirstName, LastName, Type__c, NPI__c, Phone, '; 
        strQuery += ' Org_Practice_State__c, Org_Practice_Zip__c, gender__c, Org_Practice_Address_line_1__c, Org_Practice_City__c,';
        strQuery += ' (select id, name, provider__c, Organization__c, Organization__r.Name, Data_Source__c, Data_Source_ID__c, Type__c, ';
        strQuery += ' Phone__c from Affiliations__r ';
        
        if(strorganizationname != null && strorganizationname != '')
             strQuery += ' where Organization__r.Name Like \'%' + strorganizationname + '%\'' ;
             
        strQuery += ')' ;
        
        /* Practice Address */
        if(strpracticeaddress != null && strpracticeaddress != ''){
            strQuery += ',(select id, name, Street_Address_1__c, City__c';
            strQuery += ' from Provider_Addresses__r where Type__c = \'Practice\' ';
            strQuery += ' and ( Street_Address_1__c Like \'%' + strpracticeaddress + '%\'' ;
            strQuery += ' or City__c Like \'%' + strpracticeaddress + '%\'' ;
            strQuery += ' or State__c Like \'%' + strpracticeaddress + '%\'' ;
            strQuery += ' or Postal_Code__c Like \'%' + strpracticeaddress + '%\')' ;
            strQuery += ' )';
        }
        
        /* Specialities  */
        if(strspecialities != null && strpracticeaddress != ''){
            strQuery += ',(select id, name, provider__c, Specialty__c, Specialty__r.Name ';
            strQuery += ' from Provider_Specialties__r';
            strQuery += ' where Specialty__r.Name Like \'%' + strspecialities + '%\' ) ' ;
        }    
        
        strQuery += ' from contact where RecordType.Name= \'Provider\' ';
        strQuery += ' and Name Like \'%' + strprovidername + '%\' ' ;
        
        if(strprovidercity != null && strprovidercity != '')
            strQuery += ' and Org_Practice_City__c Like \'%' + strprovidercity + '%\'';
            
        if(strproviderstate != null && strproviderstate != '')        
            strQuery += ' and Org_Practice_State__c Like \'%' + strproviderstate + '%\'' ;
        
        if(strstatus != null && strstatus != '')
             strQuery += ' and Status__c Like \'%' + strstatus + '%\'';
        
        if(strtype != null && strtype != '')
             strQuery += ' and Type__c Like \'%' + strtype + '%\'';
             
        if(strgender != null && strgender != '')
             strQuery += ' and gender__c Like \'%' + strgender + '%\'';          
        
        List<Contact> lstContact = Database.query(strQuery);
        
        system.debug('lstContact !!!'  +lstContact);
        system.debug('strQuery !!!'  +strQuery);        
        
        WrapCareTeam wpCareTeam = new WrapCareTeam();
        
         if(lstContact.size() > 0){
         
            for(Contact objContact : lstContact){
                for(Affiliation__c objAffiliation : objContact.Affiliations__r){
                   setAffiliationID.add(objAffiliation.id); 
                   wpCareTeam.wplstAffiliation.add(objAffiliation);                 
                }
                
                for(Provider_Specialty__c objProviderSpecialty : objContact.Provider_Specialties__r){
                    wpCareTeam.wpProviderSpecialty.add(objProviderSpecialty);
                }
            }
            
            List<Active_Care_Relationship__c> lstActiveCareRelationship = new List<Active_Care_Relationship__c>();
            
            lstActiveCareRelationship = [select id, Name, Organization__c, Organization__r.Name
                                         from Active_Care_Relationship__c where Active_Care__c in :setAffiliationID];
                                     
            wpCareTeam.wplstActiveCareRelationship.addall(lstActiveCareRelationship);                             
                                
            wpCareTeam.wplsContact.addall(lstContact);
            
            Map<string,string> MapstringField = new Map<string,string>();
            Map<string,string> mapfield = new map<string,string>();
            mapfield = getKeyValueColumns(MapstringField);
            string jstr = jsonstring(wpCareTeam,mapfield);

            if(lstContact.size() > 0)
            {
                jsonResponse = '{\"result\":\"Success\",';
                jsonResponse += '\"message\": \"Providers found\",';
                jsonResponse += '\"provider'+ '\":' + jstr + '}';    
                AddApiLog.ContactID  = lstContact[0].id;        
            }
        } else {
            jsonResponse = '{\"result\":\"Success\",';
            jsonResponse += '\"message\": \"Not Found - Patient id not found in consumer directory\"}';
        } 
              
         return jsonResponse;
    }
    
    
    public class WrapCareTeam 
    {
        public List<Contact> wplsContact {get;set;}
        public List<Affiliation__c> wplstAffiliation  {get;set;}
        public List<Provider_Address__c> wpProviderAddress {get;set;}
        public List<Provider_Specialty__c> wpProviderSpecialty {get;set;}
        public List<Active_Care_Relationship__c> wplstActiveCareRelationship {get;set;}

        public WrapCareTeam(){
            wplsContact = new List<Contact>();
            wplstAffiliation = new List<Affiliation__c>();
            wpProviderAddress = new List<Provider_Address__c>();  
            wpProviderSpecialty  = new List<Provider_Specialty__c>();
            wplstActiveCareRelationship = new List<Active_Care_Relationship__c>();
        }
    }
}