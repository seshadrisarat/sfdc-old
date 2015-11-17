/**
 * Dynamic autocomplete functionality
 * Originally from http://www.verticalcoder.com/2011/02/19/salesforce-javascript-remoting-jquery-and-autocomplete
 * with some improvements.
 *
 * @author Daniel Hoechst - original
 * @author ForceLogic - improvements (Company Referrals - Referred From)
 * @author jfavors (Appirio) - polish
 */
global class LookupAutocompleteController {

  @RemoteAction
  global static SObject[] findSObjects(String obj, String query,
      String additionalFields) {
    if (String.isBlank(obj)) {
      return null;
    }

    String filter;
    List<String> fieldList;
    List<SObject> results = new List<SObject>();

    // more than one field can be passed in the additionalFields parameter
    // split it into an array for later use
    if (String.isNotBlank(additionalFields)) {
      fieldList = additionalFields.split(',');
    }

    // check to see if the object passed is valid
    Map<String, Schema.SObjectType> describe = Schema.getGlobalDescribe();
    Schema.SObjectType objectType = describe.get(obj);

    if (objectType == null) {
      // Object name not valid
      return null;
    }

    // create the filter text
    if (String.isNotBlank(query)) {
    	filter = ' like \'%' + String.escapeSingleQuotes(query) + '%\'';
    }

    //begin building the dynamic soql query
    String soql = 'select Id, Name';

    // if an additional field was passed in add it to the soql
    if (fieldList != null) {
      for (String field : fieldList) {
        soql += ', ' + field;
      }
    }

    // add the object and filter by name to the soql
    soql += ' from ' + obj;

    if (filter != null) {
    	soql += ' where name' + filter;
    }

    // add the filter by additional fields to the soql
    if (fieldList != null) {
      for (String field : fieldList) {
        soql += ' or ' + field + filter;
      }
    }

    soql += ' order by Name limit 20';

    try {
      results = Database.query(soql);
    } catch (QueryException e) {
      return null;
    }

    return results;
   }
}