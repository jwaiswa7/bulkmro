namespace :sprint do
  desc "TODO"
  task setup: :environment do
    Rake::Task["db:migrate"].invoke
  end

  # Pull
  task :pull, [:repo] do |t,args|
    args.with_defaults(:repo => "master")
    system  "git pull origin #{args.repo}"
    system 'yarn install'
    system 'bundle'
    Rake::Task["db:migrate"].invoke
  end

  # Pull
  task :dbreset do |t|
    system 'rm db/schema.rb'
    Rake::Task["db:reset"].invoke
  end

  task :seed do |t|
    Rake::Task["db:migrate"].invoke
    Rake::Task["db:seed"].invoke
  end

  # Pull Task
  task :p, [:repo] => :pull
end