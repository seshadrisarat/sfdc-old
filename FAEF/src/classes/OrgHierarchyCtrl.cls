public with sharing class OrgHierarchyCtrl 
{
    public String currentFocusUserId {get;set;}
    public Integer masterCount {get;set;}
    public Integer slaveCount {get;set;}
    public UserNode me {get;set;} //current focus user
    public OrgHierarchyCtrl() 
    {
        currentFocusUserId = ApexPages.currentPage().getParameters().get('sfdc.userId');
        if(currentFocusUserId == null || currentFocusUserId == '')
            currentFocusUserId = UserInfo.getUserId();
        setFocusUser();

    }
    public void setFocusUser()
    {
        User u = [SELECT Id, Name, FirstName, LastName, Title, UserRoleId, UserRole.Name, ProfileId, ManagerId, Manager.Name, FullPhotoUrl, SmallPhotoUrl, IsActive
                  FROM User 
                  WHERE Id = :currentFocusUserId 
                  AND IsActive = TRUE
                  Limit 1];
        me = new UserNode(u);

        setMasters();
        setOtherSlavesUnderMaster();
        setSlaves();

    }
    public void setMasters()
    {
        if(me.user.ManagerId != null)
        {
            List<User> uMasters = [SELECT Id, Name, FirstName, LastName, Title, UserRoleId, UserRole.Name, ProfileId, ManagerId, Manager.Name, FullPhotoUrl, SmallPhotoUrl, IsActive
                            FROM User 
                            WHERE Id = :me.user.ManagerId
                            AND IsActive = TRUE
                            ORDER BY Name ASC
                            Limit 100];
            System.debug(uMasters);
            for(User m : uMasters)
                me.addMaster(m);
        }
        //get the count of masters so we know if we should render empty div or not
        masterCount = me.masters.size();
    }
    public void setOtherSlavesUnderMaster()
    {
        if(me.user.ManagerId != null)
        {
            List<User> urFellowSlaves = [SELECT Id, Name, FirstName, LastName, Title, UserRoleId, UserRole.Name, ProfileId, ManagerId, Manager.Name, FullPhotoUrl, SmallPhotoUrl, IsActive
                            FROM User 
                            WHERE ManagerId = :me.user.ManagerId
                            AND id != :me.User.Id
                            AND IsActive = TRUE
                            ORDER BY Name ASC
                            Limit 100];
            for(User s : urFellowSlaves)
                me.addOtherSlavesUnderMaster(s);
        }
    }
    public void setSlaves()
    {
        List<User> uSlaves = [SELECT Id, Name, FirstName, LastName, Title, UserRoleId, UserRole.Name, ProfileId, ManagerId, Manager.Name, FullPhotoUrl, SmallPhotoUrl, IsActive
                        FROM User 
                        WHERE ManagerId = :me.user.Id
                        AND IsActive = TRUE
                        ORDER BY Name ASC
                        Limit 100];
        for(User s : uSlaves)
            me.addSlave(s);
        slaveCount = me.slaves.size();
    }
}