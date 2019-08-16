module Jekyll
  class TagsGenerator < Generator
    safe true

    def generate(site)
      site.data["languages"].each do |lang, data|
        site.tags.each do |tag|
          posts = [tag[0], posts_by_lang(site, tag[0], lang), lang]
          build_subpages(site, "tag", posts)
        end
      end
    end

    def build_subpages(site, type, posts)
      posts[1] = posts[1].sort_by { |p| -p.date.to_f }
      puts posts[1]
      atomize(site, type, posts)
      paginate(site, type, posts)
    end

    def atomize(site, type, posts)
      path = "/#{posts[2]}/tag/#{posts[0]}".gsub(" ", "-").downcase
      atom = AtomPageTags.new(site, site.source, path, type, posts[0], posts[1])
      site.pages << atom
    end

    def paginate(site, type, posts)
      pages = Jekyll::Paginate::Pager.calculate_pages(posts[1], site.config["paginate"].to_i)
      (1..pages).each do |num_page|
        pager = Jekyll::Paginate::Pager.new(site, num_page, posts[1], pages)
        path = "/#{posts[2]}/tag/#{posts[0]}".gsub(" ", "-").downcase
        if num_page > 1
          path = path + "/page#{num_page}"
        end
        newpage = GroupSubPageTags.new(site, site.source, path, type, posts[0])
        newpage.pager = pager
        site.pages << newpage
      end
    end

    private

    def posts_by_lang(site, tag, lang)
      puts "Tag is: #{tag} and Lang is : #{lang}"
      site.posts.docs.select { |post| post.data["tags"].include?(tag) && post.data["lang"] == lang }
    end
  end

  class GroupSubPageTags < Page
    def initialize(site, base, dir, type, val)
      @site = site
      @base = base
      @dir = dir
      @name = "index.html"

      self.process(@name)
      self.read_yaml(File.join(base, "_layouts"), "tag.html")
      self.data["grouptype"] = type
      self.data[type] = val
    end
  end

  class AtomPageTags < Page
    def initialize(site, base, dir, type, val, posts)
      @site = site
      @base = base
      @dir = dir
      @name = "feed.xml"

      self.process(@name)
      self.read_yaml(File.join(base, "_layouts"), "feed.xml")
      self.data[type] = val
      self.data["grouptype"] = type
      self.data["posts"] = posts[0..9]
    end
  end
end
