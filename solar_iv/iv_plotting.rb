module IvPlotting
	def vocsh
		_data=[]
		_mshunt=1
		_step=_mshunt/100.0
		(0.1.._mshunt).step(_step) do |x_|
			@rsh=x_
			_data.push([x_, self.voc])
		end
		_data= _data.transpose

		Gnuplot.open do |gp|
			Gnuplot::Plot.new( gp ) do |plot|
				#style
				plot.xrange "[0:#{_mshunt}]"
				plot.data << Gnuplot::DataSet.new( _data ) do |ds|
					ds.with = "lines"
				end
			end
		end
	end

	def voc_sun(sun_max_)
		@rsh=0.1;
		_data_1= voc_sun_data(sun_max_).transpose
		@rsh=10
		_data_2= voc_sun_data(sun_max_).transpose

		Gnuplot.open do |gp|
			Gnuplot::Plot.new( gp ) do |plot|
				#style
				plot.xrange "[0:#{sun_max_}]"
				plot.data << Gnuplot::DataSet.new( _data_1 ) do |ds|
					ds.with = "lines"
				end
				plot.data << Gnuplot::DataSet.new( _data_2 ) do |ds|
					ds.with = "lines"
				end
			end
		end
	end

	def plot_iv
		_vm=self.voc
		_data_iv=self.iv_points(_vm).transpose
		_data_pw=self.power_points(_vm).transpose
		_pmax = self.pmax
		Gnuplot.open do |gp|
			Gnuplot::Plot.new( gp ) do |plot|
				#style
				plot.title ["surf: #{@area}, suns: #{@suns.signif(3)}",
										"pmax: #{_pmax[1][0].signif(4)}",
										"I,V= #{self.i(_pmax[0][0]).signif(4)} ,#{_pmax[0][0].signif(4)}"].join(", ")
				plot.yrange "[0: #{self.i(0)*1.2}]"
				plot.xrange "[0:#{_vm}]"
				plot.data << Gnuplot::DataSet.new( _data_iv ) do |ds|
					ds.with = "lines"
				end
				plot.data << Gnuplot::DataSet.new( _data_pw ) do |ds|
					ds.with = "lines"
				end
				plot.data << Gnuplot::DataSet.new( _pmax ) do |ds|
					ds.with = "points"
				end
			end
		end
	end


	def plot_distributed_id(data_)
		_vm=self.voc
		_data_iv=self.iv_points(_vm).transpose
		_data_pw=self.power_points(_vm).transpose
		
		Gnuplot.open do |gp|
			Gnuplot::Plot.new( gp ) do |plot|
				#style
				plot.yrange "[0: #{self.i(0)*1.2}]"
				plot.xrange "[0:#{_vm}]"
				plot.data << Gnuplot::DataSet.new( _data_iv ) do |ds|
					ds.with = "lines"
				end
				plot.data << Gnuplot::DataSet.new( _data_pw ) do |ds|
					ds.with = "lines"
				end
				plot.data << Gnuplot::DataSet.new( _pmax ) do |ds|
					ds.with = "points"
				end
			end
		end

	end
end