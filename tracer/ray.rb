class Ray < BasicMath
	attr_accessor :intersection, :intensity, :path, :ray, :times_reflected

	def initialize(args_)
		@intensity = args_[:intensity] || 1
		@times_reflected=0
		@ray  = BasicLine.new(*args_[:pi],args_[:theta])
		@path = []
	end

	def pi; @ray.pi; end
	def pf; @ray.pf; end

	def noise_intensity
		@@noise_intensity
	end
	def noise_intensity=(val_)
		@@noise_intensity=val_
	end

	def reflect
		_wall=@path.last[1]
		_wall_rougness=@path.last[1].rougness
		if _wall.absorbtivity
			@times_reflected+=1
			@intensity       = @intensity * (1 - _wall.absorbtivity)
		end

		#reflection_noice
		_rand1=(1 - _wall_rougness + (Random.rand(1.0) * _wall_rougness) )
		_rand2=(1 - _wall_rougness + (Random.rand(1.0) * _wall_rougness) )

		#get reflection
		_vw  = Vector[_wall.cos_t,  _wall.sin_t]
		_vwn = Vector[_wall.sin_t, -_wall.cos_t]
		_v0  = Vector[@ray.cos_t ,   @ray.sin_t]

		_vnew= (project_vectors(_vw ,_v0)*_rand1 - project_vectors(_vwn,_v0)*_rand2).normalize
		@ray=BasicLine.new(*@path.last[2][:pf], nil ,*_vnew)
	end

	def propagate
		_intersected_elements=[]

		$geometry.each do |ele_|
			if @path.empty? || @path.last[1]!=ele_
				_intersection=@ray.intersects?(ele_)
				_intersected_elements.push([@ray, ele_, _intersection]) if _intersection
			end
		end

		return if _intersected_elements.empty?
		_intersected_element=_intersected_elements.sort do |x_, y_|
				x_[2][:l] <=> y_[2][:l]
		end.first

		@ray.pf = _intersected_element[2][:pf]
		@path.push(_intersected_element)
		_intersected_element[1].hit=([@ray.pf[1], self.intensity])
	end

		def finish
		_l=1
		@ray.pf = [_l*@ray.cos_t+ @ray.pi[0] , _l*@ray.sin_t+ @ray.pi[1]]
		@path.push([@ray])
	end

end