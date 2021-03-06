require 'etc'
require 'ostruct'
require 'rbconfig'
require_relative 'psutil_error'
require_relative 'common'

os = RbConfig::CONFIG['host_os']
case os
  when PosixPsutil::COMMON::NON_LINUX_PLATFORM
    require_relative 'posix/process'
    # some modules in system.rb, like Memory, are in need, so require them here
    require_relative 'posix/system'
  when PosixPsutil::COMMON::LINUX_PLATFORM
    require_relative 'linux/process'
    require_relative 'linux/system'
  else
    raise RuntimeError, "unsupported os: #{os.inspect}"
end


module PosixPsutil

# Warning: There is already a Process module in ruby, so don't confuse it with 
# this PosixPsutil::Process. And take care of `include PosixPsutil`, unless you 
# have clearly considered about it.
class Process
  # Represents an OS process with the given PID.
  # If PID is omitted current process PID (Process.pid) is used.
  # Raise NoSuchProcess if PID does not exist.
  #
  # Note that most of the methods of this class do not make sure
  # the PID of the process being queried has been reused over time.
  # That means you might end up retrieving an information referring
  # to another process in case the original one this instance
  # refers to is gone in the meantime.
  #
  # The only exceptions for which process identity is pre-emptively
  # checked and guaranteed are:
  #
  #  - parent()
  #  - children()
  #  - nice() (set)
  #  - ionice() (set)
  #  - rlimit() (set)
  #  - cpu_affinity (set)
  #  - suspend()
  #  - resume()
  #  - send_signal()
  #  - terminate()
  #  - kill()
  #
  # To prevent this problem for all other methods you can:
  #   - use is_running() before querying the process
  #   - if you're continuously iterating over a set of Process
  #     instances use process_iter() or processes() which pre-emptively checks
  #     process identity for every instance
  include POSIX

  attr_reader :identity
  attr_reader :pid

  # class methods

  # Return an Array of current running PIDs.
  def self.pids
    PlatformSpecificProcess.pids()
  end

  # Return true if given PID exists in the current process list.
  # This is faster than doing "pid in psutil.pids()" and
  # should be preferred.
  def self.pid_exists(pid)
    POSIX::pid_exists(pid)
  end

  @@pmap = {}

  # Return all Process instances for all
  # running processes.
  #
  # Every new Process instance is only created once and then cached
  # into an internal table which is updated every time this is used.
  #
  # Cached Process instances are checked for identity so that you're
  # safe in case a PID has been reused by another process, in which
  # case the cached instance is updated.
  #
  def self.processes
    pre_pids = @@pmap.keys
    cur_pids = pids()
    gone_pids = pre_pids - cur_pids
    
    gone_pids.each { |pid| @@pmap.delete(pid) }
    cur_pids.each do |pid|
      begin
        unless @@pmap.key?(pid) && @@pmap[pid].is_running
          p = Process.new(pid)
          @@pmap[p.pid] = p
        end
      rescue NoSuchProcess
        @@pmap.delete(pid)
      rescue AccessDenied
        # Process creation time can't be determined hence there's
        # no way to tell whether the pid of the cached process
        next
      end
    end
    @@pmap.values
  end

  # Like self.processes(), but return next Process instance in each iteration.
  # To imitate Python's iterator, use Enumerator to implement this method, which
  # means it will raise StopIteration when it reaches the end.
  def self.process_iter
    processes = []
    pids().each do |pid|
      begin
        unless @@pmap.key?(pid) && @@pmap[pid].is_running
          p = Process.new(pid)
          @@pmap[p.pid] = p
        end
        processes.push @@pmap[pid]
      rescue NoSuchProcess
        @@pmap.delete(pid)
      rescue AccessDenied
        next
      end
    end
    processes.to_enum
  end
  
  # instance methods

  # initialize a Process instance with pid, 
  # if not pid given, initialize it with current process's pid.
  def initialize(pid=nil)
    pid = ::Process.pid unless pid
    @pid = pid
    raise ArgumentError.new("pid must be 
                            a positive integer (got #{@pid})") if @pid <= 0
    @name = nil
    @exe = nil
    @create_time = nil 
    @gone = false
    @proc = PlatformSpecificProcess.new(@pid)
    # for cpu_percent
    @last_sys_cpu_times = nil
    @last_proc_cpu_times = nil
    begin
      create_time
    rescue AccessDenied
      # we should never get here as AFAIK we're able to get
      # process creation time on all platforms even as a
      # limited user
    rescue NoSuchProcess
      msg = "no process found with pid #{@pid}"
      raise NoSuchProcess.new(pid:@pid, msg:msg)
    end
    # This part is supposed to indentify a Process instance
    # univocally over time (the PID alone is not enough as
    # it might refer to a process whose PID has been reused).
    # This will be used later in == and is_running().
    @identity = [@pid, @create_time]
  end

  # Return description of Process instance.
  def to_s
    begin
      return "(pid=#{@pid}, name=#{name()})"
    rescue NoSuchProcess
      return "(pid=#{@pid} (terminated))"
    rescue AccessDenied
      return "(pid=#{@pid})"
    end
  end

  # Return a printable version of Process instance's description.
  def inspect
    self.to_s.inspect
  end

  # Test for equality with another Process object based
  # on PID and creation time.
  def ==(other)
    return self.class == other.class && @identity == other.identity
  end
  alias_method :eql?, :==

  def !=(other)
    return !(self == other)
  end

  # utility methods
  
  # Utility method returning process information as a hash.
  # Unlike normal to_hash method, this method can accept two params,
  # given_attrs and default
  #
  # If 'given_attrs' is specified it must be a list of symbols
  # reflecting available Process class' attribute names
  # (e.g. [:cpu_times, :name]) else all public (read
  # only) attributes are assumed.

  # 'default' is the value which gets assigned in case
  # AccessDenied  exception is raised when retrieving that
  # particular process information.
  def to_hash(given_attrs = nil, default = {})
    # psutil defines some excluded methods, they won't be accessed via
    # this method.
    #
    # psutil want to warn us that the process with given pid may gone,
    # as the comment at the head of the class says.
    excluded_names = [
      :identity, :to_s, :inspect, :==, :eql?, :!=, :to_hash, :parent, 
      :is_running, :children, :rlimit, :send_signal, :kill, :terminate, 
      :resume, :suspend, :wait
    ]


    respond_to_methods = self.public_methods(false)
    included_names = respond_to_methods - excluded_names
    ret = {}
    attrs = (given_attrs ? given_attrs : included_names)
    attrs.each do |attr|
      next if !attr.is_a?(Symbol) || attr.to_s.end_with?('=')
      begin
        # filter unsafe methods
        if respond_to_methods.include?(attr)
          ret[attr] = method(attr).call()
        else
          # in case of not implemented functionality (may happen
          # on old or exotic systems) we want to crash only if
          # the user explicitly asked for that particular attr
          raise NotImplementedError if given_attrs
          ret[attr] = default[attr] if default.key? attr
        end
      rescue AccessDenied
        ret[attr] = default[attr] if default.key? attr
      end
    end
    ret
  end

  # Return the parent process as a Process object pre-emptively
  # checking whether PID has been reused.
  # If no parent is known return nil.
  def parent
    ppid = ppid()
    if ppid 
      begin
        parent = Process.new ppid
        return parent if parent.create_time() <= create_time()
      rescue NoSuchProcess
        # ignore ...
      end
    end
    return nil
  end

  # Return if this process is running.
  # It also checks if PID has been reused by another process in
  # which case return false.
  def is_running
    return false if @gone
    begin
      return self == Process.new(@pid)
    rescue NoSuchProcess
      @gone = true
      return false
    end
  end

  # actual API

  # Return the parent pid of the process.
  def ppid
    @proc.ppid
  end

  # The process name. The return value is cached after first call.
  def name
    unless @name
      @name = @proc.name()
      if @name.length >= 15
        begin
          # return an Array represented cmdline arguments( may be [] )
          cmdline = cmdline()
        rescue AccessDenied
          cmdline = []
        end
        if cmdline != []
          extended_name = File.basename(cmdline[0])
          @name = extended_name if extended_name.start_with?(@name)
        end
      end
    end
    @name
  end

  # The process executable as an absolute path.
  # May also be an empty string.
  # The return value is cached after first call.
  def exe
    if !@exe
      begin
        @exe = @proc.exe()
      rescue AccessDenied => e
        @exe = ''
        fallback = e
      end

      if @exe == ''
        cmdline = self.cmdline()
        if cmdline
          exe = cmdline[0] 
          if File.exists?(exe) && File.realpath == exe \
            && File.stat(exe).executable?
            @exe = exe 
          end
        else
          raise fallback if fallback
        end
      end
    end
    @exe
  end

  # The command line this process has been called with.
  # An array will be returned
  def cmdline
    @proc.cmdline()
  end

  # The process current status as a STATUS_* constant.
  def status
    @proc.status()
  end
  
  # The name of the user that owns the process.
  def username
    real_uid = uids[:real]
    begin
      return Etc::getpwuid(real_uid).name
    rescue ArgumentError
      return real_uid.to_s
    end
  end

  # Return a #<OpenStruct user, system> representing the
  # accumulated process time, in seconds.
  def cpu_times
    @proc.cpu_times
  end

  # The process creation time as a floating point number
  # expressed in seconds since the epoch, in UTC.
  # The return value is cached after first call.
  def create_time
    if @create_time.nil?
      @create_time = @proc.create_time
    end
    @create_time
  end

  # Return the wall time cost by process, measured in seconds
  def time_used
    @proc.time_used
  end

  # Process current working directory as an absolute path.
  def cwd
    @proc.cwd
  end
  
  # Get process niceness (priority).
  def nice
    @proc.nice
  end

  # Set process niceness.
  # Niceness values range from -20 (most favorable to the process) to 19 
  # (least favorable to the process) on Linux.
  def nice=(value)
    raise NoSuchProcess.new(pid:@pid) unless is_running()
    # valid niceness range is system dependency, 
    # so let each platform specific implemention handle the input
    @proc.nice = value 
  end

  # Return process UIDs as #<OpenStruct real, effective, saved>
  def uids
    @proc.uids
  end

  # Return process GIDs as #<OpenStruct real, effective, saved>
  def gids
    @proc.gids
  end

  # The terminal associated with this process, if any, else nil.
  def terminal
    @proc.terminal
  end

  # Return the number of file descriptors opened by this process
  def num_fds
    @proc.num_fds
  end

  # Waiting until process does not existed any more. 
  # Raise Timeout::Error if time out while waiting.
  def wait(timeout = nil)
    if timeout && timeout < 0
      raise ArgumentError.new("timeout must be a positive integer") 
    end
    return wait_pid(@pid, timeout)
    # maybe raise Timeout::Error, need not to convert it currently
    #rescue Timeout::Error
  end

  if PlatformSpecificProcess.method_defined? :io_counters
    # Linux, BSD only
    #
    # Return process I/O statistics as a
    # #<OpenStruct read_count, write_count, read_bytes, write_bytes>
    #
    # Those are the number of read/write calls performed and the
    # amount of bytes read and written by the process.
    def io_counters
      @proc.io_counters
    end
  end

  if PlatformSpecificProcess.method_defined?(:ionice) \
    && PlatformSpecificProcess.method_defined?(:set_ionice)
    # Linux only
    #
    # Get or set process I/O niceness (priority).
    #
    # On Linux 'ioclass' is one of the IOPRIO_CLASS_* constants.
    # 'value' is a number which goes from 0 to 7. The higher the
    # value, the lower the I/O priority of the process.
    # `man ionice` for further info
    # 
    # You can use symbols or CONSTANTS as ioclass argument.
    # For example, `p.ioclass(:be, 4)` or 
    # `p.ioclass(PosixPsutil::IOPRIO_CLASS_BE, 4)`
    # 
    # * IOPRIO_CLASS_NONE :none => 0
    # * IOPRIO_CLASS_RT :rt => 1
    # * IOPRIO_CLASS_BE :be => 2
    # * IOPRIO_CLASS_IDLE :idle => 3
    def ionice(ioclass=nil, value=nil)
      if ioclass.nil? 
        raise ArgumentError.new("'ioclass' must be specified") if value
        return @proc.ionice
      else
        # If the value is nil, a reasonable value will be assigned
        return @proc.set_ionice(ioclass, value)
      end
    end
  end

  # Linux only
  if PlatformSpecificProcess.method_defined? :rlimit
    # Get or set process resource limits as a {:soft, :hard} Hash.
    #
    # 'resource' is one of the RLIMIT_* constants.
    # Unlike other API, 'limits' is supposed to be a {:soft, :hard} Hash,
    # instead of an OpenStruct. Since using Hash as input is more common 
    # than using OpenStruct (and more handy, too).
    #
    # `man prlimit` for further info.
    # And see bits/resource.h for the detail about resource.
    # 
    # You can use symbols or CONSTANTS as resource argument.
    # For example:
    # 
    #   limits = {:soft => 1024, :hard => 4096}
    #   p.rlimit(PosixPsutil::RLIMIT_NOFILE, limits)
    #   # or
    #   p.rlimit(:nofile, limits)
    #
    # * RLIMIT_CPU :cpu => 0
    # * RLIMIT_FSIZE :fsize => 1
    # * RLIMIT_DATA :data => 2
    # * RLIMIT_STACK :stack => 3
    # * RLIMIT_CORE :core => 4
    # * RLIMIT_RSS :rss => 5
    # * RLIMIT_NPROC :nproc => 6
    # * RLIMIT_NOFILE :nofile => 7
    # * RLIMIT_MEMLOCK :memlock => 8
    # * RLIMIT_AS :as => 9
    # * RLIMIT_LOCKS :locks => 10
    # * RLIMIT_SIGPENDING :sigpending => 11
    # * RLIMIT_MSGQUEUE :msgqueue => 12
    # * RLIMIT_NICE :nice => 13
    # * RLIMIT_RTPRIO :rtprio => 14
    # * RLIMIT_RTTIME :rttime => 15
    # * RLIMIT_NLIMITS :nlimits => 16
    def rlimit(resource, limits=nil)
        @proc.rlimit(resource, limits)
    end
  end

  # Linux only
  if PlatformSpecificProcess.method_defined?(:cpu_affinity)  \
    && PlatformSpecificProcess.method_defined?(:cpu_affinity=)
    # Get or set process CPU affinity.
    # If specified 'cpus' must be a list of CPUs for which you
    # want to set the affinity (e.g. [0, 1]).
    #
    # If 'cpus' is not an Array, an ArgumentError will be raised,
    # if the length of 'cpus' larger than the number of CPUs, 
    # the remain will be ignore.
    def cpu_affinity(cpus=nil)
      if cpus.nil?
        @proc.cpu_affinity
      elsif cpus.is_a?(Array)
        @proc.cpu_affinity=(cpus)
      else
        raise ArgumentError.new("cpus must be an Array, got #{cpus}")
      end
    end
  end

  # Return the number of voluntary and involuntary context
  # switches performed by this process.
  def num_ctx_switches
    @proc.num_ctx_switches
  end

  # Return the number of threads used by this process.
  def num_threads
    @proc.num_threads
  end

  # Return threads opened by process as a list of
  # #<OpenStruct id, user_time, system_time> representing
  # thread id and thread CPU times (user/system).
  def threads
    @proc.threads
  end

  # Return the children of this process as a list of Process
  # instances, pre-emptively checking whether PID has been reused.
  # If recursive is true return all the parent descendants.
  #
  # Example (A == this process):
  #
  #   A ─┐
  #      │
  #      ├─ B (child) ─┐
  #      │             └─ X (grandchild) ─┐
  #      │                                └─ Y (great grandchild)
  #      ├─ C (child)
  #      └─ D (child)
  #
  #   require 'posixpsutil'
  #
  #   p = PosixPsutil::Process.new(Process.pid)
  #   p.children()
  #   # B, C, D
  #   p.children(true)
  #   # B, X, Y, C, D
  #
  def children(recursive = false)
    ret = []
    if recursive
      # construct a hash where 'values'(an Array) are all the processes
      # having 'key' as their parent
      table = {}
      self.class.processes.each do |p|
        begin
          ppid = p.ppid
          (table.key? ppid)? table[ppid].push(p) : table[ppid] = [p]
        rescue NoSuchProcess
          next
        end
      end

      # At this point we have a mapping table where table[self.pid]
      # are the current process' children.
      # Below, we look for all descendants recursively, similarly
      # to a recursive function call.
      checkpids = [@pid]
      checkpids.each do |pid|
        next unless table.key? pid
        table[pid].each do |child|
          begin
            # if child happens to be older than its parent,
            # it means child's PID has been reused
            intime = (create_time() <= child.create_time())
          rescue NoSuchProcess
            next
          end
          if intime
            ret.push(child)
            checkpids.push(child.pid) unless checkpids.include?(child.pid)
          end
        end
      end

    else
      self.class.processes().each do |p|
        begin
          ret.push(p) if p.ppid == @pid && create_time() <= p.create_time()
        rescue NoSuchProcess
          next
        end
      end

    end

    ret
  end

  # Return a float representing the current process CPU
  # utilization as a percentage.
  #
  # When interval is <= 0.0 or nil (default) compares process times
  # to system CPU times elapsed since last call, returning
  # immediately (non-blocking). That means that the first time
  # this is called it will return a meaningful 0.0 value.
  #
  # When interval is > 0.0 compares process times to system CPU
  # times elapsed before and after the interval.
  #
  # In this case is recommended for accuracy that this function
  # be called with at least 0.1 seconds between calls.
  # 
  # Examples:
  #
  #   require 'posixpsutil'
  #
  #   p = PosixPsutil::Process.new(Process.pid)
  #   # blocking
  #   p.cpu_percent(1)
  #   # 2.0
  #
  #   # non-blocking (percentage since last call)
  #   p.cpu_percent
  #   # 2.9
  #   
  #   p = PosixPsutil::Process.new(4527)
  #   # first called
  #   p.cpu_percent
  #   # 0.0
  #
  #   # second called
  #   p.cpu_percent
  #   # 0.5
  # 
  def cpu_percent(interval = nil)
    blocking = (interval && interval > 0.0)
    num_cpus = CPU.cpu_count()
    timer = proc { Time.now.to_f * num_cpus }
    if blocking
      st1 = timer.call
      pt1 = @proc.cpu_times
      sleep interval
      st2 = timer.call
      pt2 = @proc.cpu_times
    else
      st1 = @last_sys_cpu_times
      pt1 = @last_proc_cpu_times
      st2 = timer.call
      pt2 = @proc.cpu_times
      # first called
      if st1.nil? || pt1.nil?
        @last_sys_cpu_times = st2
        @last_proc_cpu_times = pt2
        return 0.0
      end
    end

    delta_proc = (pt2.user - pt1.user) + (pt2.system - pt1.system)
    delta_time = st2 - st1
    # reset values for next call in case of interval == None
    @last_sys_cpu_times = st2
    @last_proc_cpu_times = pt2

    begin
      # The utilization split between all CPUs.
      # Note: a percentage > 100 is legitimate as it can result
      # from a process with multiple threads running on different
      # CPU cores, see:
      # http://stackoverflow.com/questions/1032357
      # https://github.com/giampaolo/psutil/issues/474
      overall_percent = ((delta_proc / delta_time) * 100) * num_cpus
      return overall_percent.round(1)
    rescue ZeroDivisionError
      # interval was too low
      return 0.0
    end
  end

  # Return an OpenStruct representing RSS (Resident Set Size) and VMS
  # (Virtual Memory Size) in bytes.
  def memory_info
    @proc.memory_info
  end

  # Return an OpenStruct with variable fields depending on the
  # platform representing extended memory information about
  # this process. All numbers are expressed in bytes.
  def memory_info_ex
    @proc.memory_info_ex
  end

  @@total_phymem = nil
  # Compare physical system memory to process resident memory
  # (RSS) and calculate process memory utilization as a percentage.
  def memory_percent
    rss = @proc.memory_info.rss
    @@total_phymem = Memory.virtual_memory.total if @@total_phymem.nil?
    begin
      return (rss / @@total_phymem.to_f * 100).round(2)
    rescue ZeroDivisionError
      return 0.0
    end
  end

  # Return process' mapped memory regions as a list of OpenStructs
  # whose fields are variable depending on the platform.
  #
  # If 'grouped' is true the mapped regions with the same 'path'
  # are grouped together and the different memory fields are summed.

  # If 'grouped' is false every mapped region is shown as a single
  # entity and the namedtuple will also include the mapped region's
  # address space ('addr') and permission set ('perms').
  def memory_maps(grouped = true)
    maps = @proc.memory_maps
    if grouped
      d = {}
      maps.each do |region|
        path = region[2]
        nums = region[3..-1]
        (d[path].nil? ) ? d[path] = nums : 
          d[path].each_index {|i| d[path][i] += nums[i]}
      end
      @proc.pmmap_grouped(d)
    else
      @proc.pmmap_ext(maps)
    end
  end

  # Return regular files opened by process as a list of
  # <#OpenStruct path, fd> including the absolute file name
  # and file descriptor number.
  def open_files
    @proc.open_files
  end

  # Return connections opened by process as a list of
  # #<OpenStruct fd, family, type, laddr, raddr, status>
  # The 'kind' parameter filters for connections that match the
  # following criteria:
  #
  # Kind Value      Connections using
  # :inet            IPv4 and IPv6
  # :inet4           IPv4
  # :inet6           IPv6
  # :tcp             TCP
  # :tcp4            TCP over IPv4
  # :tcp6            TCP over IPv6
  # :udp             UDP
  # :udp4            UDP over IPv4
  # :udp6            UDP over IPv6
  # :unix            UNIX socket (both UDP and TCP protocols)
  # :all             the sum of all the possible families and protocols
  def connections(interface = :inet)
    @proc.connections(interface)
  end
  
  # Send a signal to process pre-emptively checking whether
  # PID has been reused (see signal module constants) .
  # 
  # signal may be an integer signal number or a POSIX signal name 
  # (either with or without a SIG prefix). 
  # For example, 'SIGSTOP'/'STOP'/19 all means the signal SIGSTOP
  # 
  # According to Ruby doc, 
  # > If signal is negative (or starts with a minus sign), 
  # > kills process groups instead of processes
  # 
  # Currently I consider it as a feature and will not change this behaviour
  def send_signal(sig)
    begin
      # according to "man 2 kill" , PID 0 refers to 
      # 'every process in the process group of the calling process'
      # Luckily, @pid is >= 0
      ::Process.kill(sig, @pid)
    rescue Errno::ESRCH
      @gone = true
      raise NoSuchProcess(@pid, @name)
    rescue Errno::EPERM
      raise AccessDenied(@pid, @name)
    end
  end

  # Suspend process execution with SIGSTOP pre-emptively checking
  # whether PID has been reused.
  def suspend
    send_signal('STOP')
  end

  # Resume process execution with SIGCONT pre-emptively checking
  # whether PID has been reused.
  def resume
    send_signal('CONT')
  end

  # Terminate process execution with SIGTERM pre-emptively checking
  # whether PID has been reused.
  def terminate
    send_signal('TERM')
  end

  # Kill the current process with SIGKILL pre-emptively checking
  # whether PID has been reused.
  #
  # It is not an alias_method of send_signal
  def kill
    send_signal('KILL')
  end

  def self.assert_pid_not_reused(methods)
    methods.each do |method|
      old_method = instance_method(method)
      define_method method do |*args, &block|
        raise NoSuchProcess(pid: @pid) unless is_running
        old_method.bind(self).call(*args, &block)
      end
    end
  end
  private_class_method :assert_pid_not_reused

  assert_pid_not_reused [:children, :send_signal, :suspend, :resume, 
                         :terminate, :kill]

end
end
