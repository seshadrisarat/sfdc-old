/*
* @author : sfdcdev, Tamarack Consulting, Inc.
* @date : 02/09/2015
* @description: Util class for getting data. 
*
* © Copyright 2003 - 2015 Tamarack Consulting, Inc.  All Rights Reserved.
* 
*/



public without sharing class TC_DataUtility {

	public static String createSelectAllString (String sobjectApiName, String whereClause, String limitClause, String orderByClause, Set <String> additionalFields) {

        Map<String, Schema.SObjectField> fldObjMap = Schema.getGlobalDescribe().get(sObjectApiName).getDescribe().fields.getMap();
 		Set <String> fieldsSet = new Set <String> ();

 		if (additionalFields != null && !additionalFields.isEmpty())
 			fieldsSet.addAll(additionalFields);

 		fieldsSet.addAll(fldObjMap.keySet());
       
        String queryString = 'SELECT ';
        
        for(String s : fieldsSet) { 
           queryString += s + ',';
        }
 
        // Trim last comma
        queryString = queryString.removeEnd(',');
 
        // Finalize query string
        queryString += ' FROM ' + sObjectApiName;
        

        if (!String.isEmpty(whereClause)) {
            queryString += ' WHERE ';
            queryString += whereClause;

        }

        if (!String.isEmpty(orderByClause)) {
         	queryString += ' ORDER BY ' + orderByClause;
        }

        if (!String.isEmpty(limitClause)) {
            queryString += ' LIMIT ' + limitClause ;
        }

        return queryString;
	}


    //this method is needed for getting team data to display on the individual dashboard
    public static AnnualGoals__c getTeamAnnualGoal (String queryString) {
        return Database.query(queryString);
    }
}