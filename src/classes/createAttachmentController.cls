public class createAttachmentController {
    
    
    public createAttachmentController(){
        System.debug('Hello i am in create attachment constructor');
    }
    
    public PageReference create(){
        
        //System.debug([Select id, name from Patients__c]);
        
        System.debug('Hello i am in create attachment method');
        
        Attachment att = new Attachment();
        att.Name = 'test attachment';
        att.ParentId = '0039000001nr2Ka';
        att.Body = Blob.valueOf('This is testing');
        att.ContentType = 'pdf'; 
        
         
        try{
            System.debug('Attachment object : -'+att);
            insert att;
        }catch(exception e){
            ApexPages.addmessages(e);
        }
        
        return null;
    } 
    
}