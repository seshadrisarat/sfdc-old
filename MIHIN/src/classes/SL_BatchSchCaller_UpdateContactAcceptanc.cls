/*
*Class: SL_BatchSchCaller_UpdateContactAcceptanc
*Description: This will schedule the batch SL_UpdateContactAcceptanceDatetime to run hourly.
*Copyright 2013 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
public with sharing class SL_BatchSchCaller_UpdateContactAcceptanc 
{
	//This class calls Schedular
	public SL_BatchSchCaller_UpdateContactAcceptanc()
	{
		SL_BatchSchedule_UpdateContactAcceptance s = new SL_BatchSchedule_UpdateContactAcceptance();
       	String scheduleBatch = '0 0 * * * ?';
       	System.schedule('Update Contact Acceptance DateTime.', scheduleBatch, s); 
	} 
	
	@isTest
	static void testSL_BatchScheduleCaller_TempAccountTeam()
	{
		Test.startTest();
		SL_BatchSchCaller_UpdateContactAcceptanc testObj = new SL_BatchSchCaller_UpdateContactAcceptanc();
		Test.stopTest();    
	}
}