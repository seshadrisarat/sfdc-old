global class GeoNamesWebService {

//global String url = 'http://ba-ws.geonames.net/postalCodeSearch?username=gluna1';
// Pass in the ipaddress to be used
  
    public static Boolean isApexTest = false;
    global static Map<String, String> getLocationInfo(String postalcode, String country, String city ,Boolean dealerLocator) {

    String postalCodeUrl = null;
    String cityUrl = null;
    String defaultUrl ='http://ba-ws.geonames.net/postalCodeSearch?username=gluna1';
     
    system.debug('postalcode ='+postalcode);
    system.debug('country ='+country);
    system.debug('city ='+city);
    
    Map<String, String> elementMap = new Map<String, String>();
    if( dealerLocator ){
    	postalCodeUrl = 'http://ba-ws.geonames.net/postalCodeSearch?username=gluna1&postalcode='+postalcode+'&maxRows=1&country='+country;
    	system.debug('dealerLocator postalCodeUrl---->'+postalCodeUrl);    	
    }
    if(postalcode != null && !dealerLocator){
       postalCodeUrl = 'http://ba-ws.geonames.net/postalCodeSearch?username=gluna1&postalcode='+postalcode+'&country='+country; 
        system.debug('postalCodeUrl---->'+postalCodeUrl);
    }      
    if(postalcode == null && city != null && country != null && !dealerLocator){  
       cityUrl = 'http://ba-ws.geonames.net/search?q='+city+'&maxRows=1&username=gluna1&country='+country+'&featureClass=P&style=FULL';
        system.debug('cityUrl---->'+cityUrl);       
    } 
     
     system.debug('---------postalCodeUrl---->'+postalCodeUrl);
     system.debug('---------cityUrl---->'+cityUrl);
    // Instantiate a new http object 
    Http h = new Http();
    // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint 
    HttpRequest req = new HttpRequest();
    
    if(cityUrl != null )
      req.setEndpoint(cityUrl);
    else if(postalCodeUrl != null)
      req.setEndpoint(postalCodeUrl);
    else
      req.setEndpoint(defaultUrl); 
       
    req.setMethod('GET');
    HttpResponse res = new HttpResponse();
      
    // Send the request, and return a response   
    try {
       if(!Test.isRunningTest()){
       res = h.send(req);
       system.debug('---------res---->'+res);
       }
       else
       {
        
        if(postalcode.replace('+', ' ') == TestLeadServices.ERROR_CODE){ //this postal code should give us a server error
          res.setStatus('Service Unavailable');
          res.setStatusCode(503);
          res.setBody('The service is temporarily unavailable');
        } else if(postalcode=='NoResultsTest'){
         res.setStatus('OK');
         res.setStatusCode(200);
         res.setBody('<geonames><totalResultsCount>0</totalResultsCount></geonames>');
        }
        else{        
         res.setStatus('OK');
         res.setStatusCode(200);
         res.setBody('<?xml version="1.0" encoding="UTF-8" standalone="no"?><geonames><totalResultsCount>1</totalResultsCount><code><postalcode>95035</postalcode><name>Milpitas</name><countryCode>CA</countryCode><lat>37.4352</lat><lng>-121.895</lng><adminCode1>CA</adminCode1><adminName1>California</adminName1><adminCode2>085</adminCode2><adminName2>Santa Clara</adminName2><adminCode3/><adminName3/></code></geonames>');
        }
       }
       if(res.getStatus() != 'OK') {
       elementMap.put('WebService Exception: ','WebService Exception: '+res.toString());   
       }       
              
    } Catch(Exception c) {
         elementMap.put('WebService Exception: ','WebService Exception: '+c.getMessage());  

    }
   if(res != null && res.getStatus() == 'OK') {
       try {
          system.debug('--------bodydocument--------'+res.getBodyDocument());   
          Dom.Document doc = res.getBodyDocument();
          system.debug('-------RootElement---------'+doc.getRootElement());
          Dom.XMLNode rootNode = doc.getRootElement();   
          system.debug('---------elementMap---->'+rootNode.getChildElements());            
          for(Dom.XMLNode child : rootNode.getChildElements()) {
                  if(child.getname() == 'status') {
                  elementMap.put('WebService Exception: ','WebService Exception: '+child.getAttributeValue('message',null));  
              }       
              system.debug('Child ='+child.getname());
              if(child.getname() == 'code') {
                  for(Dom.XMLNode child1 : child.getChildElements()) {
                      elementMap.put(child1.getName(),child1.getText());  
                  }                    
              }else if(child.getname() == 'geoname'){
              	for(Dom.XMLNode child1 : child.getChildElements()) {
              		 system.debug('---------child1---->'+child1); 
                      elementMap.put(child1.getName(),child1.getText());  
                  }
              }                        
           }
       } Catch(System.XmlException e) {
       	    system.debug('exception message'+ e.getMessage());
            elementMap.put('XML Parsing Exception: ','Error Parsing Webservice response: '+e.getMessage());      
        }  
   } 
    system.debug('---------elementMap---->'+elementMap); 
    return elementMap;    
  } 
  
 }