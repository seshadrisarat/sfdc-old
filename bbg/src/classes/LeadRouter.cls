/**
* Owner implementation of dealer routing
*
* @author Mike Regan
*/
public with sharing class LeadRouter extends DealerRouter {
	private static map<string, Lead_Routing_Do_Not_Send__c> leadRoutingDNS = Lead_Routing_Do_Not_Send__c.getAll();
	
	public static Lead_Routing_Rule__c[] getAllRoutingRules(){
        return [SELECT Name, Country_Code__c, Brand_Code__c, Routing_Attempt_1_Type__c, Number_of_Leads_1__c, Routing_Attempt_2_Type__c, Number_of_Leads_2__c, Routing_Attempt_3_Type__c, Number_of_Leads_3__c, Routing_Attempt_4_Type__c, Number_of_Leads_4__c
                                                      FROM Lead_Routing_Rule__c];
    } 
    
    protected override string getRoutingType() {
    	return 'Lead';
    }
    
    protected override boolean isSendable(sobject obj) {
    	boolean sendable = super.isSendable(obj);
    	if (sendable) {
	    	Lead lead = (Lead)obj;
	    	for(Lead_Routing_Do_Not_Send__c d : leadRoutingDNS.values()) {
	        	if(lead.Brand_Code__c == d.get('Brand_Code__c') && lead.Lead_Form_Name__c == d.get('Lead_Form_Name__c')){
	            	return false;
	            }
	    	}
	    	return true;
    	}
    	return sendable;
    }
    
    protected override DealerRoutingAssignedDealer createDealerRoutingAssignedDealer(DealerRoutingModel model, Dealer_Brand__c dealerBrand) {
    	DealerRoutingAssignedDealer ad = super.createDealerRoutingAssignedDealer(model, dealerBrand);
    	
    	return ad;	
    }
    
    private Lead_Routing_Rule__c getLeadRoutingRule(DealerRoutingModel model) {
     	Lead_Routing_Rule__c[] rules = getAllRoutingRules();
        
        // Try to find a rule match on country and brand
        for(Lead_Routing_Rule__c rule : rules) {
        	if(rule.Country_Code__c == model.CountryISO && rule.Brand_Code__c == model.Brand) {
            	return rule;
            }
        }
        
        // No match, so just try brand
        for(Lead_Routing_Rule__c rule : rules) {
        	if(rule.Country_Code__c == null && rule.Brand_Code__c == model.Brand) {
            	return rule;
            }
        } 
        
        // No match
        return null;
	}
	
	protected override void sendToFootStepsInternal(Set<Id> idsToSendToFootsteps) {
		String scheduleTime = Datetime.now().addSeconds( 60 ).format( 'ss mm HH dd MM ? yyyy' );
		String scheduleId = String.valueOf(Datetime.now().getTime());
		String jobId = System.schedule( 'footstepsIntegration'+scheduleId, scheduleTime, new FootstepsSendLeadsJob(idsToSendToFootsteps) );
    }
    
    protected override void sendToFootstepsInternal(map<Id, set<Id>> objectIdToDealerIdMap) {
    	String scheduleTime = Datetime.now().addSeconds( 60 ).format( 'ss mm HH dd MM ? yyyy' );
		String scheduleId = String.valueOf(Datetime.now().getTime());
		String jobId = System.schedule( 'footstepsIntegration'+scheduleId, scheduleTime, new FootstepsSendLeadsJob(objectIdToDealerIdMap) );
	}
	
	protected override list<Assigned_Dealer__c> getExistingAssignedDealers(sobject obj) {
		Lead lead = (Lead)obj;
		
		list<Assigned_Dealer__c> existingAssignedDealers = new list<Assigned_Dealer__c>();
		
		list<Assigned_Dealer__c> assignedDealers = null;
		
		try {
			assignedDealers = lead.Assigned_Dealers__r;
		}
		catch(Exception exp) {
		}
		if (assignedDealers != null) {
			for (Assigned_Dealer__c ad : assignedDealers) {
				existingAssignedDealers.add(ad);
			}
		}
		
		return existingAssignedDealers;
	}
	
	
	protected override string getRuleName(sobject rule, integer ruleNumber) {
		string ruleName = (string)rule.get('Routing_Attempt_' + ruleNumber + '_Type__c');	
		return ruleName; 
	}
	 
	protected override integer getRuleNumberOfDealers(sobject rule, integer ruleNumber) {
		integer maxNumberOfDealers = integer.valueOf(rule.get('Number_of_Leads_' + ruleNumber + '__c'));
		return maxNumberOfDealers;
	} 
	
	protected override DealerRoutingModel convertToModel(sobject obj) {
		Lead lead = (Lead)obj;
		DealerRoutingModel model = new DealerRoutingModel();
		model.lead(lead);
		return model;	
	}
	
	
	protected override sobject getDealerRoutingRule(DealerRoutingModel model) {
		system.debug('getDealerRoutingRule - ' + model.Id);
		Lead_Routing_Rule__c rule = getLeadRoutingRule(model);
		return rule;
	}
	
	protected override string getObjectBrand(sobject obj) {
		Lead lead = (Lead)obj;
		return lead.Brand_Code__c;
    }
    
    protected override boolean isMarineMaxDealerEmailSent(sobject obj) {
    	Lead lead = (Lead)obj;
    	if (lead.Lead_Emails_Sent__c == null || !lead.Lead_Emails_Sent__c) {
    		return false;
    	}
    	return true;
    }
    
    protected override string getMarineMaxDealerFilename(sobject obj) {
    	return 'Bayliner Lead';
    }
    
    protected override string getMarineMaxDealerPlainTextBody(sobject obj) {
    	return 'bayliner dealer xml';
    }
	
	protected override Assigned_Dealer__c createAssignedDealer(sobject obj, DealerRoutingModel model, DealerRoutingAssignedDealer dealer, list<Assigned_Dealer__c> oldAssignedDealers) {
		Assigned_Dealer__c assignedDealer = super.createAssignedDealer(obj, model, dealer, oldAssignedDealers);
		assignedDealer.Lead__c = obj.Id;
		return assignedDealer;
	}
	
	
	protected override boolean hasCustomRoutingExceptions(DealerRoutingModel model) {
		boolean hasCustomRoutingExceptions = false;
        if (model.Brand == 'SR' && model.CountryISO == 'US') {
        	hasCustomRoutingExceptions = true;
        }
       	return hasCustomRoutingExceptions;
	}
	
	protected override list<DealerRoutingAssignedDealer> getRouteToByRoutingException(DealerRoutingModel model) {
		integer numToAssign;
        if (model.ProductCategory != null) {
        	if (model.Brand == 'SR' && model.ProductCategory.contains('Yacht')) {
            	numToAssign = 1;
            }
            if(model.Brand == 'SR' && model.ProductCategory.contains('Cruiser')) {
            	numToAssign = 3;
           	}
        }
        return getRouteToDealersByLatLon(model, numToAssign);
	}
	
	protected override string getXml(Account marineMaxDealer, sobject obj) {
		Lead ld = (Lead)obj;
       
        XmlStreamWriter w = new XmlStreamWriter();  
        w.writeStartDocument(null, '1.0');
        w.writeStartElement('', 'Lead',''); 
        //w.writeNamespace('xsi','http://www.w3.org/2001/XMLSchema-instance');  
        //w.writeNamespace('xsd','http://www.w3.org/2001/XMLSchema');
        w.writeStartElement(null, 'customername', null);        
        w.writeCharacters(getValue(ld.name));
        w.writeEndElement(); 
        w.writeStartElement(null, 'customeraddress', null);
        w.writeCharacters(getValue(ld.street));
        w.writeEndElement(); 
        w.writeStartElement(null, 'customercity', null); 
        w.writeCharacters(getValue(ld.city));
        w.writeEndElement(); 
        w.writeStartElement(null, 'customerState', null);
        w.writeCharacters(getValue(ld.state));
        w.writeEndElement(); 
        w.writeStartElement(null, 'customerzip', null);
        w.writeCharacters(getValue(ld.PostalCode));
        w.writeEndElement(); 
        w.writeStartElement(null, 'customercountry', null);
        w.writeCharacters(getValue(ld.Country));
        w.writeEndElement(); 
        w.writeStartElement(null, 'customerhomephone', null);       
        w.writeCharacters(getValue(ld.Phone));
        w.writeEndElement(); 
        w.writeStartElement(null, 'customeremail1', null);
        w.writeCharacters(getValue(ld.Email));
        w.writeEndElement(); 
        w.writeStartElement(null, 'customeremail2', null);
        w.writeCharacters(getValue(ld.Alternate_Email_Address__c));
        w.writeEndElement(); 
        w.writeStartElement(null, 'dealerid', null);
        w.writeCharacters(getValue(marineMaxDealer.Id));
        w.writeEndElement(); 
        w.writeStartElement(null, 'leadformname', null);
        w.writeCharacters(getValue(ld.Lead_Form_Name__c));
        w.writeEndElement();
        w.writeStartElement(null, 'typeofinquiry', null);
        w.writeCharacters(getValue(ld.Type_of_inquiry__c));
        w.writeEndElement(); 
        /*w.writeStartElement(null, 'priority', null);
w.writeCharacters('');
w.writeEndElement();*/ 
        w.writeStartElement(null, 'createddate', null);
        w.writeCharacters(getValue(String.valueOf(ld.CreatedDate)));
        w.writeEndElement(); 
        w.writeStartElement(null, 'previousboatowner', null);
        w.writeCharacters(getValue(String.valueOf(ld.Previous_Boat_Owner__c)));
        w.writeEndElement();
        w.writeStartElement(null, 'currentownedbrand', null);
        w.writeCharacters(getValue(ld.Current_Owned_Brand__c));
        w.writeEndElement();
        w.writeStartElement(null, 'currentownedmodel', null);
        w.writeCharacters(getValue(ld.Current_Owned_Model__c));
        w.writeEndElement();
        w.writeStartElement(null, 'currentownedboatclass', null);
        w.writeCharacters(getValue(ld.Current_Owned_Boat_Class__c));
        w.writeEndElement();
        w.writeStartElement(null, 'currentownedyear', null);
        w.writeCharacters(getValue(ld.Currently_Owned_Year__c));
        w.writeEndElement();
        w.writeStartElement(null, 'currentownedidnumber', null);
        w.writeCharacters(getValue(ld.Current_Owned_ID_Number__c));
        w.writeEndElement();
        w.writeStartElement(null, 'boatmodelinterest', null);
        w.writeCharacters(getValue(ld.Boat_Model_Interest__c));
        w.writeEndElement();
        w.writeStartElement(null, 'boatclassinterest', null);
        w.writeCharacters(getValue(ld.Boat_Class_Interest__c));
        w.writeEndElement();
        w.writeStartElement(null, 'boatyearinterest', null);
        w.writeCharacters(getValue(ld.Boat_Year_Interest__c));
        w.writeEndElement();
        w.writeStartElement(null, 'interestedinstocknumber', null);
        w.writeCharacters(getValue(ld.Interested_in_Stock_Number__c));
        w.writeEndElement();
        w.writeStartElement(null, 'interestedinlength', null);
        w.writeCharacters(getValue(ld.Interested_in_length__c));
        w.writeEndElement();
        w.writeStartElement(null, 'interestedinidnumber', null);
        w.writeCharacters(getValue(ld.Interested_in_ID_Number__c));
        w.writeEndElement();
        w.writeStartElement(null, 'purchasetimeframe', null);
        w.writeCharacters(getValue(ld.Buying_horizon__c));
        w.writeEndElement();
        w.writeStartElement(null, 'comments', null);
        w.writeCharacters(getValue(ld.Notes__c));
        w.writeEndElement();        
        /*
w.writeStartElement(null, 'leadsourcetype', null);
w.writeCharacters('');
w.writeEndElement();        
w.writeStartElement(null, 'leadsourcedetail', null);
w.writeCharacters('');
w.writeEndElement();        
w.writeStartElement(null, 'leadsource', null);
w.writeCharacters(getValue(ld.LeadSource));
w.writeEndElement(); 
w.writeStartElement(null, 'leadsourcevendor', null);
w.writeCharacters('');
w.writeEndElement(); 
w.writeStartElement(null, 'leadwebsourcepage', null);
w.writeCharacters(getValue(ld.Website));
w.writeEndElement(); 
w.writeStartElement(null, 'boatunittype', null);
w.writeCharacters(getValue(ld.Boat_Class_Interest__c));
w.writeEndElement(); 
w.writeStartElement(null, 'boattype', null);
w.writeCharacters('');
w.writeEndElement(); 
w.writeStartElement(null, 'boatbrand', null);
w.writeCharacters(getValue(ld.Brand_Interest__c));
w.writeEndElement(); 
w.writeStartElement(null, 'boatstocknumber', null);
w.writeCharacters('');
w.writeEndElement(); 
w.writeStartElement(null, 'boatmodel', null);
w.writeCharacters(getValue(ld.Boat_Model_Interest__c));
w.writeEndElement(); 
w.writeStartElement(null, 'boathin', null);
w.writeCharacters('');
w.writeEndElement(); 
w.writeStartElement(null, 'tradeinhorsepower', null);
w.writeCharacters('');
w.writeEndElement(); 
w.writeStartElement(null, 'tradehours', null);
w.writeCharacters('');
w.writeEndElement(); 
w.writeStartElement(null, 'tradetrailerincluded', null);
w.writeCharacters('');
w.writeEndElement(); 
w.writeStartElement(null, 'cashdown', null);
w.writeCharacters('');
w.writeEndElement(); 
w.writeStartElement(null, 'rentorown', null);
w.writeCharacters('');
w.writeEndElement();*/ 
        w.writeEndDocument();
        String xmlOutput = w.getXmlString();
        w.close();
        return xmlOutput;
    }
    
    public static boolean sendEmail {
		get {
			return !DealerRouter.doNotSendEmail;
		}
		set {
			DealerRouter.doNotSendEmail = !value;
		}
	}
}