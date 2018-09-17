require_relative 'http_helper'

class SinglerService

  def initialize(externals)
    @externals = externals
    @hostname = 'singler'
    @port = 4517
  end

  # - - - - - - - - - - - -

  def sha
    http_get(__method__)
  end

  # - - - - - - - - - - - -

  def create(manifest)
    http_post(__method__, manifest)
  end

  def manifest(id)
    http_get(__method__, id)
  end

  # - - - - - - - - - - - -

  def id?(id)
    http_get(__method__, id)
  end

  def id_completed(partial_id)
    http_get(__method__, partial_id)
  end

  def id_completions(outer_id)
    http_get(__method__, outer_id)
  end

  # - - - - - - - - - - - -

  def ran_tests(id, files, now, stdout, stderr, colour)
    http_post(__method__, id, files, now, stdout, stderr, colour)
  end

  def increments(id)
    http_get(__method__, id)
  end

  # - - - - - - - - - - - -

  def visible_files(id)
    http_get(__method__, id)
  end

  def tag_visible_files(id, tag)
    http_get(__method__, id, tag)
  end

  def tags_visible_files(id, was_tag, now_tag)
    http_get(__method__, id, was_tag, now_tag)
  end

  private

  include HttpHelper

  attr_reader :hostname, :port

end
