require "./init.rb"
lput "Lets Start"

$geometry=[]
$transformation_efficiency=0.25
$ray=nil
$max_x=1.0
$height=1


def create_line(*args_)
	_line=MaterialFlatSurface.new(*args_)
	$geometry.push(_line)
	_line
end


def create_geometry()
	_side_inclination=0*PI/500
	_number_surfaces=2
	$basic_angle=PI/6

	$abs=_absorptivity=0.30
	create_line(pi: [0, 0]     , theta: PI/2 - _side_inclination,
							yf: $height, absorbtivity: _absorptivity, rougness: 0)
	create_line(pi: [$max_x, 0], theta: PI/2 +_side_inclination,
							yf: $height, absorbtivity: _absorptivity, rougness: 0)
end
create_geometry()

	def smooth_on_surf(data_,step_)
		data_=data_.sort_by! {|i_| i_[0]}
		_surf_data=[]
		_step=1.0/step_
		_region_n=_step
		_surface=[]
		smmoth_data_on_region(data_, _region_n, _surface, _step)
		_surface
	end


	def smmoth_data_on_region(data_, region_n_, surface_,step_)
		_in, _out = data_.partition {|i| i[0]<=region_n_}

		if !_in.empty?
			surface_.push([region_n_, _in.transpose[1].inject(:+)*$abs])
		else
			surface_.push([region_n_, 0])
		end

		if !_out.empty?
			smmoth_data_on_region(_out,region_n_+step_,surface_, step_ )
		elsif region_n_ < $height
			smmoth_data_on_region([[$height, 0]],region_n_+step_,surface_, step_ )
		end

	end

	def surface_iv(data_)
		Iv.new(suns: data_[1] )
	end


_cases="path"
#_cases="num_reflections"
#_cases="illumination_intensity"
#_cases = "ivpower_hramp"
#_cases = 'ivpower_ang_hramp'
case _cases
when "path"
	trace_path(pi: [0.5, $height], theta: -PI/6)
when "num_reflections"
	#theta points
	_points_theta = 1000
	_limit_angle=(PI)/8
	_theta_step   =(PI-2*_limit_angle)/_points_theta
	_theta_list   = Array.new(_points_theta) { |i_| -(_limit_angle + _theta_step*(1+i_)) }
	#pi points
	_points_pi    = 100
	_min_border=0.02
	_pi_step=($max_x-2*_min_border)/_points_pi
	_pi_list      = Array.new(_points_pi) { |i_| [_min_border + _pi_step*(1+i_), $height] }
	#calculate
	number_of_reflections_per(theta: _theta_list, pi:    _pi_list )
	plot_absortivity(true)

when "illumination_intensity"
	#pi points
	_points_pi    = 1000
	_min_border   = 0.002
	_pi_step      = ($max_x-2*_min_border)/_points_pi
	_pi_list      = Array.new(_points_pi) { |i_| [_min_border + _pi_step*(1+i_), $height] }

	#theta points
	_points_theta = 20
	_limit_angle=(PI)/8
	_theta_step   =(PI-2*_limit_angle)/_points_theta
	_theta_list   = Array.new(_points_theta) { |i_| -(_limit_angle + _theta_step*(1+i_)) }

	#calculate
	_data=max_power_per(theta: _theta_list, pi:    _pi_list)
	plot_power_ang(_data)

when "ivpower_hramp"

	#pi points
	_points_pi    = 1000
	_min_border   = 0.002
	_pi_step      = ($max_x-2*_min_border)/_points_pi
	_pi_list      = Array.new(_points_pi) { |i_| [_min_border + _pi_step*(1+i_), $height] }


	#calculate
	_data=[]

	(1...5).step(0.1) do |h_|
		$geometry=[]
		create_geometry(h_)
		_data||= DataState.new(labels: ["itheta", "pmax"])
		_data.data=[$height*4, max_power_per(theta: [-PI/2], pi:    _pi_list)[1][0]]
	end
	Gnuplot.open do |gp|
		Gnuplot::Plot.new( gp ) do |plot|
			#style
			#info
			plot.data << Gnuplot::DataSet.new( _data.transpose ) do |ds|
				ds.with = "linespoints"
				ds.notitle
			end
		end
	end

when "ivpower_ang_hramp"

	#theta points
	_points_theta = 50
	_limit_angle=(PI)/20
	_theta_step   =(PI-2*_limit_angle)/_points_theta
	_theta_list   = Array.new(_points_theta) { |i_| -(_limit_angle + _theta_step*(1+i_)) }

	#pi points
	_points_pi    = 1000
	_min_border   = 0.002
	_pi_step      = ($max_x-2*_min_border)/_points_pi

	_data= DataState.new(labels: ["itheta", "pmax"])

	(0.5...5).step(0.5) do |h_|
		$geometry=[]
		$height=h_
		lput $height
		create_geometry
		_pi_list = Array.new(_points_pi) { |i_| [_min_border + _pi_step*(1+i_), $height] }
		_data.h=h_
		_data.data=max_power_per(theta: _theta_list, pi:    _pi_list)
	end

	plot_power_ang(_data)


end