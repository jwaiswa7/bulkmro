class SeedDump
  module Environment

    def dump_using_environment(env = {})
      Rails.application.eager_load!

      models = retrieve_models(env) - retrieve_models_exclude(env)

      limit = retrieve_limit_value(env)
      append = retrieve_append_value(env)
      models.each do |model|
        model = model.limit(limit) if limit.present?

        SeedDump.dump(model,
                      append: append,
                      batch_size: retrieve_batch_size_value(env),
                      exclude: retrieve_exclude_value(env),
                      file: retrieve_file_value(env),
                      import: retrieve_import_value(env))

        append = true # Always append for every model after the first
        # (append for the first model is determined by
        # the APPEND environment variable).
      end

      file = File.open(retrieve_file_value(env))
      overseer = Overseer.first
      overseer.file.attach(io: file, filename: retrieve_file_value(env).split('/').last)
      overseer.save

      puts Rails.application.routes.url_helpers.url_for(overseer.file)
    end
  end
end