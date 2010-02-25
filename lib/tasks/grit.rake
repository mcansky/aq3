namespace :git do
  desc "Check git repository for new commits"
  task(:pull => :environment) do
    begin
      # Try to require the preresolved locked set of gems.
      require File.expand_path('../.bundle/environment', __FILE__)
    rescue LoadError
      # Fall back on doing an unlocked resolve at runtime.
      require "rubygems"
      require "bundler"
      Bundler.setup
      require "grit"
    end
    
    if (ENV['RNAME'])
      repository = AqRepository.find_by_name(ENV['RNAME'])
      repository.grit_update
      repository.save
    else
      repositories = AqRepository.find(:all)
      repositories.each do |repo|
        repo.grit_update
        repo.save
      end
    end
  end
  
  desc "Purge DB from commits and branches"
  task(:purge => :environment) do
    repositories = AqRepository.find(:all)
    repositories.each do |repo|
      repo.purge
    end
  end
end