module Book
  class Chapter < Middleman::Sitemap::Resource
    attr_reader :book

    # Pass in a reference to the parent Book extension for later use
    def initialize(store, path, source, book)
      super(store, path, source)
      @book   = book
    end

    def title
      data.title
    end

    def author
      data.author || @book.author
    end

    def rank
      data.sort_order
    end

    def body
      render layout: false
    end

    def next_chapter
      @book.chapters.select { |p| p.rank > rank }.min_by(&:rank)
    end

    def prev_chapter
      @book.chapters.select { |p| p.rank < rank }.max_by(&:rank)
    end

    # Generate a navpoint tag for epub toc.ncx navmap
    def generate_navpoint
      {
        :src        => "#{title.slugify}.xhtml",
        :play_order => nil,
        :id         => nil,
        :text       => title
      }
    end

    # Generate an item tag for epub manifest
    def generate_item_tag
      {
        :href       => "#{title.slugify}.xhtml",
        :id         => "c#{rank}",
        :media_type => "application/xhtml+xml"
      }
    end

    # Generate an itemref tag for epub spine
    def idref
      "c#{rank}"
    end

    def format_for_epub
      doc = Nokogiri::XML((render :layout => "epub_chapter"))

      # change absolute image src locations to relative
      images = doc.css("img")
      images.each do |image|
        image["src"] = image["src"][1..-1] if image["src"].start_with? "/"
      end

      doc.to_xml
    end
  end
end
