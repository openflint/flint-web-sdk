module.exports = (grunt) ->

    # Project configuration.
    grunt.initConfig
        pkg: grunt.file.readJSON 'package.json'

        browserify:
            sender:
                files:
                    'out/sender/chrome/flint_sender_sdk.js': ['lib/sender/chrome/exports.coffee']
                    'out/sender/firefox/flint_sender_sdk.js': ['lib/sender/firefox/exports.coffee']
                    'out/sender/ffos/flint_sender_sdk.js': ['lib/sender/ffos/exports.coffee']
                options:
                    transform: ['coffeeify']
                    browserifyOptions:
                        extensions: ['.coffee']
            receiver:
                files:
                    'out/flint_receiver_sdk.js': ['lib/receiver/exports.coffee']
                options:
                    transform: ['coffeeify']
                    browserifyOptions:
                        extensions: ['.coffee']
            discovery:
                files:
                    'out/flint_discovery.js': ['lib/discovery/exports.coffee']
                options:
                    transform: ['coffeeify']
                    browserifyOptions:
                        extensions: ['.coffee']

        uglify:
            sender_chrome:
                options: { mangle: true, compress: true }
                src: 'out/sender/chrome/flint_sender_sdk.js'
                dest: 'out/sender/chrome/flint_sender_sdk.min.js'
            sender_firefox:
                options: { mangle: true, compress: true }
                src: 'out/sender/firefox/flint_sender_sdk.js'
                dest: 'out/sender/firefox/flint_sender_sdk.min.js'
            sender_ffos:
                options: { mangle: true, compress: true }
                src: 'out/sender/ffos/flint_sender_sdk.js'
                dest: 'out/sender/ffos/flint_sender_sdk.min.js'
            receiver:
                options: { mangle: true, compress: true }
                src: 'out/flint_receiver_sdk.js'
                dest: 'out/flint_receiver_sdk.min.js'
            discovery:
                options: { mangle: true, compress: true }
                src: 'out/flint_discovery.js'
                dest: 'out/flint_discovery.min.js'

        concat:
            sender_chrome:
                options:
                    banner: '/*! <%= pkg.name %> build:<%= pkg.version %>, development. ' +
                        'Copyright(C) 2013-2014 www.OpenFlint.org */\n'
                src: 'out/sender/chrome/flint_sender_sdk.js'
                dest: 'out/sender/chrome/flint_sender_sdk.js'
            sender_prod_chrome:
                options:
                    banner: '/*! <%= pkg.name %> build:<%= pkg.version %>, production. ' +
                        'Copyright(C) 2013-2014 www.OpenFlint.org */\n'
                src: 'out/sender/chrome/flint_sender_sdk.min.js'
                dest: 'out/sender/chrome/flint_sender_sdk.min.js'

            sender_firefox:
                options:
                    banner: '/*! <%= pkg.name %> build:<%= pkg.version %>, development. ' +
                        'Copyright(C) 2013-2014 www.OpenFlint.org */\n'
                src: 'out/sender/firefox/flint_sender_sdk.js'
                dest: 'out/sender/firefox/flint_sender_sdk.js'
            sender_prod_firefox:
                options:
                    banner: '/*! <%= pkg.name %> build:<%= pkg.version %>, production. ' +
                        'Copyright(C) 2013-2014 www.OpenFlint.org */\n'
                src: 'out/sender/firefox/flint_sender_sdk.min.js'
                dest: 'out/sender/firefox/flint_sender_sdk.min.js'

            sender_ffos:
                options:
                    banner: '/*! <%= pkg.name %> build:<%= pkg.version %>, development. ' +
                        'Copyright(C) 2013-2014 www.OpenFlint.org */\n'
                src: 'out/sender/ffos/flint_sender_sdk.js'
                dest: 'out/sender/ffos/flint_sender_sdk.js'
            sender_prod_ffos:
                options:
                    banner: '/*! <%= pkg.name %> build:<%= pkg.version %>, production. ' +
                        'Copyright(C) 2013-2014 www.OpenFlint.org */\n'
                src: 'out/sender/ffos/flint_sender_sdk.min.js'
                dest: 'out/sender/ffos/flint_sender_sdk.min.js'

            receiver:
                options:
                    banner: '/*! <%= pkg.name %> build:<%= pkg.version %>, development. ' +
                        'Copyright(C) 2013-2014 www.OpenFlint.org */\n'
                src: 'out/flint_receiver_sdk.js'
                dest: 'out/flint_receiver_sdk.js'
            receiver_prod:
                options:
                    banner: '/*! <%= pkg.name %> build:<%= pkg.version %>, production. ' +
                        'Copyright(C) 2013-2014 www.OpenFlint.org */\n'
                src: 'out/flint_receiver_sdk.min.js'
                dest: 'out/flint_receiver_sdk.min.js'

            discovery:
                options:
                    banner: '/*! <%= pkg.name %> build:<%= pkg.version %>, development. ' +
                        'Copyright(C) 2013-2014 www.OpenFlint.org */\n'
                src: 'out/flint_discovery.js'
                dest: 'out/flint_discovery.js'
            discovery_prod:
                options:
                    banner: '/*! <%= pkg.name %> build:<%= pkg.version %>, production. ' +
                        'Copyright(C) 2013-2014 www.OpenFlint.org */\n'
                src: 'out/flint_discovery.min.js'
                dest: 'out/flint_discovery.min.js'

    # Load the plugin that provides the "coffee" task.

    # Load the plugin that provides the "uglify" task.
    # grunt.loadNpmTasks 'grunt-contrib-uglify'

    # Default task(s).
    # grunt.registerTask 'default', ['coffee', 'uglify']

    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-browserify'
    grunt.loadNpmTasks 'grunt-contrib-uglify'
    grunt.loadNpmTasks 'grunt-contrib-concat'

    grunt.registerTask 'default', ['browserify', 'uglify', 'concat']
