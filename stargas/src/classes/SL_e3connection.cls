public class SL_e3connection {
	public string responseBody {get;set;}

    public PageReference teste3connection() {
    
	// Instantiate a new http object
    Http h = new Http();
    
    //SL_E3_CustomerMaint customermaint = new SL_E3_CustomerMaint();
    /*
	// Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
    HttpRequest req = new HttpRequest();
    req.setEndpoint('https://smart.petroheat.com/WSSmartConnect/cCustomerMaint.asmx');
    String username = 'SaleSfOrCeLeadS';
    String password = 'G3tM3@cc0untsN0w';
    //String body = '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">  <soap:Body>    <GetCustTemplates xmlns="http://www.addsys.com/">      <p_iCompanyID>short</p_iCompanyID>      <p_iRecordType>short</p_iRecordType>      <p_iMaintenanceMode>short</p_iMaintenanceMode>      <p_sSysUser>string</p_sSysUser>      <p_lErrorCode>int</p_lErrorCode>    </GetCustTemplates>  </soap:Body></soap:Envelope>';
    Blob headerValue = Blob.valueOf(username + ':' + password);
    String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
    req.setHeader('Authorization', authorizationHeader);
    //req.setHeader('SOAPAction', '"http://www.addsys.com/GetCustTemplates"');
    //req.setHeader('Content-Type', 'text/xml; charset=utf-8');
    //req.setHeader('Content-Length', '1293');
    //req.setBody(body);
    req.setMethod('GET');
	// Send the request, and return a response
    HttpResponse res = h.send(req);
    responseBody =  res.getBody();
    return null;
*/
	//Build authentication header
	String username = 'SaleSfOrCeLeadS';
    String password = 'G3tM3@cc0untsN0w';
    //String body = '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">  <soap:Body>    <GetCustTemplates xmlns="http://www.addsys.com/">      <p_iCompanyID>short</p_iCompanyID>      <p_iRecordType>short</p_iRecordType>      <p_iMaintenanceMode>short</p_iMaintenanceMode>      <p_sSysUser>string</p_sSysUser>      <p_lErrorCode>int</p_lErrorCode>    </GetCustTemplates>  </soap:Body></soap:Envelope>';
    Blob headerValue = Blob.valueOf(username + ':' + password);
    String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
    
    /*
    //Test for cUtilitySoap
	SL_E3_cUtility.cUtilitySoap cUtilitySoap = new SL_E3_cUtility.cUtilitySoap();
	cUtilitySoap.inputHttpHeaders_x = new Map<String, String>();
	cUtilitySoap.inputHttpHeaders_x.put('Authorization', authorizationHeader);
	
	responseBody = 'Response from GetEnergyAPIVersion():' + cUtilitySoap.GetEnergyAPIVersion();
	*/
	
	//Test for cCustomerMaintSoap
	SL_E3_CustomerMaint.cCustomerMaintSoap cCustomerMaintSoap = new SL_E3_CustomerMaint.cCustomerMaintSoap();
	cCustomerMaintSoap.inputHttpHeaders_x = new Map<String, String>();
	cCustomerMaintSoap.inputHttpHeaders_x.put('Authorization', authorizationHeader);
	
	responseBody = 'Response from GetCustTemplates():' + cCustomerMaintSoap.GetCustTemplates(70,0,3,'WebUser', 0);
	//cCustomerMaintSoap.GetCustTemplates(p_iCompanyID, p_iRecordType, p_iMaintenanceMode, p_sSysUser, p_lErrorCode)
	
	
	//system.debug('responseBody: ' + responseBody);
	return null;
	}
  
}