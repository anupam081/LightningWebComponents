public class loginToOtherOrgcontroller{
    
    String accessToken = '';
    
    public loginToOtherOrgcontroller(){
        
    }
    
    public pageReference logintopartner(){
        PageReference pr;
        string serverurl = 'https://voyarim--rimpoc.cs91.my.salesforce.com';
        //String sessionid1 = CompareProfileController.loginToOtherInstance();
        String sessionid = authenticateByUserNamePassword();
        System.debug('Are both same == '+ sessionid == sessionid);
        //pr =  new Pagereference(serverurl+'/secur/frontdoor.jsp?sid='+ EncodingUtil.urlEncode(sessionId, 'UTF-8') + '&retURL=/apex/AttachmentEmail');
        pr =  new Pagereference('https://voyarim--rimpoc.cs91.my.salesforce.com/apex/AttachmentEmail?oauth_token='+sessionid);
        pr.setredirect(false);
        return pr;
        
    }
    
    public String authenticateByUserNamePassword() {
    
        String uri          = 'https://voyarim--rimpoc.cs91.my.salesforce.com/services/oauth2/token';
        String clientId     = EncodingUtil.urlEncode('3MVG9d3kx8wbPieFnnm_4sSJRYE.BSzLrK5kJbk_UVSw6_DLiYN5Ly9LejGtsnZa_or1_2TWt.uP9.KyB1REG','UTF-8');
        String clientSecret = EncodingUtil.urlEncode('9088783180289749864','UTF-8');
        String username     = EncodingUtil.urlEncode('nishant.bansal@voya.com.rim.rimpoc','UTF-8');
        String password     = EncodingUtil.urlEncode('check@2017!'+'9gUyNpNuAqTMR7ICuCseWGXh','UTF-8');
        String cookieName = 'oauth';
 
        String body =   'grant_type=password&client_id=' + clientId + 
                        '&client_secret=' + clientSecret +
                        '&username=' + username + 
                        '&password=' + password; 
 
        HttpResponse hRes = this.send(uri,'POST',body);
        if (hRes.getStatusCode() != 200) 
            throw new MyException('[HTTP-01] OAuth 2.0 access token request error. Verify username, password, consumer key, consumer secret, isSandbox?  StatusCode=' +
                                                 hRes.getStatusCode() + ' statusMsg=' + hRes.getStatus());
             
         
        System.debug('response body =\n' + hRes.getBody());
         
 
        Map<String,String> res = (Map<String,String>) JSON.deserialize(hRes.getBody(),Map<String,String>.class);
 
        accessToken = res.get('access_token');      // remember these for subsequent calls
        String sfdcInstanceUrl    = res.get('instance_url');
        
        //ApexPages.currentPage().setCookies(new Cookie[]{new Cookie(cookieName, hRes.getBody(), null,-1,false)});
        
        return accessToken;
         
    }
    
    private HttpResponse send(String uri, String httpMethod, String body) {
         
        if (Limits.getCallouts() == Limits.getLimitCallouts())
            throw new MyException('[HTTP-00] Callout limit: ' + Limits.getCallouts() + ' reached. No more callouts permitted.');
        Http        h       = new Http();
        HttpRequest hRqst   = new HttpRequest();
        hRqst.setEndpoint(uri);                     // caller provides, this will be a REST resource
        hRqst.setMethod(httpMethod);                // caller provides
        hRqst.setTimeout(6000); 
        if (body != null) 
            hRqst.setBody(body);                    // caller provides
        if (this.accessToken != null)               // REST requires using the token, once obtained for each request
            hRqst.setHeader('Authorization','Bearer ' + this.accessToken);
        return h.send(hRqst);                   // make the callout
    }   
    
    private class MyException extends Exception {}
}