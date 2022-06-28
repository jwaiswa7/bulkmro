WickedPdf.config = {
  # exe_path: "/usr/local/bin/wkhtmltopdf" # use this exec path on mac m1 development environment
  exe_path: RbConfig::CONFIG['target_os'].match(/mswin|mingw|cygwin/i) ? Rails.root.join('bin', 'wkhtmltopdf.exe').to_s : Rails.root.join('bin', 'wkhtmltopdf').to_s
}
