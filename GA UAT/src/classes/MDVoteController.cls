public with sharing class MDVoteController 
{   
    public Integer chosenScore {public get; public set; }
    public String chosenOption {public get; public set; }
    public MDVote_Question__c question {public get; private set; }
    public ID currentQuestion {public get; public set; }
    public boolean isApexTest = false;
    public boolean hasVoted {get; set;}    
    public MDVoteController()
    {
      question=[SELECT Id,Name FROM MDVote_Question__c WHERE Is_Current_Question__c=true LIMIT 1];
      currentQuestion=question.Id;
 
    }
    
    public PageReference optionChosen()
    {
        if (!isApexTest) 
        {
            Pusher myPusher = new Pusher();
            myPusher.push('admin_channel', 'voterUpdate', 'Hello from Apex');
        }
        
        MDVote_Answer__c ans = new MDVote_Answer__c(MDVote_Question__c=currentQuestion, MDVote_Option__c=chosenOption, Score__c=chosenScore);
        insert ans;
        return null;
    }
    
    public List<MDVote_Option__c> getOptions()
    {
        
        return [SELECT Id, IsDeleted, Name, MDVote_Question__c, Sort_Order__c, MDVote_Question__r.Name, MDVote_Question__r.Id, MDVote_Question__r.Sort_Order__c from MDVote_Option__c WHERE MDVote_Question__c=:question.Id ORDER BY MDVote_Question__r.Sort_Order__c, Sort_Order__c];
      
    }
    
    static testMethod void test()
    {
        MDVote_Question__c q=new MDVote_Question__c(name='test',Sort_Order__c=0,Is_Current_Question__c=true);
        insert q;
        
        MDVote_Option__c o=new MDVote_Option__c(name='testopt',MDVote_Question__c=q.Id);
        insert o;
        
        MDVoteController cont = new MDVoteController();
        cont.isApexTest=true;
        cont.chosenOption=o.Id;
        cont.chosenScore=1;
        cont.getOptions();
        cont.optionChosen();
    }

}