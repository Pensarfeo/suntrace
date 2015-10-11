class DataFlex < BasicMath

	attr_accessor :state, :data, :labels, :gpdata
	def initialize(params_={})
		@labels= params_[:labels] || []
		@state=[]
		@gpdata=[]
		@state_data=[]
	end

	def set_state(val_, lable_)
		@labels.push(lable_)
		@state.push(val_)
		new_state
	end

	def labels=(xlabel_, ylabel_)
		@labels=[xlabel_, ylabel_]
	end

	def data=(data_)
		@data_at_state.push(data_)
	end

	def to_gplot
		_i=0
		@data.map do |dat_|
			_dl=dat_[0].length-1
			_deach=dat_.transpose
			_tdat =[_deach[1..-1], new_labels(_i, _dl)]
			@gpdata.push({x: _deach[0]})
			@gpdata[_i][:data_y]=_tdat.transpose.map do |list_, label_|
				{data: list_, label: label_}
			end
			_i+=1
		end
		self
	end

	def to_gplot_state(sparam_, norm_=true)
		_data_plot_y=[]
		_data_plot_x=[]
		@state.each_with_index do |s_, i_|
			_data_plot_x.push(s_[sparam_])
			_data_trans=@data[i_].transpose
			_data_plot_y.push(
				_data_trans[1..-1].map do |dat_|
					BasicMath.integrate(_data_trans[0], dat_, norm_)
				end
			)
		end

		@gpdata=[{x: _data_plot_x, data_y: []}]

		_data_plot_label=new_labels(0, _data_plot_y.last.length)
		_data_plot_y.transpose.each_with_index do |list_, i_|
				@gpdata[0][:data_y].push({data: list_, label: _data_plot_label[i_]})
		end
		self
	end


private


	def new_labels(i_, nd_)
		_label=@labels[i_]
		if @labels[i_].kind_of?(Array)
			_ld=@labels[i_].length
			return _label[0..(_ld-1)]        if _ld>=(nd_)
			return _label + ["noname"]*(nd_ - _ld) if _ld<(nd_)
		else
			[_label]*nd_
		end

	end


	def new_state
		@data.nil? ? @data=[[]] : @data.push([])
		@data_at_state=@data.last
	end
end