public with sharing class Pages 
{
	private ApexPages.StandardSetController sscObject;
	private String query = '';
	private Integer pageSize;
	public Pages(String query, Integer PageSize)
    {
    	this.query = query;
    	if(pageSize > 0) this.pageSize = PageSize;
    	else this.pageSize = 10;
    	system.debug('this.pageSize ------------------------>'+this.pageSize);
    	this.init();
    	
    }
    
    
    
    /// standart paging	
	private void init()
	{
	    if (this.query!= '' && this.pageSize > 0)  
	    {
	    	sscObject = new ApexPages.StandardSetController(Database.getQueryLocator(this.query));
	    	sscObject.setPageSize(this.pageSize);
	    }
	}
	
	public void setObjPageSize(Integer pageSize)
	{
	   sscObject.setPageSize(pageSize);
    }
     
    public Integer getObjPageSize() 
    {
	    return sscObject.getPageSize();
    } 
    public void setObjPageNumber(Integer PageNumber) 
    {
	    if (PageNumber > 0)sscObject.setPageNumber(PageNumber);
	    else sscObject.setPageNumber(1);
    }
    public Integer getObjPageNumber() 
    {
	    return sscObject.getPageNumber();
    }
    public List<sObject> getList()
    {
    	//this.init();
    	return (List<sObject>) sscObject.getRecords();
    }

    public Integer getObjCount()
    {
        return getList().size();
    }
    
  
    
    public Integer getObjResultSize() 
    {
	    return sscObject.getResultSize();
    }
    

    public Boolean hasObjNext 
    {
        get {return sscObject.getHasNext();}
	    set;
    }
	 
    public Boolean hasObjPrevious 
    {
	    get {return sscObject.getHasPrevious();}
        set;
    }
}