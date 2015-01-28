"use strict";

const { Class }  = require('sdk/core/heritage');
const { emit } = require('sdk/event/core');
const { Cc, Ci, Cu } = require('chrome');

Cu.import('resource://gre/modules/Services.jsm');
Cu.import('resource://gre/modules/XPCOMUtils.jsm');

XPCOMUtils.defineLazyGetter(this, 'converter', function () {
    var conv = Cc['@mozilla.org/intl/scriptableunicodeconverter'].createInstance(Ci.nsIScriptableUnicodeConverter);
    conv.charset = 'utf8';
    return conv;
});

const UDPSocketFirefox = Class({
    socket_: null,

    initialize: function (options) {
        var udpOptions = {
            localAddress: '0.0.0.0',
            localPort: options.localPort,
            loopback: options.loopback
        };

        this.socket_ = Cc['@mozilla.org/network/udp-socket;1'].createInstance(Ci.nsIUDPSocket);
        if (this.socket_ == null) {
            throw 'UDPSocket: create socket failed!';
        }

        this.socket_.init(udpOptions);
        this.socket_.asyncListen(this);
    },

    joinMulticastGroup: function (addr) {
        this.socket_.joinMulticast(addr);
    },

    close: function () {
        this.socket_.close();
    },

    send: function (data, addr, port) {
        try {
            var packet = converter.convertToByteArray(data);
            this.socket_.send(addr, port, packet, packet.length);
        } catch (e) {
            console.error('UDPSocket: send error : ' + e);
        }
    },

    onPacketReceived: function (socket, packet) {
        if ('onPacket' in this) {
            this.onPacket(packet.data);
        }
    }
});

exports.UDPSocketFirefox = UDPSocketFirefox;
