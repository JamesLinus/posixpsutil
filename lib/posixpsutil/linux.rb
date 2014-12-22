require 'ostruct'
require 'date'
require_relative './common'
require_relative './linux_helper'

class CPU

  def self.cpu_times(precpu=false)
    proc_stat = File.new('/proc/stat')
    cpu = proc_stat.readline()
    return get_cpu_fields(cpu) unless precpu
    cpus = []
    loop do
      cpu = proc_stat.readline()
      break unless cpu.start_with?('cpu')
      cpus.push(get_cpu_fields(cpu))
    end
    cpus
  end

  # measure cpu usage percent during an interval
  # WARNING: set a small interval will cause incorrect result
  def self.cpu_percent(interval=0.0, percpu=false)
    if interval > 0.0
      total_start = self.cpu_times(percpu)
      sleep interval
    else
      if percpu
        total_start = @last_per_cpu_times
      else
        total_start = @last_cpu_times
      end
    end

    if percpu
      @last_per_cpu_times = self.cpu_times(true)
      ret = []
      total_start.each_index do |i|
        ret.push(calculate_cpu_percent(total_start[i], @last_per_cpu_times[i]))
      end
      ret
    else
      @last_cpu_times = self.cpu_times()
      calculate_cpu_percent(total_start, @last_cpu_times)
    end
  end
   
  def self.cpu_times_percent(interval=0.0, percpu=false)
    if interval > 0.0
      total_start = self.cpu_times(percpu)
      sleep interval
    else
      if percpu
        total_start = @last_per_cpu_times_fields
      else
        total_start = @last_cpu_times_fields
      end
    end

    if percpu
      @last_per_cpu_times_fields = self.cpu_times(true)
      ret = []
      total_start.each_index do |i|
        ret.push(calculate_cpu_percent_field(total_start[i], @last_per_cpu_times_fields[i]))
      end
      ret
    else
      @last_cpu_times = self.cpu_times()
      calculate_cpu_percent_field(total_start, @last_cpu_times_fields)
    end
  end

  @logical_cpu_count = nil
  @physical_cpu_count = nil
  def self.cpu_count(logical=true)
    count = 0
    if !logical
      unless @physical_cpu_count
        IO.readlines('/proc/cpuinfo').each do |line|
          count += 1 if line.start_with?('physical id')
        end
        @physical_cpu_count = count
      end
      return @physical_cpu_count
    end

    unless @logical_cpu_count
      Dir.entries('/sys/devices/system/cpu').each do |entry|
        count += 1 if entry.start_with?('cpu')
      end
      count -= 2 # except cpuidle and cpufreq
      @logical_cpu_count = count
    end
    @logical_cpu_count
  end

  # The  amount  of  time,  measured in units of +USER_HZ+
  # (1/100ths of a second on most architectures, use sysconf(_SC_CLK_TCK) to obtain the right value), 
  # that the system spent in various states
  # user   (1) Time spent in user mode.
  # nice   (2) Time spent in user mode with low priority (nice).
  # system (3) Time spent in system mode.
  # idle   (4) Time spent in the idle task.  This value should be USER_HZ times the second entry in the /proc/uptime pseudo-file.
  # iowait (since Linux 2.5.41)
  #        (5) Time waiting for I/O to complete.
  # irq (since Linux 2.6.0-test4)
  #        (6) Time servicing interrupts.
  # softirq (since Linux 2.6.0-test4)
  #        (7) Time servicing softirqs.
  # steal (since Linux 2.6.11)
  #        (8) Stolen time, which is the time spent in other operating systems when running in a virtualized environment
  # guest (since Linux 2.6.24)
  #        (9) Time spent running a virtual CPU for guest operating systems under the control of the Linux kernel.
  # guest_nice (since Linux 2.6.33)
  #        (10) Time spent running a niced guest (virtual CPU for guest operating systems under the control of the Linux kernel).
  def self.get_cpu_fields(line)
    stat = line.split(" ")
    clk_tck = COMMON::CLOCK_TICKS 
    cpu = OpenStruct.new
    cpu.user = stat[1].to_f / clk_tck
    cpu.nice = stat[2].to_f / clk_tck
    cpu.system = stat[3].to_f / clk_tck
    cpu.idle = stat[4].to_f / clk_tck
    cpu.iowait = stat[5].to_f / clk_tck
    cpu.irq = stat[6].to_f / clk_tck
    cpu.softirq = stat[7].to_f / clk_tck
    cpu.steal = stat[8].to_f  / clk_tck unless stat[8].nil?
    cpu.guest = stat[9].to_f / clk_tck unless stat[9].nil?
    cpu.guest_nice = stat[10].to_f / clk_tck unless stat[10].nil?
    cpu
  end

  def self.calculate_cpu_percent(start, last)
    start_sum = 0
    start.marshal_dump.each_value {|value| start_sum += value}
    last_sum = 0
    last.marshal_dump.each_value {|value| last_sum += value}

    start_busy = start_sum - start.idle
    last_busy = last_sum - last.idle

    # be aware of float precision issue
    return 0 if last_busy < start_busy
    busy_delta = last_busy - start_busy
    all_delta = last_sum - start_sum
    # if the interval is too small
    if busy_delta == 0
      percent = (last_busy + start_busy) / (last_sum + start_sum) * 100
    else
      percent = (busy_delta / all_delta) * 100
    end
    return percent.round(2)
  end

  def self.calculate_cpu_percent_field(start, last)
    start_sum = 0
    start.marshal_dump.each_value {|value| start_sum += value}
    last_sum = 0
    last.marshal_dump.each_value {|value| last_sum += value}

    ret = OpenStruct.new
    [:user, :nice, :system, :idle, :iowait, :irq, 
              :softirq, :steal, :guest, :guest_nice].each do |field|
      start_field = start[field]
      last_field = last[field]
      # be aware of float precision issue
      last_field = start_field if last_field < start_field
      field_delta = last_field - start_field
      all_delta = last_sum - start_sum
      # if the interval is too small
      if all_delta == 0
        percent = 0
      else
        percent = field_delta * 100 / all_delta
      end
      ret[field] = percent.round(2)
    end

    ret
  end

  private_class_method :get_cpu_fields, :calculate_cpu_percent

  @last_cpu_times = cpu_times()
  @last_per_cpu_times = cpu_times(true)
  @last_cpu_times_fields = cpu_times()
  @last_per_cpu_times_fields = cpu_times(true)

