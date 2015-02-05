# Getting Started

* ## Create FlintReceiverManager
```
var receiverManager = new FlintReceiverManager('flint-getting-started' /* application ID */);
```

* ## Create MessageBus
```
var messageBus = receiverManager.createMessageBus();
```

* ## Listen Message Event
```
messageBus.on('message', function(message, senderId /* from which sender */) {
    console.log(message);
    console.log(senderId);
});
```

* ## Start Application
```
receiverManager.open();
```

* ## Send Message
```
messageBus.send('some message');
```

---
# API

#FlintReceiverManager

* ## Description
    Implement the receiver part of Flint protocol. Provide some methods to communicate with Flint Service and sender apps.


* ## Methods
    * ### constructor
        * #### Description
        * #### Parameters
            * (required) String applicationId
    
    * ### open
        * #### Description
            Start IPC and establish message channel connection with Flint Service.
        * #### Parameters
            * (none)

    * ### close
        * #### Description
            Stop IPC and cut off message channel with Flint Service.
        * #### Parameters
            * (none)

    * ### setAdditionalData
        * #### Description
            Set custom additional data. The data will be sent to Flint Service by 'additionaldata'.
        * #### Parameters
            * (required) String additionalData
            
    * ### createMessageBus
        * #### Description
            Create a ReceiverMessageBus object, it's a message channel communicate with senders. This method must be called before calling `open()`.
        * #### Parameters
            * (optional) String namespace

    * ### createMediaPeer
        * #### Description
            Create a Peer object to transfer media stream, corresponding ‘callReceiverMediaPeer’ in sender side. Please refer to <https://github.com/peers/peerjs> for more information about PeerJs.
        * #### Parameters
            * (none)
            
    * ### createDataPeer
        * #### Description
            Create a Peer object to transfer binary data, corresponding ‘connectReceiverDataPeer’ in sender side. Please refer to <https://github.com/peers/peerjs> for more information about PeerJs.
        * #### Parameters
            * (none)


## ReceiverMessageBus

* ## Description
    It's a message channel between sender and receiver. Text message could be transferred only. ReceiverMessageBus cann't be constructed directly, it must created by FlintReceiverManager.createMessageBus().

* ## Events

    * ### message
        * #### Description
            Fired when the message arrived.
        * #### Parameters
            ReceiverMessageBus.on('message', function callback);
            * (required, fixed String 'message') String eventType
            * (required) function callback(message)

    * ### senderConnected
        * #### Description
            Fired when a SenderMessageBus connected.
        * #### Parameters
            ReceiverMessageBus.on('senderConnected', function callback);
            * (required, fixed String 'senderConnected') String eventType
            * (required) function callback(senderId)

    * ### senderDisconnected
        * #### Description
            Fired when a SenderMessageBus disconnected.
        * #### Parameters
            ReceiverMessageBus.on('senderDisconnected', function callback);
            * (required, fixed String 'senderDisconnected') String eventType
            * (required) function callback(senderId)
            
* ## Methods

    * ### send
        * #### Description
            Send text message to sender
        * #### Parameters
            * (required) String message
            * (optional) String senderId, if empty, the message will be broadcast to all senders. 

    * ### getSenders
        * #### Description
            Get all connected senders.
        * #### Parameters
            * (none)


Peer
===

* ## Description
    Please refer to <https://github.com/peers/peerjs> for more information about PeerJs.