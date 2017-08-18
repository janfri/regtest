# Regtest - Simple Regression Testing For Ruby Projects

## Description

This library support a very simple way to do regression testing in Ruby
projects.  You write Ruby scripts with samples. Run these and get the sample
results as YAML output besides your scripts. Check both the scripts and the YAML
files with the results in you Source Code Control System.  When you run the
scrips on a later (or even previous) version of your code a simple diff show you
if and how the changes in your code impact the results of your samples.

This is not a replacement for unit testing but a complement: You can produce a
lot of samples with a small amount of Ruby code (e.g. a large number of
combinations of data).


## Installation

Installing the gem on the command line with

```sh
gem install regtest
```

or add

```ruby
gem 'regtest'
```
to your Gemfile or put a copy of `regtest.rb` in your project.


## Using

The idea behind regtest is the following workflow:
  1. Writing samples
  2. Running samples
  3. Checking results (differences between the actual results and the results of
     a previous run of your samples using the diff functionality of your Source
     Code Control System)


### Writing Samples

A samples file is a simple Ruby script with one ore more samples, for example

```ruby
require 'regtest'

Regtest.sample 'String result' do
  # Doing something to get the result of the sample
  # end make sure it is the result of the block
  'some text'
end

Regtest.sample 'Division by zero' do
  # If an exception occurs while execution of the
  # block it is catched and used as value for the
  # sample
  2 / 0
end
```

The name of the sample (parameter of the `Regtest.sample` method) and the
results of the samples (return value of the block) are stored in YAML format. So
it should be a YAML friendly value as `String`, `Number`, `Boolean value`,
`Symbol`.  Results could also be an `Array` or `Hash` with such values.


#### Helpers

There is a method `Regtest.combinations` to generate a lot of combinations the
easy way. An example:

```ruby
require 'ostruct'
require 'regtest'

o = OpenStruct.new
o.a = [1,2,3]
o.b = [:x, :y]
Regtest.combinations(o).map(&:to_h)
# => [{:a=>1, :b=>:x}, {:a=>1, :b=>:y}, {:a=>2, :b=>:x}, {:a=>2, :b=>:y}, {:a=>3, :b=>:x}, {:a=>3, :b=>:y}]
```

See also the combinations example in the `regtest` folder.

You can also include `Regtest` to have the `sample` and `combinations method at top level.

```ruby
require 'regtest'
include Regtest

sample :x do
  :x
end
```

By convention sample files are stored in a directory `regtest` in your Ruby application.


### Running Samples

Whether you run your examples manually

```sh
ruby -I lib regtest/*.rb
```

or using the Rake task of regtest and add

```ruby
require 'regtest/task'
```

to your `Rakefile` and you can run your samples with `rake regtest`.


### Checking Results

The results of each samples file are stored as a collection of YAML documents in
a corresponding results file (YAML) per samples file.  For example for the
samples files

```sh
regtest/foo.rb
regtest/bar.rb
```

are the corresponding results files

```sh
regtest/foo.yml
regtest/bar.yml
```

So the content of the results file of the example above is

```yaml
---
sample: String result
result: some text
---
sample: Division by zero
exception: divided by 0
```

Note: Each sample is represented by a YAML document in the corresponding YAML
file.

Each time you run one ore more samples file the corresponding results file will
be overwritten (or generated if not yet existent) with the actual result values
of your samples.  So Source Code Version Control program is the tool to
determine changes between older runs of the samples.  Therefore the samples file
and their corresponding results files should be taken under version control.


## Further information

I use `regtest` in my project [scripref](https://github.com/janfri/scripref) to
generate a lot of malformed input data to check regressions in the behaviour of
the parser and text processor.

A little different is the usage in my projects
[mini_exiftool](https://github.com/janfri/mini_exiftool/tree/master/regtest) and
[multi_exiftool](https://github.com/janfri/multi_exiftool-redesign/tree/master/regtest).
There regtest is used for integration testing to check if Exiftool itself (an
external program that I do not develop) returns different values or new tags in
newer versions.


## Source Code

The code is hosted on [github](https://github.com/janfri/regtest) and
[bitbucket](https://bitbucket.org/janfri/regtest) Change it to your needs.
Release a fork. It is open source.

## Author

Jan Friedrich <janfri26@gmail.com>

## License

Regtest is licensed under the same terms as Ruby itself.
