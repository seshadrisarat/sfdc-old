@IsTest
global class SL_Test_Jira_Connect_Mock_Create_Success implements HttpCalloutMock{
    
    global HTTPResponse respond(HTTPRequest req) {

    HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/xml');
        res.setBody(

    
    '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'+
   '<soapenv:Body>'+
      '<ns1:createProjectResponse soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns1="http://soap.rpc.jira.atlassian.com">'+
         '<createProjectReturn href="#id0"/>'+
      '</ns1:createProjectResponse>'+
      '<multiRef id="id0" soapenc:root="0" soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xsi:type="ns2:RemoteProject" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns2="http://beans.soap.rpc.jira.atlassian.com">'+
         '<description xsi:type="xsd:string">This is a Test Project</description>'+
         '<id xsi:type="xsd:string">15681</id>'+
         '<issueSecurityScheme href="#id1"/>'+
         '<key xsi:type="xsd:string">TESTIV</key>'+
         '<lead xsi:type="xsd:string">eric</lead>'+
         '<name xsi:type="xsd:string">Test104</name>'+
         '<notificationScheme href="#id2"/>'+
         '<permissionScheme href="#id3"/>'+
         '<projectUrl xsi:type="xsd:string"/>'+
         '<url xsi:type="xsd:string">https://silverline.jira.com/browse/TESTIV</url>'+
      '</multiRef>'+
      '<multiRef id="id1" soapenc:root="0" soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xsi:type="ns3:RemoteScheme" xmlns:ns3="http://beans.soap.rpc.jira.atlassian.com" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/">'+
         '<description xsi:type="xsd:string">10010</description>'+
        '<id xsi:type="xsd:long" xsi:nil="true"/>'+
        '<name xsi:type="xsd:string">Security Scheme</name>'+
        '<type xsi:type="xsd:string">security</type>'+
      '</multiRef>'+
      '<multiRef id="id3" soapenc:root="0" soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xsi:type="ns4:RemotePermissionScheme" xmlns:ns4="http://beans.soap.rpc.jira.atlassian.com" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/">'+
         '<description xsi:type="xsd:string">Desc</description>'+
         '<id xsi:type="xsd:long" xsi:nil="true"/>'+
         '<name xsi:type="xsd:string">EROCK</name>'+
         '<permissionMappings soapenc:arrayType="ns4:RemotePermissionMapping[0]" xsi:type="soapenc:Array"/>'+
         '<type xsi:type="xsd:string">permission</type>'+
      '</multiRef>'+
      '<multiRef id="id2" soapenc:root="0" soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xsi:type="ns5:RemoteScheme" xmlns:ns5="http://beans.soap.rpc.jira.atlassian.com" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/">'+
         '<description xsi:type="xsd:string">desc</description>'+
         '<id xsi:type="xsd:long" xsi:nil="true"/>'+
         '<name xsi:type="xsd:string">Force.com Notification Scheme</name>'+
         '<type xsi:type="xsd:string">notification</type>'+
      '</multiRef>'+
   '</soapenv:Body>'+
'</soapenv:Envelope>');
        res.setStatusCode(200);
        return res;
}
}