
module.exports = (grunt) ->
  require('load-grunt-tasks') grunt

  grunt.initConfig
    watch:
      options:
        livereload: false
      src:
        files: ['src/**/*.coffee']
        tasks: ['src']
      test:
        files: ['src/**/*.coffee', 'test/**/*.coffee']
        tasks: ['test']

    coffee:
      src:
        expand: true
        cwd: 'src'
        src: ['**/*.coffee']
        dest: 'lib'
        ext: '.js'
      test:
        expand: true
        cwd: 'test'
        src: ['**/*.coffee']
        dest: 'test_lib'
        ext: '.js'

    clean:
      src: ['lib']
      test: ['test_lib', '.tmp']

    coffeelint:
      options:
        max_line_length:
          value: 130
      src:
        'src/**/*.coffee'
      test:
        'test/**/*.coffee'

    copy:
      test:
        files: [
          expand: true
          cwd: 'test/expected'
          src: ['**/*']
          dest: 'test_lib/expected'
        ]

    mochaTest:
      test:
        options:
          reporter: 'spec'
          timeout: 4000
          grep: process.env.GREP
        src: ['test_lib/*_test.js']

    env:
      coverage:
        APP_SRV_COVERAGE: "../coverage/instrument/"

    instrument:
      files: ["lib/**/*.js"]
      options:
        lazy: true
        basePath: "coverage/instrument"

    storeCoverage:
      options:
        dir: "coverage/reports"

    makeReport:
      src: "coverage/reports/**/*.json"
      options:
        type: "lcov"
        dir: "coverage/reports"
        print: "detail"

    open:
      htmlReport:
        path: "coverage/reports/lcov-report/index.html"

    coverage:
      options:
        thresholds:
          statements: 90
          branches: 70
          lines: 90
          functions: 90

        dir: "coverage"

    release:
      options:
        npm: false

  grunt.registerTask('src', ['coffeelint:src', 'clean:src', 'coffee:src'])
  grunt.registerTask('compile:test', ['coffeelint:test', 'clean:test', 'coffee:test', 'copy:test'])
  grunt.registerTask('test', ['src', 'compile:test', 'mochaTest'])
  grunt.registerTask('do:coverage', [
    'src'
    'env:coverage'
    'compile:test'
    'instrument'
    'mochaTest'
    'storeCoverage'
    'makeReport'
    'coverage'
  ])
