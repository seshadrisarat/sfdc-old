/**
* @ClassName    : SL_IntranetRecentUpdates 
* @JIRATicket   : Socint-281
* @CreatedOn    : 26/Nov/13
* @ModifiedBy   : Sruti 
* @Description  : This is the controller for SL_IntranetRecentUpdates Component.
*/
public with sharing class SL_IntranetRecentUpdatesController extends ComponentControllerBase 
{
    /* Constructor initialization */
    public SL_IntranetRecentUpdatesController()    
    {
        //Do nothing
    }
    /* End : Constructor initialization */
    
    //Function for implementing base class for this Controller.
    public SL_IntranetRecentUpdates getMyImpl() 
    { 
        return (SL_IntranetRecentUpdates)compImpl; 
    } 
    
    //Function for implementing base class for this Controller.
    public void getRecentUpdates() 
    { 
        getMyImpl().getRecentUpdates();  
    }
    
    //Function for calling show More Records 
    public void showMoreRecords() 
    { 
        getMyImpl().showMoreRecords(); 
    }  
}