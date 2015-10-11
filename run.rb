require "./init.rb"
_mat_gl   = Permittivity.new("glass")
_mat_si   = Permittivity.new("cSi")
_mat_ag   = Permittivity.new("Ag")
_mat_ac   = Permittivity.new("ar_coat")
_θ        = PI/2
_θ_range  = (0.0000001.._θ)
_θ_step   = 0.05
_sc=SolarCurrent.new
_t_matrix=Tmatrix.new(0)

_data_te=[]
_data_tm=[]

_λ_range=(0.5..0.93)
_λ_step=0.001
_sc_tot=0


	layers=->(λ_) {
		_layers=[
				 {ε: 1, l: 0.1},
				 {ε: _mat_gl.epsilon(λ_), l: 1},
				 {ε: 1.8**2, l: 0.1},
				 {ε: _mat_si.epsilon(λ_), l: 1},
				 {ε: 1.8**2, l: 0.1},
				 {ε: _mat_ag.epsilon(λ_), l: 2.1}
				 ]
	}

_λ_range.step(_λ_step) do |λ_|

	_t_matrix.k0(λ_)
	_θ_data=[]
	_scp=_sc.ip(λ_)[1]
	_sc_tot=_sc_tot+_scp

	_θ_range.step(_θ_step) do |θ_|
		_t_matrix.theta(θ_)
		_layers=layers.call(λ_)
		_abs_tm=_t_matrix.rt_tm(λ_, _layers)[2]
		_ic_tm=_abs_tm*_scp
		_θ_data.push( _ic_tm )
	end
	_data_te.push([λ_]+_θ_data )
end

_λ_range.step(_λ_step) do |λ_|

	_t_matrix.k0(λ_)
	_θ_data=[]
	_scp=_sc.ip(λ_)[1]

	_θ_range.step(_θ_step) do |θ_|
		_t_matrix.theta(θ_)
		_layers=layers.call(λ_)
		_abs_te=_t_matrix.rt_te(λ_, _layers)[2]
		_ic_te=_abs_te*_scp
		_θ_data.push( _ic_te )
	end

	_data_tm.push([λ_]+_θ_data)
end

_θ_range=_θ_range.step(_θ_step).map {|x_| x_/(PI/2)}
_λ_norm=_λ_step/(_λ_range.last-_λ_range.first)

_θ_abs_te=_data_te.transpose[1..-1].map do |dat_|
	_dat_tot=dat_.inject(:+)
	_dat_tot/_sc_tot
end

_θ_abs_tm=_data_tm.transpose[1..-1].map do |dat_|
	_dat_tot=dat_.inject(:+)
	_dat_tot/_sc_tot
end

	Gnuplot.open do |gp|
		Gnuplot::Plot.new( gp ) do |plot|
			plot.data << Gnuplot::DataSet.new( [_θ_range, _θ_abs_te] ) do |ds|
				ds.with = "linespoints"
				ds.linewidth = 2
				ds.title = "TE"
			end
			plot.data << Gnuplot::DataSet.new( [_θ_range, _θ_abs_tm] ) do |ds|
				ds.with = "linespoints"
				ds.linewidth = 2
				ds.title = "TM"
			end
		end
	end

#Gnuplot.open do |gp|
#	Gnuplot::Plot.new( gp ) do |plot|
#		#style
#		plot.xrange "[#{_λ_range.first}:#{_λ_range.last}]"
#		_gp_data=_data_te.transpose
#		_gp_data[1..-1].each_with_index do |dat_, ind_|
#			_norm_d=dat_.max
#			_datn=dat_.map{ |d_| d_}
#			plot.data << Gnuplot::DataSet.new( [_gp_data[0], _datn] ) do |ds|
#				ds.with = "lines"
#				ds.linewidth = 2
#				ds.title = ind_.to_s
#			end
#		end
##		plot.data << Gnuplot::DataSet.new( "1" ) do |ds|
##			ds.with = "lines"
##			ds.linewidth = 2
##		end
#	end
#end


#	_data=[]
#_θ_range.step(_θ_step) do |θ_|
#	λ_=0.5
#	_t_matrix.theta(θ_)
#	_t_matrix.kx(λ_)
#	_layers=[
#					 {ε: 1, l: 0.1},
#					 {ε: 1.5**2, l: 0},
#					 {ε: 1.8**2, l: 1},
#					 {ε: _mat_si.epsilon(λ_), l: 0.5},
#					 {ε: 1.8**2, l: 0.1},
#					 {ε: _mat_ag.epsilon(λ_), l: 2.1}
#					 ]
#	#_abs_tm=_t_matrix.rt_te(θ_, _layers)
#	_abs_te=_t_matrix.rt_te(λ_, _layers)
#	_abs_tm=_t_matrix.rt_tm(λ_, _layers)
#	_data.push([θ_, _abs_te[0], _abs_tm[0]] )
#end#
#

#Gnuplot.open do |gp|
#	Gnuplot::Plot.new( gp ) do |plot|
#		#style
#		plot.xrange "[#{_θ_range.first}:#{_θ_range.last}]"
#		_gp_data=_data.transpose
#		_gp_data[1..-1].each_with_index do |dat_, ind_|
#			_norm_d=dat_.max
#			_datn=dat_.map{ |d_| d_}
#			plot.data << Gnuplot::DataSet.new( [_gp_data[0], _datn] ) do |ds|
#				ds.with = "linespoints"
#				ds.linewidth = 2
#				ds.title = ind_.to_s
#			end
#		end
#	end
#end
