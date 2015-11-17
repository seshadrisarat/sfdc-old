/**
*  ClassName      : SL_CustomNoteVFController 
*  JIRATicket     : HIL-33
*  CreatedOn      : 23/SEP/2015
*  ModifiedBy     : Sanath
*  Description    : This class serves as controller for inline VF pages namely SL_CustomNoteVFHousehold, 
*                   SL_CustomNoteVFforClient,  SL_CustomNoteVFforOpenTasks_Client, SL_CustomNoteVFforClosedTasks_Client,
*                   SL_CustomNoteVFforOpenTasks_Household, SL_CustomNoteVFforClosedTasks_Household.
*/

public class SL_CustomNoteVFController 
{
     /* Start - Variables */
    public List<Note__c> listNotes        {get;set;}
    public Boolean renderPageBlock        {get;set;}
    private integer index = 0;
    private integer blockSize {get{
        try{
        Integer int_blk = (Integer)SL_CustomNoteVFBlockSize__c.getInstance('BlockSize').BlockSize__c;
        if(int_blk > 0)
            return (Integer)SL_CustomNoteVFBlockSize__c.getInstance('BlockSize').BlockSize__c;    
        else 
            return 10;
        } 
        catch(Exception e){
            return 10;
        }    
    }}
   
    @TestVisible private Integer size = 0;
    private Boolean checkLast; 
    
    private Boolean checkClientTypeNotTask;
    private Boolean checkClientStatusEqualsOpen;  
    private Boolean checkClientStatusEqualsClosed;
    private Boolean checkHouseholdTypeNotTask;
    private Boolean checkHouseholdStatusEqualsOpen;
    private Boolean checkHouseholdStatusEqualsClosed;
    
    private Relationship_Group__c objHousehold;
    private Account objAccount;
     /* End - Variables */
     
