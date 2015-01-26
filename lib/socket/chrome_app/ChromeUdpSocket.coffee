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

class ChromeUdpSocket extends EventEmitter

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
        info =
            'persistent': false,
            'name': 'udpSocket',
            'bufferSize': 4096
        chrome.sockets.udp.create {}, (createInfo) =>
            @socketId_ = createInfo.socketId
            console.log 'create UdpSocket: ', @socketId_
            chrome.sockets.udp.bind @socketId_, '0.0.0.0', @localPort_, (result) =>
                console.log 'bind UdpSocket: port=', @localPort_, ', result=', result

                # set packet listener
                chrome.sockets.udp.onReceive.addListener (info)=>
                    if @socketId_ is info.socketId
                        @_onMessage ChromeUdpSocket.ab2str(info.data)

                # set error listener
                chrome.sockets.udp.onReceive.addListener (info)=>
                    if @socketId_ is info.socketId
                        @_onError 'error'

                @emit 'ready'

    _onMessage: (data)->
#        console.log 'received packet:\n', data
        if @onPacketReceived
            @onPacketReceived data

    _onError: (error) ->
        if @onerror
            @onerror error


    joinMulticastGroup: (addr) ->
        if @socketId_ is -1
            @.once 'ready', =>
                chrome.sockets.udp.joinGroup @socketId_, addr, (result)=>
                    console.log 'joinGroup UdpSocket: addr=', addr, ', result=', result
        else
            chrome.sockets.udp.joinGroup @socketId_, addr, (result)=>
                console.log 'joinGroup UdpSocket: addr=', addr, ', result=', result

    send: (data, addr, port) ->
        if not @socketId_
            return

        _data = ChromeUdpSocket.str2ab data
        chrome.sockets.udp.send @socketId_, _data, addr, port, (sendInfo) =>
            if sendInfo.resultCode < 0 # fail
                console.error 'UdpSocket: send error!!!'
            else # success
                console.log 'UdpSocket: send success, ', sendInfo.bytesSent

module.exports = ChromeUdpSocket
