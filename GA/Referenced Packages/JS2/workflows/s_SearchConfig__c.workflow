<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ResumeSearchDataSpaceNotification</fullName>
        <description>Resume Search Data Space Notification</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>System_Templates/SUPPORT_Search_Data_Limit</template>
    </alerts>
    <rules>
        <fullName>Search Data Space Alert</fullName>
        <actions>
            <name>ResumeSearchDataSpaceNotification</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Workflow activated when a set limit of search Result Items is reached. Due to data space limits the result items must be deleted when limits are reached.</description>
        <formula>result_item_count__c &gt;  result_item_limit__c</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
