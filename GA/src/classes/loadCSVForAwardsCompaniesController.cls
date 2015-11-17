/************************************************************************************************************
* Name          : loadCSVForAwardsCompaniesController
* Created Date  : 5 June 2013
* Created By    : Appirio Offshore (Hemant)
* Description   : Controller Class for VF Pages: 
									- UploadCSVForAwards [To upload the records from the CSV file into Awards]
									- UploadCSVForCompanies [To upload the records from the CSV file into Companies]
* Related Story : S-117617
************************************************************************************************************/
public class loadCSVForAwardsCompaniesController {
	
	//constants
	private static final string ERROR_MSG_NO_FILE= 'No file is uploaded. Please upload the file.';
	
	//creating object of class loadCompaniesController
	public loadCompaniesController loadcompCont{get;set;}
	//creating object of class loadAwardsController
	public loadAwardsController loadAwrdCont;
	
	//constructor
	public loadCSVForAwardsCompaniesController(){
		
		loadcompCont = new loadCompaniesController();
		loadAwrdCont = new loadAwardsController();
	}
    
	public string awrdNameFile{get;set;}
	public string compNameFile{get;set;}
  public Blob awrdContentFile{get;set;}
  public Blob compContentFile{get;set;}
  String[] filelines = new String[]{};
    
  /******************************************************************************
  Method to load the Awards using the file uploaded by user
  ******************************************************************************/  
  public PageReference loadAwrdData(){
  	
  	if(awrdNameFile == null || awrdNameFile == '' || awrdContentFile == null){
  		ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error, ERROR_MSG_NO_FILE));
  		return null;
  	}
  	try{
	  	awrdNameFile=awrdContentFile.toString();
	    filelines = awrdNameFile.split('\n');
	    loadAwrdCont.awards = new List<Conference_Award__c>();
	    
	    for (Integer i=1;i<filelines.size();i++){
		    String[] inputvalues = new String[]{};
		    if(filelines[i] != null && filelines[i] != '' && filelines[i].contains(',')){
		    	inputvalues = filelines[i].split(',');
		    
			    Conference_Award__c confAward = new Conference_Award__c(Type__c = 'Award',Date__c = date.newinstance(Date.Today().Year(), 1, 1) , End__c = date.newinstance(Date.Today().Year(),12,31));
			    
			    confAward.Name = inputvalues[0];
			    confAward.Type__c = inputvalues[1];       
			    confAward.Description__c = inputvalues[2];
			    confAward.Source_URL__c = inputvalues[3];
			    confAward.Source_List__c = inputvalues[4];
			    if(inputvalues[5] != null && inputvalues[5] != ''){
			    	confAward.Date__c = Date.valueOf(inputvalues[5]);
			    }
		
		      loadAwrdCont.awards.add(confAward);
		    }
	    }
	    
	    if(loadAwrdCont.awards.size() > 0){
	 		 loadAwrdCont.UplaodAwards();
	    }
  	}catch(Exception ex){  
  		ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error, ex.getMessage()));
  	}
  	return null;
  }
  
  /******************************************************************************
  Method to load the load multiple companies and junction records for Awards/Companies using the file uploaded by user
  ******************************************************************************/  
  public PageReference loadCompanyData(){
  	
  	//If csv file is not selected then send a message and return.
  	if(compNameFile == null || compNameFile == '' || compContentFile == null){
  		ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error, ERROR_MSG_NO_FILE));
  		return null;
  	}
  	
  	try{
	    compNameFile=compContentFile.toString();
	    filelines = compNameFile.split('\n');
	
	    loadCompCont.objectList = new List<loadCompaniesController.wrapperClas>();
	    
	    for (Integer i=1;i<filelines.size();i++){
		    String[] inputvalues = new String[]{};
		    if(filelines[i] != null && filelines[i] != '' && filelines[i].contains(',')){
		    	inputvalues = filelines[i].split(',');
		    
			    loadCompaniesController.wrapperClas wrap = new loadCompaniesController.wrapperClas(loadCompCont.recordTypeID, null, null);
			    
			    wrap.companyName = inputvalues[0];
			    wrap.selectedGASector = inputvalues[1];       
			    wrap.selectedSource = inputvalues[2];
			    wrap.description = inputvalues[3];
			    if(inputvalues[4] != null && inputvalues[4] != ''){
			    	wrap.compConf.Rank__c = Decimal.valueOf(inputvalues[4]);
			    }
			    wrap.compFin.Type__c = inputvalues[5];
			    wrap.compFin.Year__c = inputvalues[6];
			    if(inputvalues[7] != null && inputvalues[7] != ''){
			    	wrap.compFin.Revenue_MM__c = Decimal.valueOf(inputvalues[7]);
			    }
			    wrap.compFin.Data_Source__c = inputvalues[8];
			    wrap.compFin.Data_Source_Other__c = inputvalues[9];
		
		      loadCompCont.objectList.add(wrap);
		    }
	    }
	    
	    if(loadCompCont.objectList.size() > 0){
	    	loadCompCont.UplaodCompanies();
	    }
  	}catch(Exception ex){  
  		ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error, ex.getMessage()));
  	}
    return null;  
  }
}