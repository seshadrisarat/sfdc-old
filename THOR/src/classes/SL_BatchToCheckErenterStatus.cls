/**
*  ClassName      : SL_BatchToCheckErenterStatus
*  JIRATicket     : THOR-11
*  CreatedOn      : 14/OCT/2014
*  ModifiedBy     : Sanath Kumar
*  Description    : This is the class to check eRenter status
*/
global class SL_BatchToCheckErenterStatus implements Database.Batchable<Sobject>, Database.AllowsCallouts
{
	/* START : Global variables */
    public string strQuery = '';
    public String PENDING = 'PENDING';
    /* END : Global variables */ 
    
    
    /* Start : Constructor */
    public SL_BatchToCheckErenterStatus(String strQuery)
    {
    	this.strQuery = strQuery;
    }
    /* End : Constructor */
    
    
    /*
    	* MethodName   : start
        * Param        : Database.BatchableContext BC
        * Description  : This method returns Contact role records with pending status
    */
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
    	return Database.getQueryLocator(strQuery);
    }
    
    
    /*
    	* MethodName   : execute
        * Param        : Database.BatchableContext BC, List<Contact_Role__c> lstContactRole
        * Description  : Processes Contact Role records returned by start method
    */
    global void execute(Database.BatchableContext BC, List<Contact_Role__c> lstContactRole)
    {
        String url;
        String strUserName;
        String strPassword;
        String strErenterStatus;
        String strErenterStatusMessage;
        String  strPdfResponse;
        String PASS = 'PASS';
        String DECLINE = 'DECLINE';
        
        try
        {
        	///Scope for this batch has been set to 1, so it would be a single record
            for(Contact_Role__c objContactRole:lstContactRole)
            {
	            SL_ERenterCustomSetting__c eRenter = new SL_ERenterCustomSetting__c();
	            
	            if(objContactRole.Current_Address_Country__c == 'United States' && objContactRole.SSN_C__c != '000000000')
	                eRenter = (test.isRunningTest()) ? SL_ERenterCustomSetting__c.getValues('value1') : SL_ERenterCustomSetting__c.getValues('1');
	            else if(objContactRole.Current_Address_Country__c == 'United States' && objContactRole.SSN_C__c == '000000000')
	                eRenter = (test.isRunningTest()) ? SL_ERenterCustomSetting__c.getValues('value1') : SL_ERenterCustomSetting__c.getValues('1'); 
	            else if(objContactRole.Current_Address_Country__c != 'United States' && objContactRole.SSN_C__c != '000000000')
	                eRenter = (test.isRunningTest()) ? SL_ERenterCustomSetting__c.getValues('value2') : SL_ERenterCustomSetting__c.getValues('3');
	            else if(objContactRole.Current_Address_Country__c != 'United States' && objContactRole.SSN_C__c == '000000000')
	                eRenter = (test.isRunningTest()) ? SL_ERenterCustomSetting__c.getValues('value3') : SL_ERenterCustomSetting__c.getValues('2');
	            
	            if(eRenter != null)
	            {
	                url = eRenter.endpoint__c;
	                strUserName = eRenter.username__c;
	                strPassword = eRenter.password__c;
	                
	                Http h = new Http();
	                HttpRequest req = new HttpRequest();
	             
	                String doDirectRequest;
	                doDirectRequest =  '<?xml version="1.0" encoding="UTF-8"?>'+
                                       		'<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" '+ 
                                       		'xmlns:ns1="urn:erapi" xmlns:xsd="http://www.w3.org/2001/XMLSchema" '+
                                        	'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '+
    										'xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" '+
    										'SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'+
    											'<SOAP-ENV:Body>'+
    												'<ns1:ApplicantNotice>'+
      													'<username xsi:type="xsd:string">'+strUserName+'</username>'+
  														'<password xsi:type="xsd:string">'+strPassword+'</password>'+
  														'<request_id xsi:type="xsd:string">'+objContactRole.e_Renter__c+'</request_id>'+
    												'</ns1:ApplicantNotice>'+
    											'</SOAP-ENV:Body>'+
										'</SOAP-ENV:Envelope>';
                                        
	                req.setBody(doDirectRequest);
	                req.setEndpoint(url);
	                req.setMethod('POST');         
	                req.setHeader('Content-Type', 'text/xml;charset=UTF-8');
	                
	                // since Test Methods do not support web callouts
	                if(!Test.isRunningTest())
	                {
	                    HttpResponse res = h.send(req);
	                    string response = string.valueOf(res);
	                    String xml = res.getBody();
	                    XmlStreamReader reader = res.getXmlStreamReader();
	                    reader = res.getXmlStreamReader();
	                    system.debug('----------------------res.getBody()------>>>>>>>>>>>'+res.getBody());
	                    strErenterStatus = readXMLResponse(reader, 'status'); 
	                    reader = res.getXmlStreamReader();
	                    strErenterStatusMessage = readXMLResponse(reader, 'message');
	                    system.debug('----------------------strErenterStatusMessage------>>>>>>>>>>>'+strErenterStatusMessage);
	                    objContactRole.e_renter_Application_Status__c = strErenterStatus;
	                    objContactRole.e_renter_Application_Status_Message__c = strErenterStatusMessage;
	                    objContactRole.Status__c = 'E-Renter Received';
	                }
	                else
	                {
	                    String reader = '<books><message>PASS</message><testMessage>Your Book</testMessage></books>';
	                    XmlStreamReader xsr = new XmlStreamReader(reader);
	                    strErenterStatus = readXMLResponse(xsr, 'message');
	                    strErenterStatusMessage = readXMLResponse(xsr, 'testMessage');
	                }
	                
	                ///Create a pdf report
	                if(strErenterStatus == PASS || strErenterStatus == DECLINE)
	                {
	                	Http ht = new Http();
		                HttpRequest httpreq = new HttpRequest();
		             
		                String strRequest;
		                strRequest =  '<?xml version="1.0" encoding="UTF-8"?>'+
	                                       		'<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" '+ 
	                                       		'xmlns:ns1="urn:erapi" xmlns:xsd="http://www.w3.org/2001/XMLSchema" '+
	                                        	'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '+
	    										'xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" '+
	    										'SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'+
	    											'<SOAP-ENV:Body>'+
	    												'<ns1:RetrieveReport>'+
	      													'<username xsi:type="xsd:string">'+strUserName+'</username>'+
	  														'<password xsi:type="xsd:string">'+strPassword+'</password>'+
	  														'<request_id xsi:type="xsd:string">'+objContactRole.e_Renter__c+'</request_id>'+
	    												'</ns1:RetrieveReport>'+
	    											'</SOAP-ENV:Body>'+
											'</SOAP-ENV:Envelope>';
	                                        
		                httpreq.setBody(strRequest);
		                httpreq.setEndpoint(url);
		                httpreq.setMethod('GET');         
		                httpreq.setHeader('Content-Type', 'text/xml;charset=UTF-8');
		                httpreq.setHeader('Accept', 'text/html;charset=utf-8'); 
		                
		                // since Test Methods do not support web callouts
		                if(!Test.isRunningTest())
		                {
		                    HttpResponse response = ht.send(httpreq);
		                    String xml = response.getBody();
		                    system.debug('----------------------response.getBody()------>>>>>>>>>>>'+response.getBody());
		                    ///Modify the html content in response

		                    xml = xml.replaceall('&lt;','<');
					        xml = xml.replaceall('&rt;','>');
					        xml = xml.replaceall('&gt;','>');
					        xml = xml.replaceall('&quot;','"');
					        xml = xml.replaceall('&amp;nbsp;',' ');
					      	
					        system.debug('===>>>>' + xml);

					        /*Added for THOR-67*/

					        /*Approach 1*/	
					        	/*String style='<head><style>div.marker ' + 
											'{ float: left; font-size: 80%; padding: 3px; color: #888; }'+ 
										'div.marker div '+ 
											'{ text-align: center; padding: 5px; border-radius: 3px; color: #fff; width: 20px; }</style></head>'; 

					        	List<String> responseList= xml.split('<response xsi:type="xsd:string">');
					        	xml = String.join(responseList , '<response xsi:type="xsd:string">' + style);*/
					        /*Approach 1*/
					        
					        /*Approach 2*/		
					        	/*xml += '<style>div.marker ' + 
											'{ float: left; font-size: 80%; padding: 3px; color: #888; }'+ 
										'div.marker div '+ 
											'{ text-align: center; padding: 5px; border-radius: 3px; color: #fff; width: 20px; }</style>'; */
					        /*Approach 2*/
					        /*Added for THOR-67*/

		                    ///Create a pdf report
		                    if(objContactRole.Opportunity__c != null)
		                    {
			                    Attachment attachmentPDF = new Attachment();
					            attachmentPDF.parentId = objContactRole.Opportunity__c;
					            attachmentPDF.Name = objContactRole.Name +'.pdf';
					            attachmentPDF.Body = blob.toPdf(xml);
					            insert attachmentPDF; 
					            
					            Attachment attachmentPDF1 = new Attachment();
					            attachmentPDF1.parentId = objContactRole.Id;
					            attachmentPDF1.Name = objContactRole.Name +'.pdf';
					            attachmentPDF1.Body = blob.toPdf(xml);
					            insert attachmentPDF1;  
		                    }
                    	
                    		update objContactRole; 
		                }
	                }
	            }
	        }
        }
        catch(Exception ex)
        { 
            system.debug('----------------------EXCEPION FROM ERENTER--------------'+ex + ex.getLineNumber());
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
    
    
    /*
    	* MethodName   : finish
        * Param        : Database.BatchableContext BC
        * Description  : Performs necessary post-execution steps
    */
    global void finish(Database.BatchableContext BC)
    {
        ///Does nothing
    }
}