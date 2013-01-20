# -*- coding: utf-8 -*-

require 'scccp'

require 'batchbase'
include Batchbase::Core
# https://github.com/pacojp/batchbase
#
# 2重起動防止
# シグナル管理
# デーモン化
#

#create_logger('/tmp/batchbase_test_sample1.log')
create_logger(STDOUT)
def receive_signal(signal)
  logger.info("receive signal #{signal}")
  @stop = true
end
set_signal_observer(:receive_signal,self)
@stop = false

REMOTE_HOST = 'localhost'
REMOTE_USER_NAME = 'paco'
REMOTE_USER_PASSWORD = nil
WORK_SPACE = '/tmp/test/scccp_sample/'
REMOTE_PATH = WORK_SPACE + 'remote/'
QUEUE_FOLDER = WORK_SPACE + 'from/'
LOCKFILE = WORK_SPACE + '.scccp.lock'
OK_FOLDER = WORK_SPACE + 'ok'
NG_FOLDER = WORK_SPACE + 'ng'

<<`MKDIR`
mkdir -p /tmp/test/scccp_sample/from
mkdir -p /tmp/test/scccp_sample/ok
mkdir -p /tmp/test/scccp_sample/ng
mkdir -p /tmp/test/scccp_sample/remote
touch /tmp/test/scccp_sample/from/file1
touch /tmp/test/scccp_sample/from/file2.tmp
touch /tmp/test/scccp_sample/from/file3.ok
MKDIR

execute(:pid_file=>LOCKFILE) do
  scccp = Scccp::Scp.new()
  scccp.logger               = logger
  scccp.remote_host          = REMOTE_HOST
  scccp.remote_user_name     = REMOTE_USER_NAME
  scccp.remote_user_password = REMOTE_USER_PASSWORD
  scccp.remote_path          = REMOTE_PATH
  scccp.queue_folder         = QUEUE_FOLDER
  scccp.ok_folder            = OK_FOLDER
  scccp.ng_folder            = NG_FOLDER
  set_signal_observer(:receive_signal,scccp)

  loop do
    cnt = scccp.proceed
    logger.info "#{cnt} files uploaded"
    break_loop = false
    5.times do
      sleep 1
      if @stop
        break_loop = true
        break
      end
    end
    break if break_loop
  end
end
