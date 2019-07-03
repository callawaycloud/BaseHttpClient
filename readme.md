# Apex BaseHttpClient

A base class to make it quick and easy to implement a Http Client.  Designed primarily with JSON rest API's in mind, but could be used for other requests.

## Install

### Unlocked Package (RECOMMENDED)

- via URL: [/packaging/installPackage.apexp?p0=04t1C000000tfGvQAI](https://login.salesforce.com/packaging/installPackage.apexp?p0=04t1C000000tfGvQAI)

**OR**

- via sfdx-cli: `sfdx force:package:install --wait 10 --publishwait 10 --package 04t1C000000tfGvQAI --noprompt -u you@yourorg`


### From Source
1. `sfdx force:source:convert -d deploy-package`
2. `sfdx force:mdapi:deploy -d deploy-package -u you@yourorg -w 1000`

## Classes

- `BaseHttpClient`: base class to make any type of HttpRequest.  Doesn't transform responses
- `BaseHttpJsonClient`: Extends `BaseHttpClient` with automatic deserialization of JSON
- `BaseHttpClientTest`: unit tests

*will eventually implement an `BaseHttpXMLClient` should I ever need one. (PR's welcome)*

## Usage

### Extend one of the abstract classes

```java
public class SuperDuperClient extends BaseHttpJsonClient {
    public SuperDuperClient(){
        super('callout:SuperDuper');

        //optionally set this if you want sandbox request to go elsewhere
        this.baseSandboxEndpoint = 'https://superduper-mock.api';
    }

    // implement public client methods
    public SuperDuper getSuperDuper(String fooParam, String barBody){
        return (SuperDuper) request(
            'GET',                  //method
            'foo',                  //url
            new Map<String,String>{ //params
                'foo' => fooParam
            },
            barBody,                //body
            SuperDuper.class        //response type
        );
    }
}
```

### Customize

If you need to change the way any of the default behavior works, you can easily do so by overriding any of the methods.  A common use case would be to override the `genRequest` method to add headers:

``` java
    protected override HttpRequest genRequest(String method, String uri){
        //call super method to init request
        HttpRequest req = super.genRequest(method, uri);
        // add some headers
        req.setHeader('X-API-KEY', 'xyz');
        req.setHeader('accept', 'application/json');
        return req;
    }
```

With the `BaseHttpJsonClient` you can override the `parseResponse` method if you needed to rename reserved keywords, etc. The following example shows how this might look if you were using the [APEX-JSONReservedNameSerializer](https://github.com/ChuckJonas/APEX-JSONReservedNameSerializer) method.

```java
    protected override Object processResponse(HttpResponse resp, Type returnType){
        String resBody = resp.getBody();
        return SuperDuperJson.deserialize(resBody, returnType);
    }
```

### Call

```java
    SuperDuperClient spc = new SuperDuperClient();
    SuperDuper sp = spc.getSuperDuper('fooooooo', 'bar!');
```
