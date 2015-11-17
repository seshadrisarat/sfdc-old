@IsTest
global class SL_Test_Jira_Connect_Mock_Logout_Success implements HttpCalloutMock{
    
     global HTTPResponse respond(HTTPRequest req) {

    HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/xml');
        res.setBody(' <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'+
   '<soapenv:Body>'+
      '<ns1:logoutResponse soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns1="http://soap.rpc.jira.atlassian.com">'+
         '<logoutReturn xsi:type="xsd:boolean">false</logoutReturn>'+
      '</ns1:logoutResponse>'+
   '</soapenv:Body>'+
'</soapenv:Envelope>');
        res.setStatusCode(200);
        return res;
     }
    
}