/**
* Owner implementation of dealer routing
*
* @author Mike Regan
*/
public with sharing class OwnerRouter extends DealerRouter {
	
    public static Owner_Routing_Rule__c[] getAllRoutingRules(){
        return [SELECT Name, Country_Code__c, Brand_Code__c, Routing_Attempt_1_Type__c, Number_of_Owners_1__c, Routing_Attempt_2_Type__c, Number_of_Owners_2__c, Routing_Attempt_3_Type__c, Number_of_Owners_3__c, Routing_Attempt_4_Type__c, Number_of_Owners_4__c
                                                      FROM Owner_Routing_Rule__c];
    } 
    
    protected override string getRoutingType() {
    	return 'Owner';
    }
    
    protected override boolean isSendable(sobject obj) {
    	boolean sendable = super.isSendable(obj);
    	if (sendable) {
	    	Account owner = (Account)obj;
	    	Map<String, Lead_Routing_Do_Not_Send__c> dns = Lead_Routing_Do_Not_Send__c.getAll();
	        for(Lead_Routing_Do_Not_Send__c d:dns.values()){
	            if(owner.Brand__c == d.get('Brand_Code__c') && owner.Lead_Form_Name__pc == d.get('Lead_Form_Name__c')){
	                sendable = false;
	                break;
	            }
	        }
	        
	        if (sendable) {
	        	// We only want to send owners if they have a pardot score
	        	if (owner.pi__score__pc == null || owner.pi__score__pc <= 0) {
	        		sendable = false;
	        	}
	        }
	    }
	    return sendable;
    }
    
    protected override void sendToFootStepsInternal(Set<Id> idsToSendToFootsteps) {
		String scheduleTime = Datetime.now().addSeconds( 60 ).format( 'ss mm HH dd MM ? yyyy' );
		String scheduleId = String.valueOf(Datetime.now().getTime());
		String jobId = System.schedule( 'ownerFootstepsIntegration'+scheduleId, scheduleTime, new FootstepsSendAccountsJob(idsToSendToFootsteps) );
    }
    
    protected override void sendToFootstepsInternal(map<Id, set<Id>> objectIdToDealerIdMap) {
    	String scheduleTime = Datetime.now().addSeconds( 60 ).format( 'ss mm HH dd MM ? yyyy' );
		String scheduleId = String.valueOf(Datetime.now().getTime());
		String jobId = System.schedule( 'ownerFootstepsIntegration'+scheduleId, scheduleTime, new FootstepsSendAccountsJob(objectIdToDealerIdMap) );
	}
    
    private Owner_Routing_Rule__c getOwnerRoutingRule(DealerRoutingModel model) {
        Owner_Routing_Rule__c[] rules = getAllRoutingRules();
        
        // Try to find a rule match on country and brand
        for(Owner_Routing_Rule__c rule : rules) {
            if(rule.Country_Code__c == model.CountryISO && rule.Brand_Code__c == model.Brand) {
                return rule;
            }
        }
        
        // No match, so just try brand
        for(Owner_Routing_Rule__c rule : rules) {
            if(rule.Country_Code__c == null && rule.Brand_Code__c == model.Brand) {
                return rule;
            }
        } 
        
        // No match
        return null;
    }
    
    protected override string getObjectBrand(sobject obj) {
		Account owner = (account)obj;
		return owner.Brand__c;
    }
    
    protected override string getMarineMaxDealerFilename(sobject obj) {
    	return 'Bayliner Owner';
    }
    
    protected override string getMarineMaxDealerPlainTextBody(sobject obj) {
    	return 'bayliner dealer xml';
    }
    
    protected override string getRuleName(sobject rule, integer ruleNumber) {
        string ruleName = (string)rule.get('Routing_Attempt_' + ruleNumber + '_Type__c');   
        return ruleName; 
    }
     
    protected override integer getRuleNumberOfDealers(sobject rule, integer ruleNumber) {
        integer maxNumberOfDealers = integer.valueOf(rule.get('Number_of_Owners_' + ruleNumber + '__c'));
        return maxNumberOfDealers;
    } 
    
    protected override DealerRoutingModel convertToModel(sobject obj) {
        Account owner = (Account)obj;
        string brand = owner.Brand__c;
        if (brand != null) {
            string productCategory = owner.Boat_Category_of_Interest__pc;
            
            DealerRoutingModel model = new DealerRoutingModel();
            model.owner(owner, brand, productCategory);
            return model;
        }
        return null;
    }
    
    protected override sobject getDealerRoutingRule(DealerRoutingModel model) {
        system.debug('getDealerRoutingRule - ' + model.Id);
        Owner_Routing_Rule__c rule = getOwnerRoutingRule(model);
        return rule;
    }
    
    protected override Assigned_Dealer__c createAssignedDealer(sobject obj, DealerRoutingModel model, DealerRoutingAssignedDealer dealer, list<Assigned_Dealer__c> oldAssignedDealers) {
		Assigned_Dealer__c assignedDealer = super.createAssignedDealer(obj, model, dealer, oldAssignedDealers);
		assignedDealer.Owner__c = obj.Id;
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
}