public class ManageDealContacts {
    public class DealContact {
        public Boolean selected { get; set; }
        public Deal_Contact__c record { get; set; }

        public DealContact(Deal_Contact__c record) {
            selected = false;
            this.record = record;
        }
    }

    public transient String dmessage { get; set; }
    public List<DealContact> newContacts { get; private set; }
    public List<DealContact> oldContacts { get; private set; }
    private Set<Id> existingContactIds;
    private Id dealId;

    public ManageDealContacts(ApexPages.StandardController controller) {
        dealId = controller.getRecord().Id;
        refresh();
    }

    public void refresh() {
        oldContacts = new List<DealContact>();
        existingContactIds = new Set<Id>();
        for (Deal_Contact__c dc : [SELECT Contact_Name__r.Name, Contact_Name__r.Account.Name, Role__c, Description__c, Estimated_Fee__c, Actual_Fee__c FROM Deal_Contact__c WHERE Deal__c=:dealId AND IsDeleted=FALSE ORDER BY Contact_Name__r.Name]) {
            oldContacts.add(new DealContact(dc));
            existingContactIds.add(dc.Contact_Name__c);
        }

        newContacts = new List<DealContact>();
        for (Integer i=0; i<5; i++) {
            newContacts.add(new DealContact(new Deal_Contact__c(
                Deal__c = dealId
            )));
        }
    }

    public void add() {
        try {
            // Mark valid contacts
            for (DealContact dc : newContacts) {
                dc.selected = false;
                if (dc.record.Contact_Name__c != null && !existingContactIds.contains(dc.record.Contact_Name__c)) {
                    dc.selected = true;
                }
            }

            List<Deal_Contact__c> selectedContacts = buildSelectedContacts(newContacts);
            if (!selectedContacts.isEmpty()) {
                insert selectedContacts;
                refresh();
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No new contacts added'));
            }
        } catch (Exception e) {
            ApexPages.addMessages(e);
        }
    }

    public void remove() {
        try {
            List<Deal_Contact__c> selectedContacts = buildSelectedContacts(oldContacts);
            if (!selectedContacts.isEmpty()) {
                delete selectedContacts;
                refresh();
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select at least one deal contact to remove'));
            }
        } catch (Exception e) {
            ApexPages.addMessages(e);
        }
    }

    private List<Deal_Contact__c> buildSelectedContacts(List<DealContact> dealContacts) {
        List<Deal_Contact__c> selectedContacts = new List<Deal_Contact__c>();
        for (DealContact dc : dealContacts) {
            if (dc.selected) {
                selectedContacts.add(dc.record);
            }
        }
        return selectedContacts;
    }
}