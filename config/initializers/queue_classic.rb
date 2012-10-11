ENV["DATABASE_URL"] = "postgres://#{PgTools.username}:#{PgTools.password}@#{PgTools.host}/#{PgTools.database}"

require 'queue_classic'

module QC
  TABLE_NAME='common.queue_classic_jobs'

  module Setup
    extend self

    def schema
      'common'
    end

    def set_schema
      Conn.execute("SET SEARCH_PATH TO #{schema}")
    end

    def create
      set_schema
      create_table
      create_functions
    end

    def drop
      set_schema
      drop_functions
      drop_table
    end

  end

end

module QC
  class Queue
    def initialize(name, notify=QC::LISTENING_WORKER)
      QC::Setup.set_schema
      @name = name
      @chan = @name if notify
    end
  end
end

module QC
  class Worker
    def initialize(*args)
      QC::Setup.set_schema

      if args.length == 5
        q_name, top_bound, fork_worker, listening_worker, max_attempts = *args
      elsif args.length <= 1
        opts = args.first || {}
        q_name           = opts[:q_name]           || QC::QUEUE
        top_bound        = opts[:top_bound]        || QC::TOP_BOUND
        fork_worker      = opts[:fork_worker]      || QC::FORK_WORKER
        listening_worker = opts[:listening_worker] || QC::LISTENING_WORKER
        max_attempts     = opts[:max_attempts]     || QC::MAX_LOCK_ATTEMPTS
      else
        raise ArgumentError, 'wrong number of arguments (expected no args, an options hash, or 5 separate args)'
      end

      @running = true
      @queue = Queue.new(q_name, listening_worker)
      @top_bound = top_bound
      @fork_worker = fork_worker
      @listening_worker = listening_worker
      @max_attempts = max_attempts
      handle_signals

      log(
        :level => :debug,
        :action => "worker_initialized",
        :queue => q_name,
        :top_bound => top_bound,
        :fork_worker => fork_worker,
        :listening_worker => listening_worker,
        :max_attempts => max_attempts
      )
    end
  end
end
