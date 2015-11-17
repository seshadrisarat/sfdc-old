<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Send_Email</fullName>
        <description>Send Email</description>
        <protected>false</protected>
        <recipients>
            <field>Notify_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Jobscience_System_Templates/Debug_Log</template>
    </alerts>
</Workflow>
