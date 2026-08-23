+++

title = "Photos from SSS Flickr"
date = "2026-08-21"
draft = false

+++

A random selection of 27 of the last 500 pictures from my [Flickr](https://flickr.com/ssshupe/photos) feed, updated each time you visit or reload the page.

~~~
<style>
    .photos-header {
        margin-bottom: 2rem;
    }

    .photos-header h1 {
        font-family: 'Fira Sans', system-ui, sans-serif;
        font-size: 1.85rem;
        font-weight: 700;
        margin-bottom: 0.4rem;
    }

    .photos-header p {
        font-family: 'Lora', Georgia, serif;
        font-size: 0.9rem;
        color: #888;
    }

    .photo-grid {
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        gap: 1.25rem;
        margin-top: 1.5rem;
    }

    .photo-grid figure {
        margin: 0;
        cursor: pointer;
    }

    .photo-grid figure img {
        width: 100%;
        aspect-ratio: 4 / 3;
        object-fit: cover;
        display: block;
        transition: opacity 0.15s ease;
    }

    .photo-grid figure:hover img {
        opacity: 0.88;
    }

    .photo-grid figcaption {
        font-family: 'Lora', Georgia, serif;
        font-size: 0.75rem;
        font-style: italic;
        color: #888;
        margin-top: 0.4rem;
        line-height: 1.4;
        text-align: center;
    }

    .photos-loading,
    .photos-error {
        font-family: 'Lora', Georgia, serif;
        font-style: italic;
        color: #888;
        font-size: 0.95rem;
        padding: 2rem 0;
    }

    .photos-error {
        color: #c1121f;
    }

    /* Lightbox */
    .lightbox {
        display: none;
        position: fixed;
        inset: 0;
        background: rgba(0, 0, 0, 0.88);
        z-index: 1000;
        align-items: center;
        justify-content: center;
        flex-direction: column;
        padding: 1.5rem;
        cursor: zoom-out;
    }

    .lightbox.open {
        display: flex;
    }

    .lightbox img {
        max-width: min(90vw, 1000px);
        max-height: 80vh;
        object-fit: contain;
        display: block;
        box-shadow: 0 8px 40px rgba(0, 0, 0, 0.6);
    }

    .lightbox figcaption {
        font-family: 'Lora', Georgia, serif;
        font-size: 0.9rem;
        font-style: italic;
        color: #ccc;
        margin-top: 0.85rem;
        text-align: center;
    }

    .lightbox-close {
        position: fixed;
        top: 1rem;
        right: 1.25rem;
        color: #fff;
        font-size: 1.75rem;
        line-height: 1;
        cursor: pointer;
        opacity: 0.7;
        background: none;
        border: none;
        font-family: inherit;
        padding: 0.25rem 0.5rem;
        transition: opacity 0.15s;
    }

    .lightbox-close:hover {
        opacity: 1;
    }

    @media (max-width: 640px) {
        .photo-grid {
            grid-template-columns: repeat(2, 1fr);
            gap: 0.75rem;
        }
    }

    @media (max-width: 400px) {
        .photo-grid {
            grid-template-columns: 1fr;
        }
    }
</style>

<div id="photo-grid-container">
    <p class="photos-loading">Loading photos…</p>
</div>

<div class="lightbox" id="lightbox" role="dialog" aria-modal="true" aria-label="Photo viewer">
    <button class="lightbox-close" id="lightbox-close" aria-label="Close">&times;</button>
    <img id="lightbox-img" src="" alt="">
    <figcaption id="lightbox-caption"></figcaption>
</div>
<script>
    (function () {
        var API_KEY = '1a77359c736a2f7546c1797c832ff5cf';
        var USER_ID = '11155423%40N00';
        var TOTAL = 500;
        var PICK = 27;

        var container = document.getElementById('photo-grid-container');
        var lightbox = document.getElementById('lightbox');
        var lbImg = document.getElementById('lightbox-img');
        var lbCap = document.getElementById('lightbox-caption');
        var lbClose = document.getElementById('lightbox-close');

        function sample(arr, n) {
            var copy = arr.slice();
            var result = [];
            for (var i = 0; i < n && copy.length; i++) {
                var idx = Math.floor(Math.random() * copy.length);
                result.push(copy.splice(idx, 1)[0]);
            }
            return result;
        }

        function openLightbox(src, title) {
            lbImg.src = src;
            lbImg.alt = title;
            lbCap.textContent = title;
            lightbox.classList.add('open');
            document.body.style.overflow = 'hidden';
            lbClose.focus();
        }

        function closeLightbox() {
            lightbox.classList.remove('open');
            lbImg.src = '';
            document.body.style.overflow = '';
        }

        lbClose.addEventListener('click', closeLightbox);

        lightbox.addEventListener('click', function (e) {
            if (e.target === lightbox) closeLightbox();
        });

        document.addEventListener('keydown', function (e) {
            if (e.key === 'Escape' && lightbox.classList.contains('open')) closeLightbox();
        });

        var url = 'https://www.flickr.com/services/rest/'
            + '?method=flickr.people.getPublicPhotos'
            + '&api_key=' + API_KEY
            + '&user_id=' + USER_ID
            + '&per_page=' + TOTAL
            + '&extras=url_l,url_m,url_sq,title'
            + '&format=json&nojsoncallback=1';

        fetch(url)
            .then(function (r) {
                if (!r.ok) throw new Error('Flickr API error: ' + r.status);
                return r.json();
            })
            .then(function (data) {
                var photos = data.photos && data.photos.photo;
                if (!photos || !photos.length) throw new Error('No photos returned');

                var picked = sample(photos, Math.min(PICK, photos.length));

                var grid = document.createElement('div');
                grid.className = 'photo-grid';

                picked.forEach(function (p) {
                    var src = p.url_l || p.url_m || p.url_sq || '';
                    var lrgSrc = p.url_l || p.url_m || src;
                    var title = p.title || '';
                    if (!src) return;

                    var fig = document.createElement('figure');
                    var img = document.createElement('img');
                    img.src = src;
                    img.alt = title;
                    img.loading = 'lazy';

                    var cap = document.createElement('figcaption');
                    cap.textContent = title;

                    fig.appendChild(img);
                    fig.appendChild(cap);

                    fig.addEventListener('click', function () {
                        openLightbox(lrgSrc, title);
                    });

                    grid.appendChild(fig);
                });

                container.textContent = '';
                container.appendChild(grid);
            })
            .catch(function (err) {
                container.innerHTML = '<p class="photos-error">Couldn\'t load photos. ' + err.message + '</p>';
            });
    }());
</script>
~~~
