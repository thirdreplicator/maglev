 module FFI
   class MemoryPointer  
    # a subclass of CByteArray , first opening in ffi.rb

    def self.new(type, count, &blk)
      # this variant  gets bridge methods
      if type._isFixnum
        elemsize = type
      else 
        modu =  FFI
        elemsize = modu.type_size(modu.find_type(type))
      end
      count = Type.coerce_to(count, Fixnum, :to_int)
      if (count < 1)
        raise ArgumentError , 'count must be a Fixnum >= 1'
      end
      numbytes = count * elemsize
      inst = self.gc_malloc(numbytes)
      inst.initialize(elemsize)
      inst
      if block_given?
        yield(inst)
      else
        inst
      end
    end
      
    def self.new(type, &blk)
      if type._isFixnum
        numbytes = type
        inst = self.gc_malloc(numbytes)
        inst.initialize(1)
      else
        modu =  FFI
        elemsize = modu.type_size(modu.find_type(type))
        inst = self.gc_malloc(elemsize)
        inst.initialize(elemsize)
      end
      if block_given?
        yield(inst)
      else
        inst
      end
    end

    def self.new(type)
      if type._isFixnum
        numbytes = type
        inst = self.gc_malloc(numbytes)
        inst.initialize(1)
      else
        modu =  FFI
        elemsize = modu.type_size(modu.find_type(type))
        inst = self.gc_malloc(elemsize)
        inst.initialize(elemsize)
      end
      inst
    end

    def self.new
      # encapsulate a single C pointer or int64
      inst = self.gc_malloc(8)
      inst.initialize(8)
      inst
    end

    # def initialize ; end #   in ffi.rb

    class_primitive_nobridge '__with_all', 'withAll:'

    def self.from_string(string)
      string = Type.coerce_to(string, String, :to_str)
      inst = self.__with_all(string)
      inst.initialize(1)
      inst
    end

    def [](element_offset)
      elem_size = @type_size
      byte_offset = element_offset * elem_size
      self + byte_offset
    end

    primitive_nobridge '__new_from', 'newFrom:numBytes:'

    def +(byteoffset)
      # return an instance derived from self
      #  instance has autofree==false, and a derivedFrom reference to self
      inst = self.__new_from(byteoffset, -2) 
      inst.initialize(@type_size)
      inst
    end

    # def address ; end  #  inherited from CByteArray

    primitive_nobridge 'autorelease', 'autoRelease'

    primitive_nobridge 'autorelease=', 'autoRelease:'
      # argument must be a boolean, false means disable auto-free
      #  all other values ignored.
   
    primitive_nobridge 'free' , 'setDead'
      # does not actually free C memory. subsequent attempts
      # to access C memory will raise an exception.

    def derived_from
      # the instance which owns the C memory pointed to by self,
      #  if nil, then the C memory is owned by self.
      # may be an Integer if created by read_pointer.
      @derivedFrom
    end

    def read_int
      self.int32at(0)
    end
    def write_int(val)
      self.int32_put(0, val)
    end
    def read_long
      self.int64at(0)
    end
    def write_long(val)
      self.int64_put(0, val)
    end
    def write_double(val)
      self.double_put(0, val)
    end 
    def read_double(val)
      self.double_at(0)
    end 
    def read_pointer
      self.int64at(0) 
    end   
    def write_pointer(val)
      self.int64_put(0, val);
    end
    def read_string(num_bytes)
      self.stringfrom_to(0, num_bytes - 1)
    end
    def write_string(string, num_bytes)
      self.copyfrom_from_to_into(string, 1, num_bytes, 0)
    end

    def put_string(offset, string)
      len = string.length
      self.copyfrom_from_to_into(string, 1, len, offset)
                                # obj, one-based, one-base, zero-based
      self.int8_put(offset + len, 0)  # add a null byte
    end

    def null? 
      self.address.equal?(0)
    end

    def read_array_of_int(a_length)
      res = Array.new(a_length)
      n = 0
      while n < a_length 
        res[n] = self.int32at(n)
        n += 1
      end
      res
    end

    def read_array_of_long(a_length)
      res = Array.new(a_length)
      n = 0
      while n < a_length 
        res[n] = self.int64at(n)
        n += 1
      end
      res
    end

    def write_array_of_int(ary)
      len = ary.length
      n = 0
      while n < a_length
        self.int32_put(n, ary[n])
        n += 1
      end
      res
    end
    
    def write_array_of_int(ary)
      len = ary.length
      n = 0
      while n < a_length
        self.int64_put(n, ary[n])
        n += 1
      end
      res
    end

    def ==(a_memory_pointer)
      unless a_memory_pointer.kind_of?(self) 
        return false
      end
      a_memory_pointer.read_pointer() == self.read_pointer()
    end

    def write_array_of_pointer(ary)
      ofs = 0
      ary.each do | elem |
        p = elem.to_ptr
      end
    end
   
    # def read_array_of_type(type, reader, length) ; end # TODO
    # def write_array_of_type(type, writer, ary); ; end # TODO
    # def get_at_offset(offset, type) ; end # TODO
    # def set_at_offset(offset, type, val) ; end # TODO
  end
end
