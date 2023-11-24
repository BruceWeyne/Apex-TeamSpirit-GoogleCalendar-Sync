/*
 * Author  : BruceWeyne, Taku H.F.
 * Purpose : HTTP コールアウトをテストするための擬似応答の指定
 * Deploy  : 
 * Version : 1.0
 * Referrence : https://developer.salesforce.com/docs/atlas.ja-jp.238.0.apexcode.meta/apexcode/apex_classes_restful_http_testing_httpcalloutmock.htm
*/
@isTest
global class HttpCalloutMockImpl implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
         // Create a fake response
         HttpResponse res = new HttpResponse();
         res.setHeader('Content-Type', 'application/json');
         res.setBody('{"id":"0aDTqp6RuLLoh7GddSJo88R6WTVYMclI"}');
         switch on req.getMethod() {
            when 'POST' {
               res.setStatusCode(200);
            }
            when 'DELETE', 'PATCH' {
               res.setStatusCode(204);
            }
            when else {
               res.setStatusCode(500);
            }
         }
         return res;
    }


} // End of the class