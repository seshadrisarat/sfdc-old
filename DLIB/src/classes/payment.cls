public without sharing class payment {
    
    private static SL_StripeCallouts.stripemode getCurrentStripeMode() {
    	return isDebug() ? SL_StripeCallouts.stripemode.TEST : SL_StripeCallouts.stripemode.LIVE;
    }
    
    public static void createCharge( ChargeInfo oChargeInfo ) {
    	if ( oChargeInfo.getToken() == null ) {
    		AddPageMessage( ApexPages.Severity.ERROR, 'Invalid card token' );
    	}
    	SL_StripeMethods oStripeMethods = new SL_StripeMethods();
    	
    	SL_StripeWrappers.token oToken = ( SL_StripeWrappers.token )JSON.deserialize( oStripeMethods.filterResponse( oChargeInfo.getToken() ), SL_StripeWrappers.token.class );
    	
    	SL_StripeWrappers.cChargeTokenReq oRequest = new SL_StripeWrappers.cChargeTokenReq();
		oRequest.amount = Integer.valueOf( oChargeInfo.getTotalPrice() * 100 ); //should match whatever user saw
		oRequest.xCurrency = 'USD';
		oRequest.description = oChargeInfo.getDescription(); //account.Name and license ID

		system.debug( LoggingLevel.ERROR, '### oToken : ' + oToken );

		if ( oToken.card.customer != null ) {
			oRequest.customer = oToken.card.customer;
		} else {
			SL_StripeWrappers.tokenCreateUpdateCust oTokenRequest = new SL_StripeWrappers.tokenCreateUpdateCust();
			oTokenRequest.email = oToken.email;
			oTokenRequest.description = oToken.card.name;
			oTokenRequest.card = oToken.id;
			
			if ( !Test.isRunningTest() ) {
				Map<String, String> aCustomerResult = oStripeMethods.createCustomer( oTokenRequest, getCurrentStripeMode() );
				
				system.debug( LoggingLevel.ERROR, '### ' + aCustomerResult );
				
				if ( !String.isBlank( aCustomerResult.get( 'error' ) ) ) {
					AddPageMessage( ApexPages.Severity.ERROR, 'Could not create customer' );
				} else {
					try {
						oRequest.customer = String.valueOf( ( ( Map<String, Object> )JSON.deserializeUntyped( aCustomerResult.get( 'json' ) ) ).get( 'id' ) );
					} catch ( Exception e ) {
						AddPageMessage( ApexPages.Severity.ERROR, 'Customer Result parsing error: ' + e.getMessage() );
					}
				}
			}
		}
		
		if ( !Test.isRunningTest() ) {
			Map<String, String> aStripeCallouts = oStripeMethods.createCharge( oRequest, getCurrentStripeMode() );
			if( aStripeCallouts != null && aStripeCallouts.containsKey( 'json' ) ) {
				ProcessResponse( aStripeCallouts.get( 'json' ), oChargeInfo, new CustomerInfo( oRequest.customer, oToken.card.name, oToken.email ) );
			} else {
				AddPageMessage( ApexPages.Severity.ERROR, 'Error in Stripe response. Debug: ' + aStripeCallouts );
			}
		}
    }
    
    private static void ProcessResponse( String sJSON, ChargeInfo oChargeInfo, CustomerInfo oCustomerInfo ) {
    	if ( oCustomerInfo.getId() == null ) {
    		AddPageMessage( ApexPages.Severity.ERROR, 'Could not find customer info' );
    		return;
    	}
    	
    	system.debug( '### JSON:\n' + sJSON );
    	Map<String, Object> aResponse = ( Map<String, Object> )JSON.deserializeUntyped( sJSON );
    	
    	if ( aResponse.containsKey( 'error' ) ) {
			try {
				Map<String, Object> aResponseDetail = ( Map<String, Object> )aResponse.get( 'error' );
				AddPageMessage( ApexPages.Severity.ERROR, aResponseDetail.get( 'type' ) + ' : ' + aResponseDetail.get( 'message' ) );
			} catch( Exception e ) {
				AddPageMessage( ApexPages.Severity.ERROR, 'Parse Error: ' + e.getMessage() );
			}
		} else {
			if ( aResponse.containsKey( 'paid' ) && ( Boolean )aResponse.get( 'paid' ) ) {
				Payment__c oPayment = CreatePayment( oChargeInfo, aResponse, oCustomerInfo );
				insert oPayment;
				UpdateLicense( oPayment );
				//sendEmail( oPayment.Id );
				AddPageMessage( ApexPages.Severity.INFO, 'Payment was successfully accomplished!' );
			} else {
				AddPageMessage( ApexPages.Severity.ERROR, 'Payment has errors: ' + aResponse.get( 'failure_message' ) );
			}
		}
    }
    
    public static Payment__c CreatePayment( ChargeInfo oChargeInfo, Map<String, Object> aInfo, CustomerInfo oCustomerInfo ) {
    	if ( oChargeInfo.getLicenseId() != null && oChargeInfo.getTotalPrice() > 0 ) {
	    	Payment__c oPayment = new Payment__c();
	        oPayment.Name = 'Payment for Licenses';
	        oPayment.Status__c = 'approved';
	        oPayment.License__c = oChargeInfo.getLicenseId();
	        oPayment.Total__c = oChargeInfo.getTotalPrice();
	        oPayment.Renewal__c = oChargeInfo.getRenewal();
	        oPayment.new_licenses__c = oChargeInfo.getNewLicenses();
	        oPayment.Orgid__c = oChargeInfo.getOrganizationId();
	        
	    	oPayment.payer_id__c = oCustomerInfo.getId();
	        oPayment.payer_name__c = oCustomerInfo.getDescription();
	        oPayment.payer_email__c = oCustomerInfo.getEmail();
	        
	        Map<String, Object> aCardInfo = ( Map<String, Object> )aInfo.get( 'card' );
	        
	        oPayment.payer_street__c = String.valueOf( aCardInfo.get( 'address_line1' ) );
	        oPayment.payer_city__c = String.valueOf( aCardInfo.get( 'address_city' ) );
	        oPayment.payer_state__c = String.valueOf( aCardInfo.get( 'address_state' ) );
	        oPayment.payer_country_code__c = String.valueOf( aCardInfo.get( 'country' ) );
	        oPayment.payer_zip__c = String.valueOf( aCardInfo.get( 'address_zip' ) );
	        oPayment.payment_currency__c = String.valueOf( aInfo.get( 'currency' ) );
	        oPayment.product_quantity__c = String.valueOf( oChargeInfo.getNewLicenses() );
	        oPayment.product_id__c = oChargeInfo.getPackageVersionId();
	        oPayment.order_number__c = String.valueOf( aInfo.get( 'balance_transaction' ) );
	        
	    	return oPayment;
    	}
    	return null;
    }
    
    private static String CreateCustomer( CustomerInfo oCustomerInfo ) {
    	return null;
    }
    
	public static void UpdateLicense( Payment__c oPayment ) {
// fake_license_changes
		list<sfLma__License__c> lics = [select ID, sfLma__Seats__c, sfLma__Status__c, sfLma__License_Status__c, sfLma__Expiration__c from sfLma__License__c where ID = :oPayment.License__c limit 1];
//		list<License__c> lics = [ select ID, sfLma_Seats__c, sfLma_Status__c, sfLma_License_Status__c, sfLma_Expiration__c from License__c where ID = :payment.License__c limit 1 ];
		ID idRecordType_Active = null;
// fake_license_changes
		for ( RecordType oItem : [ SELECT Id FROM RecordType WHERE sObjectType = 'sfLma__License__c' AND DeveloperName = 'Active' limit 1 ] ) {
//		for ( RecordType oItem : [ SELECT Id FROM RecordType WHERE sObjectType = 'License__c' AND DeveloperName = 'Active' limit 1 ] ) {
			idRecordType_Active = oItem.Id;
		}
                        
		if( lics.IsEmpty() == false ) {
// fake_license_changes
			sfLma__License__c lic = lics.get(0);
//			License__c lic = lics.get( 0 );
// fake_license_changes
			if ( lic.sfLma__License_Status__c != 'Active' ) {
//			if ( lic.sfLma_License_Status__c != 'Active' ) {
				system.debug( 'license is not active' );
// fake_license_changes
				lic.sfLma__Seats__c = oPayment.New_Licenses__c;
				lic.sfLma__Expiration__c = Date.Today().addYears( 1 );
//				lic.sfLma_Seats__c = payment.New_Licenses__c;
//				lic.sfLma_Expiration__c = Date.Today().addYears( 1 );
            } else {
                system.debug( 'license is active' );
// fake_license_changes
				lic.sfLma__Seats__c += ( oPayment.New_Licenses__c != null ? oPayment.New_Licenses__c : 0 );
//				lic.sfLma_Seats__c += ( oPayment.New_Licenses__c != null ? oPayment.New_Licenses__c : 0 );
// fake_license_changes
				if (lic.sfLma__License_Status__c == 'Active' && oPayment.Renewal__c) {
					system.debug('license is active and renewal');
					lic.sfLma__Expiration__c = lic.sfLma__Expiration__c.addYears(1);
				}
//				if ( lic.sfLma_License_Status__c == 'Active' && payment.Renewal__c ) {
//					lic.sfLma_Expiration__c = lic.sfLma_Expiration__c.addYears( 1 );
//				}
            }
// fake_license_changes
			lic.sfLma__Status__c = 'Active';
//			lic.sfLma_Status__c = 'Active';
			//lic.RecordTypeId = idRecordType_Active;
            
            //license must update after payment so that the payment can be properly converted to an opportunity. 
            try {
            	update lic;
            } catch( Exception e ) {
            	SL_ExceptionHandler.BuildExceptionMessage( e, lics, new List<sfLma__License__c> { lic } );
            }
        } else {
        	AddPageMessage( ApexPages.Severity.ERROR, 'Could not find your license. Please contact support@silverlinecrm.com. Payment: ' + oPayment.Id );
        }
    }
    
    private static void AddPageMessage( ApexPages.Severity oSeverity, String sBody ) {
    	ApexPages.addMessage( new ApexPages.Message( oSeverity, sBody ) );
    } 
 
	private static Boolean isDebug() {
		return ApexPages.currentPage().getParameters().containsKey( 'debug' );
	}
 
 	public static String getStripePublishableKey() {
 		if ( isDebug() ) {
 			return SL_Settings.StripeTestPublishableKey;
 		}
 		return SL_Settings.StripeLivePublishableKey;
 	}
    
    private class CustomerInfo {
    	private String sId, sDescription, sEmail;
    	
    	public CustomerInfo( String sId, String sDescription, String sEmail ) {
    		this.sId = sId;
    		this.sDescription = sDescription;
    		this.sEmail = sEmail;
    	}
    	
    	public String getId() {
    		return this.sId;
    	}
    	
    	public String getDescription() {
    		return this.sDescription;
    	}
    	
    	public String getEmail() {
    		return this.sEmail;
    	}
    }
    
    public class ChargeInfo {
    	private String sToken, sOrganizationId, sDescription;
    	private ID idLicense, idPackageVersion;
    	private Decimal nTotalPrice;
    	private Boolean bIsRenewal;
    	private Integer nNewLicenses;
    	
    	public ChargeInfo( String sOrganizationId, sfLma__License__c oLicense, Decimal nTotalPrice, Boolean bIsRenewal, Integer nNewLicenses, String sDescription, String sToken ) {
    		this.sOrganizationId = sOrganizationId;
    		this.idLicense = oLicense.Id;
    		this.idPackageVersion = oLicense.sfLma__Package_Version__c;
    		this.nTotalPrice = nTotalPrice;
    		this.bIsRenewal = bIsRenewal;
    		this.nNewLicenses = nNewLicenses;
    		this.sDescription = sDescription;
    		this.sToken = sToken;
    	}
    	
    	public String getToken() {
    		return this.sToken;
    	}
    	
    	public String getOrganizationId() {
    		return this.sOrganizationId;
    	}
    	
    	public String getDescription() {
    		return this.sDescription;
    	}
    	
    	public ID getLicenseId() {
    		return this.idLicense;
    	}
    	
    	public ID getPackageVersionId() {
    		return this.idPackageVersion;
    	}
    	
    	public Decimal getTotalPrice() {
    		return this.nTotalPrice;
    	}
    	
    	public Boolean getRenewal() {
    		return this.bIsRenewal;
    	}
    	
    	public Integer getNewLicenses() {
    		return this.nNewLicenses;
    	}
    }
    
    /*@future
	private static void sendEmail( ID idPayment ) {
		if ( SL_Settings.StripeMailTemplateId == null ) {
			System.debug( LoggingLevel.ERROR, 'Could not find EmailTamplate' );
			return;
		}
		
		Payment__c oPayment = null;
		for ( Payment__c oItem : [ SELECT License__r.sfLma__Lead__c, License__r.sfLma__Contact__c FROM Payment__c WHERE Id = :idPayment limit 1 ] ) {
			oPayment = oItem;
		}
		if ( oPayment == null ) {
			System.debug( LoggingLevel.ERROR, 'Could not find Payment record' );
			return;
		}
		
		Messaging.SingleEmailMessage oMail = new Messaging.SingleEmailMessage();
		oMail.setSaveAsActivity( false );
		oMail.setTemplateId( SL_Settings.StripeMailTemplateId );
		oMail.setTargetObjectId( oPayment.License__r.sfLma__Contact__c != null ? oPayment.License__r.sfLma__Contact__c : oPayment.License__r.sfLma__Lead__c );
		oMail.setWhatId( idPayment );
		
		Messaging.sendEmail( new Messaging.Email[] { oMail } );
	}*/
    
    /******************** OLD CODE **********************/
    
    // This method fire from page (I sebt you description of method) - using for Update record
    public void voidAction()
    {   
        /*Map<String, String> parameters = ApexPages.currentPage().getParameters();
        
        //this.LogXML( parameters );
        Payment_Log__c oLog = this.LogURLParams( parameters );
        
        for(string key : parameters.keyset())
            system.debug('***Parameter: '+ key + ' : ' + parameters.get(key));
        //Save google checkout fields to payment
        if (parameters.get('_type') == 'new-order-notification') 
        {
            String paymentId = parameters.get('shopping-cart.merchant-private-data');
            Double total = Double.valueOf(parameters.get('shopping-cart.items.item-1.unit-price'));
            
            system.debug('***unit price***: '+total);
            system.debug('***payment ID***: '+paymentId);
            
            //Fetch payment object
            list<Payment__c> payments = [ Select Id,Status__c,Total__c, License__c, Renewal__c, new_licenses__c FROM Payment__c Where Id = :paymentId ];
            if( !payments.IsEmpty() )
            {
                Payment__c payment = payments.get( 0 );
                
                //If total in payment equals to total from IPN update payment status
                if ( payment.Total__c == total ) 
                {
                    payment.Status__c = 'approved'; 
                    payment.payer_id__c = parameters.get('buyer-id');
                    payment.payer_name__c = parameters.get('buyer-billing-address.contact-name');
                    payment.payer_email__c = parameters.get('buyer-billing-address.email');
                    payment.payer_street__c = parameters.get('buyer-billing-address.address1');
                    payment.payer_city__c = parameters.get('buyer-billing-address.city');
                    payment.payer_state__c = parameters.get('buyer-billing-address.region');
                    payment.payer_country_code__c = parameters.get('buyer-billing-address.country-code');
                    payment.payer_zip__c = parameters.get('buyer-billing-address.postal-code');
                    payment.payment_currency__c = parameters.get('shopping-cart.items.item-1.unit-price.currency');
                    payment.product_quantity__c = parameters.get('shopping-cart.items.item-1.quantity');
                    payment.product_id__c = parameters.get('shopping-cart.items.item-1.item-name');
                    payment.order_number__c = parameters.get('google-order-number');
                    update payment;
                    
// fake_license_changes
					if ( !system.URL.getSalesforceBaseUrl().toExternalForm().contains( 'cs' ) ) {
//					if ( system.URL.getSalesforceBaseUrl().toExternalForm().contains( 'cs' ) ) { // TO TEST ON SANDBOX
// fake_license_changes
						list<sfLma__License__c> lics = [select ID, sfLma__Seats__c, sfLma__Status__c, sfLma__License_Status__c, sfLma__Expiration__c from sfLma__License__c where ID = :payment.License__c limit 1];
//						list<License__c> lics = [ select ID, sfLma_Seats__c, sfLma_Status__c, sfLma_License_Status__c, sfLma_Expiration__c from License__c where ID = :payment.License__c limit 1 ];
						ID idRecordType_Active = null;
// fake_license_changes
						for ( RecordType oItem : [ SELECT Id FROM RecordType WHERE sObjectType = 'sfLma__License__c' AND DeveloperName = 'Active' limit 1 ] ) {
//						for ( RecordType oItem : [ SELECT Id FROM RecordType WHERE sObjectType = 'License__c' AND DeveloperName = 'Active' limit 1 ] ) {
							idRecordType_Active = oItem.Id;
						}
                        
						if( lics.IsEmpty() == false ) {
// fake_license_changes
							sfLma__License__c lic = lics.get(0);
//							License__c lic = lics.get( 0 );
// fake_license_changes
							if ( lic.sfLma__License_Status__c != 'Active' ) {
//							if ( lic.sfLma_License_Status__c != 'Active' ) {
								system.debug( 'license is not active' );
// fake_license_changes
								lic.sfLma__Seats__c = payment.New_Licenses__c;
								lic.sfLma__Expiration__c = Date.Today().addYears( 1 );
//								lic.sfLma_Seats__c = payment.New_Licenses__c;
//								lic.sfLma_Expiration__c = Date.Today().addYears( 1 );
                            } else {
                                system.debug( 'license is active' );
// fake_license_changes
								lic.sfLma__Seats__c += ( payment.New_Licenses__c != null ? payment.New_Licenses__c : 0 );
//								lic.sfLma_Seats__c += ( payment.New_Licenses__c != null ? payment.New_Licenses__c : 0 );
// fake_license_changes
								if (lic.sfLma__License_Status__c == 'Active' && payment.Renewal__c) {
									system.debug('license is active and renewal');
									lic.sfLma__Expiration__c = lic.sfLma__Expiration__c.addYears(1);
								}
//								if ( lic.sfLma_License_Status__c == 'Active' && payment.Renewal__c ) {
//									lic.sfLma_Expiration__c = lic.sfLma_Expiration__c.addYears( 1 );
//								}
                            }
// fake_license_changes
							lic.sfLma__Status__c = 'Active';
//							lic.sfLma_Status__c = 'Active';
							//lic.RecordTypeId = idRecordType_Active;
                            
                            //license must update after payment so that the payment can be properly converted to an opportunity. 
                            try {
                            	update lic;
                            } catch( Exception e ) {
                            	oLog.Error_Message__c = e.getMessage();
                            	oLog.Status__c = 'Failure';
                            	SL_ExceptionHandler.BuildExceptionMessage( e, lics, new List<sfLma__License__c> { lic } );
                            }
                        } else {
                        	oLog.Error_Message__c = 'Could not find your license. Please contact support@silverlinecrm.com. ' + 'Payment ID: ' + payment.ID;
                        	oLog.Status__c = 'Failure';
							ApexPages.addMessage(
								new ApexPages.Message(
									ApexPages.Severity.ERROR, 'Could not find your license. Please contact support@silverlinecrm.com. ' + 'Payment ID: ' + payment.ID
								)
							);
                        }
                    }
                } else {
                	oLog.Error_Message__c = 'Wrong payment total ' + total + ' should be ' + payment.Total__c;
                	oLog.Status__c = 'Failure';
					ApexPages.addMessage(
						new ApexPages.Message(
							ApexPages.Severity.ERROR, 'Wrong payment total ' + total + ' should be ' + payment.Total__c
						)
					);
                }
            }
        }
        
        insert oLog;*/
    }
    
    /*private Payment_Log__c LogURLParams( Map<String, String> aParams ) {
    	Payment_Log__c oLog = new Payment_Log__c();
    	
    	if ( aParams == null || aParams.isEmpty() ) {
    		oLog.Error_Message__c = 'Params is empty';
    		oLog.Status__c = 'Failure';
    		return oLog;
    	}
    	
    	String aPairs = '';
    	for ( String sKey : aParams.keySet() ) {
    		aPairs += sKey + '=' + ( aParams.get( sKey ) != null ? aParams.get( sKey ) : '' ) + '&';
    	}
    	if ( aPairs.length() > 0 ) {
    		aPairs = aPairs.substring( 0, aPairs.length() - 1 );
    	}
    	
    	oLog.Data__c = aPairs;
    	
    	if ( aParams.containsKey( 'error.error-message' ) ) {
        	if ( aParams.get( 'error.error-message' ) != null  ) {
        		oLog.Error_Message__c = aParams.get( 'error.error-message' ).length() <= Payment_Log__c.Error_Message__c.getDescribe().getLength() ?
        			aParams.get( 'error.error-message' ) :
        			aParams.get( 'error.error-message' ).substring( Payment_Log__c.Error_Message__c.getDescribe().getLength() );
        	}
        	oLog.Status__c = 'Failure';
        } else {
        	oLog.Status__c = 'Success';
        }
    	
    	return oLog;
    }*/
}