end

class Memory

  def self.virtual_memory()
    meminfo = OpenStruct.new
    IO.readlines('/proc/meminfo').each do |line|
      pair = line.split(':')
      case pair[0]
        when 'Cached'
          # values are expressed in KB, we want bytes instead
          meminfo.cached = pair[1].to_i * 1024
        when 'Active'
          meminfo.active = pair[1].to_i * 1024
        when 'Inactive'
          meminfo.inactive = pair[1].to_i * 1024
        when 'Buffers'
          meminfo.buffers = pair[1].to_i * 1024
        when 'MemFree'
          meminfo.free = pair[1].to_i * 1024
        when 'MemTotal'
          meminfo.total = pair[1].to_i * 1024
      end
    end

    meminfo.used = meminfo.total - meminfo.free
    meminfo.available = meminfo.free + meminfo.cached + meminfo.buffers
    meminfo.percent = COMMON::usage_percent((
      meminfo.total - meminfo.available) , meminfo.total, 1)
    meminfo
  end

  def self.swap_memory()
    meminfo = OpenStruct.new
    swaps = File.new('/proc/swaps')
    swaps.readline() # ignore column header
    _, _, total, used, _ = swaps.readline().split(" ")
    # values are expressed in 4 KB, we want bytes instead
    meminfo.total = total.to_i * 1024
    meminfo.used = used.to_i * 1024

    
    meminfo.free = meminfo.total - meminfo.used
    meminfo.percent = COMMON::usage_percent(meminfo.used, meminfo.total, 1)
    
    IO.readlines('/proc/vmstat').each do |line|
      # values are expressed in 4 KB, we want bytes instead
      if line.start_with?('pswpin')
        meminfo.sin = line.split(' ')[1].to_i * 4 * 1024
      elsif line.start_with?('pswpout')
        meminfo.sout = line.split(' ')[1].to_i * 4 * 1024
      end
    end

    meminfo
  end

