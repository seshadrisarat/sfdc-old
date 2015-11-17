public with sharing class Twitter_Credential_Manager 
{
    public Twitter_Key__c objTwitterCredentials    {get;set;}
    public Boolean isGranted                       {get;set;}
    public Boolean isEdit                          {get;set;}
    public Boolean isSaved                         {get;set;}
    public String str_Message                      {get;set;}
    
    public Twitter_Credential_Manager()
    {
        Profile objProfile = [Select Name from Profile where Id =:UserInfo.getProfileId()];
        if(objProfile.Name == 'System Administrator')
        {
            if(!Twitter_Key__c.getAll().isEmpty())
            {
                objTwitterCredentials = Twitter_Key__c.getAll().values()[0];
            }
            else
            {
                objTwitterCredentials = new Twitter_Key__c();
            }
            isGranted = true;
            isSaved = false;
        }
        else
        {
            isGranted = false;
        }
        isEdit=false;
    }
    
    public void save()
    {
        upsert objTwitterCredentials;
        isSaved = true;
        isEdit=false;
        str_Message = 'Twitter Credentials Updated';
    }
    
    public void reset()
    {
        objTwitterCredentials = Twitter_Key__c.getAll().values()[0];
        isEdit=false;
        isSaved = true;
        str_Message = 'Twitter Credentials Reset';
    }
    
    public void edit()
    {
        isEdit=true;
    }
}