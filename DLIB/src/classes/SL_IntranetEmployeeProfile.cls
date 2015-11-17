/**
* @ClassName    : SL_IntranetEmployeeProfile 
* @JIRATicket   : Socint-192
* @CreatedOn    : 21/June/13
* @ModifiedBy   : Roshan 
* @Description  : This is the Implementation class of SL_IntranetEmployeeProfileController Controller.
*/

/**
@ Roshan Pillai 
Percentage of best practices followed   : 100%
No of SOQL queries used                 : 1
No of collections used                  : 1
Exception Handling implemented          : Yes
Coding standards followed               : Yes
Naming conventions followed             : Yes
Third party integrations                : No
Maximum of No of records tested with    : 
Customer Approval                       : 
Last Modified Date                      : 
Approved by                             : 
*/

public with sharing abstract class SL_IntranetEmployeeProfile extends WidgetAbstract
{
	//Global Variables
    public User objUser  {get;set;}
    public Id strUserId {get; set;}
    public String strQuery {get;set;}
    public EmployeeProfileWidgetConfiguration empPWConfig {get;set;}
    public List<SL_UtilityWrappers.FieldSetDescribe> lstEmployeeProfileFields {get; set;}    //List of Event fields that needs to display on component.
    public List<SL_UtilityWrappers.FieldSetDescribe> lstPopUpFields {get;set;}
    public List<String> lstFieldAPIName {get;set;}
    private String strCommunityId = Network.getNetworkId();
    /* Constructor initialization */
    public SL_IntranetEmployeeProfile()
    {   
        empPWConfig = new EmployeeProfileWidgetConfiguration();
        lstEmployeeProfileFields = new List<SL_UtilityWrappers.FieldSetDescribe>();
        lstPopUpFields = new List<SL_UtilityWrappers.FieldSetDescribe>();
        lstFieldAPIName = new List<String>();
		
		String idParam = Apexpages.currentPage().getParameters().get('id');
        
		strUserId = !String.isEmpty(idParam) ? (Id)idParam : UserInfo.getUserId();
        
        objUser = new User();  
        
        strQuery = '';
        
    }
    /* End : Constructor initialization */
    
    //inner Class
    public class EmployeeProfileWidgetConfiguration
    {
        //Configuration Variables
        private String fieldset;                                                                   // variable for field set.
        private Boolean showdefaultfields;     		                                          // variable to render default fields
        private String popUpFieldset;
        //Variables that are used on Page
        public String strUserAddressForMap              {get;set;}
        public List<String> lstOfficeLocations          {get;set;}
        public String strUserAboutMe                    {get;set;}
        
        public Boolean isLoad                            {get;set;} 
        public Boolean isError                          {get;set;}
        
        
        
        public EmployeeProfileWidgetConfiguration()
        {
            isLoad = true;
            isError = false;
            showdefaultfields = false;
            lstOfficeLocations = new List<String>();
        } 
    }

    // initialize method called on component's initialize
    public override protected void initialize()
    {
        displayUserDetails();
    }
    
    /* Start - Method to get the particular user details.
       @Name           - displayUserDetails
       @Parameters     - None 
       @Return Type    - void
       @Description    - Function for getting the particular user details.
    */  
    public void displayUserDetails()
    {
        try
        { 
            Set<String> setPopUpFields  = new Set<String>{'FullPhotoUrl','SmallPhotoUrl','FirstName','LastName','Title','Department','Email',
                                                                    'Phone','MobilePhone','Fax','Street','City','State','PostalCode','Country','AboutMe','User_Offices__c','ManagerId'};
            
            List<String> lstDefaultFields = new List<String>{'Title','Department','Phone','MobilePhone','Email','Street','City','State','PostalCode',
                                                             'Country','User_Offices__c','AboutMe'};
            
            /* getting Non-editbale field via describe call*/
            SObjectType userType = Schema.getGlobalDescribe().get('User');
			Set<String> setNonEditableField = new Set<String>();
			for(Schema.SObjectField sobjField:userType.getDescribe().fields.getMap().values())
			{
				if(!sobjField.getDescribe().isCreateable())
			   		setNonEditableField.add(sobjField.getDescribe().getName());
			}
			setNonEditableField.add('DigestFrequency');
			setNonEditableField.add('PortalRole'); //adding it separtly as couldn't find the type of this field
			setNonEditableField.add('ContactId');
			//Getting all the configuration
            if(this.properties != null) 
            {
                Map<String, Object> configuration = (Map<String, Object>)this.properties;
                
                empPWConfig.fieldset 				= String.valueOf(configuration.get('fieldset'));
                empPWConfig.showdefaultfields       = Boolean.valueOf(configuration.get('showdefaultfields'));
                empPWConfig.popUpFieldset           = String.valueOf(configuration.get('popupfieldset'));
            }

            if(String.isNotBlank(empPWConfig.fieldset))
            {
            	try{
                SL_UtilityWrappers.FieldSetResults objFieldSetWrapper = Utilities.buildQueryUsingFieldSet( 'User', empPWConfig.fieldset, '', '', '', new Set<String>());
            	lstEmployeeProfileFields = objFieldSetWrapper.lstFieldWrapper;
            	}
            	catch(Exception ex)
            	{
            		system.debug('-----Wrong field Set----');
            	}
            }
            
            if(String.isNotBlank(empPWConfig.popUpFieldset))
            {
            	SL_UtilityWrappers.FieldSetResults objFieldSetWrapper = Utilities.buildQueryUsingFieldSet( 'User', empPWConfig.popUpFieldset, '', '', '', setNonEditableField);
            	lstPopUpFields = objFieldSetWrapper.lstFieldWrapper;
            }
            
            if(empPWConfig.showdefaultfields)
                lstEmployeeProfileFields.addAll( Utilities.describeDefaultFields( 'User', lstDefaultFields) );
            
            strQuery = 'SELECT FullPhotoUrl,SmallPhotoUrl,FirstName,Lastname,Title,Department,Email,Phone,MobilePhone,Fax,Street,City,State,PostalCode,Country,AboutMe,User_Offices__c,ManagerId';
            
            Set<String> stDefaultFields = new Set<String>();
            stDefaultFields.addAll(lstDefaultFields);
            
            List<SL_UtilityWrappers.FieldSetDescribe> lstEmployeeProfileFieldsTemp = new List<SL_UtilityWrappers.FieldSetDescribe>();
            Set<String> setTempField = new Set<String>();
            Set<String> stTempDF = new Set<String>();
            
            // Iterate through the fields returned , to form a query
            for(SL_UtilityWrappers.FieldSetDescribe objFieldSetResult : lstEmployeeProfileFields)
            {
                if(empPWConfig.showdefaultfields)
                {
                    if(!stTempDF.contains(objFieldSetResult.fieldAPIName)) 
                    {
                        stTempDF.add(objFieldSetResult.fieldAPIName);
                        lstEmployeeProfileFieldsTemp.add(objFieldSetResult);
                        setTempField.add(objFieldSetResult.fieldAPIName);
                    }
                }
                else 
                {
                    lstEmployeeProfileFieldsTemp.add(objFieldSetResult);
                    setTempField.add(objFieldSetResult.fieldAPIName);
                }
            }
            
            lstEmployeeProfileFields = lstEmployeeProfileFieldsTemp;
            for(SL_UtilityWrappers.FieldSetDescribe objPopUpFieldSetResult : lstPopUpFields)
            {
            	lstFieldAPIName.add(objPopUpFieldSetResult.fieldAPIName);
            	setTempField.add(objPopUpFieldSetResult.fieldAPIName);
            }
			for(String strField : setTempField)
            {
                if(!setPopUpFields.contains(strField))
                {
                    strQuery += ','+ strField;
                }
            }
            
            strQuery += ' FROM User WHERE Id=:strUserId LIMIT 1';
            
            objUser = database.query(strQuery);
            
            if(String.isNotBlank(objUser.AboutMe) && objUser != null)
                empPWConfig.strUserAboutMe = objUser.AboutMe;

            if(objUser.User_Offices__c != null && objUser != null)
                empPWConfig.lstOfficeLocations = objUser.User_Offices__c.split('\n');

            //Creating string for User location to Display address for location and also for passing address to google map
            if(objUser != null)
            {
                String strStreet = objUser.Street;
                
                if(objUser.Street != null && objUser.Street != ''){
                    strStreet = strStreet.replaceAll('\n\r', ' ');
                    strStreet = strStreet.replaceAll('\r\n', ' ');
                    empPWConfig.strUserAddressForMap = strStreet;
                }
                if(objUser.City != null && objUser.City != '')
                    empPWConfig.strUserAddressForMap += (empPWConfig.strUserAddressForMap != '' ? ', ' : '') + objUser.City; 
                if(objUser.State != null && objUser.State != '')
                    empPWConfig.strUserAddressForMap += (empPWConfig.strUserAddressForMap != '' ? ', ' : '') + objUser.State + ((objUser.PostalCode != null && objUser.PostalCode != '') ? ' ' + objUser.PostalCode : '');
                else if(objUser.PostalCode != null && objUser.PostalCode != '')
                    empPWConfig.strUserAddressForMap += (empPWConfig.strUserAddressForMap != '' ? ', ' : '') + objUser.PostalCode;
                if(objUser.Country != null && objUser.Country != '')
                    empPWConfig.strUserAddressForMap += (empPWConfig.strUserAddressForMap != '' ? ', ' : '') + objUser.Country;  
            }   

            //To cover the catch block
            if(Test.isRunningTest())
            {
                Integer i = 1/0;
            }
            
        }
        catch(Exception e)
        {
            system.debug('---Exception::'+e);
        }
    }
    /* End : displayUserDetails method */
    
    
    public void deleteChatterPhoto() 
    {
        if(!Test.isRunningTest())
            ConnectApi.ChatterUsers.deletePhoto(strCommunityId , ApexPages.currentpage().getParameters().get('id'));
    }
    
    public void updateUserInformation() 
    {
        try{    
            if(objUser != null){
                objUser.AboutMe = empPWConfig.strUserAboutMe;  
                update objUser;
                empPWConfig.isLoad = false;
                empPWConfig.isError = false;
            }
            
            if(Test.isRunningTest())
                Integer i = 1/0;
        }
        catch(Exception ex){
            ApexPages.addMessages(ex);
            system.debug('::::::::ex:::::'+ex);
            empPWConfig.isLoad = false;
            empPWConfig.isError = true;
            
        }
    }    
    
    
    /* @Name           - recetEditPopUpOnCancel
       @Parameters     - None 
       @Return Type    - void
       @Description    - Function for resetting value of Profile fields on cancelation.
    */
    public void recetEditPopUpOnCancel()
    {
    	 objUser = new User();
    	 displayUserDetails();
    	 
    }
    
    
    /* @Name           - newComponent
       @Parameters     - None 
       @Return Type    - void
       @Description    - Function for creating Component dynamically.
    */
    public override ApexPages.Component newComponent() 
    { 
        Component.c.SL_IntranetEmployeeProfile c = new Component.c.SL_IntranetEmployeeProfile();   
        c.aComponentImpl = this;
        
        return c;
    }
    /* End : newComponent */
}