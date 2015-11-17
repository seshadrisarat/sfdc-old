/*
*      LeasingFlowController is used to perform Controller logic for Leasing Flow VF pages.
*      This controller is used for display the custom UI for the Leasing Lease Flow.
* 
*      Author  :   Wilson Ng 
*      Date :   November 7, 2012
* 
*/
public with sharing class LeasingFlowController extends FlowController {

    public final Deal__c deal { get; set; }
    public LeasingFlowController LeasingController { get; set; }

    public LeasingFlowController(ApexPages.StandardController controller) {
        this.deal = [select Id, Name, Lease__c, Tenant__c,Tenant__r.name, Options__c, Estimated_Square_Footage__c, Deal_Stage__c from Deal__c where Id = :controller.getId()];
        this.LeasingController = this;
    }

    public PageReference gotoDealDetail() {
        return redirectPage(Page.LeasingFlow_1DealDetail, this.deal.Id);
    }

    public PageReference gotoManageProperties() {
        return redirectPage(Page.LeasingFlow_2ManageProperties, this.deal.Id);
    }

    public PageReference gotoManageContacts() {
        return redirectPage(Page.LeasingFlow_3ManageContacts, this.deal.Id);
    }

    public PageReference gotoManageComps() {
        return redirectPage(Page.LeasingFlow_4ManageComps, this.deal.Id);
    }

    public PageReference gotoSimilarListings() {
        return redirectPage(Page.LeasingFlow_6SimilarListings, this.deal.Id);
    }


    public PageReference gotoCreateLease() {
        if(this.deal.Lease__c==null) {
            
            // create the lease
            Savepoint sp = database.setSavepoint();
            try {
                system.debug('Creating new lease for deal: ' + this.deal.Id);
                Lease__c newLease = new Lease__c();
                newLease.RecordType = new RecordType(Name='Thor Leasing Lease');
                newLease.Name = this.deal.Name + ' - ' + this.deal.Tenant__r.name + ' - Leasing Lease';
                newLease.Related_Deal__c = this.deal.Id;
                newLease.Tenant__c = this.deal.Tenant__c;
                newLease.Options__c = this.deal.Options__c;
                newLease.Leased_Square_Footage__c = this.deal.Estimated_Square_Footage__c;
                insert newLease;
                
                // update deal fields
                this.deal.Lease__c = newLease.Id;
                this.deal.Deal_Stage__c = 'Closed Won';
                update this.deal;
                
                // insert property leases using properties assigned to this deal
                list<Property_Lease__c> propertyLeases = new list<Property_Lease__c>();
                for(Deal_Property__c dp : [select Id, Deal__c, Property__c from Deal_Property__c where Deal__c = :this.deal.Id])
                    propertyLeases.add(new Property_Lease__c(Lease__c=newLease.Id, Property__c=dp.Property__c));
                if(propertyLeases.size() > 0)
                    insert propertyLeases;

                // Note Leasing and Listing comps are handled via triggers (after insert)
                
            }
            catch (Exception ex) {
                database.rollback(sp);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Error while creating new Lease: '+ex.getMessage()));
                return null;    
            }
        }
        return redirectPage(Page.LeasingFlow_5CreateLease, this.deal.Id);
    }
    
    //
    // test methods
    @isTest
    static void testThisClass() {
        
        // dummy data
        Deal__c deal = new Deal__c(Name='test deal', RecordType=new Recordtype(Name='Leasing Deal'));
        insert deal;
        Location_Neighborhood__c loc = new Location_Neighborhood__c(Name='testloc');
        insert loc;
        Property__c prop = new Property__c(Name='test property', Location_Neighborhood__c=loc.Id, Thor_Ownership__c='Thor Owned');
        insert prop;
        Deal_Property__c dealProp = new Deal_Property__c(Deal__c=deal.Id, Property__c=prop.Id);
        insert dealProp;
        
        Test.startTest();

        LeasingFlowController lfc = new LeasingFlowController(new ApexPages.StandardController(deal));

        PageReference nextPage = lfc.gotoDealDetail();
        system.assert(nextPage.getUrl().containsIgnoreCase('_1DealDetail?id='), 'Error: LeasingFlowController did not redirect to leasing deal detail page.');
        
        nextPage = lfc.gotoManageProperties();
        system.assert(nextPage.getUrl().containsIgnoreCase('_2ManageProperties?id='), 'Error: LeasingFlowController did not redirect to manage properties page.');
        
        nextPage = lfc.gotoManageContacts();
        system.assert(nextPage.getUrl().containsIgnoreCase('_3ManageContacts?id='), 'Error: LeasingFlowController did not redirect to manage contacts page.');
        
        nextPage = lfc.gotoManageComps();
        system.assert(nextPage.getUrl().containsIgnoreCase('_4ManageComps?id='), 'Error: LeasingFlowController did not redirect to manage comps page.');
        
        nextPage = lfc.gotoSimilarListings();
        system.assert(nextPage.getUrl().containsIgnoreCase('_6SimilarListings?id='), 'Error: LeasingFlowController did not redirect to similar listings page.');
        
        // test create lease
        nextPage = lfc.gotoCreateLease();
        Lease__c[] leaseCreated = [select id, name from Lease__c where Related_Deal__c = :deal.Id];
        system.assert(leaseCreated.size() == 1, 'Error: Leasing Flow Create Lease did not create proper lease.');
        Property_Lease__c[] propLeaseCreated = [select id from Property_Lease__c where Lease__c = :leaseCreated[0].Id];
        system.assert(propLeaseCreated.size() == 1, 'Error: Leasing Flow Create Lease did not create proper property leases.');
        
        Test.stopTest();
    }
}