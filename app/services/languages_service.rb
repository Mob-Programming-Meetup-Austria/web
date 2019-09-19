require_relative 'http_json/service'
require_relative 'languages_exception'

class LanguagesService

  def initialize(externals)
    @http = HttpJson::service(externals.http, 'languages', 4524, LanguagesException)
  end

  def ready?
    @http.get(__method__, {})
  end

  def sha
    @http.get(__method__, {})
  end

  def names
    @http.get(__method__, {})
  end

  def manifests
    @http.get(__method__, {})
  end

  def manifest(name)
    @http.get(__method__, { name:name })
  end

end
