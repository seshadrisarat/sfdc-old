/*******************************************************************************
Name : loadAwardsController
Created By : Reena Acharya(Appirio Offshore)
Created Date : 9th April,2013
Description : loadAwardsController class for uploading awards from uploadAwardsNew page.
*******************************************************************************/
public class loadAwardsController{
    
    public List<Conference_Award__c> awards {get;set;}
    public Boolean awardsUploaded {get;set;}
    
    //Constructor
    public loadAwardsController(){
        initializeAwards();
        awardsUploaded = false;
    }
    
    //Initialize list for showing awards on page.
    public void initializeAwards(){
        awards  = new List<Conference_Award__c>();
        for(integer i=0;i<10 ;i++){
            Conference_Award__c confAward = new Conference_Award__c(Type__c = 'Award',Date__c = date.newinstance(Date.Today().Year(), 1, 1) , End__c = date.newinstance(Date.Today().Year(),12,31));
            awards.Add(confAward);
        }
    }
    
    //Insert/update awards
    public PageReference UplaodAwards(){        
        List<Conference_Award__c > awardsToUpsert = new List<Conference_Award__c >();
        
        //If user fills same name multiple times to upload then show a message to user.
        //Create a set of names.
        Set<String> awardNames = new Set<String>();
        for(Conference_Award__c confAwd : awards){
            if(confAwd.Name != null && confAwd.Name != ''){
                if(awardNames.Contains(confAwd.Name.Trim().toUpperCase())){
                    ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error, 'You are trying to upload multiple awards with same names.Please remove duplicates.'));                
                    return null ;
                }
                awardNames.Add(confAwd.Name.Trim().toUpperCase());                
            }
        }
        
        //Get awards which already exists
        Map<String , Conference_Award__c > existingConfAwards = new Map<String , Conference_Award__c  >();
        for(Conference_Award__c  confAward :[Select id ,Name from Conference_Award__c  where name in : awardNames]){
            existingConfAwards.put(confAward.Name.ToUpperCase() , confAward);
        }
        
        //Check if award already exists then update
        //if do not exists then insert.
        for(Conference_Award__c confAwd : awards){
            if(confAwd.Name != null && confAwd.Name != ''){
                if(existingConfAwards.ContainsKey(confAwd.Name.Trim().toUpperCase())){
                    confAwd.Id = existingConfAwards.get(confAwd.Name.Trim().toUpperCase()).Id;
                }
                awardsToUpsert.Add(confAwd);
            }
        }
        
        upsert awardsToUpsert;
        
        //After upsert show a message to the user.
        ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Info, awardsToUpsert.size() + ' Conference Award has been uploaded successfully.'));                
        awardsUploaded = true;
        return null;
    }
    
    //If user want to upload more then initialize list again and show tha UI.
    public PageReference UplaodMoreAwards(){
        awardsUploaded = false;
        initializeAwards();
        return null;
    }
}