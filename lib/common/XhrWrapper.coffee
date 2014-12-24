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

Base64 = require('js-base64').Base64

class XhrWrapper

    constructor: (pluginLoader) ->
        @proxy = false

        plugin = pluginLoader.getPlugin()
        @xhrObj = plugin.createXMLHttpRequest()
        if not @xhrObj
            throw 'createXMLHttpRequest failed!!!'

        if @xhrObj.setOnReadyStateChangeCallback
            @proxy = true

        if @proxy
            _callback = =>
                readyState = @xhrObj.getReadyState()
                if readyState is 4
                    @xhrObj.readyState = readyState
                    @xhrObj.status = @xhrObj.getStatus()
                    respondText = @xhrObj.getResponseText()
                    @xhrObj.responseText = Base64.decode respondText
                    if @xhrObj.onreadystatechange
                        @xhrObj.onreadystatechange()
            # _callback.bind @
            @xhrObj.setOnReadyStateChangeCallback _callback

    #
    # callback: (statusCode, responseText) =>
    #
    request: (method, url, headers, data, callback) ->
        if not @proxy
            @xhrObj.timeout = 3 * 1000
        @xhrObj.open method, url

        if headers
            for key, value of headers
                @xhrObj.setRequestHeader key, value

        @xhrObj.onreadystatechange = =>
            if @xhrObj.readyState is 4
                # console.error ' received:\n', @xhrObj.responseText
                callback? @xhrObj.status, @xhrObj.responseText

        if not @proxy
            @xhrObj.onerror = =>
                console.error 'XhrWrapper Error: ', method, ' - ', url, ' - ', data
                callback? -1, 'error'

        if data
            @xhrObj.send JSON.stringify(data)
        else
            @xhrObj.send ''

module.exports = XhrWrapper
