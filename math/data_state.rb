class DataState

	attr_accessor :h, :data, :labels
	def initialize(params_={})
		@h=[]
		@labels= params_[:labels] || []
		@data=[]
	end

	def h=(val_)
		h.push(val_)
	end

	def labels=(xlabel_, ylabel_)
		@labels=[xlabel_, ylabel_]
	end

	def data=(data_)
		@data.push(data_)
	end

end