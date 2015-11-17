public class SL_Jira_Connect_Project_Create{
    
    public void Create(string token, string key, string pname, string oname){
        HTTPRequest req = new HTTPRequest();
        req.setHeader('SOAPAction', 'Retrieve');
        req.setHeader('Content-Type','text/xml;charset=UTF-8');
        req.setEndpoint('https://silverline.jira.com/rpc/soap/jirasoapservice-v2');
        req.setMethod('GET');
        req.setBody('<soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:soap="http://soap.rpc.jira.atlassian.com" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/">'+
   '<soapenv:Header/>'+
   '<soapenv:Body>'+
      '<soap:createProject soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'+
         '<in0 xsi:type="xsd:string">'+token+'</in0>'+
         '<in1 xsi:type="xsd:string">'+key+'</in1>'+
         '<in2 xsi:type="xsd:string">'+pname+'</in2>'+
         //'<in3 xsi:type="xsd:string">'+'Change the description to mean something'+'</in3>'+
         '<in5 xsi:type="xsd:string">'+oname+'</in5>'+
      '</soap:createProject>'+
   '</soapenv:Body>'+
'</soapenv:Envelope>');
        req.setTimeout(120000);
        
        string body;
     Http http = new Http();
        try{
            HTTPResponse res = http.send(req);
            body = res.getBody();
        }catch(System.CalloutException e) {
            System.debug('Callout error: '+ e);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getMessage()));
            }
        System.debug(body);
    }

}