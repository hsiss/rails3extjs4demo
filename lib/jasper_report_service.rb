class JasperReportService
  def self.generate_report(xml_data, report_design, output_type, select_criteria)
    report_design << '.jasper' if !report_design.match(/\.jasper$/)
    interface_classpath= "#{RAILS_ROOT}/tools/jasper_report/bin" 
    Dir.foreach("#{RAILS_ROOT}/tools/jasper_report/lib") do |file|
      interface_classpath << ";#{RAILS_ROOT}/tools/jasper_report/lib/"+file if (file != '.' and file != '..' and file.match(/\.jar$/))
    end

    cmd_line = "java -Djava.awt.headless=true -cp \"#{interface_classpath}\" XmlJasperInterface -o#{output_type} -f#{RAILS_ROOT}/app/jasper_reports/#{report_design} -x#{select_criteria}"
#    puts cmd_line
    result = nil
    IO.popen cmd_line, "w+b" do |pipe|
      pipe.write xml_data
      pipe.close_write
      result = pipe.read
      pipe.close
    end
    return result
  end
end