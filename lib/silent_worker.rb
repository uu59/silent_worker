require "thread"
require "silent_worker/version"

class SilentWorker
  attr_reader :job, :workers, :queue

  FINISH_DATA = "\x04" # EOT

  def initialize(workers = 8, &job)
    @job = job
    @workers = workers
    @threads = []
    @queue = Queue.new
    setup_signal_traps
    start
  end

  def <<(data)
    @queue.enq(data)
  end

  def wait
    finish!
    @threads.find_all(&:alive?).each(&:join)
  end

  def abort
    @threads.each(&:kill)
    wait
  end
  alias :stop! :abort

  def stop
    finish!
  end

  def start
    return if @working

    @working = true
    @finished = false
    @workers.times do |n|
      @threads << Thread.start(@job, @queue, n) do |job, queue, n|
        Thread.current[:num] = n
        loop do
          data = queue.deq
          break if @finished && data == FINISH_DATA
          job.call(data)
        end
      end
    end
  end

  private

  def finish!
    @working = false

    unless @finished
      @finished = true
      @workers.times do
        @queue.enq(FINISH_DATA)
      end
    end
  end

  def setup_signal_traps
    Signal.trap("INT") { abort }
    Signal.trap("TERM") { abort }
    Signal.trap("QUIT") { abort }

    # Maybe forgotten to call #wait
    Signal.trap("EXIT") do
      return if @finished
      warn "\nWARNING: You should call SilentWorker#wait to wait jobs are completed. Now abort them.\n"
      abort
    end
  end

end
