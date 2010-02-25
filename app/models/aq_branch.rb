class AqBranch < ActiveRecord::Base
  belongs_to :aq_repository
  has_many :commits, :class_name => "AqCommit", :order => "committed_time"

  # update AqBranch using GritRepoBranch commits
  # starts by comparing commit counts to determine how many commits need
  # to be treated
  def grit_update
    grit_repo = Repo.new(self.aq_repository.repo_path)
    new_commits_count = grit_repo.commit_count(self.name) - self.commits.count
    count = 0
    while (count < new_commits_count)
      commits = grit_repo.commits(self.name, 10, count)
      commits.each do |c|
        if not AqCommit.find_by_sha(c.id)
          a_commit = AqCommit.new(:sha => c.id,
            :log => c.message,
            :author_name => c.author.name,
            :created_at => c.committed_date,
            :committed_time => c.committed_date)
          self.commits << a_commit
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
    self.commits.each { |c| c.destroy }
  end
end
