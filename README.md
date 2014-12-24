# How to use SDK

> please refer to `https://github.com/openflint/flint-web-sdk/tree/master/doc/receiver/zh` and `https://github.com/openflint/flint-web-sdk/tree/master/doc/sender/zh` for more information.

## Receiver side
```
// include
<script src="//openflint.github.io/flint-web-sdk/out/flint_receiver_sdk.js"></script>
// or
<script src="//openflint.github.io/flint-web-sdk/out/flint_receiver_sdk.min.js"></script>

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
// include
<script src="//openflint.github.io/flint-web-sdk/out/flint_sender_sdk.js"></script>
// or
<script src="//openflint.github.io/flint-web-sdk/out/flint_sender_sdk.min.js"></script>

// find a FlintDevice
var deviceScanner = new FlintDeviceScanner();
var device = null;

var deviceList = deviceScanner.getDeviceList();
// or
deviceScanner.on('devicefound', function(_device) {
    device = _device;
});

deviceScanner.start();

// create FlintSenderManager
    var senderManager = new FlintSenderManager(
            appid /* application ID */,
            device.getUrlBase() /* Flint Service url */,
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

## install plugin

### Mac
```
unzip downloads/osx/npFlintPlugin.plugin.zip
cd ~/Library/Internet\ Plug-Ins/
ln -s downloads/osx/npFlintPlugin.plugin
```