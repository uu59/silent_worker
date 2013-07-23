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
    start
  end

  def <<(data)
    @queue.push(data)
  end

  def wait
    finish!
    @workers.times do
      @queue.push(FINISH_DATA)
    end
    @threads.each(&:join)
  end

  def abort
    @threads.each(&:kill)
    wait
  end

  def stop
    wait
  end

  def start
    @workers.times do
      @threads << Thread.start(@job, @queue) do |job, queue|
        loop do
          data = queue.pop
          break if @finished && data == FINISH_DATA
          job.call(data)
        end
      end
    end
  end

  private

  def finish!
    @finished = true
  end

end
