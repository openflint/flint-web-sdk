# Receiver SDK

## use FlintReceiverManager
```
var receiverManager = new FlintReceiverManager(appid /* application ID */);
// open FlintReceiverManager
receiverManager.open();
// stop FlintReceiverManager
receiverManager.close();
```

## use communication link

* create MessageBus

    ```
    var bus = null;
    // create anonymous MessageBus
    bus = receiverManager.createMessageBus();
    // create named MessageBus
    bus = receiverManager.createMessageBus('namespace');    
    ```
* listen event

    ```
    messageBus.on('message', function(message, senderId /* from which sender */) {
        console.log(message);
        console.log(senderId);
    });
    messageBus.on('senderConnected', function(senderId) {
        console.log(senderId);
    });
    messageBus.on('senderDisconnected', function(senderId) {
        console.log(senderId);
    });
    ```
* send message

    ```
    messageBus.send('some message');
    ```

## use WebRTC
* create Peer

    ```
    var peer = senderManager.createPeer();
    ```
    
* create data peer, sender could use FlintSenderManager.connectReceiverPeer() to connect with is.

    ```
    var dataPeer = receiverManager.createDataPeer();
    ```

* create media peer, sender could use FlintSenderManager.callReceiverPeer() to connect with is.

    ```
    var mediaPeer = receiverManager.createMediaPeer();
    ```