

namespace :sprint do
  desc 'TODO'
  task setup: :environment do
    Rake::Task['db:migrate'].invoke
  end

  # Pull
  task :pull, [:repo] do |t, args|
    args.with_defaults(repo: 'master')
    system  'git pull '
    system  "git checkout #{args.repo}"
    system 'yarn install'
    system 'bundle'
    Rake::Task['db:migrate'].invoke
  end

  # Pull
  task :dbreset do |t|
    Rake::Task['db:migrate:reset'].invoke
    Rake::Task['db:seed'].invoke
  end

  # Pull Task
  task :p, [:repo] => :pull

  task :seed, [:repo] => :dbreset
end
