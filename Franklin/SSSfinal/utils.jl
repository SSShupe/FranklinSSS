using Dates
using HTTP
using XMLDict
using StatsBase

"""
    {{blogposts}}

Plug in the list of blog posts as styled cards with cover image, excerpt, and reading time.
"""
@delay function hfun_blogposts()
    list = readdir("blog")
    filter!(f -> endswith(f, ".md") && !startswith(f, "index"), list)
    sort!(list, rev=true)  # YYYY-MM-DD filenames sort correctly in reverse

    posts_per_page = 5
    npost  = length(list)
    npages = max(1, ceil(Int, npost / posts_per_page))

    io = IOBuffer()
    write(io, """<div id="blog-paginator">""")

    for pg in 1:npages
        chunk = list[(pg-1)*posts_per_page + 1 : min(pg*posts_per_page, npost)]

        write(io, """<div class="blog-page" id="page-$pg">""")
        write(io, """<div class="post-cards">""")

        for post in chunk
            ps   = splitext(post)[1]
            url  = "/blog/$ps/"
            surl = strip(url, '/')

            title = pagevar(surl, :title)
            isnothing(title) && (title = ps)

            date_formatted = try
                Dates.format(Date(ps[1:10], DateFormat("y-m-d")), "E U d, Y")
            catch
                ps[1:10]
            end

            text      = extract_plain_text(joinpath("blog", post))
            words     = split(text)
            nwords    = length(words)
            read_time = max(1, round(Int, nwords / 200))
            excerpt   = join(words[1:min(40, nwords)], " ")
            nwords > 40 && (excerpt *= "…")

            write(io, """<article class="post-card">""")
            write(io, """<div class="post-card-body">""")
            write(io, """<h2 class="post-card-title"><a href="$url">$title</a></h2>""")
            write(io, """<p class="post-card-meta">$date_formatted · $read_time min read</p>""")
            write(io, """<p class="post-card-excerpt">$excerpt</p>""")
            write(io, """</div></article>""")
        end

        write(io, """</div>""")  # .post-cards

        if npages > 1
            write(io, """<nav class="pagination">""")
            if pg > 1
                write(io, """<a class="pagination-newer" href="#page-$(pg-1)">← Later</a>""")
            end
            if pg < npages
                write(io, """<a class="pagination-older" href="#page-$(pg+1)">Earlier →</a>""")
            end
            write(io, """</nav>""")
        end

        write(io, """</div>""")  # .blog-page
    end

    write(io, """</div>""")  # #blog-paginator

    write(io, """
<script>
(function () {
  function showPage() {
    var hash = window.location.hash;
    var id   = (hash && hash.startsWith('#page-')) ? hash.slice(1) : 'page-1';
    document.querySelectorAll('#blog-paginator .blog-page').forEach(function (p) {
      p.style.display = 'none';
    });
    var target = document.getElementById(id);
    if (target) target.style.display = 'block';
  }

  // Intercept pagination clicks so the browser doesn't jump to the anchor.
  document.querySelectorAll('#blog-paginator .pagination-link').forEach(function (a) {
    a.addEventListener('click', function (e) {
      e.preventDefault();
      history.pushState(null, '', this.getAttribute('href'));
      showPage();
      document.getElementById('blog-paginator').scrollIntoView({ block: 'start' });
    });
  });

  window.addEventListener('popstate', showPage);
  showPage();
}());
</script>
""")

    return String(take!(io))
end

function extract_plain_text(filepath)
    content = read(filepath, String)
    content = replace(content, r"^\+\+\+.*?\+\+\+"s => "")   # frontmatter
    content = replace(content, r"~~~.*?~~~"s => "")            # raw HTML blocks
    content = replace(content, r"_Posted\s+\{\{[^}]+\}\}_" => "")  # "_Posted {{date}}_" boilerplate
    content = replace(content, r"\{\{[^}]*\}\}" => "")        # Franklin directives
    content = replace(content, r"\[([^\]]*)\]\([^)]*\)" => s"\1")  # [text](url) → text
    content = replace(content, r"[*_`#>]+" => " ")            # markdown syntax
    content = replace(content, r"<[^>]+>" => " ")             # any stray HTML tags
    content = strip(replace(content, r"\s+" => " "))
    return content
end

function hfun_try()
    io = IOBuffer()
    write(io, """<ul class="blog-posts">""")
    list = reverse(readdir("blog/"))
    # titles = ["List", "of", "fake", "titles"]
    filter!(x -> !startswith(x, "index"), list)
    titles = [pagevar("blog/" * i, "title") for i in list]
    dates = map(x -> x[1:10], list)
    to_dtime = map(x -> x = Date(x, DateFormat("y-m-d")), dates)
    dates_formatted = map(x -> Dates.format(x, "U d, Y"), to_dtime)
    rpaths = map(x -> replace(x, r"\.md$" => ""), list)
    for i in 1:length(list)
        write(io, "<li><span><i>")
        write(io, """$(dates_formatted[i])</i></span><a href="$(rpaths[i])">$(titles[i])</a>""")
    end
    write(io, "</ul>")
    return String(take!(io))
end

function hfun_photos()
    call = HTTP.get("https://www.flickr.com/services/rest/?method=flickr.people.getPublicPhotos&api_key=1a77359c736a2f7546c1797c832ff5cf&user_id=11155423%40N00&per_page=500&format=rest")
    last100 = String(call.body) |> parse_xml
    ids = String[]
    titles = String[]
    for i in sample(1:500, 25, replace=false)
        push!(ids, last100["photos"]["photo"][i][:id])
        push!(titles, last100["photos"]["photo"][i][:title])
    end
    sizeCallList = String[]
    for id in ids
        push!(sizeCallList, "https://www.flickr.com/services/rest/?method=flickr.photos.getSizes&api_key=1a77359c736a2f7546c1797c832ff5cf&photo_id=$(id)&format=rest")
    end
    large_urls = String[]
    for p in sizeCallList
        r = HTTP.get(p)
        rs = String(r.body)
        prs = parse_xml(rs)
        sizes = prs["sizes"]["size"]
        idx = findfirst(s -> s[:label] == "Large", sizes)
        isnothing(idx) && (idx = findfirst(s -> s[:label] == "Medium 640", sizes))
        isnothing(idx) && (idx = 1)
        push!(large_urls, sizes[idx][:source])
    end
    io = IOBuffer()
    for i in 1:25
        write(io, """<figure><img src="$(large_urls[i])" alt="$(titles[i])"/><figcaption><em>$(titles[i])</em></figcaption></figure><br>""")
    end
    return String(take!(io))
end

function hfun_date()
    d = locvar("date")
    return Dates.format(d, "E U d, Y")
end

function lx_imgcap(lxc, _)
    url = Franklin.content(lxc.braces[1])
    caption = Franklin.content(lxc.braces[2])
    return """<figure><img src="$url" alt="$caption"><figcaption><em>$caption</em></figcaption></figure>"""
end

function hfun_featuredimage()
    img_url = locvar(:featured_image)
    (isnothing(img_url) || isempty(img_url)) && return ""
    return """<figure class="featured-image"><img src="$img_url" alt=""></figure>"""
end

