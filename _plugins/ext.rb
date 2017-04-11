module Jekyll
    module Tags
        class TagGenerator < Generator
            def generate(site)
                dir_name = "_tags";
                Dir.mkdir(dir_name) unless File.exists?(dir_name)

                for tag in site.tags
                    tag_name = tag[0]
                    File.open(dir_name + "/#{tag_name}.md", "w") do |f|
                        f.puts(file_content(tag_name))
                    end
                end
            end

            private

            def humanize_tag(tag)
                tag.gsub("-", " ")
            end

            def file_content(tag)
                <<~HEREDOC
                    ---
                    permalink: /tag/#{tag}.html
                    layout: page_tag
                    tag: '#{tag}'
                    title: #{humanize_tag(tag)}
                    ---
                HEREDOC
            end
        end
    end
end
