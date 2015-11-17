<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>EmailReferral</fullName>
        <description>EmailReferral</description>
        <protected>false</protected>
        <recipients>
            <field>p_email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>JobBoard/ReferJob</template>
    </alerts>
    <alerts>
        <fullName>Employee_Notification_on_Expiration_of_Referral</fullName>
        <description>Employee Notification on Expiration of Referral</description>
        <protected>false</protected>
        <recipients>
            <field>p_contact_lookup__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>JobBoard/Referral_Prior_Expiration</template>
    </alerts>
    <alerts>
        <fullName>Referral_Employee_Notification_on_Applied</fullName>
        <description>Referral Employee Notification on Applied</description>
        <protected>false</protected>
        <recipients>
            <field>r_contact_lookup__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>JobBoard/ReferralApplied</template>
    </alerts>
    <rules>
        <fullName>EmailReferral</fullName>
        <actions>
            <name>EmailReferral</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Referral__c.referral_type__c</field>
            <operation>notEqual</operation>
            <value>Lead</value>
        </criteriaItems>
        <criteriaItems>
            <field>Referral__c.referral_link__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>This workflow is used to notify the Prospect that they have been referred to a position.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Referral Employee Notification on Expiration</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Referral__c.expire_date__c</field>
            <operation>greaterOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <description>The employee will receive an email notification on a prospect who has not been hired a certain number of days prior to the referral expiration date.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Referral Employee Notification on Referral Applied</fullName>
        <actions>
            <name>Referral_Employee_Notification_on_Applied</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Referral__c.applied__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>The employee will receive an email notification on a referred candidate has been successfully applied.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
