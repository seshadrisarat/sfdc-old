//S-144144 - Created by Anuradha Suthar on 9/24/2013
//Class is created to send claim ownership notification to Account Owner and User who claimed (current user)
Global class AccountUtility{
  //send claim ownership notification to Account Owner and User who claimed (current user)
  webservice static void sendClaimOwnershipEmail(String accountID){ 
    //Get Account Detail
    Account acc = new Account();
    acc = [Select id, owner.email, owner.name, name from Account where id = :accountID]; 
    String previousOwner = acc.owner.name;
    
    //Update Account Owner with user who claimed ownership
    acc.ownerID = UserInfo.getUserID();
    update acc;
    
    //Set Email detail
    List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    mail.setToAddresses(new String[] {acc.owner.email});
    mail.setCcAddresses(new String[] {UserInfo.getUserEmail()});
    mail.setSubject('Ownership: ' + acc.name);   
    mail.setPlainTextBody(previousOwner +',\n\nRecord ownership of Company '+acc.name+' has been claimed by '+UserInfo.getName()+
                    ' who is now the new owner. If you have any questions about this change, please contact '+UserInfo.getName()+'.\n\nThank you,\nGAPS team');
    mails.add(mail);
    //Send email -- AA Disabled on 03-18-14 by request
    //Messaging.sendEmail(mails);    
  }
}