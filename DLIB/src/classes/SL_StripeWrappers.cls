/**
**/
public abstract class SL_StripeWrappers 
{
	public String id;
	public String xObject;
	public String xType;
	public Boolean livemode;
	public String created;
	public String description;
	//public Metadata metadata;
	public Error error;
	
	public abstract class moneyExchange extends SL_StripeWrappers
	{
		public String xCurrency;
		public String balance_transaction;
		public Integer amount;
		public Integer application_fee;
	}
	
	//public class Metadata {}
	
	public class error{
		public String xType;
		public String message;
		public String code;
    	public String charge;
	}
	
	public virtual class customer extends SL_StripeWrappers
	{
		public String email;
		public Boolean delinquent;
		//public Object subscription;
		//public Object discount;
		public Integer account_balance;
		public Cards cards;
		public String default_card;
	}

	public class Cards {
		public String xObject;
		public Integer xCount;
		public String url;
		public List<card> xData;
	}
	
	public class charge extends moneyExchange
	{
		public Boolean paid;
		public Boolean refunded;
		public Card card;
		public Boolean captured;
		public list<Refunds> refunds;
		public String failure_message;
		public String failure_code;
		public Integer amount_refunded;
		public String customer;
		public String invoice;
		//public Object dispute;
	}
	
	public class Refunds extends moneyExchange
	{
	}
	
	public class card extends SL_StripeWrappers
	{
		public String xNumber;
		public String cvc;
		public String last4;
		public String dynamic_last4;
		public String brand;
		public String funding;
		public String exp_month;
		public String exp_year;
		public String fingerprint;
		public String customer;
		public String country;
		public String name;
		public String address_line1;
		public String address_line2;
		public String address_city;
		public String address_state;
		public String address_zip;
		public String address_country;
		public String cvc_check;
		public String address_line1_check;
		public String address_zip_check;
	}
	
	public abstract class createChargeReq extends moneyExchange
	{
		public Boolean capture;
	}
	
	public class cChargeTokenReq extends createChargeReq
	{
		public String card;
		public String customer;
	}
	
	public class cChargeDictionaryReq extends createChargeReq
	{
		public Card card;
	}
	
	public class retrieveChargeReq extends SL_StripeWrappers{}
	
	public class refundCharge extends moneyExchange
	{
		//Charge id goes in url
		public Boolean refund_application_fee;
	}
	
	public class captureCharge extends moneyExchange{}
	
	public class cCardTokenReq
	{
		public String card;
	}
	
	public class cCardDictionaryReq
	{
		public Card card;
	}
	
	/**
	Parameters set entirely in the url
	public class retrieveCard{}
	**/
	
	public class tokenCreateUpdateCust extends customer
	{
		public String card;
	}
	
	public class dictionaryCreateUpdateCust extends customer
	{
		public Card card;
	}
	
	public class retrieveCustomer extends SL_StripeWrappers{}
	
	public class deleteCustomer extends SL_StripeWrappers{}
	
	
	public class token {
		public String id, email, xType, xObject;
		public Boolean livemode, used, verification_allowed;
		public Long created;
		public Card card;

	}
	
	/*
	
	{
  "id": "tok_1038FO252zefHLcQMFx87f5U",
  "livemode": false,
  "created": 1387190800,
  "used": false,
  "object": "token",
  "type": "card",
  "card": {
    "id": "card_1038FO252zefHLcQLssnadNz",
    "object": "card",
    "last4": "4242",
    "type": "Visa",
    "exp_month": 11,
    "exp_year": 2014,
    "fingerprint": "qej8u5csKEr2MX9Z",
    "customer": null,
    "country": "US",
    "name": "Name",
    "address_line1": "Street",
    "address_line2": null,
    "address_city": "New York",
    "address_state": null,
    "address_zip": "1701",
    "address_country": "United States"
  },
  "email": "dobrelya@silverlinecrm.com"
}
	
	*/
	
	
}