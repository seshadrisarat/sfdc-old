<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Invite_to_Apply_Email</fullName>
        <description>Invite to Apply Email</description>
        <protected>false</protected>
        <recipients>
            <field>Candidate_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Corp_Message_Candidate/Invite_to_Apply</template>
    </alerts>
    <alerts>
        <fullName>Send_Candidate_Hired_Email_to_Referred_Employee</fullName>
        <description>Send Candidate Hired Email to Referred Employee</description>
        <protected>false</protected>
        <recipients>
            <field>referred_by__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>JobBoard/Candidate_Status_Placement</template>
    </alerts>
    <alerts>
        <fullName>Send_Status_Change_Email_to_Referred_Employee</fullName>
        <description>Send Status Change Email to Referred Employee</description>
        <protected>false</protected>
        <recipients>
            <field>referred_by__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>JobBoard/Candidate_Status_Changed</template>
    </alerts>
    <fieldUpdates>
        <fullName>Disposition_Value_Update_to_1</fullName>
        <field>Disposition_Value__c</field>
        <literalValue>1</literalValue>
        <name>Disposition Value Update to 1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Disposition_Value_Update_to_2</fullName>
        <field>Disposition_Value__c</field>
        <literalValue>2</literalValue>
        <name>Disposition Value Update to 2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Disposition_Value_Update_to_3</fullName>
        <field>Disposition_Value__c</field>
        <literalValue>3</literalValue>
        <name>Disposition Value Update to 3</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Candidate Changed Stage</fullName>
        <actions>
            <name>Send_Status_Change_Email_to_Referred_Employee</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>The employee will receive updates via email on the candidate as their status changes during the hiring process.</description>
        <formula>NOT(ISBLANK(referred_by__c)) &amp;&amp; ISCHANGED(Stage__c ) &amp;&amp; NOT( ISPICKVAL(Stage__c , &quot;Placement&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Candidate Hired</fullName>
        <actions>
            <name>Send_Candidate_Hired_Email_to_Referred_Employee</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>The employee will receive updates vie email on the referred candidate if they are hired.</description>
        <formula>NOT(ISNULL(referred_by__c)) &amp;&amp; (ISPICKVAL( Application_Status__c , &apos;Hired&apos;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Disposition Value Update to 1</fullName>
        <actions>
            <name>Disposition_Value_Update_to_1</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This workflow updates the Application record with a Disposition Value = 1 when the Candidate is dispositioned/rejected within the system based on a specific Reject Reason.</description>
        <formula>(ISPICKVAL(Overall_Reject_Reason__c, &apos;Failed to Meet Basic Qualifications&apos;) || ISPICKVAL(Overall_Reject_Reason__c, &apos;Invited to Apply&apos;) || ISPICKVAL(Overall_Reject_Reason__c, &apos;Candidate Withdrew Interest&apos;) || ISPICKVAL(Overall_Reject_Reason__c, &apos;No Response&apos;) || ISPICKVAL(Overall_Reject_Reason__c, &apos;Not Eligible for Rehire&apos;) || ISPICKVAL(Overall_Reject_Reason__c, &apos;Offer Extended/Candidate Rejected&apos;) || ISPICKVAL(Overall_Reject_Reason__c, &apos;Hired&apos;)) &amp;&amp; !ISPICKVAL(Disposition_Value__c, &apos;1&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Disposition Value Update to 2</fullName>
        <actions>
            <name>Disposition_Value_Update_to_2</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This workflow updates the Application record with a Disposition Value = 2 when the Candidate is dispositioned/rejected within the system based on a specific Reject Reason.</description>
        <formula>(ISPICKVAL(Overall_Reject_Reason__c, &apos;Not Considered&apos;) || ISPICKVAL(Overall_Reject_Reason__c, &apos;Rolled Over&apos;) || ISPICKVAL(Overall_Reject_Reason__c, &apos;Not Hired, Consider for another position&apos;) || ISPICKVAL(Overall_Reject_Reason__c, &apos;&apos;)) &amp;&amp; !ISPICKVAL(Disposition_Value__c, &apos;2&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Disposition Value Update to 3</fullName>
        <actions>
            <name>Disposition_Value_Update_to_3</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This workflow updates the Application record with a Disposition Value = 3 when the Candidate is dispositioned/rejected within the system based on a specific Reject Reason.</description>
        <formula>(ISPICKVAL(Overall_Reject_Reason__c, &apos;Failed to meet preferred qualifications&apos;) || ISPICKVAL(Overall_Reject_Reason__c, &apos;More Qualified Candidate selected/no interview&apos;) || ISPICKVAL(Overall_Reject_Reason__c, &apos;More Qualified Candidate selected/phone interview&apos;) || ISPICKVAL(Overall_Reject_Reason__c, &apos;More Qualified Candidate selected/interview&apos;) || ISPICKVAL(Overall_Reject_Reason__c, &apos;More Qualified Candidate selected/background check&apos;)) &amp;&amp; !ISPICKVAL(Disposition_Value__c, &apos;3&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Invite to Apply</fullName>
        <actions>
            <name>Invite_to_Apply_Email</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Auto_Email_Invite_to_Apply</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Application__c.Invite_to_Apply__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Job__c.Post_Job__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Application__c.Completed__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow is used to email the Candidate Contact that they have been Invited to Apply to a position.  The email template used should contain a link to the Job Details page for the Job Order.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <tasks>
        <fullName>Auto_Email_Invite_to_Apply</fullName>
        <assignedToType>owner</assignedToType>
        <description>Standard Invite to Apply email sent to the Candidate contact using the email template name, Invite to Apply.

Dear {!Contact.Name}, 

{!User.Name} from {!User.Name} has invited you to apply to the following open Job Order. If you are interested.....</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Auto-Email: Invite to Apply</subject>
    </tasks>
</Workflow>
