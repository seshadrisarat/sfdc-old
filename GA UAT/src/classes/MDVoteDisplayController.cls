public with sharing class MDVoteDisplayController 
{ 
    public String chosenOption {public get; public set; }
    public MDVote_Question__c question {public get; private set; }
    public Boolean renderWelcome {public get; private set; }
    public String imageURL {public get; private set; }
    
    public MDVoteDisplayController()
    {
        question=[SELECT Id, Name, Sort_Order__c FROM MDVote_Question__c WHERE Is_Current_Question__c=true LIMIT 1];
        
        if (question.Sort_Order__c == 0) renderWelcome = true;
        
        GAPS_Settings__c settings = GAPS_Settings__c.getInstance();
        
        if (settings.Is_Test_Mode__c) imageURL = 'https://c.cs10.content.force.com';
        else imageURL = 'https://c.na11.content.force.com';

    }
    
    public String getWelcomeMessage()
    {
    	MDVote_Question__c q=[SELECT Id, Name, Sort_Order__c FROM MDVote_Question__c WHERE Sort_order__c=0 LIMIT 1];
    	return q.Name;
    }
    
    public List<MDVote_MD__c> getMDPhotoURLs()
    {
        List<MDVote_MD__c> MDs = [SELECT Name, User__r.Name, User__r.FullPhotoUrl FROM MDVote_MD__c WHERE MDVote_Question__c=:question.Id];
        return MDs;
    }
    
    public List<MDVote_Option__c> getOptions()
    {
        return [SELECT Id, IsDeleted, Name, Score_Average__c, Answer_Count__c, MDVote_Question__c, Sort_Order__c, MDVote_Question__r.Name, MDVote_Question__r.Id, MDVote_Question__r.Sort_Order__c from MDVote_Option__c WHERE MDVote_Question__c=:question.Id AND Display__c=True ORDER BY Score_Average__c DESC, Sort_Order__c ASC];
    }
    
    
    static testMethod void test()
    {
    	MDVote_Question__c q=new MDVote_Question__c(name='test',Sort_Order__c=0,Is_Current_Question__c=true);
    	insert q;
    	
    	MDVote_MD__c md=new MDVote_MD__c(User__c=UserInfo.getUserId(),MDVote_Question__c=q.Id);
    	insert md;
    	
    	
		MDVoteDisplayController cont=new MDVoteDisplayController();
		cont.getMDPhotoURLs();
		cont.getOptions();
    }   
}