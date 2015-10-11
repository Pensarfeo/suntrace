class SolarCurrent<BasicMath


	attr_accessor :data

	def initialize()
		@data= eval File.read  File.join(File.split(__FILE__)[0], "solarcurrent_data.rb")
		@data_index= Interpolable.new(@data[:data], "solarcurrent").index
	end

	#W/m**2 Ideally should be 1000 W/m**2 but we made a mistake exporting data to mathematica
			# ie. all our values are 1000 times smaller...
			#it should not change much...
	def total_power
		1000 
	end

	def scurrent(λ_)
		@data_index.interpolate(λ_)[1]
	end

	def sphotons(λ_)
		@data_index.interpolate(λ_)[2]
	end

	def ip_data
		@ip_data=[]
		(0.3..2).step(0.001) do |λ_|
			@ip_data.push(self.ip(λ_))
		end
		@ip_data
	end

	def plot_sc
		Gnuplot.open do |gp|
			Gnuplot::Plot.new( gp ) do |plot|
			#style
				plot.data << Gnuplot::DataSet.new( @ip_data.transpose  ) do |ds|
					ds.with = "linespoints"
				end
			end
		end
	end


private

end