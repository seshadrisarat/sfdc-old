/**
    * \arg ClassName      : SL_HomePage_SearchAccounts_Ctrl
    * \arg JIRATicket     : NPD-86
    * \arg CreatedOn      : 3/August/2015
    * \arg LastModifiedOn : 
    * \arg CreatededBy    : Sandeep
    * \arg ModifiedBy     : 
    * \arg Description    : This is controller class for SL_HomePage_SearchAccounts Vf page.
*/
public with sharing class SL_HomePage_SearchAccounts_Ctrl 
{
    public List<SelectOption> lstOptionsForSearchAccount    {get;set;} //list will store the optiins for radio buttons
    public List<SelectOption> lstOptionsForPractices        {get;set;} //list options for practice records
    public String strSelectedOption                         {get;set;} //store select option of Account types
    public String strPracticeId                             {get;set;} //Store the practice id and select first option of dropdown
    public Boolean isPracticeDropDownDisplay                {get;set;} //boolean value for displaying dropdown
    
    public SL_HomePage_SearchAccounts_Ctrl()
    {
        lstOptionsForSearchAccount = new List<SelectOption>();
        lstOptionsForSearchAccount.add(new SelectOption('Search by Master Account', 'Search by Master Account'));
        lstOptionsForSearchAccount.add(new SelectOption('Search by Practice Account', 'Search by Practice Account'));
        checkPracticeMemberRecord();
    }
    
    /**
    @MethodName : checkPracticeMemberRecord
    @Param      : 
    @Description: This method will check for project team member records
    **/
    private void checkPracticeMemberRecord()
    {
        List<Practice_Team_Members__c> lstPracticeTeamMembers = [SELECT Id, Practice__c, Practice__r.Name 
                                                                   FROM Practice_Team_Members__c 
                                                                  WHERE User__c =: UserInfo.getUserId() LIMIT 1];
        if(lstPracticeTeamMembers.isEmpty())
        {
            strSelectedOption = 'Search by Master Account';
            isPracticeDropDownDisplay = false;
        }
        else
        {
            isPracticeDropDownDisplay = true;
            strSelectedOption = 'Search by Practice Account';
            strPracticeId = lstPracticeTeamMembers[0].Practice__c;
            fetchPracticRecords();
        }
    }
    
    /**
    @MethodName : changedAccountSearchType
    @Param      : 
    @Description: This method will called when user change the Account search type
    **/
    public void changedAccountSearchType()
    {
        if(strSelectedOption == 'Search by Master Account')
        {
            isPracticeDropDownDisplay = false;
            strPracticeId = null;
        }
        else
        {
            isPracticeDropDownDisplay = true;
            fetchPracticRecords();
            strPracticeId ='select';
        }
    }
    
    /**
    @MethodName : fetchPracticRecords
    @Param      : 
    @Description: This method will prepare the select option for practice dropdown
    **/
    private void fetchPracticRecords()
    {
        lstOptionsForPractices = new List<SelectOption>();
        lstOptionsForPractices.add(new SelectOption('select', '--- Select ---'));
        for(Practice__c objPractice :[SELECT Id, Name FROM Practice__c ])
        {
            lstOptionsForPractices.add(new SelectOption(objPractice.Id, objPractice.Name));
        }
    }
    //method for handling dummy rerender
    public void dummy(){}
}