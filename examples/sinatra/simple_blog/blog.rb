

module Maglev::Model

  # These methods will be defined as class methods of the class that
  # includes this module.
  module ClassMethods

    # Create a new instance, and add it to the hash of persisted instances
    # for this class.
    def new(*params)
      obj = allocate
      obj.initialize(*params)
      add(obj)  # code smell
    end

    # Returns an array of all the posts
    def all
      Maglev::PERSISTENT_ROOT[self].values
    end

    # Get an object by object id.  If +id+ is not the id for an instance of
    # the calling class, then no object will be found (even if +id+ is the
    # valid id of soome instance of another class).
    def get(id)
      Maglev::PERSISTENT_ROOT[self][id.to_i]
    end

    # Add +obj+ to the set of persisted objects for this class.
    # called by new()
    def add(obj)
      Maglev::PERSISTENT_ROOT[self][obj.__id__] = obj
    end

    # Iterate over all saved items
    def each
      all.each do |el|
        yield el
      end
    end
    
  end

  
  def self.included(host)
    # TODO: Almost certainly not a good thing beyond the dev env: This will
    # blow away any persistent data from previous runs.  Perhaps we need a
    # migration idiom so that this can be controlled.
    self.migrate_or_initialize( host, Maglev::PERSISTENT_ROOT[host] )
    host.extend ClassMethods
    host.extend Enumerable
  end

private
  # Migrate previously saved objects to new definition.
  # Relies on an user-defined interface of the host class for migrating old data to new class.
  #   The interface is a class method called 'reincarnate', which takes in an old instances
  #   and reinstantiates it as a new instances of the new class definition.  If there are no
  #   changes in the class definition, then this can just be a call to 'new' passing in a
  #   hashified old instance.

  def self.migrate( new_class, saved_instances )
    new_instances = Hash.new
    saved_instances.values.each do |old_object|
      new_object = new_class.reincarnate( old_object )
      new_instances[new_object.__id__] = new_object
    end
    new_instances
  end

  def self.migrate_or_initialize( host, saved_instances )
    if saved_instances
      Maglev::PERSISTENT_ROOT[host] = self.migrate(host, saved_instances)
    else
      Maglev::PERSISTENT_ROOT[host] = Hash.new      
    end
  end

end

# This file defines the blog classes.  To commit the code, load this
# file from within a Maglev.persistent block and then commit it.

# Maglev::Model implements a very simple and un-production-worthy
# persistence model.  A class that includes the Maglev::Model module, will
# automatically persist all new instances in a hash table for the class.
# If the module is re-included (or the file that defines the class is
# re-run), then all previous saved instances will be migrated into the new 
# class.  New instances will be defined according to the way that the new
# class implements the 'reincarnate' interface.

class SimplePost

  attr_reader :text, :title, :timestamp, :tags
  def initialize(params)
    @title = params[:title]
    @text =  params[:text]
    @timestamp = Time.now
    @tags = []
  end

  def self.reincarnate( old_object )
    new({ :text => old_object.text, 
          :title => old_object.title, 
          :timestampe => old_object.timestamp,
          :tags => old_object.tags
      })
  end
  
  # Tag the post: (a) adds reciever to the tag and (b) adds
  # each tag to recevier's @tags
  def tag(*tags)
    p tags
    tags.each do |tag|
      tag << self
      @tags << tag
    end
  end
end

# The include bit is moved below the class so that the class gets a chance to be
#  redefined before an old version gets reused in the migration.  

class SimplePost
  include Maglev::Model
end

class SimpleTag < Array

  attr_reader :name

  def initialize(name)
    @name = name.to_s
  end
  
  def self.reincarnate( old_object )
    self.new( old_object.name )
  end
  
  def to_s
    @name
  end

  def self.find_by_name(name)
    SimpleTag.detect { |t| t.name == name }
  end
end

# The include bit is moved below the class so that the class gets a chance to be
#  redefined before an old version gets reused in the migration.  

class SimpleTag
  include Maglev::Model
end