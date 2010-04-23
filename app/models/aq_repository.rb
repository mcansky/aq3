require 'pathname'
require 'grit'
include Grit

class AqRepository < ActiveRecord::Base
  before_save :repo_path
  after_save :repo_init
  has_many :rights
  has_many :users, :through => :rights
  has_many :beans
  has_many :branches, :class_name => "AqBranch"
  has_many :commits, :class_name => "AqCommit", :through => :branches, :order => "committed_time"
  has_many :forks, :class_name => "AqRepository", :foreign_key => "parent_id"
  belongs_to :parent, :class_name => "AqRepository", :foreign_key => "parent_id"
  has_many :files, :class_name => "AqFile", :foreign_key => "aq_repository_id"

  def owner
    a_right = self.rights.find(:all, :conditions => ["role = ?",'o']).first
    if a_right
      owner = a_right.user
    else
      owner = nil
    end
  end

  def owner=(user)
    a_right = Right.new
    a_right.user = user
    a_right.aq_repository = self
    a_right.right = 'w'
    a_right.role = 'o'
    self.rights << a_right
    a_right.save
  end

  def committers
    some_rights = self.rights.find(:all, :conditions => ["role = ? AND status != ?",'c', 'p'])
    r_committers = []
    some_rights.each do |a_right|
      r_committers << a_right.user
    end
    return r_committers
  end

  def public_path
    if self.is_git?
    split_path = self.path.split("/")
    ppath = Settings.application.repo_user + "@" +
              Settings.application.hostname + ":" +
              split_path[-2] + "/" + split_path[-1]
    elsif self.is_hg?
      split_path = self.path.split("/")
      ppath = "ssh://" + Settings.application.repo_user + "@" +
                Settings.application.hostname + "/" +
                split_path[-3] + "/" + split_path[-2]
    end
  end

  def is_git?
    return true if self.kind == "git"
    return false
  end

  def is_hg?
    return true if self.kind == "hg"
    return false
  end

  def repo_update
    self.grit_update if self.is_git?
    self.hg_update if self.is_hg?
  end

  # update branches stored in db
  def grit_update
    grit_repo = Repo.new(self.path)
    count = 0
    grit_repo.branches.each do |b|
      self.branches << AqBranch.new(:name => b.name) if not self.branches.find_by_name(b.name)
    end
    self.branches.each do |b|
      b.grit_update
      count += 1
    end
    aq_logger(Settings.logs.scm, "User #{self.owner}, Repository : #{self.name}, #{count} branches treated.")
    self.save
  end
  
  # update branches stored in db (hg)
  def hg_update
    amp_repo = Repositories::LocalRepository.new(self.path)
    
  end

  # purge branches stored in db
  def purge
    self.branches.each do |b|
      b.purge
      b.destroy
    end
  end

  def orphan_files
    self.files.find(:all, :conditions => ["aq_branch_id = ?", nil])
  end

  def file(path)
    self.files.find_by_path(path)
  end

  def branch(name)
    self.branches.find_by_name(name)
  end

  # generating the repo path
  #
  # check the config/application.yml file for setup
  def repo_path
    # root dir is system home folder, need to exist prior to app launch
    # /home
    root_dir = Pathname(Settings.application.root_dir)

    # base dir is aq_git user home folder, need to exist prior to app launch
    # /home/aq_git
    base_dir = root_dir + Settings.application.repo_user

    if self.kind == "git"
      repo_path = Settings.application.repo_git_path
    elsif self.kind == "hg"
      repo_path = Settings.application.repo_hg_path
    end

    # git_dir is where the repositories are gonna be stored, creating if needed
    # /home/aq_git/git or /home/aq_git/hg
    scm_dir = base_dir + repo_path
    scm_dir.mkdir if base_dir.exist? && !scm_dir.exist?

    # repo dir is the repository own path
    # /home/aq_git/git/username
    if self.owner
      repo_dir = scm_dir + self.owner.login
    elsif current_user
      repo_dir = scm_dir + current_user.login
    end
    repo_dir.mkdir if !repo_dir.exist?

    # the dot dir is the .git (or .hg) located in the repository
    # /home/aq_git/git/username/reposit.git
    if self.is_git?
      dot_dir = repo_dir + (self.name + ".#{self.kind}")
      dot_dir.mkdir if !dot_dir.exist?
    elsif self.is_hg?
      dot_dir = repo_dir + self.name
      dot_dir.mkdir if !dot_dir.exist?
      dot_dir += ".hg"
      dot_dir.mkdir if !dot_dir.exist?
    end

    self.path = dot_dir.to_s
  end

  def fork(parent_repo)
    if !current_user.aq_repositories.find_by_name(parent_repo.name)
      self.name = parent_repo.name
      self.kind = parent_repo.kind
      self.repo_path
      system("cp -r #{parent_repo.path}/* #{self.path}")
      self.parent = parent_repo
      self.owner = current_user
      self.repo_update
    else
      redirect_to parent_repo
    end
  end

  def aq_logger(logfile, message)
    File.open(Rails.root + "log/" + logfile, "a") do |log|
		  log.puts Time.now.strftime("%d/%m/%y %H:%M ") + message
	  end
  end

  private
  def current_user
  	@current_user_session = UserSession.find
  	@current_user = @current_user_session && @current_user_session.record
  	return @current_user
  end

  # initilizing the repository
  def repo_init
    if self.kind == "git"
      git_repo_init
    elsif self.kind == "hg"
      hg_repo_init
    end
  end

  def hg_repo_init
    File.umask(0001)
    dirs = {"store" => nil}
    files = ["00changelog.i", "requires"]
    dot_hg = Pathname(self.path)

    # creating dirs
    l_mkdirs(dot_hg, dirs)

    # creating files
    files.each do |l_file|
      if !File.exist?("#{dot_hg}/#{l_file}")
        File.open("#{dot_hg}/#{l_file}", "a") do |file_out|
          template_dir = "hg_templates"
          IO.foreach("#{Rails.root}/config/#{template_dir}/#{l_file}") { |w| file_out.puts(w) }
        end
      end
    end
  end

  def git_repo_init
    File.umask(0001)
    dirs = { "hooks" => nil,
      "info" => nil,
      "objects" => {"info" => nil, "pack" => nil},
      "refs" => {"heads"=> nil, "tags" => nil}}
    files = ["HEAD", "config", "description"]

    dot_git = Pathname(self.path)

    # creating the dirs
    l_mkdirs(dot_git, dirs)

    # creating base files
    bare = true
    files.each do |l_file|
      if !File.exist?("#{dot_git}/#{l_file}")
        File.open("#{dot_git}/#{l_file}", "a") do |file_out|
          template_dir = "templates"
          template_dir += "-bare" if bare
          IO.foreach("#{Rails.root}/config/#{template_dir}/#{l_file}") { |w| file_out.puts(w) }
        end
      end
    end

  end

  # l_mkdirs method creates dirs using a hash
  #
  # root is a pathname object
  # dir_hash a hash containing dirs to create in root
  # if subdirs need to be created in those then the key points to another hash
  def l_mkdirs(root, dir_hash)
    dir_hash.each_key do |s_dir|
      Dir.mkdir(root + s_dir) if !(root + s_dir).exist?
      l_mkdirs(root + s_dir, dir_hash[s_dir]) if dir_hash[s_dir]
    end
  end

end
