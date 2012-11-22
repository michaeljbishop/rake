require File.expand_path('../helper', __FILE__)
require 'rake/thread_pool'
require 'test/unit/assertions'

class TestRakeTestThreadPool < Rake::TestCase
  include Rake

  def test_pool_executes_in_current_thread_for_zero_threads
    pool = ThreadPool.new(0)
    f = nil
    pool.start{f = Thread.current}
    pool.join
    assert_equal Thread.current, f
  end

  def test_pool_executes_in_other_thread_for_pool_of_size_one
    pool = ThreadPool.new(1)
    f = nil
    pool.start{f = Thread.current}
    pool.join
    refute_equal Thread.current, f
  end

  def test_pool_creates_the_correct_number_of_threads
    pool = ThreadPool.new(2)
    threads = Set.new
    t_mutex = Mutex.new
    10.times.each do
      pool.start do
        sleep 0.02
        t_mutex.synchronize{ threads << Thread.current }
      end
    end
    pool.join
    assert_equal 2, threads.count
  end

  def test_pool_join_empties_queue
    pool = ThreadPool.new(2)
    repeat = 25
    repeat.times {
      pool.start do
        repeat.times {
          pool.start do
            repeat.times {
              pool.start do end
            }
          end
        }
      end
    }

    pool.join
    assert_equal true, pool.__send__(:__queue__).empty?, "queue should be empty"
  end

  # test that throwing an exception way down in the blocks propagates
  # to the top
  def test_exceptions
    pool = ThreadPool.new(10)

    deep_exception_block = lambda do |count|
      raise "BAM!!" if ( count < 1 )
      pool.start(count-1,&deep_exception_block)
    end

    assert_raises(RuntimeError) do
      pool.start(5,&deep_exception_block)
      pool.join
    end

  end

end
