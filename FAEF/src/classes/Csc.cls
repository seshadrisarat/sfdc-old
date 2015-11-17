/**
* @author Alan Talanoa, Tamarack Consulting, Inc.
* @date 07/14/2014
* @description This class wraps the CSC UCC web services 
* ©Copyright 2003 - 2014 Tamarack Consulting, Inc.  All Rights Reserved.
*/


global class Csc {
  private static String endpoint = '';
  private static String envelope = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/"><soapenv:Body>XXX</soapenv:Body></soapenv:Envelope>';
  private static String login_uid = '';
  private static String contact = '';
  private static Integer httpTimeout = 60000;
  private static String uccType = 'UCC1';
  private static Integer uccYearsBackToCheck = 7;
  public class ApplicationException extends Exception {}
  public class ApplicationFatalException extends Exception {} //this one is only for when there is problem with callout
  public class NoUCCResultsException extends Exception {} // no resutls error.
 
  static{
  	// single setting vs list
  	CSC_Integration__c settings = CSC_Integration__c.getValues('csc');
  	endpoint = settings.endpoint__c;
  	login_uid = settings.login__c;
  	contact = settings.contact__c;
  }
 
/**
* @author Alan Talanoa, Tamarack Consulting, Inc.
* @date 07/14/2014
* @description Utiltiy method that builds the CSC web service request, 
* @param soapBody This is content of the soap body for the particular csc service call.
* @return return response of the web service
* ©Copyright 2003 - 2014 Tamarack Consulting, Inc.  All Rights Reserved.
*/
  public static String getWebResponse(String soapBody) {
	return processResponse(buildRequest(soapBody));
  }
  
/**
* @author Alan Talanoa, Tamarack Consulting, Inc.
* @date 07/14/2014
* @description Utiltiy method that builds the CSC web service request, 
* @param soapBody This is content of the soap body for the particular csc service call.
* @return return response of the web service
* ©Copyright 2003 - 2014 Tamarack Consulting, Inc.  All Rights Reserved.
*/ 
  public static HttpRequest buildRequest(String soapBody){
  	HttpRequest req = new HttpRequest();
    req.setTimeout(httpTimeout);
    req.setEndpoint(endpoint);
    req.setHeader('content-type', 'text/xml; charset=utf-8');
    req.setHeader('SOAPAction', 'http://eservices.diligenz.com/SubmitOnlineSearch');
    req.setMethod('POST');
    String soap_data = envelope.replace('XXX', soapBody);
    req.setBody(soap_data);
    System.debug('request built');
    return req;
  }
  
  // Helper method that takes in http request and returns the body of response
  private static String processResponse(HttpRequest req){
  	Http h = new Http();
    return h.send(req).getBody();
  }

  // This is the second web requests to CSC
  public static String getDetailResults(String orderId, String login) {
  	System.debug('u');
    String body = '<GetDetailResults xmlns="http://eservices.diligenz.com/"><params><param name="loginGuid">' + login + '</param><param name="contactNo">' + contact + '</param><param name="orderID">' + orderId + '</param></params></GetDetailResults>';
    Dom.Document doc = new Dom.Document();
    System.debug(body);
    doc.load(getWebResponse(body));
    return (doc.toXmlString());
  }

  // facade method
  public static String getDetailResults(String orderId) {
    System.debug('getDetailResults');
    return getDetailResults(orderId, login_uid);
  }

  // this method will update an account record with a CSC order id.
  // the method name should be changed on next update to reflect what it's doing better
  webservice static void updateUccRecord(String accountId) {

    Account account = [Select ucc_name_search__c, State_of_Incorporation__c, Id, name from Account where id = : accountId limit 1][0];
    String state = account.State_of_Incorporation__c;
    String company = account.ucc_name_search__c;
    String reference = account.Id;
    if(String.isEmpty(company)){
    	company = account.Name;
    }
    //20140807 - kdolan - Update to encode the XML
    
    //company = company.replace('>', '&gt;');
    //company = company.replace('<', '&lt;');
    //company = company.replace('&', '&amp');
    //company = company.replace('\'', '&apos');
    //company = company.replace('"', '&quot;');
	//CSC can not handle the escaped XML.  So, removing the reserved characters.
    company = company.replace('>', '');
    company = company.replace('<', '');
    company = company.replace('&', '');
    company = company.replace('\'', '');
    company = company.replace('"', '');

      
    if(String.isEmpty(company)){
    	throw new ApplicationException('Error:Please provide a valid company name for the UCC search.');
    }
    if(state == null || state.length() != 2){
    	throw new ApplicationException('Error:In order to process a UCC search, the associated customer must have a valid state of incorporation selected.');
    }
    
    //sfdcdev - 2/5/15 
    account.UCCs_Last_Checked_On__c = System.today();
    account.CSC_Order_Number__c = submitOnlineSearch(state, company, reference);
    update account;
  }

  // facade method
  public static String submitOnlineSearch(String state, String company, String reference) {
    String login = login_uid;
    return submitOnlineSearch(state, company, reference, login);
  }
  // This method handles the submit online request to CSC
  public static String submitOnlineSearch(String state, String company, String reference, String login) {
    String body = '<SubmitOnlineSearch xmlns="http://eservices.diligenz.com/"> <params><param name="loginGuid">' + login + '</param><param name="contactNo">' + contact + '</param><param name="stateCD">' + state + '</param><param name="type">UCC</param><param name="companyName">' + company + '</param><param name="showAllResults">true</param><param name="references"><array><item><key>app_id1</key> <value>' + reference + '</value></item> </array></param></params></SubmitOnlineSearch>';

    Dom.Document doc = new Dom.Document();
    String resp = getWebResponse(body);
    doc.load(resp);
    String ns = 'http://schemas.xmlsoap.org/soap/envelope/';
    String wns = 'http://eservices.diligenz.com/';
    if(doc == null){
    	throw new NoUCCResultsException ('Error:The CSC service did not successfully return results for ' + company);
    }
    Dom.Xmlnode returnNode = null;
    try{
    	returnNode =  doc.getRootElement().getChildElement('Body', ns)
      .getChildElement('SubmitOnlineSearchResponse', wns)
      .getChildElement('SubmitOnlineSearchResult', wns)
      .getChildElement('return', wns);
    }catch(Exception e){
		throw new NoUCCResultsException ('Error:The CSC service did not successfully return results for \'' + company + '\'. Too many results? Please specify a more specific UCC Search Name.');    	
    }

    String orderId = returnNode
      .getChildElement('orderInfo', wns).getChildElement('OrderID', wns).getText();
  
    if(returnNode.getChildElements().size() == 1 ){
		throw new NoUCCResultsException ('Error:There were no available UCC Records for ' + company);
 
    }
    
    if(returnNode.getChildElements().size() > 500){
		throw new ApplicationFatalException ('Error:There were over 500 results matched the search for ' + company + '. Please refine the company name to search for. There were ' + returnNode.getChildElements().size() + ' records. Please reduce to 500 or less.');
 
    }    
    return orderId;
  }
  // gets the debtor names from the response
  public static String[] getNames(String xml) {
    Dom.Document doc = new Dom.Document();
    System.debug(xml);
    doc.load(xml);

    String ns = 'http://schemas.xmlsoap.org/soap/envelope/';
    String wns = 'http://eservices.diligenz.com/';
    Dom.XmlNode[] detailResults = doc.getRootElement()

    .getChildElement('Body', ns)
      .getChildElement('GetDetailResultsResponse', wns)
      .getChildElement('GetDetailResultsResult', wns)
      .getChildElement('return', wns)
      .getChildren();
    Map < String, Integer > names = new Map < String, Integer > ();
    for (Dom.XmlNode node: detailResults) {

      if (node.getName() == 'detailResults') {
        String d = getValue(node, wns, 'DebtorName');
        if(d != null && d.length() > 0){
        	
          Date fileDate = date.valueOf((
          					getValue(node, wns, 'FilingDate').split('T', 0)[0]) 
          					+ ' 00:00:00');
            
          Date currentTimeFrame = System.now().addYears(-1 * uccYearsBackToCheck).date();      
          if(!uccType.equals(getValue(node, wns, 'FilingCat'))  || fileDate < currentTimeFrame)
          {
          	continue;
          }
          if(names.get(d) == null){
          	names.put(d, 1);
          }
          else{
            names.put(d, names.get(d) + 1);
          }
        }
      }
    }
 
    List < String > rVal = new List < String > ();
    for( String key: names.keySet()){
    	rVal.add(''+ key + ' - (' + names.get(key) + ')');
    }
    rVal.sort();
    return rVal;
  }

  public static String getValue(Dom.XmlNode node, String ns, String element){
  	if(node == null || node.getChildElement(element, ns) == null){
  	return null;
  	}
  	else{
  	  return node.getChildElement(element, ns).getText().trim();	
  	}
  	
  }
  // Get a list of UCCs via the getDetailResults CSC query
  public static List < Ucc > getSecuredNames(String xml, String debtor) {
    Dom.Document doc = new Dom.Document();
    System.debug('loading secure names');
    doc.load(xml);
    String ns = 'http://schemas.xmlsoap.org/soap/envelope/';
    String wns = 'http://eservices.diligenz.com/';
    Dom.XmlNode[] detailResults = doc.getRootElement()
    .getChildElement('Body', ns)
      .getChildElement('GetDetailResultsResponse', wns)
      .getChildElement('GetDetailResultsResult', wns)
      .getChildElement('return', wns)
      .getChildren();
    System.debug('dom loaded');
    List < Ucc> names = new List < Ucc> ();
    for (Dom.XmlNode node: detailResults) {
      
      if (node.getName() == 'detailResults') {
        String name = getValue(node, wns, 'DebtorName');
        if (name == debtor) {
          
          String securedName = getValue(node, wns, 'SecuredPartyName');
          String id = getValue(node, wns, 'ID');

          Ucc ucc = new Ucc();
    
          ucc.filingCat = getValue(node, wns, 'FilingCat');
          
                    Date fileDate = date.valueOf((
          					getValue(node, wns, 'FilingDate').split('T', 0)[0]) 
          					+ ' 00:00:00');
            
          Date currentTimeFrame = System.now().addYears(-1 * uccYearsBackToCheck).date();      
   
          if(!uccType.equals(ucc.filingCat) || fileDate < currentTimeFrame)
          {
          	continue;
          }
          System.debug('secured name');
          ucc.name = securedname;
          ucc.filingDate = getValue(node, wns, 'FilingDate');
          ucc.debtorName = getValue(node, wns, 'DebtorName');
          ucc.debtorAddress1 = getValue(node, wns, 'DebtorAddress1');
          ucc.debtorCity = getValue(node, wns, 'DebtorCity');
          ucc.debtorState = getValue(node, wns, 'DebtorState');
          ucc.debtorZip = getValue(node, wns, 'DebtorZip');
          ucc.securedAddress1 = getValue(node, wns, 'SecuredAddress1');
          ucc.securedCity = getValue(node, wns, 'SecuredCity');
          ucc.securedState = getValue(node, wns, 'SecuredState');
          ucc.securedZip = getValue(node, wns, 'SecuredZip');

		  ucc.filingDateExp = getValue(node, wns, 'FilingDateExp');
          ucc.origFilingNum = getValue(node, wns, 'OrigFilingNum');
          ucc.filingCat = getValue(node, wns, 'FilingCat');
          ucc.filingNum = getValue(node, wns, 'FilingNum');
          ucc.origFilingDate = getValue(node, wns, 'OrigFilingDate');            
          ucc.origFilingCat = getValue(node, wns, 'OrigFilingCat');        
          ucc.collateral = getValue(node, wns, 'Collateral');
          ucc.id = id;
          System.debug('adding names');
          names.add(ucc);
        }
      }
    }
    return names;
  }

}