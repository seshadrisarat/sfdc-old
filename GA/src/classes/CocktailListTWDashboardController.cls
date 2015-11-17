public with sharing class CocktailListTWDashboardController {
    public List<Contact> records { get; private set; }
    
    public CocktailListTWDashboardController() {
        Set<Id> teamUserIds = Utilities.getPublicTeamMembers();
        if (teamUserIds != null && !teamUserIds.isEmpty()) {
            records = [SELECT Name, Account.Name, CreatedDate FROM Contact WHERE CreatedDate=THIS_WEEK AND OwnerID IN :teamUserIds ORDER BY CreatedDate Desc LIMIT 10];
        }
    }
    
    static testMethod void testCocktailListTWDashboardController() {
        CocktailListTWDashboardController controller = new CocktailListTWDashboardController();
    }
}