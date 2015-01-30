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

class UdpSocketChrome extends EventEmitter

    @ab2str: (buf) =>
        return String.fromCharCode.apply null, new Uint8Array(buf)

    @str2ab: (str) =>
        buf = new ArrayBuffer str.length
        bufView = new Uint8Array buf
        for i, _ of str
            bufView[i] = str.charCodeAt i
        return buf

    constructor: (@options) ->
        @localPort_ = options.localPort
        @loopback_ = options.loopback

        @socketId_ = -1

        @_init()

    _init: ->
        udpInfo =
            'persistent': false,
            'name': 'Flint',
            'bufferSize': 4096
        chrome.sockets.udp.create udpInfo, (createInfo) =>
            @socketId_ = createInfo.socketId
            console.log 'create UdpSocket: ', @socketId_

            chrome.sockets.udp.setMulticastLoopbackMode @socketId_, @loopback_, (result) =>
                console.log 'setMulticastLoopbackMode UdpSocket: loopback=', @loopback_, ', result=', result

            chrome.sockets.udp.bind @socketId_, '0.0.0.0', @localPort_, (result) =>
                console.log 'bind UdpSocket: port=', @localPort_, ', result=', result
                @emit 'bind'

            # set packet listener
            chrome.sockets.udp.onReceive.addListener @_onReceiveListener
            # set error listener
            chrome.sockets.udp.onReceiveError.addListener @_onReceiveErrorListener

            @emit 'create'

    _onReceiveListener: (info)=>
        if @socketId_ is info.socketId
            @_onMessage UdpSocketChrome.ab2str(info.data)

    _onMessage: (data)->
#        console.log 'received packet:\n', data
        if @onPacket
            @onPacket data

    _onReceiveErrorListener: (info)=>
        if @socketId_ is info.socketId
            @_onError 'error'

    _onError: (error) ->
        if @onError
            @onError error

#    bind: (port)->
#        if @socketId_ is -1
#            @.once 'create', =>
#                @_bind port
#        else
#            @_bind port

#    _bind: (port) ->
#        chrome.sockets.udp.bind @socketId_, '0.0.0.0', port, (result) =>
#            console.log 'bind UdpSocket: port=', port, ', result=', result
#            @emit 'bind'

    joinMulticastGroup: (addr) ->
        if @socketId_ is -1
            @.once 'create', =>
                @_joinMulticastGroup addr
        else
            @_joinMulticastGroup addr

    _joinMulticastGroup: (addr) ->
        chrome.sockets.udp.joinGroup @socketId_, addr, (result)=>
            console.log 'joinGroup UdpSocket: addr=', addr, ', result=', result

    send: (data, addr, port) ->
        if @socketId_ is -1
            return

        _data = UdpSocketChrome.str2ab data
        chrome.sockets.udp.send @socketId_, _data, addr, port, (sendInfo) =>
            if sendInfo.resultCode < 0 # fail
                console.error 'UdpSocket: send error!!!'
            else # success
                console.log 'UdpSocket: send success, ', sendInfo.bytesSent

    close: ->
        if @socketId_
            chrome.sockets.udp.close @socketId_, =>
                chrome.sockets.udp.onReceive.removeListener @_onReceiveListener
                chrome.sockets.udp.onReceiveError.removeListener @_onReceiveErrorListener
                console.log 'socket closed! ', @socketId_

module.exports = UdpSocketChrome
