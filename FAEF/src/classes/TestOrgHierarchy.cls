@isTest(SeeAllData=true)
private class TestOrgHierarchy {
    
    @isTest static void runTest() {
        OrgHierarchyCtrl org = new OrgHierarchyCtrl();
        System.Assert(org.currentFocusUserId != null,'no current user');
        System.Assert(org.me != null,'no user node for current user');
        UserNode u = new UserNode(new User(), new User());
    }
}