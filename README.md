# Blackbox [![Build Status](https://travis-ci.org/busyloop/blackbox.png?branch=master)](https://travis-ci.org/busyloop/blackbox)

Various little helpers.

## Features

* Battle scars (distilled from production code)

* [Fully tested](http://busyloop.github.com/blackbox/coverage/)

* [Documentation](http://busyloop.github.com/blackbox/doc/frames.html)

* Pure library, no monkey-patching


## Installation

`gem install blackbox`

## Usage

```ruby
require 'blackbox/crypto'
require 'blackbox/string'

BB::Crypto.encrypt( ... )
BB::String.strip_ansi( ... )

# ...
```

## License (MPL 2.0)

All code is made available under the terms of the [Mozilla Public License 2.0](http://www.mozilla.org/MPL/2.0/).
