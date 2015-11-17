@RestResource(urlMapping='/createaffiliation/*')
global Class CreateAffiliation
{
    private static boolean blnSuccess {get;set;}
    @HttpGet
    global static void InsertAffiliation() 
    {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        
        string strjsonResponse = '';
        string strpatientid = '';
        string strorganization = '';
        string strstartdate = '';
        string strenddate = '';
        string straffinitydomain = '';
        string struniqueid = ''; 
        string strdatasource = '';
        string strelectronicsservice = '';
        
        strpatientid = req.params.get('patientid');        
        strorganization = req.params.get('organization');
        strstartdate = req.params.get('startdate');
        strenddate = req.params.get('enddate');
        straffinitydomain = req.params.get('affinitydomain');
        struniqueid = req.params.get('uniqueid');
        strdatasource = req.params.get('datasource');
        strelectronicsservice = req.params.get('services');
        
        if(strpatientid == null || strpatientid == '') {
            res.statusCode = 400;
            strjsonResponse = '{"result": "Failure", "message": "Bad Request - Missing Parameters: patientid"}';
            res.responseBody = blob.valueOf(strjsonResponse);
            AddApiLog.InsertAPILog(string.valueof(RestContext.request),strjsonResponse,false,'createaffiliation');
            return;
        } else if(!string.IsBlank(strpatientid)) {
            List<Consumer_ID__c> lstConsumerIds = new List<Consumer_ID__c>([select Id,Consumer__c from Consumer_ID__c Where Data_Source_ID__c =:  strpatientid Limit 1]);
            if(lstConsumerIds.size() > 0) {
                List<Contact> lstContact = new List<Contact>([select Id from Contact Where Id =: lstConsumerIds[0].Consumer__c  Limit 1]);
                if(lstContact.size() == 0) {
                    res.statusCode = 400;
                    strjsonResponse = '{"result": "Failure", "message": "Not Found - No consumer found"}';
                    res.responseBody = blob.valueOf(strjsonResponse);
                    AddApiLog.InsertAPILog(string.valueof(RestContext.request),strjsonResponse,false,'createaffiliation');
                    return;
                }
            } else {
                res.statusCode = 400;
                strjsonResponse = '{"result": "Failure", "message": "Not Found - No consumer found"}';
                res.responseBody = blob.valueOf(strjsonResponse);
                AddApiLog.InsertAPILog(string.valueof(RestContext.request),strjsonResponse,false,'createaffiliation');
                return;
            }
        }
        if(strorganization == null || strorganization == '') {
            res.statusCode = 400;
            strjsonResponse = '{"result": "Failure", "message": "Bad Request - Missing Parameters: organization"}';
            res.responseBody = blob.valueOf(strjsonResponse);
            AddApiLog.InsertAPILog(string.valueof(RestContext.request),strjsonResponse,false,'createaffiliation');
            return;
        } else if(!string.IsBlank(strorganization)) {
            List<Account> objOrg = new List<Account>([select Id from Account Where Id =: strorganization Limit 1]);
            if(objOrg.size() == 0) {
                res.statusCode = 400;
                strjsonResponse = '{"result": "Failure", "message": "Not Found - No organization found"}';
                res.responseBody = blob.valueOf(strjsonResponse);
                AddApiLog.InsertAPILog(string.valueof(RestContext.request),strjsonResponse,false,'createaffiliation');
                return;
            }
        }
        if(!string.Isblank(strstartdate)) {
            if(strstartdate.contains('-')) {
                try {
                    date dtstartdate = date.valueof(strstartdate);
                } catch(Exception ex) {
                    res.statusCode = 400;
                    strjsonResponse = '{"result": "Failure", "message": "invalid startdate - date should be yyyy-MM-dd"}';
                    res.responseBody = blob.valueOf(strjsonResponse);
                    AddApiLog.InsertAPILog(string.valueof(RestContext.request),strjsonResponse,false,'createaffiliation');
                    return;
                }
            } else { 
                res.statusCode = 400;
                strjsonResponse = '{"result": "Failure", "message": "invalid startdate - date should be yyyy-MM-dd"}';
                res.responseBody = blob.valueOf(strjsonResponse);
                AddApiLog.InsertAPILog(string.valueof(RestContext.request),strjsonResponse,false,'createaffiliation');
                return;
            }
        }
        if(!string.Isblank(strenddate)) {
            if(strenddate.contains('-')) {
                try {
                    date dtenddate = date.valueof(strenddate);
                } catch(Exception ex) {
                    res.statusCode = 400;
                    strjsonResponse = '{"result": "Failure", "message": "invalid enddate - date should be yyyy-MM-dd"}';
                    res.responseBody = blob.valueOf(strjsonResponse);
                    AddApiLog.InsertAPILog(string.valueof(RestContext.request),strjsonResponse,false,'createaffiliation');
                    return;
                }
            } else { 
                res.statusCode = 400;
                strjsonResponse = '{"result": "Failure", "message": "invalid enddate - date should be yyyy-MM-dd"}';
                res.responseBody = blob.valueOf(strjsonResponse);
                AddApiLog.InsertAPILog(string.valueof(RestContext.request),strjsonResponse,false,'createaffiliation');
                return;
            }
        }
        if(!string.IsBlank(strpatientid) && !string.IsBlank(strorganization)){
            strjsonResponse = InsertAffiliationRecord(strpatientid, strorganization, strstartdate, strenddate, 
                        straffinitydomain, struniqueid, strdatasource,strelectronicsservice);
        }
        if(strjsonResponse == null)
        {
            res.statusCode = 400;
            strjsonResponse= '{"result": "Failure", "message": "Request Failed - Parameters were valid but request failed."}';
            res.responseBody = blob.valueOf(strjsonResponse);
            AddApiLog.InsertAPILog(string.valueof(RestContext.request),strjsonResponse,false,'createaffiliation');
            return;
        } else {
            //strjsonResponse= strjsonResponse.unescapeEcmaScript();
            res.statusCode = 200;
            strjsonResponse= strjsonResponse.unescapeEcmaScript();
            strjsonResponse= strjsonResponse.replace('"[','[');
            strjsonResponse= strjsonResponse.replace(']"',']');
            res.responseBody = blob.valueOf(strjsonResponse);
           
            if(blnSuccess == true){
                AddApiLog.InsertAPILog(string.valueof(RestContext.request),strjsonResponse,false,'createaffiliation');
            }else{
                AddApiLog.InsertAPILog(string.valueof(RestContext.request),strjsonResponse,true,'createaffiliation');
            }
            return;
        }
    }
    
    public static string jsonstring(WrapConsumerAffiliations objWrapAffiliation){
        
        JSONGenerator generator = JSON.createGenerator(true);  
        generator.writeStartArray();

        if(objWrapAffiliation != null) {
            generator.writeStartObject();
            generator.writeStringField('recordid',objWrapAffiliation.objConsumerAff.Id);
            
            if(objWrapAffiliation.objConsumerAff.Name != null)        
                generator.writeStringField('name',objWrapAffiliation.objConsumerAff.Name);
            else
                generator.writeStringField('name','');
            
            if(objWrapAffiliation.objConsumerAff.Consumer__c != null)        
                generator.writeStringField('consumer',objWrapAffiliation.objConsumerAff.Consumer__c);
            else
                generator.writeStringField('consumer','');
            
            if(objWrapAffiliation.objConsumerAff.Organization__c != null)        
                generator.writeStringField('organization',objWrapAffiliation.objConsumerAff.Organization__c);
            else
                generator.writeStringField('organization','');
            
            if(objWrapAffiliation.objConsumerAff.Affinity_Domain__c != null)        
                generator.writeStringField('affinity_domain',objWrapAffiliation.objConsumerAff.Affinity_Domain__c);
            else
                generator.writeStringField('affinity_domain','');
            
            if(objWrapAffiliation.objConsumerAff.Organization_ID__c != null)        
                generator.writeStringField('organizationid',objWrapAffiliation.objConsumerAff.Organization_ID__c);
            else
                generator.writeStringField('organizationid','');
                        
            JSONGenerator generatorchild = JSON.createGenerator(true);
            generatorchild.writeStartArray();
        
            if(objWrapAffiliation.wplstAffiliationService.size() > 0) {
                for(Consumer_Affiliation_Service__c objservice : objWrapAffiliation.wplstAffiliationService){
                    generatorchild.writeStartObject();
                    generatorchild.writeStringField('recordid',objservice.id);
                    generatorchild.writeStringField('name',objservice.Name);
                    generatorchild.writeStringField('electronicservice',objservice.Electronic_Service__c);
                    /*if(!string.Isblank(objservice.Affinity_Domain__c))
                        generatorchild.writeStringField('affinitydomain',objservice.Affinity_Domain__c);
                    else
                        generatorchild.writeStringField('affinitydomain','');
                    if(!string.IsBlank(objservice.Organization_ID__c))
                        generatorchild.writeStringField('organizationid',objservice.Organization_ID__c);
                    else
                        generatorchild.writeStringField('organizationid','');*/
                    generatorchild.writeEndObject();  
                }       
                generatorchild.writeEndArray();
                generator.writeStringField('consumer_affiliation_service',generatorchild.getAsString().unescapeEcmaScript());
            }else{
                generator.writeStringField('consumer_affiliation_service','');              
            }
            generator.writeEndObject();
        }
        
        generator.writeEndArray();
        return generator.getAsString();
    }
    
    public static string InsertAffiliationRecord(string strpatientid , string strorganization, string strstartdate, 
            string strenddate, string straffinitydomain, string struniqueid, string strdatasource,string strelectronicsservice) 
    {
        string strjsonResponse = '';
        
        try {
            List<Consumer_ID__c> lstConsumerIds = new List<Consumer_ID__c>([select Id,Consumer__c from Consumer_ID__c Where Data_Source_ID__c =:  strpatientid Limit 1]);
            if(lstConsumerIds.size() > 0) {
                List<Contact> lstContact = new List<Contact>([select Id from Contact Where Id =: lstConsumerIds[0].Consumer__c  Limit 1]);
                if(lstContact.size() > 0) {
                    List<Account> lstOrg = new List<Account>([select Id,Organizational_OID__c from Account Where Id =: strorganization Limit 1]);
                    Consumer_Affiliation__c objCAffiliation = new Consumer_Affiliation__c();
                    objCAffiliation.Affinity_Domain__c = straffinitydomain;
                    objCAffiliation.Consumer__c = lstContact[0].Id;
                    objCAffiliation.Data_Source__c = strdatasource;
                    if(!string.IsBlank(strenddate))
                        objCAffiliation.End_Date__c = Date.valueof(strenddate);
                    objCAffiliation.Organization__c = lstOrg[0].Id;
                    if(!string.Isblank(lstOrg[0].Organizational_OID__c))
                        objCAffiliation.Organization_ID__c = lstOrg[0].Organizational_OID__c;
                    if(!string.isblank(strstartdate))
                        objCAffiliation.Start_Date__c = Date.valueof(strstartdate);
                    objCAffiliation.Unique_ID__c = struniqueid;
                    insert objCAffiliation;             
                    List<Consumer_Affiliation__c> lstCA = new List<Consumer_Affiliation__c>([select Id,Name,Affinity_Domain__c ,Consumer__c,
                                                        Data_Source__c , End_Date__c , Organization__c , Organization_ID__c ,Start_Date__c ,
                                                        Unique_ID__c from Consumer_Affiliation__c Where Id =: objCAffiliation.Id Limit 1]);
                    
                    WrapConsumerAffiliations objWrap = new WrapConsumerAffiliations();
                    objWrap.objConsumerAff = lstCA[0];
                    if(!string.Isblank(strelectronicsservice)) {
                        List<Consumer_Affiliation_Service__c> lstCAS = new List<Consumer_Affiliation_Service__c>();
                        string[] strarrServices = strelectronicsservice.split(',');
                        for(string objService: strarrServices) {
                            if(!string.isBlank(objService)){
                                Consumer_Affiliation_Service__c objCAS = new Consumer_Affiliation_Service__c();
                                //objCAS.Affinity_Domain__c = straffinitydomain;
                                //objCAS.Organization_ID__c = lstOrg[0].Organizational_OID__c;
                                objCAS.Consumer_Affiliation__c = lstCA[0].Id;
                                objCAS.Electronic_Service__c = objService;
                                
                                //objCAS.Unique_ID__c = struniqueid;
                                lstCAS.add(objCAS);
                            }
                        }
                        if(lstCAS.size() > 0) {
                            insert lstCAS;
                            objWrap.wplstAffiliationService = new List<Consumer_Affiliation_Service__c>([select Id,Name,Consumer_Affiliation__c,Electronic_Service__c,Unique_ID__c 
                                            from Consumer_Affiliation_Service__c Where id in: lstCAS]);
                        }
                    }
                    
                    if(objWrap != null) {
                        string tempstrjsonResponse = jsonstring(objWrap);
                        strjsonResponse = '{\"result\":\"Success\",';
                        strjsonResponse += '\"message\":\"Record save successfully\",';
                        strjsonResponse += '\"consumer_affiliation'+ '\":' + tempstrjsonResponse+ '}'; 
                        blnSuccess = false;
                    }
                    //strjsonResponse = '{\"result\":\"Success\",';
                    //strjsonResponse += '\"message\": \"[patientid: '+patientid+',\n activecareadministrator: '+stractivecareadmin+',\n consumer: '+strconsumer+', \n activecareaffiliation: '+stractivecareaff+' ]\"}';
                }
            }
            
            
        } catch(Exception ex) {
            blnSuccess = true;
            strjsonResponse = '{\"result\":\"Failure\",';
            strjsonResponse += '\"message\": \"'+ex.getMessage()+'\"}';
        }
        
        return strjsonResponse ;
    }
    
    public class WrapConsumerAffiliations
    {
        public Consumer_Affiliation__c objConsumerAff {get;set;}
        public List<Consumer_Affiliation_Service__c> wplstAffiliationService {get;set;}
        
        public WrapConsumerAffiliations(){
            objConsumerAff = new Consumer_Affiliation__c();
            wplstAffiliationService = new List<Consumer_Affiliation_Service__c>();
        }
    }
}