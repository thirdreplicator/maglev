# ---------------------------------
#  Bignum and Integer
#
# The Smalltalk hierarchy is
#      Integer
#        LargeNegativeInteger
#        LargePositiveInteger
#        SmallInteger
#
# Bignum and Integer will be identical
# The environment 1 name of LargeNegativeInteger and LargePositiveInteger 
# will both be Bignum.
# Environment 1 of Smalltalk Integer will hold the combined API of 
# Ruby Integer and Bignum .
#
#  At this time, there are no methods in LargeNegativeInteger nor LargePositiveInteger
#   that need to be referenced from environment 1

# Note,   1152921504606846976.class  will be LargePositiveInteger, not Integer .

class Integer
    def times
        for i in (0..self-1)
            yield i
        end
    end
    
    def upto(n, &b)
        i = self
        while(i <= n)
            b.call(i)
            i += 1
        end
    end
    
    def downto(n, &b)
        i = self
        while(i >= n)
            b.call(i)
            i -= 1
        end
    end

    def chr
        if self > 255
            raise RangeError, "#{self} out of char range"
        end
        string = ' '
        string[0] = self
        string
    end
    
    def next
      self + 1
    end
    
	primitive '+', '+'
	primitive '-', '-'
	primitive '*', '*'
	primitive '/', '_rubyDivide:'

#   Ruby  %   maps to  Smalltalk #'\\'
	primitive '%', '\\\\'

	primitive '**' , 'raisedTo:'

	primitive '|', 'bitOr:'
	primitive '&', 'bitAnd:'
	primitive '^', 'bitXor:'
	primitive '<<', 'bitShift:'
	primitive '>>', '_bitShiftRight:'

#  <=> inherited from Numeric

	primitive '[]', 'bitAt:'

#  abs inherited from Numeric

	primitive '==', '='

	primitive 'eql?', '_ruby_eqlQ:'

	primitive 'div', '_rubyDivide:'

# divmod inherited from Numeric

        primitive 'hash'

#    modulo   maps to Smalltalk  #'\\' 
	primitive 'modulo', '\\\\'

	primitive 'quo', '_rubyQuo:'

#  remainder  inherited from numeric

	primitive 'size', 'size'
	primitive 'to_f', 'asFloat'
	primitive 'to_i', 'truncated'
	primitive 'to_int' , 'truncated'
	primitive 'to_s', 'asString'
	primitive 'truncate' , 'truncated'

#  methods from Numeric
	primitive 'coerce', '_rubyCoerce:'
	primitive 'floor', 'floor'
	primitive 'nonzero?', '_rubyNonzero'
	primitive 'round', 'rounded'
	primitive 'zero?', '_rubyEqualZero'
	
	primitive 'step&', 'to:by:do:'
end