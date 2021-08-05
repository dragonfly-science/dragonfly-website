const imagemin = require('imagemin')
const imageminPngquant = require('imagemin-pngquant')
const imageminJpegoptim = require('imagemin-jpegoptim')
const imageminSvgo = require('imagemin-svgo')
const fs = require('file-system')

const process = async (dir, filepath, filename, ext) => {
  let plugins = []
  switch (ext) {
    case '.jpg':
      plugins = [
        imageminJpegoptim({
          progressive: true,
          max: 75,
        }),
      ]
      break
    case '.jpeg':
      plugins = [
        imageminJpegoptim({
          progressive: true,
          max: 75,
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

fs.recurse(
  '../_site',
  [
    'images/**/*.{jpg,jpeg,png,svg}',
    'landing-pages/**/*.{jpg,jpeg,png,svg}',
    'news/**/*.{jpg,jpeg,png,svg}',
    'people/**/*.{jpg,jpeg,png,svg}',
    'resources/**/*.{jpg,jpeg,png,svg}',
    'what-we-do/**/*.{jpg,jpeg,png,svg}',
    'work/**/*.{jpg,jpeg,png,svg}',
  ],
  (filepath, filename) => {
    if (!filename) {
      return
    }

    const dir = filepath.substr(0, filepath.lastIndexOf('/'))
    const ext = filename.substr(filename.indexOf('.'))

    process(dir, filepath, filename, ext)
  }
)
