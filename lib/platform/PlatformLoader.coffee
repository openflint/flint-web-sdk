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

PlatformDummy = require './PlatformDummy'
PlatformFfos = require './ffos/PlatformFfos'
Platform = require '../common/Platform'

class PlatformLoader

    @platform = null

    @getPlatform: ->
        if not PlatformLoader.platform
            platform = Platform.getPlatform()
            console.info 'Platform is : ', platform.browser
            try
                switch platform.browser
                    when 'ffos'
                        PlatformLoader.platform = new PlatformFfos()
                    else
                        PlatformLoader.platform = new PlatformDummy()
            catch e
                PlatformLoader.platform = null
                console.error 'catch: ', e

            if not PlatformLoader.platform
                PlatformLoader.platform = new PlatformDummy()

        return PlatformLoader.platform

module.exports = PlatformLoader
