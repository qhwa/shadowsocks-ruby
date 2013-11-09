module Shadowsocks
  class Connection < EventMachine::Connection
    BackpressureLevel = 2097152 # 2m

    attr_accessor :crypto

    private

    def encrypt(buf)
      crypto.encrypt(buf)
    end

    def decrypt(buf)
      crypto.decrypt(buf)
    end

    def over_pressure?
      remote.get_outbound_data_size > BackpressureLevel
    end

    def outbound_checker
      if over_pressure?
        pause unless paused?
        EM.add_timer(1) { outbound_checker }
      else
        resume if paused?
      end
    end
  end
end
