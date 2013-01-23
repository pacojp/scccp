require 'net/scp'
require 'fileutils'

module Scccp
  class Scp
    ATTRS = [
      :remote_host,
      :remote_user_name,
      :remote_user_password,
      :remote_path,
      :remote_port,
      :queue_folder,
      :ok_folder,
      :ng_folder,
      :timeout,
      :logger2ssh,
      :logger
    ]
    ATTRS.each do |_attr|
      attr_accessor _attr
    end

    def initialize(opts={})
      self.remote_port = 22
      self.logger      = Logger.new(STDOUT)
      opts.each do |k, v|
        send("#{k}=", v)
      end
    end

    def attrs_ok?
      ATTRS.each do |attr|
        #v = instance_variable_get("@#{attr.to_s}")
        v = send(attr)
        case attr
        when :remote_user_name,:remote_user_password,:timeout,:logger2ssh
          next
        when :queue_folder,:ok_folder,:ng_folder
          unless File.directory?(v)
            raise "#{attr}:#{v} is not folder"
          end
        else
          unless v
            raise %|must set "#{attr}" at least|
          end
        end
      end
      true
    end

    def receive_signal(signal)
      @killing = true
    end

    def proceed
      attrs_ok?

      opt = {}
      opt[:port] = remote_port
      if remote_user_password
        opt[:password] = remote_user_password
      end
      if timeout
        opt[:timeout] = timeout
      end
      if logger2ssh
        opt[:logger] = logger
      end

      files = Dir::entries(queue_folder).map{|o|"#{queue_folder}/#{o}"}
      files = files.select do |o|
        File::ftype(o) == "file" &&
          !(o =~ /\.(tmp|ok)$/)
      end

      unless @__not_first_time_to_proceed
        logger.info("queue_folder is #{queue_folder}")
        logger.info("target is #{remote_user_name}@#{remote_host}:#{remote_port}:#{remote_path}")
        @__not_first_time_to_proceed = true
      end
      #logger.info(files.inspect)
      uploaded_count = 0
      return 0 if files.size == 0

      begin
        # ブロックで使うと途中で失敗した場合にscpインスタンスを
        # 使いまわせない（というか固まる）のでこんな感じの使い方で
        scp = Net::SCP.start(remote_host, remote_user_name, opt)
        files.each do |file|
          break if @killing
          ok_file = file + '.ok'
          begin
            logger.info "uploading_start:#{file}"
            scp.upload! file, remote_path
            logger.info "uploading_finish:#{file}"
            FileUtils.touch ok_file
            logger.info "uploading_start:#{ok_file}"
            scp.upload! ok_file, remote_path
            logger.info "uploading_finish:#{ok_file}"
            FileUtils.mv(file,ok_folder)
            FileUtils.mv(ok_file,ok_folder)
            uploaded_count += 1
            true
          rescue => e
            logger.error e
            File.delete(ok_file) if File.exists?(ok_file)
            FileUtils.mv(file,ng_folder)
            begin
              scp.session.close if scp
            rescue
            end
            scp = Net::SCP.start(remote_host, remote_user_name, opt)
            false
          end
        end
      rescue SocketError => socket_error
        logger.error socket_error
      ensure
        if scp
          scp.session.close
        end
      end

      uploaded_count
    end
  end
end
