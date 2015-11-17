/**
* \arg ClassName        : SL_ContactHandler
* \arg JIRATicket       : GREENHILL-26, GREENHILL-32, GREENHILL-37
* \arg CreatedOn        : 5/6/2014
* \arg LastModifiedOn   : 24/06/2015
* \arg ModifiedBy       : Pankaj Ganwani
* \arg LastModifiedBy   : Pankaj Ganwani
* \arg Description      : This class works as controller for SL_FundDashboardReportGenerator page
*/
public with sharing class SL_FundDashboardReportGenController   
{
    /* Start - Generator Variables */
    public MultiSelectOptionWrapper multiselectInterestLevel    {   get;set;    }
    public MultiSelectOptionWrapper multiselectExistingInvestor {   get;set;    }
    public MultiSelectOptionWrapper multiselectLPType           {   get;set;    }
    public List<FieldWrapper> lstFieldWrapper                   {   get;set;    }
    public List<SelectOption> fieldPicklist                     {   get;set;    }
    public Fundraising_Deal__c objFundraisingDeal               {   get;set;    }
    public String strPrimaryField                               {   get;set;    }
    public String strSecondaryField                             {   get;set;    }
    public String strPrimarySort                                {   get;set;    }
    public String strSecondarySort                              {   get;set;    }
    public String strConsultant                                 {   get;set;    }
    public String strCoverage                                   {   get;set;    }
    public String strCity                                       {   get;set;    }
    public String strCountry                                    {   get;set;    }
    public String strFundName                                   {   get;set;    }
    public String strReportType                                 {   get;set;    }
    public String strCurrencyType								{   get;set;    }
    public DateRangeWrapper dtRange                             {   get;set;    }
    public Boolean isShowSubtotal                             	{   get;set;    }
    public String strTertiaryField                              {   get;set;    }
    public String strTertiarySort                               {   get;set;    } 
    /* End - Generator Variables */

    /*** These variables have been created as the requirement of GREENHILL-28 - 9/22/2014 ***/
    /* Start - Report Variables */
    public List<ReportDataWrapper> lstReportDataWrapper         {get;private set;}// list of report data wrapper records having records grouped by LP type
    public List<FieldWrapper> lstFieldWrapperPDF                {get;private set;}// list of field wrapper records which is used to track the selected fields from UI
    public List<Fundraising_Deal__c> lstFundraisingDeal         {get;private set;}// list of fundraising deal records returned by soql based on filters applied
    /* End - Report Variables */
    public Boolean isOtherFund									{get;set;}
    private Map<String, Schema.SObjectType> mapGlobalDescribe;//!< Describe map to get the fields, fieldset and picklist values etc...
    
        
    /* Start - Constructor */
    public SL_FundDashboardReportGenController()
    {
        initialize();
        multiselectInterestLevel = new MultiSelectOptionWrapper(getMultiselectPicklistValue(new SL_InterestLevelValues__c()));
        multiselectLPType = new MultiSelectOptionWrapper(getMultiselectPicklistValue(new SL_LPTypeValues__c()));
        multiselectExistingInvestor = new MultiSelectOptionWrapper(getPicklistValues('Fundraising_Deal__c', 'Existing_Investor__c'));
    }
    /* End - Constructor */
    
    /*** This class has been created as the requirement of GREENHILL-28 - 9/22/2014 ***/
    public class ReportDataWrapper
    {
        public List<Fundraising_Deal__c> lstFRD     {   get;private set;    }
        public String strStage                      {   get;private set;    }
        public Decimal decSubTotal                  {   get;private set;    }
		public Integer intCount						{   get;private set;    }
		
        public ReportDataWrapper(List<Fundraising_Deal__c> lstFRD, String strStage, Decimal decSubTotal, Integer intCount)
        {
            this.lstFRD = lstFRD;
            this.strStage = strStage;
            this.decSubTotal = decSubTotal;
            this.intCount = intCount;
        }
    }
    
    public class MultiSelectOptionWrapper
    {
        public List<SelectOption> available     {   get;set;    }
        public List<SelectOption> selected      {   get;set;    }

        public MultiSelectOptionWrapper(List<SelectOption> available)
        {
            this.available = available;
            this.selected = new List<SelectOption>();
        }
    }

    public class FieldWrapper
    {
        public String strFieldAPI   {   get;private set;    }
        public String strFieldLabel {   get;private set;    }
        public Boolean isSelected   {   get;set;    }
        public Integer intFieldIndex{   get;private set;    }
		public Integer intColumnNo	{   get;private set;    }
		
        public FieldWrapper(String strFieldAPI, String strFieldLabel, Boolean isSelected, Integer intFieldIndex, Integer intColumnNo)
        {
            this.strFieldAPI = strFieldAPI;
            this.strFieldLabel = strFieldLabel;
            this.isSelected = isSelected;
            this.intFieldIndex = intFieldIndex;
            this.intColumnNo = intColumnNo;
        }
    }
    
    /* Start - Wrapper Class for Date range */
    public class DateRangeWrapper
    {
        public String dateStart         {   get;set;    }
        public String dateEnd           {   get;set;    }
        
        public DateRangeWrapper()
        {
            Datetime dt = Datetime.now();
            this.dateEnd = dt.format('M/dd/yyyy');
        }
    }
    /* End - Wrapper Class for Date range */
    
    /*  
     @MethodName   : initialize
     @param        : None
     @Description  : This method will initialize all the components of the page.
    */
    private void initialize()
    {
        objFundraisingDeal = new Fundraising_Deal__c();
        lstFieldWrapperPDF = new List<FieldWrapper>();
        mapGlobalDescribe = Schema.getGlobalDescribe();
        strConsultant = strCoverage = strCity = strCountry = '';
        /* Start - Updated By Pankaj Ganwani on 17/JUNE/2015 as per the requirements of GREENHILL-37 */
        strPrimaryField = 'Outreach__c';
        /* End - Updated By Pankaj Ganwani on 17/JUNE/2015 as per the requirements of GREENHILL-37 */
        strSecondaryField = 'Company__c';
        strPrimarySort = 'ASC';
        strSecondarySort = 'ASC';
        strTertiaryField = 'Commitment_Size_MM__c';
        strTertiarySort = 'ASC';
        strReportType = 'PDF';
        prepareFieldWrapper();
        dtRange = new DateRangeWrapper();
        isOtherFund = false;
        isShowSubtotal = true;
    }
    
    /*  
     @MethodName   : prepareFieldWrapper
     @param        : None
     @Description  : This method is used to prepare data for field wrapper class.
    */
    private void prepareFieldWrapper()
    {
        lstFieldWrapper = new List<FieldWrapper>();
        fieldPicklist = new List<SelectOption>(); 
        Map<String,String> mapFieldAPIToLabel = new Map<String,String>{ 'Company__c'=>'LP',
                                                                        'Consultant_Formula__c'=>'Consultant',
                                                                        'RECA_Coverage__c'=>'Coverage',
                                                                        'Materials_Sent__c'=>'Materials Sent',
                                                                        'Stage__c'=>'Interest Level',
                                                                        'Existing_Investor__c'=>'Existing Investor',
                                                                        'Commitment_Size_MM__c'=>'Commitment Size',
                                                                        'LastModifiedDate' => 'Last Modified Date',
                                                                        'Company_Type__c'=>'LP Type',
                                                                        'City__c'=>'City',
                                                                        'Country__c'=>'Country',
                                                                        'Next_Step_RECA__c'=>'Current Status / Next Step',
                                                                        'Outreach__c'=>'Outreach'};
                                                                        
        List<String> lstFieldAPINames = new List<String>{'Company__c','Consultant_Formula__c','Outreach__c','RECA_Coverage__c','Stage__c','Existing_Investor__c','Materials_Sent__c','Commitment_Size_MM__c',
                                                         'LastModifiedDate','Company_Type__c','City__c','Country__c','Next_Step_RECA__c'};
        Integer intCount = 1;
        for(String strFieldAPIName : lstFieldAPINames)
        { 
            /* Start - Updated By Pankaj Ganwani on 17/JUNE/2015 as per the requirements of GREENHILL-37 */
            //checking if fields are not of either long text area or multiselect picklist types to avoid the SOQL exception since such type of fields do not support along with where clause in SOQL
            if(strFieldAPIName!='Materials_Sent__c' && strFieldAPIName!='Next_Step_RECA__c')
                fieldPicklist.add(new SelectOption(strFieldAPIName,mapFieldAPIToLabel.get(strFieldAPIName)));
            /* End - Updated By Pankaj Ganwani on 17/JUNE/2015 as per the requirements of GREENHILL-37 */
            
            if(strFieldAPIName == 'Company_Type__c' || strFieldAPIName == 'City__c' || strFieldAPIName == 'Country__c' || strFieldAPIName == 'Existing_Investor__c')
                lstFieldWrapper.add(new FieldWrapper(strFieldAPIName,mapFieldAPIToLabel.get(strFieldAPIName),false,0,intCount));
            else
                lstFieldWrapper.add(new FieldWrapper(strFieldAPIName,mapFieldAPIToLabel.get(strFieldAPIName),true,0,intCount));
        	intCount++;
        }
    }
    
    /*  
     @MethodName   : getMultiselectPicklistValue
     @param        : Sobject and Pick list API name.
     @Description  : This method will return the list of SelectOption which will contains the picklist value to display on the page.
    */
    private List<SelectOption> getMultiselectPicklistValue(SObject objSObject)
    {
        List<SelectOption> lstAvailablePickListValue = new List<SelectOption>();
        //Checking if custom setting is related to Interest Level
        if(objSObject.getSObjectType() == SL_InterestLevelValues__c.SObjectType)
        {
             //Iterating over interest level custom setting to fill the list
             for(SL_InterestLevelValues__c objSL_InterestLevelValues : [SELECT Name, Interest_Level__c FROM SL_InterestLevelValues__c ORDER BY Sort_Order__c])
             {
                lstAvailablePickListValue.add(new SelectOption(objSL_InterestLevelValues.Name, objSL_InterestLevelValues.Interest_Level__c));
             }          
        }
        //Checking if custom setting is related to LP type
        else if(objSObject.getSObjectType() == SL_LPTypeValues__c.SObjectType)
        {
            //Iterating over LP type custom setting to fill the list
            for(SL_LPTypeValues__c objSL_LPTypeValues : SL_LPTypeValues__c.getall().values())
            {
                lstAvailablePickListValue.add(new SelectOption(objSL_LPTypeValues.Name, objSL_LPTypeValues.LP_Type__c));
            }   
        }
        
        return lstAvailablePickListValue;
    }
    /* End */
    
    /*
        @MethodName : getPicklistValue 
        @param      : Sobject name and filed api name.
        @Description: method to get picklist value from field.
    */
    private List<SelectOption> getPicklistValues(String strSobjectName, String strFieldName)
    {
        List<SelectOption> options = new List<SelectOption>();
        Schema.SObjectType targetType = mapGlobalDescribe.get(strSobjectName);//!< From the Object Api name retrieving the SObject
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType(); //!< grab the sobject that was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //!< describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //!< get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pick_list_values = field_map.get(strFieldName).getDescribe().getPickListValues(); 
                                                        //!< grab the list of picklist values for the passed field on the sobject
        for (Schema.PicklistEntry a : pick_list_values) 
        { 
            options.add(new SelectOption(a.getLabel(), a.getValue()));
        }
        return options;
    }
    /* End */

    /*  
     @MethodName   : getSortValue
     @param        : None
     @Description  : This method will return the list of SelectOption which will contains the order of displaying data on the page.
    */

    public List<SelectOption> getSortValue()
    {
        return new List<SelectOption>{new SelectOption('ASC','ASC'), new SelectOption('DESC', 'DESC')};
    } 
    
    /*  
     @MethodName   : getReportType
     @param        : None
     @Description  : This method will return the list of SelectOption which will contains the types of reports.
    */

    public List<SelectOption> getReportType()
    {
        return new List<SelectOption>{new SelectOption('PDF','PDF'), new SelectOption('XLS', 'XLS')};
    } 

    /*  
     @MethodName   : generateReport
     @param        : None
     @Description  : This method will call from page to generate the report.
    */
    public Pagereference generateReport()
    {
        try
        {     
            PageReference reportPage;
            if(strReportType == 'PDF')  
            {
            	lstReportDataWrapper = getReportData();  
                reportPage = new PageReference('/apex/SL_FundDashboardPDFReport');
            }                
            else if(strReportType == 'XLS')
            {
            	lstFundraisingDeal = getFundraisingDealRecords();
                reportPage = new PageReference('/apex/SL_FundDashboardEXCELReport');
            }
            reportPage.setRedirect(false);
            return reportPage;
        }
        catch(Exception ex)
        {
            System.debug('==============='+ex.getMessage()+'==============='+ex.getLineNumber());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,''+ ex.getMessage()));
            return null;
        }
    }
    /* End */
    
    /*** This function has been created as the requirement of GREENHILL-28 - 9/22/2014 ***/
    /*  
     @MethodName   : getReportData
     @param        : None
     @Description  : This method will call from page to generate the report.
    */
    private List<ReportDataWrapper> getReportData()
    {
        List<ReportDataWrapper> lstRDW = new List<ReportDataWrapper>();
        List<String> lstStage = new List<String>();
        Map<String, List<Fundraising_Deal__c>> mapStageToLstOfFundraisingDeal = new Map<String, List<Fundraising_Deal__c>>();
        Map<String, Decimal> mapStageToSubTotal = new Map<String, Decimal>();
        Integer intCount = 1;
        
        //Iterating on the selectoptions to arrage the group by rows order same as the Stage__c picklist order
        for(SelectOption objSO : getPicklistValues('Fundraising_Deal__c', 'Stage__c'))
        {
        	lstStage.add(objSO.getValue());
        }
        
        //Iterating over returned records to create a map of stage and its corresponding fundraising deal records
        for(Fundraising_Deal__c objFRD : getFundraisingDealRecords())
        {
            //checking if stage is not null
            if(objFRD.Stage__c!=null)
            {
                //grouping fundraising deal records corresponding to related LP type
                if(!mapStageToLstOfFundraisingDeal.containsKey(objFRD.Stage__c))
                    mapStageToLstOfFundraisingDeal.put(objFRD.Stage__c, new List<Fundraising_Deal__c>{objFRD});
                else
                    mapStageToLstOfFundraisingDeal.get(objFRD.Stage__c).add(objFRD);
                
                //subtotal of commitment size corresponding to each LP type 
                if(!mapStageToSubTotal.containskey(objFRD.Stage__c))
                {
                    mapStageToSubTotal.put(objFRD.Stage__c, objFRD.Commitment_Size_MM__c != null ? objFRD.Commitment_Size_MM__c : 0.0);                 
                }
                else if(objFRD.Commitment_Size_MM__c!=null)
                {
                    mapStageToSubTotal.put(objFRD.Stage__c, mapStageToSubTotal.get(objFRD.Stage__c) + objFRD.Commitment_Size_MM__c);    
                }                                   
            }                 
        }
        
        /* Removing the group by functionality alphabetically and change it to same as Stage__c picklist */
        /*lstStage.addAll(mapStageToLstOfFundraisingDeal.keyset());
       	lstStage.sort();*/
       	
        //Iterating over sorted list of stages to set the data in report wrapper so that data displayed on report should be in sorted order
        for(String strStageName : lstStage)
        {
            if(String.isNotEmpty(strStageName) && mapStageToLstOfFundraisingDeal.containsKey(strStageName))
            {
                lstRDW.add(new ReportDataWrapper(mapStageToLstOfFundraisingDeal.get(strStageName),strStageName,mapStageToSubTotal.get(strStageName), intCount));
            	intCount++;
            }                
        }
        return lstRDW;
    }
    /*  
     @MethodName   : getFundraisingDealRecords
     @param        : -
     @Description  : This method is used to fetch all the records from query.
    */
    private List<Fundraising_Deal__c> getFundraisingDealRecords()
    {
        Set<String> setSplittedString;
        Set<Id> setFundId = new Set<Id>();
        String strQuery = 'SELECT Id';
        String strWhereClause = ' ';
        String strInterestLevel = '';
        String strLPType = '';
        String strExistingInverstors = '';
        String strMaterialsSent = '';
        String strFundId = objFundraisingDeal.Fund__c;
        DateTime dtStartDateTime;
        DateTime dtEndDateTime;
        if(strSecondaryField == 'Company__c')
            strSecondaryField = strSecondaryField.replace('__c', '__r.Name');
        if(strPrimaryField == 'Company__c')
            strPrimaryField = strPrimaryField.replace('__c', '__r.Name');
        if(strTertiaryField == 'Company__c')
        	strTertiaryField = strTertiaryField.replace('__c', '__r.Name');	    
        strInterestLevel = getPicklistSelectedOptions(multiselectInterestLevel);
        strLPType = getPicklistSelectedOptions(multiselectLPType);
        strExistingInverstors = getPicklistSelectedOptions(multiselectExistingInvestor);
        
        if(String.isNotEmpty(strFundId))
        {
            strWhereClause+='AND Fund__c ='+ '\''+String.escapeSingleQuotes(strFundId.trim())+'\'';
            strFundName = [SELECT Name FROM vced2__Fund__c WHERE Id=:strFundId].Name;       
        }
        if(String.isNotEmpty(strConsultant))
        {
            if(!strConsultant.contains(','))
                strWhereClause+=' AND Consultant_Formula__c Like '+'\'%'+String.escapeSingleQuotes(strConsultant.trim())+'%' +'\'';
            else
                strWhereClause+=' AND Consultant_Formula__c IN('+ getCommaSeparatedString(String.escapeSingleQuotes(strConsultant.trim())).replaceFirst(',', '') +')';
        }
        if(String.isNotEmpty(strCoverage))
        {
            if(!strCoverage.contains(','))
                strWhereClause+=' AND RECA_Coverage__c Like '+'\'%'+String.escapeSingleQuotes(strCoverage.trim())+'%' +'\'';
            else
            {
                setSplittedString = getSplitedString(String.escapeSingleQuotes(strCoverage.trim()));
                for(String strValue : setSplittedString)
                    strWhereClause+= strWhereClause.contains('RECA_Coverage__c')?' OR RECA_Coverage__c Like '+'\'%'+strValue+'%' +'\'':' AND (RECA_Coverage__c Like '+'\'%'+strValue+'%' +'\'';
                strWhereClause+=')';
            }
        }
        if(String.isNotEmpty(strInterestLevel))
        {
            strInterestLevel = strInterestLevel.replaceFirst(',', '');
            strWhereClause+=' AND Stage__c IN(' + strInterestLevel + ')';
        }
        if(String.isNotEmpty(strLPType))
        {
            strLPType = strLPType.replaceFirst(',', '');
            strWhereClause+=' AND Company_Type__c IN(' + strLPType + ')';
        }
        
        /*Added for GREENHILL-29*/
        if(String.isNotEmpty(strExistingInverstors) && !isOtherFund)
        {
            strExistingInverstors = strExistingInverstors.replaceFirst(',', '');
            strWhereClause+=' AND Existing_Investor__c IN(' + strExistingInverstors + ')';
        }
        /*Added for GREENHILL-29*/
        
        if(String.isNotEmpty(strCity))
        {
            if(!strCity.contains(','))
                strWhereClause+=' AND City__c Like '+'\'%'+String.escapeSingleQuotes(strCity.trim())+'%' +'\'';
            else
                strWhereClause+=' AND City__c IN('+ getCommaSeparatedString(String.escapeSingleQuotes(strCity.trim())).replaceFirst(',', '') +')';
        }
        if(String.isNotEmpty(strCountry))
        {
            if(!strCountry.contains(','))
                strWhereClause+=' AND Country__c Like '+'\'%'+String.escapeSingleQuotes(strCountry.trim())+'%' +'\'';
            else
                strWhereClause+=' AND Country__c IN('+ getCommaSeparatedString(String.escapeSingleQuotes(strCountry.trim())).replaceFirst(',', '') +')';
        }
        
        if(dtRange.dateStart != null && dtRange.dateStart.split('/').size() == 3)
            dtStartDateTime = Datetime.newInstance(Integer.valueOf(dtRange.dateStart.split('/')[2]), Integer.valueOf(dtRange.dateStart.split('/')[0]), Integer.valueOf(dtRange.dateStart.split('/')[1]), 0, 0, 0);
        if(dtRange.dateEnd != null && dtRange.dateEnd.split('/').size() == 3)
            dtEndDateTime = Datetime.newInstance(Integer.valueOf(dtRange.dateEnd.split('/')[2]), Integer.valueOf(dtRange.dateEnd.split('/')[0]), Integer.valueOf(dtRange.dateEnd.split('/')[1]), 23, 59, 59);
        if(dtStartDateTime!=null && dtEndDateTime!=null)
            strWhereClause+=' AND LastModifiedDate > =: dtStartDateTime AND LastModifiedDate < =: dtEndDateTime';
        
        if(strPrimaryField == 'Stage__c')
        {
            if(strPrimarySort == 'DESC')
                strPrimarySort = 'ASC';
            else
                strPrimarySort = 'DESC';
        }
            
        strWhereClause = strWhereClause.replaceFirst('AND', '');
        
        strWhereClause += ' ORDER BY '+ strPrimaryField + ' ' + strPrimarySort + ' '+ ',' + strSecondaryField + ' ' + strSecondarySort + ' ' + ',' + strTertiaryField + ' ' + strTertiarySort;
        Integer counter = 0;
        Integer intColumnNo = 1;
        for(FieldWrapper objFieldWrapper : lstFieldWrapper)
        {
            if(objFieldWrapper.isSelected || isOtherFund)
            {
                if(objFieldWrapper.strFieldLabel == 'Commitment Size')
                {
                	if(strCurrencyType == null)
                		strCurrencyType = '$'; 	
                	
                    lstFieldWrapperPDF.add(new FieldWrapper(objFieldWrapper.strFieldAPI, strCurrencyType, true, counter++,intColumnNo));
                	isShowSubtotal = true;
                }
                else if(objFieldWrapper.strFieldLabel == 'Last Modified Date')
                    lstFieldWrapperPDF.add(new FieldWrapper(objFieldWrapper.strFieldAPI, 'Last Modified',true, counter++,intColumnNo));
                else
                    lstFieldWrapperPDF.add(new FieldWrapper(objFieldWrapper.strFieldAPI, objFieldWrapper.strFieldLabel,true, counter++,intColumnNo));
                if(objFieldWrapper.strFieldAPI == 'Company__c')
                    strQuery += ', Company__r.Name ';
                else
                    strQuery += ', ' + objFieldWrapper.strFieldAPI;
				intColumnNo++;                    
            }
            else if(objFieldWrapper.strFieldLabel == 'Commitment Size' && !objFieldWrapper.isSelected)
            	isShowSubtotal = false;	
        }
        
        for(SL_ExistingInvestorOnDashboardReport__c objEIDR : SL_ExistingInvestorOnDashboardReport__c.getAll().values())
        {
        	setFundId.add(objEIDR.FundId__c);
        }
        if(setFundId.contains(strFundId.trim()))
        	isOtherFund = false;
        
        if(!strQuery.contains('Stage__c'))
            strQuery+=', Stage__c ';
        if(!strQuery.contains(', RECA_Coverage__c'))
            strQuery+=', RECA_Coverage__c';
        if(!strQuery.contains(', Commitment_Size_MM__c'))
            strQuery+=', Commitment_Size_MM__c';
            
        strQuery += ' FROM Fundraising_Deal__c WHERE ' +strWhereClause;
        
        return Database.query(strQuery);
    }
    /* End */
    
    /*  
     @MethodName   : getPicklistSelectedOptions
     @param        : MultiSelectOptionWrapper class object
     @Description  : This method is used to frame a comma separated string of all the selected items from multiselect picklist.
    */
    private String getPicklistSelectedOptions(MultiSelectOptionWrapper objMultiSelectOptionWrapper)
    {
        String strSelectedOptions = '';
        for(System.Selectoption objSelectOption : objMultiSelectOptionWrapper.selected)
            strSelectedOptions+=','+ '\''+ objSelectOption.getLabel() +'\'';
        return strSelectedOptions;
    }
    /* End */
    
    /*  
     @MethodName   : getDate
     @param        : -
     @Description  : This method is used to convert today's date into string and show it on report.
    */
    public String getDate()
    {
        Datetime dt = Datetime.now();  
        return dt.format('d MMM. yyyy');        
    }
    /* End */
    
    /*  
     @MethodName   : getCommaSeparatedString
     @param        : String
     @Description  : This method is used to form comma separated string.
    */
    private String getCommaSeparatedString(String strFieldValue)
    {
        strFieldValue.split(',');
        String strCommaSeparatedString = '';
        for(String strValue : strFieldValue.split(','))
        {
            strCommaSeparatedString+=',' + '\''+ strValue.trim() +'\'';
        }
        return strCommaSeparatedString;
    }
    /* End */
    
     /*  
     @MethodName   : getSplitedString
     @param        : set of strings
     @Description  : This method is used to form comma splitted string
    */
    private Set<String> getSplitedString(String strSeparatedString)
    {
        Set<String> setSplittedString = new Set<String>();
        for(String strValue : strSeparatedString.split(','))
            setSplittedString.add(strValue.trim());         
        return setSplittedString;
    }
    
    /* Added below method regarding GREENHILL-33 by Sandeep Sankhla */
    /*  
     @MethodName   : getCurrencyType
     @param        : None
     @Description  : This method will return the list of SelectOption which will contains the types of Currencies.
    */
    public List<SelectOption> getCurrencyType()
    {
        return new List<SelectOption>{new SelectOption('','--None--'), new SelectOption('$','$'), new SelectOption('€', '€')};
    } 
}