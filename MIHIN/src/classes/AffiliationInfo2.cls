@RestResource(urlMapping='/Affiliations2/*')
global Class AffiliationInfo2
{
    private static boolean blnSuccess {get;set;}
    
    @HttpGet
    global static void GetPatientInfo() 
    {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        set<string> setLoiccode = new set<string>();
        String jsonResponse = '';
        
        String strPatinetNo = req.params.get('patient_id');
        String strConsIdAffinityDomain = req.params.get('consumer_id_affinity_domain');
        String strAffinityDomain = req.params.get('affinity_domain');
        String strLoincCode = req.params.get('loinc_code');
        
        if(strLoincCode != '' && strLoincCode != null && strLoincCode.tolowercase()  != 'null'){
            if (strLoincCode.contains('~')){
                for(string strLoincCd : strLoincCode.split('~')){
                        setLoiccode.add(strLoincCd);
                    }
            }else{
                setLoiccode.add(strLoincCode);
            }
        }     
        
        if(strPatinetNo == null || strPatinetNo == '') 
        {
            res.statusCode = 400;
            jsonResponse = '{"result": "Failure", "patient_id" : "", "affinity_domain" :'+'"'+strAffinityDomain +'"'+',"message": "Missing Required Query Parameter: patient_id"}';
            res.responseBody = blob.valueOf(jsonResponse);
            AddApiLog.InsertAPILog(string.valueof(RestContext.request),jsonResponse,false,'Affiliations');
            return;
        }
        else if(strConsIdAffinityDomain == null || strConsIdAffinityDomain == '') 
        {
            res.statusCode = 400;
            jsonResponse = '{"result": "Failure", "patient_id" :'+'"'+strPatinetNo+'"'+',"consumer_id_affinity_domain" : "", "message": "Missing Required Query Parameter: consumer_id_affinity_domain"}';
            res.responseBody = blob.valueOf(jsonResponse);
            AddApiLog.InsertAPILog(string.valueof(RestContext.request),jsonResponse,false,'Affiliations');
            return;
        }
        else
        {
           jsonResponse = getPatientDetail(strPatinetNo,strAffinityDomain,strConsIdAffinityDomain,setLoiccode);
        }
        
        if(jsonResponse == null)
        {
            res.statusCode = 400;
            jsonResponse = '{"result": "Failure", "message": "json Response not found"}';
            res.responseBody = blob.valueOf(jsonResponse);
            AddApiLog.InsertAPILog(string.valueof(RestContext.request),jsonResponse,false,'Affiliations');
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
            strMsg += '\"patient_id\":'+'\"'+strPatinetNo+'\",';
            strMsg += '\"consumer_id_affinity_domain\":'+'\"'+strConsIdAffinityDomain+'\",';
            if (strAffinityDomain != null && strAffinityDomain.tolowercase() != 'null' && strAffinityDomain != '')
                strMsg += '\"affinity_domain\":'+'\"'+strAffinityDomain+'\",';
            if (strLoincCode != null && strLoincCode.tolowercase() != 'null' && strLoincCode != '')
                strMsg += '\"loinc_code\":'+'\"'+strLoincCode +'\",'; 
           
                
            jsonResponse =  strMsg + jsonResponse.substring(20);
            jsonResponse  = jsonResponse.unescapeEcmaScript();
            jsonResponse  = jsonResponse.replace('"[','[');
            jsonResponse  = jsonResponse.replace(']"',']');
            res.responseBody = blob.valueOf(jsonResponse);
            
            if(blnSuccess == true){
                AddApiLog.InsertAPILog(string.valueof(RestContext.request),jsonResponse,false,'Affiliations');
            }else{
                AddApiLog.InsertAPILog(string.valueof(RestContext.request),jsonResponse,true,'Affiliations');
            }
            
            return;
        } 
        catch ( Exception ex ) 
        {
            res.statusCode = 500;
            jsonResponse = '{"result": "Failure", "message": "' + ex + '"}';
            res.responseBody = blob.valueOf(jsonResponse);
            AddApiLog.InsertAPILog(string.valueof(RestContext.request),jsonResponse,false,'Affiliations');
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
                    if(fieldName.toLowerCase() == 'id')
                        mapfield.put(fieldName.toLowerCase(),fieldName.substring(0,fieldName.length()));
                    else
                        mapfield.put(fieldName.toLowerCase(),fieldName.substring(0,fieldName.length()-3));
                }
            }
         }
         
        return mapfield;
    }
    
     public static string jsonstring(WrapAffContProfile wc,Map<string,string> mapfield,Map<id,List<Electronic_Service__c>> mpes){
        JSONGenerator generator = JSON.createGenerator(true);  
        generator.writeStartArray();
        
        for(wrpca objwrpca : wc.ca){
            Consumer_Affiliation__c objca = objwrpca.lstca;
            if(mpes.containskey(objca.id)){
                wc.es = mpes.get(objca.id);
            } else {
                wc.es = new List<Electronic_Service__c>();
            }
            
            if((objca.Affinity_Domain__c != null || objca.Organization_ID__c != null || objca.Unique_ID__c != null) && wc.es != null && wc.es.size() > 0 ){
                generator.writeStartObject();
                
                for(string str: mapfield.keySet()){
                    try{
                        if(str.toLowerCase() == 'id'){
                            generator.writeStringField('recordid',(String)objca.get(str));
                            continue;
                        }
                        if((String)objca.get(str) != null)                        
                             generator.writeStringField(mapfield.get(str.toLowerCase()),(String)objca.get(str));
                    }catch(Exception ex){}
                }
                
                string strLOINCCode='';    
                
                if(objwrpca.strLoinc != null && objwrpca.strLoinc != '')
                    generator.writeStringField('loinc_code',objwrpca.strLoinc);
                else
                    generator.writeStringField('loinc_code','NULL');
                    
                JSONGenerator generatorchild = JSON.createGenerator(true);  
                generatorchild.writeStartArray();
                
                for(Electronic_Service__c objes:wc.es){
                    generatorchild.writeStartObject();
                    for(string str: mapfield.keySet()){
                        try{
                            if(str.toLowerCase() == 'id'){
                                generatorchild.writeStringField('recordid',(String)objes.get(str));
                                continue;
                            }
                            if((String)objes.get(str) != null){                          
                              generatorchild.writeStringField(mapfield.get(str.toLowerCase()),(String)objes.get(str));
                            }
                        }catch(Exception ex){}
                    }
                    generatorchild.writeEndObject();
                }
                generatorchild.writeEndArray();
                generator.writeStringField('endpoint',generatorchild.getAsString().unescapeEcmaScript());
                generator.writeEndObject();
            }
         }
         generator.writeEndArray();
         return generator.getAsString();
     }
             
    public static string getPatientDetail(String strPatientId,string strAffinityDomain, string strConsIdAffinityDomain, set<string> strLoincCode)
    {
        String jsonResponse = '';
        List<Content_Profile__c> lstCP;
        list<Contact> lstContact = new list<Contact>([
                                        SELECT ID, Patient_ID__c, Name, Account.ID 
                                        FROM Contact 
                                        where id in (select Consumer__c from Consumer_ID__c where Data_Source_ID__c =:strPatientId
                                                     and Consumer_ID_Affinity_Domain__c =: strConsIdAffinityDomain)
                                        ]);
    
        if(lstContact.size() > 0)
        {
                AddApiLog.ContactID  = lstContact[0].id;    
                set<id> setConsumerID = new set<id>();
                set<id> setAccountID = new set<id>();
                
                for(Contact objContact : lstContact){
                       if(!setConsumerID.contains(objContact.Id))
                           setConsumerID.Add(objContact.Id);
                       
                        if(!setAccountID.contains(objContact.Account.ID))
                           setAccountID.Add(objContact.Account.ID);    
                }
                
                List<Consumer_Affiliation__c> lst = new List<Consumer_Affiliation__c>();
    
                if (strAffinityDomain != null && strAffinityDomain != '') {
                    lst =  [select id,Affinity_Domain__c,Organization_ID__c, Unique_ID__c,Organization__c,
                            (select id,Electronic_Service__c,Electronic_Service__r.Service_Type__c, Electronic_Service__r.Address__c
                            from Consumer_Affiliation_Services__r)
                            from Consumer_Affiliation__c
                            where Consumer__c IN :setConsumerID and Affinity_Domain__c =: strAffinityDomain];
                } else {
                    lst =  [select id,Affinity_Domain__c,Organization_ID__c, Unique_ID__c,Organization__c,
                        (select id,Electronic_Service__c,Electronic_Service__r.Service_Type__c, Electronic_Service__r.Address__c
                        from Consumer_Affiliation_Services__r)
                        from Consumer_Affiliation__c where Consumer__c IN :setConsumerID];
                }
                
                //set for es
                set<id> setESids = new set<id>();
                for(Consumer_Affiliation__c objca : lst){
                    for(Consumer_Affiliation_Service__c objcas : objca.Consumer_Affiliation_Services__r){
                        setESids.add(objcas.Electronic_Service__c);
                    }    
                }
                
                //map es vs set of orgnizationid and list of contentprofile
                List<Content_Profile__c> lstContentProfile = new List<Content_Profile__c>();
                lstContentProfile = [select id,Electronic_Service__c,Organization__c,Loinc_Code_Profile__c,Loinc_Code_Profile__r.name  from Content_Profile__c 
                                     where  Electronic_Service__c in: setESids];
                                     
                Map<Id,set<Id>> mapESforSetOfOrg = new Map<Id,set<Id>>();
                Map<Id,List<Content_Profile__c>> mapESforLstCP = new Map<Id,List<Content_Profile__c>>();
                Map<string,set<string>> mapESPlusOrgWiseSetLonic = new Map<string,set<string>>();
                for(Content_Profile__c objcp :lstContentProfile){
                    if(!mapESforSetOfOrg.containsKey(objcp.Electronic_Service__c)){
                        mapESforSetOfOrg.put(objcp.Electronic_Service__c, new Set<Id>{ objcp.Organization__c });
                    }else{
                        mapESforSetOfOrg.get(objcp.Electronic_Service__c).add(objcp.Organization__c);
                    }
                    string strLonicCode = '';
                    if(objcp.Loinc_Code_Profile__c != null)
                        strLonicCode = objcp.Loinc_Code_Profile__r.name; 
                    if(!mapESPlusOrgWiseSetLonic.containsKey(objcp.Electronic_Service__c+'#'+objcp.Organization__c)){
                        mapESPlusOrgWiseSetLonic.put(objcp.Electronic_Service__c+'#'+objcp.Organization__c, new Set<string>{ strLonicCode});
                    }else{
                        mapESPlusOrgWiseSetLonic.get(objcp.Electronic_Service__c+'#'+objcp.Organization__c).add(strLonicCode);
                    }
                    
                    if(!mapESforLstCP.containsKey(objcp.Electronic_Service__c)){
                        mapESforLstCP.put(objcp.Electronic_Service__c, new List<Content_Profile__c>{ objcp });
                    }else{
                        mapESforLstCP.get(objcp.Electronic_Service__c).add(objcp);
                    }
                }
                
                Map<id,List<Electronic_Service__c>> mapes = new Map<id,List<Electronic_Service__c>>();
                List<wrpca> lstwrpca = new List<wrpca>();
                
                for(Consumer_Affiliation__c ca : lst){
                    
                    wrpca objwrpca = new wrpca();
                    objwrpca.lstca = ca;
                    Set<id> setec = new set<id>();
                    Boolean blca = false;
                    for(Consumer_Affiliation_Service__c cas : ca.Consumer_Affiliation_Services__r){
                        
                        if(!setec.contains(cas.Electronic_Service__c) 
                                && mapESforSetOfOrg.containsKey(cas.Electronic_Service__c)
                                && mapESforSetOfOrg.get(cas.Electronic_Service__c) != null 
                                && mapESforSetOfOrg.get(cas.Electronic_Service__c).size()>0 
                                && mapESforSetOfOrg.get(cas.Electronic_Service__c).contains(ca.Organization__c)
                                
                                //&& mapESPlusOrgWiseSetLonic.containsKey(cas.Electronic_Service__c+'#'+ca.Organization__c)
                                //&& mapESPlusOrgWiseSetLonic.get(cas.Electronic_Service__c+'#'+ca.Organization__c) != null 
                                //&& mapESPlusOrgWiseSetLonic.get(cas.Electronic_Service__c+'#'+ca.Organization__c).size()>0 
                                //&& mapESPlusOrgWiseSetLonic.get(cas.Electronic_Service__c+'#'+ca.Organization__c).contains(ca.Organization__c)
                          ){
                            
                            
                            if (strLoincCode.size() >0){
                                boolean blflg = false;
                                for(string str : strLoincCode){
                                    if(mapESPlusOrgWiseSetLonic.get(cas.Electronic_Service__c+'#'+ca.Organization__c).contains(str))
                                    {
                                        if(objwrpca.strLoinc == null || objwrpca.strLoinc == ''){
                                           objwrpca.strLoinc = str; 
                                        }else{
                                            objwrpca.strLoinc += ',' + str;
                                        }
                                        blflg = true;
                                    }
                                }
                                if(!blflg)
                                    continue;
                            }else{
                                 for(string str : mapESPlusOrgWiseSetLonic.get(cas.Electronic_Service__c+'#'+ca.Organization__c)){
                                        if(str != null){
                                            if(objwrpca.strLoinc == null || objwrpca.strLoinc == ''){
                                               objwrpca.strLoinc = str; 
                                            }else{
                                                objwrpca.strLoinc += ',' + str;
                                            }
                                        }else {
                                            objwrpca.strLoinc = 'NULL';
                                        }
                                 }
                            }  
                        
                            Electronic_Service__c objes = new Electronic_Service__c();
                            objes.id = cas.Electronic_Service__c;
                            objes.Service_Type__c = cas.Electronic_Service__r.Service_Type__c;
                            objes.Address__c = cas.Electronic_Service__r.Address__c;
                            
                            if(!mapes.containskey(ca.Id)){
                                 mapes.put(ca.Id,new List<Electronic_Service__c>{ objes });
                            }else{
                                 mapes.get(ca.Id).add(objes);
                            }
                            setec.add(cas.Electronic_Service__c);
                            blca = true;
                         }
                     }
                     if(blca)
                         lstwrpca.add(objwrpca);
                }
                
                system.debug('@lstwrpca@ ' + lstwrpca + ' strLoincCode ' + strLoincCode.size());

                lstCP = new List<Content_Profile__c>();
                if (strLoincCode.size() >0){

                    lstCP = [select Organization__c, Loinc_Code_Profile__c,Loinc_Code_Profile__r.name  from Content_Profile__c
                             where Organization__c in :setAccountID and Loinc_Code_Profile__r.name IN :strLoincCode];
                }else{  
                    //if loinic code is not pass as parameter
                    for(Consumer_Affiliation__c objcagetorg : lst){
                        if(objcagetorg.Organization__c != null){
                            setAccountID.add(objcagetorg.Organization__c);
                        }
                    }                    
                    lstCP = [select Organization__c, Loinc_Code_Profile__c,Loinc_Code_Profile__r.name  from Content_Profile__c
                             where Organization__c in :setAccountID];
                }
                
                WrapAffContProfile wp = new WrapAffContProfile();
                //if(lstCP.size() > 0){
                    if(lstwrpca.size()>0 ){
                        wp.ca = lstwrpca;
                        wp.es = new List<Electronic_Service__c>();
                        //wp.cp = lstCP;
                        //wp.mapESforLstCP = mapESforLstCP;
                    }
             //}
                
            Map<string,string> MapstringField = new Map<string,string>();
            MapstringField.put('Consumer_Affiliation__c','Affinity_Domain__c#Organization_ID__c#Unique_ID__c#Id');
            MapstringField.put('Electronic_Service__c','Service_Type__c#Address__c');
            MapstringField.put('Content_Profile__c','Loinc_Code_Profile__c');
            MapstringField.put('Loinc_Code_Profile__c','Name');
            Map<string,string> mapfield = new map<string,string>();
            mapfield = getKeyValueColumns(MapstringField);
            string jstr = jsonstring(wp,mapfield,mapes);
            //system.debug('jstr@@@ ' + jstr + ' ' + jstr.length());

            if((lstwrpca.size() != 0 && (jstr == null || jstr.length() == 3)) || (strLoincCode.size()>0 && lstwrpca.size() == 0))
            {
                jsonResponse = '{\"result\":\"Success\",';
                jsonResponse += '\"message\": \"Patient exists but loinc code not found\"';
                if(strLoincCode.size() == 0 || (strLoincCode.size() > 0 && lstCP.size() > 0)){    
                    jsonResponse += ',\"customer_affiliation'+ '\":' + jstr;
                }
                jsonResponse += '}'; 
            }
           else if(lstwrpca.size() > 1)
            {
                jsonResponse = '{\"result\":\"Success\",';
                jsonResponse += '\"message\": \"Patient exists but multiple target associations found\",';
                jsonResponse += '\"customer_affiliation'+ '\":' + jstr + '}';
            }
            else if(lstwrpca.size() > 0)
            {
                jsonResponse = '{\"result\":\"Success\",';
                jsonResponse += '\"message\": \"Patient exists and one target associations found\",';
                jsonResponse += '\"customer_affiliation'+ '\":' + jstr + '}';            
            }
            else if (lstwrpca.size() == 0)
            {    
                jsonResponse = '{\"result\":\"Success\",';
                jsonResponse += '\"message\":\"Patient exists but no target associations found\"}';
            }
        } 
        else
        {
            blnSuccess = true;
            jsonResponse = '{\"result\":\"Failure\",';
            jsonResponse += '\"message\": \"Patient not registered in consumer directory\",';
            jsonResponse += '\"errorcode\":\"XDSUnknownPatientID\"}';
        }       
         return jsonResponse;
    }
    
    
    public class WrapAffContProfile 
    {
        public List<wrpca> ca{get;set;}
        public List<Electronic_Service__c> es{get;set;}
        public List<Content_Profile__c> cp {get;set;}
        public Map<Id,List<Content_Profile__c>> mapESforLstCP {get;set;}
        
        public WrapAffContProfile(){
            ca = new List<wrpca>();
            es = new List<Electronic_Service__c>();
            cp = new List<Content_Profile__c>();
            mapESforLstCP = new Map<Id,List<Content_Profile__c>>();
        }
    }
    
    public class wrpca{
        public Consumer_Affiliation__c lstca{get;set;}
        public string strLoinc {get;set;}
        
        public wrpca(){
            lstca = new Consumer_Affiliation__c();
            strLoinc = '';
        }
    } 
}