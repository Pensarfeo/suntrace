class BasicMath
	include Math
	require "matrix"
	alias :old_tan :tan
	def tan(theta_)
		if    (theta_ % PI)    ==0
			0.0
		elsif (theta_ % (PI/2))==0
			1/0.0
		else
			old_tan(theta_)
		end
	end

	def project_vectors(v1_,v2_)
		v1_*(v1_.inner_product(v2_))
	end


	def self.integrate(data_x, data_y, norm_=false)
		_data=[data_x, data_y].transpose.reject { |x| x[1].nan?}

		_data_f=[(_data[1][0]-_data[0][0]), _data[0][1]]
		_data_m=_data.each_cons(3).map do |p0, p1, p2|
			[((p2[0]-p1[0]) + (p1[0]-p0[0]))*0.5, p1[1]]
		end
		_data_l=[(_data[-1][0]-_data[-2][0]), _data[-1][1]]
		_dat_tot=[_data_f]+_data_m+[_data_l]
		_integral=0
		_dat_tot.each do |x,y|
			_integral+=(x*y)
		end
		norm_ ? _integral/(data_x[-1]-data_x[0]) : _integral
	end


end

class Float
	def ===(val_, tolerance_=10**-12*1.0)
		(self-val_).abs<tolerance_
	end

	def signif(signs)
		Float("%.#{signs}g" % self)
	end

end

class FixNum
	def ===(val_, tolerance_=10**-12*1.0)
		(self-val_).abs<tolerance_
	end
	def nan?
		false
	end
end

class Array
	def mean
		self.inject(:+)/self.count
	end
end

#—————————————————————————————————————————————————————————————————————————————————#
#————               >>>>>>>>>basic wavelength math<<<<<<<<<                   ————#
#—————————————————————————————————————————————————————————————————————————————————#

# common contants
PLANCKJ  = 6.626*10**-34       #Jules*s
PLANCKeV = 4.135667516*10**-15 #eV*s
LIGHTSPEED = 2.998*10**14      #μm/s
Hc_Jμm     = PLANCKJ * LIGHTSPEED
Hc_eVμm    = PLANCKeV * LIGHTSPEED
Qcharge    =1.60217657*10**-19 #coulombs
Boltzmank  = 8.617*(10**(-5))  # kb/e (Volt/Kelvin)

# wavelength to energy
def λ_to_j(λ_)
	Hc_Jμm/λ_
end

def λ_to_eV(λ_)
	Hc_eVμm/λ_
end


