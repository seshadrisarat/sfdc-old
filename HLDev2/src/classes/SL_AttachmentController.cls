/*
 * Controller for attachment component
 */
 
public with sharing class SL_AttachmentController 
{
    // the parent object it where Attachment will be attached. This will be either passed from iframe param or JS method fom Save method.
    public String sobjId {get; set;}

    // String of removed attachments id's. This will be passed from JS method.
    public String strRemovedAttachments {get; set;}
    
    // list of existing attachments - populated on demand
    public Attachment attachment {get; set;}

    // Date format to use on page
    public String dateFormat {get; set;}
    
    // list of new attachments to add
    public List<Attachment> attachments;
    
    // the number of new attachments to add to the list when the user clicks 'Add More'
    public static final Integer NUM_ATTACHMENTS_TO_ADD=5;

    // constructor
    public SL_AttachmentController()
    {
        sobjId = '';

        attachments = new List<Attachment>();
        
        if(ApexPages.currentPage().getParameters().containsKey('id') && ApexPages.currentPage().getParameters().get('id') != '')
            sobjId = Id.valueOf(ApexPages.currentPage().getParameters().get('id'));
        
        // instantiate the list with a single attachment
        attachment = new Attachment();

        //Get the date format from custom setting or user locale
        dateFormat = getDateFormat();
    }   
    
    // retrieve the existing attachments
    public List<Attachment> getAttachments()
    {
        // only execute the SOQL if the list hasn't been initialised
        attachments=[select Id, ParentId, Name, Description, createdDate from Attachment where parentId = :sobjId];
        
        return attachments;
    }

    //refresh attachments table
    public void refreshAttachments()
    {
        attachment = new Attachment();
    }

    // Save action method
    public Pagereference save()
    {
        try{
            
            if(String.isNotBlank(sobjId)){
                
                if(String.isNotBlank(strRemovedAttachments)) {

                    List<Attachment> lstAttachmentsToBeDeleted = new List<Attachment>();
                    for(String strAttachmentId :strRemovedAttachments.split(',')){

                        lstAttachmentsToBeDeleted.add(new Attachment(Id = strAttachmentId));
                    }
                    
                    delete lstAttachmentsToBeDeleted;
                }     

                if(attachment.body != null){

                    attachment.ParentId = sobjId;
                    
                    insert attachment;   
                    //null the list of existing attachments - this will be rebuilt when the page is refreshed
                    attachment = new Attachment();
                }

                return new Pagereference('/apex/AttachmentRelatedList?isSuccess=true&msg=attached sucessfully');
            }
            else{
                attachment = new Attachment();
                return new Pagereference('/apex/AttachmentRelatedList?isSuccess=false&msg=Parent doesnt found');
            }  
        } 
        catch(DMLException e){
            
            attachment = new Attachment();
            return new Pagereference('/apex/AttachmentRelatedList?isSuccess=false&msg=DML exception while attaching');
        
        }            
    }

    //populate a map with locale values and corresponding datetime formats
    private static Map<String, String> MapValues() {
        Map<String, String> locale_map = new Map<String, String>{'ar' => 'dd/MM/yyyy', 
                                                                'ar_AE' => 'dd/MM/yyyy', 
                                                                'ar_BH' => 'dd/MM/yyyy', 
                                                                'ar_EG' => 'dd/MM/yyyy', 
                                                                'ar_JO' => 'dd/MM/yyyy', 
                                                                'ar_KW' => 'dd/MM/yyyy', 
                                                                'ar_LB' => 'dd/MM/yyyy', 
                                                                'ar_SA' => 'dd/MM/yyyy', 
                                                                'bg' => 'yyyy-M-d', 
                                                                'bg_BG' => 'yyyy-M-d', 
                                                                'ca' => 'dd/MM/yyyy', 
                                                                'ca_ES' => 'dd/MM/yyyy', 
                                                                'ca_ES_EURO' => 'dd/MM/yyyy', 
                                                                'cs' => 'd.M.yyyy', 
                                                                'cs_CZ' => 'd.M.yyyy', 
                                                                'da' => 'dd-MM-yyyy', 
                                                                'da_DK' => 'dd-MM-yyyy', 
                                                                'de' => 'dd.MM.yyyy', 
                                                                'de_AT' => 'dd.MM.yyyy', 
                                                                'de_AT_EURO' => 'dd.MM.yyyy', 
                                                                'de_CH' => 'dd.MM.yyyy', 
                                                                'de_DE' => 'dd.MM.yyyy', 
                                                                'de_DE_EURO' => 'dd.MM.yyyy', 
                                                                'de_LU' => 'dd.MM.yyyy', 
                                                                'el' => 'd/M/yyyy', 
                                                                'el_GR' => 'd/M/yyyy', 
                                                                'en_AU' => 'd/MM/yyyy', 
                                                                'en_BB' => 'M/d/yyyy', 
                                                                'en_BM' => 'M/d/yyyy', 
                                                                'en_CA' => 'dd/MM/yyyy', 
                                                                'en_GB' => 'dd/MM/yyyy', 
                                                                'en_GH' => 'M/d/yyyy', 
                                                                'en_ID' => 'M/d/yyyy', 
                                                                'en_IE' => 'dd/MM/yyyy', 
                                                                'en_IN' => 'd/M/yyyy', 
                                                                'en_MY' => 'd/M/yyyy', 
                                                                'en_NG' => 'm/D/yyyy', 
                                                                'en_NZ' => 'd/MM/yyyy', 
                                                                'en_PH' => 'm/d/yyyy', 
                                                                'en_SG' => 'M/d/yyyy', 
                                                                'en_US' => 'M/d/yyyy', 
                                                                'en_ZA' => 'yyyy/MM/dd', 
                                                                'es' => 'd/MM/yyyy', 
                                                                'es_AR' => 'dd/MM/yyyy', 
                                                                'es_BO' => 'dd-MM-yyyy', 
                                                                'es_CL' => 'dd-MM-yyyy', 
                                                                'es_CO' => 'd/MM/yyyy', 
                                                                'es_CR' => 'dd/MM/yyyy', 
                                                                'es_DO' => 'MM/dd/yyyy', 
                                                                'es_EC' => 'dd/MM/yyyy', 
                                                                'es_ES' => 'd/MM/yyyy', 
                                                                'es_GT' => 'd/MM/yyyy', 
                                                                'es_HN' => 'MM-dd-yyyy', 
                                                                'es_MX' => 'd/MM/yyyy', 
                                                                'es_PA' => 'mm/dd/yyyy', 
                                                                'es_PE' => 'dd/MM/yyyy', 
                                                                'es_PR' => 'MM-dd-yyyy', 
                                                                'es_PY' => 'dd/MM/yyyy', 
                                                                'es_SVUS' => 'MM-dd-yyyy', 
                                                                'es_UY' => 'dd/MM/yyyy', 
                                                                'es_VE' => 'dd/MM/yyyy', 
                                                                'et_EE' => 'd.MM.yyyy', 
                                                                'fi' => 'd.M.yyyy', 
                                                                'fi_FI' => 'd.M.yyyy', 
                                                                'fr' => 'dd/MM/yyyy', 
                                                                'fr_BE' => 'd/MM/yyyy', 
                                                                'fr_CA' => 'yyyy-MM-dd', 
                                                                'fr_CH' => 'dd.MM.yyyy', 
                                                                'fr_FR' => 'dd/MM/yyyy', 
                                                                'fr_LU' => 'dd/MM/yyyy', 
                                                                'fr_MC' => 'dd/MM/yyyy', 
                                                                'ga_IE' => 'dd/MM/yyyy', 
                                                                'hr_HR' => 'yyyy.MM.dd', 
                                                                'hu' => 'yyyy.MM.dd.', 
                                                                'hu_HU' => 'yyyy.MM.dd.', 
                                                                'hy_AM' => 'M/d/yyyy', 
                                                                'in' => 'yyyy/mm/dd', 
                                                                'in_ID' => 'dd/mm/yyyy', 
                                                                'is_IS' => 'd.M.yyyy', 
                                                                'it' => 'dd/MM/yyyy', 
                                                                'it_CH' => 'dd.MM.yyyy', 
                                                                'it_IT' => 'dd/MM/yyyy', 
                                                                'iw' => 'dd/MM/yyyy', 
                                                                'iw_IL' => 'dd/MM/yyyy', 
                                                                'ja' => 'yyyy/MM/dd', 
                                                                'ja_JP' => 'yyyy/MM/dd', 
                                                                'ka' => 'm/d/yyyy', 
                                                                'ka_GE' => 'm/d/yyyy', 
                                                                'kk_KZ' => 'M/d/yyyy', 
                                                                'km_KH' => 'M/d/yyyy', 
                                                                'ko' => 'yyyy. M. d', 
                                                                'ko_KR' => 'yyyy. M. d', 
                                                                'lt_LT' => 'yyyy.M.d', 
                                                                'lv_LV' => 'yyyy.d.M', 
                                                                'ms_MY' => 'dd/MM/yyyy', 
                                                                'nl' => 'd-M-yyyy', 
                                                                'nl_BE' => 'd/MM/yyyy', 
                                                                'nl_NL' => 'd-M-yyyy', 
                                                                'nl_SR' => 'd-M-yyyy', 
                                                                'no' => 'dd.MM.yyyy', 
                                                                'no_NO' => 'dd.MM.yyyy', 
                                                                'pl' => 'yyyy-MM-dd', 
                                                                'pt' => 'dd-MM-yyyy', 
                                                                'pt_AO' => 'dd-MM-yyyy', 
                                                                'pt_BR' => 'dd/MM/yyyy', 
                                                                'pt_PT' => 'dd-MM-yyyy', 
                                                                'ro' => 'dd.MM.yyyy', 
                                                                'ro_RO' => 'dd.MM.yyyy', 
                                                                'ru' => 'dd.MM.yyyy', 
                                                                'ru_RU' => 'dd.MM.yyyy', 
                                                                'sh' => 'dd.MM.yyyy', 
                                                                'sh_BA' => 'dd.MM.yyyy', 
                                                                'sh_CS' => 'dd.MM.yyyy', 
                                                                'sk' => 'd.M.yyyy', 
                                                                'sl_SI' => 'd.M.yy', 
                                                                'sr' => 'd.M.yyyy', 
                                                                'sr_BA' => 'yyyy-MM-DD', 
                                                                'sr_CS' => 'D.m.yyyy', 
                                                                'sk_SK' => 'd.M.yyyy', 
                                                                'sl_SI' => 'd.M.y', 
                                                                'sv' => 'yyyy-MM-dd', 
                                                                'sv_SE' => 'yyyy-MM-dd', 
                                                                'th' => 'M/d/yyyy', 
                                                                'th_TH' => 'd/M/yyyy', 
                                                                'tr' => 'dd.MM.yyyy', 
                                                                'tr_TR' => 'dd.MM.yyyy', 
                                                                'uk' => 'dd.MM.yyyy', 
                                                                'uk_UA' => 'dd.MM.yyyy', 
                                                                'ur_PK' => 'd/M/yyyy', 
                                                                'ur_PK' => 'd/M/yyyy', 
                                                                'ur_PK' => 'M/d/yyyy', 
                                                                'vi' => 'dd/MM/yyyy', 
                                                                'vi_VN' => 'dd/MM/yyyy', 
                                                                'zh' => 'yyyy-M-d', 
                                                                'zh_CN' => 'yyyy-M-d', 
                                                                'zh_HK' => 'yyyy-M-d', 
                                                                'zh_TW' => 'yyyy/M/d'}; //holds the locale to timedate formats
        return locale_map; //return the map
    }

    /*
    Function to get the date format from custom setting 
    If custom setting doesn't have any date format then get the user locale.
    */
    public static String getDateFormat() {

        String dateFormat;
        Date_Format__c csDateFormat = Date_Format__c.getInstance();
        
        if(csDateFormat.Format__c != null) {

            dateFormat = csDateFormat.Format__c;

        } else {

            dateFormat = MapValues().containsKey(UserInfo.getLocale()) ? MapValues().get(UserInfo.getLocale())  : 'dd/MM/yyyy' ;
        }

        dateFormat = dateFormat.toUpperCase();
        
        return dateFormat;
    }

}