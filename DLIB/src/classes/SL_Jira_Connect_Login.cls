public class SL_Jira_Connect_Login{
    String UN = 'sladmin';
    String PW = 'silverforc3';
    
    
    public string Login(){
        string token;
        string body;
        HTTPRequest req = new HTTPRequest();
        req.setHeader('SOAPAction', 'Retrieve');
        req.setHeader('Content-Type','text/xml;charset=UTF-8');
        req.setEndpoint('https://silverline.jira.com/rpc/soap/jirasoapservice-v2');
        req.setMethod('GET');
        req.setBody('<soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:soap="http://soap.rpc.jira.atlassian.com">'+
                    '<soapenv:Header/>'+
                    '<soapenv:Body>'+
                    '<soap:login soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'+
                    '<in0 xsi:type="xsd:string">'+UN+'</in0><in1 xsi:type="xsd:string">'+PW+'</in1>'+
                    '</soap:login>'+
                    '</soapenv:Body>'+
                    '</soapenv:Envelope>');
        req.setTimeout(120000);
        
     Http http = new Http();
        try{
            HTTPResponse res = http.send(req);
            body = res.getBody();}
        catch(System.CalloutException e) {
            System.debug('Callout error: '+ e);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getMessage()));
            }
     System.debug(body);
        integer start = body.indexOf('<loginReturn xsi:type="xsd:string">');
        integer finish = body.indexOf('</loginReturn>');
        integer difference = finish-start;
        string token1 = body.mid(start, difference);
        string hold = '<loginReturn xsi:type="xsd:string">';
        token = token1.mid(hold.length(), finish);
        system.debug(token);
     return token;
    }

}