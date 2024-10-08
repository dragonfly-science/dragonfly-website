# Dragonfly website

# Redevelopment

Redevelopment is happening on the `staging' branch.

## Open code

This is the repository for the website of [Dragonfly Data Science](http://www.dragonfly.co.nz). You are welcome to report any issues with the website, through [GitHub](https://github.com/dragonfly-science/website/issues). If you really enjoy fixing other peoples' stuff, pull requests would also be appreciated!

You are welcome to fork this repository and use it as a basis for your own projects. Text content
and code on this website are copyright Dragonfly Limited but are licenced for re-use under a [Creative Commons International Attribution 4.0 licence](https://creativecommons.org/licenses/by/4.0/) (see [LICENSE](https://github.com/dragonfly-science/website/blob/master/LICENSE) for terms and conditions). Please note that this
licence does not apply to any logos, emblems and trade marks on the website or
to the website’s design elements or to any photography, imagery, or publications.
Copyright of those specific items may not be held by Dragonfly Limited. Unless indicated
otherwise, those specific items may not be re-used without express permission.

## Hakyll and Docker

The site is statically generated from the source. This means that it is compiled,
and produces static files that are bundled up and served from the webserver. It uses the [Hakyll](http://jaspervdj.be/hakyll/index.html) static site library,
which is managed by the code in the `haskell/` directory. There is some [Docker](http://www.docker.com)
magic going on to get a build system up and running on a linux server. Ideally, you can check out the
code and run `make develop` to get started.

## Notes

#### This git repository is all there is

There is no database behind the site (other than the git repository). This means the website is static, and fully versioned. with all the collaborative benefits of git available.The content for the site is organised under the `content/` folder. Most of the folders there should be fairly self explanatory. If you need to edit the site,
these are the files to make changes to.

For example, to add a new news post you need to create a new file and directory
in the `content/news/` directory.

`2015-01-02-my-exciting-blog-post.md`

This file has the content for the post. At the top of the file is a metadata section that can include information such as title, teaser, and author.

`2015-01-02-my-exciting-blog-post.md/`

A directory where all other associated files can go, such as a image files and their associated description files

#### Adding news posts

- `teaser.jpg` - ideally a square image at 960px x 960p
- banner - link this in the `banner-image` section of the front matter
- Avoid using bigger headings than an H3

#### Adding case studies

Mandatory fields:

- `title`
- `banner-image`
- `teaser.jpg` - ideally a square image at 500x500px
- Note that all images must be must be a .png or .jpg

#### The compiler defines how to interpret the files

The file `haskell/Site.hs` defines how to interpret the files, and how to map
them to urls (routes), which templates to use, and what fields are defined
in the templates.

### Deployment is from the release branch

The release branch is automatically deployed. You can manually merge from master or create a
pull request. Creating a pull request on github from the master branch to the release branch
is the preferred method of deploying.

# Redevelopment

New front end development is taking place on the staging branch.
