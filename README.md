# Regtest - Simple Regression Testing With Ruby

## Description

This library support a very simple way to do regression testing with Ruby. It
is not limited to Ruby projects you can use it also in other contexts where you
can extract data with Ruby.

You write Ruby scripts with samples. Run these and get the sample results as
results files besides your scripts. Check both the scripts and the results
files in you Source Code Management System (SCM). When you run the scrips on a
later (or even previous) version of your code a simple diff show you if and how
the changes in your code or environment impact the results of your samples.

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
to your Gemfile.


## Using

The idea behind regtest is the following workflow:
  1. Writing samples
  2. Running samples
  3. Commit samples and result files to SCM.
  4. Change your code and / or external environment.
  5. Rerun your samples
  6. Check sample results for changes (this is normally automatically done with
     a regtest plugin like regtest/git).


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
results of the samples (return value of the block) are stored in YAML format.
So it should be a YAML-friendly value as `String`, `Number`, `Boolean value`,
`Symbol`. Results could also be an `Array` or `Hash` with such values.

In many cases you want to generate a lot of combinations of input data in your
sample code. For this there is a method `Regtest.combinations` to generate a
lot of combinations the easy way. An example:

```ruby
require 'ostruct'
require 'regtest'

o = OpenStruct.new
o.a = [1,2,3]
o.b = [:x, :y]
Regtest.combinations(o)
# => [#<OpenStruct a=1, b=:x>, #<OpenStruct a=1, b=:y>,
#     #<OpenStruct a=2, b=:x>, #<OpenStruct a=2, b=:y>,
#     #<OpenStruct a=3, b=:x>, #<OpenStruct a=3, b=:y>] 
```

See also the combinations example in the `regtest` folder.

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
a corresponding results file per samples file. For example for the
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

Each time you run one ore more samples file the corresponding results files will
be overwritten (or generated if not yet existent) with the actual result values
of your samples. The determination of changes between the results of actual and
older runs of the samples is done by your SCM. So the sample files and their
corresponding results files should be taken under version control.


## Configuration and Plugins

You can adapt the behaviour of regtest with plugins. To configure this and
maybe other things regtest support a simple rc file mechanism. While loading
regtest via `require 'regtest'` it looks for a file `.regtestrc` first in your
home directory and then in the local directory. So you can do global
configurations in the first one and project specific configurations in the
latter.

For example the following is a good default when you want colorized output and
use git as your SCM:

```ruby
require 'regtest/colorize'
# adapt some colorizing if wanted
Regtest::Colorize.mapping[:filename] = :blue
Regtest::Colorize.mapping[:statistics] = {mode: :italic}

require 'regtest/git'
```

Normally the check of changes in results is done automatically by a regtest
plugin like regtest/git (see example for `.regtestrc` above). In this case the
report will show you if there are changes or not and the exit code of the
script is accordingly set. The standard values are: 0 for success, 1 for an
unknown result (normally a new results file) and 2 for failure. If you use
plain regtest without a SCM plugin the exit code is 1 (= unknown result).

You can change the exit codes for the states with `Regtest.exit_codes` for example:

```ruby
Regtest.exit_codes[:unknown_result] = 0 
Regtest.exit_codes[:fail] = 0 
```

This also should be don in a `.regtest` file and not in the sample files.

Because in a `.regtestrc` file are individual configuration aspects of your
workflow and environment it should not be checked into your SCM.


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
