public class SL_Call_StripeMethods 
{
	private static SL_StripeMethods methods = new SL_StripeMethods();
	private static SL_StripeCallouts.stripemode mode;
	private static map<String, String> response;
	private static String jsonStr;
	
	public static String createCharge()
	{
		SL_StripeWrappers.cChargeTokenReq request = new SL_StripeWrappers.cChargeTokenReq();
		request.amount = 1000000;
		request.xCurrency='USD';
		request.customer = 'cus_2iWunHDfGG1x0m';
		request.card = 'card_102iWu2mAiB3IuYiv8YIc1Y9';
		mode = SL_StripeCallouts.stripemode.TEST;
		
		response = methods.createCharge(request, mode);
		setJsonString();
		
		SL_StripeWrappers.charge c = (SL_StripeWrappers.charge)JSON.deserialize(jsonStr, SL_StripeWrappers.charge.class);
		System.debug(Logginglevel.INFO, 'CREATE CHARGE RESPONSE: ' + response.get('json'));
		return c.id;
	}
	
	public static void retrieveCharge()
	{
		String requestId = createCharge();
		mode = SL_StripeCallouts.stripemode.TEST;
		
		response = methods.retrieveCharge(requestId, mode);
		setJsonString();
		
		SL_StripeWrappers.charge c = (SL_StripeWrappers.charge)JSON.deserialize(jsonStr, SL_StripeWrappers.charge.class);
		System.debug(Logginglevel.INFO, 'RETRIEVE CHARGE RESPONSE: ' + response.get('json'));
	}
	
	public static void refundCharge()
	{
		String requestId = createCharge();
		mode = SL_StripeCallouts.stripemode.TEST;
		
		response = methods.refundCharge(requestId, mode);
		setJsonString();
		
		SL_StripeWrappers.charge c = (SL_StripeWrappers.charge)JSON.deserialize(jsonStr, SL_StripeWrappers.charge.class);
		System.debug(Logginglevel.INFO, 'REFUND CHARGE RESPONSE: ' + response.get('json'));
	}
	
	public static String createCustomer()
	{
		SL_StripeWrappers.tokenCreateUpdateCust request = new SL_StripeWrappers.tokenCreateUpdateCust();
		request.description =  'Test customer';
		mode = SL_StripeCallouts.stripemode.TEST;
		
		response = methods.createCustomer(request, mode);
		setJsonString();
		
		SL_StripeWrappers.customer c = (SL_StripeWrappers.customer)JSON.deserialize(jsonStr, SL_StripeWrappers.customer.class);
		System.debug(Logginglevel.INFO, 'CREATE CUSTOMER RESPONSE: ' + response.get('json'));
		return c.Id;
	}
	
	public static void retrieveCustomer()
	{
		String requestId = createCustomer();
		mode = SL_StripeCallouts.stripemode.TEST;
		
		response = methods.retrieveCustomer(requestId, mode);
		setJsonString();
		
		SL_StripeWrappers.customer c = (SL_StripeWrappers.customer)JSON.deserialize(jsonStr, SL_StripeWrappers.customer.class);
		System.debug(Logginglevel.INFO, 'RETRIEVE CUSTOMER RESPONSE: ' + response.get('json'));
	}
	
	public static void createCard()
	{
		String requestId = createCustomer();
		SL_StripeWrappers.cCardDictionaryReq request = new SL_StripeWrappers.cCardDictionaryReq();
		SL_StripeWrappers.card reqCard = new SL_StripeWrappers.card();
			reqCard.xNumber 		= '378282246310005';
			reqCard.exp_month 		= '7';
			reqCard.exp_year		= '2017';
			reqCard.cvc				= '777';
			reqCard.name			= 'Johnathan Strange';
			reqCard.address_line1	= '47 Witchwood Court';
			reqCard.address_city	= 'Duma Key';
			reqCard.address_state	= 'FL';
			reqCard.address_zip		= '99039';
			reqCard.address_country	= 'USA';
		request.card = reqCard;
		mode = SL_StripeCallouts.stripemode.TEST;
		
		response = methods.createCard(requestId, request, mode);
		setJsonString();
		
		SL_StripeWrappers.card c = (SL_StripeWrappers.card)JSON.deserialize(jsonStr, SL_StripeWrappers.card.class);
		System.debug(Logginglevel.INFO, 'CREATE CARD RESPONSE: ' + response.get('json'));
	}
	
	private static String createCard(String customerId)
	{
		SL_StripeWrappers.cCardDictionaryReq request = new SL_StripeWrappers.cCardDictionaryReq();
		SL_StripeWrappers.card reqCard = new SL_StripeWrappers.card();
			reqCard.xNumber 		= '378282246310005';
			reqCard.exp_month 		= '7';
			reqCard.exp_year		= '2017';
			reqCard.cvc				= '777';
			reqCard.name			= 'Johnathan Strange';
			reqCard.address_line1	= '47 Witchwood Court';
			reqCard.address_city	= 'Duma Key';
			reqCard.address_state	= 'FL';
			reqCard.address_zip		= '99039';
			reqCard.address_country	= 'USA';
		request.card = reqCard;
		mode = SL_StripeCallouts.stripemode.TEST;
		
		response = methods.createCard(customerId, request, mode);
		setJsonString();
		
		SL_StripeWrappers.card c = (SL_StripeWrappers.card)JSON.deserialize(jsonStr, SL_StripeWrappers.card.class);
		System.debug(Logginglevel.INFO, 'CREATE CARD RESPONSE: ' + response.get('json'));
		return c.Id;
	}
	
	public static void retrieveCard()
	{
		String customerId = createCustomer();
		String cardId = createCard(customerId);
		mode = SL_StripeCallouts.stripemode.TEST;
		
		response = methods.retrieveCard(customerId, cardId, mode);
		setJsonString();
		
		SL_StripeWrappers.card c = (SL_StripeWrappers.card)JSON.deserialize(jsonStr, SL_StripeWrappers.card.class);
		System.debug(Logginglevel.INFO, 'RETRIEVE CARD RESPONSE: ' + response.get('json'));
	}
	
	private static void setJsonString()
	{
		jsonStr = response.get('json');
		//System.debug(Logginglevel.INFO, 'pre-filtered json String: ' + jsonStr);
		jsonStr = methods.filterResponse(jsonStr);
		//System.debug(Logginglevel.INFO, 'filtered json String: ' + jsonStr);
	}
}