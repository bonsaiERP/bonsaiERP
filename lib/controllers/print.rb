module Controllers::Print
  private

    def print_pdf(template, name)
      html = render_to_string template, layout: 'application.print'

      save_and_generate_pdf html

      # send_file
      #send_file File.read("#{full_path_name}.pdf"), filename: "#{name}.pdf"
      send_file "#{full_path_name}.pdf", filename: "#{name}.pdf"
    end

    def save_and_generate_pdf(html)
      save_printed html
      generate_phantom_pdf
    end

    def save_printed(html)
      f = File.new("#{full_path_name}.html", 'w+')
      f.write(html)
      f.close
    end

    def print_name
      @print_name ||= SecureRandom.urlsafe_base64
    end

    def full_path_name
      @full_path_name ||= "/tmp/#{print_name}"
    end

    def generate_phantom_pdf
      script = Rails.root.join('app', 'assets', 'javascripts', 'print', 'print.js')

      %x[phantomjs #{script} #{full_path_name}.html #{full_path_name}.pdf]
    end
end
