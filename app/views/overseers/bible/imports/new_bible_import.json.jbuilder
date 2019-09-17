json.data (@bible_uploads) do |bible_upload|
  json.array! [
                  if bible_upload.status == 'Completed with Errors' || bible_upload.status == 'Failed'
                    row_action_button(bible_upload_log_overseers_bible_import_path(bible_upload), 'eye', 'View Log', 'info', :_blank)
                  end,
                  bible_upload.id.to_s,
                  bible_upload.import_type,
                  bible_upload.file.attachment.blob.filename,
                  status_badge(bible_upload.status),
                  bible_upload.updated_by.to_s,
                  format_date(bible_upload.created_at)
              ]
end

json.columnFilters [
                       [],
                       [],
                       BibleUpload.import_types.map {|k, v| {"label": k, "value": v.to_s}}.as_json,
                       [],
                       [],
                       [],
                       []
                   ]

json.recordsTotal BibleUpload.all.count
json.recordsFiltered @indexed_bible_uploads.count
json.draw params[:draw]
