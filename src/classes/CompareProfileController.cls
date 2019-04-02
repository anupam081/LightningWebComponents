/* Description : Apex class Util to compare profile in two different org's  and send report in email notification 
   Created date : 04th Oct 17
   Last Modified date : 6th Oct 17
*/

public class CompareProfileController {
	//final static variables    
    private static final String NS_SOAP = 'http://schemas.xmlsoap.org/soap/envelope/';
    private static final String NS_SF = 'urn:partner.soap.sforce.com';
    
    //set the profile you want to compare
    private static string profileName = 'Read Only';
    
    //set the destination org base url
    private static string DESTINATION_URL = 'https://ap5.salesforce.com';
    
    //set the destination org username & password with token
    private static string DESTINATION_USERNAME = 'nishant.bansal@voya.com.rim.rimpoc';
    private static string DESTINATION_PASSWORD = 'check@2017!'+'9gUyNpNuAqTMR7ICuCseWGXh';
    
    //Variable to hold comparison result
    private static Map<String, String> objPerCompareResultMap; 
    
    /**
    * @author      : Anupam Tripathi
    * @date        : 10/04/2017
    * @description : Method to run the utility
    * @param1      : None
    * @param2      : 
    * @return      : void
    */
    public static void run(){
        try{
            fetchObjPermSource();
            fetchObjPermDestination();
            system.debug('objPerCompareResultMap == '+objPerCompareResultMap);        
            exportToCsv();
            
        }catch(Exception e){
            throw new CompareProfileException(e.getMessage());
        }
        
    }
    
    
   /**
    * @author      : Anupam Tripathi
    * @date        : 10/03/2017
    * @description : Method to login to destination org and get session id
    * @param1      : None
    * @param2      : 
    * @return      : String
    */
    public static String loginToOtherInstance()
    {
        string user = DESTINATION_USERNAME;
        string password = DESTINATION_PASSWORD;           
        
        HttpRequest req = createHttpRequest('https://voyarim--rimpoc.cs91.my.salesforce.com' + '/services/Soap/u/40.0', 'POST', '');
        req.setHeader('Content-Type', 'text/xml;charset=UTF-8');        
        req.setHeader('SOAPAction', '""');
        req.setBody('<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/"><Header/><Body><login xmlns="urn:partner.soap.sforce.com"><username>' +user+ '</username><password>' + password + '</password></login></Body></Envelope>');        
        
        HttpResponse res = getResponse(req) ;
        system.debug('response'+ res);
        system.debug('response'+ res.getBody());
        
        if(res.getStatusCode() != 200)
        {
            Dom.Document responseDocument = res.getBodyDocument();
            Dom.Xmlnode rootElm = responseDocument.getRootElement(); // soapenv:Envelope
            Dom.Xmlnode bodyElm = rootElm.getChildElement('Body', NS_SOAP); // soapenv:Body 
            Dom.Xmlnode faultElm = bodyElm.getChildElement('Fault', NS_SOAP); // soapenv:Fault
            Dom.Xmlnode faultStringElm = faultElm.getChildElement('faultstring', null); // faultstring          
            throw new CompareProfileException(faultStringElm.getText()); 
        }
        // Get session id
        Dom.Document responseDocument = res.getBodyDocument();
        Dom.Xmlnode rootElm = responseDocument.getRootElement(); // soapenv:Envelope
        Dom.Xmlnode bodyElm = rootElm.getChildElement('Body', NS_SOAP); // soapenv:Body 
        Dom.Xmlnode loginResponseElm = bodyElm.getChildElement('loginResponse', NS_SF); // loginResponse
        Dom.Xmlnode resultElm = loginResponseElm.getChildElement('result', NS_SF); // result
        Dom.Xmlnode sessionIdElm = resultElm.getChildElement('sessionId', NS_SF); // sessionId
        return sessionIdElm.getText();
    }
    
    /**
    * @author      : Anupam Tripathi
    * @date        : 10/03/2017
    * @description : custom exception class
    * @param1      : None
    * @param2      : None
    * @return      : None
    */
    private class CompareProfileException extends Exception {}
	