    /* Start - Constructor */
     public SL_CustomNoteVFController(ApexPages.StandardController stdController) 
     {
        
        if(((Id)stdController.getId()).getSObjectType() == Relationship_Group__c.SObjectType)
        {
            this.objHousehold = (Relationship_Group__c)stdController.getRecord();
        }
        else if(((Id)stdController.getId()).getSObjectType() == Account.SObjectType)
        {
            this.objAccount = (Account)stdController.getRecord();
        } 
        else 
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Invalid ID.');
            ApexPages.addMessage(myMsg);
            renderPageBlock = false;
        }
        listNotes = new List<Note__c>();
        checkLast = false;
        setBooleans();
     }
    /* End - Constructor */
      
     /*
        * MethodName        : setBooleans
        * param             : -
        * Description       : This function will be called to initialize all the boolean variables in order to control pagination for respective pages and 
                              different methods.
    */
    private void setBooleans()
    {
        checkClientTypeNotTask = false;
        checkClientStatusEqualsOpen = false;
        checkClientStatusEqualsClosed = false;
        checkHouseholdTypeNotTask = false;
        checkHouseholdStatusEqualsOpen = false;
        checkHouseholdStatusEqualsClosed = false;
    }
   
    /*
        * MethodName        : fetchAllNonTaskTypeNotes
        * param             : -
        * Description       : This function will query all the Note_Joiner__c records for the respective detail page record Id where Type__c != 'Task'.
    */
    public PageReference fetchAllNonTaskTypeNotes()
    {
        setBooleans();
        checkHouseholdTypeNotTask = true;
        
        listNotes = new List<Note__c>();
        set<id> setNoteIds = new set<id>();
        try{
            for(Note_Joiner__c objNoteJoiner : [Select Id,
                                                       Note__c, 
                                                       Type__c,
                                                       Relationship_Group__c 
                                                from   Note_Joiner__c 
                                                where  Type__c != 'Task' 
                                                AND    Relationship_Group__c =:this.objHousehold.Id
                                                ])  
            {
                setNoteIds.add(objNoteJoiner.Note__c);
            }
            
            for(Note__c objNote: [Select    Id,   
                                            Type__c, 
                                            Subject_Text__c,
                                            Relationship_Group__c,
                                            Status__c,
                                            Description__c 
                                  FROM Note__c 
                                  where Id IN:setNoteIds
                                  LIMIT :blockSize OFFSET :index
                                    ])
            {
                listNotes.add(objNote);
            }
            
          
            size = [Select  count()
                        FROM Note__c 
                        where Id IN:setNoteIds];
                
              
                
            if(size == 0)
                {
                    Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,''+'No records to Display'));
                    renderPageBlock = false;
                }
            else
                renderPageBlock = true;
                                            
        }
        catch (QueryException e){
            
            ApexPages.addMessages(e);   
            return null;
            
        }  
        return null;
    }
    
    /*
        * MethodName        : fetchAllOpenTasksForHousehold
        * param             : -
        * Description       : This function will query all the Note_Joiner__c records for the respective detail page record Id where Type__c = 'Task'
                              and Status__c = 'Open' for the Note.
    */ 
    public PageReference fetchAllOpenTasksForHousehold()
    {
        setBooleans();
        checkHouseholdStatusEqualsOpen = true;
        
        listNotes = new List<Note__c>();
        set<id> setNoteIds = new set<id>();
        try{
            for(Note_Joiner__c objNoteJoiner : [Select Id,
                                                       Note__c, 
                                                       Type__c,
                                                       Relationship_Group__c 
                                                from   Note_Joiner__c 
                                                where  Type__c = 'Task' 
                                                AND    Relationship_Group__c =:this.objHousehold.Id
                                                ])  
            {
                setNoteIds.add(objNoteJoiner.Note__c);
            }
            
            for(Note__c objNote: [Select    Id, 
                                            Type__c, 
                                            Subject_Text__c,
                                            Relationship_Group__c,
                                            Status__c,
                                            Description__c 
                                  FROM Note__c 
                                  where Id IN:setNoteIds
                                  AND Status__c='Open'
                                  LIMIT :blockSize OFFSET :index])
            {
                listNotes.add(objNote);
            }
            size = [Select count()
                        FROM Note__c 
                        where Id IN:setNoteIds
                            AND Status__c='Open'];
            if(size == 0)
            {
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,''+'No records to Display'));
                renderPageBlock = false;
            }
            else
                renderPageBlock = true;
        }
        catch (QueryException e)
        {
            ApexPages.addMessages(e);   
            return null; 
        }  
        return null;
    }
    
    /*
        * MethodName        : fetchAllClosedTasksForHousehold
        * param             : -
        * Description       : This function will query all the Note_Joiner__c records for the respective detail page record Id where Type__c = 'Task'
                              and Status__c = 'Closed' for the Note.
    */ 
    public PageReference fetchAllClosedTasksForHousehold()
    {
        setBooleans();
        checkHouseholdStatusEqualsClosed = true;
        
        listNotes = new List<Note__c>();
        set<id> setNoteIds = new set<id>();
        try{
            for(Note_Joiner__c objNoteJoiner : [Select Id,
                                                       Note__c, 
                                                       Type__c,
                                                       Relationship_Group__c 
                                                from   Note_Joiner__c 
                                                where  Type__c = 'Task' 
                                                AND    Relationship_Group__c =:this.objHousehold.Id
                                                ])  
            {
                setNoteIds.add(objNoteJoiner.Note__c);
            }
            
              
            for(Note__c objNote: [Select    Id, 
                                            Type__c, 
                                            Subject_Text__c,
                                            Relationship_Group__c,
                                            Status__c,
                                            Description__c 
                                  FROM Note__c 
                                  where Id IN:setNoteIds
                                  AND Status__c='Closed'
                                  LIMIT :blockSize OFFSET :index])
            {
                listNotes.add(objNote);
            }
            size = [Select count() from Note__c
                        where Id IN:setNoteIds
                            AND Status__c='Closed'];
                
            if(size == 0)
            {
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,''+'No records to Display'));
                renderPageBlock = false;
            }
            else
                renderPageBlock = true;
        }
        catch (QueryException e)
        {
            ApexPages.addMessages(e);  
            return null;
        }  
        return null;
    }
    
     /*
        * MethodName        : fetchAllNonTaskTypeNotesForClient
        * param             : -
        * Description       : This function will query all the Note_Joiner__c records for the respective detail page record Id where Type__c != 'Task'.
    */    
    public PageReference fetchAllNonTaskTypeNotesForClient()
    {
        setBooleans();
        checkClientTypeNotTask = true;
        
        set<id> setNoteIds = new set<id>();
        listNotes = new List<Note__c>();
        
        try{
            for(Note_Joiner__c objNoteJoiner : [Select Id,
                                                       Note__c, 
                                                       Type__c,
                                                       Client_Prospect__c 
                                                from   Note_Joiner__c 
                                                where  Type__c != 'Task' 
                                                AND    Client_Prospect__c =:this.objAccount.Id
                                                ])  
            {
                setNoteIds.add(objNoteJoiner.Note__c);
            }
            
            for(Note__c objNote: [Select    Id, 
                                            Type__c, 
                                            Subject_Text__c,  
                                            Relationship_Group__c,
                                            Status__c,
                                            Description__c
                                   FROM Note__c 
                                   where Id IN:setNoteIds
                                   LIMIT :blockSize OFFSET :index])
            {
                listNotes.add(objNote);
            }
            size = [Select  count()
                    FROM Note__c 
                    where Id IN:setNoteIds];
                
        if(size == 0)
        {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,''+'No records to Display'));
            renderPageBlock = false;
        }
        else
            renderPageBlock = true;
        }
        catch (QueryException e){
            
            ApexPages.addMessages(e);   
            return null;
            
        }  
        return null;
    }
    
     /*
        * MethodName        : fetchAllOpenTasksForClient
        * param             : -
        * Description       : This function will query all the Note_Joiner__c records for the respective detail page record Id where Type__c = 'Task'
                              and Status__c = 'Open' for the Note.
    */ 
    public PageReference fetchAllOpenTasksForClient()
    { 
        setBooleans();
        checkClientStatusEqualsOpen = true;
        
        listNotes = new List<Note__c>();
        set<id> setNoteIds = new set<id>();
        
        try{
            for(Note_Joiner__c objNoteJoiner : [Select Id,
                                                       Note__c, 
                                                       Type__c,
                                                       Client_Prospect__c 
                                                from   Note_Joiner__c 
                                                where  Type__c = 'Task' 
                                                AND    Client_Prospect__c =:this.objAccount.Id
                                                ])  
            {
                setNoteIds.add(objNoteJoiner.Note__c);
            }
            
            for(Note__c objNote: [Select    Id, 
                                            Type__c, 
                                            Subject_Text__c,
                                            Relationship_Group__c,
                                            Status__c,
                                            Description__c
                                   FROM Note__c 
                                   where Id IN:setNoteIds
                                   AND Status__c='Open'
                                   LIMIT :blockSize OFFSET :index])
            {
                listNotes.add(objNote);
            }
              size = [Select  count() from Note__c
                            where Id IN:setNoteIds
                            AND Status__c='Open'];
              
            if(size == 0)
            {
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,''+'No records to Display'));
                renderPageBlock = false;
            }
            else
                renderPageBlock = true;
        }
        catch (QueryException e){
            
            ApexPages.addMessages(e);   
            return null;
            
        }  
        return null;
    }
    
     /*
        * MethodName        : fetchAllClosedTasksForClient
        * param             : -
        * Description       : This function will query all the Note_Joiner__c records for the respective detail page record Id where Type__c = 'Task'
                              and Status__c = 'Closed' for the Note.
    */ 
    public PageReference fetchAllClosedTasksForClient()
    {
        setBooleans();
        checkClientStatusEqualsClosed = true;
        
        listNotes = new List<Note__c>();
        set<id> setNoteIds = new set<id>();
        
        try{
            for(Note_Joiner__c objNoteJoiner : [Select Id,
                                                       Note__c, 
                                                       Type__c,
                                                       Client_Prospect__c 
                                                from   Note_Joiner__c 
                                                where  Type__c = 'Task' 
                                                AND    Client_Prospect__c =:this.objAccount.Id
                                                ])  
            {
                setNoteIds.add(objNoteJoiner.Note__c);
            }
            
            for(Note__c objNote: [Select    Id, 
                                            Type__c, 
                                            Subject_Text__c,
                                            Relationship_Group__c,
                                            Status__c,
                                            Description__c
                                   FROM Note__c 
                                   where Id IN:setNoteIds
                                   AND Status__c='Closed'
                                   LIMIT :blockSize OFFSET :index])
            {
                listNotes.add(objNote);
            }
            size = [Select  count()
                        FROM Note__c 
                        where Id IN:setNoteIds
                        AND Status__c='Closed'];
                
      
            if(size == 0)
            {
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,''+'No records to Display'));
                renderPageBlock = false;
            }
            else
                renderPageBlock = true;
        }
        catch (QueryException e){
            ApexPages.addMessages(e);   
            return null;
        }  
        return null;
    }
   
    /*
        * MethodName        : beginning
        * param             : -
        * Description       : This function will query all the Note_Joiner__c records for the respective detail page record Id and fetch records for the 
                              starting page of total pages.
    */ 
    public void beginning()
    {   
         index = 0;
         
         if(this.objAccount != null)
         {
             if(checkClientTypeNotTask)
                fetchAllNonTaskTypeNotesForClient();
             else if(checkClientStatusEqualsOpen)
                fetchAllOpenTasksForClient();
             else if(checkClientStatusEqualsClosed)
                fetchAllClosedTasksForClient();
         }
         
         if(this.objHousehold != null)
         {
             if(checkHouseholdTypeNotTask)
                fetchAllNonTaskTypeNotes();
             else if(checkHouseholdStatusEqualsOpen)
                fetchAllOpenTasksForHousehold();
             else if(checkHouseholdStatusEqualsClosed)
                fetchAllClosedTasksForHousehold();
         }
            
    }
    
     /*
        * MethodName        : previous
        * param             : -
        * Description       : This function will query all the Note_Joiner__c records for the respective detail page record Id and fetch records for the 
                              previous page of total pages.
    */ 
    public void previous()
    {
        index = index - blockSize;
            
        if(this.objAccount != null)
         {
             if(checkClientTypeNotTask)
                fetchAllNonTaskTypeNotesForClient();
             else if(checkClientStatusEqualsOpen)
                fetchAllOpenTasksForClient();
             else if(checkClientStatusEqualsClosed)
                fetchAllClosedTasksForClient();
         }
         
         if(this.objHousehold != null)
         {
             if(checkHouseholdTypeNotTask)
                fetchAllNonTaskTypeNotes();
             else if(checkHouseholdStatusEqualsOpen)
                fetchAllOpenTasksForHousehold();
             else if(checkHouseholdStatusEqualsClosed )
                fetchAllClosedTasksForHousehold();
         }
    }  
    
     /*
        * MethodName        : next
        * param             : -
        * Description       : This function will query all the Note_Joiner__c records for the respective detail page record Id and fetch records for the 
                              next page of total pages.
    */ 
    public void next()
    {
        checkLast = false;
        index = index + blockSize;
        if(index == size || index+blockSize >= size)  
        {
            checkLast = true;
        }
        
        if(this.objAccount != null)
         {
             if(checkClientTypeNotTask)
                fetchAllNonTaskTypeNotesForClient();
             else if(checkClientStatusEqualsOpen)
                fetchAllOpenTasksForClient();
             else if(checkClientStatusEqualsClosed)
                fetchAllClosedTasksForClient();
         }
         
         if(this.objHousehold != null)
         {
             if(checkHouseholdTypeNotTask)
                fetchAllNonTaskTypeNotes();
             else if(checkHouseholdStatusEqualsOpen)
                fetchAllOpenTasksForHousehold();
             else if(checkHouseholdStatusEqualsClosed)
                fetchAllClosedTasksForHousehold();
         }
            
    }

     /*
        * MethodName        : end
        * param             : -
        * Description       : This function will query all the Note_Joiner__c records for the respective detail page record Id and fetch records for the 
                              end page of total pages.
    */    
    public void end()
    {
        Integer TotalPages = (Integer)Math.ceil(size/(Double)blockSize);
        if((TotalPages * blockSize) >= size)
        {
            index = (TotalPages * blockSize) - blockSize;
        }
        checkLast = false;
        if(index == size || index+blockSize >= size)
        { 
           checkLast = true;
           getnxt();
        }
        if(this.objAccount != null)
        {  
             if(checkClientTypeNotTask)
                fetchAllNonTaskTypeNotesForClient();
             else if(checkClientStatusEqualsOpen)
                fetchAllOpenTasksForClient();
             else if(checkClientStatusEqualsClosed)
                fetchAllClosedTasksForClient();
        }
         
         if(this.objHousehold != null)
         {
             if(checkHouseholdTypeNotTask)
                fetchAllNonTaskTypeNotes();
             else if(checkHouseholdStatusEqualsOpen )
                fetchAllOpenTasksForHousehold();
             else if(checkHouseholdStatusEqualsClosed )
                fetchAllClosedTasksForHousehold();
         }
    }        
    
    /*
        * MethodName        : getprev
        * param             : -
        * Description       : Boolean control of rendering pagination for previous page.
    */ 
    public boolean getprev()
    {
        if(index <= 0)
            return true;
        else
            return false;
    }  
    
     /*
        * MethodName        : getnxt
        * param             : -
        * Description       : Boolean control of rendering pagination for next page.
    */ 
    public boolean getnxt()  
    {  
        if((index >= size || index+blockSize >= size) && checkLast)
           return true;
        else if((index + blockSize ) >= size)
            return true;
        else
            return false;
    }      
}