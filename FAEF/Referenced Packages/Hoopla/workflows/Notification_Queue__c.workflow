<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <outboundMessages>
        <fullName>Hoopla_Notification_Messaging</fullName>
        <apiVersion>23.0</apiVersion>
        <endpointUrl>https://hoopla-notify.herokuapp.com/notify</endpointUrl>
        <fields>CreatedDate</fields>
        <fields>Id</fields>
        <fields>Message_ID__c</fields>
        <fields>Message_Token__c</fields>
        <fields>Message_Type__c</fields>
        <fields>Message__c</fields>
        <includeSessionId>false</includeSessionId>
        <integrationUser>alan.cona@faef.com</integrationUser>
        <name>Hoopla Notification Messaging</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>Process Notifications</fullName>
        <actions>
            <name>Hoopla_Notification_Messaging</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Notification_Queue__c.Message_ID__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
