require 'hotch'
require 'transproc/all'
require 'benchmark/ips'
require 'yaml'
require 'byebug'

module T
  extend Transproc::Registry

  import :nest_slow, from: Transproc::HashTransformations
  import :nest, from: Transproc::HashTransformations
end

nest_slow = T[:nest_slow, :address, [:street, :city, :zipcode]]
nest_fast = T[:nest, :address, [:street, :city, :zipcode]]

m = -> b, m { s = Time.now; b.call; puts "#{m} done in #{Time.now-s} seconds" }

size = ENV['SIZE'].to_i

data = size.times.map do |i|
  { name: "user #{i}", street: "street #{i}", city: "city #{i}", zipcode: "zip-#{i}" }
end

m.(-> { nest_slow[data[0]] }, 'nest_slow')
m.(-> { nest_fast[data[1]] }, 'nest_fast')

Hotch() do
  data.map { |r| nest_fast.call(r) }
end

puts '*'*80

Benchmark.ips do |x|
  x.report("[nest_slow] nest #{size} items") do
    data.map { |r| nest_slow.call(r) }
  end

  x.report("[nest_fast] nest #{size} items") do
    data.map { |r| nest_fast.call(r) }
  end

  x.compare!
end
