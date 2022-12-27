//test coverage could be improved, but actual implementation tests should will validate base functionality
// giturl: https://github.com/ChuckJonas/BaseHttpClient
@isTest
private class BaseHttpClientTests {

    @isTest
    private static void testUrLBuilding(){
        TestClient client = new TestClient();
        String url = client.buildEndpoint(
            'testUri',
            new Map<String, String> {
                'param1' => 'paramValue1',
                'param2' => 'paramValue2'
            }
        );
        System.assertEquals('ENDPOINT/testUri?param1=paramValue1&param2=paramValue2', url);
    }

    @isTest
    private static void testSucessfulRequest(){
        Test.setMock(HttpCalloutMock.class, new TestClientMockImpl());
        Test.startTest();
             TestClient client = new TestClient();
             TestDTO requestDto = new TestDTO();
             requestDto.foo = 'hello world';
             TestDTO responseDTO = client.fooRequest(requestDto);
        Test.stopTest();

        System.assertEquals(requestDto.foo, responseDTO.foo);
    }

    @isTest
    private static void testBadResponseFormat(){
        Test.setMock(HttpCalloutMock.class, new TestClientMockImpl());
        Test.startTest();
             TestClient client = new TestClient();
             try{
                TestDTO responseDTO = client.badRequest('hello world');
                System.assert(false, 'should have thrown exception');
             }catch(BaseHttpJsonClient.ResponseJsonParseException e){
                system.assertEquals(e.resp.getBody(), 'hello world');
             }
        Test.stopTest();
    }
     @isTest
    private static void testSucessfulRequestHttpEncoded(){
        Test.setMock(HttpCalloutMock.class, new TestClientMockImpl());
        Test.startTest();
             TestClient2 client = new TestClient2();
             TestDTO requestDto = new TestDTO();
             requestDto.foo = 'hello world';
             TestDTO responseDTO = client.fooRequest(requestDto);
        Test.stopTest();

        System.assertEquals(requestDto.foo, responseDTO.foo);
    }

    public class TestDTO {
        public string foo;
    }

    public class TestClient extends BaseHttpJsonClient{
        public TestClient(){
            super('ENDPOINT');
        }

        public TestDTO fooRequest(TestDTO dto){
            return (TestDTO) super.request('POST','foo', null, dto, TestDTO.class);
        }

        public TestDTO badRequest(String s){
            return (TestDTO) super.request('POST','foo', null, s, TestDTO.class);
        }
    }
    public class TestClient2 extends BaseHttpUrlEncodedClient{
         public TestClient2(){
            super('ENDPOINT2');
        }

        public TestDTO fooRequest(TestDTO dto){
            return (TestDTO) super.request('POST','foo', null, new Map<String, String>{'hello'=> 'world'}, TestDTO.class);
        }

    }

    public class TestClientMockImpl implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            string s = req.getBody();
            //This is a hack for the fact that
            //for all the other tests the DTO Body deserlizes into the object
            //but for the Form Encoded tests it doesnt, so
            //we swap bodies to match the FOO
            if(s == 'hello=world'){
                res.setBody('{\"foo\":\"hello world\"}');
            }else{
                res.setBody(req.getBody());
            }
            res.setStatusCode(200);
            return res;
        }
    }

}