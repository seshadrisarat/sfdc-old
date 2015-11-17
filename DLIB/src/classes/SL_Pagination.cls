public abstract class SL_Pagination
{
	
	// for pagination
	public Integer pageSize    {get;set;}
	public Integer currentPage    {get;set;}
	public String currentPageInfo    {get;set;}
	public Integer pageNumber		{get;set;}
     
	// for disabling pagination links
	public Boolean showPrevious    {get;set;}
	public Boolean showNext    {get;set;}
      
	public Integer totalRecords;
	public String strPages      {get;set;}
	
	/* Start - Constructor*/
	public SL_Pagination()
	{
		currentPage = 0;
		pageSize = 10;
		pageNumber = 1;
		showPrevious = false;
		
		
		if(totalRecords > pageSize)
		    showNext = true;
		else
		    showNext = false;
	}
	
	public void goToPage()
	{
        currentPage = (Integer.valueOf(strPages) - 1) * pageSize;
        pageNumber = Integer.valueOf(strPages);
         //pageNumber++;
        enableDisablePaginationLinks();  
	}
	 public void showFirst()
     {
         currentPage = 0;
         pageNumber = 1;
         enableDisablePaginationLinks();
     }
	public void showPrevious()
	{
		currentPage = currentPage - pageSize;
		pageNumber--;
		enableDisablePaginationLinks();        
	}
     
     public void showNext()
     {
         currentPage = currentPage + pageSize;
         pageNumber++;
         enableDisablePaginationLinks();
     }
     
     
    public void showLast()
	{
		currentPage = (Math.mod(totalRecords, pageSize) == 0) ? totalRecords - pageSize : (totalRecords / pageSize) * pageSize;
		pageNumber = (Math.mod(totalRecords, pageSize) == 0 ? totalRecords/pageSize : (totalRecords/pageSize) + 1);
		enableDisablePaginationLinks();
    }
	
	public void enableDisablePaginationLinks()
	{
		if(currentPage == 0 )
			showPrevious = false;
		else
			showPrevious = true;
		
		if(currentPage !=0 )
		{
		if((totalRecords - pageSize) <= currentPage)
			showNext = false;
		else
			showNext = true;
		}
		if(currentPage == 0 )
			showNext = true;
		
		if(pageSize>=totalRecords)
		{
            showPrevious = false;
            showNext = false;
		}
			
		currentPageInfo = 'Showing Page ' + pageNumber +   ' of ' + (Math.mod(totalRecords, pageSize) == 0 ? totalRecords/pageSize : (totalRecords/pageSize) + 1);
     }
}