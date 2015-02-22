var search_data = {"index":{"searchIndex":["posixpsutil","accessdenied","common","cpu","disks","memory","network","nosuchprocess","process","psutilerror","system","rbconfig","!=()","==()","boot_time()","calculate_cpu_percent_field()","children()","cmdline()","connections()","cpu_affinity()","cpu_count()","cpu_percent()","cpu_percent()","cpu_times()","cpu_times()","cpu_times_percent()","create_time()","cwd()","disk_io_counters()","disk_partitions()","disk_usage()","eql?()","exe()","gids()","inspect()","io_counters()","ionice()","is_running()","kill()","memory_info()","memory_info_ex()","memory_maps()","memory_percent()","name()","net_connections()","net_io_counters()","new()","new()","new()","nice()","nice=()","num_ctx_switches()","num_fds()","num_threads()","open_files()","parent()","pid_exists()","pids()","ppid()","process_iter()","processes()","resume()","rlimit()","send_signal()","status()","suspend()","swap_memory()","terminal()","terminate()","threads()","time_used()","to_hash()","to_s()","to_s()","uids()","username()","users()","virtual_memory()","wait()"],"longSearchIndex":["posixpsutil","posixpsutil::accessdenied","posixpsutil::common","posixpsutil::cpu","posixpsutil::disks","posixpsutil::memory","posixpsutil::network","posixpsutil::nosuchprocess","posixpsutil::process","posixpsutil::psutilerror","posixpsutil::system","rbconfig","posixpsutil::process#!=()","posixpsutil::process#==()","posixpsutil::system::boot_time()","posixpsutil::cpu::calculate_cpu_percent_field()","posixpsutil::process#children()","posixpsutil::process#cmdline()","posixpsutil::process#connections()","posixpsutil::process#cpu_affinity()","posixpsutil::cpu::cpu_count()","posixpsutil::cpu::cpu_percent()","posixpsutil::process#cpu_percent()","posixpsutil::cpu::cpu_times()","posixpsutil::process#cpu_times()","posixpsutil::cpu::cpu_times_percent()","posixpsutil::process#create_time()","posixpsutil::process#cwd()","posixpsutil::disks::disk_io_counters()","posixpsutil::disks::disk_partitions()","posixpsutil::disks::disk_usage()","posixpsutil::process#eql?()","posixpsutil::process#exe()","posixpsutil::process#gids()","posixpsutil::process#inspect()","posixpsutil::process#io_counters()","posixpsutil::process#ionice()","posixpsutil::process#is_running()","posixpsutil::process#kill()","posixpsutil::process#memory_info()","posixpsutil::process#memory_info_ex()","posixpsutil::process#memory_maps()","posixpsutil::process#memory_percent()","posixpsutil::process#name()","posixpsutil::network::net_connections()","posixpsutil::network::net_io_counters()","posixpsutil::accessdenied::new()","posixpsutil::nosuchprocess::new()","posixpsutil::process::new()","posixpsutil::process#nice()","posixpsutil::process#nice=()","posixpsutil::process#num_ctx_switches()","posixpsutil::process#num_fds()","posixpsutil::process#num_threads()","posixpsutil::process#open_files()","posixpsutil::process#parent()","posixpsutil::process::pid_exists()","posixpsutil::process::pids()","posixpsutil::process#ppid()","posixpsutil::process::process_iter()","posixpsutil::process::processes()","posixpsutil::process#resume()","posixpsutil::process#rlimit()","posixpsutil::process#send_signal()","posixpsutil::process#status()","posixpsutil::process#suspend()","posixpsutil::memory::swap_memory()","posixpsutil::process#terminal()","posixpsutil::process#terminate()","posixpsutil::process#threads()","posixpsutil::process#time_used()","posixpsutil::process#to_hash()","posixpsutil::process#to_s()","posixpsutil::psutilerror#to_s()","posixpsutil::process#uids()","posixpsutil::process#username()","posixpsutil::system::users()","posixpsutil::memory::virtual_memory()","posixpsutil::process#wait()"],"info":[["PosixPsutil","","PosixPsutil.html","",""],["PosixPsutil::AccessDenied","","PosixPsutil/AccessDenied.html","","<p>Raise it when the access is denied, a wrapper of ENOENT::EACCES\n"],["PosixPsutil::COMMON","","PosixPsutil/COMMON.html","",""],["PosixPsutil::CPU","","PosixPsutil/CPU.html","",""],["PosixPsutil::Disks","","PosixPsutil/Disks.html","",""],["PosixPsutil::Memory","","PosixPsutil/Memory.html","",""],["PosixPsutil::Network","","PosixPsutil/Network.html","",""],["PosixPsutil::NoSuchProcess","","PosixPsutil/NoSuchProcess.html","","<p>Raise it if the process behind doesn&#39;t exist  when you try to call a\nmethod of a Process instance. …\n"],["PosixPsutil::Process","","PosixPsutil/Process.html","","<p>Warning: There is already a Process module in ruby, so don&#39;t confuse it\nwith  this PosixPsutil::Process …\n"],["PosixPsutil::PsutilError","","PosixPsutil/PsutilError.html","",""],["PosixPsutil::System","","PosixPsutil/System.html","",""],["RbConfig","","RbConfig.html","",""],["!=","PosixPsutil::Process","PosixPsutil/Process.html#method-i-21-3D","(other)",""],["==","PosixPsutil::Process","PosixPsutil/Process.html#method-i-3D-3D","(other)","<p>Test for equality with another Process object based on PID and creation\ntime.\n"],["boot_time","PosixPsutil::System","PosixPsutil/System.html#method-c-boot_time","()","<p>return system boot time expressed in seconds since epoch\n"],["calculate_cpu_percent_field","PosixPsutil::CPU","PosixPsutil/CPU.html#method-c-calculate_cpu_percent_field","(start, last)",""],["children","PosixPsutil::Process","PosixPsutil/Process.html#method-i-children","(recursive = false)","<p>Return the children of this process as a list of Process instances,\npre-emptively checking whether PID …\n"],["cmdline","PosixPsutil::Process","PosixPsutil/Process.html#method-i-cmdline","()","<p>The command line this process has been called with. An array will be\nreturned\n"],["connections","PosixPsutil::Process","PosixPsutil/Process.html#method-i-connections","(interface = :inet)","<p>Return connections opened by process as a list of #&lt;OpenStruct fd,\nfamily, type, laddr, raddr, status&gt; …\n"],["cpu_affinity","PosixPsutil::Process","PosixPsutil/Process.html#method-i-cpu_affinity","(cpus=nil)","<p>Get or set process CPU affinity. If specified &#39;cpus&#39; must be a list\nof CPUs for which you want …\n"],["cpu_count","PosixPsutil::CPU","PosixPsutil/CPU.html#method-c-cpu_count","(logical=true)","<p>Return the number of physical/logical CPUs in the system.\n"],["cpu_percent","PosixPsutil::CPU","PosixPsutil/CPU.html#method-c-cpu_percent","(interval=0.0, percpu=false)","<p>measure cpu usage percent during an interval WARNING: set a small interval\nwill cause incorrect result …\n"],["cpu_percent","PosixPsutil::Process","PosixPsutil/Process.html#method-i-cpu_percent","(interval = nil)","<p>Return a float representing the current process CPU utilization as a\npercentage.\n<p>When interval is &lt;= …\n"],["cpu_times","PosixPsutil::CPU","PosixPsutil/CPU.html#method-c-cpu_times","(precpu=false)","<p>Return OpenStruct representing the CPU times for all CPU available in the\nsystem.  If precpu is true, …\n"],["cpu_times","PosixPsutil::Process","PosixPsutil/Process.html#method-i-cpu_times","()","<p>Return a #&lt;OpenStruct user, system&gt; representing the accumulated\nprocess time, in seconds.\n"],["cpu_times_percent","PosixPsutil::CPU","PosixPsutil/CPU.html#method-c-cpu_times_percent","(interval=0.0, percpu=false)",""],["create_time","PosixPsutil::Process","PosixPsutil/Process.html#method-i-create_time","()","<p>The process creation time as a floating point number expressed in seconds\nsince the epoch, in UTC. The …\n"],["cwd","PosixPsutil::Process","PosixPsutil/Process.html#method-i-cwd","()","<p>Process current working directory as an absolute path.\n"],["disk_io_counters","PosixPsutil::Disks","PosixPsutil/Disks.html#method-c-disk_io_counters","(perdisk=true)","<p>Return disk I/O statistics for every disk installed on the system as an\nArray of  &lt;OpenStruct read_count …\n"],["disk_partitions","PosixPsutil::Disks","PosixPsutil/Disks.html#method-c-disk_partitions","()","<p>Return mounted disk partitions as an Array of  &lt;OpenStruct device,\nmountpoint, fstype, opts&gt;\n"],["disk_usage","PosixPsutil::Disks","PosixPsutil/Disks.html#method-c-disk_usage","(disk)","<p>Return disk usage associated with path,  representing in &lt;OpenStruct\nfree, total, used, percent&gt;. …\n"],["eql?","PosixPsutil::Process","PosixPsutil/Process.html#method-i-eql-3F","(other)",""],["exe","PosixPsutil::Process","PosixPsutil/Process.html#method-i-exe","()","<p>The process executable as an absolute path. May also be an empty string.\nThe return value is cached after …\n"],["gids","PosixPsutil::Process","PosixPsutil/Process.html#method-i-gids","()","<p>Return process GIDs as #&lt;OpenStruct real, effective, saved&gt;\n"],["inspect","PosixPsutil::Process","PosixPsutil/Process.html#method-i-inspect","()","<p>Return a printable version of Process instance&#39;s description.\n"],["io_counters","PosixPsutil::Process","PosixPsutil/Process.html#method-i-io_counters","()","<p>Linux, BSD only\n<p>Return process I/O statistics as a #&lt;OpenStruct read_count, write_count,\nread_bytes …\n"],["ionice","PosixPsutil::Process","PosixPsutil/Process.html#method-i-ionice","(ioclass=nil, value=nil)","<p>Linux only\n<p>Get or set process I/O niceness (priority).\n<p>On Linux &#39;ioclass&#39; is one of the IOPRIO_CLASS_ …\n"],["is_running","PosixPsutil::Process","PosixPsutil/Process.html#method-i-is_running","()","<p>Return if this process is running. It also checks if PID has been reused by\nanother process in which …\n"],["kill","PosixPsutil::Process","PosixPsutil/Process.html#method-i-kill","()","<p>Kill the current process with SIGKILL pre-emptively checking whether PID\nhas been reused.\n<p>It is not an …\n"],["memory_info","PosixPsutil::Process","PosixPsutil/Process.html#method-i-memory_info","()","<p>Return an OpenStruct representing RSS (Resident Set Size) and VMS (Virtual\nMemory Size) in bytes.\n"],["memory_info_ex","PosixPsutil::Process","PosixPsutil/Process.html#method-i-memory_info_ex","()","<p>Return an OpenStruct with variable fields depending on the platform\nrepresenting extended memory information …\n"],["memory_maps","PosixPsutil::Process","PosixPsutil/Process.html#method-i-memory_maps","(grouped = true)","<p>If &#39;grouped&#39; is false every mapped region is shown as a single\nentity and the namedtuple will …\n"],["memory_percent","PosixPsutil::Process","PosixPsutil/Process.html#method-i-memory_percent","()","<p>Compare physical system memory to process resident memory (RSS) and\ncalculate process memory utilization …\n"],["name","PosixPsutil::Process","PosixPsutil/Process.html#method-i-name","()","<p>The process name. The return value is cached after first call.\n"],["net_connections","PosixPsutil::Network","PosixPsutil/Network.html#method-c-net_connections","(interface=:inet)","<p>interface can be one of [:inet, :inet4, inet6, :udp, :udp4, :udp6, :tcp,\n:tcp4, :tcp6, :all, :unix]\n<p>the …\n"],["net_io_counters","PosixPsutil::Network","PosixPsutil/Network.html#method-c-net_io_counters","(pernic=false)","<p>Get counters of network io (per network interface)\n<p>When pernic is true, return a hash contains network …\n"],["new","PosixPsutil::AccessDenied","PosixPsutil/AccessDenied.html#method-c-new","(opt={})",""],["new","PosixPsutil::NoSuchProcess","PosixPsutil/NoSuchProcess.html#method-c-new","(opt={})","<p>should be used at least like NoSuchProcess.new(pid: xxx)\n"],["new","PosixPsutil::Process","PosixPsutil/Process.html#method-c-new","(pid=nil)","<p>initialize a Process instance with pid,  if not pid given, initialize it\nwith current process&#39;s pid. …\n"],["nice","PosixPsutil::Process","PosixPsutil/Process.html#method-i-nice","()","<p>Get process niceness (priority).\n"],["nice=","PosixPsutil::Process","PosixPsutil/Process.html#method-i-nice-3D","(value)","<p>Set process niceness. Niceness values range from -20 (most favorable to the\nprocess) to 19  (least favorable …\n"],["num_ctx_switches","PosixPsutil::Process","PosixPsutil/Process.html#method-i-num_ctx_switches","()","<p>Return the number of voluntary and involuntary context switches performed\nby this process.\n"],["num_fds","PosixPsutil::Process","PosixPsutil/Process.html#method-i-num_fds","()","<p>Return the number of file descriptors opened by this process\n"],["num_threads","PosixPsutil::Process","PosixPsutil/Process.html#method-i-num_threads","()","<p>Return the number of threads used by this process.\n"],["open_files","PosixPsutil::Process","PosixPsutil/Process.html#method-i-open_files","()","<p>Return regular files opened by process as a list of &lt;#OpenStruct path,\nfd&gt; including the absolute …\n"],["parent","PosixPsutil::Process","PosixPsutil/Process.html#method-i-parent","()","<p>Return the parent process as a Process object pre-emptively checking\nwhether PID has been reused. If …\n"],["pid_exists","PosixPsutil::Process","PosixPsutil/Process.html#method-c-pid_exists","(pid)","<p>Return true if given PID exists in the current process list. This is faster\nthan doing “pid in  …\n"],["pids","PosixPsutil::Process","PosixPsutil/Process.html#method-c-pids","()","<p>Return an Array of current running PIDs.\n"],["ppid","PosixPsutil::Process","PosixPsutil/Process.html#method-i-ppid","()","<p>Return the parent pid of the process.\n"],["process_iter","PosixPsutil::Process","PosixPsutil/Process.html#method-c-process_iter","()","<p>Like self.processes(), but return next Process instance in each iteration.\nTo imitate Python&#39;s iterator, …\n"],["processes","PosixPsutil::Process","PosixPsutil/Process.html#method-c-processes","()","<p>Return all Process instances for all running processes.\n<p>Every new Process instance is only created once …\n"],["resume","PosixPsutil::Process","PosixPsutil/Process.html#method-i-resume","()","<p>Resume process execution with SIGCONT pre-emptively checking whether PID\nhas been reused.\n"],["rlimit","PosixPsutil::Process","PosixPsutil/Process.html#method-i-rlimit","(resource, limits=nil)","<p>Get or set process resource limits as a {:soft, :hard} Hash.\n<p>&#39;resource&#39; is one of the RLIMIT_* …\n"],["send_signal","PosixPsutil::Process","PosixPsutil/Process.html#method-i-send_signal","(sig)","<p>Send a signal to process pre-emptively checking whether PID has been reused\n(see signal module constants) …\n"],["status","PosixPsutil::Process","PosixPsutil/Process.html#method-i-status","()","<p>The process current status as a STATUS_* constant.\n"],["suspend","PosixPsutil::Process","PosixPsutil/Process.html#method-i-suspend","()","<p>Suspend process execution with SIGSTOP pre-emptively checking whether PID\nhas been reused.\n"],["swap_memory","PosixPsutil::Memory","PosixPsutil/Memory.html#method-c-swap_memory","()",""],["terminal","PosixPsutil::Process","PosixPsutil/Process.html#method-i-terminal","()","<p>The terminal associated with this process, if any, else nil.\n"],["terminate","PosixPsutil::Process","PosixPsutil/Process.html#method-i-terminate","()","<p>Terminate process execution with SIGTERM pre-emptively checking whether PID\nhas been reused.\n"],["threads","PosixPsutil::Process","PosixPsutil/Process.html#method-i-threads","()","<p>Return threads opened by process as a list of #&lt;OpenStruct id,\nuser_time, system_time&gt; representing …\n"],["time_used","PosixPsutil::Process","PosixPsutil/Process.html#method-i-time_used","()","<p>Return the wall time cost by process, measured in seconds\n"],["to_hash","PosixPsutil::Process","PosixPsutil/Process.html#method-i-to_hash","(given_attrs = nil, default = {})","<p>&#39;default&#39; is the value which gets assigned in case AccessDenied \nexception is raised when retrieving …\n"],["to_s","PosixPsutil::Process","PosixPsutil/Process.html#method-i-to_s","()","<p>Return description of Process instance.\n"],["to_s","PosixPsutil::PsutilError","PosixPsutil/PsutilError.html#method-i-to_s","()",""],["uids","PosixPsutil::Process","PosixPsutil/Process.html#method-i-uids","()","<p>Return process UIDs as #&lt;OpenStruct real, effective, saved&gt;\n"],["username","PosixPsutil::Process","PosixPsutil/Process.html#method-i-username","()","<p>The name of the user that owns the process.\n"],["users","PosixPsutil::System","PosixPsutil/System.html#method-c-users","()","<p>Return currently connected users as a list of  OpenStruct&lt;#name, #tty,\n#host(hostname), #started(the …\n"],["virtual_memory","PosixPsutil::Memory","PosixPsutil/Memory.html#method-c-virtual_memory","()",""],["wait","PosixPsutil::Process","PosixPsutil/Process.html#method-i-wait","(timeout = nil)","<p>Waiting until process does not existed any more.  Raise Timeout::Error if\ntime out while waiting.\n"]]}}