end

class Disks

  def self.disk_partitions()
    phydevs = []
    # get physical filesystems
    IO.readlines('/proc/filesystems').each do |line|
      phydevs.push(line.strip()) unless line.start_with?('nodev')
    end

    ret = []
    # there will be some devices with /dev/disk/by-*, they are symbol links to physical devices
    IO.readlines('/proc/self/mounts').each do |line|
      line = line.split(' ')
      # omit virtual filesystems
      if phydevs.include?(line[2])
        partition = OpenStruct.new
        partition.device = line[0]
        partition.mountpoint = line[1]
        partition.fstype = line[2]
        partition.opts = line[3]
        ret.push(partition)
      end
    end
    ret
  end

  # WARNING: this method show the usage of a +disk+ instead of a given path!
  def self.disk_usage(disk)
    usage = OpenStruct.new
    # FIXME use df to get disk usage. Once the c binding is finished, replace it.
    IO.popen('df') do |f|
      f.readlines[1..-1].each do |fs|
        _, total, used, free, percent, mountpoint = fs.split(' ')
        # with 1K blocks
        if mountpoint == disk
          usage.total = total.to_i * 1024
          usage.used = used.to_i * 1024
          usage.free = free.to_i * 1024
          usage.percent = percent
        end
      end
    end

    throw ArgumentError.new('Given Argument is not a disk name') if usage.total.nil?
    usage
  end
   
  def self.disk_io_counters(perdisk=true)
    # get disks list
    partitions = []
    lines = IO.readlines('/proc/partitions')[2..-1]
    # reverse lines so sda will be below sda1
    lines.reverse_each do |line|
      name = line.split(' ')[3]
      if name[-1] === /\d/
        # we're dealing with a partition (e.g. 'sda1'); 'sda' will
        # also be around but we want to omit it
        partitions.push(name)
      elsif partitions.empty? || !partitions[-1].start_with?(name)
        # we're dealing with a disk entity for which no
        # partitions have been defined (e.g. 'sda' but
        # 'sda1' was not around), see:
        # https://github.com/giampaolo/psutil/issues/338
        partitions.push(name)
      end
    end

    ret = {}

    # man iostat states that sectors are equivalent with blocks and
    # have a size of 512 bytes since 2.4 kernels. This value is
    # needed to calculate the amount of disk I/O in bytes.
    sector_size = 512
    # get disks stats
    IO.readlines('/proc/diskstats').each do |line|
      fields = line.split()
      if partitions.include?(fields[2])
        # go to http://www.mjmwired.net/kernel/Documentation/iostats.txt
        # and see what these fields mean
        if fields.length
          _, _, name, reads, _, rbytes, rtime, writes, _, wbytes, wtime = fields[0..10]
        else
          # < kernel 2.6.25
          _, _, name, reads, rbytes, writes, wbytes = fields
          rtime, wtime = 0, 0
        end

        # fill with the data
        disk = OpenStruct.new
        disk.read_bytes = rbytes.to_i * sector_size
        disk.write_bytes = wbytes.to_i * sector_size
        disk.read_count = reads.to_i
        disk.write_count = writes.to_i
        disk.read_time = rtime.to_i
        disk.write_time = wtime.to_i
        ret[name] = disk
      end # end if name in partitions
    end # end read /proc/diskstats

    # handle ret
    if perdisk
      return ret
    else
      total = OpenStruct.new(read_bytes: 0, write_bytes: 0, read_count: 0, 
                             write_count: 0, read_time: 0, write_time: 0)
      ret.each_value do |disk|
        total.read_bytes += disk.read_bytes
        total.write_bytes += disk.write_bytes
        total.read_count += disk.read_count
        total.write_count += disk.write_count
        total.read_time += disk.read_time
        total.write_time += disk.write_time
      end

      return total
    end
  end

