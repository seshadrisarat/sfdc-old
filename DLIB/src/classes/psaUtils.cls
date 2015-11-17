/*
 * \author Vladimir Dobrelya
 * \date Jan 30, 2014
 */
public with sharing class psaUtils {
	
	public static ID idRTChildTask {
        get {
            if ( idRTChildTask == null ) {
                for ( RecordType oItem : [ SELECT Id FROM RecordType WHERE sObjectType = 'pse__Milestone__c' AND DeveloperName = 'CHILD_TASK' limit 1 ] ) {
                    idRTChildTask = oItem.Id;
                }
                if ( idRTChildTask == null ) {
                    throw new RecordTypeNotFoundException( 'Couldn\'t find CHILD_TASK RecordType for pse__Milestone__c object' );
                }
            }
            return idRTChildTask;
        } set;
    }

    public static ID idRTParentTask {
        get {
            if ( idRTParentTask == null ) {
                for ( RecordType oItem : [ SELECT Id FROM RecordType WHERE sObjectType = 'pse__Milestone__c' AND DeveloperName = 'PARENT_TASK' limit 1 ] ) {
                    idRTParentTask = oItem.Id;
                }
                if ( idRTParentTask == null ) {
                    throw new RecordTypeNotFoundException( 'Couldn\'t find PARENT_TASK RecordType for pse__Milestone__c object' );
                }
            }
            return idRTParentTask;
        } set;
    }

    public static ID idRTBillable {
        get {
            if ( idRTBillable == null ) {
                for ( RecordType oItem : [ SELECT Id FROM RecordType WHERE sObjectType = 'pse__Milestone__c' AND DeveloperName = 'BILLABLE' limit 1 ] ) {
                    idRTBillable = oItem.Id;
                }
                if ( idRTBillable == null ) {
                    throw new RecordTypeNotFoundException( 'Couldn\'t find BILLABLE RecordType for pse__Milestone__c object' );
                }
            }
            return idRTBillable;
        } set;
    }

    public static ID idRTOpportunityChangeOrders {
        get {
            if ( idRTOpportunityChangeOrders == null ) {
                for ( RecordType oItem : [ SELECT Id FROM RecordType WHERE sObjectType = 'Opportunity' and DeveloperName = 'Change_Orders' limit 1 ] ) {
                    idRTOpportunityChangeOrders = oItem.Id;
                }
                if ( idRTOpportunityChangeOrders == null ) {
                    throw new RecordTypeNotFoundException( 'Couldn\'t find Change_Orders RecordType for Opportunity object' );
                }
            }
            return idRTOpportunityChangeOrders;
        } set;
    }

    public static ID idRTOpportunityServices {
        get {
            if ( idRTOpportunityServices == null ) {
                for ( RecordType oItem : [ SELECT Id FROM RecordType WHERE sObjectType = 'Opportunity' and DeveloperName = 'Services' limit 1 ] ) {
                    idRTOpportunityServices = oItem.Id;
                }
                if ( idRTOpportunityServices == null ) {
                    throw new RecordTypeNotFoundException( 'Couldn\'t find Services RecordType for Opportunity object' );
                }
            }
            return idRTOpportunityServices;
        } set;
    }

    public static Boolean refreshRecord( sObject oRecord, Map<String, object> aFieldMapping ) {
        Boolean bResult = false;
        
        for ( String sFieldName : aFieldMapping.keySet() ) {
            if ( oRecord.get( sFieldName ) != aFieldMapping.get( sFieldName ) ) {
                oRecord.put( sFieldName, aFieldMapping.get( sFieldName ) );
                bResult = true;
            }
        }
        
        return bResult;
    }

    public static String cutString( String sValue, Integer nLength ) {
        if ( sValue == null || sValue.length() <= nLength ) {
            return sValue;
        }
        return sValue.left( nLength );
    }

    public static void addPageErrorMessage( String sMessage ) {
        addPageMessage( ApexPages.Severity.ERROR, sMessage );
        system.debug( LoggingLevel.ERROR, sMessage );
    }

    public static void addPageInfoMessage( String sMessage ) {
        addPageMessage( ApexPages.Severity.INFO, sMessage );
        system.debug( LoggingLevel.INFO, sMessage );
    }

    private static void addPageMessage( ApexPages.Severity oSeverity, String sMessage ) {
        ApexPages.addMessage( new ApexPages.Message( oSeverity, sMessage ) );
    }


    public static void debug( Exception e ) {
        debug( e, null );
    }

    public static void debug( Exception e, String sAdditionalMessage ) {
        if ( String.isBlank( sAdditionalMessage ) ) {
            debug( LoggingLevel.ERROR, e.getMessage() + '; trace: ' + e.getStackTraceString() );
        } else {
            debug( LoggingLevel.ERROR, e.getMessage() + '; trace: ' + e.getStackTraceString() + '\n' + sAdditionalMessage );
        }
    }

    public static void debug( LoggingLevel oLoggingLevel, String sMessage ) {
        system.debug( oLoggingLevel, sMessage );
    }

    private class RecordTypeNotFoundException extends Exception { }
}