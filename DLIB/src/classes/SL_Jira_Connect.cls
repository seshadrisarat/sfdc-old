global class SL_Jira_Connect{
    
    @RemoteAction
    webservice static string[] JiraProject(Id projectID, string key, string projectName){
        
        string[] message = new List<string>();
        string[] success = new List<String>();
        
        string proID = UserInfo.getProfileId();
        Profile pro = [SELECT Name FROM Profile WHERE Id =: ProID LIMIT 1];
        if(pro.name != 'System Administrator' && pro.name != 'SL - System Administrator'){
            message.add('Restricted');
            message.add('You are not an Administrator!');
            return message;
        }
        
        //Get the project information and check to see if it already has an attached project
        list<Project__c> p = [SELECT Account__c, Jira_Project_Name__c, Ownerid FROM Project__c WHERE ID =:projectID LIMIT 1];
        system.debug(p);
        List<Account> client = [SELECT Name FROM Account WHERE id =: p[0].Account__c];
        if(p[0].Jira_Project_Name__c != null&&p[0].Jira_Project_Name__c != ''){
            message.add('Project Already Exists');
            message.add('Jira project already created');
            return message;
        }
        
        else{
            if(key == ''||key == null){
                //generates jira key, making sure it is unique compared to the projects on file and returns it to the button if one was not passed in
                SL_Jira_Connect_Key_Create kc = new SL_Jira_Connect_Key_Create();
        		key = kc.MakeKey(client[0].Name);
            	system.debug('key: '+key);
                message.add(key);
                message.add(client[0].Name);
                return message;
                    }else{
                        //gets the section of the email before the @silverlinecrm (jira id *should* be this)
        				list<User> u = [SELECT Email FROM User WHERE ID =:p[0].OwnerId];
        				string em = '@silverlinecrm.com';
        				string oname = u[0].Email.left(u[0].Email.length()-em.length());
        
                        system.debug('pName: '+projectName);
                        system.debug('key return: '+key);
            List<Jira_Login_Credentials__c> JLC = [SELECT User_Name__c, Password__c FROM Jira_Login_Credentials__c WHERE Name = 'Admin'];
        //logs in to jira and returns token
        string token = Login(JLC[0].User_Name__c, JLC[0].Password__c);
            if(token.length() == 0){
                message.add('Login Failed');
                return message;
               //attempts to create the project using they key, token, project name, and owner name
            }else{
        success = ProjectCreate(token, key, projectName, oname);
                //logs out of jira and updates the project file if it is a success
                if(success[1] == 'true'){
        			p[0].Jira_Project_Name__c = key;
        			message.add(Logout(token));
                    message.add(success[0]);
        update p[0];
            return message;
                    //error message if project creation failed
                }else{
                    message.add('Project not created');
                    message.add(success[0]);
                    return message;
               				}
            			}
                    }
        }
    }
    
    public static String[] ProjectCreate(string token, string key, string pname, string oname){
        string[] success = new List<String>();
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
            system.debug(body);
            
            
            //gets the faults from the return message or the id if it was a success
            XmlStreamReader reader = res.getXmlStreamReader();
            while(reader.hasNext()) {
      		System.debug('Event Type:' + reader.getEventType());
      			if (reader.getEventType() == XmlTag.START_ELEMENT) {
        		System.debug(reader.getLocalName());
                    if(reader.getLocalName() == 'faultstring'){
                        reader.next();
                        system.debug(reader.getText());
                        if(success.isEmpty()){
                            success.add(reader.getText());
                        }
                        else{
                        	success.add(0,success[0]+' '+reader.getText());
                        }
                    }
                    else if(reader.getLocalName() == 'id'){
                        reader.next();
                        system.debug(reader.getText());
                        success.add(reader.getText());
                    }
      			}
     		reader.next();
   		}
        }catch(System.CalloutException e) {
            System.debug('Callout error: '+ e);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getMessage()));
            }
        //test element is for the test class' use only
        if(!body.contains('faultstring')){
            if(success.isEmpty()){
                success.add('Test Element');
            }
            success.add('true');
                }
        else{
            if(success.isEmpty()){
                success.add('Test Element');
            }
            success.add('false');
            }
        
        system.debug('success'+success);
        return success;
    }
    
    
    public static string Login(String UN, String PW){
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
    
    public static string Logout(string token){
        boolean success;
        string body;
        string message;
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
            body = res.getBody();
        }catch(System.CalloutException e) {
            System.debug('Callout error: '+ e);
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getMessage()));
            }
        success = !body.contains('faultstring');
        if(success){
            message = 'Project Created';
        }else{
            message = 'Project Created, Logout Error';
        }
        return message;
    }
    
    webservice static String[] MakeRepo(String Key){
        string[] message = new List<String>();
        HttpRequest req = new HttpRequest();
     	req.setEndpoint('https://bitbucket.org/api/1.0/repositories');
     	req.setMethod('POST');
     
     // Specify the required user name and password to access the endpoint
     // As well as the header and header information
 
     	String username = 'sl_jenkins';
     	String password = 'jenkinsforc3';
        
     	Blob headerValue = Blob.valueOf(username + ':' + password);
     	String authorizationHeader = 'BASIC ' +
     	EncodingUtil.base64Encode(headerValue);
     	req.setHeader('Authorization', authorizationHeader);
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setBody('name='+key+'&owner=silverline&is_private=true');
        system.debug(req.getHeader('Authorization'));
   
     // Create a new http object to send the request object
     // A response object is generated as a result of the request  
  
     	Http http = new Http();
     	HTTPResponse res = http.send(req);
     	string body = res.getBody();
        if(!body.contains('faultstring')||!body.contains('fault string')){
            message.add('Repository Created, No Errors');
        }else{
            message.add('Error In Creating Repository');
            message.add(body);
        }
        return message;
    
    }

}