class Interpolable

	class ImproperDataFormat < StandardError; end
	class PointOutOfRange < StandardError; end


	def initialize(data_,info_={})
		@info=info_
		if !(data_[0].kind_of?(Array) && data_.length>1 && data_[0].length > 1 )
			raise ImproperDataFormat, "data not array or improper structure"
		end
		@data=data_
	end

	def index
		@data=@data.map.with_index.to_a
		@index=true
		return self
	end

	def interpolate(val_)
		#serch top element
		_ele=@data.bsearch {|x_| x_[0][0] > val_ }
		#point is contained in the array
		if _ele.nil? || _ele[1]==0 
			raise PointOutOfRange,
	"
	point out of range for #{@info},
	min point = #{@data.first},
	max point =#{@data.last},
	value given=#{val_}"
		end
		_index=_ele[1]
		_ele=_ele[0]


		#point is contained in the array
		_inter=[ @data[_index-1][0], _ele ].transpose
		_δx  = _inter[0][1]-_inter[0][0]
		_δxn = val_-_inter[0][0]

		_inter[1..-1].map do |y0_, y1_|
			y0_+_δxn*((y1_-y0_)/_δx) #new value
		end.unshift(val_)
	end

end