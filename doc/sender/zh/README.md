# Sender SDK

## 设备发现

* FlintDeviceScanner
```javascript
var deviceScanner = new FlintDeviceScanner();
// 发现新设备
deviceScanner.on('devicefound', function(device) {
});
// 设备离开
deviceScanner.on('devicegone', function(device) {
});
// 开始扫描
deviceScanner.start();
// 停止扫描
deviceScanner.stop();
// 获取设备列表
deviceScanner.getDeviceList();
```

* FlintDevice
```javascript
// 获取设备名称
device.getName();
// 获取Flint Service Url
device.getUrlBase();
```

## 创建FlintSenderManager
```javascript
var senderManager = new FlintSenderManager(
    appid /* application ID */,
    'http://127.0.0.1:9431' /* Flint Service url */,
    true /* 是否与Flint Service保持心跳 */);
    
// 设置Flint Service Url， 会覆盖创建FlintSenderManager时传递的Service url
senderManager.setServiceUrl(urlBase);

// 获取reciever端传递过来的additional data
senderManager.getAdditionalData();
```

## 创建通信链路
sender端与receiver端创建MessageBus时要对应，同时使用匿名MessageBus或者namespace相同的MessageBus才可以互相通信。
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