/**
* \arg \b ClassName      : SL_Paginator
* \arg \b JIRATicket     : 
* \arg \b CreatedOn      : 
* \arg \b ModifiedBy     : 
* \arg \b Description    : This is a paginator class which will handle pagination logic in vf page.
*/
public abstract class SL_Paginator 
{
    public Integer FirstPage    {get; set;} // first row number in the list.
    public Integer PageSize     {get; set;} // number of rows per page. //previously currentPageCount
    public Integer LastPage     {get; set;} // row index of the first record the in the last page
    public Integer page         {get; set;}
    public Integer TotalRows; 				// total rows in all pages.
    public Integer noOfPages    {get;set;}
   
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
}