require 'transproc/all'
require 'benchmark/ips'
require 'yaml'
require 'byebug'
require 'pathname'

combine_slow = Transproc[
  :combine_slow,
  [
    [
      :item, {:item_id=>:id}, [
        [:contributions, {:id=>:item_id}, [
          [:contributor, {:contributor_id=>:id}]
        ]]
      ]
    ]
  ]
]

combine_fast = Transproc[
  :combine,
  [
    [
      :item, {:item_id=>:id}, [
        [:contributions, {:id=>:item_id}, [
          [:contributor, {:contributor_id=>:id}]
        ]]
      ]
    ]
  ]
]

m = -> b, m { s = Time.now; b.call; puts "#{m} done in #{Time.now-s} seconds" }

size = ENV['SIZE'] or abort "usage: SIZE=50|100|200 #$0"
data = YAML.load_file("#{Pathname(__FILE__).dirname.realpath}/data_#{size}.yml")

m.(-> { combine_slow[data] }, 'combine_slow')
m.(-> { combine_fast[data] }, 'combine_fast')

puts '*'*80

Benchmark.ips do |x|
  x.report("[combine_slow] combine #{size} items with 3 levels of nesting") do
    combine_slow.call(data)
  end

  x.report("[combine_faster] combine #{size} items with 3 levels of nesting") do
    combine_fast.call(data)
  end

  x.compare!
end
