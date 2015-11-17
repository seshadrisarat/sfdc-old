@IsTest
global class SL_Test_Connect_Mock_Failure implements HttpCalloutMock{
    
    global HTTPResponse respond(HTTPRequest req) {

    HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/xml');
        res.setBody('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'+
   '<soapenv:Body>'+
      '<soapenv:Fault>'+
         '<faultcode>soapenv:Server.userException</faultcode>'+
         '<faultstring>com.atlassian.jira.rpc.exception.RemoteValidationException: Cannot create project:  projectName:A project with that name already exists. projectKey:Project Test103 uses this project key.</faultstring>'+
         '<detail>'+
            '<com.atlassian.jira.rpc.exception.RemoteValidationException xsi:type="ns1:RemoteValidationException" xmlns:ns1="http://exception.rpc.jira.atlassian.com"/>'+
            '<ns2:hostname xmlns:ns2="http://xml.apache.org/axis/">silverline.jira.com</ns2:hostname>'+
         '</detail>'+
      '</soapenv:Fault>'+
   '</soapenv:Body>'+
'</soapenv:Envelope>');
        res.setStatusCode(200);
        return res;
     }
    
    
}