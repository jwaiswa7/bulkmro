json.data (@bible_file_uploads) do |bible_upload|
  json.array! [
                  bible_upload.id.to_s,
                  bible_upload.import_type,
                  bible_upload.file_name,
                  bible_upload.status,
                  bible_upload.updated_by.to_s,
                  format_date(bible_upload.created_at),
                  if bible_upload.status == 'Complete'
                    link_to('View Log', bible_file_upload_log_overseers_bible_sales_orders_import_path(bible_upload), target: '_blank')
                  end
              ]
end

json.columnFilters [
                       [],
                       BibleFileUpload.import_types.map {|k, v| {"label": k, "value": v.to_s}}.as_json,
                       [],
                       [],
                       [],
                       [],
                       []
                   ]


json.recordsTotal BibleFileUpload.all.count
json.recordsFiltered @bible_file_uploads.count
json.draw params[:draw]
