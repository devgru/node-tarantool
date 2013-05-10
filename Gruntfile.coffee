'use strict'

module.exports = (grunt) ->
    # Project configuration.
    grunt.initConfig
        nodeunit: files: ['test/*']

    grunt.loadNpmTasks 'grunt-contrib-nodeunit'

    # Default task.
    grunt.registerTask 'default', ['nodeunit']