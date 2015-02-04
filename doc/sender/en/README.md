# Sender SDK

## use FlintSenderManager

```
var senderManager = new FlintSenderManager({
        appid, // application ID
        flint-service-url, // http url, means Flint Service url
        flint-server-host, // ip address, means Flint Server host
        use-heartbeat // boolean type, means keeping heartbeat with Flint Service or not
    });
// get custom additional data from receiver
senderManager.getAdditionalData();
// or
senderManager.on('customDataavailable', function(customData) {
});
```

## use communication link

* create MessageBus

    ```
    var bus = null;
    // create anonymous MessageBus
    bus = senderManager.createMessageBus();
    // create named MessageBus
    bus = senderManager.createMessageBus('namespace');    
    ```
* listen event

    ```
    messageBus.on('message', function(message) {
        console.log(message);
    });
    ```
* send message

    ```
    messageBus.send('some message');
    ```

## use WebRTC
* connect receiver peer

    ```
    // data connection
    senderManager.connectReceiverPeer(options);
    // stream call
    senderManager.callReceiverPeer(stream, options);
    ```

## Application control
* get application's state

    ```
    var callback = function(result, state, additionaldata) {
        // result：true means success，false means failure
        // state：application's state，could be 'stopped'，'starting' or 'running'
        // additionaldata：additional data from receiver
    };
    senderManager.getState(callback); // the first way
    senderManager.on('appstate', callback); // the second way
    ```
* launch application

    ```
    var appInfo = {
        appUrl: url,
        useIpc: true or false,
        maxInactive: int
    };
    var callback = function(type, result, token) {
        // type：event type, 'app' + the name of api, for example, if you call launch()，the type is 'applaunch'
        // result：true means success，false means failure
        // token：Flint Service response a token to sender to indicate this request
    };
    //
    // launch application：
    //
    senderManager.launch(appInfo, callback); // the first way
    senderManager.launch(appInfo) // the second way
    senderManager.on('applaunch', callback);
    //
    // relaunch application：
    //
    senderManager.relaunch(appInfo, callback); //the first way
    senderManager.relaunch(appInfo) // the second way
    senderManager.on('apprelaunch', callback);
    //
    // join application：
    //
    senderManager.join(appInfo, callback); //the first way
    senderManager.join(appInfo) // the second way
    senderManager.on('appjoin', callback);
    ```

* stop application

    ```
    var callback = function(type, result) {
        // type：event type, 'app' + the name of api, for example, if you call stop()，the type is 'appstop'
        // result：true means success，false means failure
    };
    //
    // stop application：
    //
    senderManager.stop(appInfo, callback); //the first way
    senderManager.on('appstop', callback); //the second way
    senderManager.stop(appInfo);
    //
    // disconnect from Flint Service but donot stop application：
    //
    senderManager.disconnect(appInfo, callback); //the first way
    senderManager.on('appdisconnect', callback); //the second way
    senderManager.disconnect(appInfo);
    ```