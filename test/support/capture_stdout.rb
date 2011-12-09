require 'stringio'
 
module Kernel
 
  def capture_stdout
    out = StringIO.new
    $stdout = out
    yield
    return out.string.sub(/\n$/, '')
  ensure
    $stdout = STDOUT
  end
 
end
