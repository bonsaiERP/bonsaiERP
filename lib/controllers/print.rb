module Controllers::Print
  private

    def print_pdf(html, name)
      save_printed html, print_name
      execute_phantom "#{print_name}"

      send_file "#{print_name}.pdf", filename: name
    end

    def save_printed(html, prn_name)
      f = File.new("#{prn_name}.html", 'w+')
      f.write(html)
      f.close
    end

    def print_name
      @print_name ||= '/tmp/' + SecureRandom.urlsafe_base64
    end

    def execute_phantom(prn_name, script = 'print.js')
      script = Rails.root.join('app', 'assets', 'javascripts', 'print', script)

      %x[phantomjs #{script} #{prn_name}.html #{prn_name}.pdf]
    end
end
