public with sharing class MDFDataModel {
        public static final String SUBSCRIBER_ORG_ID_FIELD_NAME = 'subscriberOrgId';
        public static final String SUBSCRIBER_ORG_STATUS_FIELD_NAME = 'subscriberOrgStatus';
        public static final String RESOURCE_NAME_FIELD_NAME = 'resourceName';
        public static final String RESOURCE_COUNT_FIELD_NAME = 'resourceCount';
        
        public String subscriberOrgId{get; private set;}
        public String subscriberOrgStatus{get; private set;}
        public String resourceName{get; private set;}
        public Integer resourceCount{get; private set;}
        
        public MDFDataModel(String subscriberOrgId, String subscriberOrgStatus, String resourceName, String resourceCount) {        
            this.subscriberOrgId = subscriberOrgId;
            this.subscriberOrgStatus = subscriberOrgStatus;
            
            /* we want to strip everything before the last slash 
             * (basically elinate the 'apex/' in the normal page name of 'apex/fooPage') */
            Integer lastSlash = resourceName != null ? resourceName.lastIndexOf('/') : -1;
            if (lastSlash != -1){
                this.resourceName = resourceName.substring(lastSlash+1, resourceName.length());
            }
            else {
                this.resourceName = resourceName;
            }
            this.resourceCount = resourceCount != null && resourceCount.isNumeric() ? Integer.valueOf(resourceCount) : null;
        }
}