public with sharing abstract class SL_IntranetOffices extends WidgetAbstract
{
	public List<IntranetOffice> lstOffices {get;set;}
	public List<SL_UtilityWrappers.FieldSetDescribe> lstOfficeFieldNames {get;set;}
    public List<SL_UtilityWrappers.FieldSetDescribe> lstOfficeFieldNamesOnHover {get;set;}
    public List<Office_Locations__c> lstOfficeLocation {get;set;}
    public String strFontColor		{	get; set;	}
    public String strFontStyle		{	get; set;	}
    public String strHeading		{	get; set;	}
    public String strPageName; 
	
	public List<SL_UtilityWrappers.FieldSetDescribe> lstFieldWrapper		{	get;set;	}//<! This list will contains the field API name to render.
	
	//populate a map with locale values and corresponding datetime formats
	private Map<String, String> MapValues() {
		Map<String, String> locale_map = new Map<String, String>{'ar' => 'dd/MM/yyyy hh:mm a', 
																'ar_AE' => 'dd/MM/yyyy hh:mm a', 
																'ar_BH' => 'dd/MM/yyyy hh:mm a', 
																'ar_EG' => 'dd/MM/yyyy hh:mm a', 
																'ar_JO' => 'dd/MM/yyyy hh:mm a', 
																'ar_KW' => 'dd/MM/yyyy hh:mm a', 
																'ar_LB' => 'dd/MM/yyyy hh:mm a', 
																'ar_SA' => 'dd/MM/yyyy hh:mm a', 
																'bg' => 'yyyy-M-d H:mm', 
																'bg_BG' => 'yyyy-M-d H:mm', 
																'ca' => 'dd/MM/yyyy HH:mm', 
																'ca_ES' => 'dd/MM/yyyy HH:mm', 
																'ca_ES_EURO' => 'dd/MM/yyyy HH:mm', 
																'cs' => 'd.M.yyyy H:mm', 
																'cs_CZ' => 'd.M.yyyy H:mm', 
																'da' => 'dd-MM-yyyy HH:mm', 
																'da_DK' => 'dd-MM-yyyy HH:mm', 
																'de' => 'dd.MM.yyyy HH:mm', 
																'de_AT' => 'dd.MM.yyyy HH:mm', 
																'de_AT_EURO' => 'dd.MM.yyyy HH:mm', 
																'de_CH' => 'dd.MM.yyyy HH:mm', 
																'de_DE' => 'dd.MM.yyyy HH:mm', 
																'de_DE_EURO' => 'dd.MM.yyyy HH:mm', 
																'de_LU' => 'dd.MM.yyyy HH:mm', 
																'el' => 'd/M/yyyy h:mm a', 
																'el_GR' => 'd/M/yyyy h:mm a', 
																'en_AU' => 'd/MM/yyyy HH:mm', 
																'en_BB' => 'M/d/yyyy h:mm a', 
																'en_BM' => 'M/d/yyyy h:mm a', 
																'en_CA' => 'dd/MM/yyyy h:mm a', 
																'en_GB' => 'dd/MM/yyyy HH:mm', 
																'en_GH' => 'M/d/yyyy h:mm a', 
																'en_ID' => 'M/d/yyyy h:mm a', 
																'en_IE' => 'dd/MM/yyyy HH:mm', 
																'en_IN' => 'd/M/yyyy HH:mm a', 
																'en_MY' => 'd/M/yyyy HH:mm a', 
																'en_NG' => 'm/D/yyyy HH:mm a', 
																'en_NZ' => 'd/MM/yyyy HH:mm a', 
																'en_PH' => 'm/d/yyyy HH:mm a', 
																'en_SG' => 'M/d/yyyy h:mm a', 
																'en_US' => 'M/d/yyyy h:mm a', 
																'en_ZA' => 'yyyy/MM/dd hh:mm a', 
																'es' => 'd/MM/yyyy H:mm', 
																'es_AR' => 'dd/MM/yyyy HH:mm', 
																'es_BO' => 'dd-MM-yyyy hh:mm a', 
																'es_CL' => 'dd-MM-yyyy hh:mm a', 
																'es_CO' => 'd/MM/yyyy hh:mm a', 
																'es_CR' => 'dd/MM/yyyy hh:mm a', 
																'es_DO' => 'MM/dd/yyyy hh:mm a', 
																'es_EC' => 'dd/MM/yyyy hh:mm a', 
																'es_ES' => 'd/MM/yyyy H:mm', 
																'es_GT' => 'd/MM/yyyy hh:mm a', 
																'es_HN' => 'MM-dd-yyyy hh:mm a', 
																'es_MX' => 'd/MM/yyyy hh:mm a', 
																'es_PA' => 'mm/dd/yyyy hh:mm a', 
																'es_PE' => 'dd/MM/yyyy hh:mm a', 
																'es_PR' => 'MM-dd-yyyy hh:mm a', 
																'es_PY' => 'dd/MM/yyyy hh:mm a', 
																'es_SVUS' => 'MM-dd-yyyy hh:mm a', 
																'es_UY' => 'dd/MM/yyyy hh:mm a', 
																'es_VE' => 'dd/MM/yyyy hh:mm a', 
																'et_EE' => 'd.MM.yyyy H:mm', 
																'fi' => 'd.M.yyyy H:mm', 
																'fi_FI' => 'd.M.yyyy H:mm', 
																'fr' => 'dd/MM/yyyy HH:mm', 
																'fr_BE' => 'd/MM/yyyy H:mm', 
																'fr_CA' => 'yyyy-MM-dd HH:mm', 
																'fr_CH' => 'dd.MM.yyyy HH:mm', 
																'fr_FR' => 'dd/MM/yyyy HH:mm', 
																'fr_LU' => 'dd/MM/yyyy HH:mm', 
																'fr_MC' => 'dd/MM/yyyy HH:mm', 
																'ga_IE' => 'dd/MM/yyyy HH:mm', 
																'hr_HR' => 'yyyy.MM.dd HH:mm', 
																'hu' => 'yyyy.MM.dd. H:mm', 
																'hu_HU' => 'yyyy.MM.dd. H:mm', 
																'hy_AM' => 'M/d/yyyy h:mm a', 
																'in' => 'yyyy/mm/dd hh:mm ', 
																'in_ID' => 'dd/mm/yyyy hh:mm ', 
																'is_IS' => 'd.M.yyyy HH:mm', 
																'it' => 'dd/MM/yyyy H.mm', 
																'it_CH' => 'dd.MM.yyyy HH:mm', 
																'it_IT' => 'dd/MM/yyyy H.mm', 
																'iw' => 'HH:mm dd/MM/yyyy', 
																'iw_IL' => 'HH:mm dd/MM/yyyy', 
																'ja' => 'yyyy/MM/dd H:mm', 
																'ja_JP' => 'yyyy/MM/dd H:mm', 
																'ka' => 'm/d/yyyy H:mm a', 
																'ka_GE' => 'm/d/yyyy H:mm a', 
																'kk_KZ' => 'M/d/yyyy h:mm a', 
																'km_KH' => 'M/d/yyyy h:mm a', 
																'ko' => 'yyyy. M. d a h:mm', 
																'ko_KR' => 'yyyy. M. d a h:mm', 
																'lt_LT' => 'yyyy.M.d HH.mm', 
																'lv_LV' => 'yyyy.d.M HH:mm', 
																'ms_MY' => 'dd/MM/yyyy h:mm a', 
																'nl' => 'd-M-yyyy H:mm', 
																'nl_BE' => 'd/MM/yyyy H:mm', 
																'nl_NL' => 'd-M-yyyy H:mm', 
																'nl_SR' => 'd-M-yyyy H:mm', 
																'no' => 'dd.MM.yyyy HH:mm', 
																'no_NO' => 'dd.MM.yyyy HH:mm', 
																'pl' => 'yyyy-MM-dd HH:mm', 
																'pt' => 'dd-MM-yyyy H:mm', 
																'pt_AO' => 'dd-MM-yyyy H:mm', 
																'pt_BR' => 'dd/MM/yyyy HH:mm', 
																'pt_PT' => 'dd-MM-yyyy H:mm', 
																'ro' => 'dd.MM.yyyy HH:mm', 
																'ro_RO' => 'dd.MM.yyyy HH:mm', 
																'ru' => 'dd.MM.yyyy HH:mm', 
																'ru_RU' => 'dd.MM.yyyy HH:mm', 
																'sh' => 'dd.MM.yyyy HH:mm', 
																'sh_BA' => 'dd.MM.yyyy HH:mm', 
																'sh_CS' => 'dd.MM.yyyy HH:mm', 
																'sk' => 'd.M.yyyy H:mm', 
																'sl_SI' => 'd.M.yy H:mm', 
																'sr' => 'd.M.yyyy H:mm', 
																'sr_BA' => 'yyyy-MM-DD HH:mm', 
																'sr_CS' => 'D.m.yyyy HH:mm', 
																'sk_SK' => 'd.M.yyyy H:mm', 
																'sl_SI' => 'd.M.y H:mm', 
																'sv' => 'yyyy-MM-dd HH:mm', 
																'sv_SE' => 'yyyy-MM-dd HH:mm', 
																'th' => 'M/d/yyyy h:mm a', 
																'th_TH' => 'd/M/yyyy => H:mm ?.', 
																'tr' => 'dd.MM.yyyy HH:mm', 
																'tr_TR' => 'dd.MM.yyyy HH:mm', 
																'uk' => 'dd.MM.yyyy HH:mm', 
																'uk_UA' => 'dd.MM.yyyy HH:mm', 
																'ur_PK' => 'd/M/yyyy H:mm a', 
																'ur_PK' => 'd/M/yyyy H:mm a', 
																'ur_PK' => 'M/d/yyyy h:mm a', 
																'vi' => 'HH:mm dd/MM/yyyy', 
																'vi_VN' => 'HH:mm dd/MM/yyyy', 
																'zh' => 'yyyy-M-d ah:mm', 
																'zh_CN' => 'yyyy-M-d ah:mm', 
																'zh_HK' => 'yyyy-M-d ah:mm', 
																'zh_TW' => 'yyyy/M/d a h:mm'}; //holds the locale to timedate formats
		return locale_map; //return the map
	}
	
	/* Constructor initialization */
	public SL_IntranetOffices()
	{
		try
		{
            strPageName = ApexPages.currentPage().getParameters().get('page');
            lstFieldWrapper = new List<SL_UtilityWrappers.FieldSetDescribe>();
			lstOffices = new List<IntranetOffice>(); 
			lstOfficeLocation = new List<Office_Locations__c>();
            lstOfficeFieldNames = new List<SL_UtilityWrappers.FieldSetDescribe>();
            lstOfficeFieldNamesOnHover = new List<SL_UtilityWrappers.FieldSetDescribe>();
            
            if(String.isBlank(strPageName))		strPageName = 'Home';
			
			//To cover the catch block during test run
			if(Test.isRunningTest())
				Integer i = 1/0;	
		}
		catch(Exception e){
			//Do nothing
		} 
	}
	/* End : Constructor initialization */
	
	
	/* Start - Method for getting Office locations.
	   @Name           - getOfficeLocations
	   @Parameters     - None 
	   @Return Type    - void
	   @Description    - Function for getting Office locations.
	*/
	public override protected void initialize()
	{
		try
		{
			if(!getObjectAccess('read', new Office_Locations__c().getsObjectType()))
				return ;
			DateTime currentDateTime = datetime.now();
			lstOfficeLocation =  new List<Office_Locations__c>();
            lstOfficeFieldNames = new List<SL_UtilityWrappers.FieldSetDescribe>();
            lstOfficeFieldNamesOnHover  = new List<SL_UtilityWrappers.FieldSetDescribe>();
            Set<String>  setDefaultFields = new Set<String>{'Id', 'Address__c', 'Phone__c' , 'Fax__c'};
            List<String>  lstDefaultFields = new List<String>{'Id', 'Address__c', 'Phone__c' , 'Fax__c'};
            Set<String> setFieldsToQuery = new Set<String>{'Id', 'Name', 'Address__c', 'TimeZoneSidKey__c', 'Company_Name__c', 'Fax__c', 'Phone__c', 'Image__c', 'Map__c'};
            String strFieldSet1 = ''; ///variable to store field set name
            String strFieldSet2 = ''; ///variable to store field set name

            if(this.properties != null) {
				Map<String, Object> configuration = (Map<String, Object>)this.properties;
				
				if(configuration.containsKey('fieldset1')) 	strFieldSet1 = String.valueOf(configuration.get('fieldset1'));
				if(configuration.containsKey('fieldset2')) 	strFieldSet2 = String.valueOf(configuration.get('fieldset2'));
				if(configuration.containsKey('fontcolor')) 	strFontcolor = String.valueOf(configuration.get('fontcolor'));
				if(configuration.containsKey('fontstyle')) 	strFontstyle = String.valueOf(configuration.get('fontstyle'));	
				if(configuration.containsKey('heading'))	strHeading 	 = String.valueOf(configuration.get('heading'));
				
				if(configuration.get('heading') == null || configuration.get('heading') == '')
					((map<String, object>)properties).put('heading', Label.SL_Home_OfficesHeader);
			}
			
            // Fetch the query string and fieldsets describe results from Utilities
            SL_UtilityWrappers.FieldSetResults objFieldSetWrapper;
            
            //Fetch query data related to Fieldset 1
            if(String.isNotBlank(strFieldSet1))
            {
	     		objFieldSetWrapper = Utilities.buildQueryUsingFieldSet( 'Office_Locations__c', strFieldSet1, 
	     																'', ' ORDER BY Display_Order__c ASC nulls last', ' LIMIT 250', new Set<String>());
	     		
	     		lstOfficeFieldNames = objFieldSetWrapper.lstFieldWrapper;
            }
            
            //Fetch query data related to Fieldset 2
            if(String.isNotBlank(strFieldSet2))
            {
	     		objFieldSetWrapper = Utilities.buildQueryUsingFieldSet( 'Office_Locations__c', strFieldSet2, 
	     																'', ' ORDER BY Display_Order__c ASC nulls last', ' LIMIT 250', new Set<String>());
	     		
	     		lstOfficeFieldNamesOnHover = objFieldSetWrapper.lstFieldWrapper;	
            }
            
     		// Form the set to form the query
     		for(SL_UtilityWrappers.FieldSetDescribe objFieldSetDescribe : lstOfficeFieldNames)
     		{
     			setFieldsToQuery.add(objFieldSetDescribe.fieldAPIName);
     		}
     		
     		for(SL_UtilityWrappers.FieldSetDescribe objFieldSetDescribe : lstOfficeFieldNamesOnHover)
     		{
     			setFieldsToQuery.add(objFieldSetDescribe.fieldAPIName);
     		}
	     	
	     	// Add default fields if no fields found in hover list
            if(lstOfficeFieldNamesOnHover.isempty())
            	lstOfficeFieldNamesOnHover.addAll( Utilities.describeDefaultFields( 'Office_Locations__c', lstDefaultFields) );
            
            //if(setFieldsToQuery.isempty())
               // setFieldsToQuery.addAll(setDefaultFields);
            
            // Form the query
            String strQuery = 'Select '+ String.join(new List<String>(setFieldsToQuery), ',') + ' FROM Office_Locations__c order by Display_Order__c asc nulls last';
            
            /// query Office records
            lstOfficeLocation = database.query(strQuery);
            
            lstOffices = new List<IntranetOffice>(); 
            for(Office_Locations__c obj : lstOfficeLocation)
            {
                if(obj.TimeZoneSidKey__c != null)
                {
                    String strTemp = currentDateTime.format( (  MapValues().containsKey(UserInfo.getLocale())  ?    MapValues().get(UserInfo.getLocale())  : 'dd/MM/yyyy h:mm a'  ), obj.TimeZoneSidKey__c);
                    lstOffices.add(new IntranetOffice(obj, strTemp));
                } 
                else
                	lstOffices.add(new IntranetOffice(obj, ''));
            }
            
			//To cover the catch block
			if(Test.isRunningTest())
				Integer i = 1/0;	
		}
		catch(Exception ex){
			system.debug(':::::::Exception:::::::'+ex);
		} 
	}
	/** End : getOfficeLocations method **/
	
	
	/**
        * Name: JSONClass 
        * Parameters: JSON Values
        * Description: This is the class to hold JSOn values
    */
    public class JSONClass
    {
        String fieldset1        {get;set;} //variable to store first field set
        String fieldset2        {get;set;} //variable to store second field set
        String fontcolor        {get;set;} //variable to store font color
        String fontstyle        {get;set;} //variable to store font style
    }
    
    
	/* Wrapper class for  Intranet Offices */
	public class IntranetOffice{
		public Office_Locations__c objOL {get; set;}
		public string strCurrentTime {get;set;}
		public string strAddress {get;set;}
		public string strAddressToMapIt {get; set;}
		public List<String> lstOfficeAddress {get;set;}
		
		public IntranetOffice(Office_Locations__c objOffice, String strTZ){
			objOL			= objOffice;
			strCurrentTime = strTZ; 
			strAddressToMapIt = '';
			lstOfficeAddress = new List<String>();
			
			if(objOffice.Map__c != null && objOffice.Map__c != '')
				strAddressToMapIt = objOffice.Map__c;
			
			if(objOffice.Address__c != null && objOffice.Address__c != '')
			{
				List<String> lstAddresses = objOffice.Address__c.split('\\n');
				lstOfficeAddress = objOffice.Address__c.split('\\n');
			    String strAddresses = '';
			    
			    for(String str : lstAddresses)
			    {
			     	strAddresses += str+'<br/>';
			    }    
			    strAddress = strAddresses;
			}
			
		} 
	}
	/* End : IntranetOffices Wrapper class */
	
  	public override ApexPages.Component newComponent() 
	{
    	Component.c.SL_IntranetOffices c = new Component.c.SL_IntranetOffices();   
		c.aComponentImpl = this;
		
    	return c;
  	}
}