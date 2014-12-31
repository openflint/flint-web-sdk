# Sender SDK

## 设备发现

```
var deviceScanner = new FlintDeviceScanner();
// 发现新设备
deviceScanner.on('devicefound', function(device) {
    // 获取设备名称
    var name = device.getName();
    // 获取Flint Service Url
    var url = device.getUrlBase();
    // 获取设备唯一ID
    var uniqueId = device.getUniqueId();
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

## 创建FlintSenderManager

```
var senderManager = new FlintSenderManager(
    appid, // application ID
    'http://127.0.0.1:9431', // Flint Service url
    true // 是否与Flint Service保持心跳
    );
// 设置Flint Service Url， 会覆盖创建FlintSenderManager时传递的Service url
senderManager.setServiceUrl(urlBase);
// 获取reciever端传递过来的custom additional data
senderManager.getAdditionalData();
// or
senderManager.on('customDataavailable', function(customData) {
});
```

## 创建通信链路

sender端与receiver端通过MessageBus进行通信。

    * 两端只要创建了相同namespace的MessageBus，消息就可以在这两个MessageBus之间传递。如果application只需要一个MessageBus就能满足需求，那么在两端可以各自创建一个匿名的MessageBus，也可以相互通信。
    * sender端的MessageBus与receiver端的MessageBus是多对一的关系，即多个sender可以创建同一个namespace的MessageBus，同时与1个receiver的MessageBus通信。

* 创建匿名MessageBus

    ```
    var bus = null;
    // 创建匿名MessageBus
    bus = senderManager.createMessageBus();
    // 创建命名MessageBus
    bus = senderManager.createMessageBus('namespace');    
    ```
* 监听事件

    ```
    messageBus.on('message', function(message) {
        console.log(message);
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

* 连接receiver

    ```
    // data connection
    senderManager.connectReceiverPeer(options);
    // stream call
    senderManager.callReceiverPeer(stream, options);
    ```

## Application控制
* 获取应用状态

    ```
    var callback = function(result, state, additionaldata) {
        // result：表示调用结果，true表示成功，false表示失败
        // state：application的状态，可能为'stopped'，'starting'或者'running'
        // additionaldata：receiver端传递过来的附加信息
    };
    senderManager.getState(callback); //第一种方式
    senderManager.on('appstate', callback); //第二种方式
    ```
* 启动应用

    ```
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

    ```
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