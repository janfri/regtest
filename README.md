# Regtest - Simple Regression Testing For Ruby Projects

## Description

This library support a very simple way to do regression testing in Ruby projects.
I am using it for integration testing of my projects
[mini_exiftool](https://github.com/janfri/mini_exiftool/tree/master/regtest)
and [multi_exiftool](https://github.com/janfri/multi_exiftool-redesign/tree/master/regtest)
to check if exiftool itself returns different values or
new tags in newer versions.

## Installation

Installing the gem with

    gem install regtest

or put a copy of regtest.rb in your project.

## Using

The idea behind regtest is the following workflow:
  1. Writing samples
  2. Running samples
  3. Checking results (differences between the actual results and the
  results of a previous run of your samples)

### Writing Samples

A samples file is a simple Ruby script with one ore more samples,
for example

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

The name of the sample (parameter of the `Regtest.sample` method)
and the results of the samples (return value of the block) are stored
in YAML format. So it should be a YAML friendly value as String,
Number, boolean value, Symbol.
Results could also be an Array or Hash with such values.

You can also include Regtest to have the sample method at
top level.

    require 'regtest'
    include Regtest

    sample :x do
      :x
    end

By convention sample files are stored in a directory `regtest`
in your Ruby application.


### Running Samples

Wether you run your examples manually

    ruby -I lib regtest/*.rb

or using the Rake task of regtest:
Add the line

    require 'regtest/task'

to your Rakefile and you can run your samples with `rake regtest`.

### Checking Results

The results of each samples file are stored as a collection of
YAML documents in a corresponding results file (YAML) per samples
file.
For example for the samples files

    regtest/foo.rb
    regtest/bar.rb

are the corresponding results files

    regtest/foo.yml
    regtest/bar.yml

So the content of the results file of the example above is

    ---
    sample: String result
    result: some text
    ---
    sample: Division by zero
    exception: divided by 0

Each time you run one ore more samples file the corresponding
results file will be overwritten (or generated if not yet
existend) with the actual result values of your samples.
So source code version control programm is the tool to determine
changes between older runs of the samples.
Therefore the samples file and their corresponding results files
should be taken under version control.

## Source Code

The code is hosted on [github](https://github.com/janfri/regtest) and
[gitorious](https://gitorious.org/regtest).
Change it to your needs. Release a fork. It is open source.

## Author

Jan Friedrich <janfri26@gmail.com>

## License

Regtest is licensed under the same terms as Ruby itself.
