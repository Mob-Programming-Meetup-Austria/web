
module Externals # mix-in

  def starter
    @starter ||= external
  end

  def saver
    @saver ||= external
  end

  def runner
    @runner ||= external
  end

  def differ
    @differ ||= external
  end

  #def zipper
  #  @zipper ||= external
  #end

  #def porter
  #  @porter ||= external
  #end

  def http
    @http ||= external
  end

  private # = = = = = = = = =

  def external
    # See comment below
    key = 'CYBER_DOJO_' + name_of(caller).upcase + '_CLASS'
    var = ENV[key] || fail("ENV[#{key}] not set")
    Object.const_get(var).new(self)
  end

  def name_of(caller)
    # eg caller[0] == "externals.rb:21:in `zipper'"
    /`(?<name>[^']*)/ =~ caller[0] && name
  end

end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# External class-names are set using environment variables.
# This gives tests a way to do Parameterize-From-Above that
# can tunnel through a *deep* stack. In particular, I can set an
# environment variable and then run a controller test which issues
# GETs/POSTs, which work their way through the rails stack,
# -In-A-Different-Thread-, reaching externals.rb, where the
# specificied Substitute class takes effect.
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
