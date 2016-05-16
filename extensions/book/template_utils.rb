module Book
  module TemplateUtils
    # Load a template from the book/templates directory
    # Returns a Haml::Engine object ready to render
    def load_template(file)
      path = File.join("extensions/book/templates", file)
      Haml::Engine.new(File.read(path), :format => :xhtml)
    end

    # Expects a working_dir method to be available in execution scope
    def build_page_from_template(filename, dir = "OEBPS")
      template = load_template("#{filename}.haml")
      Dir.chdir(File.join(working_dir, dir)) do
        File.open(filename, "w") { |f| f.puts template.render(Object.new, :book => book) }
      end
    end

    def clean_directory(dirname)
      valid_start_chars = /[A-z]/
      valid_start_chars.freeze
      return false unless dirname.chr.match(valid_start_chars)
      FileUtils.rm_rf(dirname) if Dir.exist?(dirname)
      Dir.mkdir(dirname)
    end
  end
end
