<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>PeopleStatus</fullName>
        <description>This will update the People Status to active when one is created through TalentStaffing or through an Import when not populated.</description>
        <field>People_Status__c</field>
        <literalValue>Active</literalValue>
        <name>People Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>People Status Update</fullName>
        <actions>
            <name>PeopleStatus</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.People_Status__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>This will update the People Status to active when one is created through TalentStaffing or through an Import when not populated.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
