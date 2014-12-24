# How to use SDK

## Receiver side
```
// create FlintReceiverManager
    var receiverManager = new FlintReceiverManager(
            appid /* application ID */
        );

// create message bus
    var messageBus = receiverManagerr.createMessageBus();

// receive message
    messageBus.on('message', function(message, senderId) {
        console.log('received message from ', senderId, ' : ', message); 
        messageBus.send('response message', senderId);
    });

// send message
    messageBus.send('response message', 'senderId');

// open FlintReceiverManager
    receiverManager.open();

// close FlintReceiverManager
    receiverManager.close();
```

## Sender side
```
// create FlintSenderManager
    var senderManager = new FlintSenderManager(
            appid /* application ID */,
            flintServiceUrl /* Flint Service url */,
            keepHeartbeat /* boolean, keep heartbeat with FLint Service */
        );

// create message bus
    var messageBus = senderManager.createMessageBus();

// receive message
    messageBus.on('message', function(message) {
        console.log('received message : ', message);
        messageBus.send('response message');
    });

// send message
    messageBus.send('response message');

// get receiver application's state
    var callback = function(result, state, additionaldata) {
    };
    senderManager.getState(callback);
    /* or */
    senderManager.on('appstate', callback);
    senderManager.getState();

// launch receiver application
    var appInfo = {
        appUrl: url,
        useIpc: bool,
        maxInactive: int
    };
    var callback = function(type, result, token) {
    };
    senderManager.launch(appInfo, callback);
    /* or */
    senderManager.launch(appInfo);
    senderManager.on('applaunch', callback);

// stop receiver application
    var callback = function(type, result) {
    };
    senderManager.stop(appInfo, callback);
    /* or */
    senderManager.on('appstop', callback);
    senderManager.stop(appInfo);
```