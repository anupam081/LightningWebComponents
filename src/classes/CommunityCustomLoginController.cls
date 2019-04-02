/**
 * An apex page controller that exposes the site login functionality
 */

global with sharing class CommunityCustomLoginController {


    global String username{get;set;}
    global String password{get;set;}
    global CommunityCustomLoginController () {}
    global PageReference forwardToCustomAuthPage() {
        return new PageReference( '/CustomLogin');
    }
    global PageReference login() {
        return Site.login(username, password, null);
    }



}