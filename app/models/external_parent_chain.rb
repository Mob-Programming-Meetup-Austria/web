
module ExternalParentChain # mix-in

  def dir
    disk[path]
  end

  def read(filename)
    dir.read(filename)
  end

  def read_json(filename)
    dir.read_json(filename)
  end

  def write(filename, string)
    dir.write(filename, string)
  end

  def write_json(filename, object)
    dir.write_json(filename, object)
  end

  module_function

  def method_missing(command, *args)
    @parent.send(command, *args)
  end

end

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
# All the model classes include this module.
# method_missing assumes the including class has three things
#   @parent
#   disk 
#   path (a string)
# Its effect is to pass calls (to externals) up
# the child->parent chain all the way to the root
# Dojo object where the externals are held.
# See also app/models/Dojo.rb
#- - - - - - - - - - - - - - - - - - - - - - - - - - -
