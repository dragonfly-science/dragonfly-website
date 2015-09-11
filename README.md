# Dragonfly website generator

## Statically generated

The site is statically generated from the source. This means that it compiled,
and produces completely static files that are simply served from any webserver. 

It uses the [Hakyll](http://jaspervdj.be/hakyll/index.html) static site library,
which is managed by the code in the `haskell/` directory. 

## Concepts

#### This git repository is the database

There is no database behind the site, unless you consider the git repository as
the database. The structure is significantly more flexible than a relational
database, with directories and files being arranged in whatever way makes most
sense.

The content for the site is organised under the `content/` folder. Most of the
folders there should be fairly self explanatory. If you need to edit the site,
these are the files to make changes to. 

For example, to add a new new post you need to create a new file and directory
in the `content/posts/` directory.

`2015-01-02-my-exciting-blog-post.md`

:   This file has the content for the post. At the top of the file is a metadata
    section that can include information such as title, teaser, and author.

`2015-01-02-my-exciting-blog-post.md/`

:   A directory where all other associated files can go, such as a image files
    and there associated description files (more about that later).



#### The compiler defines how to interpret the files

The file `haskell/Site.hs` defines how to interpret the files, and how to map
them to urls (routes), which templates to use, and what fields are defined
in the templates.

#### Version and user control is managed by git

One big advantage with this approach comes from git and
[GitHub](https://www.github.com/dragonfly-science), which gives us good version
control and user management respectively.

When code changes are pushed to the correct branch (ocean-hakyll) of the  
[GitHub repo](https://www.github.com/dragonfly-science/website), our
deployhub will update the [staging site](https://www-staging.dragonfly.co.nz).
This takes less than a minute. 


## Templates

A typical page has the following structure:
```
<html>
  <head>
  </head>
  <body>
    <header>
      <nav>
      </nav>
    </header>
    <main>
      <div class="container">
        <div class="heading"></div>
        <div class="content"></div>
        <div class="content"></div>
      </div>
      <div class="container">
        <div class="marginal"></div>
        <div class="marginal"></div>
        <div class="content"></div>
      </div>
    </main>
    <footer>
      <div class="container">
      </div>
    </footer>
  </body>
</html>
```

The html body is divided into three components: the header, which contains the
navigation, the main block, which contains most of the page, and the footer,
which contains the contact information. The container element sets the margins, and all
content that is not full width should be inside a container block. Typical page
content is inside a content block. The default template includes everything outside
the main block. Page templates should include container and content blocks as appropriate.

### Breakpoints

Breakpoints are named after mountain bike trails in Aro Valley. There is a mysterious order to them.

  - [$transient](http://www.trailforks.com/trails/transient/): smallest
  - [$highbury-fling](http://tracks.org.nz/track/show/851): smallish
  - [$clinical](http://www.trailforks.com/trails/clinical/): medium
  - [$serendipity](http://www.trailforks.com/trails/serendipity-16954/): large

### Adding news posts

- `teaser.jpg` - ideally a square image at 500x500px
- banner - link this in the `banner-image` section of the front matter
- Avoid using bigger headings than an H3

### Adding case studies

Mandatory fields:
- `title`
- `banner-image`
- `teaser.jpg` - ideally a square image at 500x500px
- Note that all images must be must be a .png or .jpg
