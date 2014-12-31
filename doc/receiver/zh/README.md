# Receiver SDK

## 创建FlintReceiverManager
```
var receiverManager = new FlintReceiverManager(appid /* application ID */);
// 启动FlintReceiverManager
receiverManager.open();
// 停止FlintReceiverManager
receiverManager.close();
```

## 创建通信链路
receiver端与sender端通过MessageBus进行通信。

    * 两端只要创建了相同namespace的MessageBus，消息就可以在这两个MessageBus之间传递。如果application只需要一个MessageBus就能满足需求，那么在两端可以各自创建一个匿名的MessageBus，也可以相互通信。
    * sender端的MessageBus与receiver端的MessageBus是多对一的关系，即多个sender可以创建同一个namespace的MessageBus，同时与1个receiver的MessageBus通信。

* 创建匿名MessageBus

    ```
    var bus = null;
    // 创建匿名MessageBus
    bus = receiverManager.createMessageBus();
    // 创建命名MessageBus
    bus = receiverManager.createMessageBus('namespace');    
    ```
* 监听事件

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
* 发送消息

    ```
    messageBus.send('some message');
    ```

## 使用WebRTC
* 创建Peer

    ```
    var peer = senderManager.createPeer();
    ```
    
* 创建data peer, sender可以通过connectReceiverPeer()接口进行连接

    ```
    var dataPeer = receiverManager.createDataPeer();
    ```

* 创建media peer, sender可以通过callReceiverPeer()接口进行连接

    ```
    var mediaPeer = receiverManager.createMediaPeer();
    ```