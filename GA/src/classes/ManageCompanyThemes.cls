public class ManageCompanyThemes {
    public class Theme {
        public Boolean selected { get; set; }
        public Company_Theme__c record { get; set; }

        public Theme(Company_Theme__c record) {
            selected = false;
            this.record = record;
        }
    }

    public transient String dmessage { get; set; }
    public List<Theme> newThemes { get; private set; }
    public List<Theme> oldThemes { get; private set; }
    private Id accountId;

    public ManageCompanyThemes(ApexPages.StandardController controller) {
        accountId = controller.getRecord().Id;
        refresh();
    }

    public void refresh() {
        oldThemes = new List<Theme>();
        Set<Id> existingThemeIds = new Set<Id>();
        for (Company_Theme__c dt : [SELECT Theme__r.Name, Theme__r.Description__c, Theme__r.Active__c FROM Company_Theme__c WHERE Company__c=:accountId AND IsDeleted=FALSE ORDER BY Theme__r.Name]) {
            oldThemes.add(new Theme(dt));
            existingThemeIds.add(dt.Theme__c);
        }

        newThemes = new List<Theme>();
        for (Theme__c t : [SELECT Name, Description__c, Active__c FROM Theme__c WHERE Id NOT IN :existingThemeIds AND IsDeleted=FALSE ORDER BY Name]) {
            newThemes.add(new Theme(new Company_Theme__c(
                Company__c = accountId,
                Theme__c = t.Id,
                Theme__r = t
            )));
        }
    }

    public void add() {
        try {
            List<Company_Theme__c> selectedThemes = buildSelectedThemes(newThemes);
            if (!selectedThemes.isEmpty()) {
                insert selectedThemes;
                refresh();
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select at least one theme to add'));
            }
        } catch (Exception e) {
            ApexPages.addMessages(e);
        }
    }

    public void remove() {
        try {
            List<Company_Theme__c> selectedThemes = buildSelectedThemes(oldThemes);
            if (!selectedThemes.isEmpty()) {
                delete selectedThemes;
                refresh();
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select at least one theme to remove'));
            }
        } catch (Exception e) {
            ApexPages.addMessages(e);
        }
    }

    private List<Company_Theme__c> buildSelectedThemes(List<Theme> themes) {
        List<Company_Theme__c> selectedThemes = new List<Company_Theme__c>();
        for (Theme t : themes) {
            if (t.selected) {
                selectedThemes.add(t.record);
            }
        }
        return selectedThemes;
    }
}