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

Platform = require '../common/Platform'
ChromeUdpSocket = require './chrome_app/ChromeUdpSocket'
FfosUdpSocket = require './ffos/FfosUdpSocket'

class SocketGenerator

    @createUdpSocket: (options)->
        platform = Platform.getPlatform()
        try
            switch platform.browser
                when 'ffos'
                    return new FfosUdpSocket(options)
                when 'chrome_app'
                    return new ChromeUdpSocket(options)
                else
                    return null
        catch e
            console.error 'catch: ', e

module.exports = SocketGenerator
