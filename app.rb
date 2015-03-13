#This file is part of MINI-LIMS; it is distributed under the terms of GNU General Public License version 1 or later;
#Please refer to the LICENSE and README files for information on licensing and authorship of this file.
#Copyright (c) 2015 Genome Research Ltd.

require 'sinatra/base'
require 'sinatra/activerecord'
require 'sass'
require 'bootstrap-sass'
require 'sinatra/assetpack'
require 'pry-nav'

class MiniLims < Sinatra::Base
 set :root, File.dirname(__FILE__)
  # Need to find somewhere better for this, but lets just stop the messages for now.
  I18n.enforce_available_locales = true

  set :views, settings.root + '/app/views'
  set :method_override, true
  set :server, :puma

  configure :development do
    set :show_exceptions => :after_handler
  end

  register Sinatra::AssetPack

  assets do

    serve '/assets/javascripts', :from => 'app/assets/javascripts'
    serve '/assets/stylesheets', :from => 'app/assets/stylesheets'

    css :application, '/assets/stylesheets/app.css', [
      '/assets/stylesheets/*.css',
    ]

    js :application, '/assets/javascripts/app.js', [
      '/assets/javascripts/jquery.min.js',
      '/assets/javascripts/bootstrap.min.js',
      '/assets/javascripts/application.js'
    ]


    js_compression :jsmin
    css_compression :sass
  end

  enable :sessions

  get '/' do
    erb :'show', :locals=>{ :version_information => "0.1" }
  end


  #error Controller::ParameterError do
  #  session[:flash] = ['danger', env['sinatra.error'].message ]
  #  redirect back
  #end

  # Error handling
  error do
    send_file 'public/500.html', :status => 500
  end

  not_found do
    send_file 'public/404.html', :status => 404
  end

  after do
    ActiveRecord::Base.connection_pool.release_connection
  end

  def render_messages
    if session[:flash].present?
      yield(*session[:flash])
      session[:flash] = nil # unset the value
    end
  end

end
