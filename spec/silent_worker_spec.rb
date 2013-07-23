# -- coding: utf-8

require "spec_helper"

describe SilentWorker do
  describe "#new" do
    it "invoke #start" do
      SilentWorker.any_instance.should_receive(:start)
      SilentWorker.new {|data| data }
    end
  end

  describe "#<<" do
    it "given arg pass to job" do
      data = 42
      job = proc {|given| given.should == data}
      sw = SilentWorker.new(&job)
      sw << data
      sw.wait
    end
  end

  describe "#wait" do
    it "worker threads exit after jobs completed" do
      sw = SilentWorker.new {|data| data } 
      expect{ Thread.list.length > sw.workers }.to be_true
      sw.wait
      expect{ Thread.list.length < sw.workers }.to be_true
    end
  end

  describe "#abort" do
    it "kill the worker threads" do
      sleeping = 10
      start = Time.now
      sw = SilentWorker.new {|data| sleep sleeping }
      sw << 1
      sw.abort
      expect{ Time.now - start < sleeping }.to be_true
    end
  end

  describe "#stop and #start" do
    let(:sw) { SilentWorker.new {|data| data } }

    after { sw.abort }

    it "jobs won't be fired when stopping workers" do
      sw << 1
      sw.stop
      sw << 2
      sw.queue.pop.should == 2
    end

    it "resume works when #start called" do
      sw = SilentWorker.new {|data| data }
      sw << 1
      sw.stop
      sw << 2
      sw.queue.length.should == 1
      sw.start
      sw.wait
      sw.queue.length.should == 0
    end
  end
end
