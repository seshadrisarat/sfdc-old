/**
* \arg \b ClassName      : SL_Paginator
* \arg \b JIRATicket     : WP-99
* \arg \b CreatedOn      : 15/07/2013
* \arg \b ModifiedBy     : -
* \arg \b Description    : This is a paginator class which will handel pagination logic in vf page.
*/
public abstract class SL_Paginator 
{
    public Integer FirstPage 	{get; set;} // first row number in the list.
    public Integer PageSize 	{get; set;} // number of rows per page. //previously currentPageCount
    public Integer LastPage 	{get; set;} // row index of the first record the in the last page
    public Integer page			{get; set;}
    public Integer TotalRows; // total rows in all pages.
   
    /*!
      *  @MethodName: previousPage
      *  @param None: None.
      *  @Description: This method will Navigate to previous page.
    */
    public void previousPage() 
    {
        if(FirstPage - PageSize >= 0) 
        {
            FirstPage -= PageSize ;
           	page--;
        }
       
    }
    
    /*!
      *  @MethodName: lastPage
      *  @param None: None.
      *  @Description: This method will Navigate to last page.
    */
    public void lastPage() 
    {    
        FirstPage = calcLastPage();
    }
    
    /*!
      *  @MethodName: calcLastPage
      *  @param None: None.
      *  @Description: This method will calculate page number of last page.
    */
    private Integer calcLastPage() 
    {
        if(TotalRows >= PageSize ) 
        {
            page=Math.mod(TotalRows, PageSize) == 0 ? TotalRows/PageSize : TotalRows/PageSize + 1;
            return ((page-1)*PageSize);
        }
        else 
        {
            return 0;
        }
    } 
    
    /*!
      *  @MethodName: nextPage
      *  @param None: None.
      *  @Description: This method will navigate to next page.
    */
    public void nextPage() 
    {
        if(TotalRows== 0 || PageSize == 0) return;
        
        if(FirstPage + PageSize < TotalRows) 
        {
            FirstPage += PageSize ;
            page++;
        }
    }
    
    /*!
      *  @MethodName: firstPage
      *  @param None: None.
      *  @Description: This method will navigate to firstPage.
    */
    public void firstPage() 
    {
        page=1;
        FirstPage = 0;
    }
}