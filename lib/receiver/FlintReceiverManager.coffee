#
# Copyright (C) 2013-2014, The OpenFlint Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS-IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

EventEmitter = require 'eventemitter3'
ReceiverMessageChannel = require './ReceiverMessageChannel'
MessageChannel = require '../common/MessageChannel'
ReceiverMessageBus = require './ReceiverMessageBus'
FlintConstants = require '../common/FlintConstants'
Peer = require '../peerjs/peer'

class FlintReceiverManager extends EventEmitter

    constructor: (@appId) ->
        if not @appId
            throw 'illegal APP ID'
        else
            console.info 'FlintReceiverManager appid = ', @appId

        @ipcChannel = null
        @ipcAddress = "ws://127.0.0.1:9431/receiver/" + @appId
        @FlintServerIp = '127.0.0.1'

        @defMessageChannel = @_createMessageChannel()
        @messageBusList = {}
        @defPeer = null
        @defPeerId = null

        @cusAdditionalData = null

    open: ->
        if @_isStarted()
            console.warn 'FlintReceiverManager is already opened'
            return

        # open MessageChannel before opening IPC
#        @defMessageChannel.open()

        @ipcChannel = new MessageChannel 'ipc', @ipcAddress
        @ipcChannel.on 'open', (event) =>
            console.log 'ipcChannel opened!!!'
            @_ipcSend
                type: 'register'
            @emit 'open', event

        @ipcChannel.on 'close', (event) =>
            console.log 'ipcChannel closed!!!'
            @ipcChannel = null
            @emit 'close', event

        @ipcChannel.on 'error', (event) =>
            console.error 'ipcChannel error!!!'
            @ipcChannel = null
            @emit 'error', event

        @ipcChannel.on 'message', (data) =>
            try
                console.log 'ipcChannel received message: [', data, ']'
                _data = JSON.parse data
                @_onIpcMessage _data
            catch e
                console.error 'error: ', e

        @ipcChannel.open()
        @defMessageChannel.open()

    _onIpcMessage: (data) ->
        switch data.type
            when 'startHeartbeat'
                console.info 'receiver ready to start heartbeat!!!'
            when 'registerok'
                console.info 'receiver register done!!!'
                @FlintServerIp = data['service_info']['ip'][0]
                # uuid = data['service_info']['uuid']
                # device_name = data['service_info']['device_name']
                additionalData = @_joinAdditionalData()
                if additionalData
                    @_ipcSend
                        type: 'additionaldata'
                        additionaldata: additionalData
                else
                    console.warn 'no additionaldata need to send'
            when 'heartbeat'
                if data.heartbeat is 'ping'
                    @_ipcSend
                        type: 'heartbeat'
                        heartbeat: 'pong'
                else if data.heartbeat is 'pong'
                    @_ipcSend
                        type: 'heartbeat'
                        heartbeat: 'ping'
                else
                    console.error 'unknow heartbeat message!!!'
            when 'senderconnected'
                @emit 'senderconnected', data.token
                console.info 'IPC senderconnected: ', data.token
            when 'senderdisconnected'
                @emit 'senderdisconnected', data.token
                console.info 'IPC senderdisconnected: ', data.token
            else
                console.error 'IPC unknow type: ', data.type

    setAdditionalData: (additionaldata) ->
        console.info "set custom additionaldata: ", additionaldata
        @cusAdditionalData = additionaldata
        additionalData = @_joinAdditionalData()
        if additionalData
            @_ipcSend
                type: 'additionaldata'
                additionaldata: additionalData
        else
            console.warn 'no additionaldata need to send'

    _joinAdditionalData: ->
        additionalData = {}
        additionalData[@defMessageChannel.getName()] = 'ws://' + @FlintServerIp + ':9439/channels/' + @defMessageChannel.getName()
        for own key, value of @cusAdditionalData
            additionalData[key] = value
        if @defPeer and @defPeerId
            additionalData['peerId'] = @defPeerId
        if Object.keys(additionalData).length > 0
            return additionalData
        else
            return null

    close: ->
        if @_isStarted()
            @_ipcSend
                type: 'unregister'
            @defMessageChannel = null
            @messageBusList = null
            @ipcChannel?.close()
            @ipcChannel = null
            @defPeer = null
        else
            throw 'FlintReceiverManager is not started, cannot close!!!'

    _createMessageChannel: ->
        if @_isStarted()
            throw 'FlintReceiverManager is started, cannot create default message channel'
        if not @defMessageChannel
            url = 'ws://127.0.0.1:9439/channels/' + FlintConstants.DEFAULT_CHANNEL_NAME
            @defMessageChannel = new ReceiverMessageChannel FlintConstants.DEFAULT_CHANNEL_NAME, url
            @defMessageChannel.on 'open', (event) =>
                console.log 'Receiver default message channel open!!! ', event
            @defMessageChannel.on 'close', (event) =>
                console.log 'Receiver default message channel open!!! ', event
            @defMessageChannel.on 'error', (event) =>
                console.log 'Receiver default message channel open!!! ', event
        return @defMessageChannel

    #
    # for android/iOS senders, don't suggest to use this API if the sender is a web app
    #
    createMessageBus: (namespace) ->
        if not namespace
            namespace = FlintConstants.DEFAULT_NAMESPACE
        if not @defMessageChannel
            throw 'createMessageBus failed: default MessageChannel is null'
        messageBus = @_createMessageBus namespace
        return messageBus

    _createMessageBus: (namespace) ->
        messageBus = null
        if @messageBusList[namespace]
            messageBus = @messageBusList[namespace]
        else
            messageBus = new ReceiverMessageBus @defMessageChannel, namespace
            @messageBusList[namespace] = messageBus
        return messageBus

    #
    # TODO: need this API???
    #
    _getMessageBusList: ->
        return @messageBusList

    createPeer: ->
        if not @defPeer
            @defPeer = new Peer
                host: '127.0.0.1'
                port: '9433'
            @defPeer.on 'open', (peerId) =>
                @defPeerId = peerId
        return @defPeer

    createCustomPeer: ->
        peer = new Peer
            host: '127.0.0.1'
            port: '9433'
        return peer

    _isStarted: ->
        return @ipcChannel && ipcChannel.isOpened()

    _ipcSend: (message) ->
        message['appid'] = @appId
        data = JSON.stringify message
        @ipcChannel?.send data

module.exports = FlintReceiverManager