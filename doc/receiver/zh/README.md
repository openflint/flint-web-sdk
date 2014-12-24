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
receiver端与sender端创建MessageBus时要对应，同时使用匿名MessageBus或者namespace相同的MessageBus才可以互相通信。
两端可以创建多条MessageBus。

* `MessageBus`
    * 创建MessageBus
    > 注意：sender端与receiver端创建MessageBus时要对应，同时使用匿名MessageBus或者namespace相同的MessageBus才可以互相通信。
    ```javascript
    // 创建匿名MessageBus
    var messageBus = senderManager.createMessageBus();
    // 创建命名MessageBus
    var messageBus = senderManager.createMessageBus('namespace');
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