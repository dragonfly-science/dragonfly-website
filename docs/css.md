# CSS

CSS for the website is written for postcss (https://postcss.org/), primarily 
using the following pluigns:

+ autoprefixer
+ postcss-font-magician
+ postcss-import
+ precss

In combination these plugins allow us to have css that is vendor-prefixed, can
be modulated (i.e. we can import partials as with other pre-processors like
sass), can be nested.

---

<!-- @import "[TOC]" {cmd="toc" depthFrom=2 depthTo=6 orderedList=false} -->

<!-- code_chunk_output -->

- [Tailwind](#tailwind)
- [Fonts](#fonts)
- [Code location](#code-location)
- [Structure](#structure)
- [Methodology](#methodology)
  - [Naming convention](#naming-convention)
  - [Responsiveness](#responsiveness)
- [PurgeCSS](#purgecss)

<!-- /code_chunk_output -->

## Tailwind

The code is primarily written using the Tailwind framework (https://tailwindcss.com/).

This is a utility framework - it provides css classes for a number of css
attributes, which when combined allow you to build up css elements relatively
quickly & easily.

It can be further customised via the `/tailwind.config.js` file.

## Fonts

The site uses the font `Omnes Pro` which is loaded from typekit.

There is also a custom font (called `dragonfly`) which is built from the svg 
images in the `/images/icons` folder. It is built via a npm module `glyphs2font`
which is called from the main `make develop` command. If you need to run this
manually it can be called via `npm run fonts`.

To allow new icons to be added to the font, modify `fonts.yaml` & add the new
icon:

```yaml
glyphs:
  - ...
  - glyph: ./content/images/icons/<icon-name>.svg
    name: <icon-name>
    code: 0xE00X
```

**Note:**

Tailwind supplies a postcss function `@apply` to allow you to reuse existing
css. Due to how we're loading the font icon css into the browser, you will not
be able to apply this to any of the icon classes. Instead, add the appropriate
icon class directly to the html.

## Code location

All css is located in the `/content/stylesheets/` directory.

## Structure

All files should be named `*.src.css` in order to make sure that the processing
only looks for those files & not `*.css`.

The main file is `main.src.css`. When compiled, it creates `dragonfly.css`

The css is broken into multiple directories corresponding to the element types:

+ _grid_: Grid layout & cells.
+ _layout_: Layouts for specific elements & components.
+ _navigation_: Main navigation & navigable elements such as links & buttons.
+ _tiles_: Additional grid tile elements.
+ _typography_: General typographical styles.
+ _utilities_: Additional utility classes.

## Methodology

Where possible, any CSS that is created will simply extend Tailwind classes via
the `@apply` function - e.g.:

```css
.grid-cell {
    @apply bg-white mb-8 w-full max-w-full;
}
```

### Naming convention

We use the **BEM** naming comvention (http://getbem.com/naming/)

### Responsiveness

Tailwind provides a number of breakpoints out of the box (https://tailwindcss.com/docs/breakpoints).
We additionally have a breakpoint called `wd` (`min-width: 1660px`).

Tailwind uses a mobile first approach (i.e. code with no breakpoint assumes
we're writing for a mobile device), which we will adhere to as well.

Where responsiveness needs to be added to a file, we aim to create separate
blocks for each, rather than adding breakpoints within the code. e.g:

**Desirable:**

```css
/* Grid cells that are intended to utilise gutters. */
.grid-cell {
    @apply bg-white mb-8 w-full max-w-full;
}

@screen sm {
    .grid-cell {
        max-width: calc(50% - 1rem);
    }
}

@screen lg {
    .grid-cell {
        max-width: calc(33% - 1rem);
    }
}

@screen xl {
    .grid-cell {
        max-width: calc(25% - 2rem);
    }
}
```

**Undesirable:**

```css
/* Grid cells that are intended to utilise gutters. */
.grid-cell {
    @apply bg-white mb-8 w-full max-w-full;

    @screen sm {
        max-width: calc(50% - 1rem);
    }

    @screen lg {
        max-width: calc(33% - 1rem);
    }

    @screen xl {
        max-width: calc(25% - 2rem);
    }
}
```

## PurgeCSS

When the css is compiled for production, any unused css is removed via purgecss
(https://www.purgecss.com/). It scans the html documents & templates & strips 
out any css that is not in use (Tailwind can be especially large if not
compressed).
