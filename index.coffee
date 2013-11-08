### A Wintersmith plugin. ###

fs = require 'fs'
path = require 'path'
child_process = require 'child_process'

module.exports = (env, callback) ->
  # *env* is the current wintersmith environment
  # *callback* should be called when the plugin has finished loading

  class UnretinaPlugin extends env.ContentPlugin
    ### Prepends 'Wintersmith is awesome' to text files. ###

    constructor: (@filepath) ->
      
      #@text = 'Wintersmith is awesome!\n' + text

    getFilename: ->
      # filename where plugin is rendered to, this plugin uses the
      @filepath.relative

    getView: -> (env, locals, contents, templates, callback) ->
      build_path = env.resolvePath env.config.output
      destination = path.join build_path, @filepath.relative.replace '_2x.', '_1x.'
      if !fs.existsSync @new_file
        cmd = 'convert ' + @filepath.full + ' -resize 50% ' + destination
        #console.log ' cmd ' + cmd
        child_process.exec cmd
      
      # note that this function returns a function, you can also return a string
      # to use a view already added to the env, see env.registerView for more
      try
        rs = fs.createReadStream @filepath.full
      catch err
        return callback err
      callback null, rs

  UnretinaPlugin.fromFile = (filepath, callback) ->
    callback null, new UnretinaPlugin filepath

  # register the plugin to intercept .txt and .text files using a glob pattern
  # the first argument is the content group the plugin will belong to
  # i.e. directory grouping, contents.somedir._.text is an array of all
  #      plugin instances beloning to the text group in somedir
  env.registerContentPlugin 'files', '**/*_2x*', UnretinaPlugin
  # tell plugin manager we are done
  callback()