    /**
    * @author      : Anupam Tripathi
    * @date        : 10/05/2017
    * @description : Fetch object permission from source org
    * @param1      : None
    * @param2      : None
    * @return      : None
    */
    private static void fetchObjPermSource(){
    	objPerCompareResultMap =  new Map<String,String>();
        for(ObjectPermissions op : [SELECT Id, SObjectType, PermissionsRead,PermissionsCreate, PermissionsEdit, 
                                    PermissionsDelete, PermissionsViewAllRecords, PermissionsModifyAllRecords
							   		FROM ObjectPermissions WHERE parentid in 
							   		(select id from permissionset 
                                     where PermissionSet.Profile.Name = :profileName)]){
                                         
                                         String rowdata = '';                                      
                                         
                                         rowdata = String.valueof(op.PermissionsRead);
                                         rowdata = rowdata + ',' + String.valueof(op.PermissionsCreate);                                        
                                         rowdata = rowdata + ',' + String.valueof(op.PermissionsEdit);
                                         rowdata = rowdata + ',' + String.valueof(op.PermissionsDelete);
                                         rowdata = rowdata + ',' + String.valueof(op.PermissionsViewAllRecords);
                                         rowdata = rowdata + ',' + String.valueof(op.PermissionsModifyAllRecords);
                                         objPerCompareResultMap.put(op.SObjectType,rowdata);
                                         
        }
    }   
    
    
     /**
    * @author      : Anupam Tripathi
    * @date        : 10/05/2017
    * @description : Fetch object permission from destination org
    * @param1      : None
    * @param2      : None
    * @return      : None
    */
    private static void fetchObjPermDestination(){
    	
        String destSessionId = loginToOtherInstance();
        
        if(string.isNotBlank(destSessionId)){
            
            String query = '/services/data/v40.0/query/?q=SELECT+id,SObjectType,PermissionsCreate,parentid,PermissionsRead,PermissionsEdit,PermissionsDelete,PermissionsViewAllRecords,PermissionsModifyAllRecords+from+ObjectPermissions';
            query = query + '+where+parentid+in(select+id+from+permissionset+where+PermissionSet.Profile.Name=\'' + EncodingUtil.urlEncode(profileName, 'UTF-8') + '\')+order+by+SObjectType+asc';
			
			//request            
            HttpRequest req = createHttpRequest(DESTINATION_URL + query, 'GET', destSessionId);
            system.debug('request'+ req);
            
            //response
            HttpResponse response = getResponse(req);     
            
            //parse response
            parseResponse(response.getBody());
            
        }
    }  
    
     /**
    * @author      : Anupam Tripathi
    * @date        : 10/05/2017
    * @description : parse the Json response
    * @param1      : None
    * @param2      : None
    * @return      : None
    */    
    private static void parseResponse(String apiResp) {
        //deserialize the json 
        Map<String, Object> root = (Map<String, Object>)JSON.deserializeUntyped(apiResp);
        
        //get records from the root
        List<Object> items = (List<Object>)root.get('records');
        system.debug('items == '+ items);
       
        //iterate thorough records and get each field value
        for (Object item : items) {
            String rowdata = '';
            Map<String, Object> i = (Map<String, Object>)item;
			System.debug('obj == '+i.get('SobjectType') + ' - '+ i.get('PermissionsRead'));
            
            //Prepare data to add to Map
            rowdata = String.valueof(i.get('PermissionsRead'));
            rowdata = rowdata + ',' + String.valueof(i.get('PermissionsCreate'));
            rowdata = rowdata + ',' + String.valueof(i.get('PermissionsEdit'));
            rowdata = rowdata + ',' + String.valueof(i.get('PermissionsDelete'));
            rowdata = rowdata + ',' + String.valueof(i.get('PermissionsViewAllRecords'));
            rowdata = rowdata + ',' + String.valueof(i.get('PermissionsModifyAllRecords')) + '\n';
            
            if(objPerCompareResultMap.containskey(String.valueof(i.get('SobjectType'))) && String.valueof(i.get('SobjectType')) != null){
                String finalStr = objPerCompareResultMap.get(String.valueof(i.get('SobjectType'))) + ',' + '-' + ',' + '-' + ',';
                finalStr = finalStr + rowdata;
                objPerCompareResultMap.put(String.valueof(i.get('SobjectType')), finalStr);
            }else if(String.valueof(i.get('SobjectType')) != null){
                String finalStr = '-';
                for(integer j=0; j < 7; j++){
                    finalStr = finalStr + ',' + '-';
                }
                finalStr = finalStr + ',' + rowdata;
                objPerCompareResultMap.put(String.valueof(i.get('SobjectType')), finalStr);
            }
 			
        }
    }
    
      /**
    * @author      : Anupam Tripathi
    * @date        : 10/05/2017
    * @description : create a http request with required endpoint and request method
    * @param1      : String
    * @param2      : String
    * @return      : HttpRequest
    */   
    private static HttpRequest createHttpRequest(String endpoint, String method, String SessionId)
    {
        HttpRequest req = new
        HttpRequest();
        endpoint += '';
        req.setHeader('Authorization', 'Bearer ' + SessionId);
        req.setHeader('Content-Type', 'application/json; charset=UTF-8');
        req.setEndpoint(endpoint);
        req.setTimeout(60000);
        req.setMethod(method);
        return req;
    }
    
