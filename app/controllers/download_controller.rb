class DownloadController < ApplicationController
  layout false

  # GET /download/file/name
  def download_pdf
    send_file "#{download_file}.pdf", filename: "#{params[:name]}.pdf"
  end

  private
    def download_file
      if File.exists?("/tmp/#{params[:file]}.pdf")
        "/tmp/#{params[:file]}"
      else
        "fail"
      end
    end
end
