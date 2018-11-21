require_relative 'http_helper'

class RunnerService

  def initialize(externals)
    @http = HttpHelper.new(externals, self, 'runner-stateless', 4597)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def sha
    @http.get(__method__)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def run_cyber_dojo_sh(
    image_name, id,
    created_files, deleted_files, changed_files, unchanged_files,
    max_seconds)

    @http.post_hash(__method__, {
             image_name:image_name,
                     id:id,
          created_files:created_files,
          deleted_files:deleted_files,
          changed_files:changed_files,
        unchanged_files:unchanged_files,
            max_seconds:max_seconds
      })
  end

  private

end
