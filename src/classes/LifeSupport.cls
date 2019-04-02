public class LifeSupport {
  
    //Variable declaration and initialization
    public String regID { get; set;}
    public List<Patients__c> patientList{get;set;} //List of patients
    public List<Contact> ListHostpitals = new List<Contact>();//list of doctors
    
    //Getter
    public List<Contact> getListHostpitals(){
        return ListHostpitals;
    }
    
    //setter
    public void setListHostpitals(List<Contact> temp)
    {
        ListHostpitals = temp;
    }
    
    //Method to search list of hospitals    
    public PageReference search() {
        if (String.isBlank(regID)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter Registertion ID. If you are not a registered user,<a href="/apex/eCRM_Survey">Click here</a>'));
        
        }
        else{
            if(regID != null){
                patientList = [select id, Name, City__c from Patients__c where Name =: regID];
            }

            if(patientList.size() > 0 && !String.isBlank(patientList[0].city__c)){
                ListHostpitals = [Select id,name,phone, MobilePhone,MailingCity, Email,Account.Name,Speciality__c from contact where MailingCity =: patientList[0].city__c]; 
            }
            else
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Incorrect Registration ID.<a href="/apex/eCRM_Survey">Click here</a> to register'));
            
            
            }
            return null;
        }
        
    //Method to send emails to contacts    
    public PageReference send() {
        try{
            List <Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
            EmailTemplate temp = [select id from EmailTemplate where developername = 'LifeSupport_Email_to_Contact'];
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            
            system.debug('email of dr'+ApexPages.currentPage().getParameters().get('doctor'));
            
            email.setTargetObjectId(ApexPages.currentPage().getParameters().get('doctor'));
            
            if(temp != null){
                email.setTemplateId(temp.id);
            }
            
            if(patientList.size()>0)
                email.setWhatId(patientList[0].id);
            
            emailList.add(email);
            
            if(emailList.size() > 0){
                Messaging.sendEmail(emailList);
            }
        }
        catch(Exception e)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
            
        }
        return null;
    }

    

   
    
}