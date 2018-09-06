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
  # Pull Task
  task :p, [:repo] => :pull

end