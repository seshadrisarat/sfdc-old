/**
* @author Alan Talanoa, Tamarack Consulting, Inc.
* @date 07/14/2014
* @description This class is effectively a struct for UCC data coming from CSC
* ©Copyright 2003 - 2014 Tamarack Consulting, Inc.  All Rights Reserved.
*/
public class Ucc {
	public Boolean isSelected{get;set;}
	public String id{get;set;}
	public String name{get;set;}
	public String filingDate{get;set;}
	public String collateral{get;set;}
	public String DebtorName{get;set;}
	public String DebtorAddress1{get;set;}
	public String DebtorCity{get;set;}
	public String DebtorState{get;set;}
	public String DebtorZip{get;set;}
	public String SecuredAddress1{get;set;}
	public String SecuredCity{get;set;}
	public String SecuredState{get;set;}
	public String SecuredZip{get;set;}
	public String FilingCat{get;set;}
	public String FilingDateExp{get;set;}
	public String OrigFilingNum{get;set;}
	public String FilingNum{get;set;}
	public String OrigFilingDate{get;set;}
	public String OrigFilingCat{get;set;}

	
	public Ucc() {
    collateral = '';
    name = '';
    isSelected = false;
    FilingDate = '';
    DebtorName = '';
    DebtorAddress1 = '';
    DebtorCity = '';
    DebtorState = '';
    DebtorZip = '';
    SecuredAddress1 = '';
    SecuredCity = '';
    SecuredState = '';
    SecuredZip = '';
    FilingCat = '';
    FilingDateExp = '';
    OrigFilingNum = '';
    FilingNum = '';
    OrigFilingDate = '';
    OrigFilingCat = '';
  }
}