/* Batch class to send notification to user when profile changes are done by any user
Created date : 21st Sept 17
*/

global class SendEmailonProfileUpdateBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    //class variables
    global String Query;
    global List<SetupAuditTrail> atList;
    global final String ADMINBUSINESSGROUP; 
    global final String DURATION;
    
    //constructor
    global SendEmailonProfileUpdateBatch(){
        atList = new List<SetupAuditTrail>();
        ADMINBUSINESSGROUP = 'AdminBusinessGroup';
        DURATION = 'This_week';
        Query = 'SELECT Id, Action, CreatedDate, CreatedBy.Name,Display,ResponsibleNamespacePrefix,Section from SetupAuditTrail ';
        Query += 'where CreatedDate <='+ DURATION + ' and (Action like \'%profile%\' or Action like \'%perm%\') order by CreatedDate desc ';
    }
    
    //Start method
    global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('Query == '+Query);
        return Database.getQueryLocator(query);
    }
    
    //execute method 
    global void execute(Database.BatchableContext BC, List<sObject> scope){              
       
        for(sobject s : scope){
            SetupAuditTrail sa = (SetupAuditTrail)s;   
            atList.add(sa);
        }
      
        
    }
    
    //finish method
    global void finish(Database.BatchableContext BC){
        try{
        	exportToCsv(atList);
        }catch(Exception e){
            System.debug('The Exception occured is '+e.getMessage());
        }
    }

/**
* @author      : Anupam Tripathi
* @date        : 9/21/2017
* @description : Method to Prepare CSV for setup audit trial Result and send it in an email
* @param1      : List<sObject>
* @param2      : 
* @return      : 
*/
   
    private void exportToCsv(List<sObject> atList){
        String generatedCSVFile ='';
        String header ='';
        
        Integer percentCovered = 0;
        Integer totalLine = 0;
        Integer NumLinesCovered = 0;
        Integer NumLinesUncovered = 0;
        
        header = 'AuditTrialId';
        header = header +','+ 'Action';
        header = header +','+ 'Display';
        header = header +','+ 'Section';
        header = header +','+ 'CreatedBy';
        header = header +','+ 'CreatedDate'+'\n';
        generatedCSVFile = generatedCSVFile + header;
        
        for(sObject eachat: atList){
            SetupAuditTrail sa = (SetupAuditTrail)eachat;
            String fileRow = sa.id;		
            fileRow = fileRow +','+ sa.Action;
            fileRow = fileRow +','+ sa.Display;
            fileRow = fileRow +','+ sa.Section;
            fileRow = fileRow +','+ sa.CreatedBy.Name;
            fileRow = fileRow +','+ sa.CreatedDate;
            fileRow = fileRow + '\n';    
            generatedCSVFile = generatedCSVFile + fileRow;
        }
        
        //Sending Email
        Messaging.EmailFileAttachment csvAttachment = new Messaging.EmailFileAttachment();
        Blob csvBlob = blob.valueOf(generatedCSVFile);
        String csvName = 'SetAuditTrialResult_' + System.today().format() + '.csv';
        csvAttachment.setFileName(csvName);
        csvAttachment.setBody(csvBlob);
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        //Set Your Email IDs in Below Line - EmailSetting
        //String[] toAddresses = new String[]{'anupam.tripathi@niit-tech.com'};
        String subject = 'Setup Audit trial for week ' + (System.today() - 7).format() + ' - ' + System.today().format();
        email.setSubject(subject);
        email.setToAddresses(fetchUsersFromGroup());
        String emailBody = 'Hi \n Please find attached the setup Audit Trial for the week '+ (System.today() - 7).format() + ' - ' + System.today().format();
        emailBody = emailBody + '\n Thanks \n Admin Support';
        email.setPlainTextBody(emailBody);
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttachment});
        Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
        
    }

/**
* @author      : Anupam Tripathi
* @date        : 9/21/2017
* @description : Method to fetch user's email id from a public group
* @param1      : 
* @param2      : 
* @return      : List<String>
*/    
    private List<String> fetchUsersFromGroup(){
        List<Id> usersIdsInGroup= new List<Id>();
		List<GroupMember> groupMembers=[Select Id, group.type, UserOrGroupId From GroupMember 
                                        where group.name = 'AdminBusinessGroup'];
		for(GroupMember gm : groupMembers)
		{
            if(String.valueof(gm.UserOrGroupId).startsWith('005')){
            	usersIdsInGroup.add(gm.UserOrGroupId);
            }
		}
        String[] toAddresses = new String[]{};
        
            for(User u : [select id, email from User where id in : usersIdsInGroup]){
                toAddresses.add(u.email);
            }
     		toAddresses.add('anupam.tripathi@niit-tech.com'); // remove after testing
        return toAddresses;   
    }
}