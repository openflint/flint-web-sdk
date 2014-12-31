"use strict"

/*
 * Player Class
 * How to use:
 * //1. Create MediaPlayer Instance
 * var mediaPlayer = new MediaPlayer("{video element id}");
 * //2. Listen message from sender, data is a json object
 * mediaPlayer.on("message", function(data){
 *
 * });
 * //3. send message to receiver
 * mediaPlayer.send("{String}");
 * @param {String|videoElement} video Element id  or video element
 **/
var MediaPlayer = function (manager, videoId) {
    var self = this;
    self.status = "IDLE";
    self.playerState = "IDLE";
    self.title = "";
    self.subtitle = "";
    self.mediaMetadata = null;
    self.videoVolume = 0;
    //----------------------------------------------
    self.requestId = 0;
    self.requestIdLoad = 0;
    self.requestIdPause = 0;
    self.requestIdPlay = 0;
    self.requestIdSetVolume = 0;
    self.requestIdSeek = 0;
    self.requestIdGetStatus = 0;

    self.receiverManager = manager;
    var messageBus = self.receiverManager.createMessageBus("urn:flint:org.openflint.fling.media");

    var video = (typeof(videoId) == "string") ? document.getElementById(videoId) : videoId;
    if (video == null) {
        throw Error("video element undefined!");
    }
    video.style.visibility = "visible";
    function syncExecute(readyCallback) {
        if (self.status == "READY") {
            if (typeof(readyCallback != "undefined" && readyCallback != null)) {
                readyCallback();
            }
        } else if (self.status == "IDLE") {
            return;
        } else if (self.status == "LOADDING") {
            setTimeout(function () {
                syncExecute(readyCallback);
            }, 50);
        }
    };

    /*
     * MessageReport Class
     * Wrapper protocol message
     **/
    var MessageReport = function () {
        function loadData() {
            var duration = 0;
            if (video.duration) {
                duration = video.duration;
            }
            return {
                "type": "MEDIA_STATUS",
                "status": [
                    {
                        "mediaSessionId": 1,
                        "playbackRate": video.playbackRate,
                        "currentTime": video.currentTime,
                        "duration": duration,
                        "supportedMediaCommands": 15,
                        "volume": {
                            "level": video.volume,
                            "muted": video.muted
                        }
                    }
                ],
                "requestId": 0
            };
        }

        this.idle = function (idleReason) {
            var messageData = loadData();
            messageData.status[0].playerState = "IDLE";
            messageData.status[0].idleReason = idleReason;
            messageBus.send(JSON.stringify(messageData), _senderId);
            if (idleReason == "FINISHED") {
                video.style.visibility = "hidden";
            }
        };
        this.loadmetadata = function () {
            var messageData = loadData();
            messageData["requestId"] = self.requestIdLoad;

            messageData.status[0].playerState = "PLAYING";
            messageData.status[0].media = {
                "streamType": self.mediaMetadata.media.streamType,
                "duration": video.duration,
                "contentType": self.mediaMetadata.media.contentType,
                "contentId": self.mediaMetadata.media.contentId,
                "metadata": {
                    // "studio": self.mediaMetadata.media.metadata.studio,
                    "title": self.mediaMetadata.media.metadata.title,
                    "subtitle": self.mediaMetadata.media.metadata.subtitle,
                    "images": self.mediaMetadata.media.metadata.images,
                    "metadataType": self.mediaMetadata.media.metadata.metadataType
                }
            };
            video.style.visibility = "visible";
            messageBus.send(JSON.stringify(messageData), _senderId);
        };
        this.playing = function () {
            var messageData = loadData();
            messageData["requestId"] = self.requestIdPlay;
            self.playerState = messageData.status[0].playerState = "PLAYING";
            messageBus.send(JSON.stringify(messageData), _senderId);
        };
        this.paused = function () {
            var messageData = loadData();
            messageData["requestId"] = self.requestIdPause;
            self.playerState = messageData.status[0].playerState = "PAUSED";
            messageBus.send(JSON.stringify(messageData), _senderId);
        };
        this.buffering = function () {
            var messageData = loadData();
            messageData.status[0].playerState = "BUFFERING";
            messageBus.send(JSON.stringify(messageData), _senderId);
        };

        this.syncPlayerState = function (type) {
            var messageData = loadData();
            if (type == "seeked") {
                messageData["requestId"] = self.requestIdSeek;
            } else if (type == "volumechange") {
                messageData["requestId"] = self.requestIdSetVolume;
            }
            if (self.mediaMetadata != null) {
                messageData.status[0].media = {
                    "streamType": self.mediaMetadata.media.streamType,
                    "duration": video.duration,
                    "contentType": self.mediaMetadata.media.contentType,
                    "contentId": self.mediaMetadata.media.contentId,
                    "metadata": {
                        "title": self.mediaMetadata.media.metadata.title,
                        "subtitle": self.mediaMetadata.media.metadata.subtitle,
                        "images": self.mediaMetadata.media.metadata.images,
                        "metadataType": self.mediaMetadata.media.metadata.metadataType
                    }
                };
            }
            messageData.status[0].playerState = self.playerState;
            messageBus.send(JSON.stringify(messageData), _senderId);
        }

    };

    //create MessageReport Object.
    var messageReport = new MessageReport();

    self.load = function (url, videoType, title, subtitle, mediaMetadata) {
        self.mediaMetadata = mediaMetadata;

        self.status = "LOADDING";
        // var source = document.createElement('source');
        // source.src = url;
        // if (typeof(videoType) != "undefined" && videoType) {
        //     source.type = videoType;
        // }
        // video.innerHTML = "";
        // video.appendChild(source);
        video.src = url;
        video.load();

        if (typeof(title) != "undefined" && !title) {
            self.title = title;
        }
        if (typeof(subtitle) != "undefined" && !subtitle) {
            self.subtitle = subtitle;
        }
        video.autoplay = true;
        video.controls = false;
    };

    self.pause = function () {
        syncExecute(function () {
            video.pause();
        });
    };

    self.play = function () {
        syncExecute(function () {
            video.play();
        });
    };

    self.seek = function (value) {
        syncExecute(function () {
            var seekToTime = value;
            if (seekToTime < 0 || seekToTime > video.duration) {
                return;
            }
            video.currentTime = seekToTime;
        });
    };

    self.volumechange = function (num) {
        console.info("==========================self.volumechange===[" + num + "]=======================");
        syncExecute(function () {
            video.volume = num;
        });
        ("onvolumechange" in self) && self.onvolumechange(num);
        if (num == self.videoVolume) {
            messageReport.syncPlayerState("volumechange");
        }
    };

    var _senderId = "*:*";

    messageBus.on("senderConnected", function (senderId) {
        console.log("@#@#@#@#", "MediaPlayer received sender connected: ", senderId);
    });

    messageBus.on("senderDisconnected", function (senderId) {
        console.log("@#@#@#@#", "MediaPlayer received sender disconnected: ", senderId);
    });

    /*
     * sender message listener.
     **/
    messageBus.on("message", function (message, senderId) {
        console.info("messageBus received: ", senderId, message);
        var messageData = JSON.parse(message);
        self.requestId = messageData.requestId;
        if ("type" in messageData) {
            switch (messageData.type) {
                case "LOAD":
                    (self.requestId) && (self.requestIdLoad = self.requestId);
                    self.load(messageData.media.contentId, messageData.media.contentType, messageData.media.metadata.title, messageData.media.metadata.subtitle, messageData);
                    break;

                case "PAUSE":
                    (self.requestId) && (self.requestIdPause = self.requestId);
                    self.pause();
                    break;

                case "PLAY":
                    (self.requestId) && (self.requestIdPlay = self.requestId);
                    self.play();
                    break;

                case "SET_VOLUME":
                    (self.requestId) && (self.requestIdSetVolume = self.requestId);
                    self.volumechange(messageData.volume.level);
                    break;

                case "SEEK":
                    (self.requestId) && (self.requestIdSeek = self.requestId);
                    self.seek(messageData.currentTime);
                    break;

                case "PING":
                    break;

                case "GET_STATUS":
                    (self.requestId) && (self.requestIdGetStatus = self.requestId);
                    messageReport.syncPlayerState();
                    break;
            }

        }
        ("onmessage" in self) && self.onmessage(message);
    });

    //video event linstener 
    video.addEventListener("emptied", function (e) {
        messageReport.idle("NONE");
    });
    video.addEventListener("loadedmetadata", function (e) {
        self.status = "READY";
        messageReport.loadmetadata();
    });
    video.addEventListener("play", function (e) {
        messageReport.playing();
    });
    video.addEventListener("playing", function (e) {
        messageReport.playing();
    });
    video.addEventListener("waiting", function (e) {
        messageReport.buffering();
    });
    video.addEventListener("pause", function (e) {
        messageReport.paused();
    });
    video.addEventListener("ended", function (e) {
        messageReport.idle("FINISHED");
    });
    video.addEventListener("volumechange", function (e) {
        self.videoVolume = video.volume;
        console.info("----------------------------------volumechange------------------------------");
        messageReport.syncPlayerState("volumechange");
    });
    video.addEventListener("seeked", function (e) {
        messageReport.syncPlayerState("seeked");
    });
    video.addEventListener("canplay", function (e) {
        messageReport.syncPlayerState();
    });

    video.addEventListener("error", function (e) {
        messageReport.idle("ERROR");
    });
    video.addEventListener("abort", function (e) {
        messageReport.idle("INTERRUPTED");
    });

    self.sendMessage = messageBus.send;

    self.on = function (type, func) {
        self["on" + type] = func;
    };
};
