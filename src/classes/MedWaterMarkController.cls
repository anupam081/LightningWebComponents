public with sharing class MedWaterMarkController {
    
    public Attachment att {
        get {
            if (att == null && attId != null) {
                att = [SELECT Body, ContentType, Name FROM Attachment WHERE ID = :attId];
            }
            return att;
        }
        private set;
    }
    
    /*
    public String pdf {
        get {
            return EncodingUtil.Base64Encode(att.body);
        }
    }
    */
    
    
    public String pdf {
        get {
            
                if(attId != null){
                    return att.body.toString();
                }else{
                     HttpRequest req=new HttpRequest();      
                    req.setEndpoint('https://proof2-dev-ed.my.salesforce.com/00P9000000eL7WN');
                    req.setMethod('GET');   
                    return new Http().send(req).getBody();
                }
            
        }
    }
    
    public String pdfPage {
        get {
            
                if(attId != null){
                    return att.body.toString();
                }else{
                     HttpRequest req=new HttpRequest();      
                    req.setEndpoint('http://www.cbu.edu.zm/downloads/pdf-sample.pd');
                    req.setHeader('Accept', 'application/pdf');
                    req.setMethod('GET');   
                    return new Http().send(req).getBody();
                    
                }
            
        }
    }
    
    
    
    public String pdfcontent{get;set;}
    public Id attId{get;set;}
    
    public MedWaterMarkController(){
         attId = ApexPages.currentPage().getParameters().get('pdfid');
         //at = [Select Id, name, body, ContentType, LastModifiedDate 
          //           From Attachment where id =: attId];
          
         //pdfcontent = EncodingUtil.Base64Encode(at.body)
        
    }

}