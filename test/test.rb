# -*- coding: utf-8 -*-

$: << File.dirname(__FILE__)
require 'test_helper'
require 'test/unit'
require 'Fileutils'

require 'scccp'

class TestScccp < Test::Unit::TestCase

  SCCCP_WORKING_DIR    = '/tmp/test/scccp/'
  QUEUE_FOLDER         = "#{SCCCP_WORKING_DIR}from/"
  OK_FOLDER            = "#{SCCCP_WORKING_DIR}done/"
  NG_FOLDER            = "#{SCCCP_WORKING_DIR}error/"
  REMOTE_PATH          = "#{SCCCP_WORKING_DIR}remote/"
  REMOTE_USER_NAME     = 'paco'
  REMOTE_USER_PASSWORD = nil
  REMOTE_HOST          = "localhost"

  def setup
    FileUtils.mkdir_p(QUEUE_FOLDER)
    FileUtils.mkdir_p(OK_FOLDER)
    FileUtils.mkdir_p(REMOTE_PATH)
    FileUtils.mkdir_p(NG_FOLDER)
    delete_files(QUEUE_FOLDER)
    delete_files(OK_FOLDER)
    delete_files(NG_FOLDER)
    delete_files(REMOTE_PATH)
    files = [
      @l_file     = QUEUE_FOLDER + 'testfile',
      @l_file1    = QUEUE_FOLDER + 'testfile1',
      @l_file2    = QUEUE_FOLDER + 'testfile2',
      @l_file_tmp = QUEUE_FOLDER + 'test.tmp',
      @l_file_ok  = QUEUE_FOLDER + 'test.ok'
    ]
    files.each do |file|
      File.write(file,'test_data')
    end
  end

  def delete_files(dir)
    raise 'safety net orz' unless dir =~ %r|/scccp/|
    Dir::entries(dir).each do |file|
      file = "#{dir}/#{file}"
      next unless File::ftype(file) == 'file'
      File.delete(file) if File.exist?(file)
    end
  end

  def attr
    {
      :logger               => Logger.new('/dev/null'),
      :remote_host          => REMOTE_HOST,
      :remote_user_name     => REMOTE_USER_NAME,
      :remote_user_password => REMOTE_USER_PASSWORD,
      :remote_path          => REMOTE_PATH,
      :queue_folder         => QUEUE_FOLDER,
      :ok_folder            => OK_FOLDER,
      :ng_folder            => NG_FOLDER
    }
  end

  def test_error
    scccp = Scccp::Scp.new(attr)
    scccp.remote_path = '/tmp/slefijseflislfjsliefjsief/'
    scccp.timeout = 3
    #scccp.logger2ssh = true
    scccp.proceed

    assert_true File.exists?(NG_FOLDER + "testfile2")
    assert_false File.exists?(NG_FOLDER + "testfile2.ok")
  end

  def test_connection_error
    scccp = Scccp::Scp.new(attr)
    scccp.remote_host = 'sefisfejisfe.sefijsefij.esfij'
    scccp.timeout = 3
    #scccp.logger2ssh = true
    scccp.proceed

    # コネクションエラーだとキューフォルダーをいじらない
    assert_true File.exists?(QUEUE_FOLDER + "testfile2")
  end


  def test_scccp
    assert_true File.exists?(@l_file)
    assert_true File.exists?(@l_file1)
    scccp = Scccp::Scp.new()
    assert_raise do
      scccp.proceed
    end
    scccp.logger               = Logger.new('/dev/null')
    scccp.remote_host          = REMOTE_HOST
    scccp.remote_user_name     = REMOTE_USER_NAME
    scccp.remote_user_password = REMOTE_USER_PASSWORD
    scccp.remote_path          = REMOTE_PATH
    scccp.queue_folder         = 'hohogege'
    scccp.ok_folder            = OK_FOLDER
    scccp.ng_folder            = NG_FOLDER

    assert_raise do
      scccp.proceed
    end
    scccp.queue_folder = QUEUE_FOLDER
    scccp.proceed

    assert_true File.exists?(REMOTE_PATH + "testfile2")
    assert_true File.exists?(REMOTE_PATH + "testfile2.ok")

    assert_true File.exists?(@l_file_tmp)
    assert_true File.exists?(@l_file_ok)
  end
end
