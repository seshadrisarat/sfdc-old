/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class SL_Test_Stripe {
	
	private static SL_StripeMethods methods;
	private static StaticResourceCalloutMock mock;
	private static SL_StripeCallouts.stripemode mode;
	private static map<String, String> response;
	private static String jsonStr;
	
	private static void initialize()
	{
		mock = new StaticResourceCalloutMock();
		methods = new SL_StripeMethods();
	}
	
	private static void setMock(String resource)
	{
		if(Test.isRunningTest())
		{
			mock.setStaticResource(resource);
			mock.setStatusCode(200);
			mock.setHeader('Content-Type', 'application/json');
			Test.setMock(HttpCalloutMock.class, mock);
		}
	}
	
	private static String createCharge()
	{
		if(Test.isRunningTest())
		{
			setMock('createRetrieveCharge');
		}
		SL_StripeWrappers.cChargeTokenReq request = new SL_StripeWrappers.cChargeTokenReq();
		request.amount = 1000000;
		request.xCurrency='USD';
		request.customer = 'cus_2iWunHDfGG1x0m';
		request.card = 'card_102iWu2mAiB3IuYiv8YIc1Y9';
		mode = SL_StripeCallouts.stripemode.TEST;
		
		response = methods.createCharge(request, mode);
		setJsonString();
		
		SL_StripeWrappers.charge ch = (SL_StripeWrappers.charge)JSON.deserialize(jsonStr, SL_StripeWrappers.charge.class);
		System.debug(Logginglevel.INFO, 'CREATE CHARGE RESPONSE: ' + ch);
		return ch.id;
	}
	
	static testmethod void retrieveCharge()
	{
		initialize();
		String requestId = createCharge();
		mode = SL_StripeCallouts.stripemode.TEST;
		
		setMock('createRetrieveCharge');
		response = methods.retrieveCharge(requestId, mode);
		setJsonString();
		
		SL_StripeWrappers.charge ch = (SL_StripeWrappers.charge)JSON.deserialize(jsonStr, SL_StripeWrappers.charge.class);
		System.debug(Logginglevel.INFO, 'RETRIEVE CHARGE RESPONSE: ' + ch);
	}
	
	static testmethod void refundCharge()
	{
		initialize();
		String requestId = createCharge();
		mode = SL_StripeCallouts.stripemode.TEST;
		
		setMock('refundCharge');
		response = methods.refundCharge(requestId, mode);
		setJsonString();
		
		SL_StripeWrappers.charge ch = (SL_StripeWrappers.charge)JSON.deserialize(jsonStr, SL_StripeWrappers.charge.class);
		System.debug(Logginglevel.INFO, 'REFUND CHARGE RESPONSE: ' + ch);
	}
	
	private static String createCustomer()
	{
		if(Test.isRunningTest())
		{
			setMock('createRetrieveCustomer');
		}
		SL_StripeWrappers.tokenCreateUpdateCust request = new SL_StripeWrappers.tokenCreateUpdateCust();
		request.description =  'Test customer';
		mode = SL_StripeCallouts.stripemode.TEST;
		
		response = methods.createCustomer(request, mode);
		setJsonString();
		
		SL_StripeWrappers.customer cu = (SL_StripeWrappers.customer)JSON.deserialize(jsonStr, SL_StripeWrappers.customer.class);
		System.debug(Logginglevel.INFO, 'CREATE CUSTOMER RESPONSE: ' + cu);
		return cu.Id;
	}
	
	static testmethod void retrieveCustomer()
	{
		initialize();
		String requestId = createCustomer();
		mode = SL_StripeCallouts.stripemode.TEST;
		
		setMock('createRetrieveCustomer');
		response = methods.retrieveCustomer(requestId, mode);
		setJsonString();
		
		SL_StripeWrappers.customer cu = (SL_StripeWrappers.customer)JSON.deserialize(jsonStr, SL_StripeWrappers.customer.class);
		System.debug(Logginglevel.INFO, 'RETRIEVE CUSTOMER RESPONSE: ' + cu);
	}
	
	/**
	static testmethod void createCard()
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
	**/
	
	private static String createCard(String customerId)
	{
		if(Test.isRunningTest())
		{
			setMock('createRetrieveCard');
		}
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
		
		SL_StripeWrappers.card ca = (SL_StripeWrappers.card)JSON.deserialize(jsonStr, SL_StripeWrappers.card.class);
		System.debug(Logginglevel.INFO, 'CREATE CARD RESPONSE: ' + ca);
		return ca.Id;
	}
	
	static testmethod void retrieveCard()
	{
		initialize();
		String customerId = createCustomer();
		String cardId = createCard(customerId);
		mode = SL_StripeCallouts.stripemode.TEST;
		
		setMock('createRetrieveCard');
		response = methods.retrieveCard(customerId, cardId, mode);
		setJsonString();
		
		SL_StripeWrappers.card ca = (SL_StripeWrappers.card)JSON.deserialize(jsonStr, SL_StripeWrappers.card.class);
		System.debug(Logginglevel.INFO, 'RETRIEVE CARD RESPONSE: ' + ca);
	}
	
	private static void setJsonString()
	{
		jsonStr = response.get('json');
		//System.debug(Logginglevel.INFO, 'pre-filtered json String: ' + jsonStr);
		jsonStr = methods.filterResponse(jsonStr);
		//System.debug(Logginglevel.INFO, 'filtered json String: ' + jsonStr);
	}
	
	static testmethod void instantiateJsonObjects()
	{
		SL_StripeWrappers.error err = new SL_StripeWrappers.error();
		SL_StripeWrappers.customer cus = new SL_StripeWrappers.customer();
		SL_StripeWrappers.Cards cds = new SL_StripeWrappers.Cards();
		SL_StripeWrappers.charge chg = new SL_StripeWrappers.charge();
		SL_StripeWrappers.Refunds rfs = new SL_StripeWrappers.Refunds();
		SL_StripeWrappers.card crd = new SL_StripeWrappers.card();
		SL_StripeWrappers.cChargeTokenReq cChTR = new SL_StripeWrappers.cChargeTokenReq();
		SL_StripeWrappers.cChargeDictionaryReq cChDR = new SL_StripeWrappers.cChargeDictionaryReq();
		SL_StripeWrappers.retrieveChargeReq rtCh = new SL_StripeWrappers.retrieveChargeReq();
		SL_StripeWrappers.refundCharge rfCh = new SL_StripeWrappers.refundCharge();
		SL_StripeWrappers.captureCharge capCh = new SL_StripeWrappers.captureCharge();
		SL_StripeWrappers.cCardTokenReq cCaTR = new SL_StripeWrappers.cCardTokenReq();
		SL_StripeWrappers.cCardDictionaryReq cCaDR = new SL_StripeWrappers.cCardDictionaryReq();
		SL_StripeWrappers.tokenCreateUpdateCust tCrUpCus = new SL_StripeWrappers.tokenCreateUpdateCust();
		SL_StripeWrappers.dictionaryCreateUpdateCust dCrUpCus = new SL_StripeWrappers.dictionaryCreateUpdateCust();
		SL_StripeWrappers.retrieveCustomer retCus = new SL_StripeWrappers.retrieveCustomer();
		SL_StripeWrappers.deleteCustomer delCus = new SL_StripeWrappers.deleteCustomer();
	}
}