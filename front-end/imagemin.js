const imagemin = require('imagemin')
const imageminPngquant = require('imagemin-pngquant')
const imageminJpegoptim = require('imagemin-jpegoptim')
const imageminSvgo = require('imagemin-svgo')
const fs = require('file-system')

fs.recurse(
  '../_site',
  [
    'images/**/*.{jpg,png,svg}',
    'news/**/*.{jpg,png,svg}',
    'people/**/*.{jpg,png,svg}',
    'work/**/*.{jpg,png,svg}',
    'what-we-do/**/*.{jpg,png,svg}',
  ],
  (filepath, filename) => {
    if (!filename) {
      return
    }

    const dir = filepath.substr(0, filepath.lastIndexOf('/'))
    const ext = filename.substr(filename.indexOf('.'))

    async function process() {
      let plugins = []
      switch (ext) {
        case '.jpg':
          plugins = [
            imageminJpegoptim({
              progressive: true,
              max: 80,
            }),
          ]
          break
        case '.jpeg':
          plugins = [
            imageminJpegoptim({
              progressive: true,
              max: 80,
            }),
          ]
          break
        case '.png':
          plugins = [imageminPngquant()]
          break
        case '.svg':
          plugins = [imageminSvgo()]
          break
        default:
          break
      }

      try {
        const processed = await imagemin([filepath], {
          destination: dir,
          plugins,
          glob: true,
        })
        console.info(`Processing completed for ${processed[0].sourcePath}`)
      } catch (error) {
        console.warn(`Error processing ${filename}`)
      }
    }

    process()
  }
)
