require 'gnuplot'
require './run_cases.rb'

include Math
include RunCases
require 'cmath'

$ENV||={}
$ENV[:root_dir]="C:/Users/pedro/Desktop/patent/raytracer"

["math","tmatrix","material", "tracer", "solar_iv","solar_current"].each do |dir_|
	Dir["./#{dir_}/*.rb"].each do |file_|
		require file_
	end
end

include HomelessMethods
