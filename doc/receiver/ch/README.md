# Receiver SDK

## 创建FlintReceiverManager
```javascript
var receiverManager = new FlintReceiverManager(appid /* application ID */);
// 启动FlintReceiverManager
receiverManager.open();
// 停止FlintReceiverManager
receiverManager.close();
```

## 创建通信链路
通信链路有两种，分别是`MessageChannel`与`MessageBus`，都可以与sender端进行通信。  
两者的区别是：每条`MessageChannle`是单独的一个websocket连接，而`MessageBus`是基于一个SDK预先创建好的`MessageChannel`之上，通过不同的`namespace`模拟出多条通信链路。

* `MessageChannel`
    * 创建MessageChannel  
    ```javascript
    // 创建一个匿名通道
    var messageChannel = receiverManager.createMessageChannel();
    // 创建命名通道
    var messageChannel = receiverManager.createCustomMessageChannel('channel name');
    ```
    * 监听事件
    ```javascript
    messageChannel.on('open', function(event) {
    });
    messageChannel.on('close', function(event) {
    });
    messageChannel.on('error', function(event) {
    });
    messageChannel.on('message', function(message) {
        console.log(message);
    });
    ```
    * 发送消息
    ```javascript
    messageChannel.send('some message');
    ```
* `MessageBus`
    * 创建MessageBus
    ```javascript
    // 必须要指定一个namespace，并且与receiver在receiver端要创建同样namespace的MessageBus才能通信
    var messageBus = receiverManager.createMessageBus('namespace');
    ```
    * 监听事件
    ```javascript
    messageBus.on('message', function(message) {
        console.log(message);
    });
    ```
    * 发送消息
    ```javascript
    messageBus.send('some message');
    ```

## 创建peer
* 创建
```javascript
// 创建default peer，receiver sdk会帮助这个peer的peerId传递到sender端
var peer = receiverManager.createPeer();
// 创建自定义peer，需要developer自己实现某种方式将peer的peerId传递到sender端
var peer = receiverManager.createCustomPeer();
```