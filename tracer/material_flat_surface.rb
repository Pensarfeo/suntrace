class MaterialFlatSurface < BasicLine

	attr_accessor :xf, :bounding, :absorbtivity, :rougness

	def initialize(opts_)
		super(*opts_[:pi], opts_[:theta])
		_ending_coordinate = opts_.select{|k_,v_| k_==:xf || k_==:yf}
		self.pf                = self.ending_point( _ending_coordinate )[:pf]
		_bound = [self.pi, self.pf].transpose
		@bounding={x: _bound[0].sort, y: _bound[1].sort}
		@absorbtivity=opts_[:absorbtivity]
		@rougness=opts_[:rougness] || 0
	end

end