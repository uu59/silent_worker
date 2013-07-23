[![Build Status](https://travis-ci.org/uu59/silent_worker.png)](https://travis-ci.org/uu59/silent_worker)
[![Coverage Status](https://coveralls.io/repos/uu59/silent_worker/badge.png?branch=master)](https://coveralls.io/r/uu59/silent_worker?branch=master)

# SilentWorker

SilentWorker gives simple worker thread model.

## Installation

Add this line to your application's Gemfile:

    gem 'silent_worker'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install silent_worker

## Usage

```ruby
sw = SilentWorker.new(2) do |data|
  puts data
  sleep 0.01
end

10.times |n|
  sw << n
end

sw.wait

# => 
#  1
#  0
#  2
#  3
#  4
#  5
#  6
#  7
#  8
#  9

# NOTE: Order is a random
```

Real world example:

```ruby
parallel = 8

sw = SilentWorker.new(parallel) do |url|
  system("wget", url)
end

File.open('url_list.txt') do |f|
  sw << f.gets.strip
end

File.open('url_list2.txt') do |f|
  sw << f.gets.strip
end

sw.wait
```

This example will be 8 paralleled `wget` from `url_list.txt` and `url_list2.txt` such as `cat url_list.txt url_list2.txt | xargs -P8 -n1 wget`.

## See Also

* [parallel](https://github.com/grosser/parallel)
* [eventmachine](https://github.com/eventmachine/eventmachine)
* [celluloid](https://github.com/celluloid/celluloid)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
