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
    :adapter => "sqlite3",
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

    def is_git?
      return true if self.kind == "git"
      return false
    end

    def is_hg?
      return true if self.kind == "hg"
      return false
    end

    def aqlog(message)
  	  File.open(Settings.defaults.user_home + "/" + Settings.defaults.user_name + "/" + Settings.defaults.log, "a") do |log|
  		  log.puts Time.now.strftime("%d/%m/%y %H:%M ") + message
  	  end
    end

    def grit_update
      base_dir = File.expand_path("../../../../", __FILE__ )
      Dir.chdir(base_dir)
      if system("rake git:pull RNAME=#{self.name}")
        self.aqlog("grit update #{self.name} : OK")
      else
        self.aqlog("grit update #{self.name} : KO")
      end
    end
  end

  class Command
    attr_accessor :cmd_type, :cmd_cmd, :cmd_opt, :fake_path, :real_path, :aq_user, :user_login,
     :user_email, :user_id, :read, :write, :kind, :fresh_cmd

    def aqlog(message)
  	  File.open(Settings.defaults.user_home + "/" + Settings.defaults.user_name + "/" + Settings.defaults.log, "a") do |log|
  		  log.puts Time.now.strftime("%d/%m/%y %H:%M ") + message
  	  end
    end

    def is_write?
      return write
    end

    def is_read?
      return read
    end

    def is_git?
      return true if self.kind == "git"
      return false
    end

    def is_hg?
      return true if self.kind == "hg"
      return false
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
      @write = false
      @read = false
      @kind = nil
      @fresh_cmd = ""

      begin
        key = SshKey.find_by_login(user)
      rescue
        self.aqlog("Couldn't find key #{user}")
      end
      if !key
        exit(1)
      else
        self.aq_user = User.find(key.user_id)
        self.user_login = self.aq_user.login
        self.user_email = self.aq_user.email
        self.user_id = key.user_id
        self.aqlog("Found #{user} : #{self.aq_user.email} #{self.user_id}")
        self.aqlog("Want to :#{command}:")
        self.fresh_cmd = command
        # can be either r (read) or w (write)
      end
    end

    def repo(command)
    end

    # basic sanity check and split of the command line
    def check(command)
      if !(command =~ /\n/) && (command =~ /^git/)
        self.kind = "git"
        self.aqlog("Git command")
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
          self.read = true
          self.aqlog("Read command")
        end
        if writes.include?(self.cmd_cmd)
          self.write = true
          self.aqlog("Write command")
        end
        return true
      elsif !(command =~ /\n/) && (command =~ /^hg/)
        # something fails in here
        self.kind = "hg"
        self.aqlog("Hg command")
        reads = ["-R"]
        writes = []
        sh_command = command.split(" ")
        hg_command = { :cmd => sh_command[0],
            :cmdopt => sh_command[1],
            :fake_path => sh_command[2],
            :cmd2 => sh_command[3],
            :cmd3 => sh_command[4] }
        # probably those lines
        self.cmd_cmd = "hg #{hg_command[:cmd]}"
        self.cmd_opt = "#{hg_command[:cmdopt]} #{hg_command[:fake_path]} #{hg_command[:cmd2]} #{hg_command[:cmd3]}"
        self.aqlog(cmd_opt)
        if reads.include?(self.cmd_cmd)
          self.read = true
          self.aqlog("Read command")
        end
        if writes.include?(self.cmd_cmd)
          self.write = true
          self.aqlog("Write command")
        end
        return true
      else
        return false
      end
    end

    # extract the repo path from the command
    def repo_path
      if !self.cmd_opt.empty?
        if self.is_git?
          self.fake_path = self.cmd_opt.gsub("'","").split("/")[-1]
          self.real_path = Settings.defaults.user_home + "/" +
                  Settings.defaults.user_name + "/" +
                  Settings.defaults.repo_git_path + "/" +
                  self.username_from_cmd + "/" +
                  self.fake_path
          return self.real_path
        elsif self.is_hg?
          self.fake_path = self.cmd_opt.split(" ")[1]
          self.real_path = Settings.defaults.user_home + "/" +
                  Settings.defaults.user_name + "/" +
                  Settings.defaults.repo_hg_path + "/" +
                  self.fake_path
          return self.real_path
        end
      end
    end

    # extract the repo name from the command
    def repo_name
      if self.is_git?
        return self.cmd_opt.gsub("'","").split("/")[-1] if !self.cmd_opt.empty?
      elsif self.is_hg?
        return self.cmd_opt.split(" ")[1].split("/")[-1] if !self.cmd_opt.empty?
      end
    end

    # extract the user name from the command
    def username_from_cmd
      if self.is_git?
        return self.cmd_opt.gsub("'","").split("/")[0] if !self.cmd_opt.empty?
      elsif self.is_hg?
        return self.cmd_opt.split(" ")[1].split("/")[0] if !self.cmd_opt.empty?
      end
    end

    # the exec of the command
    def run
      if self.is_git?
        self.aqlog("Running command : git-shell #{@cmd_cmd} '#{@real_path}'")
        if system(Settings.defaults.gitshell, "-c", "#{@cmd_cmd} '#{@real_path}'")
          self.aqlog("\t\tOK")
        else
          self.aqlog("\t\tKO")
        end
      elsif self.is_hg?
        hg_commands = self.fresh_cmd.split(" ")
        added_path = Settings.defaults.user_home + "/" +
                Settings.defaults.user_name + "/" +
                Settings.defaults.repo_hg_path
        hg_command = "#{hg_commands[0]} #{hg_commands[1]} #{added_path}/#{hg_commands[2]} #{hg_commands[3]} #{hg_commands[4]}"
        cmd_to_run = hg_command
        self.aqlog("Running command : #{cmd_to_run}")
        if system(cmd_to_run)
          self.aqlog("\t\tOK")
        else
          self.aqlog("\t\tKO")
        end
      end
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
          if command.is_git?
            a_repo = AqRepository.find_by_path(repo_path)
          elsif command.is_hg?
            a_repo = AqRepository.find_by_path(repo_path.to_s + "/.hg")
          end
          if a_repo
            command.aqlog("Found repo in db : #{a_repo.name}")
          else
            command.aqlog("Couldn't find the repository #{repo_name}")
            exit(1)
          end
          a_right = Right.find(:all, :conditions => ["user_id = ? AND aq_repository_id = ?", command.user_id, a_repo.id]).first
          if a_right
            command.aqlog("#{command.user_login} has #{a_right.right} right")
            if command.is_git?
              if (command.is_read? || (a_right && a_right.right == "w")) && a_repo.public?
                command.run
              else
                command.aqlog("insufficiant rights for #{command.user_login}")
              end
            elsif command.is_hg?
              if (a_right && a_right.right == "w")
                command.run
              else
                command.aqlog("insufficiant rights for #{command.user_login}")
              end
            end
          elsif command.is_read?
            command.run
          else
            command.aqlog("insufficiant rights for #{command.user_login} (#{command.user_id})")
          end
        end
      else
        command.aqlog("Command Invalid !")
      end
    end
  end
end