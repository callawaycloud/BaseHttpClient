public abstract class BaseHttpJsonClient extends BaseHttpClient {

    public BaseHttpJsonClient(String baseEndpoint) {
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
                                Map<String, String> qryParams, String body, Type returnType){

        HttpResponse resp = super.request(method, uri, qryParams, body);
        try{
            return parseResponse(resp, returnType);
        }catch(Exception e){
            return new ResponseJsonParseException(resp, returnType);
        }
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

}