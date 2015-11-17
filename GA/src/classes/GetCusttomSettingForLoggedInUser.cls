public with sharing class GetCusttomSettingForLoggedInUser 
{
	// To fetch the custtom setting defined for logged in user
	public static CustomTrackingPages__c getCustomSetting()
    {
        CustomTrackingPages__c objCustomTrackingPages = new CustomTrackingPages__c();
        
        objCustomTrackingPages = CustomTrackingPages__c.getInstance(Userinfo.getUserId());
        
        if(objCustomTrackingPages.Id != null) 
        {
            system.debug('======objCustomTrackingPages userId======='+ objCustomTrackingPages);
            return objCustomTrackingPages;
        }
        else
        {
            objCustomTrackingPages = CustomTrackingPages__c.getInstance(Userinfo.getProfileId());
            
            if(objCustomTrackingPages.Id != null)
            {
                system.debug('======objCustomTrackingPages pro ======='+ objCustomTrackingPages);
                return objCustomTrackingPages;
            }   
            else
            {
                objCustomTrackingPages = CustomTrackingPages__c.getOrgDefaults();
                
                if(objCustomTrackingPages != null && objCustomTrackingPages.Id != null)
                {
                    system.debug('======objCustomTrackingPages org Def======='+objCustomTrackingPages);
                    return objCustomTrackingPages;
                }
                else
                    return null;
            }
        }
    }
}