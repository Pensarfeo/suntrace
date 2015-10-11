require 'minimization'

class IV < BasicMath

	attr_accessor :area

	def initialize(params_={})
		@A    = params_[:area]  || 0.01
		@T    = params_[:T]      || 25             # Centigrade
		_Dp   = difussion_coefficient(_μp)
		_Dn   = difussion_coefficient(_μn)
		_Nd   = params_[:Nd]    || 10**16
		_Na   = params_[:Na]    || 10**20
		_τp   = params_[:τp]
		_τn   = params_[:τa]
		_Lp   = difussion_length(_Dp,_μp)
		_Ln   = difussion_length(_Dn,_μn)
		@idark=Qcharge*@A*_ni**2*(_Dp/(_Lp*_Nd)+_Dn/(_Ln*_Na))
		@shh  = params_[:shh] || false

		@tk   = @T + 273.16                        # Kelvin
		@kbe  = 8.617*(10**(-5))                   # kb/e (Volt/Kelvin)
		@n    = params_[:n]      || 2.5
		@kbet = @n * @kbe * @tk                         # Volt
		@i0   = params_[:I0]     || 6*(10**(-5))   # Amper
		@rsh  = params_[:Rshunt] || 10             # ohm
		@suns = params_[:suns] || 1
		@lpd  = 3.2*(10**(21)) # charges / (meter) for 1 second
		@ca   = params_[:area] || 0.01               # m^2, 10cm^2 indicence surface
		@ampc = 6.241*(10**18)                       # Amper = C / meter^2
		@li   = ((@lpd * @suns) / @ampc) * @ca # create
		@area = params_[:area] || 1;
	end

	def i(v_)
		@li - @area * (@i0*(exp(v_/@kbet) - 1) + (v_/@rsh))
	end

	def di_dv(v_)
		-@area*( @i0*(1/@kbet)*exp(v_/@kbet) + (1 / @rsh))
	end

	def li=(suns_)
		@suns=suns_
		@li   = (@lpd*@suns / @ampc) * @ca
		puts "li was corrected to #{@li}" if @shh
		@li
	end


	def set_distributed_iv(ilu_dat_)
		self.area = $height*4
		self.li = ilu_dat_.inject(:+)
		return self
	end

	def set_normal_iv(suns_)
		self.area = 1
		self.li = suns_
		self
	end

	def voc
		d = Minimization::Brent.new(0.01, 1 , proc {|x| self.i(x)**2 })
		d.iterate
		d.x_minimum
	end

#		d = Minimization::Brent.new(0.01, 1 , proc {|x_| (self.di_dv(x_) * x_ + self.i(x_) ) })

	def pmax
		d = Minimization::Brent.new(0.01, 10 , proc {|x_| -(self.i(x_) * x_ ) })
		d.iterate
		if @shh
			puts "surface area correction #{@area}"
			puts "max power #{-d.f_minimum}"
		end
		[[d.x_minimum], [-d.f_minimum]]
	end

	def voc_sun_data(sun_max_)
		_data=[]
		_suns=sun_max_
		_step=_suns/100.0
		(0.._suns).step(_step) do |x_|
			@lpd  = 3.2*(10**(21))* x_
			@li   = (@lpd / @ampc) * @ca
			_data.push([x_, self.voc])
		end
		_data
	end


	def iv_points(vm_)
		_data= []
		(0..vm_).step(vm_/100) {|x_| _data.push([x_, self.i(x_)])}
		_data
	end

	def power_points(vm_)
		_data= []
		(0..vm_).step(vm_/100) {|x_| _data.push([x_, self.i(x_)*(x_)])}
		_data
	end

private

	def difussion_length(d_, μ_)
		sqrt(d_*μ_)
	end

	def difussion_coefficient(μ_)
		μ_*Boltzmank*@T/Qcharge
	end


end