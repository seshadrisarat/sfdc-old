/**
* \arg ClassName      : SL_Paginator
* \arg JIRATicket     : OAKHILL-7
* \arg CreatedOn      : 15/OCT/2014
* \arg LastModifiedOn : 15/OCT/2014
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : -
* \arg Description    : This class serves as generic pagination logic.
*/
public abstract class SL_Paginator 
{
	public Integer LastPage 									{get; set;} // Index of the last page
    public Integer page											{get; set;}//variable to hold current page number
    public Integer TotalRows;//variable to hold total no of records returned from SOQL
	public Integer intPageOffset;//variable to hold current page offset
	public Integer PageSize;//variable to hold page size
	
	/*!
      *  @MethodName: anyPage
      *  @param None: None.
      *  @Description: This method will redirect to the page number which is entered.
    */
	public void anyPage() 
	{
		intPageOffset = 0;
		if(page > LastPage)
		{
			intPageOffset+=(PageSize*(LastPage-1));
			page = LastPage;
		}
		else if(page == 0 || page < 0)
				page = 1;
		else
			intPageOffset += (PageSize*(page-1));
	}
	
	/*!
      *  @MethodName: nextPage
      *  @param None: None.
      *  @Description: This method will redirect to the immediate next page from the current page.
    */
	public void nextPage()
	{
		intPageOffset +=PageSize;
		page++; 
	}
	
	/*!
      *  @MethodName: previousPage
      *  @param None: None.
      *  @Description: This method will redirect to the immediate previous page from the current page.
    */
	public void previousPage()
	{
		intPageOffset -= intPageOffset == 0 || intPageOffset < 0 ? 0: PageSize;
		page--;
	}
	
	/*!
      *  @MethodName: firstPage
      *  @param None: None.
      *  @Description: This method will redirect to the first page from the current page.
    */
	public void firstPage()
	{
		intPageOffset = 0;
		page=1;
	}
	
	/*!
      *  @MethodName: lastPage
      *  @param None: None.
      *  @Description: This method will redirect to the last page from the current page.
    */
	public void lastPage()
	{
		intPageOffset += (PageSize * (LastPage - page));
		page = LastPage;
	}
}