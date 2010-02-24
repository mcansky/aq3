module AqLib
  begin
    # Try to require the preresolved locked set of gems.
    require File.expand_path('../../.bundle/environment', __FILE__)
  rescue LoadError
    # Fall back on doing an unlocked resolve at runtime.
    require "rubygems"
    require "bundler"
    gemfile_path= File.expand_path('../../', __FILE__)
    ENV['BUNDLE_GEMFILE'] ||= File.join(gemfile_path, 'Gemfile')
    Bundler.setup
  end
  require "active_record"
  require "settingslogic"
  require "arel"
  require 'pathname'

  class Settings < Settingslogic
    source File.expand_path("../../config/application.yml", __FILE__ )
  end

  ActiveRecord::Base.establish_connection(
    :adapter => Settings.default.database.adapter,
    :database => File.expand_path("../../development.sqlite3", __FILE__ ))

  class User < ActiveRecord::Base
    has_many :ssh_keys
    has_many :rights

    def has_read?
    end

    def has_write?
    end
  end

  class Right < ActiveRecord::Base
    belongs_to :user
    belongs_to :aq_repository
  end

  class SshKey < ActiveRecord::Base
    belongs_to :user
  end

  class AqRepository < ActiveRecord::Base
    has_many :rights

    def public?
      return true
    end
  end

  class Command
    attr_accessor :cmd_type, :cmd_cmd, :cmd_opt, :fake_path, :real_path, :aq_user, :user_login,
     :user_email, :user_id

    def aqlog(message)
  	  File.open(Settings.default.user_home + "/" + Settings.default.user_name + "/" + Settings.default.log, "a") do |log|
  		  log.puts Time.now.strftime("%d/%m/%y %H:%M ") + message
  	  end
    end

    def initialize(user,command)
      # r or w (read or write)
      @cmd_type = ""
      # the git or hg command
      @cmd_cmd = ""
      # the options
      @cmd_opt = ""
      # fake path
      @fake_path = ""
      # real path
      @real_path = ""
      # user login
      @aq_user = nil
      @user_login = ""
      @user_email = ""
      @user_id = nil

      begin
        key = SshKey.find_by_login(user)
      rescue
        puts "Couldn't find key #{user}"
      end
      exit(1) if !key
      self.aq_user = User.find(key.user_id)
      self.user_login = self.aq_user.login
      self.user_email = self.aq_user.email
      self.user_id = key.user_id
      self.aqlog("Found #{user} : #{self.aq_user.email}")
      self.aqlog("Want to :#{command}:")
      # can be either r (read) or w (write)
    end

    def repo(command)
    end

    # basic sanity check and split of the command line
    def check(command)
      if command =~ /\n/ || !(command =~ /^git/)
        return false
      end
      reads = ["git-upload-pack", "git upload-pack"]
      writes = ["git-receive-pack", "git receive-pack"]
      sh_command = command.split(" ")
      if sh_command.size == 3
        self.cmd_cmd = sh_command[0] + " " + sh_command[1]
        self.cmd_opt = sh_command[2]
      elsif sh_command.size == 2
        self.cmd_cmd = sh_command[0]
        self.cmd_opt = sh_command[1]
      else
        return false
      end

      # check the command for type
      if reads.include?(self.cmd_cmd)
        self.cmd_type = "r"
        self.aqlog("Read command")
      end
      if writes.include?(self.cmd_cmd)
        self.cmd_type = "w"
        self.aqlog("Write command")
      end
      return true
    end

    # extract the repo path from the command
    def repo_path
      if !self.cmd_opt.empty?
        self.fake_path = self.cmd_opt.gsub("'","").split("/")[-1]
        self.real_path = Settings.default.user_home + "/" +
                Settings.default.user_name + "/" +
                Settings.default.repo_git_path + "/" +
                self.username_from_cmd + "/" +
                self.fake_path
        return self.real_path
      end
    end

    # extract the repo name from the command
    def repo_name
      return self.cmd_opt.gsub("'","").split("/")[-1].split(".")[0] if !self.cmd_opt.empty?
    end

    # extract the user name from the command
    def username_from_cmd
      return self.cmd_opt.gsub("'","").split("/")[0] if !self.cmd_opt.empty?
    end

    # the exec of the command
    def run
      self.aqlog("Running command : git-shell #{@cmd_cmd} '#{@real_path}'")
      exec(Settings.default.gitshell, "-c", "#{@cmd_cmd} '#{@real_path}'")
    end

    def self.kickstart!(user, sh_command)
      key = nil
      command = self.new(user, sh_command)
      if command.check(sh_command)
        name_from_cmd = command.username_from_cmd
        command.aqlog("Found user name from cmd : #{name_from_cmd}") if name_from_cmd

        repo_path = command.repo_path
        repo_name = command.repo_name
        if !repo_path.empty?
          a_repo = AqRepository.find_by_path(repo_path)
          if a_repo
            command.aqlog("Found repo in db : #{a_repo.name}")
          else
            command.aqlog("Couldn't find the repository #{repo_name}")
            exit(1)
          end
          a_right = Right.find(:all, :conditions => ["user_id = ? AND aq_repository_id = ?", command.user_id, a_repo.object_id]).first
          if (command.cmd_type == "r" || (a_right && a_right.right == "w")) && a_repo.public?
            command.run
          else
            command.aqlog("insufficiant rights for #{command.user_login}")
          end
        end
      else
        command.aqlog("Command Invalid !")
      end
    end
  end
end