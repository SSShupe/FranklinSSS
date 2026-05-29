# SSSfinal — Claude session guide

Franklin.jl static site for alt.ssshupe.com. Goal: attractive, not-too-busy personal blog.
Owner is learning site internals — always show actual code changes, not just descriptions.

## Key files

| File/Dir | Purpose |
|---|---|
| `index.md` | Home page — uses `{{blogposts}}` template variable |
| `config.md` | Franklin config; sets `div_content = "container"` |
| `_css/franklin.css` | All styles — single CSS file, start here for any visual change |
| `_layout/` | HTML templates (head, navbar, foot, social_share, etc.) |
| `assets/` | Images and static files (e.g. `LRCorniche.jpg` = header photo) |
| `blog/` | Blog post markdown files |
| `utils.jl` | Franklin utility functions (e.g. `blogposts` hfun) |
| `wp_publish.py` | Publishes new posts to WordPress as drafts |
| `hooks/post-commit` | Git hook that calls `wp_publish.py` on new blog `.md` files |
| `setup_wp_hook.sh` | Run once to install the git hook on a new machine |

## Layout structure

```
<body>                         ← max-width: 720px, margin: auto (in franklin.css)
  <header>                     ← full-bleed background image (LRCorniche.jpg)
    <nav> … </nav>
  </header>
  <main>
    <div class="container">   ← Franklin wraps page content here
      … page content …
    </div>
  </main>
  <footer> … </footer>
</body>
```

## Dev server

```julia
julia -e "using Franklin; serve()"
```

## Windows gotcha

`python3` resolves to a broken Microsoft Store stub on this machine.
The git hook uses `python` → `C:\Python314\python` instead. If Python issues recur, check that path.
