public virtual class SL_StripeCallouts 
{
	private static final String STRIPE_CALLOUT_URL = 'https://api.stripe.com/v1/';
	private HttpRequest req;
	private blob headerValue;
	private String authorizationHeader;
	private String API_Key;
	private Http conn;
	private HttpResponse response;
	
	public enum stripemode { LIVE, TEST }
    
    protected map<String, String> dispatcher(String relativePath, String method, stripemode mode, Object o)
    {
    	initialDispatch(relativePath, method, mode);
    	setBody(o);
    	return dispatchEnd();
    }
    
    protected map<String, String> dispatcher(String relativePath, String method, stripemode mode)
    {
    	initialDispatch(relativePath, method, mode);
    	return dispatchEnd();
    }
    
    protected map<String, String> dispatcher(String relativePath, String method, stripemode mode, String body)
    {
    	initialDispatch(relativePath, method, mode);
    	req.setBody(body);
    	return dispatchEnd();
    }
    
    private void initialDispatch(String relativePath, String method, stripemode mode)
    {
    	setEndpoint(relativePath);
    	setMethod(method);
    	setHeader(mode);
    }
    
    private map<String, String> dispatchEnd()
    {
    	map<String, String> output = new map<String, String>();
    	String msg = sendRequest();
    	if(!msg.contains('CalloutException'))
    	{
    		output.put('json', msg);
    		output.put('error', '');
    	}
    	else
    	{
    		output.put('error', msg);
    		output.put('json', '');
    	}
    	output.put('status', String.valueOf(getStatus()));
    	return output;
    }
    
    private void setEndpoint(String relativePath)
    {
    	req = new HttpRequest();
    	String endpoint = STRIPE_CALLOUT_URL + relativePath;
    	req.setEndpoint(endpoint);
    }
    
    private void setMethod(String method)
    {
    	req.setMethod(method);
    }
    
    private void setHeader(stripemode mode)
    {
    	API_Key = setApiKey(mode);
    	headerValue = Blob.valueOf(API_Key + ':');
        authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
    }
    
    private void setBody(Object o)
	{       
		String jsonStr = JSON.serialize(o);
		jsonStr = filterRequest(jsonStr);
		map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(jsonStr);
		String body = '';
		for(String key : m.keyset())
		{
			if( m.get(key) != null)
			{
				System.debug(Logginglevel.INFO, 'KEY: ' + key);
				System.debug(Logginglevel.INFO, 'VALUE: ' + m.get(key));
				if(!String.isBlank(body))
				{
					body += '&';
				}
				if( key.trim() == 'card' && m.get(key) instanceOf map<String,object>)
				{
					System.debug(Logginglevel.INFO, 'key == card');
					map<String, Object> card = (map<String, Object>)m.get(key);
					System.debug(Logginglevel.INFO, 'card: ' + card);
					for(String cardKey : card.keyset())
					{
						if( card.get(cardKey) != null)
						{
							if(!String.isBlank(body) && !body.endsWith('&'))
							{
								body += '&';
							}
							body += 'card[' + cardKey + ']=' + card.get(cardKey);
						}
					}
				}
				else
				{
					body += key + '=' + m.get(key);
				}
			}
		}
		System.debug(Logginglevel.INFO, 'Body, which is sent to the service:');
		System.debug(Logginglevel.INFO, body);
		req.setBody(body);
	}
	
	private String sendRequest()
    {
    	try
    	{
    		conn = new Http();
    		response = conn.send(req);
    		System.debug('Status Code: ' + response.getStatusCode());
    		return response.getBody();
    	}
    	catch(calloutException ce)
    	{
    		String msg = ce.getTypeName() + ' at line ' + ce.getLineNumber() + ' -- ' + ce.getMessage();
    		System.debug(msg);
    		return msg;
    	}
    }
    
    private Integer getStatus()
    {
    	return response.getStatusCode();
    }
    
    private String setApiKey( StripeMode oMode ) {
    	if( Test.isRunningTest() ) {
    		return 'TEST_KEY';
    	} else {
			if ( oMode == StripeMode.TEST ) {
	    		return Stripe_Key__c.getValues('test').value__c;
	    	} else {
	        	return Stripe_Key__c.getValues('live').value__c;
	    	}
    	}
    	return null;
    }
        
	private String filterRequest(String value)
	{
		value = value.replaceall('"xCurrency"\\s*:', '"currency" :');
		value = value.replaceall('"xObject"\\s*:', '"object" :');
		value = value.replaceall('"xCount"\\s*:', '"count" :');
		value = value.replaceall('"xData"\\s*:', '"data" :');
		value = value.replaceall('"xType"\\s*:', '"type" :');
		value = value.replaceall('"xNumber"\\s*:', '"number" :');
		return value;
	}

	public String filterResponse(String value)
	{
		value = value.replaceall('"currency"\\s*:', '"xCurrency" :');
		value = value.replaceall('"object"\\s*:', '"xObject" :');
		value = value.replaceall('"count"\\s*:', '"xCount" :');
		value = value.replaceall('"data"\\s*:', '"xData" :');
		value = value.replaceall('"type"\\s*:', '"xType" :');
		value = value.replaceall('"number"\\s*:', '"xNumber" :');
		return value;
	}
	
	public static String filterResponsePrivlad(String value)
	{
		value = value.replaceall('"currency"\\s*:', '"xCurrency" :');
		value = value.replaceall('"object"\\s*:', '"xObject" :');
		value = value.replaceall('"count"\\s*:', '"xCount" :');
		value = value.replaceall('"data"\\s*:', '"xData" :');
		value = value.replaceall('"type"\\s*:', '"xType" :');
		value = value.replaceall('"number"\\s*:', '"xNumber" :');
		return value;
	}
}