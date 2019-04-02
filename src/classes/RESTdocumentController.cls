@RestResource(urlMapping='/createdocument/*')
global with sharing class RESTdocumentController {
	
global class response{
	String message;
}

@HttpPost   
  global static response createNewDocument(String DocNumber, String Category, String overview, String title, String products, String TherapeuticArea ) {
     
     System.debug('DocNumber: '+DocNumber);
     System.debug('overview: '+overview);
     
    
     
     //create document
     MedDocument__c objInsert = new MedDocument__c();   
     objInsert.Name = DocNumber;
     objInsert.Category__c = Category;
     objInsert.Document_Overview__c = overview;
     objInsert.Document_Title__c = title;
     objInsert.Product__c = products;
     objInsert.Therapeutic_Area__c = TherapeuticArea;
     System.debug('objInsert = '+objInsert);
     Database.SaveResult lsr = database.insert(objInsert,false);
     
     
	     //PageReference pr = new PageReference('apex/GetPageAsPDF?id='+objInsert.id);    
	     
	     //Blob pdf;
	     //callout to fetch page as pdf
	     //if(lsr != null && lsr.isSuccess()){	     
		     
		 //    createAttachment(lsr.getId(), title);
		 //}
		 
	 	 //create attachment
	     Attachment objAttachmnt = new Attachment();
	     objAttachmnt.parentId = lsr.getId(); 
	     objAttachmnt.name= title + '.pdf';
	     objAttachmnt.body =  Blob.toPDF(overview.replaceAll('src',''));
	     //objAttachmnt.body =  Blob.valueOf(pdf);
	     objAttachmnt.ContentType = 'pdf';
	     System.debug('objAttachmnt = '+objAttachmnt);
	     insert objAttachmnt;  
	     
	     //prepare response
	 	 response res = new response();
	     res.message = 'Document and Attachment create successfully';       
	     return res;
     
     
    
  }
  
  /*
  @Future(callout=true)  
  public static void createAttachment(Id docId, String title ){
  		 HttpRequest request = new HttpRequest();
		 request.SetMethod('GET');
		 request.SetEndPoint('https://c.ap1.visual.force.com/apex/GetPageAsPDF?id='+docId);	               
		 HttpResponse httpResponse = new Http().Send(request);
		 String pdf = httpResponse.getBody();
		 System.debug('PDF body == '+ pdf);
		 
		 //create attachment
	     Attachment objAttachmnt = new Attachment();
	     objAttachmnt.parentId = docId; 
	     objAttachmnt.name= title + '.pdf';
	     //objAttachmnt.body =  Blob.toPDF(overview);
	     objAttachmnt.body =  Blob.valueOf(pdf);
	     objAttachmnt.ContentType = 'pdf';
	     System.debug('objAttachmnt = '+objAttachmnt);
	     insert objAttachmnt;  
	      
  	
  }
  */
 }