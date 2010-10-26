require 'rubygems'
require 'active_record'

ActiveRecord::Base.establish_connection(
    :adapter => 'mysql',
    :host => "localhost",
    :database => "orcus_dev",
    :username => "root",
    :password => ""
)


