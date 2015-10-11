class Permittivity < BasicMath

	attr_accessor :data

	def initialize(material_, params_={})
		@material=material_
		@data= eval File.read  File.join(File.split(__FILE__)[0], "materials","#{material_}.rb" )
		if @data[:data_type]==:array
			initialize_array_data
		elsif @data[:data_type]==:function && @data[:data_description]==:n_only
			initialize_function_n_only
		elsif @data[:data_type]==:function && @data[:data_description]==:eps
			initialize_function_ε
		end
	end

	def bg
		@data[:bandgap]
	end


	def plot_nk
		Gnuplot.open do |gp|
			Gnuplot::Plot.new( gp ) do |plot|
				_data_x=@op_data.transpose[0]
				_data_y1=@op_data.transpose[1]
				_data_y2=(@data[:data_description]==:n_only ? nil : @op_data.transpose[2])
				#style
				[_data_y1, _data_y2].reject {|x_| x_.nil?}.each do |dat_|
					plot.data << Gnuplot::DataSet.new( [_data_x, dat_]  ) do |ds|
						ds.with = "lines"
					end
				end
			end
		end
	end

	def op_data
		@op_data
	end

private

	def initialize_array_data
		@data_index= Interpolable.new(@data[:data], @material).index
		@op_data = @data[:data]
		define_singleton_method "epsilon" do |λ_|
			_l, _n, _k = @data_index.interpolate(λ_)
			Complex(_n**2 - _k**2,  2*_n*_k)
		end
	end

	def initialize_function_n_only
		_block=eval @data[:data]

		define_singleton_method "n_index", _block

		define_singleton_method "epsilon" do |λ_|
			λ_=λ_
			self.n_index(λ_)**2
		end

		define_singleton_method "op_data" do
			@op_data=[]
			(3000..20000).step(100) do |λ_|
				λ_=λ_ * @data[:data_to_A]
				@op_data.push([λ_, self.n_index(λ_)])
			end
		end

	end

	def initialize_function_ε
		_block=eval @data[:data]

		define_singleton_method "epsilon", _block

		define_singleton_method "op_data" do
			@op_data=[]
			(0.1..1.1).step(100) do |λ_|
				λ_=λ_ * @data[:data_to_A]
				@op_data.push([λ_, self.n_index(λ_)])
			end
		end

	end

end

