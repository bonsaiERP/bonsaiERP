class DownloadController < ApplicationController
  layout false

  # GET /download/file/name
  def download_pdf
    send_file "/tmp/#{params[:file]}.pdf", filename: "#{params[:name]}.pdf"
  end
end
