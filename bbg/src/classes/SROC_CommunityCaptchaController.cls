public with sharing class SROC_CommunityCaptchaController {
	
	private static String baseUrl = 'https://www.google.com/recaptcha/api/siteverify';
    
    // The keys you get by signing up for reCAPTCHA for your domain
    private static String secret = '6LcwOQ4TAAAAAFwFxUNfd_eXHNvEF8EQhKtlehF-';
    
    public String sitekey {
        get { return '6LcwOQ4TAAAAABAvaw85gD63ONcdpXBclTYVIc0C'; }
    }
    public String response  { 
        get { return ApexPages.currentPage().getParameters().get('g-recaptcha-response'); }
    }
    
    // this method is called when the button is clicked
    public PageReference doVerify () {
        String responseBody = makeRequest(baseUrl,
                'secret=' + secret +
                '&response='+ response
        );
        String success = getValueFromJson(responseBody, 'success');
        if(success.equalsIgnoreCase('true')){
            ApexPages.Message successMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'You are really a human!');
            ApexPages.addMessage(successMsg);
        }else{
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please verify the captcha');
            ApexPages.addMessage(errorMsg);
        }
        return null;
    }
    
    /**
     * Make request to verify captcha
     * @return      response message from google
     */
    private static String makeRequest(string url, string body)  {
        HttpResponse response = null;
        HttpRequest req = new HttpRequest();   
        req.setEndpoint(url);
        req.setMethod('POST');
        req.setBody (body);
        
        try {
            Http http = new Http();
            response = http.send(req);
            return response.getBody();
        } catch(System.Exception e) {
            System.debug('ERROR: ' + e);
        }
        return '{"success":false}';
    }   
    
    /**
     * to get value of the given json string
     * @params      
     *  - strJson       json string given
     *  - field         json key to get the value from
     * @return          string value
     */
    public static string getValueFromJson ( String strJson, String field ){
        JSONParser parser = JSON.createParser(strJson);
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)) {
                if(parser.getText() == field){
                    // Get the value.
                    parser.nextToken();
                    return parser.getText();
                }
            }
        }
        return null;
    }
}