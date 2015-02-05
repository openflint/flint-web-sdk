# Getting Started
```
var appInfo = {
    appUrl: 'http://www.your-app.com/index.html',
    useIpc: true,
    maxInactive: -1
};
var senderManager = new FlintSenderManager({
    appId: '~appId',
    urlBase: 'http://xxx.xxx.xxx.xxx:9431',
    host: 'xxx.xxx.xxx.xxx',
    useHeartbeat: true
});
// launch application
senderManager.launch(appInfo, function(result, token) {
    if (result) { // true means success
        var bus = senderManager.createMessageBus();
        // received message
        bus.on('message', function(message) {
            console.log(message);
        });
        // send message
        bus.send('some message');
    }
});
// stop application
senderManager.stop(appInfo, function(result) {
    console.log('stop result: ', result);
});
```

---
# API

## FlintSenderManager

### Methods
* constructor
    * description
    * parameters
        * options
            * appId: application ID
            * urlBase: http url, means Flint Service url
            * host: ip address, means Flint Server host
            * useHeartbeat: boolean type, means keeping heartbeat with Flint Service or not
            
* getAdditionalData
    * description  
        * Get additional from receiver application, this method may return null-value if the receiver application is in a starting process. For this, you can listen 'customDataavailable' event to obtain the additional data.
    * parameters  
        * none
    * return value
        * (string)additional data
        
* getState
    * description  
        * Get a application's state
    * parameters
        * function callback(result, state, additionalData)
            * result(bool): success or failed
            * state(string): application's state
            * additionalData(string): 
    * return value
        * none

* launch
    * description  
        * launch application
    * parameters
        * appInfo
            * appUrl(string): application's address
            * useIpc(bool): need to communicate with receiver or not
            * maxInactive(int): receiver closed timeout, ignore this if useIpc is true
        * function callback(result, token)
            * result(bool): , success or failed
            * token(string): unused
    * return value
        * none

* relaunch
    * description  
        * relaunch application
    * parameters
        * appInfo
            * appUrl(string): application's address
            * useIpc(bool): need to communicate with receiver or not
            * maxInactive(int): receiver closed timeout, ignore this if useIpc is true
        * function callback(result, token)
            * result: success or failed
            * token: unused
    * return value
        * none

* join
    * description  
        * join a running application
    * parameters
        * appInfo
            * appUrl(string): application's address
            * useIpc(bool): need to communicate with receiver or not
            * maxInactive(int): receiver closed timeout, ignore this if useIpc is true
        * function callback(result, token)
            * result: success or failed
            * token: unused
    * return value
        * none

* stop
    * description  
        * stop application
    * parameters
        * appInfo
            * appUrl(string): application's address
            * useIpc(bool): need to communicate with receiver or not
            * maxInactive(int): receiver closed timeout, ignore this if useIpc is true
        * function callback(result)
            * result: success or failed
    * return value
        * none

* disconnect
    * description  
        * disconnect self and flint service and not stop application
    * parameters
        * appInfo
            * appUrl(string): application's address
            * useIpc(bool): need to communicate with receiver or not
            * maxInactive(int): receiver closed timeout, ignore this if useIpc is true
        * function callback(result)
            * result: success or failed
    * return value
        * none

* createMessageBus
    * description  
        * MessageBus is a virtual message channel between sender and receiver, text message could be transferred.
    * parameters
        * namespace(optional, string): the namespace of the created MessageBus
    * return value
        * SenderMessageBus(Object)

* connectReceiverDataPeer
    * description
        * create a data peer and connect it to receiver's data peer, more information please refer to <http://peerjs.com>
    * parameter
        * options(object)

* callReceiverMediaPeer
    * description
        * create a media peer and call receiver's media peer, and pass a media stream to receiver, more information please refer to <http://peerjs.com>
    * parameter
        * stream(object): media stream, like video stream
        * options(object):


### Events
* customDataavailable

```    
    FlintSenderManager.on('customDataavailable', function(customData) {        
    });
```

## SenderMessageBus

### Methods
* constructor
    description: you shouldn't create SenderMessageBus directly, SenderMessageBus should be created by FlintSenderManager.createMessageBus().
    
* send
    * description
        * send text message to receiver's MessageBus whose namespace is the same as this MessageBus's.
    * parameter
        * data(string): text message

### Events
* 'message'

```
    messageBus.on('message', function(message) {
        console.log(message);
    });
```