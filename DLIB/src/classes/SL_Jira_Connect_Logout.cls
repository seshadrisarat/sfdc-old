public class SL_Jira_Connect_Logout{
    
    public void Logout(string token){
        HTTPRequest req = new HTTPRequest();
        req.setHeader('SOAPAction', 'Retrieve');
        req.setHeader('Content-Type','text/xml;charset=UTF-8');
        req.setEndpoint('https://silverline.jira.com/rpc/soap/jirasoapservice-v2');
        req.setMethod('GET');
        req.setBody('<soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:soap="http://soap.rpc.jira.atlassian.com">'+
   '<soapenv:Header/>'+
   '<soapenv:Body>'+
      '<soap:logout soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'+
         '<in0 xsi:type="xsd:string">'+token+'</in0>'+
      '</soap:logout>'+
   '</soapenv:Body>'+
'</soapenv:Envelope>');
        req.setTimeout(120000);
        
     Http http = new Http();
        try{
            HTTPResponse res = http.send(req);
        }catch(System.CalloutException e) {
            System.debug('Callout error: '+ e);
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getMessage()));
            }
    }

}