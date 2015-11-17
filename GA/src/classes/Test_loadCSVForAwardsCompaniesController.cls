/*******************************************************************************
Name : Test_loadCSVForAwardsCompaniesController
Created By : Hemant (Appirio Offshore)
Created Date : 18th June,2013
Description : Test coverage of loadCSVForAwardsCompaniesController class 
*******************************************************************************/
@isTest
private class Test_loadCSVForAwardsCompaniesController{
	
	 @isTest
   static void loadCSVAwardsTest(){
   	
   	loadCSVForAwardsCompaniesController loadCSVCont = new loadCSVForAwardsCompaniesController();
   	//testing null case
   	loadCSVCont.loadAwrdData();
   	
   	//testing with data
   	loadCSVCont.awrdNameFile = 'Test_CSV_File_for_Awards.csv';
   	loadCSVCont.awrdContentFile = Blob.valueOf('Name,Type,Description,Link,Source,Publication Date\ntest award 10/6.1,Award,test awrd desc,test link,award src,2013-06-10\ntest Conference 10/6.1,Conference,test conference desc,test link,Conference src,2013-06-20');
   	loadCSVCont.loadAwrdData();
   	
   	//testing for exception
   	loadCSVCont.awrdContentFile = Blob.valueOf('Name,Type,Description,Link,Source,Publication Date\ntest award 10/6.1,Award,test awrd desc,test link,award src,20130610');
   	loadCSVCont.loadAwrdData();
   	
   }
   
   @isTest
   static void loadCSVCompaniesTest(){
   	
   	loadCSVForAwardsCompaniesController loadCSVCont = new loadCSVForAwardsCompaniesController();
   	//testing null case
   	loadCSVCont.loadCompanyData();
   	
   	//testing with data
   	loadCSVCont.compNameFile = 'Test_CSV_File_for_Companies.csv';
   	loadCSVCont.compContentFile = Blob.valueOf('Company Name,GA Sector,Source,Description,Rank,Company Financial Type,Company Financial Year,Revenue (MM),Data Source,Data Source (Other)\ntest Company 11/6.1,Finance,Award List,test desc 11/6.1,1,Estimated,2013,1000,Capital IQ,test other src1\ntest Company 11/6.2,Healthcare,Award List,test desc 11/6.2,2,Actual,2014,1001,Capital IQ,test other src2');
   	loadCSVCont.loadCompanyData();
   	
   	//testing for exception
   	loadCSVCont.compContentFile = Blob.valueOf('Company Name,GA Sector,Source,Description,Rank,Company Financial Type,Company Financial Year,Revenue (MM),Data Source,Data Source (Other)\ntest Company 11/6.1,Finance,Award List,test desc 11/6.1,x,Estimated,2013,1000,Capital IQ,test other src1');
   	loadCSVCont.loadCompanyData();
   	
   }
}