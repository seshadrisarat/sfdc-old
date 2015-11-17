/**
 * \author Vladimir Dobrelya
 * \date Nov 20, 2014
 * \brief The upper layer of the describe logic
 * \see https://silverline.jira.com/browse/HL-53
 */
public with sharing class SL_Describe {

	public static Schema.SObjectType getToken( String sObjectName ) {
		return SL_DescribeTokens.get( sObjectName );
	}

	public static Schema.SObjectField getToken( String sObjectName, String fieldName ) {
		return SL_DescribeTokens.get( sObjectName, fieldName );
	}

	public static Schema.DescribeSObjectResult getDescribe( String sObjectName ) {
		return SL_DescribeResults.get( sObjectName );
	}

	public static Schema.DescribeFieldResult getDescribe( String sObjectName, String fieldName ) {
		return SL_DescribeResults.get( sObjectName, fieldName );
	}

	public static Boolean isExisting( String sObjectName ) {
		return SL_DescribeTokens.isExisting( sObjectName );
	}

	public static Boolean isExisting( String sObjectName, String fieldName ) {
		return isExisting( sObjectName, fieldName, false );
	}

	public static Boolean isAccessible( String sObjectName ) {
		return isExisting( sObjectName ) && getDescribe( sObjectName ).isAccessible();
	}

	public static Boolean isAccessible( String sObjectName, String fieldName ) {
		return isExisting( sObjectName, fieldName ) && getDescribe( sObjectName, fieldName ).isAccessible();
	}

	public static Boolean isUpdateable( String sObjectName ) {
		return isExisting( sObjectName ) && getDescribe( sObjectName ).isUpdateable();
	}

	public static Boolean isUpdateable( String sObjectName, String fieldName ) {
		return isExisting( sObjectName, fieldName ) && getDescribe( sObjectName, fieldName ).isUpdateable();
	}

	public static Boolean isSortable( String sObjectName, String fieldName ) {
		return isExisting( sObjectName, fieldName ) && getDescribe( sObjectName, fieldName ).isSortable();
	}

	public static Boolean isFilterable( String sObjectName, String fieldName ) {
		return isExisting( sObjectName, fieldName ) && getDescribe( sObjectName, fieldName ).isFilterable();
	}

	public static Boolean isRequired( String sObjectName, String fieldName ) {
		if ( !isExisting( sObjectName, fieldName ) ) {
			return false;
		}
		Schema.DescribeFieldResult fieldDescribe = getDescribe( sObjectName, fieldName );
		return fieldDescribe.isCreateable() && !fieldDescribe.isNillable() && !fieldDescribe.isDefaultedOnCreate();
	}

	public static Schema.DisplayType getType( String sObjectName, String fieldName ) {
		return isExisting( sObjectName, fieldName ) ? getDescribe( sObjectName, fieldName ).getType() : null;
	}

	public static String getRelationshipName( String sObjectName, String fieldName ) {
		return isExisting( sObjectName, fieldName ) ? getDescribe( sObjectName, fieldName ).getRelationshipName() : null;
	}

	public static String getReferenceTo( String sObjectName, String fieldName ) {
		if ( getType( sObjectName, fieldName ) == DisplayType.REFERENCE ) {
			for ( Schema.SObjectType objectType : getDescribe( sObjectName, fieldName ).getReferenceTo() ) {
				return String.valueOf( objectType );
			}
		}
		return null;
	}



	// use for the fields with dot notation like: Field1__r.Field2__r.Field__c
    public static Boolean isExisting( String sObjectName, String fieldName, Boolean dotNotation ) {
        if ( dotNotation ) {
            return validateFieldName( sObjectName, fieldName ) == null; 
        }
        return SL_DescribeTokens.isExisting( sObjectName, fieldName );
    }

    public static String validateFieldName( String sObjectName, String fieldName ) {
    	return validateFieldName( sObjectName, fieldName.split( '\\.' ) ); 
    }

    public static String validateFieldName( String sObjectName, String fieldName, String errorFormat ) {
    	return validateFieldName( sObjectName, fieldName.split( '\\.' ), errorFormat ); 
    }

    public static String validateFieldName( String sObjectName, List<String> fieldParts ) {
    	return validateFieldName( sObjectName, fieldParts, null ); 
    }

    public static String validateFieldName( String sObjectName, List<String> fieldParts, String errorFormat ) {
        if ( !isExisting( sObjectName ) ) {
        	return 'Invalid object name: ' + sObjectName;
        }
        if ( fieldParts == null || fieldParts.isEmpty() ) {
            return 'Invalid fieldParts: ' + fieldParts;
        }
        if ( String.isBlank( errorFormat ) ) {
    		errorFormat = 'The {0} object has no {1} field.';
    	}
        
        String curObjectName = sObjectName, curFieldName = null, referenceTo = sObjectName; // referenceTo is used for exception building

        for ( String fieldPart : fieldParts ) {
        	if ( referenceTo == null ) {
        		return String.format( 'The {0} object has no {1} field with REFERENCE type.', new List<String>{ curObjectName, curFieldName } );
        	}
        	curObjectName = referenceTo;
            curFieldName = getFieldNameByRelationshipName( curObjectName, fieldPart );
            if ( !isExisting( curObjectName, curFieldName ) ) { // when Field1__c.Field2__c.Field__c
	           return String.format( errorFormat, new List<String>{ curObjectName, curFieldName } );
	        }
            referenceTo = getReferenceTo( curObjectName, curFieldName );
        }
        return null;
    }

    public static String getFieldNameByRelationshipName( String sObjectName, String relationshipFieldName ) {
        if ( String.isBlank( relationshipFieldName ) ) {
            return null;
        }

        if ( !relationshipFieldName.endsWithIgnoreCase( '__c' ) ) {
            if ( relationshipFieldName.endsWithIgnoreCase( '__r' ) && isExisting( sObjectName, relationshipFieldName.substring( 0, relationshipFieldName.length() - 3 ) + '__c' ) ) {
            	relationshipFieldName = relationshipFieldName.substring( 0, relationshipFieldName.length() - 3 ) + '__c';
                //relationshipFieldName = relationshipFieldName.replace( '__r', '__c' );
            } else if ( !relationshipFieldName.endsWithIgnoreCase( 'id' ) && isExisting( sObjectName, relationshipFieldName + 'Id' ) ) {
                relationshipFieldName = relationshipFieldName + 'Id';
            }
        }
        return relationshipFieldName;
    }

	/*public static String getRelationshipFieldName( String sObjectName, String relatedTo ) {
		if ( isExisting( sObjectName ) && isExisting( relatedTo ) ) {
			for ( Schema.ChildRelationship relationship : getDescribe( relatedTo ).getChildRelationships() ) {
			    if ( String.valueOf( relationship.getChildSObject() ).equalsIgnoreCase( sObjectName ) ) {
			        return String.valueOf( relationship.getField() ).toLowerCase();
			    }
			}
		}
		return null;
	}*/
}