     /**
    * @author      : Anupam Tripathi
    * @date        : 10/05/2017
    * @description : used receive response by sending a http request
    * @param1      : HttpRequest
    * @param2      : none
    * @return      : HttpResponse
    */     
    private static HttpResponse getResponse(HttpRequest req)
    {
       
            Http httpreq = new Http();
            HttpResponse res = httpreq.send(req);
            system.debug('response'+ res);
            system.debug('response'+ res.getBody());
            if(res.getStatusCode() != 200){
                 throw new CompareProfileException(res.getStatus());
            }
            //String reqresponse = res.getBody();
            return res;
       
    }
    
      /**
    * @author      : Anupam Tripathi
    * @date        : 10/05/2017
    * @description : Fetch destination profile metadata
    * @param1      : None
    * @param2      : None
    * @return      : None
    */ 
    private static void exportToCsv(){
        String generatedCSVFile ='';
        String header ='';
    	
        //set title of the file
        String title = '' + ',' + '' + ',' + '' + ','+ '' + ',';
        title = title + 'PROFILE COMPARISON SANDBOX == PRODUCTION :::: PROFILE NAME = ' + profileName +  '\n';
        
        
        if(!objPerCompareResultMap.isEmpty()){
            //set column headers
            header = 'SObjectType' + ',';
            String header1  = 'PermissionsRead';
            header1 = header1 +','+ 'PermissionsCreate';
            header1 = header1 +','+ 'PermissionsEdit';
            header1 = header1 +','+ 'PermissionsDelete';
            header1 = header1 +','+ 'PermissionsViewAllRecords';
            header1 = header1 +','+ 'PermissionsModifyAllRecords'; 
            header1 = header1 + ',' + '-' + ',' + '-' + ',' + header1 + '\n';
            
            //add header to file
            generatedCSVFile = generatedCSVFile + title + header + header1;
            
            for(String str : objPerCompareResultMap.keyset()){                
                String fileRow = str;	
                if(!objPerCompareResultMap.get(str).contains('\n')){
                    fileRow = fileRow +','+ objPerCompareResultMap.get(str) + '\n';
                }else{
                    fileRow = fileRow +','+ objPerCompareResultMap.get(str);
                }
                               
                generatedCSVFile = generatedCSVFile + fileRow;
            }
            
            //Sending Email
            Messaging.EmailFileAttachment csvAttachment = new Messaging.EmailFileAttachment();
            Blob csvBlob = blob.valueOf(generatedCSVFile);
            String csvName = 'ProfileComparisonResult_' + System.today().format() + '.csv';
            csvAttachment.setFileName(csvName);
            csvAttachment.setBody(csvBlob);
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            //Set Your Email IDs in Below Line - EmailSetting
            //String[] toAddresses = new String[]{'anupam.tripathi@niit-tech.com'};
            String subject = 'Object permission comparison report for profile = ' + profileName;
            email.setSubject(subject);
            email.setToAddresses(fetchUsersFromGroup());
            String emailBody = 'Hi \n Please find attached the object permission report from sandbox and production for profile :  '+ profileName + '\n';
            emailBody = emailBody + '\n Thanks \n Admin Support';
            email.setPlainTextBody(emailBody);
            email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttachment});
            Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
        }
        
    }

    /**
    * @author      : Anupam Tripathi
    * @date        : 9/21/2017
    * @description : Method to fetch user's email id from a public group
    * @param1      : 
    * @param2      : 
    * @return      : List<String>
    */    
    private static List<String> fetchUsersFromGroup(){
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
    
     /**
    * @author      : Anupam Tripathi
    * @date        : 10/05/2017
    * @description : Fetch destination profile metadata
    * @param1      : None
    * @param2      : None
    * @return      : None
      
    private static void fetchDestinationProfile()
    {  
        String baseURL = URL.getSalesforceBaseUrl().toExternalForm();
        HttpRequest req = new HttpRequest();
    	req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
    	req.setHeader('Content-Type', 'application/json; charset=UTF-8');
        req.setTimeout(60000);
        String query = '/services/data/v40.0/tooling/query/?q=Select+id,Name,Metadata+from+Profile+where+name+=\''+EncodingUtil.urlEncode(profileName, 'UTF-8')+'\'+limit+1';
        req.setEndpoint(baseURL + query);
		req.setMethod('GET');
        system.debug('request'+ req);
        HttpResponse res =  new Http().send(req);
        system.debug('response'+ res);
        system.debug('response'+ res.getBody());
         if(res.getStatusCode() != 200){
             throw new CompareProfileException(res.getStatus());
        }
        
		parseResponse(res.getBody());
    }
  */
    
}