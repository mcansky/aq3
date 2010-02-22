require 'pathname'

class AqRepository < ActiveRecord::Base
  before_save :repo_path
  after_save :repo_init
  
  private
  def repo_path
    # root dir is system home folder, need to exist prior to app launch
    root_dir = Pathname(Settings.application.root_dir)
    
    # base dir is aq_git user home folder, need to exist prior to app launch
    base_dir = root_dir + Settings.application.repo_user
    
    # git_dir is where the repositories are gonna be stored, creating if needed
    git_dir = base_dir + Settings.application.repo_git_path
    git_dir.mkdir if base_dir.exist? && !git_dir.exist?
    
    # repo dir is the repository own path
    repo_dir = git_dir + self.name
    repo_dir.mkdir if !repo_dir.exist?
    
    # the dot git dir is the .git located in the repository
    dot_git = repo_dir + ".git"
    dot_git.mkdir if !dot_git.exist?
    
    self.path = repo_dir.to_s
  end
  
  def repo_init
    dirs = { "hooks" => nil,
      "info" => nil,
      "objects" => {"info" => nil, "pack" => nil},
      "refs" => {"heads"=> nil, "tags" => nil}}
    files = ["HEAD", "config", "description"]
    
    dot_git = Pathname(self.path) + ".git"

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