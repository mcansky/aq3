require "rubygems"
require "grit"
include Grit

namespace :git do
  desc "Check git repository for new commits"
  task(:pull => :environment) do
    
    if (ENV['RNAME'])
      repository = AqRepository.find_by_name(ENV['RNAME'])
      repository.grit_update if repository.kind == "git"
      repository.save
    else
      repositories = AqRepository.find(:all)
      repositories.each do |repo|
        repo.grit_update if repo.kind == "git"
        repo.save
      end
    end
  end
  
  desc "Purge DB from commits and branches"
  task(:purge => :environment) do
    repositories = AqRepository.find(:all)
    repositories.each do |repo|
      repo.purge if repo.kind == "git"
    end
  end
end