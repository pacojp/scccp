require 'scccp'

REMOTE_HOST = 'localhost'
REMOTE_USER_NAME = 'paco'
REMOTE_USER_PASSWORD = nil
WORK_SPACE = '/tmp/test/scccp_sample/'
REMOTE_PATH = WORK_SPACE + 'remote/'
QUEUE_FOLDER = WORK_SPACE + 'from/'
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

scccp = Scccp::Scp.new
scccp.remote_host          = REMOTE_HOST
scccp.remote_user_name     = REMOTE_USER_NAME
scccp.remote_user_password = REMOTE_USER_PASSWORD
scccp.remote_path          = REMOTE_PATH
scccp.queue_folder         = QUEUE_FOLDER
scccp.ok_folder            = OK_FOLDER
scccp.ng_folder            = NG_FOLDER
scccp.proceed
