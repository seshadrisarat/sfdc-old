public with sharing class MDVoteAdminController
{
	public MDVote_Question__c currentQuestion {public get; public set; }
    public String newQuestion {public get; public set; }
    public boolean isApexTest = false;
    
    public MDVoteAdminController() 
    {
    	List<MDVote_Question__c> qs=[SELECT Id,name FROM MDVote_Question__c WHERE Is_Current_Question__c=true];
    	
    	if(qs.size()>0)
    		currentQuestion=qs.get(0);
    		
    	/* CWD-- DML not allowed in constructors. derp derp derp
    	List<MDVote_Question__c> qs=[SELECT Id FROM MDVote_Question__c WHERE Is_Current_Question__c=true];
    	
    	if(qs.size()==0)
    	{
    		MDVote_Question__c q=[SELECT Id,Is_Current_Question__c FROM MDVote_Question__c ORDER BY Sort_Order__c,Name LIMIT 1];
    		q.Is_Current_Question__c=true;
    		update q;
    	}
    	*/
    }
    
    public List<MDVote_Question__c> getQuestions() 
    {
        return [SELECT Id, Name FROM MDVote_Question__c ORDER BY Sort_Order__c];
    }
    
    public List<MDVote_Option__c> getDisplayedOptions() 
    {
        return [SELECT Id, Name FROM MDVote_Option__c WHERE Display__c=True AND MDVote_Question__c=:currentQuestion.Id ORDER BY Sort_Order__c];
    }    
    
    public PageReference displayNextOption()
    {
        MDVote_Question__c currentQuestion = [SELECT Id FROM MDVote_Question__c WHERE Is_Current_Question__c=true LIMIT 1];
        List<MDVote_Option__c> optionsToDisplay = [SELECT Id, Name, Display__c FROM MDVote_Option__c WHERE Display__c=False AND MDVote_Question__c=:currentQuestion.Id ORDER BY Sort_Order__c];
        Integer oTDSize = optionsToDisplay.size();
        
        if (oTDSize != 0)
        {
            if (oTDSize == 1)
            {
                if (!isApexTest)  { Pusher myPusher2 = new Pusher(); myPusher2.push('test_channel', 'my_event', 'Hello from Apex'); }
            }
            
            MDVote_Option__c optionToDisplay = optionsToDisplay[0];
            
            if (!isApexTest)  { Pusher myPusher = new Pusher(); myPusher.push('admin_channel', 'update', 'Hello from Apex'); }
            
            optionToDisplay.Display__c = True;
            update optionToDisplay;
        }
        
        return null;
    }
    
    public PageReference displayAllOptions()
    {
    	List<MDVote_Option__c> optionsToDisplay = [SELECT Id, Name, Display__c FROM MDVote_Option__c WHERE Display__c=False AND MDVote_Question__c=:currentQuestion.Id ORDER BY Sort_Order__c];
    	
    	for(MDVote_Option__c o : optionsToDisplay)  o.Display__c=true;
    	
        if (!isApexTest)  {  Pusher myPusher2 = new Pusher(); myPusher2.push('test_channel', 'my_event', 'Hello from Apex'); Pusher myPusher = new Pusher(); myPusher.push('admin_channel', 'update', 'Hello from Apex'); }      	
    	
    	update optionsToDisplay;
    	return null;
    }
    
    public PageReference changeQuestion() 
    {               
    	MDVote_Question__c question = new MDVote_Question__c(Id=newQuestion, Is_Current_Question__c=true);
        List<MDVote_Question__c> existingQuestions = [SELECT Id FROM MDVote_Question__c WHERE Is_Current_Question__c=true];
        
        for(MDVote_Question__c q :existingQuestions)
        {
        	q.Is_Current_Question__c=false;
        }
                
        List<MDVote_Option__c> opts=[SELECT Id,Display__c FROM MDVote_Option__c WHERE MDVote_Question__c=:question.Id];
        
        for(MDVote_Option__c opt : opts)
        {
        	opt.Display__c=false;
        }
        
        if (!isApexTest)  { Pusher myPusher = new Pusher(); myPusher.push('admin_channel', 'update', 'Hello from Apex'); }  
        
        update existingQuestions;
        update question;
        update opts;
             
        return null;
    }
    
    static testMethod void test() 
    {
      	MDVote_Question__c q=new MDVote_Question__c(name='test',Sort_Order__c=0,Is_Current_Question__c=true);
    	insert q;

    	MDVote_Option__c o=new MDVote_Option__c(name='testopt1',MDVote_Question__c=q.Id,Display__c=false);
    	insert o;
    	o=new MDVote_Option__c(name='testopt2',MDVote_Question__c=q.Id,Display__c=true);
    	insert o;
    	    	
		MDVoteAdminController cont=new MDVoteAdminController();
		cont.newQuestion=q.Id;
		cont.isApexTest=true;
		cont.getQuestions();
		cont.displayNextOption();
		cont.displayAllOptions();
		cont.changeQuestion();
		cont.getDisplayedOptions();
    }
}