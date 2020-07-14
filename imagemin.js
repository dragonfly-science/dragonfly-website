const imagemin = require('imagemin')
const imageminPngquant = require('imagemin-pngquant')
const imageminJpegoptim = require('imagemin-jpegoptim')
const imageminSvgo = require('imagemin-svgo')
const fs = require('file-system')

fs.recurse(
  '_site',
  [
    'images/**/*.{jpg,png,svg}',
    'news/**/*.{jpg,png,svg}',
    'people/**/*.{jpg,png,svg}',
    'work/**/*.{jpg,png,svg}',
    'what-we-do/**/*.{jpg,png,svg}',
  ],
  (filepath, filename, relative) => {
    const dir = filepath.substr(0, filepath.lastIndexOf('/'))
    const ext = relative.substr(relative.indexOf('.'))

    const process = async () => {
      try {
        switch (ext) {
          case '.jpg':
            await imagemin([filepath], {
              destination: dir,
              plugins: [
                imageminJpegoptim({
                  progressive: true,
                }),
              ],
            })
            break
          case '.png':
            await imagemin([filepath], {
              destination: dir,
              plugins: [imageminPngquant()],
            })
            break
          case '.svg':
            await imagemin([filepath], {
              destination: dir,
              plugins: [imageminSvgo()],
            })
            break
          default:
            break
        }
      } catch (error) {}
    }

    process()
  }
)
