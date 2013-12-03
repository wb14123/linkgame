// Generated by CoffeeScript 1.6.3
(function() {
  var bold, build, clean, docco, err, exec, files, fs, green, launch, log, mocha, moduleExists, print, red, reset, spawn, unlinkIfCoffeeFile, walk, which, _ref;

  files = ['obj', 'src'];

  fs = require('fs');

  print = require('util').print;

  _ref = require('child_process'), spawn = _ref.spawn, exec = _ref.exec;

  try {
    which = require('which').sync;
  } catch (_error) {
    err = _error;
    if (process.platform.match(/^win/) != null) {
      console.log('WARNING: the which module is required for windows\ntry: npm install which');
    }
    which = null;
  }

  bold = '\x1b[0;1m';

  green = '\x1b[0;32m';

  reset = '\x1b[0m';

  red = '\x1b[0;31m';

  task('docs', 'generate documentation', function() {
    return docco();
  });

  task('build', 'compile source', function() {
    return build(function() {
      return log(":)", green);
    });
  });

  task('watch', 'compile and watch', function() {
    return build(true, function() {
      return log(":-)", green);
    });
  });

  task('test', 'run tests', function() {
    return build(function() {
      return mocha(function() {
        return log(":)", green);
      });
    });
  });

  task('clean', 'clean generated files', function() {
    return clean(function() {
      return log(";)", green);
    });
  });

  walk = function(dir, done) {
    var results;
    results = [];
    return fs.readdir(dir, function(err, list) {
      var file, name, pending, stat, _i, _len, _results;
      if (err) {
        return done(err, []);
      }
      pending = list.length;
      if (!pending) {
        return done(null, results);
      }
      _results = [];
      for (_i = 0, _len = list.length; _i < _len; _i++) {
        name = list[_i];
        file = "" + dir + "/" + name;
        try {
          stat = fs.statSync(file);
        } catch (_error) {
          err = _error;
          stat = null;
        }
        if (stat != null ? stat.isDirectory() : void 0) {
          _results.push(walk(file, function(err, res) {
            var _j, _len1;
            for (_j = 0, _len1 = res.length; _j < _len1; _j++) {
              name = res[_j];
              results.push(name);
            }
            if (!--pending) {
              return done(null, results);
            }
          }));
        } else {
          results.push(file);
          if (!--pending) {
            _results.push(done(null, results));
          } else {
            _results.push(void 0);
          }
        }
      }
      return _results;
    });
  };

  log = function(message, color, explanation) {
    return console.log(color + message + reset + ' ' + (explanation || ''));
  };

  launch = function(cmd, options, callback) {
    var app;
    if (options == null) {
      options = [];
    }
    if (which) {
      cmd = which(cmd);
    }
    app = spawn(cmd, options);
    app.stdout.pipe(process.stdout);
    app.stderr.pipe(process.stderr);
    return app.on('exit', function(status) {
      if (status === 0) {
        return typeof callback === "function" ? callback() : void 0;
      }
    });
  };

  build = function(watch, callback) {
    var options;
    if (typeof watch === 'function') {
      callback = watch;
      watch = false;
    }
    options = ['-c', '-b', '-o'];
    options = options.concat(files);
    if (watch) {
      options.unshift('-w');
    }
    return launch('coffee', options, callback);
  };

  unlinkIfCoffeeFile = function(file) {
    if (file.match(/\.coffee$/)) {
      fs.unlink(file.replace('src', 'lib').replace(/\.coffee$/, '.js'), function() {});
      return true;
    } else {
      return false;
    }
  };

  clean = function(callback) {
    var file, _i, _len;
    try {
      for (_i = 0, _len = files.length; _i < _len; _i++) {
        file = files[_i];
        if (!unlinkIfCoffeeFile(file)) {
          walk(file, function(err, results) {
            var f, _j, _len1, _results;
            _results = [];
            for (_j = 0, _len1 = results.length; _j < _len1; _j++) {
              f = results[_j];
              _results.push(unlinkIfCoffeeFile(f));
            }
            return _results;
          });
        }
      }
      return typeof callback === "function" ? callback() : void 0;
    } catch (_error) {
      err = _error;
    }
  };

  moduleExists = function(name) {
    try {
      return require(name);
    } catch (_error) {
      err = _error;
      log("" + name + " required: npm install " + name, red);
      return false;
    }
  };

  mocha = function(options, callback) {
    if (typeof options === 'function') {
      callback = options;
      options = [];
    }
    options.push('--compilers');
    options.push('coffee:coffee-script');
    return launch('mocha', options, callback);
  };

  docco = function(callback) {
    return walk('src', function(err, files) {
      return launch('docco', files, callback);
    });
  };

}).call(this);

/*
//@ sourceMappingURL=.map
*/