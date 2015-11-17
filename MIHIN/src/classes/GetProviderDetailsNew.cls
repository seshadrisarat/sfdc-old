@RestResource(urlMapping='/viewprovider2/*')
global Class GetProviderDetailsNew
{
    @HttpGet
    global static void GetProviderDetailsNew() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        String jsonResponse = '';
        
        String strorgname = '';
        String strorgnpi = '';
        String strorgoid = '';
        
        strorgname = req.params.get('organization_name');        
        strorgnpi = req.params.get('organization_npi');
        strorgoid = req.params.get('organization_oid');
        
        
        if((strorgname == null || strorgname == '') && (strorgnpi == null || strorgnpi== '') 
                    && (strorgoid == null || strorgoid == '')) {
            res.statusCode = 400;
            jsonResponse = '{"result": "Failure", "message": "Bad Request - Missing Parameters: organization_name, organization_npi, organization_oid"}';
            res.responseBody = blob.valueOf(jsonResponse);
            AddApiLog.InsertAPILog(string.valueof(RestContext.request),jsonResponse,false,'viewprovider2');
            return;
        } else {
            jsonResponse = GetOrganizationInfo(strorgname,strorgnpi,strorgoid);
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
            if (strorgname!= null && strorgname.tolowercase() != 'null' && strorgname!= '')
                strMsg += '\"organization_name\":'+'\"'+strorgname+'\",';
            if (strorgnpi!= null && strorgnpi.tolowercase() != 'null' && strorgnpi!= '')
                strMsg += '\"organization_npi\":'+'\"'+strorgnpi+'\",';
            if (strorgoid!= null && strorgoid.tolowercase() != 'null' && strorgoid!= '')
                strMsg += '\"organization_oid\":'+'\"'+strorgoid+'\",';
                
            //strMsg += '\"organization_name\":'+'\"'+ strorgname +'\",';
                  
            jsonResponse =  strMsg + jsonResponse.substring(20);
            jsonResponse  = jsonResponse.unescapeEcmaScript();
            jsonResponse  = jsonResponse.replace('"[','[');
            jsonResponse  = jsonResponse.replace(']"',']');
            res.responseBody = blob.valueOf(jsonResponse);
            AddApiLog.InsertAPILog(string.valueof(RestContext.request),jsonResponse,true,'viewprovider2');
            return;
        } 
        catch ( Exception ex ) {
            res.statusCode = 500;
            jsonResponse = '{"result": "Failure", "message": "Server errors - ' + ex + '"}';
            res.responseBody = blob.valueOf(jsonResponse);
            AddApiLog.InsertAPILog(string.valueof(RestContext.request),jsonResponse,false,'viewprovider2');
            return;
        }
    }
    
    public static string jsonstring(List<WrapProviderDetails> lstWrapProviderDetails){
        
        JSONGenerator generator = JSON.createGenerator(true);  
        generator.writeStartArray();

        for(WrapProviderDetails objwrap : lstWrapProviderDetails){
            generator.writeStartObject();
            generator.writeStringField('recordid',objwrap.objAccount.Id);
            
            if(objwrap.objAccount.Name != null)        
                generator.writeStringField('name',objwrap.objAccount.Name);
            else
                generator.writeStringField('name','');
            
            if(objwrap.objAccount.Organizational_NPI__c != null)        
                generator.writeStringField('npi',objwrap.objAccount.Organizational_NPI__c);
            else
                generator.writeStringField('npi','');
            
            if(objwrap.objAccount.Organizational_OID__c != null)        
                generator.writeStringField('oid',objwrap.objAccount.Organizational_OID__c);
            else
                generator.writeStringField('oid','');
                        
            JSONGenerator generatorchild = JSON.createGenerator(true);
            generatorchild.writeStartArray();
        
            if(objwrap.wplstElectronicsService.size() > 0) {
                for(Electronic_Service__c objservice : objwrap.wplstElectronicsService){
                    generatorchild.writeStartObject();
                    generatorchild.writeStringField('recordid',objservice.id);
                    generatorchild.writeStringField('name',objservice.Name);
                    if(!string.IsBlank(objservice.Type__c))
                        generatorchild.writeStringField('type',objservice.Type__c);
                    else
                        generatorchild.writeStringField('type','');
                    if(!string.IsBlank(objservice.Protocol__c))
                        generatorchild.writeStringField('integrationprofile',objservice.Protocol__c);
                    else
                        generatorchild.writeStringField('integrationprofile','');
                    if(!string.IsBlank(objservice.Payload__c))
                        generatorchild.writeStringField('contentprofile',objservice.Payload__c);
                    else
                        generatorchild.writeStringField('contentprofile','');
                    if(!string.IsBlank(objservice.Address__c))
                        generatorchild.writeStringField('address',objservice.Address__c);
                    else
                        generatorchild.writeStringField('address','');
                    if(!string.IsBlank(objservice.Service_ID__c))
                        generatorchild.writeStringField('serviceid',objservice.Service_ID__c);
                    else
                        generatorchild.writeStringField('serviceid','');
                    if(!string.IsBlank(objservice.Service_Type__c))
                        generatorchild.writeStringField('servicetype',objservice.Service_Type__c);
                    else
                        generatorchild.writeStringField('servicetype','');
                    
                    generatorchild.writeEndObject();  
                }       
                generatorchild.writeEndArray();
                generator.writeStringField('electronic_service',generatorchild.getAsString().unescapeEcmaScript());
            }else{
                generator.writeStringField('electronic_service','');              
            }
            generator.writeEndObject();
        }
        
        generator.writeEndArray();
        return generator.getAsString();
     }
    
    public static string GetOrganizationInfo(String strorgname,String strorgnpi, String strorgoid) {
        String jsonResponse = '';
        String strQuery ='';
         
        strQuery = 'select id, Name, Organizational_NPI__c, Organizational_OID__c, '; 
        strQuery += ' (select Id, Name, Address__c, Protocol__c,Type__c,Payload__c,Service_ID__c,Service_Type__c from Electronic_Services__r) from Account Where Id != null ';
        
        if(!string.IsBlank(strorgname))
            strQuery += ' and Name = \'' + strorgname.trim() + '\'';
            
        if(!string.Isblank(strorgnpi))        
            strQuery += ' and Organizational_NPI__c = \'' + strorgnpi.trim() + '\'' ;
        
        if(!string.IsBlank(strorgoid))
             strQuery += ' and Organizational_OID__c = \'' + strorgoid.trim() + '\'';
        
        system.debug('strQuery !!!'  +strQuery);
        
        List<Account> lstAccount = Database.query(strQuery);
        
        system.debug('lstAccount  !!!'  +lstAccount);        
        
        List<WrapProviderDetails> lstWrapProviderDetails = new List<WrapProviderDetails>();
        if(lstAccount.size() > 0){
            for(Account objAccount : lstAccount){
                WrapProviderDetails wpDetails = new WrapProviderDetails();
                for(Electronic_Service__c objServices : objAccount.Electronic_Services__r){
                   wpDetails.wplstElectronicsService.add(objServices);                 
                }
                wpDetails.objAccount = objAccount;
                lstWrapProviderDetails.add(wpDetails);
            }
            
            string jstr = jsonstring(lstWrapProviderDetails);
            
            if(lstAccount.size() > 0)
            {
                jsonResponse = '{\"result\":\"Success\",';
                jsonResponse += '\"message\": \"organization found\",';
                jsonResponse += '\"organization'+ '\":' + jstr + '}';           
            }
        } else {
            jsonResponse = '{\"result\":\"Success\",';
            jsonResponse += '\"message\": \"Not Found - Organization not found\"}';
        } 
              
         return jsonResponse;
    }
    
    
    public class WrapProviderDetails
    {
        public Account objAccount {get;set;}
        public List<Electronic_Service__c> wplstElectronicsService  {get;set;}
        
        public WrapProviderDetails(){
            objAccount = new Account();
            wplstElectronicsService  = new List<Electronic_Service__c>();
        }
    }
}