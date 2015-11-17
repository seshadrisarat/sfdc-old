<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Sends_email_to_the_Hiring_Manager_user</fullName>
        <description>Sends email to the Hiring Manager user.</description>
        <protected>false</protected>
        <recipients>
            <field>HiringManager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Jobscience_Submittal_Templates/Submittal_Review_Process</template>
    </alerts>
    <fieldUpdates>
        <fullName>Reveiw_Sent</fullName>
        <description>This populates the Review Sent Date/Time field.</description>
        <field>ReviewSent__c</field>
        <formula>now()</formula>
        <name>Reveiw Sent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Immediate Submittal Review Process</fullName>
        <actions>
            <name>Sends_email_to_the_Hiring_Manager_user</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Reveiw_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Submittal__c.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>This Workflow is designed to initiate the Submittal Review Process immediately upon creation of the Submittal Record.  An Email will be generated to the Manager on the Submittal Record, which allows them to approve/reject the candidate.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>OnDemand Submittal Review Process</fullName>
        <actions>
            <name>Sends_email_to_the_Hiring_Manager_user</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Reveiw_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Submittal__c.Initiate_SRP__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>This Workflow is designed to initiate the Submittal Review Process based on the Submittal Record.  An Email will be generated to the Manager on the Submittal Record, which allows them to approve/reject the candidate.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
