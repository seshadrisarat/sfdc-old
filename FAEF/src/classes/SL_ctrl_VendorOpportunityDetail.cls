public with sharing class SL_ctrl_VendorOpportunityDetail {

	public Opportunity opportunity {get;set;}
    public String buttonColor {get;set;}
    public String buttonFontColor {get;set;}
    public Attachment attachment { get { if (attachment == null) attachment = new Attachment(); return attachment; } set; }
    public List<VendorDocument> vendorDocs {get;set;}
    public String vendorDocsJson {get;set;}

	public SL_ctrl_VendorOpportunityDetail() {
		this.opportunity = getOpportunity();
        this.vendorDocs = getVendorDocs(this.opportunity);
        this.vendorDocsJson = JSON.serializePretty(this.vendorDocs);
        SL_util_VendorCommunity.PortalBrandingWrapper branding = SL_util_VendorCommunity.getPortalBranding();
        this.buttonColor = branding.inactiveNavColor;
        this.buttonFontColor = branding.inactiveNavFontColor;
        User currentUser = [SELECT ContactId, Id FROM User WHERE Id = : UserInfo.getUserId()];
	}

	private List<Schema.FieldSetMember> getDetailFields() {
        return SObjectType.Opportunity.FieldSets.FAEF_Vendor_Opportunity_Detail.getFields();
    }

    private List<Schema.FieldSetMember> getProposalOptionsFields() {
        return SObjectType.Opportunity.FieldSets.FAEF_Vendor_Opportunity_Proposal_Options.getFields();
    }

    private List<Schema.FieldSetMember> getAdditionalInfoFields() {
        return SObjectType.Opportunity.FieldSets.FAEF_Vendor_Opportunity_Additional_Info.getFields();
    }

	private Opportunity getOpportunity(){
		String opportunityId = ApexPages.currentPage().getParameters().get('opportunityId');

		String query = 'SELECT ';
        for(Schema.FieldSetMember f : this.getDetailFields()) {
            query += f.getFieldPath() + ', ';
        }
        for(Schema.FieldSetMember f : this.getProposalOptionsFields()){
        	query += f.getFieldPath() + ', ';
        }
        for(Schema.FieldSetMember f : this.getAdditionalInfoFields()){
        	query += f.getFieldPath() + ', ';
        }
        query += 'Id, Proposal_Request_Date__c FROM Opportunity WHERE Id =: opportunityId';
        return Database.query(query);
	}

    private List<VendorDocument> getVendorDocs(Opportunity opp){
        List<VendorDocument> vendorDocuments = new List<VendorDocument>();
        for(Vendor_Document__c vendorDoc : [SELECT Id, Attachment__c, Attachment_Name__c, CreatedDate, CreatedBy.Name
                                            FROM Vendor_Document__c 
                                            WHERE Opportunity__c = : ApexPages.currentPage().getParameters().get('opportunityId')]){
            vendorDocuments.add(new VendorDocument(vendorDoc));
        }
        return vendorDocuments;
    }

    public PageReference upload() {

        attachment.OwnerId = UserInfo.getUserId();
        attachment.ParentId = opportunity.Id; // the record the file is attached to
        Vendor_Document__c doc = new Vendor_Document__c(Opportunity__c = ApexPages.currentPage().getParameters().get('opportunityId'), Attachment_Name__c = Attachment.Name);
        
        try {
            insert attachment;
            doc.Attachment__c = attachment.Id;
            insert doc;
        } catch (DMLException e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading attachment'));
            return null;
        } finally {
            attachment = new Attachment(); 
        }

        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Attachment uploaded successfully'));
        PageReference pr = ApexPages.currentPage();
        pr.setRedirect(true);
        return pr;
    }

    @RemoteAction
    public static Boolean setProposalDate(String oppId){
        String query = 'SELECT Id, Proposal_Request_Date__c FROM Opportunity WHERE Id =: oppId';
        Opportunity opportunity = Database.query(query);
        if(opportunity != null){
            if(opportunity.Proposal_Request_Date__c != null){
                return false;
            }
            else{
                opportunity.Proposal_Request_Date__c = datetime.now();
                update opportunity;
                return true;
            }
        }
        return false;
    }

    public class VendorDocument{
        public String name {get;set;}
        public String url {get;set;}
        public String anchor {get;set;}
        public String createdBy {get;set;}
        public DateTime createdDate {get;set;}

        public VendorDocument(Vendor_Document__c doc){
            anchor = '<a href="'+Site.getPathPrefix()+'/SL_VendorAttachment?attachmentId='+doc.Attachment__c+'">'+doc.Attachment_Name__c+'</a>';
            createdDate = doc.CreatedDate;
            createdBy = doc.CreatedBy.Name;
        }
    }
}