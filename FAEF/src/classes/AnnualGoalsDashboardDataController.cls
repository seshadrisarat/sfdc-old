public class AnnualGoalsDashboardDataController 
{
	public ID userId {get;set;}
    public Boolean isManager{get;set;}
    public Decimal fmaTotal{get;set;}
    public Decimal fmvTotal{get;set;}
    public Decimal cscTotal{get;set;}
    public Decimal total {get { return fmaTotal + fmvTotal + cscTotal;}}
    
    public AnnualGoalsDashboardDataController()
    {
    	List<User> users = null; 
    	    	
        this.fmaTotal = 0;
        this.fmvTotal = 0;
        this.cscTotal = 0;
    	this.isManager = AnnualGoalsUtility.Manager();
    	
        users = AnnualGoalsUtility.getUsers();
        
        if(this.isManager && users.size() > 0)
        {
            this.userId = users[0].Id;
        }
        else
        {
            this.userId = UserInfo.getUserId();
        }   	
    }
    
    public List<SelectOption> getUserOptions()
    {
    	return AnnualGoalsUtility.getUserOptions();
    } 
    
    public void userListOnChange()
    {
    	this.fmaTotal = 0;
        this.fmvTotal = 0;
        this.cscTotal = 0;	    	
    }
    
    public List<AnnualGoalsUtility.ScheduleSummary> getScheduleSummaries()
    {
        List<AnnualGoalsUtility.ScheduleSummary> summaries = AnnualGoalsUtility.getUserScheduleSummaries(this.userId);
        
        for(AnnualGoalsUtility.ScheduleSummary s : summaries)
        {
            this.fmaTotal += s.fma;
            this.fmvTotal += s.fmv;
            this.cscTotal += s.csc;
        }
                
        return summaries;
    }
}