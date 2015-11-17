<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Send_Support_Request</fullName>
        <description>Send Support Request</description>
        <protected>true</protected>
        <recipients>
            <field>Support_Ticket_Recipient__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ExactTarget/SupportRequest</template>
    </alerts>
    <rules>
        <fullName>NewSupportRequest</fullName>
        <actions>
            <name>Send_Support_Request</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>true</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
