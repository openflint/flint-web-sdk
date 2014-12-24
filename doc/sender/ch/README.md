# Sender SDK

## 创建FlintSenderManager
```javascript
var senderManager = new FlintSenderManager(
    appid /* application ID */,
    'http://127.0.0.1:9431' /* Flint Service url */,
    true /* 是否与FLint Service保持心跳 */);
```

## 创建通信链路
通信链路有两种，分别是`MessageChannel`与`MessageBus`，都可以与receiver端进行通信。  
两者的区别是：每条`MessageChannle`是单独的一个websocket连接，而`MessageBus`是基于一个SDK预先创建好的`MessageChannel`之上，通过不同的`namespace`模拟出多条通信链路。

* `MessageChannel`
    * 创建MessageChannel  
    ```javascript
    // 创建一个匿名通道
    var messageChannel = senderManager.createMessageChannel();
    // 创建命名通道
    var messageChannel = senderManager.createCustomMessageChannel('channel name');
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
// 创建default peer，sender sdk会帮助这个peer获取到receiver端同样通过createPeer接口创建的peer的peerId
var peer = senderManager.createPeer();
// 创建自定义peer，需要developer自己实现某种方式获取到receiver端通过同样接口createCustomPeer接口创建的peer的peerId
var peer = senderManager.createCustomPeer();
```
* 连接receiver
```javascript
// data connection
peer.connectReceiverPeer(options);
// stream call
peer.callReceiverPeer(stream, options);
```

## Application控制
* 获取应用状态
```javascript
var callback = function(result, state, additionaldata) {
    // result：表示调用结果，true表示成功，false表示失败
    // state：application的状态，可能为'stopped'，'starting'或者'running'
    // additionaldata：receiver端传递过来的附加信息
};
senderManager.getState(callback); //第一种方式
senderManager.on('appstate', callback); //第二种方式
senderManager.getState();
```
* 启动应用
```javascript
var appInfo = {
    appUrl: url,
    useIpc: true or false,
    maxInactive: int
};
var callback = function(type, result, token) {
    // type：固定为'app'+api名称，比如调用launch接口，type就是'applaunch'
    // result：表示调用结果，true表示成功，false表示失败
    // token：如果Flint Service成功处理了这个请求，就会为这个请求创建一个标示这个请求的token，返回给sender端
};
//
// 启动应用：
//
senderManager.launch(appInfo, callback); //第一种方式
senderManager.launch(appInfo) //第二种方式
senderManager.on('applaunch', callback);
//
// 重新启动应用：
//
senderManager.relaunch(appInfo, callback); //第一种方式
senderManager.relaunch(appInfo) //第二种方式
senderManager.on('apprelaunch', callback);
//
// 加入应用：
//
senderManager.join(appInfo, callback); //第一种方式
senderManager.join(appInfo) //第二种方式
senderManager.on('appjoin', callback);
```
* 停止应用
```javascript
var callback = function(type, result) {
    // type：固定为'app'+api名称，比如调用stop接口，type就是'appstop'
    // result：表示调用结果，true表示成功，false表示失败
};
//
// 停止应用：
//
senderManager.stop(appInfo, callback); //第一种方式
senderManager.on('appstop', callback); //第二种方式
senderManager.stop(appInfo);
//
// 断开与Flint Service的链接，而不停止应用：
//
senderManager.disconnect(appInfo, callback); //第一种方式
senderManager.on('appdisconnect', callback); //第二种方式
senderManager.disconnect(appInfo);
```