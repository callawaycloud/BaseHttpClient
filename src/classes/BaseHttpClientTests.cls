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

    public class TestDTO {
        public string foo;
    }

    public class TestClient extends BaseHttpJsonClient{
        public TestClient(){
            super('ENDPOINT');
        }
    }
}