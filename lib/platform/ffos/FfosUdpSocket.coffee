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

class FfosUdpSocket extends EventEmitter

    constructor: (@options) ->
        @localPort_ = options.localPort
        @loopback_ = options.loopback

        @socket_ = new UDPSocket(options)

        @socket.onmessage = (event) =>
            data = String.fromCharCode.apply null, new Uint8Array(event.data)
            _onMessage data

    _onMessage: (data)->
#        console.log 'received packet:\n', data
        if @onPacketReceived
            @onPacketReceived data

    joinMulticastGroup: (addr) ->
        @socket?.joinMulticastGroup addr

    send: (data, addr, port) ->
        @socket?.send data, addr, port

module.exports = FfosUdpSocket
