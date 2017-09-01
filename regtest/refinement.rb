# encoding: utf-8
# frozen_string_literal: true

require 'regtest'

# It is also possible to use Regtest as refinement.
# This approach is prefered over including Regtest.
using Regtest

# Now sample and combinations are top level methods.
# in this Ruby script
sample 'Refinement works' do
  # The sample is executed but the sample method is not
  # an official member of self.
  !self.respond_to?(:sample)
end
