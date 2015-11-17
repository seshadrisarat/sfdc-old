public class SL_StripeMethods extends SL_StripeCallouts
{
	public map<String, String> createCharge(SL_StripeWrappers.cChargeTokenReq request, stripemode mode)
	{
		request.xCurrency = 'USD';
		map<String, String> response = dispatcher('charges', 'POST', mode, (object) request);
		return response;
	}
	
	/**
	public map<String, String> createCharge(SL_StripeWrappers.cChargeDictionaryReq request, stripemode mode)
	{
		request.xCurrency = 'USD';
		map<String, String> response = dispatcher('charges', 'POST', mode, (object) request);
		return response;
	}
	**/
    
    public map<String, String> retrieveCharge(String requestId, stripemode mode)
    {
    	String relativeURL = 'charges/' + requestId;
    	map<String, String> response = dispatcher(relativeURL, 'GET', mode);
    	return response;
    }
    
    public map<String, String> refundCharge(String requestId, stripemode mode)
	{
		String relativeURL = 'charges/' + requestId + '/refund';
		map<String, String> response = dispatcher(relativeURL, 'POST', mode);
		return response;
	}
	
	/**
	public map<String, String> captureCharge(String requestId, stripemode mode)
	{
		String relativeURL = 'charges/' + requestId + '/capture';
		map<String, String> response = dispatcher(relativeURL, 'POST', mode);
		return response;
	}
	**/
    
    public map<String, String> createCustomer(SL_StripeWrappers.tokenCreateUpdateCust request, stripemode mode)
	{
		map<String, String> response = dispatcher('customers', 'POST', mode, (object) request);
		return response;
	}
	
	/**
	public map<String, String> createCustomer(SL_StripeWrappers.dictionaryCreateUpdateCust request, stripemode mode)
	{
		map<String, String> response = dispatcher('customers', 'POST', mode, (object) request);
		return response;
	}
	**/
	
	public map<String, String> retrieveCustomer(String requestId, stripemode mode)
	{
		String relativeURL = 'customers/' + requestId;
		map<String, String> response = dispatcher(relativeURL, 'GET', mode);
		return response;
	}
	
	/**
	public map<String, String> updateCustomer(String requestId, SL_StripeWrappers.tokenCreateUpdateCust request, stripemode mode)
	{
		String relativeURL = 'customers/' + requestId;
		map<String, String> response = dispatcher(relativeURL, 'POST', mode, (object) request);
		return response;
	}
	
	public map<String, String> updateCustomer(String requestId, SL_StripeWrappers.dictionaryCreateUpdateCust request, stripemode mode)
	{
		String relativeURL = 'customers/' + requestId;
		map<String, String> response = dispatcher(relativeURL, 'POST', mode, (object) request);
		return response;
	}
	
	public map<String, String> deleteCustomer(String requestId, stripemode mode)
	{
		String relativeURL = 'customers/' + requestId;
		map<String, String> response = dispatcher(relativeURL, 'POST', mode);
		return response;
	}
	**/
	
	public map<String, String> createCard(String requestId, SL_StripeWrappers.cCardDictionaryReq request, stripemode mode)
	{
		String relativeURL = 'customers/' + requestId + '/cards';
		map<String, String> response = dispatcher(relativeURL, 'POST', mode, (object) request);
		return response;
	}
	
	public map<String, String> retrieveCard(String customerId, String cardId, stripemode mode)
	{
		String relativeURL = 'customers/' + customerId + '/cards/' + cardId;
		map<String, String> response = dispatcher(relativeURL, 'GET', mode);
		return response;
	}
}