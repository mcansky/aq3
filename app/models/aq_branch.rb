require 'grit'
include Grit

class AqBranch < ActiveRecord::Base
  belongs_to :aq_repository
  has_many :commits, :class_name => "AqCommit", :order => "committed_time"
  has_many :files, :class_name => "AqFile", :foreign_key => "aq_branch_id"

  # update AqBranch using GritRepoBranch commits
  # starts by comparing commit counts to determine how many commits need
  # to be treated
  def grit_update
    grit_repo = Repo.new(self.aq_repository.path)
    new_commits_count = grit_repo.commit_count(self.name) - self.commits.count
    count = 0
    while (count < new_commits_count)
      commits = grit_repo.commits(self.name, 10, count)
      commits.each do |c|
        if not self.commits.find_by_sha(c.id)
          a_commit = AqCommit.new(:sha => c.id,
            :log => c.message,
            :author_name => c.author.name,
            :created_at => c.committed_date,
            :committed_time => c.committed_date)
          c.diffs.each do |diff|
            a_file = nil
            begin
              a_file = self.files.find_by_path(diff.b_path)
            rescue
            end
            if !a_file
              a_file = AqFile.new(:name => diff.b_path.split("/").last,
                :path => diff.b_path)
            end
            self.files << a_file if !a_file.branch
            self.aq_repository.files << a_file if !a_file.repository
            a_commit.aq_files << a_file
          end
          a_commit.author = self.aq_repository.owner
          self.commits << a_commit
          self.save
        end
      end
      diff_c = new_commits_count - count
      if (diff_c > 10)
        count += 10
      else
        count += diff_c
      end
    end
  end

  def purge
    self.files.each do |f|
      f.destroy
    end
    self.commits.each do |c|
      c.purge
      c.destroy
    end
  end
  
  def file(path)
    self.files.find_by_path(path)
  end
end
