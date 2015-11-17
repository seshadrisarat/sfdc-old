@IsTest
global class SL_Test_Jira_Connect_HTTP_Req implements HttpCalloutMock{
    
     global HTTPResponse respond(HTTPRequest req) {
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/xml');
        res.setBody('<?xml version="1.0" encoding="UTF-8"?>'+
                    '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'+
                    '<soapenv:Body>'+
                    '<ns1:loginResponse soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns1="http://soap.rpc.jira.atlassian.com">'+
                    '<loginReturn xsi:type="xsd:string">231273868426da75c5a82c32c8c97713b0eb163a</loginReturn>'+
                    '</ns1:loginResponse>'+
                    '</soapenv:Body>'+
                    '</soapenv:Envelope>');
        res.setStatusCode(200);
        return res;
    }

}