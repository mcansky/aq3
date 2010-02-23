require 'pathname'

class AqRepository < ActiveRecord::Base
  before_save :repo_path
  after_save :repo_init
  has_many :rights
  has_many :users, :throught => :rights

  private
  def current_user
  	@current_user_session = UserSession.find
  	@current_user = @current_user_session && @current_user_session.record
  	return @current_user
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

    # git_dir is where the repositories are gonna be stored, creating if needed
    # /home/aq_git/git
    git_dir = base_dir + Settings.application.repo_git_path
    git_dir.mkdir if base_dir.exist? && !git_dir.exist?

    # repo dir is the repository own path
    # /home/aq_git/git/username
    repo_dir = git_dir + current_user.login
    repo_dir.mkdir if !repo_dir.exist?

    # the dot git dir is the .git located in the repository
    # /home/aq_git/git/username/reposit.git
    dot_git = repo_dir + (self.name + ".git")
    dot_git.mkdir if !dot_git.exist?

    self.path = dot_git.to_s
  end

  # initilizing the repository
  def repo_init
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
      File.open("#{dot_git}/#{l_file}", "a") do |file_out|
        template_dir = "templates"
        template_dir += "-bare" if bare
        IO.foreach("#{Rails.root}/config/#{template_dir}/#{l_file}") { |w| file_out.puts(w) }
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
      Dir.mkdir(root + s_dir)
      l_mkdirs(root + s_dir, dir_hash[s_dir]) if dir_hash[s_dir]
    end
  end

end
