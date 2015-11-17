public class ManageDealTeamMembers {
    public class TeamMember {
        public Boolean selected { get; set; }
        public Team_Member__c record { get; set; }

        public TeamMember(Team_Member__c record) {
            selected = false;
            this.record = record;
        }
    }

    public transient String dmessage { get; set; }
    public List<TeamMember> newMembers { get; private set; }
    public List<TeamMember> oldMembers { get; private set; }
    private Id dealId;

    public ManageDealTeamMembers(ApexPages.StandardController controller) {
        dealId = controller.getRecord().Id;
        refresh();
    }

    public void refresh() {
        oldMembers = new List<TeamMember>();
        Set<Id> existingEmployeeIds = new Set<Id>();
        for (Team_Member__c tm : [SELECT Id, Title__c, User__c, User__r.Title, User__r.Name, Role__c, Deal_Mentor__c FROM Team_Member__c WHERE Deal__c=:dealId AND IsDeleted=FALSE ORDER BY User__r.LastName]) {
            oldMembers.add(new TeamMember(tm));
            existingEmployeeIds.add(tm.User__c);
        }

        newMembers = new List<TeamMember>();
        for (User u : [SELECT Id, Name, Title, Active_Deals__c FROM User WHERE Id NOT IN :existingEmployeeIds AND IsActive=TRUE ORDER BY LastName]) {
            newMembers.add(new TeamMember(new Team_Member__c(
                Deal__c = dealId,
                User__c = u.Id,
                User__r = u
            )));
        }
    }

    public void applyDealMentor() {
        try {
            Integer index = Double.valueOf(ApexPages.currentPage().getParameters().get('index')).intValue();
            update oldMembers.get(index).record;            
        } catch (Exception e) {
        }        
    }

    public void add() {
        try {
            List<Team_Member__c> selectedMembers = buildSelectedMembers(newMembers);
            if (!selectedMembers.isEmpty()) {
                insert selectedMembers;
                refresh();
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select at least one team member to add'));
            }
        } catch (Exception e) {
            ApexPages.addMessages(e);
        }
    }

    public void remove() {
        try {
            List<Team_Member__c> selectedMembers = buildSelectedMembers(oldMembers);
            if (!selectedMembers.isEmpty()) {
                delete selectedMembers;
                refresh();
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select at least one team member to remove'));
            }
        } catch (Exception e) {
            ApexPages.addMessages(e);
        }
    }

    private List<Team_Member__c> buildSelectedMembers(List<TeamMember> teamMembers) {
        List<Team_Member__c> selectedMembers = new List<Team_Member__c>();
        for (TeamMember tm : teamMembers) {
            if (tm.selected) {
                selectedMembers.add(tm.record);
            }
        }
        return selectedMembers;
    }


    private static testMethod void testManageDealTeamMembers() {
        Account a = new Account(name='Test Deal Company');
        insert a;

        Contact c = new Contact(FirstName='Test',LastName='Contact',AccountID=a.id);
        insert c;

        Deal__c d = new Deal__c(Related_Company__c=a.Id,Source_Name__c=c.id,Source_Company__c=a.id,Deal_Size_MM__c=5,Status__c='Early Investigation');
        insert d;

        Employee__c e = new Employee__c(Initials__c='!TL');
        insert e;

        Theme__c thm = new Theme__c(Name='Test Theme',Assigned_To_v2__c=e.Id,Active__c='Active');
        insert thm;

        ManageDealTeamMembers controller = new ManageDealTeamMembers(new ApexPages.StandardController(d));
        controller.newMembers[0].selected = true;
        controller.add();

        controller.oldMembers[0].selected = true;
        controller.remove();
    }
}