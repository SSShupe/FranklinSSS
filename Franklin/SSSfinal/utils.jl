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

    io = IOBuffer()
    write(io, """<div class="post-cards">""")
    for post in list
        ps = splitext(post)[1]
        url = "/blog/$ps/"
        surl = strip(url, '/')

        title = pagevar(surl, :title)
        isnothing(title) && (title = ps)

        date_formatted = try
            Dates.format(Date(ps[1:10], DateFormat("y-m-d")), "U d, Y")
        catch
            ps[1:10]
        end

        cover = pagevar(surl, :featured_image)
        has_cover = cover isa String && !isempty(cover)

        text = extract_plain_text(joinpath("blog", post))
        words = split(text)
        nwords = length(words)
        read_time = max(1, round(Int, nwords / 200))
        excerpt = join(words[1:min(40, nwords)], " ")
        nwords > 40 && (excerpt *= "…")

        write(io, """<article class="post-card">""")
        write(io, """<div class="post-card-body">""")
        write(io, """<h2 class="post-card-title"><a href="$url">$title</a></h2>""")
        write(io, """<p class="post-card-meta">$date_formatted · $read_time min read</p>""")
        if has_cover
            write(io, """<a href="$url" class="post-card-image-link"><img src="$cover" alt="$title" class="post-card-image"></a>""")
        end
        write(io, """<p class="post-card-excerpt">$excerpt</p>""")
        write(io, """</div></article>""")
    end
    write(io, "</div>")
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

"""
    {{custom_taglist}}

Plug in the list of blog posts with the given tag
"""
function hfun_custom_taglist()::String
    tag = locvar(:fd_tag)
    rpaths = globvar("fd_tag_pages")[tag]
    sorter(p) = begin
        pubdate = pagevar(p, :published)
        if isnothing(pubdate)
            return Date(Dates.unix2datetime(stat(p * ".md").ctime))
        end
        return Date(pubdate, dateformat"d U Y")
    end
    sort!(rpaths, by=sorter, rev=true)

    io = IOBuffer()
    write(io, """<ul class="blog-posts">""")
    # go over all paths
    for rpath in rpaths
        write(io, "<li><span><i>")
        url = get_url(rpath)
        title = pagevar(rpath, :title)
        pubdate = pagevar(rpath, :published)
        if isnothing(pubdate)
            date = "$curyear-$curmonth-$curday"
        else
            date = Date(pubdate, dateformat"d U Y")
        end
        # write some appropriate HTML
        write(io, """$date</i></span><a href="$url">$title</a>""")
    end
    write(io, "</ul>")
    return String(take!(io))
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
        push!(large_urls, prs["sizes"]["size"][12][:source])
    end
    io = IOBuffer()
    for i in 1:25
        write(io, """<figure><img src="$(large_urls[i])" alt="$(titles[i])"/><figcaption><em>$(titles[i])</em></figcaption></figure><br>""")
    end
    return String(take!(io))
end

function hfun_date()
    d = locvar("date")
    return Dates.format(d, "U d, Y")
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

