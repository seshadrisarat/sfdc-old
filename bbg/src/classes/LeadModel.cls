public class LeadModel {
	
	/*

    public Lead thisLead{get;set;}
    
    public LeadModel(Lead l){
        this.thisLead = l;
        hasBeenAssigned = false;
    }
    
    public boolean isSendable{
        get{
            // get the custom settings that dictate whether a lead should be sent to a dealer or not
            Map<String,Lead_Routing_Do_Not_Send__c> dns = Lead_Routing_Do_Not_Send__c.getAll();
            for(Lead_Routing_Do_Not_Send__c d:dns.values()){
                if(this.thisLead.Brand_Code__c == d.get('Brand_Code__c') && this.thisLead.Lead_Form_Name__c == d.get('Lead_Form_Name__c')){
                    return false;
                }
            }
            return true;
        }
        set{}
    }
    
    public Lead_Routing_Rule__c routingRule{
        get{
            //find the right Lead_Routing_Rule__c record that matches the criteria 
            //of this lead instance
            Lead_Routing_Rule__c[] rules = new list<Lead_Routing_Rule__c>();
            system.debug('LeadRouter.routingRules:' + LeadRouter.routingRules);
            boolean lrAssigned = false;
            for(Lead_Routing_Rule__c lr:LeadRouter.routingRules){
                system.debug('Routing Rule ISO: '+ lr.Country_Code__c + ':: lead ISO'+ this.thisLead.Country_ISO_Code__c);
                system.debug('Routing Rule Brand Code: '+lr.Brand_Code__c + ':: lead Brand Code: '+ this.thisLead.Brand_Code__c);
                if(lr.Country_Code__c == this.thisLead.Country_ISO_Code__c && lr.Brand_Code__c == this.thisLead.Brand_Code__c){
                    return lr;
                    lrAssigned = TRUE;
                }
            }
            if(!lrAssigned){
                // todo: get the routing rule for "All Other"
                for(Lead_Routing_Rule__c lr: LeadRouter.routingRules){
                	if(lr.Country_Code__c == null && lr.Brand_Code__c == this.thisLead.Brand_Code__c){
                		return lr;
                	}
                }
            }
            return null;
        }
        set{}
    }
    
    public boolean hasCustomRoutingExceptions{
        get{
            hasCustomRoutingExceptions = false;
            system.debug('hasCustomRoutingExceptions'+ hasCustomRoutingExceptions);
            if(thisLead.Brand_Code__c=='SR' && thisLead.Country_ISO_Code__c == 'US'){
                hasCustomRoutingExceptions = true;
            }
            return hasCustomRoutingExceptions;
        }set;}
    // to-do: add custom routing exception criteria check here.  See Lead Routing spreadsheet for details
    // this is specific to Sea Ray leads that need custom routing based on Product Type.
    
    public boolean hasBeenAssigned{
        get{
            if(hasBeenAssigned==null){
                hasBeenAssigned = false;
            }
            return hasBeenAssigned;
        }set;}
    public boolean hasBeenRouted{
        get{
            if(hasBeenRouted==null){
                hasBeenRouted = false;
            }
            return hasBeenRouted;
        }set;}
        
        */
}