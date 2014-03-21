#! /usr/bin/env node

fs = require('fs')
path = require('path')

tmpPath = path.join(__dirname, '../tmp')


pdfFiles = fs.readdirSync(tmpPath).filter(function(file){
  return file.indexOf('.pdf') > 1
})
expiredFiles = pdfFiles.filter(function(file){
  stat = fs.statSync(tmpPath + '/' + file)

  created_at = new Date(stat.ctime)
  expiration_time = new Date(stat.ctime)
  expiration_time.setMinutes(expiration_time.getMinutes() + 30)
  now = new Date()

  if (now.getTime() - expiration_time > 0) {
    return file
  } else {
    return
  }
})

if (expiredFiles.length > 0) {
  console.log('Found ' + expiredFiles.length + ' expired PDFs')

  args = process.argv.slice(2)
  // delete files only if option '-d' is given
  canDelete = args.indexOf('-d') == 0
  expiredFiles.forEach(function(file){
    if (canDelete) {
      process.stdout.write('Removing ' + file + '...')
      fs.unlinkSync(tmpPath + '/' + file)
      console.log('done!')
    } else {
      console.log(file)
    }
  })
  if (!canDelete) {
    console.log('To remove the expired files pass the option -d')
  }
} else {
  console.log('Nothing to clean.')
}
