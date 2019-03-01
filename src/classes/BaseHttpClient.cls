/**
* Base Client v1.1
*/
public abstract class BaseHttpClient {
    protected String baseProductionEndpoint;

    //optional endpoint for sandbox
    protected String baseSandboxEndpoint;

    // Warning: this will result in a SOQL query at context initilization
    //  If that's a concern, use another method (custom setting/host parsing/etc)
    public static boolean isSandbox{
        get{
            if(isSandbox == null){
                isSandbox = [SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox;
            }
            return isSandbox;
        }
        private set;
    }

    //returns production or sandbox endpoint bases on config & env
    public String baseEndpoint{
        get{
            baseEndpoint = baseProductionEndpoint;
            if(baseSandboxEndpoint != null && isSandbox){
                baseEndpoint = baseSandboxEndpoint;
            }
            return baseEndpoint;
        }
        private set;
    }

    /**
      * @description Constructor.
      * @param baseEndpoint: the base endpoint to send all request to (typically HOST)
      */
    public BaseHttpClient(String baseEndpoint) {
		this.baseProductionEndpoint = baseEndpoint;
	}

    /**
      * @description: build request -> send request -> check response -> parse response body (optional)
      * @param method: HTTP Method to send
      * @param uri: the URI.  Realitive to base endpoint
      * @param qryParams: url query params to add to URI
      * @param body: Request Body
      * @return The HttpResponse object
    */
    protected virtual HttpResponse request(String method, String uri,
                                Map<String, String> qryParams, String body){

        uri = buildEndpoint(uri, qryParams);
        HttpRequest req = genRequest(method, uri);
        if(body != null){
            req.setBody(body);
        }
        HttpResponse resp = sendRequest(req);
        checkResponse(req, resp);
        return resp;
    }


    /** FIRE! */
    protected virtual HttpResponse sendRequest(HttpRequest req){
        Http http = new Http();
        return http.send(req);
    }

    /** throw an error if the request didn't succeed! */
    protected virtual void checkResponse(HttpRequest req, HttpResponse resp){
        if(resp.getStatusCode() < 200 || resp.getStatusCode() >= 300){
            throw new HttpRequestException(req, resp);
        }
    }

    /** setup response */
    protected virtual HttpRequest genRequest(String method, String uri){
        HttpRequest req = new HttpRequest();
        req.setEndpoint(uri);
        req.setMethod(method);
        req.setTimeout(120000);
        return req;
    }

    /** Build the URL.  Base + uri + query params */
    @TestVisible
    protected virtual String buildEndpoint(String uri, Map<String, String> qryParams){
        if(qryParams != null && qryParams.size() > 0){
            List<String> keyPairs = new List<String>();
            for(String key : qryParams.keySet()){
                keyPairs.add(key + '=' + qryParams.get(key));
            }
            uri += '?' + String.join(keyPairs, '&');
        }

        return baseEndpoint +'/'+ uri;
    }

    /** Custom Exception */
    public class HttpRequestException extends Exception {
        public HttpRequest req;
        public HttpResponse resp;

        public HttpRequestException(HttpRequest req, HttpResponse resp){
            this.req = req;
            this.resp = resp;
            this.setMessage('Failed HTTP Request! Status: ' + resp.getStatusCode() + ' - ' + resp.getStatus() + ' Body: ' + resp.getBody());
        }
    }
}