end

class Network
  
  include PsutilHelper
  include NetworkConstance

  # get counters of network io (per network interface)
  #
  # when pernic is true, return a hash contains network io of each interface,
  # otherwise return sum of all interface
  def self.net_io_counters(pernic=false)
    lines = IO.readlines('/proc/net/dev')[2..-1]
    if pernic
      ret = {}
      lines.each do |line|
        colon = line.rindex(':')
        name = line[0...colon].strip()
        fields = line[(colon + 1)..-1].strip.split(' ')
        counter = OpenStruct.new
        counter.bytes_recv = fields[0].to_i
        counter.packets_recv = fields[1].to_i
        counter.errin = fields[2].to_i
        counter.dropin = fields[3].to_i
        counter.bytes_sent = fields[8].to_i
        counter.packets_sent = fields[9].to_i
        counter.errout = fields[10].to_i
        counter.dropout = fields[11].to_i
        ret[name.to_sym] = counter
      end
      return ret
    else
      counter = OpenStruct.new(bytes_recv: 0, packets_recv: 0, 
                               errin: 0, dropin: 0, bytes_sent: 0, 
                               packets_sent: 0, errout: 0, dropout: 0)
      lines.each do |line|
        colon = line.rindex(':')
        fields = line[(colon + 1)..-1].strip.split(' ')
        counter.bytes_recv += fields[0].to_i
        counter.packets_recv += fields[1].to_i
        counter.errin += fields[2].to_i
        counter.dropin += fields[3].to_i
        counter.bytes_sent += fields[8].to_i
        counter.packets_sent += fields[9].to_i
        counter.errout += fields[10].to_i
        counter.dropout += fields[11].to_i
      end
      return counter
    end
  end

  # interface can be one of [:inet, :inet4, inet6, :udp, :udp4, :udp6,
  # :tcp, :tcp4, :tcp6, :all, :unix]
  #
  # the default interface is :inet, contains udp[46] and tcp[46]
  # return #<OpenStruct inode, laddr, raddr, family, type, status, fd, pid>
  def self.net_connections(interface=:inet)
    ret = []
    connection = Connection.new
    return nil unless connection.tmap.key?(interface)
    connection.tmap[interface].each do |kind|
      f, family, type = kind
      if [AF_INET, AF_INET6].include?(family)
        ret.concat(connection.process_inet("/proc/net/#{f}", family, type))
      else
        ret.concat(connection.process_unix("/proc/net/#{f}", family, type))
      end
    end
    inodes = Processes.get_all_inodes
    #  set pid to nil and fd to -1 for those inodes without relative pid/fd. 
    #  Mostly because Permission denied
    ret.each do |conn|
      if inodes.has_key? conn.inode
        conn.pid, conn.fd = inodes[conn.inode].first
      else
        conn.pid, conn.fd = nil, -1
      end
    end
    ret
  end

end

class System
  
  # store boot time since it won't be changed
  @boot_at = nil
  # use `who` to get userinfo. Also, replace it with system call if possible
  def self.users
    users = []
    IO.popen('who') do |f|
      f.readlines.each do |login_info|
        name, tty, date, time, host = login_info.split(' ')
        host = host[1..-2]
        host = 'localhost' if host == ':0'
        ts = DateTime.parse(date + " " + time).to_time.to_f
        # I do not like to convert date and time to timestamp
        # but this is what psutil does, so I have to follow it.
        users.push(OpenStruct.new({name: name, terminal: tty, 
                                   host: host, started: ts}))
      end
    end
    users
  end

  # return system boot time expressed in seconds since epoch
  def self.boot_time
    @boot_at = PsutilHelper::boot_time() if @boot_at.nil?
    @boot_at
  end

end

