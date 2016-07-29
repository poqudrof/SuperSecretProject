def create
  @client = OSC::Client.new('localhost', 4557)
  code = 'play 50' # or whatever you want
  @message = OSC::Message.new('/run-code', 'SONIC_PI', code)
  @client.send(@message)
end

def update
end


def apply
end
