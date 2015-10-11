require "./init.rb"

@mat_gl   = Permittivity.new("glass")
@mat_ITO   = Permittivity.new("ITO")
@mat_psic = Permittivity.new("aSiCH")
@mat_si   = Permittivity.new("aSiH")
@mat_ag   = Permittivity.new("Ag")
@mat_ac   = Permittivity.new("ar_coat")
@sc       = SolarCurrent.new
@t_matrix = Tmatrix.new(0)
@data     = DataFlex.new

def sc_tot(params_)
	_tot=0
	params_[:λ_range].step(params_[:λ_step]) do |λ_|
		_tot+=@sc.sphotons(λ_)
	end
	_tot
end

def n_reflections(val_, ap_, ord_, norm_=1)
	(1..ord_).map do |i_|
		(ap_/val_)*(1 - ( 1 - val_ )**i_)*norm_
	end
end


def collection_efficiency(l_,val_)
	@b_col=0
	if l_<0.11
		@a_col=val_
		val_
	elsif l_>=0.1 && l_<=0.4
		@b_col+=(val_- @a_col)*(0.4 - l_)/0.3
		@a_col+@b_col
	elsif l_>0.4
		@a_col + @b_col
	end
end

@n_ref=10
def abs_data_λ(params_)
	_state_var=params_[:state]
	_state_dat=params_[_state_var]


	_state_dat[:range].step(_state_dat[:step]).each do |s_|
		#lput "running at #{_state_var} = #{s_}"
		_sp_norm= (!!params_[:rad]) ? λ_to_j(@mat_si.bg)/@sc.total_power : 1
		#@data.set_state({_state_var => s_} , [params_[:pol]+"r", params_[:pol]+"t", params_[:pol]+"a"])
		@data.set_state({_state_var => s_} ,  Array(1..@n_ref))
		@t_matrix.pol = params_[:pol]
		@t_matrix.th  = params_[:θ]

		params_[:λ_range].step(params_[:λ_step]) do |λ_|
			_scp = (!!params_[:rad]) ? @sc.scurrent(λ_) : 1
			@t_matrix.send :reset
			@t_matrix.λ(λ_)
			@t_matrix.layers = layers(λ_, s_)
			_ref = @t_matrix.run.atr[2]
			_abs_local = @t_matrix.abs_at(:active)
			@data.data= [λ_] + n_reflections(_ref, _abs_local, @n_ref, _scp) #+ Array(_abs) +[0]
			#@data.data= [λ_]  + _ref #+ Array(_abs) +[0]_ref[2],_abs_local
			#lput n_reflections(_ref[2], @n_ref) 
			#lput @data.data
		end

	end
end


#-------------------------------------Parameters----------------------------------#

_integrate_on_state=true
_solar_radiation   =true
_structure_nip     =true   #else pin (p on top)
_solar_type        ="current"
_norm = !_solar_radiation
_type = "total"


@θ0       = PI/2
@θ_range  = (0.0000001..@θ0)
@θ_step   = 0.01


@λ_range=(0.25..@mat_si.bg)
@λ_step=0.001
@sc_tot=0


_l_step   = 0.01
@l        = 0.1
@L_range  = _integrate_on_state ? (_l_step..0.5) : (@l..@l)


def layers(λ_, l_)
	[#{ε: 1, l: 0.1,                  name: :air   },
	 {ε: @mat_gl.epsilon(λ_)  , l: 1  ,   name: :glass },
	 {ε: @mat_ITO.epsilon(λ_) , l: 0.1,   name: :toxide},
	 #{ε: @mat_psic.epsilon(λ_), l: 0.01, name: :p_active},
	 {ε: @mat_si.epsilon(λ_)  , l: l_, name: :active},
	 {ε: @mat_psic.epsilon(λ_), l: 0.02, name: :p_active},
	 {ε: @mat_ITO.epsilon(λ_) , l: 0.03, name: :toxide},
	 {ε: @mat_ag.epsilon(λ_), l: 1}
	 ]
end


_ranges ={state: :l, var: :λ, 
					l: {i: 0.1, range:@L_range, step: _l_step},
					λ: {i: 0.1, range:@λ_range, step: @λ_step},
					θ: {i: @θ0, range:@θ_range, step: @θ_step },
					θ: PI/2,
					λ_range: @λ_range, λ_step: @λ_step,
					θ_range: @θ_range, θ_step: @θ_step,
					rad: _solar_radiation}



abs_data_λ(_ranges.merge({ pol: "te"}) )
#abs_data_λ(_ranges.merge({ pol: "tm"}))


_θ_range=@θ_range.step(@θ_step).map {|x_| x_/(PI/2)}
_λ_range=@λ_range.step(@λ_step).map {|x_| x_}
_λ_norm=@λ_step/(@λ_range.last-@λ_range.first)

_integrate_on_state ? @data.to_gplot_state(_ranges[:state],_norm) : @data.to_gplot

Gnuplot.open do |gp|
	Gnuplot::Plot.new( gp ) do |plot|
		@data.gpdata.each do |dat_|
			dat_[:data_y].map do |daty_|

				_ndat= [dat_[:x], daty_[:data]].transpose.map do |x_, y_|
					#_solar_radiation ? [x_,collection_efficiency(x_ , y_)] : [x_,y_]
					[x_,y_]
				end.transpose #[dat_[:x], daty_[:data]]

				plot.data << Gnuplot::DataSet.new( _ndat ) do |ds|
					ds.with = "lines"
					ds.linewidth = 2
					ds.title = daty_[:label]
				end
			end
		end
	end
end
