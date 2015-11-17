global class SL_Test_Jira_Mock_Success implements HttpCalloutMock{
    
    global HTTPResponse respond(HTTPRequest req) {

    HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/xml');
        res.setBody('<?xml version="1.0" encoding="UTF-8"?>'
                    +'<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
                    +'<soapenv:Body><ns1:createProjectResponse soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns1="http://soap.rpc.jira.atlassian.com">'
                    +'<createProjectReturn href="#id0"/></ns1:createProjectResponse><multiRef id="id0" soapenc:root="0" soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xsi:type="ns2:RemoteProject" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns2="http://beans.soap.rpc.jira.atlassian.com">'
                    +'<description xsi:type="xsd:string"></description><id xsi:type="xsd:string">16186</id><issueSecurityScheme xsi:type="ns2:RemoteScheme" xsi:nil="true"/>'
                    +'<key xsi:type="xsd:string">TIATAVI</key><lead xsi:type="xsd:string">brock</lead><name xsi:type="xsd:string">TestTestTestTest</name><notificationScheme xsi:type="ns2:RemoteScheme" xsi:nil="true"/>'
                    +'<permissionScheme xsi:type="ns2:RemotePermissionScheme" xsi:nil="true"/><projectUrl xsi:type="xsd:string" xsi:nil="true"/>'
                    +'<url xsi:type="xsd:string">https://silverline.jira.com/browse/TIATAVI</url></multiRef></soapenv:Body></soapenv:Envelope>');
        res.setStatusCode(200);
        return res;
     }
}