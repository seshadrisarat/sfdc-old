/*
*      HighStreetFlowController is used to perform Controller logic for THS Flow VF pages.
*      This controller is used for display the custom UI for the THS Tenant Flow.
* 
*      Author  :   Wilson Ng 
*      Date :   November 7, 2012
* 
*/
public with sharing class HighStreetFlowController extends FlowController {

    public final Account acct;
    public HighStreetFlowController HighStreetController { get; set; }

    public HighStreetFlowController(ApexPages.StandardController controller) {
        this.acct = (Account)controller.getRecord();
        this.HighStreetController = this;
    }
    
    public PageReference gotoTenantDetail() {
        return redirectPage(Page.HighStreetFlow_1TenantDetail, this.acct.Id);
    }

    public PageReference gotoLocationRequests() {
        return redirectPage(Page.HighStreetFlow_2LocationRequest, this.acct.Id);
    }

    public PageReference gotoSiteSurveys() {
        return redirectPage(Page.HighStreetFlow_3SiteSurveys, this.acct.Id);
    }
    
    public PageReference gotoManageDeals() {
        return redirectPage(Page.HighStreetFlow_4ManageDeals, this.acct.Id);
    }
    
    // creates the deal from the listing
    public PageReference gotoCreateDeal() {
        
        Deal__c newDeal = null;
        // check for listingid
        string listingId = (string)ApexPages.currentPage().getParameters().get('listingId');
        if(string.isEmpty(listingId)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Fatal, 'Error: Missing listingId URL parameter.'));
            return null;
        }
        // check for sitesurveyid
        string sitesurveyId = (string)ApexPages.currentPage().getParameters().get('sitesurveyId');
        if(string.isEmpty(sitesurveyId)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Fatal, 'Error: Missing sitesurveyId URL parameter.'));
            return null;
        }
        
        Savepoint sp = database.setSavepoint();
        try {
            // retrieve listing information
            Listing__c listing = [select Id, Name from Listing__c where Id=:listingId];
        
            // create the deal
            system.debug('Creating new deal for sitesurvey[' + sitesurveyId + '  listing[' + listingId + ']   tenant[' + this.acct.Id + ']');   
            newDeal = new Deal__c();
            newDeal.Name = listing.Name + ' - ' + this.acct.name + ' - THS Deal';
            newDeal.RecordType = new RecordType(Name='THS Deal');
            newDeal.Tenant_THS_Deal__c = this.acct.Id;
            newDeal.Listing__c = listing.Id;
            insert newDeal;
            
            // update site survey
            Site_Survey__c ss = new Site_Survey__c(Id=sitesurveyId);
            ss.Deal__c = newDeal.Id;
            update ss;
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'New Deal Created.'));
        }
        catch (Exception ex) {
            database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Error while creating new Deal: '+ex.getMessage()));
            return null;    
        }
     
        // if all processing okay, then navigate to back to the next step in flow (step 4: manage deals)
        return gotoManageDeals();
    }
    
    
    // creates the lease from the deal
    public Id newLeaseId { get; private set;}
    public String manageDealsUrl { get { return gotoManageDeals().getUrl(); } }
    public boolean hasMessages { get { return ApexPages.hasMessages(); } }
    public PageReference gotoCreateLease() {
        
        Lease__c newLease = null;
        // check for dealId
        string dealId = (string)ApexPages.currentPage().getParameters().get('dealId');
        if(string.isEmpty(dealId)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Fatal, 'Error: Missing dealId URL parameter.'));
            return null;
        }
        
        Savepoint sp = database.setSavepoint();
        try {
            // retrieve deal and listing information
            Deal__c deal = [select Id, Name, Lease__c, Listing__c, Listing__r.Name, Listing__r.Lease__c, Listing__r.Property__c, Listing__r.Listing_Status__c, Listing__r.Total_Overall_SF__c from Deal__c where Id=:dealId];
            if(string.isNotEmpty(deal.Lease__c)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Error while creating new Lease.  Current deal already has lease.' + deal.Lease__c));
                return null;    
            }
            if(string.isEmpty(deal.Listing__c)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Error while creating new Lease.  Current deal has empty listing.'));
                return null;    
            }
            
            // create the lease
            system.debug('Creating new lease for deal[' + deal.Id + ']   tenant[' + this.acct.Id + ']');
            newLease = new Lease__c();
            newLease.Name = deal.Listing__r.Name + ' - ' + this.acct.name + ' - THS Lease';
            newLease.RecordType = new RecordType(Name='Thor High Street Lease');
            newLease.Tenant__c = this.acct.Id;
            newLease.Related_Deal__c = deal.Id;
            newLease.Leased_Square_Footage__c = deal.Listing__r.Total_Overall_SF__c;
            
            insert newLease;
            
            deal.Lease__c = newLease.Id;
            update deal;
            
            // update listing fields
            Listing__c listing = new Listing__c(Id=deal.Listing__c);
            listing.Lease__c = newLease.Id;
            listing.Listing_Status__c = 'Leased';
            update listing;
                
            // insert property lease using tenant and new lease
            Property_Lease__c propertyLease = new Property_Lease__c(Lease__c=newLease.Id, Property__c=deal.Listing__r.Property__c);
            insert propertyLease;

            // Note Leasing and Listing comps are handled via triggers (after insert)
            
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'New Lease Created.'));
            // if all processing okay, then navigate to new lease detail page
            this.newLeaseId = newLease.Id;
            return null;
        }
        catch (Exception ex) {
            database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Error while creating new Lease: '+ex.getMessage() + ' ' + ex.getLineNumber()));
            return null;    
        }
    }
    
    //
    // test methods
    @isTest
    static void testThisClass() {
        
        // dummy data
        Account acct = new Account(Name='test acct', RecordType=new RecordType(Name='Tenant'));
        insert acct;
        Location_Neighborhood__c loc = new Location_Neighborhood__c(Name='testloc');
        insert loc;
        Property__c prop = new Property__c(Name='test property', Location_Neighborhood__c=loc.Id, Thor_Ownership__c='Thor Prospect');
        insert prop;
        Listing__c listing = new Listing__c(Name='test property', Property__c=prop.Id);
        insert listing;
        Site_Survey__c sitesurvey = new Site_Survey__c(Listing__c=listing.Id, Prospective_Tenant__c=acct.Id);
        insert sitesurvey;
        
        Test.startTest();

        HighStreetFlowController hsfc = new HighStreetFlowController(new ApexPages.StandardController(acct));

        PageReference nextPage = hsfc.gotoTenantDetail();
        system.assert(nextPage.getUrl().containsIgnoreCase('_1TenantDetail?id='), 'Error: AcquisitionsFlowController did not redirect to tenant detail page.');
        
        nextPage = hsfc.gotoLocationRequests();
        system.assert(nextPage.getUrl().containsIgnoreCase('_2LocationRequest?id='), 'Error: AcquisitionsFlowController did not redirect to location requests page.');
        
        nextPage = hsfc.gotoSiteSurveys();
        system.assert(nextPage.getUrl().containsIgnoreCase('_3SiteSurveys?id='), 'Error: AcquisitionsFlowController did not redirect to site surveys page.');
        
        nextPage = hsfc.gotoManageDeals();
        system.assert(nextPage.getUrl().containsIgnoreCase('_4ManageDeals?id='), 'Error: AcquisitionsFlowController did not redirect to manage deals page.');
        
        // test create deal
        ApexPages.currentPage().getParameters().put('listingId', listing.Id);
        ApexPages.currentPage().getParameters().put('sitesurveyId', sitesurvey.Id);
        nextPage = hsfc.gotoCreateDeal();
        Deal__c[] dealCreated = [select id, name from Deal__c where Tenant_THS_Deal__c = :acct.Id];
        system.assert(dealCreated.size() == 1, 'Error: High Street Flow Create Deal did not create proper deal.');
        
        // test create lease
        ApexPages.currentPage().getParameters().put('dealId', dealCreated[0].Id);
        nextPage = hsfc.gotoCreateLease();
        Lease__c[] leaseCreated = [select id, name from Lease__c where Tenant__c = :acct.Id];
        system.assert(leaseCreated.size() == 1, 'Error: High Street Flow Create Lease did not create proper lease.');
        Property_Lease__c[] propLeaseCreated = [select id from Property_Lease__c where Lease__c = :leaseCreated[0].Id];
        //system.assert(propLeaseCreated.size() == 1, 'Error: High Street Flow Create Lease did not create proper property leases.');
        
        Test.stopTest();
    }
    
    @isTest
    static void testThisClass_Errors() {
        
        // dummy data
        Account acct = new Account(Name='test acct', RecordType=new RecordType(Name='Tenant'));
        insert acct;
                
        Test.startTest();

        HighStreetFlowController hsfc = new HighStreetFlowController(new ApexPages.StandardController(acct));

        // errors: missing listingid, missing sitesurveyid, and invalid ids
        PageReference nextPage = hsfc.gotoCreateDeal();
        ApexPages.currentPage().getParameters().put('listingId', 'invalid id');
        nextPage = hsfc.gotoCreateDeal();
        ApexPages.currentPage().getParameters().put('sitesurveyId', 'invalid id');
        nextPage = hsfc.gotoCreateDeal();
        
        // test create lease
        nextPage = hsfc.gotoCreateLease();
        ApexPages.currentPage().getParameters().put('dealId', 'invalid id');
        nextPage = hsfc.gotoCreateLease();
        
        Test.stopTest();
    }
}