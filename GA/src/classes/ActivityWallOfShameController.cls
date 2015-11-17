public class ActivityWallOfShameController 
{
    public Datetime dtConstructed { public get; public set; }
    public Date dtStart { public get; public set; }
    public Date dtEnd { public get; public set; }
    public List<String> laggingTeams { public get; private set; }
    private List<String> lTeams;
    private Map<String,Date> laggers;
    
    public ActivityWallOfShameController()
    {
        dtConstructed=Datetime.now();
        lTeams=new List<String>();
        laggers=new Map<String,Date>();
        
        if(dtStart==null)
            dtStart=Date.today().addDays(-14);
    
        if(dtEnd==null)
            dtEnd=Date.today();
    
        Schema.DescribeFieldResult fieldResult=Account.Industry.getDescribe();
        
        for(Schema.PickListEntry f : fieldResult.getPicklistValues())
        {
            if(f.getValue()!='Other')
                lTeams.add(f.getValue());            
        }
        
        updateLaggingTeams();
    }
    
    public PageReference updateLaggingTeams()
    {
        List<AggregateResult> lResults=[SELECT Industry FROM Account WHERE Last_Modified_Date__c>=:dtStart AND Last_Modified_Date__c<=:dtEnd AND Industry!='' AND Industry!='Other' GROUP BY Industry];
        laggingTeams=new List<String>();
        Map<String,Integer> mTeams=new Map<String, Integer>();
        
        for(String str : lTeams)
            mTeams.put(str,0);
        
        for(AggregateResult ar : lResults)
        {
                System.debug('getting count for '+ar.get('Industry'));
                Integer i=mTeams.get((String)ar.get('Industry'));
                
                if(i!=null)
                        mTeams.put((String)ar.get('Industry'),i+1 );
        }
        
        for(String str : mTeams.keySet())
        {
            if(mTeams.get(str)==0)
                laggingTeams.add(str);
        }
        
        laggingTeams.sort();
        getLaggers();
        return null;
    }
    
    public Map<String,Date> getLaggers()
    {
        laggers=new Map<String,Date>();
        
        List<AggregateResult> lResults=[SELECT Industry,Max(Last_Modified_Date__c) LMD FROM Account WHERE Industry IN :laggingTeams GROUP BY Industry ORDER BY Max(Last_Modified_Date__c) DESC];
        
        for(AggregateResult ar : lResults)
            laggers.put( (String)ar.get('Industry'), (Date)ar.get('LMD') );
            
        return laggers;
    }
    
    public integer getLaggersCount()
    {
        return laggers.size();
    }

    public integer getNumberOfDays()
    {
        return dtStart.daysBetween(dtEnd);
    }
    
    public static testMethod void test()
    {
        ActivityWallOfShameController cont=new ActivityWallOfShameController();
        cont.getNumberOfDays();
        cont.getLaggers();
    }
}