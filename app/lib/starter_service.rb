require_relative 'http_helper'

class StarterService

  def initialize(parent)
    @parent = parent
  end

  attr_reader :parent

  # - - - - - - - - - - - -

  def custom_choices
    http_get(__method__)
  end

  def languages_choices
    http_get(__method__)
  end

  def exercises_choices
    http_get(__method__)
  end

  # - - - - - - - - - - - -

  def custom_manifest(major_name, minor_name)
    http_get(__method__, major_name, minor_name)
  end

  def language_manifest(major_name, minor_name, exercise_name)
    http_get(__method__, major_name, minor_name, exercise_name)
  end

  private

  include HttpHelper

  def hostname
    'starter'
  end

  def port
    4527
  end

end
