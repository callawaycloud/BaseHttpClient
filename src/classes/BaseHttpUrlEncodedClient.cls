/**
* Base JSON Client v1.2
* giturl: https://github.com/ChuckJonas/BaseHttpClient
*/
public abstract class BaseHttpUrlEncodedClient extends BaseHttpClient {

    public BaseHttpUrlEncodedClient(String baseEndpoint) {
        super(baseEndpoint);
    }

    /**
      * @description: build request -> send request -> check response -> parse response body (optional)
      * @param method: HTTP Method to send
      * @param uri: the URI.  Realitive to base endpoint
      * @param qryParams: url query params to add to URI
      * @param body: Request Body
      * @param returnType: The type of object to return.  Will be used to parse Object to JSON.  If null, return null
      * @return The parsed object (if appliciable)
      */
    protected virtual Object request(String method, String uri,
                                Map<String, String> qryParams, Map<String, String> body, Type returnType){

        HttpResponse resp = super.request(method, uri, qryParams, body);
        try{
            if(returnType == null){
                return null;
            }
            return parseResponse(resp, returnType);
        }catch(Exception e){
            throw new ResponseJsonParseException(resp, returnType);
        }
    }

    /**
      * @description: sets the request body based on the incoming object type
      * @param req: HttpRequest req to set the body on
      * @param body: Request Body. Can only be map
      * @return Void.  Mutates req.body
    */
    protected virtual override void setRequestBody(HttpRequest req, Object body){
        if(body != null){
            if(body instanceOf Map<String,String>){
                req.setBody(buildEntityBody((Map<string, string>) body));
            }else{
                super.setRequestBody(req, body);
            }
        }
    }


    protected virtual override HttpRequest genRequest(String method, String uri){
        HttpRequest req = super.genRequest(method,uri);
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        return req;
    }

    /* parse JSON/XML/Other to response DTO type */
    protected virtual Object parseResponse(HttpResponse resp, Type returnType){
        String resBody = resp.getBody();
        return JSON.deserialize(resBody, returnType);
    }


    /* parse json exception */
    public class ResponseJsonParseException extends Exception {
        public HttpResponse resp;
        public Type returnType;

        public ResponseJsonParseException(HttpResponse resp, Type returnType){
            this.resp = resp;
            this.returnType = returnType;
            this.setMessage('Failed to parse http response to type: ' + returnType.toString());
        }
    }

    /**
     * Builds the entity body. and URL encodes it
     *
     * @param params
     *            the params
     * @return the url encoded form entity
     */
    private String buildEntityBody(Map<String,String> params) {
        String entityBody='';
        if (params != null) {
            for (String key : params.keySet()) {
                try {
                    entityBody += (entityBody=='' ? '' : '&')
                                    + key + '=' + EncodingUtil.urlEncode(params.get(key), 'UTF-8');
                } catch (Exception e) {
                    System.debug('ERROR: ' + e);
                    throw e;
                }
            }
        }
        return entityBody;
    }

}