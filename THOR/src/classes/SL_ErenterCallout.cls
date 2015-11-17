global with sharing class SL_ErenterCallout 
{
    public static String cid;
    public static Map<String, String> mapStateCodes = new Map<String, String>();
    
    ///Method called from Custom button
    webservice static string sendErenterRequest(Id contactRoleId)
    {
         cid = contactRoleId;
         mapStateCodes.put('Alabama','AL');
         mapStateCodes.put('Alaska','AK');
         mapStateCodes.put('Arizona','AZ'); 
         mapStateCodes.put('Arkansas','AR');
         mapStateCodes.put('California','CA');
         mapStateCodes.put('Colorado','CO');
         mapStateCodes.put('Connecticut','CT');
         mapStateCodes.put('Delaware','DE');
         mapStateCodes.put('District of Columbia','DC');
         mapStateCodes.put('Florida','FL');
         mapStateCodes.put('Georgia','GA');
         mapStateCodes.put('Hawaii','HI');
         mapStateCodes.put('Idaho','ID');
         mapStateCodes.put('Illinois','IL');
         mapStateCodes.put('Indiana','IN');
         mapStateCodes.put('Iowa','IA');
         mapStateCodes.put('Kansas','KS');
         mapStateCodes.put('Kentucky','KY');
         mapStateCodes.put('Louisiana','LA');
         mapStateCodes.put('Maine','ME');
         mapStateCodes.put('Maryland','MD');
         mapStateCodes.put('Massachusetts','MA');
         mapStateCodes.put('Michigan','MI');
         mapStateCodes.put('Minnesota','MN');
         mapStateCodes.put('Mississippi','MS');
         mapStateCodes.put('Missouri','MO');
         mapStateCodes.put('Montana','MT');
         mapStateCodes.put('Nebraska','NE');
         mapStateCodes.put('Nevada','NV');
         mapStateCodes.put('New Hampshire','NH');
         mapStateCodes.put('New Jersey','NJ');
         mapStateCodes.put('New Mexico','NM');
         mapStateCodes.put('New York','NY');
         mapStateCodes.put('North Carolina','NC');
         mapStateCodes.put('North Dakota','ND');
         mapStateCodes.put('Ohio','OH');
         mapStateCodes.put('Oklahoma','OK');
         mapStateCodes.put('Oregon','OR');
         mapStateCodes.put('Pennsylvania','PA');
         mapStateCodes.put('Rhode Island','RI');
         mapStateCodes.put('South Carolina','SC');
         mapStateCodes.put('South Dakota','SD');
         mapStateCodes.put('Tennessee','TN');
         mapStateCodes.put('Texas','TX');
         mapStateCodes.put('Utah','UT');
         mapStateCodes.put('Vermont','VT');
         mapStateCodes.put('Virginia','VA');
         mapStateCodes.put('Washington','WA');
         mapStateCodes.put('West Virginia','WV');
         mapStateCodes.put('Wisconsin','WI');
         mapStateCodes.put('Wyoming','WY');
         
         return erenterCallOut();  
    } 
    
    
    /* Start - Methods for fetching e-Renter request ID */
    private static string erenterCallOut()
    {
        Contact_Role__c objCR = new Contact_Role__c();
        String requestId;
        String eRenterStatus;
        Integer eRenterStatusCode;
        try
        {
            String url;
            String un;
            String pw;
            String productId;
            //Fetch the eRenter credentials from custom setting
            objCR =  [Select Current_Address_Country__c, Billing_Zip__c, Middle_Name__c, Billing_City__c, Billing_Address__c, DOB__c, SSN_C__c, Billing_State__c, 
                     FirstName__c, LastName__c From Contact_Role__c 
                     WHERE Id = :cid];
                     
            system.debug('==============objCR=====>>>>>>>>>>>>>>>>'+objCR);
            SL_ERenterCustomSetting__c eRenter = new SL_ERenterCustomSetting__c();
            
            if(objCR.Current_Address_Country__c == 'United States' && objCR.SSN_C__c != '000000000')
                eRenter = (test.isRunningTest()) ? SL_ERenterCustomSetting__c.getValues('test1') : SL_ERenterCustomSetting__c.getValues('1');
                
            else if(objCR.Current_Address_Country__c == 'United States' && objCR.SSN_C__c == '000000000')
                eRenter = (test.isRunningTest()) ? SL_ERenterCustomSetting__c.getValues('test1') : SL_ERenterCustomSetting__c.getValues('1'); 
            
            else if(objCR.Current_Address_Country__c != 'United States' && objCR.SSN_C__c != '000000000')
                eRenter = (test.isRunningTest()) ? SL_ERenterCustomSetting__c.getValues('test2') : SL_ERenterCustomSetting__c.getValues('3');
            
            else if(objCR.Current_Address_Country__c != 'United States' && objCR.SSN_C__c == '000000000')
                eRenter = (test.isRunningTest()) ? SL_ERenterCustomSetting__c.getValues('test3') : SL_ERenterCustomSetting__c.getValues('2');
            if(eRenter != null)
            {
                url = eRenter.endpoint__c;
                un = eRenter.username__c;
                pw = eRenter.password__c;
                productId = eRenter.product_ID__c;
                
                String grade = '1';
                String tlinkDate = Datetime.now().format('yyyy-MM-dd');
                String dob = '';
                if(objCR.DOB__c != null){
                    Datetime dt = Datetime.newInstance(objCR.DOB__c.year(),objCR.DOB__c.month(),objCR.DOB__c.day());
                    dob = dt.format('yyyy-MM-dd');}
                String firstName = objCR.FirstName__c != null ? objCR.FirstName__c : '';
                String lastName = objCR.LastName__c != null ? objCR.LastName__c : '';
                String middleName = objCR.Middle_Name__c != null ? objCR.Middle_Name__c : '';
                String state = mapStateCodes.containsKey(objCR.Billing_State__c) ? mapStateCodes.get(objCR.Billing_State__c) : '';
                String taxId = objCR.SSN_C__c != null ? objCR.SSN_C__c : '';
                String address = objCR.Billing_Address__c != null ? objCR.Billing_Address__c : '';
                String city = objCR.Billing_City__c != null ? objCR.Billing_City__c : '';
                String zip = objCR.Billing_Zip__c != null ? objCR.Billing_Zip__c : '';
                
                system.debug('----------------eRenter---------' + eRenter);
                system.debug('----------------productId---------' + productId);
                system.debug('----------------state---------' + state);
                Http h = new Http();
                HttpRequest req = new HttpRequest();
             
                String doDirectRequest;
                if(productId == '46')
                {
                    doDirectRequest =  '<?xml version="1.0" encoding="UTF-8"?>' +
                                            '<SOAP-ENV:Envelope SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" ' +
                                            'xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" '+
                                            'xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '+
                                            'xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" '+
                                            'xmlns:tns="urn:erapi">'+
                                                '<SOAP-ENV:Body>'+
                                                    '<tns:InsertRequest xmlns:tns="urn:erapi">'+
                                                        '<username xsi:type="xsd:string">'+un+'</username>'+
                                                        '<password xsi:type="xsd:string">'+pw+'</password>'+
                                                        '<product_id xsi:type="xsd:int">'+productId+'</product_id>'+
                                                        '<first_name xsi:type="xsd:string">'+firstName+'</first_name>'+
                                                        '<last_name xsi:type="xsd:string">'+lastName+'</last_name>'+
                                                         '<middle_name xsi:type="xsd:string">'+middleName+'</middle_name>'+
                                                        '<address xsi:type="xsd:string">'+address+'</address>'+
                                                        '<city xsi:type="xsd:string">'+city+'</city>' +
                                                        '<state xsi:type="xsd:string">'+state+'</state>'+
                                                        '<zip xsi:type="xsd:string">'+zip+'</zip>' +
                                                        '<dob xsi:type="xsd:string">'+dob+'</dob>'+
                                                        '<ssn xsi:type="xsd:string">'+taxId+'</ssn>'+
                                                        '<grade xsi:type="xsd:int">'+grade+'</grade>'+
                                                        '<tlink_date xsi:type="xsd:string">'+tlinkDate+'</tlink_date>'+
                                                    '</tns:InsertRequest>'+
                                                '</SOAP-ENV:Body>'+
                                                '</SOAP-ENV:Envelope>';
                }
                else if(productId == '60')
                {
                    doDirectRequest =  '<?xml version="1.0" encoding="UTF-8"?>' +
                                            '<SOAP-ENV:Envelope SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" ' +
                                            'xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" '+
                                            'xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '+
                                            'xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" '+
                                            'xmlns:tns="urn:erapi">'+
                                                '<SOAP-ENV:Body>'+
                                                    '<tns:InsertRequest xmlns:tns="urn:erapi">'+
                                                        '<username xsi:type="xsd:string">'+un+'</username>'+
                                                        '<password xsi:type="xsd:string">'+pw+'</password>'+
                                                        '<product_id xsi:type="xsd:int">'+productId+'</product_id>'+
                                                        '<first_name xsi:type="xsd:string">'+firstName+'</first_name>'+
                                                        '<last_name xsi:type="xsd:string">'+lastName+'</last_name>'+
                                                        '<middle_name xsi:type="xsd:string">'+middleName+'</middle_name>'+
                                                        '<address xsi:type="xsd:string"></address>'+
                                                        '<city xsi:type="xsd:string"></city>' +
                                                        '<state xsi:type="xsd:string"></state>'+
                                                        '<zip xsi:type="xsd:string"></zip>' +
                                                        '<dob xsi:type="xsd:string">'+dob+'</dob>'+
                                                        '<ssn xsi:type="xsd:string">'+taxId+'</ssn>'+
                                                        '<grade xsi:type="xsd:int">'+grade+'</grade>'+
                                                        '<tlink_date xsi:type="xsd:string">'+tlinkDate+'</tlink_date>'+
                                                    '</tns:InsertRequest>'+
                                                '</SOAP-ENV:Body>'+
                                                '</SOAP-ENV:Envelope>';
                                                
                }
                else if(productId == '61')
                {                   
                    doDirectRequest =  '<?xml version="1.0" encoding="UTF-8"?>' +
                                            '<SOAP-ENV:Envelope SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" ' +
                                            'xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" '+
                                            'xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '+
                                            'xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" '+
                                            'xmlns:tns="urn:erapi">'+
                                                '<SOAP-ENV:Body>'+
                                                    '<tns:InsertRequest xmlns:tns="urn:erapi">'+
                                                        '<username xsi:type="xsd:string">'+un+'</username>'+
                                                        '<password xsi:type="xsd:string">'+pw+'</password>'+
                                                        '<product_id xsi:type="xsd:int">'+productId+'</product_id>'+
                                                        '<first_name xsi:type="xsd:string">'+firstName+'</first_name>'+
                                                        '<last_name xsi:type="xsd:string">'+lastName+'</last_name>'+
                                                        '<middle_name xsi:type="xsd:string">'+middleName+'</middle_name>'+
                                                        '<address xsi:type="xsd:string"></address>'+
                                                        '<city xsi:type="xsd:string"></city>' +
                                                        '<state xsi:type="xsd:string"></state>'+
                                                        '<zip xsi:type="xsd:string"></zip>' +
                                                        '<dob xsi:type="xsd:string">'+dob+'</dob>'+
                                                        '<ssn xsi:type="xsd:string">'+taxId+'</ssn>'+
                                                        '<grade xsi:type="xsd:int">'+grade+'</grade>'+
                                                        '<tlink_date xsi:type="xsd:string">'+tlinkDate+'</tlink_date>'+
                                                    '</tns:InsertRequest>'+
                                                '</SOAP-ENV:Body>'+
                                                '</SOAP-ENV:Envelope>';
                }
                
                req.setBody(doDirectRequest);
                req.setEndpoint(url);
                req.setMethod('POST');         
                req.setHeader('Content-Type', 'text/xml;charset=UTF-8'); 
                
                system.debug('----------------doDirectRequest---------' + doDirectRequest);
                system.debug('----------------Request---------' + req);
                system.debug('----------------Request.getBody()---------' + req.getBody());
                
                // since Test Methods do not support web callouts
                if(!Test.isRunningTest())
                {
                    HttpResponse res = h.send(req);
                    string response = string.valueOf(res);
                    system.debug('----------------response---------' + response);
                    system.debug('----------------res.getBody()---------' + res.getBody());
                    String xml = res.getBody();
                    XmlStreamReader reader = res.getXmlStreamReader();
                    reader = res.getXmlStreamReader();
                    requestId = readXMLResponse(reader, 'request_id');
                    eRenterStatus = res.getStatus();
                    eRenterStatusCode =  res.getStatusCode();
                    objCR.e_Renter__c = requestId;
                    update objCR;
                }
                else
                {
                    String reader = '<books><book>My Book</book><book>Your Book</book></books>';
                    XmlStreamReader xsr= new XmlStreamReader(reader);
                    requestId = readXMLResponse(xsr, 'testRequestId');
                }
            }
            system.debug('==========eRenterStatusCode=========='+eRenterStatusCode);
            return String.ValueOf(eRenterStatusCode);
        }
        catch(Exception ex)
        { 
            system.debug('----------------------EXCEPION FROM ERENTER--------------'+ex);
            return ex.getMessage(); 
        }
    }
    
    private static String readXMLResponse(XmlStreamReader reader, String sxmltag) 
    {
        try
        {
			string retValue; // Read through the XML
			while(reader.hasNext())
          	{
            	if (reader.getEventType() == XmlTag.START_ELEMENT)
            	{
              		if (reader.getLocalName() == sxmltag)
              		{
                		reader.next();
                		if (reader.getEventType() == XmlTag.characters)
                		{
                  			retValue = reader.getText();
                		}
              		}
            	}
            	reader.next();
          	}
          	return retValue;
        }
        catch(Exception ex)
        {
            return null;
        }
    }
    /* End - Methods for fetching e-Renter request ID */
}