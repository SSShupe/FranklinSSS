<!--
Add here global page variables to use throughout your
website.
The website_* must be defined for the RSS to work
-->
@def website_title = "The New SSS Blog"
@def website_url   = "https://alt.ssshupe.com"

@def author = "Steven Shupe"

<!--
Supported frontmatter variables for blog posts (set these in the +++ block):

  title           = "Post Title"          # page title and og:title
  date            = Date(YYYY, MM, DD)    # publication date
  featured_image  = "https://..."         # cover image (local /assets/file.jpg or full URL)
                                          #   used in: post card, og:image, page header
  description     = "One sentence summary" # used in: og:description (social share cards)
                                           # if omitted, falls back to site description

Example post frontmatter:
  +++
  title = "My Post"
  date = Date(2026, 5, 1)
  featured_image = "/assets/my-photo.jpg"
  description = "A short summary for social sharing."
  +++
-->
@def featured_image = ""
@def description = ""

@def mintoclevel = 2

<!-- Stuff related to the site styling -->
@def div_content = "container"

<!--
Add here files or directories that should be ignored by Franklin, otherwise
these files might be copied and, if markdown, processed by Franklin which
you might not want. Indicate directories by ending the name with a `/`.
-->
@def ignore = ["node_modules/", "franklin", "franklin.pub"]

<!--
Add here global latex commands to use throughout your
pages. It can be math commands but does not need to be.
For instance:
* \newcommand{\phrase}{This is a long phrase to copy.}
-->
\newcommand{\R}{\mathbb R}
\newcommand{\scal}[1]{\langle #1 \rangle}
