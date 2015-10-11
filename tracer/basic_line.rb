class BasicLine < BasicMath

	attr_accessor :l0, :q0, :pi, :pf, :theta, :sin_t, :cos_t, :hit

	def initialize(x0_, y0_, theta_, *cos_sin_)
		@pi   =[x0_, y0_]
		@theta=theta_
		if theta_
			@theta=theta_
			@cos_t, @sin_t = cos(theta_), sin(theta_)
		else
			@cos_t, @sin_t = *cos_sin_
			@theta=nil
		end

	end

	def orientation=(orientation_)
		@orientation=orientation_
	end

	def orientation
		@orientation||=1
	end

	def hit=(hit_)
		self.hit.push(hit_)
	end

	def hit
		@hit||=[]
	end

	def reset
		@hit=[]
	end

	class LineCoordinateError< StandardError; end

	def line(val_)
		_x0, _y0 = *self.pi

		if val_[:x].nil? #get x
			raise LineCoordinateError if @cos_t ==0.0
			(val_[:y]-_y0)*(@cos_t/@sin_t) + _x0
		else             #get y
			raise LineCoordinateError if @sin_t==0.0
			(val_[:x]-_x0)*(@sin_t/@cos_t)  + _y0
		end

	end

	def ending_point(val_)
		_end =if val_[:xf].nil?
						{ pf: [ line(y: val_[:yf]), val_[:yf]       ] }
					else
						{ pf: [ val_[:xf]         , line(x: val_[:xf]) ] }
					end
	end

	def intersects?(wall_)
		#if _x_in is NaN or infinity then the two lines are parelel 
		@intersection={}
		_sin_tr_tw= @sin_t*wall_.cos_t - @cos_t*wall_.sin_t

		return if _sin_tr_tw==0

		_dx = @pi[0]-wall_.pi[0]
		_dy = @pi[1]-wall_.pi[1]
		_l  = (_dx* wall_.sin_t-_dy*wall_.cos_t)/_sin_tr_tw
		return if _l < 0
		_intersection= {l:_l}
		_intersection[:pf] = [_l*@cos_t+ @pi[0] , _l*@sin_t+ @pi[1]]

		_intersection if hits?(wall_.bounding, _intersection[:pf])
	end



	private

	def hits?(wall_bounds_, intersection_)
		_dbx = (wall_bounds_[:x][0]-wall_bounds_[:x][1]).abs
		_dby = (wall_bounds_[:y][0]-wall_bounds_[:y][1]).abs

		_iaxis  = (_dby>=_dbx ? [:y, 1] : [:x, 0] ) 

		left_bound(intersection_[_iaxis[1]] , wall_bounds_[_iaxis[0]])
	end

	def left_bound(val_, limits_)
		limits_[0]<=val_ && val_<limits_[1]
	end

end

class TestBasicline < BasicLine

	def self.check
		# xaxis parallel
		_theta=0
		bl=BasicLine.new(0,1,_theta)
		_ep=bl.ending_point(xf: 2)[:pf]
		puts "OK" if _ep[0]==2 && _ep[1]===1

		#fails if the coordinate is not consisten with the line
		begin 
			bl.ending_point(yf: 2)
			puts "ERROR #{caller[0]}"
		rescue BasicLine::LineCoordinateError
			puts "OK"
		end	
		# yaxis parallel
		_theta=PI/2
		bl=BasicLine.new(2,1,_theta)
		puts "OK" if bl.ending_point(yf: 2)[:pf]==[2,2]	

		#fails if the coordinate is not consisten with the line
		#we don't try this one because is nearly impossible acchieve
		#begin
		#	bl.ending_point(xf: 2)
		#	puts "ERROR #{caller[0]}"
		#rescue BasicLine::LineCoordinateError
		#	puts "OK"
		#end


		# normal line parallel
		_theta=PI/4
		bl=BasicLine.new(0,0,_theta)
		_ep=bl.ending_point(yf: 2)[:pf]
		puts "OK" if _ep[0]-_ep[1]<0.000000001 && _ep[1]==2
		_ep=bl.ending_point(xf: 2)[:pf]
		puts "OK" if _ep[0]-_ep[1]<0.000000001 && _ep[0]==2

	end


end

#TestBasicline.check


















