require 'grit'
include Grit

namespace :git do
  desc "Check git repository for new commits"
  task(:pull => :environment) do
    repositories = AqRepository.find(:all)
    repositories.each do |repo|
      repo.update
      repo.save
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