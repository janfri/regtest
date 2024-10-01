# Regtest - Simple Regression Testing With Ruby

## Description

This library supports a very simple way to do regression testing with Ruby. It
is not limited to Ruby projects; you can use it also in other contexts where
you can extract data with Ruby.

The core idea is to test results against the results of an earlier run of the
tests, not against defined results of a specification.

You write Ruby scripts with samples. Run these and get the sample results as
result files beside your scripts. Check both the scripts and the result files
in your Source Code Management System (SCM). When you run the scripts on a
later (or even previous) version of your code, a simple diff will show you if
and how the changes in your code or environment impact the results of your
samples.

This is not a replacement for unit testing but a complement: You can produce a
lot of samples with a small amount of Ruby code (e.g., a large number of
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
  3. Committing samples and result files to SCM
  4. Changing code and/or external environment
  5. Rerunning the samples
  6. Checking sample results for changes (this is normally automatically done with
     a regtest plugin like regtest/git)
  7. If there are changed that are indented (new samples, corrected behavior)
     committing the files to the SCM - if there are unintended changes, fix the
     causes


### Writing Samples

A samples file is a simple Ruby script with one or more samples. Let's see an example

```ruby
require 'regtest'

Regtest.sample 'String result' do
  # Doing something to get the result of the sample
  # and ensure it is the result of the block
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
`Symbol`. Also `arrays` and `hashes` are commonly used.

In some cases you want to generate a lot of combinations of input data in your
sample code. For this there is a method `Regtest.combinations` to generate a
lot of combinations in an easy way. An example:

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

See also the example `combinations` in directory `regtest` of this repository.

By convention samples files are stored in a directory names `regtest` in your
Ruby application.


### Running Samples

Whether you run your examples manually

```sh
ruby -I lib regtest/*.rb
```

or using the Rake task of regtest by adding

```ruby
require 'regtest/task'
```

to your `Rakefile`. Then you can run your samples with `rake regtest`.


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

So the content of the results file of the first example above is

```yaml
---
sample: String result
result: some text
---
sample: Division by zero
exception: divided by 0
```

Each time you run one or more samples files, the corresponding results files
will be overwritten (or generated if they do not yet exist) with the actual
results values of your samples. The determination of changes between the
results of actual and older runs of the samples is done by your SCM. Therefore
the sample files and their corresponding results files should be taken under
version control.


## Logging

The key idea behind regtest is to produce values that are invariant and check
if this assumption is true at another (mostly later) state of code. But often
there are temporary or specific values which change or could change at each
run of regtest. This could be, for example, an id of a created record or the
version of a used external service or some time-relevant values. Sometimes it
is useful, to know the actual values of some of these.

In such cases the method `Regtest.log` could be handy. It writes a line of the
given object to a log file which is named with the same name as the calling
Ruby script but has the extension `.log`. It could be called inside as well as
outside of a regtest sample. As default this file is overwritten by the first
call of `Regtest.log` of each run of regtest and per file. And each further
call of `Regtest.log` appends then to the file.  So you get a complete log for
each run. This behavior could be changed with the `mode` keyword argument of
the method. Let's see an example:

```ruby
Regtest.log RUBY_VERSION

def create_record **values
  # do stuff to create the record and return the id of the generated record
end

def delete_record id
  # delete an existing record or raise an exception if record with id doesn't
  # exists
end

Regtest.sample 'create a record and delete it' do
  id = create_record language: 'Ruby', creator: 'Matz'
  Regtest.log "generated record with id #{id}"
  delete_record id
  # the generated id should not be part of the result, because it changes every
  # time you create a new record
  'Record created and deleted'
end

Regtest.sample 'try to delete a non existing record' do
  delete_record -1
end
```

If you want to have a log that is not truncated at each run of regtest, you can
use `mode: 'a'` at the first call of `Regtest.log` in the corresponding
ruby script.

```ruby
# ...
# the first call of Regtest.log in this Ruby file
Regtest.log Time.now, mode: 'a'
```

On the other hand, you can use `mode: 'w'` to truncate the log file even at a
later call of `Regtest.log`.

```ruby
max_time = 0
ary.each do |e|
  t = get_time_to_do_some_stuff
  if t > max_time
    max_time = t
    Regtest.log max_time, mode: 'w'
    # the content of the corresponding log file is now one line with max_time
  end
end
```

Because the log files contain only temporary information, they should normally
not be checked into the SCM.


## Configuration and Plugins

You can adapt the behavior of regtest with plugins. To configure this and maybe
other things regtest supports a simple rc file mechanism. While loading regtest
via `require 'regtest'` it looks for a file `.regtestrc` first in your home
directory and then in the local directory. So you can do global configurations
in the first one and project-specific configurations in the latter.

Normally, the check of changes in results is done automatically by a regtest
plugin like regtest/git (see below). In this case, the report will show you if
there are changes or not, and the exit code of the script is accordingly set.
The standard values are: `0` for success, `1` for an unknown result (normally a
new results file), and `2` for failure. If you use plain regtest without a SCM
plugin, the exit code is `1` (= unknown result).

You can change the exit codes for the states with `Regtest.exit_codes`. The
following example changes the behavior to the same as in regtest version 1.x.

```ruby
Regtest.exit_codes[:unknown_result] = 0
Regtest.exit_codes[:fail] = 0
```

This should be done in a `.regtestrc` file and not in sample files.

Because in a `.regtestrc` file are individual configuration aspects of your
workflow and environment, it should not be checked into your SCM.


### Plugin regtest/colors

When using the regtest/colors plugin (`require 'regtest/colors'`) it is
possible to adapt the colors of the output of different types of messages. The
following mappings are possible:

* `:filename`
* `:statistics`
* `:success`
* `:unknown_result`
* `:fail`

The configuration is done as the following example shows:

```ruby
require 'regtest/colors'
# adapt some colorizing if wanted
Regtest::Colors.mapping[:filename] = :cyan
Regtest::Colors.mapping[:statistics] = %i(blue italic)
Regtest::Colors.mapping[:fail] = %i(white @red)
```

As you can see there are colors and modifiers (such as `[:blue, :italic]`)
possible. Color codes with prefix `@` are background colors. Run
`Regtest::Colors.codes` to get a list of possible color codes.


### Plugin regtest/git

If you use the git plugin (`require 'regtest/git'`), there are the following
options available:

* `Regtest::Git.C`
* `Regtest::Git.git_dir`
* `Regtest::Git.work_tree`

which corresponds to the git parameters `-C`, `--git-dir` and `--work-tree`.
These could be helpful if you run `regtest` from inside some other git
repository than your regtest files. Have a look at the git documentation for
more details.

Be aware when using these options. It is possible to get unwanted results.

As said above: this should also be done in a local `.regtestrc` file.


### Example of a .regtestrc file

The following is a good default when you want colorized output and
use git as your SCM:

```ruby
require 'regtest/colors'
require 'regtest/git'
```

See above for more information about the plugins `regtest/colors` and
`regtest/git`.


## Rake task

Regtest includes a Rake task `regtest`. By default it runs any `.rb` files
under the `regtest` directory and includes all files under the `regtest`
directory to the files packaged with gem.  You can change these defaults like
this:

```ruby
require 'regtest/task'

REGTEST_FILES_RB.clear << 'my_regtest_file.rb'
REGTEST_FILES.clear << 'my_regtest_file.rb' << 'my_regtest_file.yml' << 'other_file'
```

It's a little bit old school like `CLEAN` and `CLOBBER` in `rake/clean` but I
like the simple approach to use constants.


## Best practise

### Use Ruby

As said above, the sample files are plain Ruby scripts. Yes, Ruby is a
scripting language. So use the power of Ruby to get the things done you need.
Some food for thought:

* Generate samples inside of loops.
* Use `String#gsub` to level out runtime specific values. For example, if you
get a response of a web service "Record 4711 created" and do a
`sub(/\d+/, '#')` the `4711` is eliminated and the string is invariant between
different runs of regtest.
* Use compare operators to get invariant values for sample results.


### Know your SCM

I use git as SCM for my work. Here are some hints how I check changes in the
results files:

```shell
git diff --ignore-all-space -- regtest/*.yml
git diff --color-words --ignore-all-space -- regtest/*.yml
git diff --color-words=. --ignore-all-space
git diff --color-words=\\w+ --ignore-all-space
git diff --color-moved
```


### Unexpected exceptions

If there is an exception raised inside a regtest sample its message is a part
of the result of the sample. This is intentional because exceptions are
possible results you want to check.

But sometimes an exception occur inside of a sample that was not the intention
of the sample code. In such situation it would be helpful to have the full
exception message with the backtrace, to find the code location where the error
occurred.

You can do this with setting `Regtest.show_exceptions = true` Then the
exception and backtrace is written to STDERR.

Example

```Ruby
Regtest.sample 'something' do
  # ...
end

Regtest.sample 'something goes wrong' do
  Regtest.show_exceptions = true
  # the code that causes the problem
  Regtest.show_exceptions = false
end

Regtest.sample 'another thing' do
  # ...
end
```

Alternatively the use of the Ruby debugger (`require 'debug'`) could be helpful (Know Ruby):

```ruby
Regtest.sample 'something' do
  # ...
end

Regtest.sample 'something goes wrong' do
  IRB.debugger
  # the code that causes the problem
end

Regtest.sample 'another thing' do
  # ...
end
```


### Regtest is not thread safe

The methods `Regtest.sample` and `Regtest.log` are not thread safe. So you have
to ensure they are executed in a sequential order to avoid unexpected results.


## Further information

I use `regtest` in my project [scripref](https://github.com/janfri/scripref) to
generate a lot of malformed input data to check regressions in the behavior of
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


## Versioning

Regtest follows [Semantic Versioning](https://semver.org/), both SemVer and
SemVerTag.


## Author

Jan Friedrich <janfri26@gmail.com>

## License

Regtest is licensed under the same terms as Ruby itself.
