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
