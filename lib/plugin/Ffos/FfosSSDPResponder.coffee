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
#PluginLoader = require '../../plugin/PluginLoader'
XhrWrapper = require '../../common/XhrWrapper'
SSDPDevice = require '../../discovery/ssdp/SSDPDevice'

SEARCH_INTERVAL = 5 * 1000

SSDP_PORT = 1900
SSDP_ADDRESS = '239.255.255.250'

SSDP_DISCOVER_MX = 10
SSDP_DISCOVER_PACKET =
        'M-SEARCH * HTTP/1.1\r\n' +
        'HOST: ' + SSDP_ADDRESS + ':' + SSDP_PORT + '\r\n' +
        'MAN: \"ssdp:discover\"\r\n' +
        'MX: ' + SSDP_DISCOVER_MX + '\r\n' +
        'ST: %SEARCH_TARGET%\r\n\r\n'
SSDP_RESPONSE_HEADER = /HTTP\/\d{1}\.\d{1} \d+ .*/
SSDP_HEADER = /^([^:]+):\s*(.*)$/

SSDP_SEARCH_TARGET = 'urn:dial-multiscreen-org:service:dial:1'

# TODO: to be implemented
class FfoxSSDPResponder extends EventEmitter

    constructor: (@pluginLoader, @options) ->
        @ssdpServer = null
        @ssdpClient = null
        @started = false

    _init: ->
        @ssdpServer = PluginLoader.getPlugin().createUdpServer SSDP_PORT,
            multicast: true
            multicastTTL: 16
            multicastGroup: SSDP_ADDRESS
            reuseAddress: true
        @ssdpServer.addEventListener "data", (event) =>
            @_onData event.read()

        @ssdpClient = PluginLoader.getPlugin().createUdpClient SSDP_ADDRESS, SSDP_PORT,
            multicast: true,
            multicastTTL: 16

    start: (interval) ->
        if @started
            throw 'FfosSSDPResponder already started'

        if interval is undefined
            interval = SEARCH_INTERVAL

        @started = true
        @_init()

        @ssdpServer.listen()

        interval = interval or SEARCH_INTERVAL
        @searchTimerId = setInterval (=>
            @_search()), interval
        @_search()

    _search: ->
        data = SSDP_DISCOVER_PACKET
        _data = data.replace '%SEARCH_TARGET%', @searchTarget
        @ssdpClient.send _data

    stop: ->
        if not @started
            console.warn 'FfosSSDPResponder is not started'
            return

        @started = false
        if @searchTimerId
            clearInterval @searchTimerId

        @ssdpServer?.close()
        delete @ssdpServer
        @ssdpClient?.close()
        delete @ssdpClient

    _onData: (data) ->
        # Listen for responses from specific targets. There could be more than one
        # available.
        lines = data.toString().split '\r\n'
        firstLine = lines.shift()
        method =
            if SSDP_RESPONSE_HEADER.test(firstLine)
                'RESPONSE'
            else
                firstLine.split(' ')[0].toUpperCase()
        headers = {}
        lines.forEach (line) =>
            if line.length
                pairs = line.match(/^([^:]+):\s*(.*)$/)
                if pairs
                    headers[pairs[1].toLowerCase()] = pairs[2]

        if method is 'M-SEARCH'
            # ignore
        else if method is 'RESPONSE'
            @_onResponse headers
        else if method is 'NOTIFY'
            @_onNotify headers

    _onResponse: (headers) ->
        if headers.location and @options.st is headers.st
            @_fetchDeviceDesc headers.location

    _onNotify: (headers) ->
        if headers.location and @options.st is headers.st
            if headers.nts == 'ssdp:alive'
                @_fetchDeviceDesc headers.location
            else if headers.nts == 'ssdp:byebye'
                @emit 'devicebyebye', headers.udn

    _fetchDeviceDesc: (url) ->
        xhr = new XhrWrapper PluginLoader
        xhr.request 'GET', url, null, null, (statusCode, responseText) =>
            if statusCode is 200
                @_parseDeviceDesc responseText

    _parseDeviceDesc: (data) ->
        try
            xml = null
            if window.DOMParser # Standard
                parser = new DOMParser()
                xml = parser.parseFromString data, "text/xml"
            else # for IE
                xml = new ActiveXObject "Microsoft.XMLDOM"
                xml.async = "false"
                xml.loadXML data

            urlBase = null
            urls = xml.querySelectorAll 'URLBase'
            if urls and urls.length > 0
                urlBase = urls[0].innerHTML

            devices = xml.querySelectorAll 'device'
            if devices.length > 0
                @_parseSingleDeviceDesc devices[0], urlBase
        catch e
            console.error e

    _parseSingleDeviceDesc: (deviceNode, urlBase) ->
        deviceType = deviceNode.querySelector('deviceType').innerHTML
        udn = deviceNode.querySelector("UDN").innerHTML
        friendlyName = deviceNode.querySelector('friendlyName').innerHTML
        manufacturer = deviceNode.querySelector('manufacturer').innerHTML
        modelName = deviceNode.querySelector('modelName').innerHTML
        device = new SSDPDevice
            uniqueId: udn
            urlBase: urlBase
            deviceType: deviceType
            udn: udn
            friendlyName: friendlyName
            manufacturer: manufacturer
            modelName: modelName
        @emit 'devicealive', device

module.exports = FfoxSSDPResponder
