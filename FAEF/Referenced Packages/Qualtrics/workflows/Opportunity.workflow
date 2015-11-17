<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <outboundMessages>
        <fullName>Qualtrics_Example_Outbound_Message</fullName>
        <apiVersion>19.0</apiVersion>
        <description>An example of how to setup an outbound message. 
The endpoint url is not valid and needs to be updated to a real out endpoint url.</description>
        <endpointUrl>http://survey.qualtrics.com/WRQualtricsServer/sfApi.php?r=outboundMessage&amp;u=UR_123456789&amp;s=SV_123456789&amp;t=TR_123456789</endpointUrl>
        <fields>Id</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>mark.tomaselli@faef.com</integrationUser>
        <name>Qualtrics Example Outbound Message</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>Qualtrics Example Survey Rule</fullName>
        <actions>
            <name>Qualtrics_Example_Outbound_Message</name>
            <type>OutboundMessage</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.IsClosed</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>An example of how to setup a rule to trigger a survey using an outbound message.  
In this example when an opportunity is closed we want to email the opportunity and see how their interaction with the sales representative went.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
