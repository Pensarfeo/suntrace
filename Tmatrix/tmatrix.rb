class Tmatrix < BasicMath

	attr_accessor :layers, :th, :k0, :matm, :matp, :pol, :inter_f

	def initialize(θ_,layers_={})
		@th = θ_
		@layers=layers_
		@pol="te"
		reset
	end

	def reset
		reset
	end

	def run
		self.send(@pol)
		self
	end

	def matm=(mat_)
		@matm.push(mat_)
	end

	def matp=(mat_)
		@matp.push(mat_)
	end


	def λ(λ_)
		@λ=λ_
		@k0=(2*PI/λ_)
	end

	def te
		@tn=te_norm
		_lmat=@layers.last

		@layers.each_cons(2).map do |mat0_, mat1_|
			_kz0 , _kz1 = kz(@λ, mat0_[:ε]), kz(@λ, mat1_[:ε])
			@norm_t.push(_kz0)
			form_matrix(_kz1 / _kz0, mat1_[:l] * _kz1)
		end

		@norm_t.push(kz(@λ, _lmat[:ε]))
	end

	def tm
		@tn=tm_norm
		_lmat=@layers.last
		@layers.each_cons(2).map do |mat0_, mat1_|
			_kz0 , _kz1 = kz(@λ, mat0_[:ε]), kz(@λ, mat1_[:ε])
			_a_0 = (_kz0/mat0_[:ε])
			_a_1 = (_kz1/mat1_[:ε])
			@norm_t.push(_a_0)
			form_matrix(_a_1/_a_0, mat1_[:l] * _kz1)
		end
		@norm_t.push(kz(@λ, _lmat[:ε])/_lmat[:ε])

	end

	def atr
		@t = (1/@matt[0,0])
		@r = @matt[1,0] * @t
		@R = @r.abs**2
		@T = (@norm_t.last.real/@norm_t.first.real)*(@t.abs**2)
		@A = 1-@R-@T

		[@R, @T, @A]
	end

	def selected_layer(name_)
		@layers.each_with_index do |l_, i_|
			@selected_layer=i_ if l_[:name]==name_
		end if @selected_layer.nil?
	end

	#the energy loss is normalized by the input power to get the layers absolute absortivity
	# Initial power input reduces to @norm_t[0].real
	def abs_at(name_)
		self.selected_layer(name_)
		_n=@selected_layer
		@inter_f=interface_fields
		_ei = @inter_f[_n-1][0]
		_er = @inter_f[_n-1][1]
		_et = @inter_f[_n][2]
		_eb = @inter_f[_n][3]
		_nf = @norm_t[_n-1].conjugate
		_nl = @norm_t[_n+1].conjugate
		_pin  = _nf * (_ei.abs**2 + _er * _ei.conjugate - _er.abs**2 - _ei * _er.conjugate)
		_pout = _nl * (_et.abs**2 + _eb * _et.conjugate - _eb.abs**2 - _et * _eb.conjugate)
		(_pin - _pout).real/(@norm_t[0].real)
	end

private

	#light incident form the left
	def interface_fields
		_mats=[@matm.reverse,@matp.reverse].transpose
		_left_fields=Matrix[[@t],[0]]
		_mats.map do |m_,p_|
			#fields to the right of the interface
			_right_fields=p_*_left_fields
			#fields at the left of the interface
			_left_fields=m_*_right_fields
			_left_fields.to_a.flatten + _right_fields.to_a.flatten
		end.reverse

	end

	def interface_power_flow
		@inter_f=interface_fields
		_i=0

		@inter_p = @inter_f.map do |ei_, er_, et_, eb_|
			_nl = @norm_t[_i].conjugate
			_nr = @norm_t[_i+1].conjugate
			_i+=1
			_pleft  = _nl * (ei_.abs**2 + er_ * ei_.conjugate - er_.abs**2 - ei_ * er_.conjugate)
			_pright = _nr * (et_.abs**2 + eb_ * et_.conjugate - eb_.abs**2 - et_ * eb_.conjugate)
			_pright.real/(@norm_t[0].real)
		end
		@inter_p

	end


	def reset
		@R=nil
		@T=nil
		@norm_t=[]
		@matm=[]
		@matp=[]
		@matt=Matrix[[1,0],[0,1]]
	end


	def form_matrix(pfe_, optical_length_)
		_tramatr= 0.5*Matrix[[1 + pfe_, 1 - pfe_], [1 - pfe_, 1 + pfe_]]
		@matm.push(_tramatr)

		_pro     = Complex(0, 1) * optical_length_
		_pro_re  = _pro.real.abs
		_pro_img = _pro.imag

		_prop_matrix = Matrix[ [exp(_pro_re)* CMath.exp(Complex(0,-1*_pro_img)), 0],
													 [0   ,exp(-1*_pro_re)*CMath.exp(Complex(0,_pro_img)) ]
												 ]

		@matp.push(_prop_matrix)
		@matt= (@matt*_tramatr)*_prop_matrix
	end

	def kx
		@k0*cos(@th)
	end

	#get k vector nomral to the surface
	#kp is the kvector componenent parallel to the surfaces
	def kz(λ_, ε_)
		_kz=CMath.sqrt(ε_*(2*PI/λ_)**2 - kx**2)
		_kz.real<0 ? -_kz : _kz
	end

	def tm_norm_layer(λ_,mat0_, mat1_)
		_kz0 , _kz1 = kz(λ_, mat0_[:ε]), kz(λ_, mat1_[:ε])
	end

	def tm_norm
		_εf=@layers.first[:ε]
		_εl=@layers.last[:ε]
		_tnf = (_εf/kz(@λ, _εf)).real
		_tnl = (kz(@λ, _εl)/_εl).real
		_tnf *_tnl
	end

	def te_norm
		_εf=@layers.first[:ε]
		_εl=@layers.last[:ε]
		(kz(@λ, _εl)/kz(@λ, _εf)).real
	end



end