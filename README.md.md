---


---

<h1 id="dragonfly-website">Dragonfly website</h1>
<h2 id="open-code">Open code</h2>
<p>This is the repository for the website of <a href="http://www.dragonfly.co.nz">Dragonfly Data Science</a>. You are welcome to report any issues with the website, through <a href="https://github.com/dragonfly-science/website/issues">GitHub</a>. If you really enjoy fixing other peoples’ stuff, pull requests would also be appreciated!</p>
<p>You are welcome to fork this repository and use it as a basis for your own projects. Text content<br>
and code on this website are copyright Dragonfly Limited but are licenced for re-use under a <a href="https://creativecommons.org/licenses/by/4.0/">Creative Commons International Attribution 4.0 licence</a> (see <a href="https://github.com/dragonfly-science/website/blob/master/LICENSE">LICENSE</a> for terms and conditions). Please note that this<br>
licence does not apply to any logos, emblems and trade marks on the website or<br>
to the website’s design elements or to any photography, imagery, or publications.<br>
Copyright of those specific items may not be held by Dragonfly Limited. Unless indicated<br>
otherwise, those specific items may not be re-used without express permission.</p>
<h2 id="hakyll-and-docker">Hakyll and Docker</h2>
<p>The site is statically generated from the source. This means that it is compiled,<br>
and produces static files that are bundled up and served from the webserver. It uses the <a href="http://jaspervdj.be/hakyll/index.html">Hakyll</a> static site library,<br>
which is managed by the code in the <code>haskell/</code> directory.  There is some <a href="http://www.docker.com">Docker</a><br>
magic going on to get a build system up and running on a linux server. Ideally, you can check out the<br>
code and run <code>./run.sh develop</code> to get started.</p>
<h2 id="notes">Notes</h2>
<h4 id="this-git-repository-is-all-there-is">This git repository is all there is</h4>
<p>There is no database behind the site (other than the git repository). This means the website is static, and fully versioned, with all the collaborative benefits of git available.The content for the site is organised under the <code>content/</code> folder. Most of the folders there should be fairly self explanatory. If you need to edit the site,<br>
these are the files to make changes to.</p>
<p>For example, to add a new new post you need to create a new file and directory<br>
in the <code>content/posts/</code> directory.</p>
<p><code>2015-01-02-my-exciting-blog-post.md</code></p>
<p>This file has the content for the post. At the top of the file is a metadata section that can include information such as title, teaser, and author.</p>
<p><code>2015-01-02-my-exciting-blog-post.md/</code></p>
<p>A directory where all other associated files can go, such as a image files and their associated description files</p>
<h4 id="adding-news-posts">Adding news posts</h4>
<ul>
<li><code>teaser.jpg</code> - ideally a square image at 500x500px</li>
<li>banner - link this in the <code>banner-image</code> section of the front matter</li>
<li>Avoid using bigger headings than an H3</li>
</ul>
<h4 id="adding-case-studies">Adding case studies</h4>
<p>Mandatory fields:</p>
<ul>
<li><code>title</code></li>
<li><code>banner-image</code></li>
<li><code>teaser.jpg</code> - ideally a square image at 500x500px</li>
<li>Note that all images must be must be a .png or .jpg</li>
</ul>
<h4 id="the-compiler-defines-how-to-interpret-the-files">The compiler defines how to interpret the files</h4>
<p>The file <code>haskell/Site.hs</code> defines how to interpret the files, and how to map<br>
them to urls (routes), which templates to use, and what fields are defined<br>
in the templates.</p>
<h4 id="version-and-user-control-is-managed-by-git">Version and user control is managed by git</h4>
<p>One big advantage with this approach comes from git and<br>
<a href="https://www.github.com/dragonfly-science">GitHub</a>, which gives us good version<br>
control and user management respectively. When code changes are pushed to the master branch of the<br>
<a href="https://www.github.com/dragonfly-science/website">GitHub repo</a>, our<br>
continuous integration system will update the <a href="https://www-dev.dragonfly.co.nz">staging site</a>.<br>
This takes less than a minute. If you are collaborating with us, we can give you a username and<br>
password for the staging site.</p>
<h4 id="html-templates-and-css">HTML templates and CSS</h4>
<p>HTML templates for the project are in <code>content/templates</code>. A typical page has the following structure:</p>
<pre><code>&lt;html&gt;
  &lt;head&gt;
  &lt;/head&gt;
  &lt;body&gt;
    &lt;header&gt;
      &lt;nav&gt;
      &lt;/nav&gt;
    &lt;/header&gt;
    &lt;main&gt;
      &lt;div class="container"&gt;
        &lt;div class="wide"&gt;&lt;/div&gt;
      &lt;/div&gt;
      &lt;div class="container"&gt;
        &lt;div class="side-bar"&gt;&lt;/div&gt;
        &lt;div class="content"&gt;&lt;/div&gt;
      &lt;/div&gt;
    &lt;/main&gt;
    &lt;footer&gt;
      &lt;div class="container"&gt;
      &lt;/div&gt;
    &lt;/footer&gt;
  &lt;/body&gt;
&lt;/html&gt;
</code></pre>
<p>The html body is divided into three components: the header, which contains the<br>
navigation, the main block, which contains most of the page, and the footer,<br>
which contains the contact information. The container element sets the margins, and all<br>
content that is not full width should be inside a container block. Typical page<br>
content is inside a wide or a content block. The default template includes everything outside<br>
the main block. Page templates should include container and content blocks as appropriate.</p>
<p>The layout uses the <a href="http://www.bourbon.io">Bourbon</a> SASS system for managing the CSS and the responsive<br>
design. Breakpoints are named after mountain bike trails in Aro Valley. There is a mysterious order to them.</p>
<ul>
<li><a href="http://www.trailforks.com/trails/transient/">$transient</a>: smallest</li>
<li><a href="http://tracks.org.nz/track/show/851">$highbury-fling</a>: smallish</li>
<li><a href="http://www.trailforks.com/trails/clinical/">$clinical</a>: medium</li>
<li><a href="http://www.trailforks.com/trails/serendipity-16954/">$serendipity</a>: large</li>
</ul>
<h3 id="deployment-is-from-the-release-branch">Deployment is from the release branch</h3>
<p>The release branch is automatically deployed. You can manually merge from master or create a<br>
pull request. Creating a pull request on github from the master branch to the release branch<br>
is the preferred method of deploying.</p>

