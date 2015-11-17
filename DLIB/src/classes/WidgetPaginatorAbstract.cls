global abstract with sharing class WidgetPaginatorAbstract extends WidgetAbstract implements IPaginator
{
    /* Start of vars */
    
    global Integer startIndex {get;set;} 
    global Integer rowsPerPage {get;set;}
    
    global Integer totalPages {get;set;}
    global Integer pageNo {get;set;}
    
    global Integer totalRecords {get;set;}
    
    /* End of vars */
    
    
    /*  Name:  firstRecords()
        Param: None
        Description: To get the records of first page
    */
    global void firstRecords()
    {
        startIndex = 0;
        pageNo = 1;
    }
    /* End : firstRecords Methods */ 
    
    
    /*  Name: lastRecords
        Param: None
        Description: To get the records of last page
    */
    global void lastRecords()
    {
        startIndex = (totalPages - 1) * rowsPerPage;
        pageNo = totalPages;
    }
    /* End : lastRecords Methods */ 
    
    
    /*  Name: nextRecords
        Param: None
        description: To get the records of Next page
    */
    global void nextRecords()
    {
        if(startIndex + rowsPerPage < totalRecords)
        {
            startIndex += rowsPerPage;
            pageNo += 1;  
        }
    }
    /* End : nextRecords Methods */
    
    
    /*  Name: prevRecords
        Param: None
        Description: To get the records of Previous page  
    */
    global void prevRecords()
    {
        if(startIndex - rowsPerPage >= 0)
        {
            startIndex -= rowsPerPage;
            pageNo -= 1;
        }
    }
    /* End : prevRecords Methods */
    
    
    /*  Name: goToPage
        param: None
        Description: To get the records of particulat page  
    */
    global void goToPage()
    {
        Integer pageNumber = Integer.valueOf(Apexpages.currentPage().getparameters().get('pageNo')); 
        
        pageNo = pageNumber;
        startIndex = rowsPerPage * (pageNumber - 1);
    }
    /* End : goToPage Methods */

}