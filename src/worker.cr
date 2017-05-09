require "./worker/*"

module Worker
  class Unit(T, R)
    # The running fiber on this Unit
    @fiber : Fiber?

    # Channel used to send data in and out of this unit
    @channel : Channel({T, R?, Exception?})

    # Whether this unit is running or not
    getter running = false

    def initialize(@channel, &block : T -> R?)
      @block = block
    end

    def run!
      return if running
      @running = true

      @fiber = spawn do
        loop do
          input = @channel.receive

          begin
            output = @block.call input[0].as(T)
            @channel.send({input[0], output, nil})
          rescue ex
            @channel.send({input[0], nil, ex})
          end
        end
      end
    end

    def send(obj : T)
      @channel.send({State::Ok, obj, nil})
    end
  end

  # Class for managing a pool of units.
  class Pool(T, R)
    # The template unit for this pool.
    @unit : Unit(T, R)

    # The instanced units working for this pool
    @units = [] of Unit(T, R)

    # The channel used to communicate to units in this pool
    @channel = Channel({T, R?, Exception?}).new

    # Instances a new Pool with `count` to perform action `&block`.
    # All units will be ran unless `run` is false.
    def initialize(count : Int32, run : Bool = true, &block : T -> R?)
      @unit = Unit(T, R).new(@channel, &block)

      count.times { add_unit }

      self.run! if run
    end

    # Adds a Unit to this Pool.
    # A Unit can be provided, however by default it will use the "tempalte" unit stored in @unit.
    def add_unit(unit : Unit? = nil)
      new_unit = unit || @unit.dup
      @units << new_unit
    end

    # Starts all Units within this pool.
    def run!
      @units.map &.run!
    end

    # Send something to the Unit pool.
    def send(obj : T)
      @channel.send({obj, nil, nil})
    end

    # Block until something is received from the pool.
    def receive
      @channel.receive
    end

    # Helper method for sending something, and then immediately blocking until a result is returned.
    def handle(obj : T)
      future do
        send obj
        receive
      end
    end

    # Stops all units in the pool.
    def stop!
       # @units.size.times { @channel.send({State::Stop, nil, nil}) }
    end
  end
end
