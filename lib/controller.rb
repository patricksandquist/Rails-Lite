require_relative './flash'
require_relative './params'
require_relative './session'
require 'active_support'
require 'active_support/core_ext'
require 'active_support/inflector'
require 'erb'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res, route_params = {})
    @req, @res = req, res
    @params = Params.new(req, route_params)
  end

  def invoke_action(name)
    self.send(name)
  end

  def flash
    @flash ||= Flash.new(req)
  end

  def session
    @session ||= Session.new(req)
  end

  def already_built_response?
    @already_built_response
  end

  def redirect_to(url)
    raise "Already built response" if already_built_response?

    @res['location'] = url
    @res.status = 302
    @already_built_response = true
    session.store_session(res)
    flash.store_flash(res)
  end

  def render_content(content, content_type)
    raise "Already built response" if already_built_response?

    @res.content_type = content_type
    @res.body = content
    @already_built_response = true
    session.store_session(res)
    flash.store_flash(res)
  end

  def render(template_name)
    controller_name = self.class.to_s.underscore
    file = File.read("views/#{controller_name}/#{template_name}.html.erb")
    template = ERB.new(file).result(binding)
    render_content(template, 'text/html')
  end
end
