/**
 * \author Vladimir Dobrelya
 * \date Nov 21, 2014
 * \brief Util-class to work with Describe Tokens [ Lazy-loading pattern ]
 */
public class SL_DescribeTokens {
	private static Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
	private static Map<Schema.SObjectType, Map<String, Schema.SObjectField>> objectFields = new Map<Schema.SObjectType, Map<String, Schema.SObjectField>>();

	// returns an object token for object which name = sObjectName
	public static Schema.SObjectType get( String sObjectName ) {
		return globalDescribe.get( sObjectName );
	}

	// returns a field token for field which name = fieldName 
	public static Schema.SObjectField get( String sObjectName, String fieldName ) {
		if ( String.isBlank( sObjectName ) || String.isBlank( fieldName ) ) {
			return null;
		}
		Schema.SObjectType objectToken = get( sObjectName );
		if ( objectToken == null ) {
			return null;
		}
		if ( !objectFields.containsKey( objectToken ) ) {
			objectFields.put( objectToken, SL_DescribeResults.get( objectToken ).fields.getMap() ); // must be exactly describe.fields.getMap(), because it is a "magical" stangard and case insensetive map
		}
		return objectFields.get( objectToken ).get( fieldName );
	}

	public static Boolean isExisting( String sObjectName ) {
		return globalDescribe.containsKey( sObjectName );
	}

	public static Boolean isExisting( String sObjectName, String fieldName ) {
		return get( sObjectName, fieldName ) != null;
	}
}