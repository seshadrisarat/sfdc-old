public class ManageCompanyConferencesAwards {
    public class ConferenceAward {
        public Boolean selected { get; set; }
        public Company_Conference_Award__c record { get; set; }

        public ConferenceAward(Company_Conference_Award__c record) {
            selected = false;
            this.record = record;
        }
    }

    public transient String dmessage { get; set; }
    public List<ConferenceAward> newConferencesAwards { get; private set; }
    public List<ConferenceAward> oldConferencesAwards { get; private set; }
    private Id accountId;

    public ManageCompanyConferencesAwards(ApexPages.StandardController controller) {
        accountId = controller.getRecord().Id;
        refresh();
    }

    public void refresh() {
        oldConferencesAwards = new List<ConferenceAward>();
        Set<Id> existingConferenceAwardIds = new Set<Id>();
        for (Company_Conference_Award__c ca : [SELECT Conference_Award__r.Name, Conference_Award__r.Description__c FROM Company_Conference_Award__c WHERE Company__c=:accountId AND IsDeleted=FALSE ORDER BY Conference_Award__r.Name]) {
            oldConferencesAwards.add(new ConferenceAward(ca));
            existingConferenceAwardIds.add(ca.Conference_Award__c);
        }

        newConferencesAwards = new List<ConferenceAward>();
        for (Conference_Award__c ca : [SELECT Name, Description__c FROM Conference_Award__c WHERE Id NOT IN :existingConferenceAwardIds AND IsDeleted=FALSE ORDER BY Name]) {
            newConferencesAwards.add(new ConferenceAward(new Company_Conference_Award__c(
                Company__c = accountId,
                Conference_Award__c = ca.Id,
                Conference_Award__r = ca
            )));
        }
    }

    public void add() {
        try {
            List<Company_Conference_Award__c> selectedConferenceAward = buildselectedConferenceAward(newConferencesAwards);
            if (!selectedConferenceAward.isEmpty()) {
                insert selectedConferenceAward;
                refresh();
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select at least one conference / award to add'));
            }
        } catch (Exception e) {
            ApexPages.addMessages(e);
        }
    }

    public void remove() {
        try {
            List<Company_Conference_Award__c> selectedConferenceAward = buildselectedConferenceAward(oldConferencesAwards);
            if (!selectedConferenceAward.isEmpty()) {
                delete selectedConferenceAward;
                refresh();
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select at least one conference / award to remove'));
            }
        } catch (Exception e) {
            ApexPages.addMessages(e);
        }
    }

    private List<Company_Conference_Award__c> buildselectedConferenceAward(List<ConferenceAward> conferencesAwards) {
        List<Company_Conference_Award__c> selectedConferenceAward = new List<Company_Conference_Award__c>();
        for (ConferenceAward t : conferencesAwards) {
            if (t.selected) {
                selectedConferenceAward.add(t.record);
            }
        }
        return selectedConferenceAward;
    }
}