/**
* \arg \b ClassName      : SL_Paginator
* \arg \b JIRATicket     : THOR-16
* \arg \b CreatedOn      : 5/08/2014
* \arg \b ModifiedBy     : -
* \arg \b Description    : This is a paginator class which will handel pagination logic in vf TotalRowsForRecipient.
*/
public abstract class SL_Paginator 
{
    public Integer FirstPageForRecipient    {get; set;} // first row number in the list.
    public Integer PageSizeForRecipient     {get; set;} // number of rows per page. //previously currentPageCount
    public Integer LastPageForRecipient     {get; set;} // row index of the first record the in the last page
    public Integer pageForRecipient         {get; set;}
    public Integer TotalRowsForRecipient; // total rows in all pages.
    public Integer noOfPagesForRecipient    {get;set;}
    
    public Integer FirstPageForApartment    {get; set;} // first row number in the list.
    public Integer PageSizeForApartment     {get; set;} // number of rows per page. //previously currentPageCount
    public Integer LastPageForApartment     {get; set;} // row index of the first record the in the last page
    public Integer pageForApartment         {get; set;}
    public Integer TotalRowsForApartment; // total rows in all pages.
    public Integer noOfPagesForApartment    {get;set;}
    
    /*!
      *  @MethodName: previousPageForRecipient
      *  @param None: None.
      *  @Description: This method will Navigate to previous page.
    */
    public void previousPageForRecipient() 
    {
        if(FirstPageForRecipient - PageSizeForRecipient >= 0) 
        {
            FirstPageForRecipient -= PageSizeForRecipient ;
            pageForRecipient--;
        }
       
    }
    
    /*!
      *  @MethodName: nextPageForRecipient
      *  @param None: None.
      *  @Description: This method will navigate to next page.
    */
    public void nextPageForRecipient() 
    {
        if(TotalRowsForRecipient== 0 || PageSizeForRecipient == 0) return;
        
        if(FirstPageForRecipient + PageSizeForRecipient < TotalRowsForRecipient) 
        {
            FirstPageForRecipient += PageSizeForRecipient ;
            pageForRecipient++;
        }
    }
    
    /*!
      *  @MethodName: previousPageForApartment
      *  @param None: None.
      *  @Description: This method will Navigate to previous page.
    */
    public void previousPageForApartment() 
    {
        if(FirstPageForApartment - PageSizeForApartment >= 0) 
        {
            FirstPageForApartment -= PageSizeForApartment ;
            pageForApartment--;
        }
    }
    
    /*!
      *  @MethodName: nextPageForApartment
      *  @param None: None.
      *  @Description: This method will navigate to next page.
    */
    public void nextPageForApartment() 
    {
        if(TotalRowsForApartment== 0 || PageSizeForApartment == 0) return;
        
        if(FirstPageForApartment + PageSizeForApartment < TotalRowsForApartment) 
        {
            FirstPageForApartment += PageSizeForApartment ;
            pageForApartment++;
        }
    }
}