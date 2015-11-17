/*
*Class: SL_LIB9_Paginator
*Description: This is the generic class for pagination.
*Copyright 2013 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
public class SL_LIB9_Paginator
{
    /* Start - Variables */
    public  Integer intPageNumber       {get;set;}//To know the current Page no.
    public  Integer intTotalPages       {get;set;}//To know the total page.
    private Integer intPageSize         {get;set;}//Number of records to be displayed in the grid per page.
    public  Boolean isPreviousDisabled  {get;set;}//To know if the Previous link/button is disabled or not.
    public  Boolean isNextDisabled      {get;set;}//To know if the Next link/button is disabled or not.
    private String fieldDefinition      {get;set;}//Can contain Query String or fieldSet(sObject fieldSet) that needs to be queried against the Database.
    private String strObjectName        {get;set;}//API Name of the Sobject we are dealing with the above query string.
    private Map<Integer, Integer> mapPageNumber_StartIndex = new Map<Integer, Integer>();//This map is behaving just like an Index page for a Book.
                                                                                         //Like if you have the Chapter No, it tells you the page no you should be going to.
                                                                                         //Similarly in our case, just pass the Page No and get the exact starting record
                                                                                         //for that page.
    private boolean isValueFromFieldSet ; 
    public Set<Id>  setSelectedIds      {get;set;}//To know the checked items while paginating.
    public List<SobjectWrapper> lstSObjectWrappers {get;set;}   // This will be local list where we will process all data and return back to main List
                                                                //  where ever it is required by get Method.
    public String strOrderByFieldName   {get;set;}//To set the field Name which will be used for Order By clause.
    public String strOrderByDirection   {get;set;}//To set the direction in which we want the query result.
                                                  // Expected Values : ASC DESC
    public String strWhereCondition     {get;set;}//Where clause that will apply in SOQL.
    public boolean isValidParameters;    //Parameter will be used in controller where this class Instantiated.To ensure that parameter which is being passed in constructor is 
                                         //correct or not. 
    private string strFieldsFromFieldSet;  //Comman seprated fieldNames of field which contains by fieldSet. 
    private string prevSortOrderField;    //Contains field Name which has been applied in order by clause in last sorting.
    public List<Sobject> lstSobject;
    public Decimal decLatitude; //This is used to store value of latitude of address
    public Decimal decLongitude;
    
    /* End - Variables */


    /* Start - Wrapper Class
       Purpose: Using this Wrapper class we can keep a track of selected values while paginating through different pages
       It is generic enough to handle any Sobject */
    public class SobjectWrapper
    {
        public SObject sObjectRecord    {   get;set;    }
        public Boolean isChecked        {   get;set;    }
        public Decimal decDistance      {   get;set;    }//This is used to show the distance between the given address and address of providers.
        public SObjectWrapper (SObject sObjectRecord,Boolean isChecked,Decimal decDistance)
        {
           this.sObjectRecord = sObjectRecord;
           this.isChecked = isChecked;
           this.decDistance = decDistance;
        }
    }
    /* End - Wrapper Class */
    
    public SL_LIB9_Paginator(Integer pageSize, List<Sobject> lstSobject, Decimal decLatitude,Decimal decLongitude)
    {
        init();
        this.lstSobject = lstSobject;
        this.intPageSize = pageSize;
        this.decLatitude = decLatitude;
        this.decLongitude = decLongitude;
        
        if(fillMapofPageIndexes() != null)
            this.mapPageNumber_StartIndex = fillMapofPageIndexes();
         getPageRecords();
    }

    /* Start - Method
       Method Name: init
       Arguments: NONE
       Access: PRIVATE
       Return Type: NONE
       Purpose: To initialize all necessary variables.
    */
    private void init()
    {
        //Initializing variables
        setSelectedIds = new Set<Id>();
        lstSObjectWrappers = new List<SobjectWrapper>();
        strFieldsFromFieldSet = '';
        isValidParameters = false;
        lstSobject = new List<Sobject>();
        intPageNumber = 0;
        isPreviousDisabled = true;
        isNextDisabled = true;
        intTotalPages = 0;
    }
    /* End - Method */
    
    /* Start - Method
       Method Name: calculateDistance
       Arguments: latitudes and longitudes of the original and target places.
       Access: PRIVATE
       Return Type: Decimal(Distance between them)
       Purpose: This function is used to calculate the distance between two points.
    */
    private Decimal calculateDistance(Decimal decOriginalLatitude,Decimal decOriginalLongitude,Decimal decTargetLatitude,Decimal decTargetLongitude)
    {
        // convert to radians
        Double dDepartLat = decOriginalLatitude * 3.14159 / 180;
        Double dDepartLong = decOriginalLongitude * 3.14159 / 180;
        Double dArrivalLat = decTargetLatitude * 3.14159 / 180;
        Double dArrivalLong = decTargetLongitude * 3.14159 / 180;
    
        Double dDeltaLong = dArrivalLong - dDepartLong;
        Double dDeltaLat = dArrivalLat - dDepartLat;
    
        // calculate angle using the haversine formula
        Double dHaversineResult = Math.Sin( dDeltaLat / 2 ) * Math.Sin( dDeltaLat / 2 ) 
                                  + Math.Cos( dDepartLat ) * Math.Cos( dArrivalLat ) 
                                    * Math.Sin( dDeltaLong / 2 ) * Math.Sin( dDeltaLong / 2 );
    
        // calculate distance by multiplying arc-tangent by the planet radius in miles
        Double dDistance = 3958.76 * 2 * Math.Atan2( Math.Sqrt( dHaversineResult ), Math.Sqrt( 1 - dHaversineResult ) );
    
        // return estimate
        return dDistance;
    }
    /* End - Method */
    
    /* Start - Method
       Method Name: fillMapofPageIndexes
       Arguments: NONE
       Access: PRIVATE
       Return Type: Map<Integer, Integer>
       Purpose: To maintain a Map storing Page Number as its Key and Start Index as its value. This would be used to derive the desired Page records.
    */
    private Map<Integer, Integer> fillMapofPageIndexes()
    {
        Map<Integer, Integer> mapPageNo_StartIndex = new Map<Integer, Integer>();
        List<Sobject> lstTotalRecords = new List<Sobject>();
        Integer intTotalRecords = 0;
        Integer intStartIndex = 0;
        Integer intTotalNoOfPages = 0;
        try
        {
            
            if(lstSobject != null)
                lstTotalRecords = lstSobject;//Query all the records.
        }
        catch(QueryException ex)
        {
            system.debug('#######################EXCEPTION FOUND#################'+ex.getMessage());
            Apexpages.addMessage(new apexpages.Message(ApexPages.Severity.ERROR, 'Found Some Exception while extracting records from database'));
            return null;
        }
        if(!lstTotalRecords.isEmpty())
        {
            intTotalRecords = lstTotalRecords.size();//Total number of records retrieved.
            intPageNumber = 1;
        }

        if(intPageSize > 0)
            intTotalNoOfPages = Math.mod(intTotalRecords, intPageSize) == 0 ? intTotalRecords / intPageSize : intTotalRecords / intPageSize + 1;

        for(Integer intPageNo = 1; intPageNo <= intTotalNoOfPages; intPageNo++)//Maintain a map which will keep Page No as the Key and Start Index of that page as its Value.
        {
            mapPageNo_StartIndex.put(intPageNo, intStartIndex);
            intStartIndex += intPageSize;
        }
        return mapPageNo_StartIndex;
    }
    /* End - Method */

    /* Start - Method
       Method Name: getPageRecords
       Arguments: NONE
       Access: PRIVATE
       Return Type: void
       Purpose: To retrieve the page records as a list.
    */
    public void getPageRecords()
    {
        List<Sobject> lstSobjectTemp = new List<Sobject>();
        lstSObjectWrappers = new List<SObjectWrapper>();
        Integer intStartIndex = 0;
        Integer intEndIndex = 0;
        Integer intTotalRecord = 0 ;
        Integer EndIndex = 0;

        try
        {
                lstSobjectTemp = lstSobject;
        }
        catch(QueryException ex)
        {
            Apexpages.addMessage(new apexpages.Message(ApexPages.Severity.ERROR, 'Found some exception while extracting records from database'));
            return;
        }
        try
        {
            if( lstSobjectTemp!=null && !lstSobjectTemp.isEmpty())
            {
                if(!lstSobjectTemp.isEmpty())
                    intTotalRecord = lstSobject.size();
                    
                if(intPageSize > 0)
                    intTotalPages = Math.mod(intTotalRecord, intPageSize) == 0 ? intTotalRecord / intPageSize : intTotalRecord / intPageSize + 1;//Total number of pages.
                    
                intStartIndex = mapPageNumber_StartIndex.get(intPageNumber);//Retrieve the Start index for the related Page No.
                
                if(intStartIndex != null)
                    EndIndex = intStartIndex + intPageSize;//Based on the Start Index and Page Size decide the End index.
                
                Integer offset = 0;
                //Managing offset. 
                if(intTotalRecord < EndIndex)
                    offset = Math.mod(intTotalRecord, intPageSize); 
                else
                    offset = intPageSize ;
            
                intEndIndex = intStartIndex + offset ;
                for(Integer index = intStartIndex; index < intEndIndex; index++)//Now build the list to be shown as the current selected page.
                {
                    if(decLatitude!=null && decLongitude!=null && lstSobjectTemp[index].get('Location__Latitude__s')!=null && lstSobjectTemp[index].get('Location__Longitude__s')!=null)
                    {
                        Decimal decCalculatedDistance = calculateDistance(decLatitude, decLongitude, (Decimal)lstSobjectTemp[index].get('Location__Latitude__s'), (Decimal)lstSobjectTemp[index].get('Location__Longitude__s'));
                        lstSObjectWrappers.add(new SobjectWrapper(lstSobjectTemp[index],false,decCalculatedDistance.setScale(2)));
                    }
                    else
                        lstSObjectWrappers.add(new SobjectWrapper(lstSobjectTemp[index],false,0.0));
                }
                
                //Decide whether Previous link/button should be disabled or not.    
                isPreviousDisabled = (intPageNumber == 1) ? true : false;   
                
                //Decide whether Previous link/button should be disabled or not.    
                isNextDisabled  = (intPageNumber == intTotalPages) ? true : false;
                
                lstSobject = new List<Sobject>();
                    
            }
        }
        catch(Exception ex)
        {
            System.debug('===========Exception========='+ex.getLineNumber()+' '+ex);
            
        }
    }
    /* End - Method */

    /* Start - Method
       Method Name: getPage
       Arguments: paramPageNo - Desired page no for which we need to fetch records for.
       Access: PUBLIC
       Return Type: void
       Purpose: To retrieve the desired page records as a list based on the Page No selected.
    */
    public void goToSpecificPage(Integer paramPageNo)
    {

        intPageNumber = paramPageNo;
        getPageRecords();
    }
    /* End - Method */

    /* Start - Method
       Method Name: gotoNextPage
       Arguments: NONE
       Access: PUBLIC
       Return Type: void
       Purpose: To retrieve the current page records as a list based on the Next Page No.
    */
    public void gotoNextPage()
    {
        intPageNumber += 1;//Increase the Page no by 1.
        goToSpecificPage(intPageNumber);//Get the above page records.
    }
    /* End - Method */

    /* Start - Method
       Method Name: gotoPrevPage
       Arguments: NONE
       Access: PUBLIC
       Return Type: Void
       Purpose: To retrieve the previous page records as a list and updating the Page number.
    */
    public void gotoPrevPage()
    {
        intPageNumber -= 1;//Reduce the Page no by 1.
        goToSpecificPage(intPageNumber);//Get the above page records.
    }
    /* End - Method */

    /* Start - Method
       Method Name: gotoFirstPage
       Arguments: NONE
       Access: PUBLIC
       Return Type: Void
       Purpose: To retrieve the first page records as a list.
    */
    public void gotoFirstPage()
    {
        goToSpecificPage(1);
    }
    /* End - Method */

    /* Start - Method
       Method Name: gotoLastPage
       Arguments: NONE
       Access: PUBLIC
       Return Type: void
       Purpose: To retrieve the last page records as a list.
    */
    public void gotoLastPage()
    {
        goToSpecificPage(intTotalPages);
    }
    /* End - Method */

    
    static Account objTestAccount1;
    static Account objTestAccount2;
    static Account objTestAccount3;
    
    // Create records for Test Coverage
    private static void createTestRecords()
    {
        objTestAccount1 = new Account(Name = 'Test Account 1');
        objTestAccount2 = new Account(Name = 'Test Account 2');
        objTestAccount3 = new Account(Name = 'Test Account 3');
        List<Account> lstTestAccount = new List<Account>{objTestAccount1,objTestAccount2,objTestAccount3};
        
        for(Integer i=0; i<50;i++)
            lstTestAccount.add(new Account(Name='Account'+i));
        insert lstTestAccount;
    }

    // How to pass values for Constructor
    private static testMethod void SL_LIB9_Paginator()
    {
        createTestRecords();

        String paramCSVFields = 'Id,Name';
        Integer paramPageSize = 1;
        String paramObjectName = 'Account';
        String paramWhereCondition = '';
        //string fieldset = '';
        List<Sobject> lst = [SELECT Id FROM Account ];
        SL_LIB9_Paginator obj = new SL_LIB9_Paginator(2,lst,null,null);
        obj.gotoFirstPage();
        obj.gotoNextPage();
        obj.gotoPrevPage();
        obj.gotoLastPage();
    }

}