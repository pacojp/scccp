
require 'bundler'
Bundler.setup
Bundler.require(:test)

$: << File.dirname(__FILE__) + '/../lib'

require 'scccp'
require 'scccp/version'

