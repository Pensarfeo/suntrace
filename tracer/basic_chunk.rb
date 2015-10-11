class GeometryChunk< BasicMath

	def initialize(*elements_, ray_)
		@ray=ray_
		@window=elements_.last[0]
		@window_verse=elements_.last[1]
		@lines[0]=elements_.first
	end

	def leaves?(ray_)
		
		v1_.inner_product(Vector[ray_.pi[0],  ray_.pi[1]]) 
		@ray.intersects?(@window)
	end

	def enters?(ray_)
		ray_

	end

	def stays?(ray_)

	end

end