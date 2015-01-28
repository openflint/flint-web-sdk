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
FlintDevice = require './FlintDevice'

class FlintDeviceScanner extends EventEmitter

    INTERVAL = 10 * 1000

    constructor: ->
        @devices = {}
        @ssdpManager = null

        @_init()

    _init: ->
        @_initSSDP()

    _createSSDP: ->
        throw 'Not Implement'

    _initSSDP: ->
        console.info 'init SSDPManager'
        @ssdpManager = @_createSSDP()
        @ssdpManager.on 'adddevice', (device) =>
            @_addDevice device
        @ssdpManager.on 'removedevice', (uniqueId) =>
            @_removeDevice uniqueId

    _addDevice: (device) ->
        uniqueId = device.getUniqueId()
        if not @devices[uniqueId]
            console.log 'found device: ', device.getName()
            @devices[uniqueId] = device
            device.on 'devicetimeout', (_uniqueId) =>
                @_removeDevice _uniqueId
            @emit 'devicefound', device

    _removeDevice: (uniqueId) ->
        if @devices[uniqueId]
            console.warn 'gone device: ', @devices[uniqueId].getName()
            @emit 'devicegone', @devices[uniqueId]
            delete @devices[uniqueId]

    start: ->
        @ssdpManager?.start()

    stop: ->
        @ssdpManager?.stop()

    getDeviceList: ->
        dList = []
        for _, value of @devices
            dList.push value
        return dList

module.exports = FlintDeviceScanner
